# F0X status

Last audited: 2026-08-12

This ledger deliberately distinguishes source inspection, compilation, and
runtime evidence. No Apple gameplay claim is made without a dated test entry.

| Gate | Status | Evidence |
| --- | --- | --- |
| 0: reproducible baseline | Verified | G-Diffuser `719fd82` and recursive dependency pins are documented; the maintained patch series clean-applies and reverse-checks against the local source checkout. |
| 1: macOS ARM64 compile/link | macOS verified | Cartridge-only Debug executables and the sealed `F0X.app` bundle build as native arm64 Mach-O with Metal on Apple Silicon. |
| 2: fiber proof | macOS verified | `gdx_fiber_smoketest` passed 30,000 deterministic Apple Silicon switches across three stacks on 2026-08-11. |
| 3: complete macOS Metal race | Stability and save persistence verified | The signed packaged app boots an authorized raw ROM, deterministically traverses modes `0 -> 7 -> 10 -> 8 -> 9 -> 1`, and directly renders a live GP race. The repeating black strobe was reproduced at 38/60 direct window captures and reduced to 0/120 after keeping live Metal render targets off the unsynchronized readback queue. A later owner report aligned with an obsolete `G-Diffuser.app` sharing the current app's bundle identifier; this is a concrete launch-confusion mechanism, not proof of the path previously opened. The build now removes that legacy product, and dense current-bundle videos passed 462 race frames plus 544 Finder-launched Home frames without a near-black frame or brightness jump. A race HUD portrait crash from a physical-address/module-address collision was fixed. Two real Options-menu writes across two launches proved the 32 KiB SRAM is loaded and persisted exactly. Player-controlled race completion remains open. Cartridge synthesis produces nonzero PCM under SDL dummy output; audible output remains unverified. |
| 4: macOS application | macOS interface foundation verified | The sealed `F0X.app` passes strict ad-hoc signature validation, keeps mutable state in Application Support, and now opens on a branded F0X Home surface with verified-data state, Play, Manage Game Data, Open Data Folder, startup display settings, recovery guidance, and Quit. Management reuses the validated import screen in-process and guards against click-through. Release signing/notarization and broader settings remain open. |
| 5: iOS/iPadOS build | Simulator picker-to-race verified | A genuine arm64 iOS 16+ `F0X.app` builds with the Xcode Simulator SDK and launches on the iPad Pro 11-inch (M5) Simulator through SDL + Metal. One clean process presented the native Files picker, selected the authorized ROM from Files storage, copied and SHA-1-validated it in sandbox Documents, ran in-process Torch, atomically installed/hot-mounted the 3,610-entry archive, and visibly reached a live landscape GP race. This is not physical-device evidence. |
| 6: physical iPad engine proof | Device SDK compiled; physical run blocked | The complete F0X/Torch graph builds and Xcode-validates as an unsigned arm64 iPhoneOS app (iOS 16 minimum, iPhone/iPad families, landscape). This host currently has no connected Apple device and zero valid code-signing identities, so installation, signing, controller, lifecycle, audio, and physical gameplay remain untested. |
| 7–8: product import / in-process Torch | macOS and iPad Simulator verified | The bundled desktop extractor produces a byte-deterministic, fully validated 3,610-entry archive whose golden is `7d60d975...`. With `GDX_INPROCESS_TORCH=ON`, both the sealed macOS app and genuine arm64 Simulator app link Torch statically without child processes. The uninterrupted native Files-picker-to-race Simulator process is verified, and a separate ROM-absent run independently reached the race from the installed archive. Physical-device import remains open. |
| Touch controls | Not implemented | The HarkinianPad checkout and patches are read-only references. F0X has no UIKit gameplay overlay, direct touch pad-state bridge, racing layout, touch settings, editor, opacity, or controller handoff. SDL finger-to-ImGui mouse translation is menu input only. |
| Lifecycle / 60 Hz / high refresh | Not started | Mobile background/audio/render suspension, correct 60 Hz acceptance, and later Match Display/120 Hz remain open. |
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
   gameplay. The settings-SRAM save/relaunch/load round trip is already verified.
4. Build/sign for iPhoneOS and establish physical-iPad controller, Files import,
   lifecycle, audio, persistence, and performance proof.
5. Run physical iPad/iPhone touch acceptance, then diagnostics, correct 60 Hz,
   high refresh, release packaging, README, final audits, and Expansion Kit.
