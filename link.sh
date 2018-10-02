#!/bin/bash

# Git
rm ~/.gitconfig
ln -s ./gitconfig ~/.gitconfig

rm ~/.gitignore_global
ln -s ./gitignore ~/.gitignore_global

# fish
rm ~/.config/fish/config.fish
ln -s ./fishconfig ~/.config/fish/config.fish

rm -rf ~/.config/fish/functions
ln -s ./fishfunctions ~/.config/fish/functions

# bash
rm ~/.bashrc
ln -s ./bash_profile ~/.bash_profile

