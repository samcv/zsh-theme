# oh-my-zsh Bureau Theme

### NVM

ZSH_THEME_NVM_PROMPT_PREFIX="%B⬡%b "
ZSH_THEME_NVM_PROMPT_SUFFIX=""

### Git [±master ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[green]%}±%{$reset_color%}%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[blue]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STASHED="S"

bureau_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) \
  || ref=$(command git rev-parse --short HEAD 2> /dev/null) \
  || return
  print -r "${ref#refs/heads/}"
}

bureau_git_status() {
  local _STATUS=
  local MYNLNOW=$'\n'
  local RE_MATCH_PCRE=1
  # check status of files
  _INDEX=$(command git status -b -uno --porcelain 2> /dev/null)
  if [[ -n "$_INDEX" ]]; then
    if [[ $_INDEX =~ "(^|$MYNLNOW)[AMRD]. " ]]; then
        [[ $_bureau_debug ]] && echo staged 1>&2
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if [[ $_INDEX =~ "(^|$MYNLNOW).[MTD] " ]]; then
    [[ $_bureau_debug ]] && echo unstaged 1>&2
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if [[ $_INDEX =~ "(^|$MYNLNOW)\?\? " ]]; then
    [[ $_bureau_debug ]] && echo untracked 1>&2
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if [[ $_INDEX =~ "(^|$MYNLNOW)UU " ]]; then
    [[ $_bureau_debug ]] && echo unmerged 1>&2
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
     # check status of local repository
    if [[ "$_INDEX" =~ '^## .*ahead' ]]; then
        [[ $_bureau_debug ]] && echo ahead 1>&2
        _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
    fi
    if [[ "$_INDEX" =~ '^## .*behind' ]]; then
        [[ $_bureau_debug ]] && echo behind 1>&2
        _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
    fi
    if [[ "$_INDEX" =~ '^## .*diverged' ]]; then
        [[ $_bureau_debug ]] && echo diverged 1>&2
        _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
    fi
  else
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi   

  if command git rev-parse --verify refs/stash &> /dev/null; then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi
  print -r "$_STATUS"
}

bureau_git_prompt () {
  # Return early if we aren't in a git folder
  if [[ ! -d .git ]]; then
    # Use git rev-parse because it's many orders of
    # magnitude faster than git status (if not in git folder why waste your valuble time?)
    if ! git rev-parse --git-dir &> /dev/null; then
      return
    fi
  fi
  local _branch=$(bureau_git_branch)
  local _status=$(bureau_git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result $_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  print -r $_result
}


_PATH="%{$fg_bold[white]%}%~%{$reset_color%}"

if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
  _LIBERTY="%{$fg[red]%}#"
else
  _USERNAME="%{$fg_bold[white]%}%n"
  _LIBERTY="%{$fg[green]%}$"
fi
_USERNAME="$_USERNAME%{$reset_color%}@%m"
_LIBERTY="$_LIBERTY%{$reset_color%}"


get_space () {
  local STR=$1$2
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  (( LENGTH = ${COLUMNS} - $LENGTH ))
  # This is the fastest way I've found to repeat a character.
  # way better than the original
  printf " %.0s" {1..$LENGTH}
}

_1LEFT="$_USERNAME $_PATH"
_1RIGHT="[%*] "

bureau_precmd () {
  _1SPACES=$(get_space $_1LEFT $_1RIGHT)
  print -rP $'\n'"$_1LEFT$_1SPACES$_1RIGHT"
}
bureau_return_code () {
    print -r "%(?..%{$bg_bold[red]%}%? ↵%{$reset_color%})"
}
setopt prompt_subst
PROMPT='> $_LIBERTY '
RPROMPT='$(bureau_return_code) $(bureau_git_prompt)'

autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd
