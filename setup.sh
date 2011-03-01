cd ~/dotfiles
git submodules init
git submodules update

echo "
==============
Setting up rvm
==============
"

mkdir -p ~/.rvm/src/ && cd ~/.rvm/src && rm -rf ./rvm/ && git clone --depth 1 git://github.com/wayneeseguin/rvm.git && cd rvm && ./install

echo "
==============
Changing the default shell to zsh
==============
"
echo "!"
chsh -s /bin/zsh

echo "
==============
Changing the default shell to zsh
==============
"
cd autojump
chmod +x install.zsh
./install.zsh
cd ..

echo "
==============
Setting up all the symlinks
==============
"
mv ~/.oh-my-zsh ~/.oh-my-zsh.bak
ln -s ~/dotfiles/oh-my-zsh ~/.oh-my-zsh

mv ~/.gemrc ~/.gemrc.bak
ln -s ~/dotfiles/gemrc ~/.gemrc

mv ~/.zshrc ~/.zshrc.bak
ln -s ~/dotfiles/zshrc ~/.zshrc

mv ~/.screenrc ~/.screenrc.bak
ln -s ~/dotfiles/screenrc ~/.screenrc

mv ~/.git_layout.yml ~/.git_layout.yml.bak
ln -s ~/dotfiles/git_layout.yml ~/.git_layout.yml

mv ~/.tmux.conf ~/.tmux.conf.bak
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf

echo "
==============
Installing Janus
==============
"
git clone git://github.com/jtaby/janus.git ~/.vim
cd ~/.vim
rake
