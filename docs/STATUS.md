# F0X status

Last audited: 2026-08-12

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
| 6: physical iPad engine proof | Device SDK compiled; physical run blocked | The complete F0X/Torch graph builds and Xcode-validates as an unsigned arm64 iPhoneOS app (iOS 16 minimum, iPhone/iPad families, landscape). This host currently has no connected Apple device and zero valid code-signing identities, so installation, signing, controller, lifecycle, audio, and physical gameplay remain untested. |
| 7–8: product import / in-process Torch | macOS and iPad Simulator verified | The bundled desktop extractor produces a byte-deterministic, fully validated 3,610-entry archive whose golden is `7d60d975...`. With `GDX_INPROCESS_TORCH=ON`, both the sealed macOS app and genuine arm64 Simulator app link Torch statically without child processes. The uninterrupted native Files-picker-to-race Simulator process is verified, and a separate ROM-absent run independently reached the race from the installed archive. Physical-device import remains open. |
| Touch controls | Simulator verified (core + settings/editor/persistence) | The F0X touch system is implemented: a UIKit overlay writes direct atomic N64 pad state merged at the port-1 seam in `input_bridge.c`, with a neutral desktop stub, touch CVars, a Settings -> Controls -> Touch Controls section, hand-authored phone/tablet defaults, opacity, haptics, auto-hide with physical controller, permanent menu access, menu-state hiding, a layout editor with versioned `NSUserDefaults` profiles, and lifecycle cancel paths. `gdx_touch_merge_tests` passes 87 sub-checks. On the iPad Simulator the overlay rendered, START/L/ACCEL/BOOST/BRAKE/D-pad produced the exact N64 bits, the analog stick reported continuous values, the ••• button opened/closed the GdxMenu with overlay hide/restore, auto-hide reacted to the Simulator's SDL-visible gamepads, and a touch-driven GP flow reached a live race. The Settings -> Controls -> Touch Controls page renders live with all widgets; the layout editor opens and its Size slider/Hide/Reset/Done chrome work; a live hold-to-cancel (ACCEL held -> Menu press -> neutral), the Z hold-to-latch (0x2000 persists after release, AX "Locked", blue fill, tap releases), and cancel-clears-latch are captured; and a non-default tablet profile saved through the editor survives relaunch and drives the overlay (D-pad y=0.318030 vs code default 0.6058). Phone defaults still need a phone-Simulator re-run and physical-device multi-touch acceptance remains open. SDL finger-to-ImGui mouse translation is unchanged menu input. |
| Diagnostics | macOS verified (Home action); iOS wiring open | A Share Diagnostic Log action on the F0X Home surface collects app/OS/device, Metal device, window/refresh/interpolation, game-data validation, save, controller/touch, scheduler, audio/timing state, and errors into a privacy-scrubbed text report and presents the macOS Share sheet (`NSSharingServicePicker`). `gdx_diagnostics_tests` passes all formatter/privacy/truncation checks; the live artifact was captured and audited (no ROM/save contents, signing material, or private paths). The iOS path (`UIActivityViewController`) compiles in the unsigned device build but is not yet wired into the menu/overlay. |
| Lifecycle / 60 Hz / high refresh | 60 Hz macOS measured; mobile lifecycle partial; high refresh not started | macOS simulation/timer measured at 59.954 race frames/s over a 37.4 s scripted Mute City race (NTSC cadence; race TIME advances in lockstep), with race-window frame pacing p50 16.6 ms / p99 17.9-19.2 ms / 0 spikes and audio-thread p95 2.9-4.0 ms on the Apple M1 host (see TESTING.md). A Simulator Home background + relaunch re-attached the touch overlay neutrally, and touch input clears on menu/cancel paths. Remaining: representative courses, physical-device timing, full mobile background/audio/render suspension, high refresh/Match Display transitions, and Low Power Mode behavior. |
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

1. Implement the locally actionable F0X-specific touch system from
   `TOUCH_CONTROLS_IMPLEMENTATION.md`, while keeping every physical-device claim
   open. The original controller-first physical gate is externally blocked here.
2. Ask the owner to confirm the corrected Finder launch after the stale duplicate
   bundle was removed; keep the dense title/menu/race/resize/fullscreen route as
   a regression even if confirmation closes the visible symptom.
3. Prove player control through a completed race and repeated representative
   gameplay. The settings-SRAM save/relaunch/load round trip is already
   verified. This gate is blocked on this host (no controller, Bluetooth off,
   blind automation provably retires the craft); resume with owner/human play
   or a connected controller, see `docs/blockers/MAC-RACE-CONTROL-01.md`.
4. Build/sign for iPhoneOS and establish physical-iPad controller, Files import,
   lifecycle, audio, persistence, and performance proof.
5. Run physical iPad/iPhone touch acceptance, then iOS diagnostics wiring,
   full 60 Hz acceptance (representative courses/devices), high refresh,
   release packaging, README, final audits, and Expansion Kit.
