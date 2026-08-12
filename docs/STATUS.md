# F0X status

Last audited: 2026-08-12

This ledger deliberately distinguishes source inspection, compilation, and
runtime evidence. No Apple gameplay claim is made without a dated test entry.

| Gate | Status | Evidence |
| --- | --- | --- |
| 0: reproducible baseline | In progress | G-Diffuser `719fd82`; recursive source clone present locally. Desktop build pending. |
| 1: macOS ARM64 compile/link | Compiled | Cartridge-only Debug build linked as arm64 Mach-O on 2026-08-11. |
| 2: fiber proof | macOS verified | `gdx_fiber_smoketest` passed 30,000 deterministic Apple Silicon switches across three stacks on 2026-08-11. |
| 3: complete macOS Metal race | Partially working | The branded F0X Metal bundle now visibly holds the F-Zero X title screen after the host acquires its drawable before synchronous game rendering. A test-only local archive deterministically traverses title, menu, course selection, machine selection, machine settings, and GP race mode before a clean exit. Framebuffer BMP readbacks remain black despite the visible title. Cartridge synthesis and the dedicated producer generate nonzero PCM in a bounded SDL dummy-device run; audible output remains unverified. |
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
