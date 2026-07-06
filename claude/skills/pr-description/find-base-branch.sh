#!/usr/bin/env bash
# Finds the local branch whose tip is an ancestor of HEAD with the fewest commits between them.
set -euo pipefail

git for-each-ref --format='%(refname:short)' refs/heads | while read branch; do
  [ "$branch" = "$(git branch --show-current)" ] && continue
  if git merge-base --is-ancestor "$branch" HEAD 2>/dev/null; then
    echo "$(git rev-list --count "$branch"..HEAD) $branch"
  fi
done | sort -n | awk 'NR==1{print $2}'
