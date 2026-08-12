# Handoff

## Current gate

Gate 4 is partially working: F0X has a reproducible, sealed arm64 `F0X.app`
that macOS directly launches, with mutable data separated from bundle contents.
The normal Metal path acquires the drawable before synchronous game rendering,
which improved the original title strobe, but the user still reports severe
flashing in the current F0X Metal window. Do not call presentation stable.
Gate 3 now has direct packaged-app race visuals, but the captured raw-ROM race
now has restored raw-ROM machine textures and a contained narrow-window HUD.
Presentation stability, a real F0X application interface, player control through
a completed race, and physical audio remain open.

## Revised goal and execution order

Continue from commit `996973f`; do not reopen the native build, macOS fiber,
PCM-synthesis, bundle-sealing, or title-stability gates without contradictory
evidence. Preserve the G-Diffuser → libultraship/Fast3D → Metal architecture and
the ROM-free public boundary. Work one falsifiable gate at a time:

1. Metal presentation stability across title/menu/race/resize/fullscreen;
2. coherent F0X app shell for import, ready/library state, settings, recovery, and launch;
3. completed controlled race plus save/relaunch/load round-trip;
4. desktop extraction-golden correction plus safe import through the app shell;
5. iOS/iPadOS build and physical-iPad controller/lifecycle/audio proof;
6. touch, timing/high refresh, packaging, README, and final audits.

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
- The rebuilt sealed bundle rendered a complete F-Zero X title after the
  normal frame setup moved ahead of `gdx_vi_tick()`. Keep that order: the game
  fiber submits its Metal work synchronously inside the tick, so moving setup
  back afterward reintroduces the drawable mismatch and black strobe.
- `scripts/macos-packaged-race.gdx` now waits on the title screen's actual
  readiness state instead of a boot-time delay. In the signed packaged app it
  traversed modes `0 -> 7 -> 10 -> 8 -> 9 -> 1` without a timeout and emitted
  `packaged_gp_race_capture_interval`. Direct inspection showed a live GP race.
- Raw-ROM texture pointers now use direct copies when their generated archive
  key is not actually mounted, restoring the Blue Falcon and scene detail.
- Narrower-than-4:3 windows now select the centered 4:3 composite instead of
  applying hor+ expansion that pushed the HUD outside the viewport.

## Next action

Treat the user's observed rapid Metal flashing as the active blocker. Reproduce
and instrument presentation across title, menu transitions, the preserved GP
route, window resizing, and fullscreen entry/exit; require a sustained direct
visual soak before claiming stability. Then build the missing F0X product shell:
first-run/import, ready/library state, settings, progress/error recovery, and a
clear launch path. The current setup window plus upstream/developer menus are a
foundation, not the finished interface. Only after these two gates should the
loop return to a completed controlled race and save persistence.
