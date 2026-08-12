#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

apply_patch_file() {
  local checkout="$1"
  local patch_file="$2"
  if git -C "$checkout" apply --reverse --check "$patch_file"; then
    return
  fi
  git -C "$checkout" apply --check "$patch_file"
  git -C "$checkout" apply "$patch_file"
}

apply_patch_file "$root_dir/ref/G-Diffuser" "$root_dir/patches/gdiffuser-apple-macos.patch"
apply_patch_file "$root_dir/ref/G-Diffuser" "$root_dir/patches/gdiffuser-fiber-smoketest.patch"
apply_patch_file "$root_dir/ref/G-Diffuser/decomp" "$root_dir/patches/fzerox-decomp-apple.patch"
apply_patch_file "$root_dir/ref/G-Diffuser/libultraship" "$root_dir/patches/libultraship-apple-metal.patch"
apply_patch_file "$root_dir/ref/G-Diffuser/torch" "$root_dir/patches/torch-inprocess-apple.patch"
