#!/bin/bash
set -e

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
list="$repo_root/cursor/extensions.txt"

if ! command -v cursor >/dev/null; then
  echo "Error: cursor CLI not found. Install via brew cask first." >&2
  exit 1
fi

while IFS= read -r ext || [[ -n "$ext" ]]; do
  [[ -z "$ext" || "$ext" =~ ^[[:space:]]*# ]] && continue
  echo "Installing $ext..."
  cursor --install-extension "$ext"
done < "$list"
