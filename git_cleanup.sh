#!/bin/bash

# Set difference. Takes two strings, treats each a a set of space-separated words.
# Prints a space-separated string containing only the words that appear only in the first input.
set_sub() {
  [[ $# == 2 ]] || { echo "set_sub got $# args, needs 2"; exit 1; }
  comm -23 <(echo "$1" | tr ' ' $'\n' | sort) <(echo "$2" | tr ' ' $'\n' | sort) | tr $'\n' ' '
}

# Update remote-tracking branches branches.
# Remove remote-tracking branches (origin/...) for which the tracked branch
# does not exist any more.
git fetch --prune

main="$(git master-branch)"

{
  echo "### Uncomment the branches that should be removed"
  echo
  echo "### Gone branches (no longer on origin):"
  gone="$(git gone)"
  if [[ "$gone" == "" ]]; then echo "# (none)"; else echo "$gone"; fi
  echo
  echo "### Branches that have been merged into $main"
  for br in $(
	  git log "$main" | sed -En "s/Merge branch '(.*)' into '$main'/\1/p" | tr -d ' ';  # gitlab format
	  git log "$main" | sed -En 's/Merge pull request #.+ from [^\/]+?\/(.*)/\1/p' | tr -d ' ';  # github format
  ); do
    git br | grep --quiet -w $br && echo $br
  done
  echo
  echo "### Active (!) $USER branches, by age:"
  git for-each-ref \
    --sort committerdate \
    --format $'# %(refname:short)\t# %(authordate:short) (%(authordate:relative))' \
    "refs/heads/$USER/"
} >/tmp/branches_to_delete

vi /tmp/branches_to_delete
local_to_delete="$(cat /tmp/branches_to_delete | sed -s 's/#.*//g' | tr '\n' ' ' | sed -E 's/\s+/ /g; s/^ *//g; s/ *$//g;')"

# Find all branches on origin that belong to $USER, but we have no
# equivalent branch locally (or WILL not have, after deletions of local branches).
remote="$(git br -r | grep -v BACKUP | grep -E "^ *origin/$USER" | sed "s/^.*$USER/$USER/g")"
local="$(git br | grep -v BACKUP | grep -E "^ *$USER" | sed "s/^.*$USER/$USER/g")"
local="$(set_sub "$local" "$local_to_delete")"
remote_to_delete="$(set_sub "$remote" "$local")"

if [[ "${local_to_delete}${remote_to_delete}" == "" ]]; then
  echo "All caught up!"
else
  echo "RUN:"
  [[ "$local_to_delete"  != "" ]] && echo "  git branch -D $local_to_delete"
  [[ "$remote_to_delete" != "" ]] && echo "  git push origin --delete $remote_to_delete"
fi

