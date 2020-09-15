#!/bin/bash

# Creates a new GitHub PR out of this branch.

set -euo pipefail

pr="$(hub pr list -h $(git branch-name) -f '%I')"

if [[ "$pr" != "" ]]; then
  echo "This branch already has a PR: $pr"
else
  git push --set-upstream origin $(git branch-name)
  hub pull-request -e
  #add_changelog.sh
fi

# Open PR in browser
which xdg-open >/dev/null 2>/dev/null &&
  xdg-open "$(hub pr list -h $(git branch-name) -f %U)"
