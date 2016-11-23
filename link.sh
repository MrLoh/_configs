#!/bin/bash

rm ~/.gitconfig
ln -s ~/configs/gitconfig ~/.gitconfig

rm ~/.config/fish/config.fish
ln -s ~/configs/fishconfig ~/.config/fish/config.fish

rm ~/.gitignore_global
ln -s ~/configs/gitignore ~/.gitignore_global

rm ~/.bashrc
ln -s ~/configs/bashrc ~/.bashrc