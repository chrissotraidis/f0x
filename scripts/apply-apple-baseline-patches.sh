#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

apply_patch_file() {
  local checkout="$1"
  local patch_file="$2"
  # A failed reverse-check is the normal "not applied yet" case. Keep its
  # expected hunk diagnostics quiet; the forward check below still reports a
  # real patch failure in full.
  if git -C "$checkout" apply --reverse --check "$patch_file" >/dev/null 2>&1; then
    return
  fi
  git -C "$checkout" apply --check "$patch_file"
  git -C "$checkout" apply "$patch_file"
}

apply_patch_stack() {
  local checkout="$1"
  local base_patch="$2"
  local overlay_patch="$3"
  # The overlay deliberately edits files introduced by the base patch. If the
  # overlay reverse-checks, the complete stack is already present; checking the
  # base independently would fail because those same lines have advanced.
  if git -C "$checkout" apply --reverse --check "$overlay_patch" >/dev/null 2>&1; then
    return
  fi
  apply_patch_file "$checkout" "$base_patch"
  apply_patch_file "$checkout" "$overlay_patch"
}

apply_patch_stack "$root_dir/ref/G-Diffuser" \
  "$root_dir/patches/gdiffuser-apple-macos.patch" \
  "$root_dir/patches/gdiffuser-controller-lifecycle.patch"
apply_patch_file "$root_dir/ref/G-Diffuser" "$root_dir/patches/gdiffuser-fiber-smoketest.patch"
apply_patch_file "$root_dir/ref/G-Diffuser/decomp" "$root_dir/patches/fzerox-decomp-apple.patch"
apply_patch_stack "$root_dir/ref/G-Diffuser/libultraship" \
  "$root_dir/patches/libultraship-apple-metal.patch" \
  "$root_dir/patches/libultraship-controller-lifecycle.patch"
apply_patch_file "$root_dir/ref/G-Diffuser/torch" "$root_dir/patches/torch-inprocess-apple.patch"

icon_source="$root_dir/assets/AppIcon.xcassets"
icon_destination="$root_dir/ref/G-Diffuser/port/Assets.xcassets"
mkdir -p "$icon_destination/AppIcon.appiconset"
cp "$icon_source/Contents.json" "$icon_destination/Contents.json"
cp "$icon_source/AppIcon.appiconset/Contents.json" \
   "$icon_destination/AppIcon.appiconset/Contents.json"
cp "$icon_source/AppIcon.appiconset/AppIcon-1024.png" \
   "$icon_destination/AppIcon.appiconset/AppIcon-1024.png"
