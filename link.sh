#!/bin/bash

# Load and validate secrets
if [ -f "$PWD/.env" ]; then
  set -a
  source "$PWD/.env"
  set +a
fi
if [ -z "$CONTEXT7_API_KEY" ]; then
  echo "Warning: CONTEXT7_API_KEY is not set; ~/.config/zed/settings.json will contain a placeholder" >&2
fi

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
rm -f ~//Library/Application\ Support/pypoetry/config.toml
mkdir -p ~/Library/Application\ Support/pypoetry
ln -s $PWD/poetryconfig ~/Library/Application\ Support/pypoetry/config.toml

# cursor cli
mkdir -p ~/.cursor
rm -f ~/.cursor/cli-config.json
ln -s $PWD/cursor/cli-config.json ~/.cursor/cli-config.json
rm -f ~/.cursor/mcp.json
ln -s $PWD/cursor/mcp.json ~/.cursor/mcp.json

# cursor editor
mkdir -p ~/Library/Application\ Support/Cursor/User
rm -f ~/Library/Application\ Support/Cursor/User/settings.json
ln -s $PWD/cursor/editor-settings.json ~/Library/Application\ Support/Cursor/User/settings.json
rm -f ~/Library/Application\ Support/Cursor/User/keybindings.json
ln -s $PWD/cursor/editor-keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json

# claude
mkdir -p ~/.claude
rm -f ~/.claude/settings.json
ln -s $PWD/claude/settings.json ~/.claude/settings.json
rm -rf ~/.claude/skills
ln -s $PWD/claude/skills ~/.claude/skills

# zed
mkdir -p ~/.config/zed
rm -f ~/.config/zed/keymap.json
ln -s $PWD/zed/keymap.json ~/.config/zed/keymap.json
rm -f ~/.config/zed/settings.json
perl -pe 's/__([A-Z0-9_]+)__/$ENV{$1} \/\/ ""/ge' $PWD/zed/settings.template.json > ~/.config/zed/settings.json
