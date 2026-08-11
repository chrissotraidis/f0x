# F0X

F0X is an in-progress native Apple port of **F-Zero X** built on
[G-Diffuser](https://github.com/Zorkats/G-Diffuser): native decompiled game
logic, libultraship/Fast3D, and the existing Metal renderer. It is not a
generic N64 emulator frontend.

F0X will never include F-Zero X, a ROM, extracted Nintendo assets, saves, or
ROM-derived archives. A user-owned supported ROM will be validated and
prepared locally when the Apple import flow is implemented.

## Current status

| Area | Evidence-backed status |
| --- | --- |
| Baseline | Current upstream pinned and source-audited |
| Apple Silicon macOS | Not built or run yet |
| iPhone / iPad | Not built or run yet |
| Metal on Apple | Source path identified; not verified in F0X |
| ROM import / extraction | Planned; no F0X implementation yet |
| Touch / high refresh / Expansion Kit | Not started |

The project is at Gate 0. See [`docs/STATUS.md`](docs/STATUS.md) for the
evidence ledger, [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md)
for the gate order, and [`docs/LEGAL_AND_PROVENANCE.md`](docs/LEGAL_AND_PROVENANCE.md)
for the game-data boundary.
