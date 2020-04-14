#!/bin/bash

# Adds a changelog entry for the current branch, assuming the branch corresponds to a GitHub PR.
# Coded to the specifics of Oasis/Towncrier changelog collection setup:
#  - Creates a .changelog/... file
#  - Adds it to a new commit
#  - Pushes the commit to origin
#
# Usage: add_changelog.sh [--strict]
#
# If --strict is given, will exit with non-zero status if repo seems ot not use the changelog.

set -euo pipefail

if ! [[ -d .changelog ]]; then
  echo "There is no .changelog dir; assuming this repo does not use changelogs. Exiting."
  if [[ "$flags" == "--strict" ]]; then exit 1; else exit 0; fi
fi

# Determine PR number
branch="$(git rev-parse --abbrev-ref HEAD)"
pr="$(hub pr list -h ${branch} -f '%I')"

# Check for existing changelog entries
old_changelog="$(find .changelog/ -name "${pr}"'*.md' -print -quit)"
if [[ "$old_changelog" != "" ]]; then
  echo "NOTE: $old_changelog already exists. Feel free to Ctrl-C out of this."
  echo ""
fi

# Determine type of change
select changelog_type in breaking feature bugfix doc internal trivial; do
  break
done

# Edit the file
path=".changelog/${pr}.${changelog_type}.md"
if [[ "$changelog_type" == "trivial" ]]; then
  touch $path
else
  [[ -s "$path" ]] && hub pr list -h "$branch" -f '%t%n%n%b%n' >"$path"  # Seed changelog with PR description
  vi "$path"
  [[ -s "$path" ]] || { 
    rm -f "$path"; echo "Empty changelog file; aborting."; break;
  }
fi

# Autoformat
prettier --write --print-width 78 --prose-wrap always "$path" || {
  echo "Did not autoformat the file; install prettier with 'npm i -g prettier'"
}

# Add to new commit
git status --porcelain | grep -E '^[^ ?]' -q && {
  # ^ "git status --porcelain" will list *staged* files with a status character in the first column of the line.
  #   Untracked files will have a status of "?".
  echo "Will not auto-commit; staging area is not empty"
  exit 1
}
git add -f "$path"
git commit -m 'Add changelog entry'
git push origin
