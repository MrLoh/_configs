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

# asdf
rm -f ~/.asdfrc
ln -s $PWD/asdfrc ~/.asdfrc

rm -f ~/.tool-versions
ln -s $PWD/tool-versions ~/.tool-versions

rm -f ~/.default-npm-packages
ln -s $PWD/default-npm-packages ~/.default-npm-packages
rm -f ~/.default-python-packages
ln -s $PWD/default-python-packages ~/.default-python-packages
rm -f ~/.default-gems
ln -s $PWD/default-ruby-gems ~/.default-gems

# poetry
rm -f ~/Library/Preferences/pypoetry/config.toml
ln -s $PWD/poetryconfig ~/Library/Preferences/pypoetry/config.toml
