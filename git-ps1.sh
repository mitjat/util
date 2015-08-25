# Light weight git completions

# Inspired by:
# .git-completion.bash by Shawn O. Pearce <spearce@spearce.org>
# But it was too slow in Source.

# Get the full path to the .git folder if it exists
# Pass args to printf
git-root()
{
  local wd="$PWD"
  until [[ -z "$wd" ]]; do # Loop will hang if $PWD doesn't start with /
    if [[ -d "${wd}/.git" ]]; then
      printf "$@" "%s" "${wd}/.git"
      return 0
    fi
    wd="${wd%/*}"
  done
  return 1
}

# Get the current branch if it exists. Pass args to printf
git-current-branch()
{
  if git-root -vgit_root; then
    local git_head="${git_root}/HEAD"
    local cb
    if [[ -f "$git_head" ]]; then
      read < "$git_head"
      case $REPLY in
        "ref: "*) cb="${REPLY:16}" ;; # ref: refs/heads/your/branch
        *) cb="${REPLY:0:8}" ;; # hash (probably) - take first 8
      esac
      printf "$@" "%s" "$cb"
      return 0
    fi
  fi
  return 1
}

# Generate a PS1 addition. Replacement for __git_ps1 from .git-completion.bash
# git-ps1 (-e) (format)
#   -e     -- Add some extra data
#   format -- printf format. Default is just "%s"
git-ps1()
{
  local git_branch=""
  if git-current-branch -vgit_branch; then
    local fmt="%s"
    local git_ps1="$git_branch"
    if [[ "$1" == "-e" ]]; then
      shift 1
      # gotchya! git-current-branch sets git_root
      [[ "$PWD" == "$git_root"* ]] && git_ps1="${git_ps1}|GIT_DIR"
      [[ -d "${git_root}/rebase-merge" ]] && git_ps1="${git_ps1}|REBASE"
    fi
    [[ ! -z "$1" ]] && fmt="$1"
    printf "$fmt" "${git_ps1}"
    return 0
  fi
  return 1
}
