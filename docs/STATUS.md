# F0X status

Last audited: 2026-08-12

This ledger deliberately distinguishes source inspection, compilation, and
runtime evidence. No Apple gameplay claim is made without a dated test entry.

| Gate | Status | Evidence |
| --- | --- | --- |
| 0: reproducible baseline | Verified | G-Diffuser `719fd82` and recursive dependency pins are documented; the maintained patch series clean-applies and reverse-checks against the local source checkout. |
| 1: macOS ARM64 compile/link | macOS verified | Cartridge-only Debug executables and the sealed `F0X.app` bundle build as native arm64 Mach-O with Metal on Apple Silicon. |
| 2: fiber proof | macOS verified | `gdx_fiber_smoketest` passed 30,000 deterministic Apple Silicon switches across three stacks on 2026-08-11. |
| 3: complete macOS Metal race | Stability and save persistence verified | The signed packaged app boots an authorized raw ROM, deterministically traverses modes `0 -> 7 -> 10 -> 8 -> 9 -> 1`, and directly renders a live GP race. The repeating black strobe was reproduced at 38/60 direct window captures and reduced to 0/120 after keeping live Metal render targets off the unsynchronized readback queue. Additional current-build samples passed 0/80 across two window sizes and 0/60 in fullscreen. A race HUD portrait crash from a physical-address/module-address collision was fixed. Two real Options-menu writes across two launches proved the 32 KiB SRAM is loaded and persisted exactly. Player-controlled race completion remains open. Cartridge synthesis produces nonzero PCM under SDL dummy output; audible output remains unverified. |
| 4: macOS application | macOS interface foundation verified | The sealed `F0X.app` passes strict ad-hoc signature validation, keeps mutable state in Application Support, and now opens on a branded F0X Home surface with verified-data state, Play, Manage Game Data, Open Data Folder, startup display settings, recovery guidance, and Quit. Management reuses the validated import screen in-process and guards against click-through. Release signing/notarization and broader settings remain open. |
| 5: iOS/iPadOS build | Not started | No F0X iOS target exists. |
| 6: physical iPad engine proof | Not tested | No signed device run exists. |
| 7–8: product import / in-process Torch | macOS archive path verified; mobile importer open | The bundled desktop extractor now produces a byte-deterministic, fully validated 3,610-entry archive whose refreshed golden is `7d60d975...`. The sealed app installed it atomically, reused it unchanged on warm boot, and reached a GP race with the original ROM absent. The desktop extractor remains a child process; an in-process mobile importer and first-time import UX proof remain open. |
| Touch / lifecycle / 60 Hz / high refresh | Not started | Deferred until controller-first engine proof. |
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

1. Obtain owner confirmation that the current packaged Metal build no longer
   flashes; retain the automated windowed/resize/fullscreen soak as regression.
2. Prove player control through a completed race, then save creation, clean
   relaunch, and load persistence.
3. Complete the first-time import UX around the now-verified deterministic
   desktop archive path, then replace the child process with an in-process
   mobile-capable importer.
4. Establish iOS/iPadOS build closure, then a physical-iPad controller race,
   lifecycle, and audio.
5. Only after physical engine proof: touch UX, timing/high refresh, release
   packaging, README, and final audits.
