# F0X implementation plan

## Scope and invariant

F0X keeps the existing path: F-Zero X matching decompilation → G-Diffuser →
libultraship/Fast3D → Metal. It will not become a new engine or an emulator
frontend. Public source and packages remain ROM-free.

## Ordered gates

1. Freeze and reproduce the current G-Diffuser baseline with
   `GDX_EXPANSION_KIT=OFF`; record every dependency and audit repository safety.
2. Make the smallest source changes needed for an Apple Silicon macOS
   configure/link: explicit platform distinctions, Linux-only linker behavior,
   and correct renderer/audio/fullscreen capability selection.
3. Add and run a standalone Apple ARM64 fiber smoke test before inferring that
   the scheduler works.
4. Prove one complete macOS Metal race with input, audio, and persistent state.
5. Productize macOS paths, bundle behavior, and managed game data.
6. Add an iOS/iPadOS bundle around the same runtime; prove a complete physical
   iPad controller race before building polished touch controls.
7. Implement transactional Files import and in-process Torch extraction on iOS.
8. Add separate iPad/iPhone racing touch layouts, lifecycle correctness,
   60 Hz validation, then high-refresh presentation.
9. Restore and validate Expansion Kit support only after cartridge stability.
10. Complete packaging, artifact audits, and the README benchmark gate.

## Hard evidence gates

- A successful compile is not a runtime claim.
- Simulator evidence is never physical-device evidence.
- Raw-ROM fallback may support private engine bring-up but cannot satisfy the
  consumer import gate.
- Every meaningful result goes into [`TESTING.md`](TESTING.md); blocked work
  includes a reproducible command, log, cause, attempted fix, and next step.

## Ownership strategy

Prefer upstream-compatible generic fixes, then shared libultraship changes,
then G-Diffuser `port/` changes. Keep Apple code out of the matching decomp
unless no narrower seam exists.
