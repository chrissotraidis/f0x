# F0X status

Last audited: 2026-08-13

This ledger deliberately distinguishes source inspection, compilation, and
runtime evidence. No Apple gameplay claim is made without a dated test entry.

| Gate | Status | Evidence |
| --- | --- | --- |
| 0: reproducible baseline | Verified | G-Diffuser `719fd82` and recursive dependency pins are documented. All maintained patches reverse-check, and a local fresh reconstruction matched every patched path byte-for-byte, including the required TMEM metadata header and copied icon assets. |
| 1: macOS ARM64 compile/link | macOS verified | Cartridge-only Debug executables and the sealed `F0X.app` bundle build as native arm64 Mach-O with Metal on Apple Silicon. |
| 2: fiber proof | macOS verified | `gdx_fiber_smoketest` passed 30,000 deterministic Apple Silicon switches across three stacks on 2026-08-11. |
| 3: complete macOS Metal race | Stability and save persistence verified; player completion blocked on this host | The signed packaged app boots an authorized raw ROM, deterministically traverses modes `0 -> 7 -> 10 -> 8 -> 9 -> 1`, and directly renders a live GP race. The repeating black strobe was reproduced at 38/60 direct window captures and reduced to 0/120 after keeping live Metal render targets off the unsynchronized readback queue. A later owner report aligned with an obsolete `G-Diffuser.app` sharing the current app's bundle identifier; this is a concrete launch-confusion mechanism, not proof of the path previously opened. The build now removes that legacy product, and dense current-bundle videos passed 462 race frames plus 544 Finder-launched Home frames without a near-black frame or brightness jump. A race HUD portrait crash from a physical-address/module-address collision was fixed. Partial-overlap TMEM metadata now preserves untouched ranges; the focused regression passes and the machine-settings route no longer reports null texture addresses. Two real Options-menu writes across two launches proved the 32 KiB SRAM is loaded and persisted exactly. Player-controlled race completion is blocked on this host: two tap-driven attempts, four System Events driver variants, and two internal-harness wall-hug probes all ended in RETIRE or an off-course craft; the probes captured the RETIRE banner at TIME 00'22"05 with LAP 1/3 and the mode 1 -> 15 -> 18 retire/continue loop, and the decompiled life-penalty path explains it. Full report in `docs/blockers/MAC-RACE-CONTROL-01.md`. Cartridge synthesis produces nonzero PCM; a focused review found no duplicated BGM or menu-SFX synthesis, while audible owner/device acceptance remains open. |
| 4: macOS application | macOS interface foundation verified | The sealed `F0X.app` passes strict ad-hoc signature validation, keeps mutable state in Application Support, and now opens on a branded F0X Home surface with verified-data state, Play, Manage Game Data, Open Data Folder, startup display settings, recovery guidance, and Quit. Management reuses the validated import screen in-process and guards against click-through. Release signing/notarization and broader settings remain open. |
| 5: iOS/iPadOS build | Simulator picker-to-race verified | A genuine arm64 iOS 16+ `F0X.app` builds with the Xcode Simulator SDK and launches on the iPad Pro 11-inch (M5) Simulator through SDL + Metal. One clean process presented the native Files picker, selected the authorized ROM from Files storage, copied and SHA-1-validated it in sandbox Documents, ran in-process Torch, atomically installed/hot-mounted the 3,610-entry archive, and visibly reached a live landscape GP race. This is not physical-device evidence. |
| 6: physical iPad engine proof | Corrected signed build installed and running with protected data preserved; route acceptance in progress | The complete F0X/Torch graph builds and signs as arm64 for iPhoneOS. The corrected app passed strict signature and ROM-free payload audits, was installed in place on an attached iPad Pro, and launched without replacing its data container. Pre/post-install SHA-256 remained exact for the local ROM (`2be0f861...`), generated archive (`7d60d975...`), save (`9d231971...`), and tablet preferences. The corrected cartridge font mapping passed continuous 21.67-second LLE/HLE title-to-menu PCM; on the physical iPad its first 2,400 audio buffers retained the two-buffer startup zero baseline with zero SDL drops/errors. The owner reports the major audio bugs appear fixed and accepted the current tablet layout, which is now the tablet default without changing phone defaults. Complete audible-route, course-preview framing, multi-touch/gameplay, lifecycle, performance, thermals, controller, and long-session acceptance remain open. |
| 7–8: product import / in-process Torch | macOS and iPad Simulator verified | The bundled desktop extractor produces a byte-deterministic, fully validated 3,610-entry archive whose golden is `7d60d975...`. With `GDX_INPROCESS_TORCH=ON`, both the sealed macOS app and genuine arm64 Simulator app link Torch statically without child processes. The uninterrupted native Files-picker-to-race Simulator process is verified, and a separate ROM-absent run independently reached the race from the installed archive. Physical-device import remains open. |
| Touch controls | Implemented; owner-accepted iPad profile promoted to tablet defaults | The F0X touch system writes direct atomic N64 pad state at the port-1 seam and passes all 87 focused sub-checks. Live Simulator acceptance verified the compact N64 glyph controls, safe-area layout, complete D-pad, Settings/editor behavior, persistence, arrow-only C-left, corrected analog direction, and one-second bright A-button latch. The physical iPad retained its tablet preference hash across every in-place update; its owner-accepted normalized profile is now the tablet default. Phone defaults are intentionally unchanged pending a later physical phone pass. Physical multi-touch stress, haptics feel, controller handoff, interruptions, and complete gameplay acceptance remain open. |
| Diagnostics | macOS and iOS Simulator verified | Home and in-game Settings actions collect app/OS/device, Metal, window/refresh/interpolation, game-data validation, save, controller/touch, scheduler, audio/timing, game mode, and bounded error-tail state into a privacy-scrubbed report. macOS presents `NSSharingServicePicker`; the iPhone 17 Pro Simulator presented `UIActivityViewController` for a 2 KB report. The iOS artifact was audited: sandbox-safe classifications and file sizes only, with no private paths, ROM/save contents, or signing material. `gdx_diagnostics_tests` passes. Physical-device sharing remains open. |
| App identity / public README | Simulator icon verified; public-release copy prepared | Original opaque 1024x1024 F0X artwork is tracked as an Apple asset catalog. Xcode generated iPhone and iPad icon renditions, both `CFBundleIcons` dictionaries, and a validated dual-family bundle; after a clean reinstall, iPhone 17 Pro Simulator Spotlight visibly rendered the real F0X icon instead of the prior placeholder. README now follows the HarkinianPad reference hierarchy while preserving F0X's stricter truth: no public IPA, App Store, or TestFlight claim, and no broader hardware-acceptance claim beyond the dated physical-iPad evidence. |
| Lifecycle / 60 Hz / high refresh | Multi-course 60 Hz macOS measured; Simulator lifecycle verified; physical audio cadence verified | macOS simulation/timer measured at 59.954 race frames/s on Mute City and 60.009 on Fire Field. Apple mobile now defaults the existing absolute N64 clock to 59.94 Hz; both Simulator and physical iPad produced about 60 audio buffers/s with zero queue drops/errors in the accepted windows. Simulator background/foreground neutralization and resume pass. Physical interruptions, route changes, Low Power Mode, thermals, 120 Hz behavior, and representative player-controlled performance remain open. |
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
3. Keep the corrected font-converter build as the audio baseline and finish
   owner listening for title/menu continuity, menu effects, GP countdown/race
   audio, and crackle/buzz absence. The major audio faults are reported fixed;
   signing, in-place install, launch, protected-data preservation, and the
   former permanent-silence transition are already proven.
4. Verify the host-packed 0.25 course-preview scale visually on the physical
   iPad. The deterministic Mac route already reaches and holds the six-map
   preview without a timeout or crash.
5. Run broader physical iPad/iPhone lifecycle/controller/touch acceptance and representative-course/device
   60 Hz measurement, 120 Hz/Match Display/Low Power Mode acceptance, and the
   signed-package/update matrix. README, icon, unsigned packaging, Simulator
   lifecycle, diagnostics, and final local audits are already complete.
6. Begin Expansion Kit only after the cartridge physical-acceptance gate passes.
