# Handoff

## Current gate

Gate 0: reproducible cartridge-only baseline.

## Verified state

- Pinned, recursive upstream source is at `ref/G-Diffuser`, commit `719fd82`.
- Local reference files are ignored; the repository safety boundary is now
  explicit.
- The G-Diffuser research and HarkinianPad README benchmark were read and
  reconciled with the current source.

## Next action

Run the macOS Debug configure/build from [`BUILDING.md`](BUILDING.md) with
`GDX_EXPANSION_KIT=OFF`. Preserve the full build output as evidence. If it
fails, make the smallest reproducible fix only after identifying whether the
failure is upstream source, a missing host dependency, or an Apple-specific
assumption.
