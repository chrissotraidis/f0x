# Known issues

## F0X-specific

- **IOS-TOUCH-01 — gameplay touch controls are implemented; physical
  acceptance remains open:** the UIKit overlay now writes direct atomic N64
  pad state merged at the port-1 seam, with hand-authored phone/tablet
  defaults, settings CVars, auto-hide with physical controller, opacity,
  haptics, permanent menu access, menu-state hiding, a layout editor with
  versioned `NSUserDefaults` profiles, and lifecycle cancel paths. The
  Simulator verified the complete control set and a touch-driven GP flow to a
  live race; `gdx_touch_merge_tests` passes 87 sub-checks. The Settings ->
  Controls -> Touch Controls page renders live with every widget; the layout
  editor opens and saves; a non-default tablet profile survives relaunch and
  drives the overlay; hold-to-cancel, the Z hold-to-latch (with AX "Locked"
  and blue fill), and cancel-clears-latch are captured live. The phone
  defaults were re-verified on the current build via the iPhone 17 Pro
  Simulator (2026-08-13): phone table selected, every control at its
  normalized default center with edge pills safe-clamped, ••• in the phone
  top-center slot clear of the Dynamic Island, overlay attached over a live
  race. Open: true multi-touch contact stress, controller handoff,
  interruptions, haptics feel, and long sessions require physical
  iPad/iPhone acceptance. SDL finger-to-ImGui mouse translation is unchanged.
- **IOS-LIFECYCLE-01 — mobile lifecycle is partially verified:** a Simulator
  Home background + relaunch re-attached the touch overlay neutrally and
  cancel paths clear input, but full background/foreground simulation/audio/
  presentation suspension, config/save flush, interruption, memory pressure,
  and resume still need runtime proof.
- **IOS-AUDIO-01 — launch backend resolved in Simulator; physical audible
  route remains under IOS-HARDWARE-01:** libultraship now excludes iOS from
  the Apple CoreAudio default and falls through to SDL, matching the pinned
  HarkinianPad `libultraship-ios.patch`. A rebuilt iPhone 17 Pro Simulator
  launch logged `SDL Audio initialized: 2 channels, 32000 Hz`, the dedicated
  producer active, and live BGM synthesis. This closes the silent Null-player
  root cause without an F0X-only override. Speaker/headphone audibility,
  route changes, interruptions, and physical hardware remain unverified.
- **IOS-GFX-CRASH-01 — resolved in Simulator; physical long-session proof
  remains under IOS-HARDWARE-01:** the failing design kept converted display-
  list dialect metadata in a second pointer-keyed `unordered_map`, independent
  of the cache entry that owns, rebuilds, and evicts the converted vector. The
  iPhone 17 Pro Simulator crash occurred in that side map's `find()` at address
  `0x1e0`. Dialect now lives in the same `GfxWideCache::Entry`; each queued list
  carries the cache result by value, and the side map is gone. A focused test
  covers stamp rebuilds, 513-entry stale eviction, and post-eviction rebuild.
  The rebuilt app completed a 5:16 scripted race/retire/next-course soak under
  `MallocGuardEdges`, `MallocPreScribble`, and `MallocScribble`, more than twice
  the old ~2:20 failure window, with no crash report. `MallocStackLogging` is
  not valid for this runtime: its unwinder independently faults while walking
  the custom `ucontext` fiber stack, before the target display-list path.
- **IOS-TOUCH-VISUAL-01 — resolved in Simulator; physical acceptance remains
  under IOS-HARDWARE-01:** live iPad and iPhone 17 Pro acceptance on
  2026-08-13 replaced the long/colliding action labels with compact N64 glyphs
  plus semantic accessibility labels, separated phone rails and D-pad,
  restored the round stick knob, removed the duplicate Settings reset row,
  and rebuilt the Input Editor as a safe-viewport responsive surface. iPad
  uses two primary columns; iPhone collapses to one; mapping rows align and
  all secondary stick/rumble/gyro/LED sections remain reachable. Gameplay
  controls and ••• are absent while the editor/menu owns the screen, then
  restore neutrally after close. Both maintained patches clean-replay.
- **IOS-HARDWARE-01 — physical mobile acceptance externally blocked here:** the
  current Mac reports no connected device and zero valid signing identities.
  Simulator and unsigned device-SDK builds do not establish physical rendering,
  controller, touch, audible audio, saves, lifecycle, performance, or thermals.

- **MAC-PRESENT-02 — stale duplicate bundle likely explained the continuing strobe:**
  the renderer fixes remain supported by the original 0/120 race, 0/80 resize,
  and 0/60 fullscreen samples plus a new 462-frame race video with no black
  frame or brightness jump. The owner's continuing report aligned with the
  build directory containing an obsolete `G-Diffuser.app` beside
  current `F0X.app`; both declared `com.chrissotraidis.f0x`, so Launch Services
  could reopen the pre-Home, pre-strobe-fix binary. That is a concrete mechanism,
  not proof of the exact path the owner launched. Packaged builds now remove
  only that legacy product, and Finder's registered current app passed a fresh
  544-frame Home soak. Keep owner confirmation open after this corrected launch.
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
- **MAC-ARCHIVE-01 — desktop and Simulator importer fixed; physical import remains:**
  the bundled extractor and recipes reproducibly emit the same 3,610-entry
  archive (`7d60d975...`) across two independent runs. The refreshed generated
  golden passes the entry-count, version-CRC, family-completeness, install,
  warm-boot, and ROM-absent race gates. Cartridge-only first boot now accepts a
  validated installed archive even when no legacy setup marker exists. The
  first-run screen now owns consent, determinate progress, logs, retry/fallback,
  hot-mount, and same-process game continuation; keyboard navigation supplies
  default focus even though ImGui widgets are not individually exposed to macOS
  accessibility. F0X now has a verified opt-in static/in-memory backend and the
  default desktop child backend remains available. The combined static graph is
  now compiled and executed in the iPad Simulator. One uninterrupted Files
  picker-to-race process is verified; physical iPad extraction/gameplay and
  invalid/cancel/storage-pressure failure paths remain unverified.
- **MAC-AUDIO-01 — physical CoreAudio route remains unverified:** cartridge
  synthesis and the dedicated producer path now emit nonzero captured PCM.
  The reproducible proof uses SDL's dummy device so it does not establish
  speaker/headphone delivery, volume, route changes, interruptions, or
  latency on a physical output device. A subsequent normal-CoreAudio launch
  stalled inside Apple audio-device creation before F0X booted; this is an
  external host-service boundary, not a synthesis failure.
- **MAC-PERF-01 — perf summary `post=` sub-mean overflows in early windows:**
  with `GDX_PERF=1`, the summary's `post` field reports millions of ms in
  startup/menu windows (accumulator/normalization issue in the perf
  sub-timers). The race-window sub-breakdowns are sane and the frame-time
  p50/p95/p99/spike and audio-tick figures are unaffected. Telemetry-only;
  no game behavior is involved.
- **MAC-RACE-CONTROL-01 — player-completed race is blocked on this host (full
  report in [`docs/blockers/MAC-RACE-CONTROL-01.md`](blockers/MAC-RACE-CONTROL-01.md)):**
  the deterministic harness reaches and holds a live GP race, real mapped
  keyboard input reaches the game (763 km/h proved), and the SRAM settings
  path survives relaunch, but no available input path can complete a race.
  Two tap-driven attempts, four System Events driver variants, and two
  internal-harness wall-hug probes all ended in RETIRE or an off-course craft.
  The probes are decisive: sustained A + full-left wall-rides Mute City,
  drains energy, and the HUD shows RETIRE at TIME 00'22"05 with LAP 1/3; the
  game then advances mode 1 -> 15 (next course) -> 18 (next machine settings).
  Decompiled logic confirms the mechanism: `Racer_RetireRacer` sets
  `D_800F80C4 = -1` in GP, and at race end `Racer_DecreaseLife` applies the
  life penalty before `MENU_CHANGE_NEXT_COURSE`. That mode sequence is
  retirement continuation, not a finish. This host has no connected controller
  and Bluetooth is off. Smallest resume action: owner/human play with the
  working keyboard mapping or any USB/Bluetooth controller, or a track-aware
  input test bed. Do not promote scripted race entry, partial keyboard
  driving, or file presence into finish/results acceptance.
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
- Current iOS extraction correctly uses in-process Torch; physical-device memory,
  cancellation, interruption, and storage-pressure behavior remain open.
- The packaged cartridge build has validated and booted an authorized local US
  rev0 `.z64`; byte-swapped `.v64` import is not yet a product-supported claim.
