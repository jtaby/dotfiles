
#------------------------------------------------------
#------------------------------------------------------

# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set to the name theme to load.
# Look in ~/.oh-my-zsh/themes/
export ZSH_THEME="prose"

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/opt/bin:/opt/local/bin:/opt/local/sbin
export PATH=/Users/majd/.gem/ruby/1.8/bin:/Users/majd/dotfiles/bin:/Users/majd/bin:$PATH
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/usr/X11/bin:$PATH

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

function j { local new_path="$(autojump $@)";if [ -n "$new_path" ]; then echo -e "\\033[31m${new_path}\\033[0m"; cd "$new_path";fi }

#------------------------------------------------------
#------------------------------------------------------

# SSH aliases
alias vaio="ssh -p 2222 majd@taby.dnsalias.com"

# GIT aliases
alias gw="git-wtf"
alias gs="git status"
alias gc="git commit -am"
alias gp="git push"
alias ga="git add"
alias gu="git fetch && git rebase origin/master"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %C(cyan)%an%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

function go() {
  echo "Commiting your changes..."
  ga .
  gc $1
  echo ""

  echo "Making sure your local branch is up-to-date..."
  gu
  echo ""

  echo "Pushing your changes..."
  git push origin $2
}

function gcl() {
  git clone $1
  git submodule init 
  git submodule update
}

#------------------------------------------------------
#------------------------------------------------------

function compress() {
  tar cvzf $@
}

function uncompress() {
  if [ -d "$2" ]; then
    tar xvzf $1 -C $2
  else
    echo "$2 is not a directory!"
  fi
}

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


