#!/bin/bash

# Git
rm ~/.gitconfig
ln -s ~/Repos/_configs/gitconfig ~/.gitconfig

rm ~/.gitignore_global
ln -s ~/Repos/_configs/gitignore ~/.gitignore_global

# fish
rm ~/.config/fish/config.fish
ln -s ~/Repos/_configs/fishconfig ~/.config/fish/config.fish

rm -rf ~/.config/fish/functions
ln -s ~/Repos/_configs/fishfunctions ~/.config/fish/functions

# bash
rm ~/.bashrc
ln -s ~/Repos/_configs/bashrc ~/.bashrc

