#!/usr/bin/python3

import argparse
import os.path
import re
import subprocess
import sys
import time
import shlex

from github import Github, PullRequest   # pip3 install PyGithub


def get_stdout(cmd: str) -> str:
    return subprocess.run(shlex.split(cmd), capture_output=True).stdout.decode('utf8').strip()


def parse_origin() -> (str, str):
    origin = get_stdout('git remote get-url origin')
    m = re.search(r'github.com.*?([\w_-]+)/([\w_-]+)(?:.git)?', origin)
    if m is None:
        raise Exception(
            f'Git origin URL is "{origin}", cannot parse Github user and repo')
    return (m.group(1), m.group(2))


def ellipsis(s: str, max_len: int) -> str:
    if len(s) <= max_len:
        return s
    else:
        return s[:max_len-3] + '...'


def connect_to_github() -> Github:
    token_path = os.path.expanduser("~")+"/.github_token"
    if not os.path.isfile(token_path):
        raise "Path does not exist: "+token_path
    return Github(open(token_path).read().strip())


def local_cleanup(pr: PullRequest):
    branch = pr.head.ref
    print(
        f"Branch {branch} has been merged as PR #{pr.number}; cleaning up locally.")
    github_sha = pr.head.sha
    local_sha = get_stdout(f"git rev-parse {branch}")
    if github_sha == local_sha:
        print(
            f"Branch points to {local_sha} both on GitHub and locally. Deleting local branch.")
        os.system(
            f"[ $(git rev-parse --abbrev-ref HEAD) -eq {branch} ] && git checkout master; git branch -D {branch}")
        # We deleted the branch locally, GitHub did it remotely. Lastly, remove tracking branch.
        os.system("git fetch --prune")
    else:
        print(
            f"Branch points to {local_sha} locally but to {github_sha} on GitHub. Renaming local branch to BACKUP_{branch} just in case.")
        os.system(f"git branch -m {branch} BACKUP_{branch}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--pr', metavar='N', type=int,
                        help='Number of the PR to submit')
    args = parser.parse_args()

    gh = connect_to_github()
    repo = gh.get_repo("%s/%s" % parse_origin())

    while True:
        pr = repo.get_pull(args.pr)
        print(time.strftime(r'%y-%m-%d %H:%M') +
              f'  [PR #{pr.number}: {ellipsis(pr.title, 40)}]    ', end='')
        if pr.is_merged():
            print(f"PR is already merged!")
            local_cleanup(pr)
            break
        ci_status = repo.get_commit(
            sha=pr.head.sha).get_combined_status().state

        is_behind_master = pr.mergeable_state == 'behind'
        if pr.mergeable_state == 'unknown':
            print('Mergeable state is "unknown". This can sometimes be resolved by trying to sync to master. Attempting that now.')
            is_behind_master = True
        if is_behind_master:
            print(f"PR is behind master. Trying to merge master into branch.")
            if pr.update_branch():
                print(
                    "Branch updated (= master was merged into it) on GitHub (but not locally!). Retrying to merge PR.")
                # GitHub backend is eventually-consistent; give it some time to catch up
                time.sleep(30)
                continue
            else:
                print("New master cannot be automatically merged into branch, or there is another reason branch is unmeregeable. Aborting.")
                break

        if pr.mergeable_state == 'clean':
            try:
                print(
                    f"STATUS IS GOOD! Submitting. Status: {ci_status} {pr.mergeable_state}")
                print(pr.merge(merge_method='squash',
                               commit_message=(pr.body or '')))
                print("PR merged!")
                local_cleanup(pr)
                break
            except Exception as e:
                print(
                    f"Cannot merge (yet?): {e.args[1]['message']} | Status: {ci_status} {pr.mergeable_state}")
        print(f"Status: {ci_status} {pr.mergeable_state}")
        time.sleep(5*60)  # seconds
