#!/bin/bash

# Git
rm ~/.gitconfig
ln -s ~/configs/gitconfig ~/.gitconfig

rm ~/.gitignore_global
ln -s ~/configs/gitignore ~/.gitignore_global

# fish
rm ~/.config/fish/config.fish
ln -s ~/configs/fishconfig ~/.config/fish/config.fish

rm -rf ~/.config/fish/functions
ln -s ~/configs/fishfunctions ~/.config/fish/functions

# bash
rm ~/.bashrc
ln -s ~/configs/bashrc ~/.bashrc

