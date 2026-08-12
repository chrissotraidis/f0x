# Handoff

> **Superseded navigation:** this historical narrative preserves the detailed
> implementation history. The canonical continuation is now
> [`NEXT_BUILDER.md`](NEXT_BUILDER.md), with touch specifics in
> [`TOUCH_CONTROLS_IMPLEMENTATION.md`](TOUCH_CONTROLS_IMPLEMENTATION.md) and the
> paste-ready loop in [`BUILDER_GOAL_LOOP.md`](BUILDER_GOAL_LOOP.md).

## 2026-08-12 reconciliation after the entries below

One uninterrupted native Files-picker selection-to-race interaction is now
verified in a single Simulator F0X process: the app selected the authorized ROM
from Files storage, copied it into its new sandbox as `baserom.us.rev0.z64`,
validated SHA-1 `5f658e88ffa9de23cba6986a8fd3d3a90d7b4340`, ran in-process Torch, installed
the verified 3,610-entry archive, and visibly rendered a live race. This closes
the older “separate picker and extraction proofs” caveat below.

Gameplay touch controls and their menu options are not implemented. The pinned
HarkinianPad checkout is only a reference. The current machine still has no
connected physical Apple device and no signing identity, so physical iPad/iPhone
acceptance remains open.

## Current gate

Gate 5 now has Simulator gameplay proof from the genuine arm64 iOS target. It
links the same F0X, libultraship/Fast3D, Metal, and in-process Torch graph;
launches on the single booted iPad Pro 11-inch (M5) Simulator; uses sandbox
Documents for mutable data; and presents the native Files picker from `Choose
ROM...`. From an authorized ROM already placed in that sandbox, the app logged
`in-process Torch (ROM bytes, no fork/exec)`, atomically installed the verified
3,610-entry golden archive, traversed the packaged GP route, and visibly rendered
a live landscape race. A second run temporarily removed the ROM and independently
reached the same race from the validated archive alone, then exited cleanly and
restored the local ROM. Picker presentation and extraction/gameplay are therefore
separate proofs; a single uninterrupted manual picker-selection-to-race run is
still open. The same graph now also compiles, links, packages, and validates as
an unsigned arm64 iPhoneOS app. Physical signing/device execution, controller,
audio, lifecycle, and touch gameplay remain open because this host currently has
no connected Apple device and no valid code-signing identity.

The first iOS launch originally aborted in `AddFontFromFileTTF`: Xcode had copied
fonts to a literal variable directory and libultraship conflated Documents with
bundle resources. Fonts now ship inside `F0X.app`, bundle/data paths are distinct,
and missing fonts fall back without asserting.

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
frames. The owner's continuing report subsequently aligned with a second,
obsolete `G-Diffuser.app` in the same build directory: it shared the F0X bundle
identifier but predated both Home and the strobe fix, so Launch Services could
open the wrong product. This is the strongest concrete explanation found, not
proof of the exact path previously launched. The packaged build now deletes only
that legacy bundle.
Dense videos of the current app passed 462 live-race frames and, after explicit
Launch Services registration plus Finder launch, 544 Home frames without a
near-black frame or brightness jump. Owner confirmation of this corrected launch
remains open; the previous report must not be relabeled as imaginary.
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
process and refuses to overwrite a non-empty output. It is integrated behind
`GDX_INPROCESS_TORCH` on macOS and iOS; the desktop child backend remains the
default fallback.

That API is now integrated behind `GDX_INPROCESS_TORCH`. The opt-in macOS bundle
links Torch statically into F0X, reuses the parent build's YAML/spdlog/tinyxml
targets, labels recipe processing as indeterminate rather than falsely mapping
31 recipe nodes onto 3,610 archive records, and retains the port's existing
golden validation plus atomic activation. Its first-run regression explicitly
logged `in-process Torch (ROM bytes, no fork/exec)`, installed the exact golden,
hot-mounted it, and reached the packaged GP race. The default child backend also
still builds and seals.

## Revised goal and execution order

Continue from the current `main` checkpoint (the Simulator-shell implementation
landed in `382159c`); do not reopen the native build, macOS fiber,
PCM-synthesis, bundle-sealing, or title-stability gates without contradictory
evidence. Preserve the G-Diffuser → libultraship/Fast3D → Metal architecture and
the ROM-free public boundary. Work one falsifiable gate at a time:

1. owner confirmation of the corrected, unambiguous F0X bundle launch while
   retaining Metal presentation regression across title/menu/race/resize/fullscreen;
2. completed controlled race plus save/relaunch/load round-trip;
3. close the remaining uninterrupted native picker-selection-to-race interaction;
4. iPhoneOS build/signing and physical-iPad controller/lifecycle/audio proof;
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
- The macOS packaged build removes the exact obsolete `port/G-Diffuser.app`
  product before linking `F0X.app`. Both products previously used
  `com.chrissotraidis.f0x`, allowing Finder/Launch Services to launch the stale
  pre-Home binary. After rebuilding and explicitly registering only current
  `F0X.app`, Finder launched the expected Home surface and its dense capture was
  stable.
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
- The genuine arm64 iPad Simulator app ran Torch inside the F0X process against
  an authorized sandbox ROM, installed the exact 3,610-entry golden archive,
  reached `packaged_gp_race_capture_interval`, and visibly rendered a live GP
  race. With that ROM temporarily renamed, the next launch explicitly selected
  archive-only mode, skipped extraction, reached the same marker, completed all
  28 commands, and closed normally. The test ROM was restored afterward.
- A separate `PLATFORM=OS64` tree built the complete F0X/Torch graph against the
  iPhoneOS 26.5 SDK with a 16.0 deployment target. Xcode validated the resulting
  unsigned 33 MiB app; its executable is arm64 with platform `IOS`, its plist
  targets iPhone and iPad in landscape, and its 73-file payload contains the
  expected engine archive, fonts, recipes, and licenses with no ROM, generated
  gameplay archive, disk image, or save. No connected Apple device or signing
  identity exists on this host, so this is device-SDK compile/package evidence,
  not physical acceptance.

## Next action

This section belonged to the older checkpoint: its picker-to-race item is now
closed by the reconciliation at the top of this file. The active local task is
the touch implementation in `NEXT_BUILDER.md`; the unsigned iPhoneOS build still
awaits a machine with an Apple Development identity and connected iPad, and the
owner's macOS flashing confirmation remains open.
