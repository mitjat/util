#!/bin/bash

# Shows the diff of the current branch HEAD and its merge base.
# Assuming you usually rebase instead of merging master, this corresponds to all the changes made on the branch.
#
# Usage:
#   git_branchdiff.sh [<flags to git-diff>] [<branch>]

if [ -z "${1:-}" ]; then
  br="$(git rev-parse --abbrev-ref HEAD)"  # default: current branch
  args=""
else
  br=${!#}  # last positional arg
  args="${@:1:$#-1}"  # all args but the last one
fi

git diff $args $(git merge-base $br $(git master-branch)) $br
