#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
checkout="$root_dir/ref/G-Diffuser"
remote="https://github.com/Zorkats/G-Diffuser.git"
pin="719fd82a3af605b064fb53ad6eecb020090b4c5d"

if [[ -e "$checkout" && ! -d "$checkout/.git" && ! -f "$checkout/.git" ]]; then
  echo "ref/G-Diffuser exists but is not a Git checkout; refusing to overwrite it" >&2
  exit 1
fi

if [[ ! -e "$checkout" ]]; then
  git clone --recursive "$remote" "$checkout"
fi

current="$(git -C "$checkout" rev-parse HEAD)"
if [[ "$current" != "$pin" ]]; then
  if ! git -C "$checkout" diff --quiet || ! git -C "$checkout" diff --cached --quiet; then
    echo "ref/G-Diffuser has local changes at $current; refusing to switch to $pin" >&2
    exit 1
  fi
  git -C "$checkout" fetch origin "$pin"
  git -C "$checkout" checkout --detach "$pin"
fi

git -C "$checkout" submodule update --init --recursive
git -C "$checkout" remote set-url --push origin DISABLED
git -C "$checkout" submodule foreach --recursive \
  'git remote set-url --push origin DISABLED 2>/dev/null || true'
bash "$root_dir/scripts/apply-apple-baseline-patches.sh"

echo "F0X pinned sources are ready at $checkout"
