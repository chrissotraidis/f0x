# Handoff

## Current gate

Gate 4 is partially working: F0X has a reproducible, sealed arm64 `F0X.app`
that macOS directly launches, with mutable data separated from bundle contents.
The normal Metal path now acquires the drawable before synchronous game rendering,
which removed the observed black-window flash and visibly restores the title.
Gate 3 now has direct packaged-app race visuals, but the captured raw-ROM race
shows missing/cropped HUD and machine-texture regions. Visual correctness,
player control through a completed race, and physical audio remain open.

## Revised goal and execution order

Continue from commit `996973f`; do not reopen the native build, macOS fiber,
PCM-synthesis, bundle-sealing, or title-stability gates without contradictory
evidence. Preserve the G-Diffuser → libultraship/Fast3D → Metal architecture and
the ROM-free public boundary. Work one falsifiable gate at a time:

1. packaged raw-ROM race texture/HUD correctness and a completed controlled race;
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
- `scripts/macos-packaged-race.gdx` now waits on the title screen's actual
  readiness state instead of a boot-time delay. In the signed packaged app it
  traversed modes `0 -> 7 -> 10 -> 8 -> 9 -> 1` without a timeout and emitted
  `packaged_gp_race_capture_interval`. Direct inspection showed a live GP race.

## Next action

Use the preserved packaged route as the regression while correcting the visible
race defects. The direct image has a working track, racers, player craft, lap /
position / energy UI, but portions of the HUD are clipped or black and machine
textures are missing. The run also logged missing `machine_custom_gfx` resources
and null TMEM texture addresses, so start at the raw-ROM fallback's texture
resolution boundary. Do not claim Gate 3 complete until the direct race image is
visually intact and a player-controlled race completes. Then exercise
save/relaunch/load persistence. The extraction golden, internal BMP readback,
and CoreAudio route remain separate gaps.
