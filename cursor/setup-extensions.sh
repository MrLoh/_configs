#!/bin/bash
set -e

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
list="$repo_root/cursor/extensions.txt"

if ! command -v cursor >/dev/null; then
  echo "Error: cursor CLI not found. Install via brew cask first." >&2
  exit 1
fi

failed=()
while IFS= read -r ext || [[ -n "$ext" ]]; do
  [[ -z "$ext" || "$ext" =~ ^[[:space:]]*# ]] && continue
  echo "Installing $ext..."
  if ! cursor --install-extension "$ext"; then
    echo "Warning: failed to install $ext, skipping." >&2
    failed+=("$ext")
  fi
done < "$list"

if [[ ${#failed[@]} -gt 0 ]]; then
  echo >&2
  echo "Finished with ${#failed[@]} failed extension(s):" >&2
  printf '  %s\n' "${failed[@]}" >&2
fi
