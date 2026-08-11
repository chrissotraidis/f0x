# Known issues

## F0X-specific

- **MAC-GFX-01 — rendered frame mirror is black after the first task:** on
  Apple Silicon macOS, the present trace reaches a real `task-render`, but
  deterministic captures before and after Start are identical all-black
  320×240 images. The graphics bridge no longer rejects the display-list root,
  so the next gate is to inspect conversion/geometry/texture diagnostics, not
  to claim a working title screen.
- **MAC-ARCHIVE-01 — extracted game archive fails the golden gate:** the
  existing desktop child-process extractor completes but emits a SHA-256 that
  differs from the source-configured golden. The runtime correctly discards it
  and uses the locally authorized raw ROM. This blocks archive-first proof and
  reinforces that mobile must use an in-process importer.
- **MAC-AUDIO-01 — hardware output unverified:** the dedicated audio thread
  runs, but no speaker/headphone or controller audio test has been performed.

## Baseline risks requiring proof

- Apple ARM64 correctness of the current `ucontext` fiber backend is unknown.
- The linker reduced one oversized common-data alignment from 0x8000 to 0x4000; this is a warning until runtime pointer/address validation proves otherwise.
- Current G-Diffuser public documentation and platform matrix are Windows/Linux
  only; Apple link and runtime assumptions must be tested against `719fd82`.
- Current mobile extraction cannot retain the desktop child-process model.
- The local development ROM is `.v64`; the pinned runtime's documented direct
  input is `.z64`, so conversion/validation behavior needs a safe, explicit
  implementation rather than an assumption.
