# Handoff

## Current gate

Gate 3: native macOS cartridge runtime, with synthesis proven but physical
audio output and direct race visuals still open.

## Verified state

- Pinned, recursive upstream source is at `ref/G-Diffuser`, commit `719fd82`.
- The cartridge-only ARM64 build completes and the PCM capture harness passes
  all 5 cases / 28 checks.
- A bounded SDL dummy-device run with the dedicated audio thread produced
  nonzero cartridge PCM; see `TESTING.md` for exact capture evidence.

## Next action

Run one clean normal-CoreAudio macOS session and record route/volume evidence
without claiming speaker output from PCM alone. Keep this separate from the
independent direct-race-visual and iPad gates.
