#!/bin/bash
set -e

# Load and validate secrets
if [ -f "$PWD/.env" ]; then
  set -a
  source "$PWD/.env"
  set +a
fi

REQUIRED_ENV_VARS=(CONTEXT7_API_KEY)
missing=()
for var in "${REQUIRED_ENV_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    missing+=("$var")
  fi
done
if [ "${#missing[@]}" -gt 0 ]; then
  echo "Error: missing required .env value(s): ${missing[*]}" >&2
  echo "Add them to $PWD/.env before running this script." >&2
  exit 1
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

rm -f ~/.p10k.zsh
ln -s $PWD/p10k.zsh ~/.p10k.zsh

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
perl -pe 's/__([A-Z0-9_]+)__/$ENV{$1} \/\/ ""/ge' $PWD/cursor/mcp.template.json > ~/.cursor/mcp.json

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

# shared agent skills (Cursor reads ~/.agents/skills natively; Claude Code reads ~/.claude/skills)
mkdir -p ~/.agents
rm -rf ~/.agents/skills
ln -s $PWD/agents/skills ~/.agents/skills
rm -rf ~/.claude/skills
ln -s $PWD/agents/skills ~/.claude/skills

# zed
mkdir -p ~/.config/zed
rm -f ~/.config/zed/keymap.json
ln -s $PWD/zed/keymap.json ~/.config/zed/keymap.json
rm -f ~/.config/zed/settings.json
perl -pe 's/__([A-Z0-9_]+)__/$ENV{$1} \/\/ ""/ge' $PWD/zed/settings.template.json > ~/.config/zed/settings.json
