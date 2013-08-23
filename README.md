##Bash Configuration Files

Config files in a separate forlder for easy portability.

### To Use

	cd ~
	git clone http://github.com/zaffudo/dotfiles.git ~/.dotfiles

	ln -s ~/.dotfiles/bash_profile ~/.bash_profile
	ln -s ~/.dotfiles/bashrc ~/.bashrc
	ln -s ~/.dotfiles/inputrc ~/.inputrc
	ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
	ln -s ~/.dotfiles/vim ~/.vim

	cd ~/.dotfiles
	git submodule update --init --recursive
	git submodule update --recursive
