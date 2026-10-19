#!/usr/bin/env bash
# PadMint's iPhone/iPad build of F0X, from a fresh clone: pinned sources, the
# build-only Python environment, the pinned iOS CMake toolchain, an unsigned
# arm64 device app and a re-signable IPA. No ROM is read: players choose their
# own F-Zero X ROM inside F0X after installing it.
#
#   scripts/build-padmint-ios.sh OUTPUT.ipa
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="${1:?usage: scripts/build-padmint-ios.sh OUTPUT.ipa}"
jobs="${F0X_BUILD_JOBS:-$(sysctl -n hw.ncpu)}"
cd "$root"

echo "F0X: preparing pinned sources"
bash scripts/setup-sources.sh

python_env="$root/build/python-build-tools"
if [[ ! -x "$python_env/bin/python" ]]; then
  echo "F0X: creating the build-only Python environment"
  /usr/bin/python3 -m venv "$python_env"
  "$python_env/bin/python" -m pip install --quiet --disable-pip-version-check \
    "PyYAML==6.0.3" "Pillow==11.3.0"
fi

# ios-cmake at the commit libultraship pins (ios-toolchain-populate.cmake).
toolchain="$root/build/ios-cmake"
toolchain_pin="06465b27698424cf4a04a5ca4904d50a3c966c45"
if [[ "$(git -C "$toolchain" rev-parse HEAD 2>/dev/null || true)" != "$toolchain_pin" ]]; then
  echo "F0X: fetching the pinned iOS CMake toolchain"
  rm -rf "$toolchain"
  git init -q "$toolchain"
  git -C "$toolchain" fetch -q --depth 1 https://github.com/leetal/ios-cmake.git "$toolchain_pin"
  git -C "$toolchain" checkout -q --detach FETCH_HEAD
fi

build="$root/build/f0x-ios-device"
echo "F0X: configuring the iPhone/iPad build"
cmake -S ref/G-Diffuser -B "$build" -G Xcode \
  -DCMAKE_TOOLCHAIN_FILE="$toolchain/ios.toolchain.cmake" \
  -DPLATFORM=OS64 \
  -DDEPLOYMENT_TARGET=16.0 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
  -DGDX_EXPANSION_KIT=OFF \
  -DGDX_INPROCESS_TORCH=ON \
  -DPython3_EXECUTABLE="$python_env/bin/python"

echo "F0X: compiling the unsigned device app"
xcodebuild \
  -project "$build/GDiffuser.xcodeproj" \
  -scheme G-Diffuser \
  -configuration Debug \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -jobs "$jobs" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  build

echo "F0X: packaging"
bash scripts/package-ios.sh "$build/port/Debug-iphoneos/F0X.app" "$output"

