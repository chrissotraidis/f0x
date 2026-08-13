# F0X exact next-builder handoff

Last reconciled: 2026-08-13 from repository `main` commit `47c9727`, with the
verified touch/Input Editor/audio/diagnostics unit recorded in the maintained
patches and this handoff.

## Read order

Before editing, read completely:

1. `README.md`
2. `docs/STATUS.md`
3. this file
4. `docs/TOUCH_CONTROLS_IMPLEMENTATION.md`
5. `docs/TESTING.md`
6. `docs/KNOWN_ISSUES.md`
7. `docs/ARCHITECTURE.md`
8. `docs/BUILDING.md`
9. `docs/GAME_DATA.md`
10. `docs/LEGAL_AND_PROVENANCE.md`
11. `docs/G-Diffuser_Apple_Port_Research_Plan.md`
12. the original master goal, if supplied by the owner

Then inspect `git status`, the pinned SHAs, current device/Simulator state, and
the exact evidence artifact before relying on a path or process ID.

## What is genuinely finished

- Pinned recursive baseline at G-Diffuser `719fd82`, libultraship `a4919b1`,
  Torch `c1bdc6f`, decomp `f7fd0fd`, and HarkinianPad reference `1197472`.
- Native Apple Silicon build and 30,000-switch ucontext fiber regression.
- Sealed, ad-hoc-signed local macOS `F0X.app` with separate immutable/mutable
  paths and branded F0X Home.
- Live macOS Metal title and race; renderer strobe reproduction/fix and dense
  current-bundle capture evidence; physical-address HUD crash fix.
- Real macOS 32 KiB settings-SRAM write/relaunch/load round trip.
- Nonzero cartridge PCM synthesis and dedicated producer proof under SDL dummy.
- Deterministic 3,610-entry archive generation and validation.
- In-process Torch API and F0X integration.
- Genuine arm64 iPad Simulator SDL/UIKit/Metal app.
- One uninterrupted native Files picker → selected authorized ROM → validation →
  in-process extraction → atomic install/hot mount → visible live race process.
- Archive-only Simulator race without the ROM.
- Complete unsigned arm64 iPhoneOS app compile and ROM-free payload audit.
- Touch visual/Input Editor Simulator acceptance on iPad Pro 11-inch (M5) and
  iPhone 17 Pro: compact reference-aligned controls, responsive editor, no
  overlay obstruction, and neutral close/restore behavior.
- macOS Share Diagnostic Log Home action (collector + privacy scrub + share
  sheet + `gdx_diagnostics_tests`), macOS 60 Hz sim/timer/pacing measurement
  (59.954 race frames/s, race-window p50 16.6 ms / p99 17.9-19.2 ms / 0 spikes
  on the Apple M1 host), the macOS race-control blocker report, and the
  phone-defaults re-run on the current build (iPhone 17 Pro Simulator).

## What is explicitly not finished

- Physical-device touch acceptance (multi-touch stress, controller handoff,
  interruptions, haptics feel, long sessions, thermals).
- Physical iPad/iPhone signing, install, launch, controller, touch, audio,
  lifecycle, performance, thermals, or long-session evidence.
- A player-completed macOS race; blocked on this host with an exact report in
  `docs/blockers/MAC-RACE-CONTROL-01.md` (two tap attempts, four System Events
  driver variants, and two internal-harness wall-hug probes all ended in
  RETIRE or an off-course craft; the RETIRE banner and the mode 1 -> 15 -> 18
  retire/continue loop are captured).
- Owner confirmation that the exact corrected current bundle no longer flashes.
- Audible macOS/mobile speakers/headphones and route/interruption behavior on
  physical hardware. The Simulator SDL device now opens and synthesis runs.
- A live iPhone 17 Pro Simulator race crashed in the display-list bridge
  (IOS-GFX-CRASH-01): `gConvertedWideIsF3d.find()` dereferenced 0x1e0; the
  crash is under investigation (repro with guard malloc, then smallest
  regression + fix).
- Mobile lifecycle pause/resume/persistence.
- Correct 60 Hz timing evidence and high-refresh acceptance.
- Release signing/notarization/re-signable package workflow.
- HarkinianPad-quality final public README/screenshots/install guide.
- Expansion Kit.

## Environment boundary at handoff

- One iPhone 17 Pro Simulator is booted.
- No physical Apple device is connected (`devicectl: No devices found`).
- No valid code-signing identity exists (`0 valid identities found`).
- The installed Simulator container contains authorized private inputs/derived
  data. Treat them as user-owned local state; never stage, copy into docs, or
  include in a package.
- Build products live under ignored `build/` and may be stale after source edits.
- Process IDs and Simulator bundle/container UUIDs are ephemeral; rediscover them.

## Maintained Apple source state (2026-08-13)

The tested ignored checkout contains the following Apple-side implementation,
all represented by the regenerated maintained patches:

- `port/gdx_console_log.{h,cpp}` — warn/error tail ring
  (`GdxConsoleLogErrorTail`) for the diagnostics report.
- `port/gdx_diagnostics.h` — `gdx_diagnostics_share_runtime` declaration.
- `port/main.cpp` — `gdx_diagnostics_share_runtime()` implementation (live
  in-game collection) AND the iOS audio fix (resolve
  `gEnhancements.Audio.Backend` auto -> SDL on iOS builds).
- `port/gdx_menu_registry.cpp` — Settings -> General "Diagnostics" section
  with the "Share Diagnostic Log" button (Apple builds).

The macOS app, iOS Simulator app, and unsigned arm64 iPhoneOS app compile with
these changes. The iPhone Simulator opens SDL audio and the in-game diagnostic
action presents an audited native Share sheet. The maintained G-Diffuser and
libultraship patches reverse-check and clean-replay; touch tests are 87/87,
diagnostics tests pass, and the device bundle payload audit reports zero
prohibited files.

## Highest-priority actionable work

1. **Reproduce and fix IOS-GFX-CRASH-01.** Relaunch the rebuilt app on the
   iPhone 17 Pro Simulator with `SIMCTL_CHILD_MallocGuardEdges=1`,
   `SIMCTL_CHILD_MallocStackLogging=1`, and `SIMCTL_CHILD_GUARD_MALLOC=1`, let
   the race run ~3 min, and find the write that clobbers the
   `gConvertedWideIsF3d` heap nodes (or prove a lifetime/thread bug). Add the
   smallest falsifiable regression, fix, re-run, and document. The bridge is
   untouched by the F0X patches, so suspect the converted-wide/asset pipeline
   or a freed-node reuse in the display-list walk.
2. Then continue the remaining queue: physical iPad/iPhone acceptance
   (externally blocked here), representative-course 60 Hz measurement,
   high refresh, packaging, README, Expansion Kit.

Do not regress the verified core: `gdx_touch_merge_tests` (87 checks), the
macOS sealed-bundle race route, the unsigned iPhoneOS build, and the
`gdx_diagnostics_tests` are the standing regressions.

## Remaining execution queue after touch

### A. Touch completion and Simulator evidence

Finish every mapping, separate phone/tablet defaults, settings, editor,
persistence, opacity, haptics, menu visibility, controller auto-hide, and all
cancel paths. Run the full matrix in the touch reference. Commit only after
patch replay and macOS/device-build regressions pass.

### B. macOS human acceptance and flashing confirmation

Build the exact current `F0X.app`; verify only one bundle with
`com.chrissotraidis.f0x` is registered; run the dense title/menu/race/resize/
fullscreen route; have the owner open that exact bundle and confirm whether the
reported rapid flashing remains. If it remains, capture a human-visible video
and correlate it with frame/present logs. Do not close from automated luma alone.

Use real sustained input or a physical controller to complete a race. Verify A
accelerator, C-down brake, B boost, Z/R slides and attacks, C-right camera,
C-up look-back, pause, results, another race, and representative tracks. Record
failures honestly. Automated blind driving is exhausted on this host (see
`docs/blockers/MAC-RACE-CONTROL-01.md`): the smallest resume action is owner or
human play with the working keyboard mapping, or any USB/Bluetooth controller.

### C. Physical iPad controller-first gate

On a signing-capable Mac with a connected iPad:

1. rebuild from the maintained patch series;
2. sign with a controlled bundle identifier/profile;
3. install and cold launch;
4. run the fiber smoke test or equivalent device regression;
5. import the legal ROM through Files and extract on device;
6. complete a controller race and repeat it;
7. validate Metal, audible audio, save/reload, background/foreground, controller
   disconnect/reconnect, memory, thermals, and extended runtime;
8. capture evidence without provisioning secrets or game data.

### D. Physical touch acceptance

Run touch-only complete races on iPad and iPhone, including simultaneous contacts,
layout editing, both orientations, safe areas, controller handoff, interruption
clearing, audio routes, save/reload, and extended sessions. Simulator results
remain separate.

### E. Diagnostics

The macOS Home "Share Diagnostic Log" action is implemented and verified
(2026-08-13): the privacy-scrubbed text report covers app/OS/device, Metal
device, window/refresh/interpolation, game-data validation, save, controller/
touch, scheduler, audio/timing state, and errors; `NSSharingServicePicker`
presented the artifact; `gdx_diagnostics_tests` passes; the report contains no
ROM/save contents, signing material, or private paths (see TESTING.md). The
next slice is the in-game entry and the iOS wiring: trigger the same collector
from the GdxMenu (and/or the touch overlay) and present
`UIActivityViewController` on iOS — the share module already compiles into the
unsigned device build. Consider a live log-tail error ring so the report's
Errors section carries the last runtime warnings instead of "none collected".

### F. Timing and high refresh

The macOS 60 Hz base is measured (2026-08-13): a new opt-in
`GDX_RACE_TIME_PROBE=1` probe plus `GDX_PERF=1` showed 59.954 race frames/s
over a 37.4 s scripted Mute City race (race timer and game frame counter in
lockstep), race-window pacing p50 16.6 ms / p99 17.9-19.2 ms / 0 spikes, and
audio-thread p95 2.9-4.0 ms on the Apple M1 host. Remaining: measure
representative courses, verify the race HUD timer against wall clock on
physical devices, then test 60/Match Display/120 transitions on capable
hardware, including Low Power Mode and thermal behavior, without changing
simulation speed.

### G. Release hardening and public docs

Add reproducible build/package/audit scripts, exact checksums, clean-machine
replay, update/container behavior, Developer ID/notarization or explicitly
unsigned/re-signable boundaries, and complete ROM/signing scans. Replace the
current concise README with a polished public guide only as features are proven.
Use real captures, controls/settings tables, install/build/first-run/diagnostics/
performance/FAQ content, and retain every limitation.

### H. Expansion Kit

Only after cartridge base acceptance, enable `GDX_EXPANSION_KIT=ON` and treat
disk/IPL import, extraction, writable media, editors, DD content, lifecycle,
save/reload, and packaging as a distinct evidence program. Never destabilize the
cartridge-only path.

## Documentation discipline for the next builder

For each gate:

1. write the expected observable result before editing;
2. identify the smallest falsifiable regression;
3. make the smallest source change;
4. build, run, interact, and inspect the actual artifact;
5. store compact evidence under `docs/evidence/<gate>/` when useful;
6. append a dated `TESTING.md` entry with command, result, failures, fixes, and
   boundary;
7. update `STATUS`, `KNOWN_ISSUES`, relevant architecture/build/data/touch docs,
   and README public claims;
8. regenerate maintained patches and prove clean/reverse application;
9. audit staged files for ROMs, archives, saves, logs with private data, and
   signing secrets;
10. make one focused commit;
11. immediately pick the next highest unmet gate.

Three repetitions of the exact same blocker require a written stop report with
reproduction, logs, attempted fixes, why no further safe local work exists, and
the smallest external/technical action needed. A hard task, slow build, missing
automation, or Simulator limitation is not by itself a fundamental blocker.
