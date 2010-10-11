
#------------------------------------------------------
#------------------------------------------------------

# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set to the name theme to load.
# Look in ~/.oh-my-zsh/themes/
export ZSH_THEME="jtaby"

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/Users/majd/.seeds/bin:/Users/majd/src/depot_tools:/Users/majd/dotfiles/bin:/opt/local/bin:/opt/local/sbin:/Users/majd/.gem/ruby/1.8/bin:/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/usr/local/bin:/opt/local/bin:/opt/bin:/Users/majd/bin:/Users/majdtaby/.gem/ruby/1.8/bin

# Make git use colors in its output
git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto

# 10 second wait if you do something that will delete everything.  I wish Id had this before...
setopt RM_STAR_WAIT

function title {
    if [[ $TERM == "screen"* ]]; then
        print -nR $'\033k'$1$'\033\\'
        print -nR $'\033]0;'$2$'\a'
    fi
}

function precmd {
    title "zsh" "$PWD"
}   

function preexec {
    emulate -L zsh
    local -a cmd; cmd=(${(z)1})
    title "$cmd[1]:t" "$cmd[2,-1]"
}

# Which plugins from the plugins/ directory to load
plugins=(git osx textmate gem github)

#------------------------------------------------------
#------------------------------------------------------

#autojump
#Copyright Joel Schaerer 2008, 2009
#This file is part of autojump

#autojump is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#autojump is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with autojump.  If not, see <http://www.gnu.org/licenses/>.

function autojump_preexec() {
    { (autojump -a "$(pwd -P)"&)>/dev/null 2>>|${HOME}/.autojump_errors ; } 2>/dev/null
}

typeset -ga preexec_functions
preexec_functions+=autojump_preexec

alias jumpstat="autojump --stat"

function j { local new_path="$(autojump $@)";if [ -n "$new_path" ]; then echo -e "${new_path}"; cd "$new_path";fi }

#------------------------------------------------------
#------------------------------------------------------

# SSH aliases
alias vaio="ssh -p 2222 majd@taby.dnsalias.com"

# GIT aliases
alias gs="git status"
alias gd="git diff --color"
alias gc="git commit -am"
alias gp="git push"
alias ga="git add"
alias gb="gbranch"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %C(cyan)%an%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

alias gclean="git clean -f"
alias gmate="git diff | mate"

#------------------------------------------------------
#------------------------------------------------------

# I could never remember the arguments for tar
function compress() {
  tar cvzf $@
}

function uncompress() {
  if [ -d "$2" ]; then
    tar xvzf $1 -C $2
  else
    mkdir $2
    tar xvzf $1 -C $2
  fi
}

# Make vim ask for sudo password if I try to open a 
# privileged file
function vim {
       LIMIT=$#
       for ((i = 1; i <= $LIMIT; i++ )) do
               eval file="\$$i"
               if [[ -e $file && ! -O $file ]]
               then
                       otherfile=1
               else

               fi
       done
       if [[ $otherfile = 1 ]]
       then
               sudo vim "$@"
       else
               command vim "$@"
       fi
}

#------------------------------------------------------
#------------------------------------------------------

source "$HOME/.rvm/scripts/rvm"
