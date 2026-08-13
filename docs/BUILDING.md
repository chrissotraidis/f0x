# Building F0X

All source inputs are pinned under ignored `ref/`; maintained changes live in
tracked `patches/`. Never add a ROM or generated archive to a build or package.

## Prepare sources

Clone the exact upstream pin, initialize its submodules, and apply the
maintained series with:

```sh
scripts/setup-sources.sh
```

The setup refuses to overwrite a non-Git path or switch an edited checkout.
The underlying patch step is idempotent and treats a clean reverse-check as
already applied.

## Apple Silicon macOS app

```sh
cmake -S ref/G-Diffuser -B build/macos-f0x-bundle -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DGDX_EXPANSION_KIT=OFF \
  -DGDX_MACOS_BUNDLE=ON \
  -DPython3_EXECUTABLE="$PWD/build/python-build-tools/bin/python"

cmake --build build/macos-f0x-bundle --target G-Diffuser --parallel 4
```

Product: `build/macos-f0x-bundle/port/F0X.app`.

Verify the local seal and plist:

```sh
codesign --verify --deep --strict --verbose=2 \
  build/macos-f0x-bundle/port/F0X.app
plutil -lint build/macos-f0x-bundle/port/F0X.app/Contents/Info.plist
```

This is ad-hoc local signing, not Developer ID signing or notarization.

## iPad/iPhone Simulator

Use ios-cmake commit `06465b27698424cf4a04a5ca4904d50a3c966c45`, the pin in
`ref/G-Diffuser/libultraship/cmake/ios-toolchain-populate.cmake`. The paths below
reuse the copy already fetched by the proven build. On a clean machine, fetch
that exact commit into a known ignored directory first; do not pass a nonexistent
toolchain path and assume CMake will bootstrap itself. The proven configuration is:

```sh
cmake -S ref/G-Diffuser -B build/f0x-iossim-native -G Xcode \
  -DCMAKE_TOOLCHAIN_FILE="$PWD/build/f0x-iossim-native/_deps/iostoolchain-src/ios.toolchain.cmake" \
  -DPLATFORM=SIMULATORARM64 \
  -DDEPLOYMENT_TARGET=16.0 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
  -DGDX_EXPANSION_KIT=OFF \
  -DGDX_INPROCESS_TORCH=ON \
  -DPython3_EXECUTABLE="$PWD/build/python-build-tools/bin/python"

xcodebuild \
  -project build/f0x-iossim-native/GDiffuser.xcodeproj \
  -scheme G-Diffuser \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,id=<BOOTED_SIMULATOR_UDID>' \
  build
```

Product:
`build/f0x-iossim-native/port/Debug-iphonesimulator/F0X.app`.

Use exactly one booted Simulator and one F0X process while validating. A typical
install/launch is:

```sh
xcrun simctl install booted \
  build/f0x-iossim-native/port/Debug-iphonesimulator/F0X.app
xcrun simctl launch --console-pty booted com.chrissotraidis.f0x
```

## Unsigned iPhoneOS/iPadOS compile

```sh
cmake -S ref/G-Diffuser -B build/f0x-ios-device -G Xcode \
  -DCMAKE_TOOLCHAIN_FILE="$PWD/build/f0x-iossim-native/_deps/iostoolchain-src/ios.toolchain.cmake" \
  -DPLATFORM=OS64 \
  -DDEPLOYMENT_TARGET=16.0 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=16.0 \
  -DGDX_EXPANSION_KIT=OFF \
  -DGDX_INPROCESS_TORCH=ON \
  -DPython3_EXECUTABLE="$PWD/build/python-build-tools/bin/python"

xcodebuild \
  -project build/f0x-ios-device/GDiffuser.xcodeproj \
  -scheme G-Diffuser \
  -configuration Debug \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  build
```

Product: `build/f0x-ios-device/port/Debug-iphoneos/F0X.app`.

This proves compilation/package structure only. Physical installation requires
an Apple Development identity, a provisioning profile, a controlled bundle ID,
and a connected device. Never commit team IDs or signing material.

## Unsigned re-signable IPA

After the unsigned iPhoneOS build succeeds, audit it and create a deterministic
developer artifact with:

```sh
scripts/package-ios.sh
```

The default output is
`artifacts/F0X-0.1.0-development-unsigned.ipa`. The script accepts an optional
app path and output path as its first two arguments. It refuses Simulator or
non-arm64 products, unexpected identity/platform metadata, missing iPhone/iPad
icons, ROMs, `fzerox.o2r`, saves, signing credentials, provisioning profiles,
valid or stale signatures, and prohibited files inside the engine archive.
It normalizes package metadata and file order so an unchanged `.app` produces
the same IPA SHA-256 on repeated runs.

This IPA is a package/re-signing proof, not a public download and not directly
installable on a standard iPhone or iPad. A compatible personal-signing tool or
Xcode must sign it for an installer's device. Never publish an IPA produced
from an app containing a maintainer profile or signature.
