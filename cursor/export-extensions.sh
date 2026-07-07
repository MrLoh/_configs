#!/bin/bash
set -e

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cursor --list-extensions | sort > "$repo_root/cursor/extensions.txt"
echo "Wrote $(wc -l < "$repo_root/cursor/extensions.txt" | tr -d ' ') extensions to cursor/extensions.txt"
