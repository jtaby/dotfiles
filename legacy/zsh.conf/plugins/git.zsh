# Make git use colors in its output
git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto

function gco() {
  git checkout $@
}

function gd() {
  git diff $@
}

function gdm() {
  git diff $@ | mate
}
#
# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

# these aliases take advantage of the previous function
alias ggpull='git pull origin $(current_branch)'
alias ggpush='git push origin $(current_branch)'
alias ggrebase='git rebase origin/$(current_branch)'
alias ggl='gl origin/$(current_branch)'

alias gr='git rebase'
alias grcontinue='git rebase --continue'
alias grabort='git rebase --abort'
alias grskip='git rebase --skip'

alias gs="git status"
alias gc="git commit -m"
alias gp="git push"
alias ga="git add"
alias gf="git fetch"
alias gb="gbranch"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %C(cyan)%an%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gurl="git config --get remote.origin.url"
alias gclean="git clean -f"
alias gmate="git diff | mate"

#compdef ggpull=git
#compdef ggpush=git
