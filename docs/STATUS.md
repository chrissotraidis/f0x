# F0X status

Last audited: 2026-08-11

This ledger deliberately distinguishes source inspection, compilation, and
runtime evidence. No Apple gameplay claim is made without a dated test entry.

| Gate | Status | Evidence |
| --- | --- | --- |
| 0: reproducible baseline | In progress | G-Diffuser `719fd82`; recursive source clone present locally. Desktop build pending. |
| 1: macOS ARM64 compile/link | Compiled | Cartridge-only Debug build linked as arm64 Mach-O on 2026-08-11; launch is still unverified. |
| 2: fiber proof | macOS verified | `gdx_fiber_smoketest` passed 30,000 deterministic Apple Silicon switches across three stacks on 2026-08-11. |
| 3: complete macOS Metal race | Not tested | Metal backend source is present; no Apple runtime evidence exists. |
| 4: macOS application | Not started | No F0X bundle/import shell exists. |
| 5: iOS/iPadOS build | Not started | No F0X iOS target exists. |
| 6: physical iPad engine proof | Not tested | No signed device run exists. |
| 7–8: product import / in-process Torch | Not started | Desktop extractor remains child-process based. |
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
