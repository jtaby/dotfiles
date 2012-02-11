#------------------------------------------------------
# INITIALIZE SYSTEM CONFIGURATION
#------------------------------------------------------

# Path to your oh-my-zsh configuration.
export DOTFILES=$HOME/dotfiles
export PATH=$DOTFILES/bin:$PATH
export PATH=$HOME/bin:$PATH

for config_file ($DOTFILES/zsh.conf/lib/*.zsh) source $config_file
for config_file ($DOTFILES/zsh.conf/plugins/*.zsh) source $config_file
for config_file ($DOTFILES/private/*.zsh) source $config_file

fpath=($fpath $DOTFILES/zsh.conf/zcomp_functions)
autoload -U $DOTFILES/zsh.conf/zcomp_functions/*(:t)
autoload -U compinit
compinit

export EDITOR=vim

[[ -s "/Users/majd/.rvm/scripts/rvm" ]] && source "/Users/majd/.rvm/scripts/rvm" 
