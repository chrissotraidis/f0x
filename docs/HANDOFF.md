# Handoff

## Current gate

Gate 4 is partially working: F0X has a reproducible, sealed arm64 `F0X.app`
that macOS directly launches, with mutable data separated from bundle contents.
The normal Metal path now acquires the drawable before synchronous game rendering,
which removed the observed black-window flash and visibly restores the title.
Gate 3 direct race visuals and physical audio remain open.

## Revised goal and execution order

Continue from commit `996973f`; do not reopen the native build, macOS fiber,
PCM-synthesis, bundle-sealing, or title-stability gates without contradictory
evidence. Preserve the G-Diffuser → libultraship/Fast3D → Metal architecture and
the ROM-free public boundary. Work one falsifiable gate at a time:

1. packaged-app visual GP race;
2. save/relaunch/load round-trip;
3. desktop extraction-golden correction plus safe UI import;
4. iOS/iPadOS build and physical-iPad controller/lifecycle/audio proof;
5. touch, timing/high refresh, packaging, README, and final audits.

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
- The rebuilt sealed bundle visibly rendered a stable F-Zero X title after the
  normal frame setup moved ahead of `gdx_vi_tick()`. Keep that order: the game
  fiber submits its Metal work synchronously inside the tick, so moving setup
  back afterward reintroduces the drawable mismatch and black strobe.

## Next action

Run the existing deterministic GP route in the signed `F0X.app`, leave it alive
at the race interval, and capture the app window directly. This is now the
highest-value experiment because the app is UI-enumerable and the Metal
drawable-order defect is fixed. If the race is visually correct, immediately
exercise save/relaunch/load persistence. Only then return to the linked AppKit
import bridge and the extraction-golden mismatch. The black internal BMP
readback and CoreAudio route/volume checks remain separate evidence gaps.
