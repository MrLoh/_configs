#!/bin/bash
set -euo pipefail

zsh_path="$(command -v zsh)"

if [[ -z "$zsh_path" ]]; then
  echo "Error: zsh is not installed" >&2
  exit 1
fi

# Homebrew zsh lives outside /etc/shells on macOS.
if [[ "$zsh_path" != /bin/zsh && "$zsh_path" != /usr/bin/zsh ]]; then
  if ! grep -qxF "$zsh_path" /etc/shells; then
    echo "Adding $zsh_path to /etc/shells"
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi
fi

if [[ "$SHELL" != "$zsh_path" ]]; then
  echo "Setting default shell to $zsh_path"
  chsh -s "$zsh_path"
else
  echo "Default shell is already $zsh_path"
fi

# iTerm2 shell integration (https://iterm2.com/documentation-shell-integration.html)
curl -fsSL https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh

echo "zsh setup complete"
