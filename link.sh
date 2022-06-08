#!/bin/bash

# Git
rm -f ~/.gitconfig
ln -s $PWD/gitconfig ~/.gitconfig

rm -f ~/.gitignore_global
ln -s $PWD/gitignore ~/.gitignore_global

# fish
rm -f ~/.config/fish/config.fish
ln -s $PWD/fishconfig ~/.config/fish/config.fish

rm -rf ~/.config/fish/functions
ln -s $PWD/fishfunctions ~/.config/fish/functions

# bash
rm -f ~/.bashrc
rm -f ~/.bash_profile
ln -s $PWD/bash_profile ~/.bash_profile

# zsh
rm -f ~/.zshrc
ln -s $PWD/zshrc ~/.zshrc
