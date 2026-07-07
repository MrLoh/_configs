#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
brewfile="${script_dir}/Brewfile"

if [[ ! -f "$brewfile" ]]; then
  echo "Error: Brewfile not found at $brewfile" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Error: brew is not installed" >&2
  exit 1
fi

found=0
while IFS= read -r tap; do
  found=1
  echo "Trusting tap: $tap"
  brew trust --tap "$tap"
done < <(grep '^tap ' "$brewfile" | sed -E 's/^tap "([^"]+)".*/\1/')

if [[ "$found" -eq 0 ]]; then
  echo "No taps found in $brewfile"
fi
