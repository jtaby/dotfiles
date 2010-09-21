
echo "Time to change your default shell to zsh!"
chsh -s /bin/zsh

cd autojump
chmod +x install.zsh
./install.zsh
cd ..

ln -s ~/dotfiles/oh-my-zsh ~/.oh-my-zsh
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/vim ~/.vim
ln -s ~/dotfiles/vimrc ~/.vimrc
ln -s ~/dotfiles/gvimrc ~/.gvimrc
ln -s ~/dotfiles/screenrc ~/.screenrc
