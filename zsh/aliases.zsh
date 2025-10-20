# -------- Aliases
#
# File system
#
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd="zd"
alias cat="bat"
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Directories
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias ros-init="source ros-env"
alias conda-init='eval "$($HOME/miniconda3/bin/conda shell.zsh hook)"'

# Git
alias gl="git log --oneline --graph"
alias gs="git status"
alias ga="git add"
alias gp="git push"
alias gc="git commit"
