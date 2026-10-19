#!/usr/bin/env bash
# PadMint's Mac build of F0X, from a fresh clone: pinned sources, the build-only
# Python environment, a native Apple Silicon F0X.app and a zip of it. No ROM is
# read: players choose their own F-Zero X ROM inside F0X on first launch.
#
#   scripts/build-padmint-macos.sh OUTPUT.zip
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="${1:?usage: scripts/build-padmint-macos.sh OUTPUT.zip}"
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

build="$root/build/macos-f0x-bundle"
echo "F0X: configuring the Mac app"
cmake -S ref/G-Diffuser -B "$build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DGDX_EXPANSION_KIT=OFF \
  -DGDX_MACOS_BUNDLE=ON \
  -DGDX_INPROCESS_TORCH=ON \
  -DPython3_EXECUTABLE="$python_env/bin/python"

echo "F0X: compiling the Mac app"
cmake --build "$build" --target G-Diffuser --parallel "$jobs"

app="$build/port/F0X.app"
if [[ ! -x "$app/Contents/MacOS/F0X" ]]; then
  echo "F0X Mac app not found: $app" >&2
  exit 1
fi
for pattern in '*.z64' '*.v64' '*.n64' '*.rom' '*.ndd' 'fzerox.o2r' \
  '*.sra' '*.eep' '*.fla' '*.mobileprovision' '*.p12' '*.cer' '*.key'; do
  forbidden="$(find "$app" -type f -iname "$pattern" -print -quit)"
  if [[ -n "$forbidden" ]]; then
    echo "Refusing app containing private game data or signing material: $forbidden" >&2
    exit 1
  fi
done

echo "F0X: signing for this Mac and packaging"
codesign --force --deep --sign - "$app"
codesign --verify --deep --strict "$app"
rm -f "$output"
ditto -c -k --keepParent "$app" "$output"
