# Known issues

## F0X-specific

- **MAC-PRESENT-02 — Metal strobe fix awaits owner confirmation:** transition
  capture moved a live game framebuffer permanently to Metal's readback queue,
  while the main queue sampled it without a cross-queue dependency. The measured
  38/60 black-frame baseline became 0/120 in race, 0/80 across resize, and 0/60
  in fullscreen after keeping that target on the main queue. Keep this issue
  open until the owner confirms the originally observed flashing is gone.
- **MAC-RACE-CRASH-01 — physical segment-base collision fixed, regression retained:**
  a valid segment-4 RDRAM offset shared low address bits with the PIE executable;
  the generic resolver chose read-only `__TEXT`, and HUD portrait DMA crashed in
  `GdxSegmentSourceRead`. Segment setters now treat in-range physical bases as
  RDRAM. The rebuilt app survived the former crash point, but the long race soak
  remains a required regression.
- **MAC-UI-01 — F0X Home foundation exists; release polish remains:** normal
  packaged launches now open on a branded F0X Home surface with verified-data
  state, Play, Manage Game Data, Open Data Folder, VSync/widescreen/fullscreen,
  recovery guidance, and Quit. Management returns through the validated import
  state machine without launching a second app. Broader settings, release-grade
  accessibility, signing/notarization, and owner UX review remain open.

- **MAC-CAPTURE-01 — framebuffer BMP readback is black while the title is visible:**
  on Apple Silicon macOS, deterministic 320×240 BMP captures are identical
  black frames even though a fresh desktop capture visibly shows the rendered
  F-Zero X title screen. The readback path cannot be used as gameplay proof
  until it is fixed or independently cross-checked.
- **MAC-ARCHIVE-01 — desktop archive fixed; in-process/mobile importer remains:**
  the bundled extractor and recipes reproducibly emit the same 3,610-entry
  archive (`7d60d975...`) across two independent runs. The refreshed generated
  golden passes the entry-count, version-CRC, family-completeness, install,
  warm-boot, and ROM-absent race gates. Cartridge-only first boot now accepts a
  validated installed archive even when no legacy setup marker exists. The
  first-run screen now owns consent, determinate progress, logs, retry/fallback,
  hot-mount, and same-process game continuation; keyboard navigation supplies
  default focus even though ImGui widgets are not individually exposed to macOS
  accessibility. F0X now has a verified opt-in static/in-memory backend and the
  default desktop child backend remains available. The combined static graph has
  not yet been compiled or executed on iOS/iPadOS.
- **MAC-AUDIO-01 — physical CoreAudio route remains unverified:** cartridge
  synthesis and the dedicated producer path now emit nonzero captured PCM.
  The reproducible proof uses SDL's dummy device so it does not establish
  speaker/headphone delivery, volume, route changes, interruptions, or
  latency on a physical output device. A subsequent normal-CoreAudio launch
  stalled inside Apple audio-device creation before F0X booted; this is an
  external host-service boundary, not a synthesis failure.
- **MAC-RACE-CONTROL-01 — player-completed race remains unverified:** the
  deterministic harness reaches and holds a live GP race, and the real SRAM
  settings path survives relaunch. Real mapped keyboard input has accelerated,
  steered, damaged, and recovered the craft, but two tap-driven hands-on attempts
  did not finish. This host currently has no connected controller and Bluetooth
  is off. Do not promote scripted race entry, partial keyboard driving, or file
  presence into finish/results acceptance.
- **MAC-RACE-TEX-01 — residual null TMEM warnings need follow-up:** raw-ROM
  machine textures now render after filepath emission was gated on actual
  mounted-resource existence, and narrow windows fall back to centered 4:3.
  The route still logs null texture addresses for TMEM tiles 5 and 6 during
  pre-race settings; retain this as a visual regression while fixing flashing.

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
