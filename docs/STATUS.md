# F0X status

Last audited: 2026-08-13

This ledger deliberately distinguishes source inspection, compilation, and
runtime evidence. No Apple gameplay claim is made without a dated test entry.

| Gate | Status | Evidence |
| --- | --- | --- |
| 0: reproducible baseline | Verified | G-Diffuser `719fd82` and recursive dependency pins are documented; the maintained patch series clean-applies and reverse-checks against the local source checkout. |
| 1: macOS ARM64 compile/link | macOS verified | Cartridge-only Debug executables and the sealed `F0X.app` bundle build as native arm64 Mach-O with Metal on Apple Silicon. |
| 2: fiber proof | macOS verified | `gdx_fiber_smoketest` passed 30,000 deterministic Apple Silicon switches across three stacks on 2026-08-11. |
| 3: complete macOS Metal race | Stability and save persistence verified; player completion blocked on this host | The signed packaged app boots an authorized raw ROM, deterministically traverses modes `0 -> 7 -> 10 -> 8 -> 9 -> 1`, and directly renders a live GP race. The repeating black strobe was reproduced at 38/60 direct window captures and reduced to 0/120 after keeping live Metal render targets off the unsynchronized readback queue. A later owner report aligned with an obsolete `G-Diffuser.app` sharing the current app's bundle identifier; this is a concrete launch-confusion mechanism, not proof of the path previously opened. The build now removes that legacy product, and dense current-bundle videos passed 462 race frames plus 544 Finder-launched Home frames without a near-black frame or brightness jump. A race HUD portrait crash from a physical-address/module-address collision was fixed. Two real Options-menu writes across two launches proved the 32 KiB SRAM is loaded and persisted exactly. Player-controlled race completion is blocked on this host: two tap-driven attempts, four System Events driver variants, and two internal-harness wall-hug probes all ended in RETIRE or an off-course craft; the probes captured the RETIRE banner at TIME 00'22"05 with LAP 1/3 and the mode 1 -> 15 -> 18 retire/continue loop, and the decompiled life-penalty path explains it. Full report in `docs/blockers/MAC-RACE-CONTROL-01.md`. Cartridge synthesis produces nonzero PCM under SDL dummy output; audible output remains unverified. |
| 4: macOS application | macOS interface foundation verified | The sealed `F0X.app` passes strict ad-hoc signature validation, keeps mutable state in Application Support, and now opens on a branded F0X Home surface with verified-data state, Play, Manage Game Data, Open Data Folder, startup display settings, recovery guidance, and Quit. Management reuses the validated import screen in-process and guards against click-through. Release signing/notarization and broader settings remain open. |
| 5: iOS/iPadOS build | Simulator picker-to-race verified | A genuine arm64 iOS 16+ `F0X.app` builds with the Xcode Simulator SDK and launches on the iPad Pro 11-inch (M5) Simulator through SDL + Metal. One clean process presented the native Files picker, selected the authorized ROM from Files storage, copied and SHA-1-validated it in sandbox Documents, ran in-process Torch, atomically installed/hot-mounted the 3,610-entry archive, and visibly reached a live landscape GP race. This is not physical-device evidence. |
| 6: physical iPad engine proof | Device SDK compiled; physical run blocked | The complete F0X/Torch graph builds and Xcode-validates as an unsigned arm64 iPhoneOS app (iOS 16 minimum, iPhone/iPad families, landscape). A deterministic ROM-free re-signable IPA workflow now audits and packages that product, but this host has no connected Apple device and zero valid code-signing identities, so installation, signing, controller, physical lifecycle/audio, and gameplay remain untested. |
| 7–8: product import / in-process Torch | macOS and iPad Simulator verified | The bundled desktop extractor produces a byte-deterministic, fully validated 3,610-entry archive whose golden is `7d60d975...`. With `GDX_INPROCESS_TORCH=ON`, both the sealed macOS app and genuine arm64 Simulator app link Torch statically without child processes. The uninterrupted native Files-picker-to-race Simulator process is verified, and a separate ROM-absent run independently reached the race from the installed archive. Physical-device import remains open. |
| Touch controls | Simulator verified (core + visual layout + settings/editors/persistence, phone + tablet) | The F0X touch system writes direct atomic N64 pad state at the port-1 seam and passes all 87 focused sub-checks. Live iPad and iPhone 17 Pro Simulator acceptance on 2026-08-13 verified the HarkinianPad-derived compact N64 glyph controls, safe-area separation, round stick knob, complete D-pad, Settings/editor behavior, latch/cancel/persistence, and responsive Input Editor. The Input Editor now occupies the safe viewport, uses aligned mapping rows, lays out Buttons beside D-Pad/Analog on iPad and collapses to one column on iPhone, exposes all lower sections (secondary stick, rumble, gyro, LEDs), and suppresses both gameplay controls and the ••• affordance while open. Closing returns to Settings; closing Settings restores the neutral gameplay overlay. Maintained G-Diffuser/libultraship patches reverse-check and clean-replay byte-for-byte; macOS and iOS Simulator builds pass. Physical-device multi-touch, haptics feel, interruptions, and long-session acceptance remain open. |
| Diagnostics | macOS and iOS Simulator verified | Home and in-game Settings actions collect app/OS/device, Metal, window/refresh/interpolation, game-data validation, save, controller/touch, scheduler, audio/timing, game mode, and bounded error-tail state into a privacy-scrubbed report. macOS presents `NSSharingServicePicker`; the iPhone 17 Pro Simulator presented `UIActivityViewController` for a 2 KB report. The iOS artifact was audited: sandbox-safe classifications and file sizes only, with no private paths, ROM/save contents, or signing material. `gdx_diagnostics_tests` passes. Physical-device sharing remains open. |
| App identity / public README | Simulator verified; public-release copy prepared | Original opaque 1024x1024 F0X artwork is tracked as an Apple asset catalog. Xcode generated iPhone and iPad icon renditions, both `CFBundleIcons` dictionaries, and a validated dual-family bundle; after a clean reinstall, iPhone 17 Pro Simulator Spotlight visibly rendered the real F0X icon instead of the prior placeholder. README now follows the HarkinianPad reference hierarchy while preserving F0X's stricter truth: no public IPA, App Store, TestFlight, or physical-device claim. |
| Lifecycle / 60 Hz / high refresh | 60 Hz macOS measured; Simulator lifecycle/audio/stability verified; high-refresh acceptance hardware-blocked | macOS simulation/timer measured at 59.954 race frames/s over a 37.4 s scripted Mute City race, with race-window p50 16.6 ms / p99 17.9-19.2 ms / 0 spikes and audio-thread p95 2.9-4.0 ms. On iOS, libultraship defaults to SDL; the iPhone 17 Pro Simulator logs a real 2-channel 32 kHz device, active synthesis, and live BGM. UIKit lifecycle observation starts before first-time setup without attaching the gameplay overlay. Resign/background neutralizes touch, flushes CVars, suspends simulation/Metal/audio during gameplay, and stops setup drawing; foreground resumes neutrally. A live race → Home → F0X cycle logged both edges, stayed alive, kept the file-backed log byte/timestamp stable during the settled background interval, and visibly resumed. The converted-display-list cache regression and guarded 5:16 race/transition soak also pass. Representative-course/device timing, physical interruptions/audio, Low Power Mode, thermals, and 120 Hz acceptance remain open; this Mac and its Simulator expose only 60 Hz and no physical device is connected. |
| 64DD Expansion Kit | Deferred | Cartridge-only build is the first Apple target. |

## Baseline discrepancy from supplied research

The research refers to the v1.0.1 tag (`dfad53d`). F0X is pinned to current
upstream `main` (`719fd82`, 2026-08-11) after recording it before any source
change. The newer tree has additional runtime/extraction work and defaults
`GDX_EXPANSION_KIT` to ON. Future decisions use the pinned source, not a
stale inference from the research.

## Evidence labels

`Planned`, `implemented`, `compiled`, `Simulator verified`, `macOS verified`,
`physical iPhone verified`, `physical iPad verified`, `gameplay verified`,
`partially working`, `blocked`, and `not tested` are used literally.

## Revised execution order

The active loop resumes at the first unproven product behavior, not at an
already-passed compile or fiber gate:

1. Ask the owner to confirm the corrected Finder launch after the stale duplicate
   bundle was removed; keep the dense title/menu/race/resize/fullscreen route as
   a regression even if confirmation closes the visible symptom.
2. Prove player control through a completed race and repeated representative
   gameplay. The settings-SRAM save/relaunch/load round trip is already
   verified. This gate is blocked on this host (no controller, Bluetooth off,
   blind automation provably retires the craft); resume with owner/human play
   or a connected controller, see `docs/blockers/MAC-RACE-CONTROL-01.md`.
3. Build/sign for iPhoneOS and establish physical-iPad controller, Files import,
   lifecycle, audio, persistence, and performance proof.
4. Run physical iPad/iPhone touch acceptance, representative-course/device
   60 Hz measurement, 120 Hz/Match Display/Low Power Mode acceptance, and the
   signed-package/update matrix. README, icon, unsigned packaging, Simulator
   lifecycle, diagnostics, and final local audits are already complete.
5. Begin Expansion Kit only after the cartridge physical-acceptance gate passes.
