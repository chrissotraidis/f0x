# F0X exact next-builder handoff

Last reconciled: 2026-08-12 at repository `main` commit `22f2772` before this
documentation checkpoint.

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

## What is explicitly not finished

- Physical-device touch acceptance (multi-touch stress, controller handoff,
  interruptions, haptics feel, long sessions, thermals) and a fresh
  phone-defaults re-run on a phone Simulator for the current build.
- Physical iPad/iPhone signing, install, launch, controller, touch, audio,
  lifecycle, performance, thermals, or long-session evidence.
- A player-completed macOS race; two real-input attempts failed before finish.
- Owner confirmation that the exact corrected current bundle no longer flashes.
- Audible macOS/mobile speakers/headphones and route/interruption behavior.
- Mobile lifecycle pause/resume/persistence.
- Full diagnostics/share-log product flow.
- Correct 60 Hz timing evidence and high-refresh acceptance.
- Release signing/notarization/re-signable package workflow.
- HarkinianPad-quality final public README/screenshots/install guide.
- Expansion Kit.

## Environment boundary at handoff

- One iPad Pro 11-inch (M5) Simulator is booted.
- No physical Apple device is connected (`devicectl: No devices found`).
- No valid code-signing identity exists (`0 valid identities found`).
- The installed Simulator container contains authorized private inputs/derived
  data. Treat them as user-owned local state; never stage, copy into docs, or
  include in a package.
- Build products live under ignored `build/` and may be stale after source edits.
- Process IDs and Simulator bundle/container UUIDs are ephemeral; rediscover them.

## Highest-priority actionable work

The touch system is implemented and Simulator-verified at its core, including
live captures of the settings page, editor open/save, hold-to-cancel, the
Z hold-to-latch, cancel-clears-latch, and non-default profile persistence
across relaunch (see `docs/evidence/touch-ios/2026-08-12.txt` and
`docs/evidence/touch-ios-live/2026-08-12-live-captures.txt`). The remaining
touch work is polish and physical acceptance:

1. Re-run the phone defaults on a phone Simulator (the compact layout was
   previously verified on an iPhone 17 Pro Simulator; a fresh run on the
   current build is the standing check), and consider a live editor pass that
   also exercises Hide/Show and Reset on the tablet profile without leaving a
   stale override in the Simulator container.
2. Re-run the touch-driven GP flow and complete a race on Simulator, then
   replay the whole matrix on physical iPad/iPhone when a signing-capable Mac
   with a connected device is available.
3. Physical touch acceptance remains the only Simulator-independent proof:
   sustained simultaneous steering + accelerator + brake/boost/attack,
   four-contact stress, controller handoff, interruptions, haptics feel,
   long sessions, and thermals.

Do not regress the verified core: `gdx_touch_merge_tests` (87 checks), the
macOS sealed-bundle race route, and the unsigned iPhoneOS build are the
standing regressions.

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
failures honestly.

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

Add an accessible Share Diagnostic Log action. Include app/OS/device, renderer
and Metal device, game-data validation status, extraction/resource mount,
controller/touch state, scheduler/fibers, lifecycle, audio, save path class,
timing, and errors. Exclude ROM/assets/save contents, signing material, and
unnecessary full private paths. Test the shared artifact.

### F. Timing and high refresh

At 60 Hz, measure simulation rate, race timer, physics, AI, input, audio sync,
frame pacing, and presentation during real races. Fix correctness before
interpolation. Then test 60/Match Display/120 transitions on capable hardware,
including Low Power Mode and thermal behavior, without changing simulation.

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
