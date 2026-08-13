#!/usr/bin/env bash
# Audit an unsigned iPhoneOS F0X app and wrap it as a re-signable IPA.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
app="${1:-$root_dir/build/f0x-ios-device/port/Debug-iphoneos/F0X.app}"

if [[ "$app" != /* ]]; then
  app="$root_dir/$app"
fi

if [[ ! -d "$app" || ! -f "$app/F0X" || ! -f "$app/Info.plist" ]]; then
  echo "F0X device app not found: $app" >&2
  exit 1
fi

if ! vtool -show-build "$app/F0X" | grep -Eq 'platform +IOS$'; then
  echo "Refusing non-device product: $app" >&2
  exit 1
fi

if [[ "$(lipo -archs "$app/F0X")" != "arm64" ]]; then
  echo "Refusing device executable that is not arm64-only: $app/F0X" >&2
  exit 1
fi

bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist")"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Info.plist")"
build_number="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app/Info.plist")"
minimum_os="$(/usr/libexec/PlistBuddy -c 'Print :MinimumOSVersion' "$app/Info.plist")"
device_families="$(/usr/libexec/PlistBuddy -c 'Print :UIDeviceFamily' "$app/Info.plist")"

if [[ "$bundle_id" != "com.chrissotraidis.f0x" ]]; then
  echo "Refusing unexpected bundle identifier: $bundle_id" >&2
  exit 1
fi
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
   [[ ! "$build_number" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
  echo "Refusing invalid app version: $version ($build_number)" >&2
  exit 1
fi
if ! awk -v version="$minimum_os" 'BEGIN {
  split(version, parts, "."); exit !((parts[1] + 0) >= 16)
}'; then
  echo "Refusing unsupported minimum iOS version: $minimum_os" >&2
  exit 1
fi
if ! grep -Eq '(^|[[:space:]])1($|[[:space:]])' <<<"$device_families" ||
   ! grep -Eq '(^|[[:space:]])2($|[[:space:]])' <<<"$device_families"; then
  echo "Refusing app without both iPhone and iPad device families." >&2
  exit 1
fi

for required in \
  "$app/AppIcon60x60@2x.png" \
  "$app/AppIcon76x76@2x~ipad.png" \
  "$app/Assets.car" \
  "$app/LICENSE" \
  "$app/THIRD_PARTY_NOTICES.md" \
  "$app/gdiffuser.o2r"; do
  if [[ ! -f "$required" ]]; then
    echo "Required ROM-free bundle resource is missing: $required" >&2
    exit 1
  fi
done

for pattern in \
  '*.z64' '*.v64' '*.n64' '*.rom' '*.ndd' 'fzerox.o2r' \
  '*.sra' '*.eep' '*.fla' '*.mobileprovision' '*.p12' '*.cer' '*.key'; do
  forbidden="$(find "$app" -type f -iname "$pattern" -print -quit)"
  if [[ -n "$forbidden" ]]; then
    echo "Refusing app containing private game data or signing material: $forbidden" >&2
    exit 1
  fi
done

if [[ -d "$app/_CodeSignature" ]] || codesign --verify --strict "$app" >/dev/null 2>&1; then
  echo "Refusing signed or stale-signed app; build with code signing disabled." >&2
  exit 1
fi

engine_entries="$(unzip -Z1 "$app/gdiffuser.o2r")"
if grep -Eiq '(^|/).*\.(z64|v64|n64|rom|ndd|sra|eep|fla)$|(^|/)fzerox\.o2r$' \
  <<<"$engine_entries"; then
  echo "Refusing engine archive containing private game data." >&2
  exit 1
fi

output="${2:-$root_dir/artifacts/F0X-${version}-development-unsigned.ipa}"
if [[ "$output" != /* ]]; then
  output="$root_dir/$output"
fi

mkdir -p "$(dirname "$output")"
package_root="$(mktemp -d /tmp/f0x-package.XXXXXX)"
trap 'rm -rf "$package_root"' EXIT
mkdir "$package_root/Payload"
ditto --norsrc "$app" "$package_root/Payload/F0X.app"

# Normalize metadata and archive order so identical app bundles produce the
# same IPA bytes and checksum on repeated runs.
find "$package_root/Payload" -exec touch -t 198001010000 {} +
temporary_ipa="$package_root/F0X.ipa"
(
  cd "$package_root"
  find Payload -print | LC_ALL=C sort | \
    COPYFILE_DISABLE=1 zip -X -q -9 "$temporary_ipa" -@
)

ipa_entries="$(unzip -Z1 "$temporary_ipa")"
if ! grep -Fxq 'Payload/F0X.app/F0X' <<<"$ipa_entries" ||
   ! grep -Fxq 'Payload/F0X.app/Info.plist' <<<"$ipa_entries"; then
  echo "IPA payload verification failed." >&2
  exit 1
fi
if grep -Eiq '\.(z64|v64|n64|rom|ndd|sra|eep|fla|mobileprovision|p12|cer|key)$|Payload/F0X\.app/fzerox\.o2r$|_CodeSignature/' \
  <<<"$ipa_entries"; then
  echo "Refusing IPA containing private game data or signing material." >&2
  exit 1
fi

mv -f "$temporary_ipa" "$output"
echo "Packaged unsigned F0X $version ($build_number) for iPhone/iPad"
echo "Bundle identifier: $bundle_id"
echo "Minimum iOS/iPadOS: $minimum_os"
echo "IPA: $output"
shasum -a 256 "$output"
echo "This artifact must be re-signed before installation on a standard device."
