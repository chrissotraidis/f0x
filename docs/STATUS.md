# F0X status

Last audited: 2026-08-12

This ledger deliberately distinguishes source inspection, compilation, and
runtime evidence. No Apple gameplay claim is made without a dated test entry.

| Gate | Status | Evidence |
| --- | --- | --- |
| 0: reproducible baseline | Verified | G-Diffuser `719fd82` and recursive dependency pins are documented; the maintained patch series clean-applies and reverse-checks against the local source checkout. |
| 1: macOS ARM64 compile/link | macOS verified | Cartridge-only Debug executables and the sealed `F0X.app` bundle build as native arm64 Mach-O with Metal on Apple Silicon. |
| 2: fiber proof | macOS verified | `gdx_fiber_smoketest` passed 30,000 deterministic Apple Silicon switches across three stacks on 2026-08-11. |
| 3: complete macOS Metal race | Partially working | The signed packaged app now boots an authorized raw ROM, deterministically traverses modes `0 -> 7 -> 10 -> 8 -> 9 -> 1`, and directly renders a live GP race with track, racers, player craft, and HUD. The direct image also shows missing/cropped HUD and machine-texture regions, matching raw-fallback null-texture warnings; visual correctness and a player-controlled completed race remain open. Cartridge synthesis and the dedicated producer generate nonzero PCM in a bounded SDL dummy-device run; audible output remains unverified. |
| 4: macOS application | Partially working | A clean, ad-hoc-signed `F0X.app` Debug bundle passes strict macOS signature validation, carries correct F0X metadata, keeps mutable state in `~/Library/Application Support/F0X`, directly launches its branded Metal cartridge-ROM setup window, and now visibly renders a stable title screen from authorized local game data. Completed import, saves, Developer ID signing/notarization, and distribution remain unproven. |
| 5: iOS/iPadOS build | Not started | No F0X iOS target exists. |
| 6: physical iPad engine proof | Not tested | No signed device run exists. |
| 7–8: product import / in-process Torch | Not started | Desktop extractor remains child-process based; current child-process extraction is rejected by its SHA-256 golden gate and falls back to the raw ROM. |
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

1. Correct the packaged raw-ROM race's missing/cropped HUD and machine textures,
   then prove player control through a completed race.
2. Prove save creation, clean relaunch, and load persistence.
3. Correct the desktop extraction golden mismatch and prove safe, atomic ROM
   import through the F0X UI.
4. Establish iOS/iPadOS build closure, then a physical-iPad controller race,
   lifecycle, and audio.
5. Only after physical engine proof: touch UX, timing/high refresh, release
   packaging, README, and final audits.
