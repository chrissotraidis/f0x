# F0X implementation plan

## Scope and invariant

F0X keeps the existing path: F-Zero X matching decompilation → G-Diffuser →
libultraship/Fast3D → Metal. It will not become a new engine or an emulator
frontend. Public source and packages remain ROM-free.

## Completed foundation

The pinned baseline, native/fiber/Metal app, deterministic extraction,
in-process Torch, iPad Simulator import/race, archive-only boot, SRAM relaunch,
touch/editor, diagnostics, audio backend, graphics-cache repair, Simulator
lifecycle, public README/icon, and deterministic unsigned IPA workflow are
evidenced in [`STATUS.md`](STATUS.md) and [`TESTING.md`](TESTING.md). Do not
reopen them without contradictory evidence.

## Ordered remaining work

1. Retain the macOS flashing issue as owner-confirmation-open. Re-run the dense
   current-bundle route after renderer/input changes and obtain human confirmation
   that the exact corrected `F0X.app` no longer flashes.
2. Close human gameplay on macOS: complete a real race with mapped input, exercise
   steering/accelerator/brake/boost/Z/R attacks/camera/pause, then run repeated
   races and representative courses. Existing scripted race entry and SRAM proof
   are supporting evidence, not this acceptance.
3. On a Mac with signing and a connected iPad, sign/install the existing device
   build and prove the physical controller-first engine gate: fiber regression,
   Files import, extraction, complete race, audio, lifecycle, save/reload, and
   stable Metal rendering. This environment is currently externally blocked.
4. Run physical touch acceptance on iPad and iPhone: true simultaneous
   steering+accelerator+brake/boost/attack, editor ergonomics, controller handoff,
   safe areas, haptics, lifecycle clearing, audio routes, memory, thermals, and
   long sessions. Simulator cannot close these checks.
5. Touch/editor, diagnostics, public README/icon, Simulator lifecycle, and the unsigned
   re-signable package workflow are complete. Retain their regressions.
6. On representative physical devices/courses, prove correct 60 Hz simulation,
   timer, physics, AI, input, audio sync, and
   presentation. Measure named devices/tracks and document evidence.
7. Only after 60 Hz acceptance, implement Match Display/120 Hz using the existing
   interpolation architecture and prove simulation speed remains unchanged.
8. On signing-capable hardware, finish release signing/notarization decisions,
   signed-package installation, and update/container behavior. The deterministic
   unsigned/re-signable IPA, ROM/signing scans, hashes, and clean patch replay
   are complete.
9. Keep the HarkinianPad-quality README current as hardware claims close; do
    not add private game captures or unsupported distribution links.
10. After cartridge base completion, restore Expansion Kit behind
    `GDX_EXPANSION_KIT=ON` and independently validate its import, IPL, writable
    media, editors, persistence, lifecycle, and packaging boundary.

## Evidence rules

- Compilation is not runtime proof.
- Simulator is not physical-device proof.
- A scripted route is not player acceptance.
- A generated file is not proof that the game loaded and used it.
- Every meaningful result receives a dated `TESTING.md` entry and, when useful,
  a compact tracked artifact under `docs/evidence/<gate>/`.
- Each coherent unit updates `STATUS`, `KNOWN_ISSUES`, the relevant builder doc,
  and the public README when a public fact changes, then receives a focused commit.

The exact continuation protocol is in [`NEXT_BUILDER.md`](NEXT_BUILDER.md) and
the autonomous prompt is in [`BUILDER_GOAL_LOOP.md`](BUILDER_GOAL_LOOP.md).
