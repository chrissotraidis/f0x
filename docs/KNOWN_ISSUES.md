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
- **MAC-AUDIO-01 — physical CoreAudio route remains unverified:** cartridge
  synthesis and the dedicated producer path now emit nonzero captured PCM.
  The reproducible proof uses SDL's dummy device so it does not establish
  speaker/headphone delivery, volume, route changes, interruptions, or
  latency on a physical output device. A subsequent normal-CoreAudio launch
  stalled inside Apple audio-device creation before F0X booted; this is an
  external host-service boundary, not a synthesis failure.
- **MAC-RACE-TEX-01 — pre-race null-texture warnings require visual follow-up:**
  the GP route emitted one suppressed `ImportTexture` warning for tiles 5 and
  6 while leaving machine settings, before GP-race initialization. The route
  completed and rendered race display lists, but no direct race image is
  available yet to judge whether those missing texture addresses have visible
  impact.

## Remaining platform risks

- The current `ucontext` fiber backend passed 30,000 deterministic switches on
  Apple Silicon macOS, but the equivalent proof remains required on physical
  ARM64 iPad hardware.
- The linker reduced one oversized common-data alignment from 0x8000 to 0x4000; this is a warning until runtime pointer/address validation proves otherwise.
- Upstream G-Diffuser public documentation and its platform matrix remain
  Windows/Linux-oriented; F0X's Apple behavior is carried by the maintained
  patch series and must remain regression-tested against pin `719fd82`.
- Current mobile extraction cannot retain the desktop child-process model.
- The packaged cartridge build has validated and booted an authorized local US
  rev0 `.z64`; byte-swapped `.v64` import is not yet a product-supported claim.
