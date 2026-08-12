# Handoff

## Current gate

Gate 4 now has a verified interface foundation: F0X has a reproducible, sealed
arm64 `F0X.app` that macOS directly launches, with mutable data separated from
bundle contents. Normal launches open on F0X Home with ready/data state, Play,
data management, startup display settings, recovery guidance, and Quit; scripted
regressions bypass Home deliberately and retain their existing boot contract.
The normal Metal path acquires the drawable before synchronous game rendering.
The later repeating strobe was traced to transition readback permanently moving
a live game framebuffer onto a second Metal command queue while the window
sampled it on the main queue. The isolated current build passed 120 consecutive
race captures, 80 resize captures, and 60 fullscreen captures with no black
frames; owner confirmation remains the final stability check.
Gate 3 now has direct packaged-app race visuals, but the captured raw-ROM race
now has restored raw-ROM machine textures and a contained narrow-window HUD.
Owner confirmation of presentation stability, player control through a completed
race, and physical audio remain open.

## Revised goal and execution order

Continue from commit `996973f`; do not reopen the native build, macOS fiber,
PCM-synthesis, bundle-sealing, or title-stability gates without contradictory
evidence. Preserve the G-Diffuser → libultraship/Fast3D → Metal architecture and
the ROM-free public boundary. Work one falsifiable gate at a time:

1. Metal presentation stability across title/menu/race/resize/fullscreen;
2. completed controlled race plus save/relaunch/load round-trip;
3. desktop extraction-golden correction plus safe import through the app shell;
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
- Normal packaged launches now show a styled, borderless F0X Home panel. Its
  management path reuses the verified first-boot/import state machine with
  management-specific copy, a two-frame click-through guard, and a clear return
  to Home. The sealed archive resolver now uses FirstBootRun's already-resolved
  executable directory, so relative shell launches and Finder launches locate
  `Contents/Resources/gdiffuser.o2r` identically.
- `scripts/macos-sram-toggle.gdx` uses the game's own Options menu to toggle a
  persisted setting. The first launch loaded the existing 32 KiB SRAM and
  changed its SHA-256 from `aaf4cc30...` to `a13e7eb3...`; the second launch
  explicitly loaded that changed file and the identical toggle restored the
  exact original hash. Both 18-command routes returned to main menu and exited
  0 without a mode timeout.

## Next action

Ask the owner to observe the current packaged build while retaining the direct
soak regression. Unless flashing recurs, proceed to a player-controlled completed
race; save/relaunch/load persistence is now independently verified. Keep F0X Home
as the single preboot surface; extend it only when a concrete recovery or launch
behavior is missing.
