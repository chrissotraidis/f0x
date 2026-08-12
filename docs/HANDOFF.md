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

The desktop archive gate is no longer blocked by a stale golden. Two independent
bundled-extractor runs produced the same `7d60d975...` container; it passed the
3,610-entry/version/family gauntlet, installed into Application Support, stayed
unchanged on warm boot, and drove the packaged GP race with the original ROM
temporarily absent. That negative-ROM test exposed and fixed a cartridge-only
first-boot inconsistency: archive validation now precedes the raw-ROM fallback
and does not depend on a setup marker that older cartridge installs never wrote.
The macOS app now defers a raw-ROM-only install to its visible first-run surface,
runs extraction asynchronously behind a determinate 3,610-entry progress bar and
scrolling log, hot-mounts the validated archive, and continues into the same
process. Standard keyboard navigation/default focus is enabled on Setup and Home.
Torch now also exposes `GdxRunInProcessO2R`: it accepts ROM bytes, recipes,
unique staging output, version, and a pollable asset counter. The static-library
harness reproduced the exact `7d60d975...` archive twice sequentially in one
process and refuses to overwrite a non-empty output. It is not yet linked into
the default desktop backend or compiled for iOS.

That API is now integrated behind `GDX_INPROCESS_TORCH`. The opt-in macOS bundle
links Torch statically into F0X, reuses the parent build's YAML/spdlog/tinyxml
targets, labels recipe processing as indeterminate rather than falsely mapping
31 recipe nodes onto 3,610 archive records, and retains the port's existing
golden validation plus atomic activation. Its first-run regression explicitly
logged `in-process Torch (ROM bytes, no fork/exec)`, installed the exact golden,
hot-mounted it, and reached the packaged GP race. The default child backend also
still builds and seals.

## Revised goal and execution order

Continue from commit `996973f`; do not reopen the native build, macOS fiber,
PCM-synthesis, bundle-sealing, or title-stability gates without contradictory
evidence. Preserve the G-Diffuser → libultraship/Fast3D → Metal architecture and
the ROM-free public boundary. Work one falsifiable gate at a time:

1. Metal presentation stability across title/menu/race/resize/fullscreen;
2. completed controlled race plus save/relaunch/load round-trip;
3. compile the integrated in-process F0X/Torch graph for iOS;
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
- `scripts/macos-race-handoff.gdx` ends deterministic playback at a live GP
  starting grid. Normal X/A/D keyboard mappings then accelerated and steered the
  Blue Falcon in two hands-on attempts, including a recovery from 0 to 438
  km/h. Neither attempt finished: one exploded and one became stuck off the
  crossover. No controller is attached (Bluetooth is off; USB has no gamepad),
  so player-completed race acceptance remains honestly open.
- The current bundled extractor and recipes are deterministic at SHA-256
  `7d60d975bdbce24ba544c6ed3cc3a06f365cfe88e6a8096b5a6d63940513181a`.
  The candidate contains exactly 3,610 unique records, the expected US-rev0
  version CRC, and all 33 complete-or-absent families. The installed archive
  was reused without rewrite on warm boot and completed the packaged GP route
  with `baserom.us.rev0.z64` absent; the test restored the ROM immediately.
- On a fresh-import simulation, F0X visibly rendered the verified-ROM consent
  screen, then live extraction progress and log output. The existing scripted
  regression contract confirmed only after one setup frame, the async extractor
  installed and hot-mounted the 3,610-entry archive, and the same process reached
  the packaged GP race marker. Ordinary launches still require explicit user
  confirmation; the script seam exists only when `GDX_INPUT_SCRIPT` is set.
- Torch static-library mode now has a small exception-safe in-memory O2R entry
  point and harness. It generated the exact 3,610-entry golden twice in one
  process from the authorized ROM, passed the full archive validator, and safely
  rejected a destination already containing `generic.o2r`.
- An opt-in F0X macOS build now links that Torch library and routes cartridge
  extraction through it while preserving the port-layer validation/atomic
  install. The generated archive matched `7d60d975...`, hot-mounted in the same
  process, and completed the packaged race route. The ordinary child-backend
  build was rebuilt afterward and still seals successfully.

## Next action

Compile the integrated in-process dependency graph for iOS/iPadOS and expose the
first concrete platform/compiler blockers. Keep final archive validation and
atomic activation in the port layer. In parallel, the owner can
observe the current packaged build for flashing and use a connected controller
to close the completed-race gate; save/relaunch/load persistence is already
independently verified.
