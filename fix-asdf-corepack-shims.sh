#!/bin/bash
# asdf-nodejs's `corepack enable` adds yarn/yarnpkg (and pnpm/pnpx, if not
# already managed by a dedicated plugin) to each installed nodejs version's
# bin/ directory, but `asdf reshim nodejs` never generates shims for them
# (asdf-vm/asdf-nodejs#342). Without a shim, `yarn` resolves to
# "command not found" even though corepack installed it correctly.
#
# This enables corepack for every asdf-managed nodejs version and hand-writes
# the missing shims, mirroring the format asdf itself uses for npm/npx.
#
# Re-run after installing a new nodejs version with asdf.
set -e

nodejs_versions_dir="$HOME/.asdf/installs/nodejs"
shims_dir="$HOME/.asdf/shims"

versions=()
for dir in "$nodejs_versions_dir"/*/; do
  versions+=("$(basename "$dir")")
done

if [ "${#versions[@]}" -eq 0 ]; then
  echo "No nodejs versions installed via asdf (looked in $nodejs_versions_dir)" >&2
  exit 1
fi

enabled_versions=()
for version in "${versions[@]}"; do
  install_dir="$nodejs_versions_dir/$version"
  corepack_js="$install_dir/lib/node_modules/corepack/dist/corepack.js"
  if [ ! -f "$corepack_js" ]; then
    echo "Skipping nodejs $version: no bundled corepack" >&2
    continue
  fi
  # --install-directory pins the target explicitly; without it, corepack
  # scans PATH for existing yarn/pnpm shims and can crash (EINVAL from
  # readlink) on the non-symlink shim asdf's dedicated pnpm plugin manages.
  if "$install_dir/bin/node" "$corepack_js" enable --install-directory "$install_dir/bin"; then
    enabled_versions+=("$version")
  else
    echo "Skipping nodejs $version: corepack enable failed" >&2
  fi
done
versions=("${enabled_versions[@]}")

for shim in yarn yarnpkg; do
  {
    echo '#!/usr/bin/env bash'
    for version in "${versions[@]}"; do
      echo "# asdf-plugin: nodejs $version"
    done
    echo "exec asdf exec \"$shim\" \"\$@\""
  } >"$shims_dir/$shim"
  chmod +x "$shims_dir/$shim"
done

echo "Wrote asdf shims for: yarn, yarnpkg (nodejs versions: ${versions[*]})"
