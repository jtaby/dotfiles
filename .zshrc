HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# starfish is used for the prompt
eval "$(starship init zsh)"

autoload -Uz history-beginning-search-backward history-beginning-search-forward

bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

alias l='ls -lah'
alias gst="git status"
alias glol="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'"
alias ga="git add"
alias gcmsg="git commit -m "
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"
alias gfa="git fetch --all"
alias gri="git rebase -i origin/develop"

current_branch() {
  git symbolic-ref --quiet --short HEAD
}

ggp() {
  local branch
  branch=$(current_branch) || return 1
  git push origin "$branch"
}

ggu() {
  local branch
  branch=$(current_branch) || {
    echo "Not on a branch (detached HEAD?)"
    return 1
  }
  git pull --rebase origin "$branch"
}
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.platformio/penv/bin"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# run builds and runs an iOS app from the current git worktree. run setup
# changes the settings of the repository.
run() { zsh ~/github/dotfiles/run.zsh "$@" }
