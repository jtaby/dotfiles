#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install dependencies
brew install starship
brew install fzf

ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/.zprofile" ~/.zprofile
ln -sf "$DOTFILES_DIR/.tmux.conf" ~/.tmux.conf

# Link the whole fish directory, moving aside a real one if present
mkdir -p ~/.config
if [ -d ~/.config/fish ] && [ ! -L ~/.config/fish ]; then
    mv ~/.config/fish ~/.config/fish.backup.$(date +%Y%m%d%H%M%S)
fi
ln -sfn "$DOTFILES_DIR/.config/fish" ~/.config/fish

echo "Dotfiles symlinked successfully!"
