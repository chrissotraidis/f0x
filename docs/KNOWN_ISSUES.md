# Known issues

## F0X-specific

- **MAC-CAPTURE-01 — framebuffer BMP readback is black while the title is visible:**
  on Apple Silicon macOS, deterministic 320×240 BMP captures are identical
  black frames even though a fresh desktop capture visibly shows the rendered
  F-Zero X title screen. The readback path cannot be used as gameplay proof
  until it is fixed or independently cross-checked.
- **MAC-ARCHIVE-01 — extracted game archive fails the golden gate:** the
  existing desktop child-process extractor completes but emits a SHA-256 that
  differs from the source-configured golden. The runtime correctly discards it
  and uses the locally authorized raw ROM. A locally generated, ignored archive
  can accelerate developer-only macOS runs, but it is not a production path.
  This blocks archive-first proof and reinforces that mobile must use an
  in-process importer.
- **MAC-AUDIO-01 — hardware output unverified:** the dedicated audio thread
  runs, but no speaker/headphone or controller audio test has been performed.
- **MAC-RACE-TEX-01 — pre-race null-texture warnings require visual follow-up:**
  the GP route emitted one suppressed `ImportTexture` warning for tiles 5 and
  6 while leaving machine settings, before GP-race initialization. The route
  completed and rendered race display lists, but no direct race image is
  available yet to judge whether those missing texture addresses have visible
  impact.

## Baseline risks requiring proof

- Apple ARM64 correctness of the current `ucontext` fiber backend is unknown.
- The linker reduced one oversized common-data alignment from 0x8000 to 0x4000; this is a warning until runtime pointer/address validation proves otherwise.
- Current G-Diffuser public documentation and platform matrix are Windows/Linux
  only; Apple link and runtime assumptions must be tested against `719fd82`.
- Current mobile extraction cannot retain the desktop child-process model.
- The local development ROM is `.v64`; the pinned runtime's documented direct
  input is `.z64`, so conversion/validation behavior needs a safe, explicit
  implementation rather than an assumption.
