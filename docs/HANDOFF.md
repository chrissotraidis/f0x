# Handoff

## Current gate

Gate 4 is partially working: F0X has a reproducible, sealed arm64 `F0X.app`
that macOS directly launches, with mutable data separated from bundle contents.
Gate 3 direct race visuals and physical audio remain open.

## Verified state

- Pinned, recursive upstream source is at `ref/G-Diffuser`, commit `719fd82`.
- The cartridge-only ARM64 build completes and the PCM capture harness passes
  all 5 cases / 28 checks.
- A bounded SDL dummy-device run with the dedicated audio thread produced
  nonzero cartridge PCM; see `TESTING.md` for exact capture evidence.
- `cmake -DGDX_MACOS_BUNDLE=ON` produces `build/macos-f0x-bundle/port/F0X.app`
  with F0X bundle identity and a passing strict ad-hoc signature check. It keeps
  immutable payload under `Contents/Resources`, its signed extractor under
  `Contents/Helpers`, and its launched process uses
  `~/Library/Application Support/F0X` for configuration and logs, preserves
  immutable fonts in `Contents/Resources`, and directly reached the branded
  one-ROM Metal first-time setup screen.

## Next action

Exercise the existing in-window file-drop/import flow with authorized local
test media, proving validation, staging, raw-ROM continuation, and a subsequent
bundled boot. The native AppKit Browse bridge is now linked but should be
interacted with as part of that end-to-end proof. In parallel, keep the
reproducible GP route available for direct race-window capture. The black
framebuffer-readback problem and CoreAudio route/volume validation remain
separate evidence gaps.
