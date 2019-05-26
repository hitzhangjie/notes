设置shell的PS1变量，自动显示repo所处的分支和状态，脚本如下，在.bashrc中source一下就可以了。

```bash
#!/bin/bash -e

function init {
    case $OSTYPE in
        linux*)
            MAGENTA='\e[0;31m'
            GREEN='\e[0;32m'
            ORANGE='\e[1;33m'
            BLUE='\e[0;34m'
            PURPLE='\e[0;35m'
            WHITE='\e[0;37m'
            RESET='\e[0m'
            ;;
        darwin*)
            MAGENTA="\033[1;31m"
            GREEN="\033[1;32m"
            ORANGE="\033[1;33m"
            BLUE="\033[1;34m"
            PURPLE="\033[1;35m"
            WHITE="\033[1;37m"
            RESET="\033[m"
            ;;
    esac
}
init

function git_color {
  local git_status="$(git status 2> /dev/null)"

  if [[ ! $git_status =~ "working directory clean" ]]; then
    echo -e $MAGENTA
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
    echo -e $ORANGE
  elif [[ $git_status =~ "nothing to commit" ]]; then
    echo -e $GREEN
  else
    echo -e $PURPLE
  fi
}

function git_branch {
  local git_status="$(git status 2> /dev/null)"
  local on_branch="On branch ([^${IFS}]*)"
  local on_branch_zh="位于分支 ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo "($branch)"
  elif [[ $git_status =~ $on_branch_zh ]]; then
    local branch=${BASH_REMATCH[1]}
    echo "($branch)"
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo "($commit)"
  fi
}

#export PS1="\[${PURPLE}\]\u\[$GREEN\]@\[$ORANGE\]\h \[$BLUE\]\w \$(git_color)\$(git_branch)\[$RESET\] \[$GREEN\]\$\[$RESET\] "
export PS1="\[${PURPLE}\]\u\[$GREEN\]@\[$ORANGE\]\h \[$BLUE\]\W \$(git_color)\$(git_branch)\[$RESET\] \[$GREEN\]\$\[$RESET\] "
export PS2="\[$ORANGE\]→ \[$RESET\]"

```





