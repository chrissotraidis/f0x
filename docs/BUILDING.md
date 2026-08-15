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

Re-resolve the data-container path with `simctl get_app_container` after every
install; Simulator may remap its UUID while preserving Documents, so a cached
absolute path can become stale. Clean cartridge first-run requires a verified
big-endian US rev0 `.z64` (`80 37 12 40` magic). Renaming a byte-swapped `.v64`
does not convert it. Keep the original ROM unchanged and, when validating a
dump you are authorized to use, make a separate 16-bit-swapped local copy:

```sh
dd if='/private/path/game.v64' of='/private/tmp/baserom.us.rev0.z64' \
  conv=swab status=none
xxd -l 4 /private/tmp/baserom.us.rev0.z64
shasum -a 256 /private/tmp/baserom.us.rev0.z64
```

Copy/import only that private local file into the app's Documents container;
never put ROM data in the source tree, app bundle, patch series, or IPA.

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

## Signed physical iPad/iPhone development build

Keep signing values local. Use a fresh device build directory: a reused output
can retain stale `_CodeSignature` and `embedded.mobileprovision` files even when
an unsigned compile succeeds. Resolve the CoreDevice identifier with
`xcrun devicectl list devices`; resolve the Xcode destination UDID from the same
device listing/details. Configure the clean tree with the same `PLATFORM=OS64`
arguments as the unsigned build, then build for that destination:

```sh
xcodebuild \
  -project build/f0x-ios-device/GDiffuser.xcodeproj \
  -scheme G-Diffuser \
  -configuration Debug \
  -sdk iphoneos \
  -destination 'platform=iOS,id=<DEVICE_UDID>' \
  DEVELOPMENT_TEAM=<LOCAL_TEAM_ID> \
  CODE_SIGN_STYLE=Automatic \
  CODE_SIGN_IDENTITY='Apple Development' \
  build

codesign --verify --deep --strict --verbose=2 \
  build/f0x-ios-device/port/Debug-iphoneos/F0X.app
```

Use `-allowProvisioningUpdates` only when Xcode has a valid signed-in developer
account and profile creation/refresh is intended. A fully local build can use an
already-installed Xcode-managed profile. Do not infer the team ID from the value
in parentheses in a certificate's display name. Verify the certificate subject's
`OU` and the profile's `TeamIdentifier`; those are the signing team. Also verify
that `ProvisionedDevices` contains the target UDID and that the final entitlement
is `<TEAM_ID>.com.chrissotraidis.f0x`. For example:

```sh
security find-identity -v -p codesigning
security cms -D -i '<PROFILE.mobileprovision>' | \
  plutil -extract TeamIdentifier.0 raw -o - -
security cms -D -i '<PROFILE.mobileprovision>' | \
  plutil -extract ProvisionedDevices json -o - -
codesign -d --entitlements :- \
  build/f0x-ios-device/port/Debug-iphoneos/F0X.app
```

Before replacing an installed development build, copy its app-data container to
a private temporary directory and hash the ROM, `fzerox.o2r`, save, and settings.
Install the signed `.app` in place; do not uninstall the existing app, because
uninstalling removes its container:

```sh
xcrun devicectl device install app \
  --device <COREDEVICE_ID> \
  build/f0x-ios-device/port/Debug-iphoneos/F0X.app

xcrun devicectl device process launch \
  --device <COREDEVICE_ID> \
  --terminate-existing \
  com.chrissotraidis.f0x
```

Copy the post-install `Documents` directory back to another private temporary
directory and compare the protected hashes before testing. A successful build,
signature check, install, launch, or unchanged data-container audit does not
establish audible audio, correct touch behavior, stable gameplay, or acceptable
performance; those require hands-on physical-device acceptance.

Copy `Documents` and `Library` separately, into already-created destinations;
do not request source `.` and do not use `--remove-existing-content`. If a
CoreDevice copy reports a closed network socket while the process remains live,
retry the unchanged copy rather than rebuilding or reinstalling the app.

### Moving an existing private test setup from iPad to iPhone

For owner-authorized device-to-device testing, copy the source app's `Documents`
and preference plist to a private temporary directory, inspect nonzero file sizes
and hashes, install the same universal bundle on the target device, and copy only
the required ROM/archive/save/config/preferences into its new container. Exclude
logs, caches, screenshots, and unrelated container state. A tablet profile may be
cloned into `F0X.TouchLayout.phone-v1` as a temporary starting point, but do not
promote it to phone source defaults until hands-on phone ergonomics are accepted.
Read the target files back and compare hashes before calling the transfer complete.

Once accepted, promote the phone profile's exact normalized centers, scales,
and hidden flags only to `kPhoneSpecs`; keep `kTabletSpecs` unchanged. Existing
saved profiles remain overrides, so an in-place install preserves the test device.

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
