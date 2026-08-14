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
  race. The owner-accepted physical iPad normalized profile is now the tablet
  default; `kPhoneSpecs` is deliberately unchanged until a later physical
  iPhone ergonomics pass. Open: true multi-touch contact stress, controller handoff,
  interruptions, haptics feel, and long sessions require physical
  iPad/iPhone acceptance. SDL finger-to-ImGui mouse translation is unchanged.
- **IOS-LIFECYCLE-01 — Simulator lifecycle is verified; physical acceptance
  remains:** UIKit resign/background first cancels every touch/latch, then the
  host loop flushes CVars and stops simulation/Metal submission while the
  dedicated audio producer blocks on its condition variable. Foreground wakes
  the producer and resumes the host loop from neutral input. Lifecycle
  observation starts before first-time setup, independently of the gameplay
  overlay, so the pre-game surface also stops drawing while inactive. An iPhone 17 Pro
  Simulator live-race Home/return cycle logged both suspend/resume edges, kept
  the process alive, held the file-backed log byte count/timestamp stable after
  settling, and visibly returned to Metal output. Physical interruptions,
  route changes, memory pressure, OS termination, save-at-interruption,
  Low Power Mode, and thermal behavior remain under IOS-HARDWARE-01.
- **IOS-AUDIO-01 — two concrete faults fixed; physical audibility remains
  unaccepted:** libultraship excludes iOS from the Apple CoreAudio default and
  uses SDL at two channels and 32000 Hz. On the attached physical iPad, owner
  comparison against an emulator found title/menu music transitions at the
  wrong times, incorrect or mistimed menu effects, countdown effects ahead of
  the visible event, race desynchronization, crackle, and buzzing. The result
  was judged essentially unplayable. Two deeper defects are now measured: both
  audio executors used Expansion Kit `HILOGAIN` opcode 14 instead of retail
  cartridge opcode 24, and the frame-coupled iOS host loop free-ran at roughly
  three times its intended VI cadence while SDL discarded about two-thirds of
  complete buffers. The ABI now follows the selected build, non-authentic
  repeated-PCM substitution is removed, and Apple mobile uses the existing
  absolute 59.94 Hz clock by default. On the same iPad Simulator, the clock A/B
  changed SDL from 2658 drops at 4200 buffers to zero drops/errors through 3300;
  every sampled task completed in LLE with zero fallback. A later parity audit
  also restored the cartridge's original `Audio_GuitarSeqStart()` boot call
  instead of starting only the SE player early in `Audio_Init()`. The rebuilt
  GP route completed 5100/5100 LLE tasks and SDL submissions with zero fallback,
  drops, or queue errors. Physical PCM telemetry then exposed a separate title-
  demo state defect: after the attract race returned, the sequence channel was
  muted while the cached BGM ID still said `BGM_TITLE`, so the title reload did
  not restart it. The selector now invalidates that cache only on title-demo
  return. A stricter Simulator run completed title -> demo -> title -> next demo
  through 6900 buffers; the zero count stayed at its startup baseline with zero
  drops/errors. A separate deterministic raw-PCM test then proved the menu track
  always became silent at 15.085 seconds before SDL/CoreAudio. The PORT-only
  cartridge font converter started its instrument-offset array at byte `+8`
  instead of the N64 header's byte `+4`, shifting every requested instrument by
  one. Title/select therefore played the next samples in the bank, producing
  wrong effects and a one-shot select sample that ended early. The single table-
  base correction removed all detected silence from 21.67-second LLE and HLE
  title-to-menu captures. The corrected signed build was then installed in
  place on the physical iPad with protected data hashes preserved. Its first
  2,400 buffers held the two-buffer startup-zero baseline with zero SDL
  drops/errors, and the owner reported that the major audio bugs now appear
  fixed. Correct audible title/menu continuity, effect/countdown sync, and
  crackle/buzz absence across the full route still require owner listening and
  remain release-blocking.
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
- **IOS-COURSE-PREVIEW-01 — corrected; physical visual acceptance pending:**
  every course-select preview used the intended `0.25` model scale, but
  `guScale()` packed the stock N64 `Mtx` layout while the PORT renderer decoded
  the lane-swapped `Matrix_ToMtx` layout. The scale consequently decoded as
  zero and the six 3D course models appeared greatly enlarged and cropped.
  PORT now builds that same 0.25 matrix through the existing host-safe matrix
  builder; console and non-PORT behavior remain unchanged. The rebuilt Mac app
  reached mode 10, held on the six-map preview, rendered the full interval, and
  exited normally. Final framing acceptance remains a physical-iPad visual gate.
- **IOS-HARDWARE-01 — physical mobile acceptance is in progress:** a signed
  Debug build has been installed and launched in place on the attached iPad.
  Pre/post-install hashes match for the local ROM, `fzerox.o2r`, save, config,
  extraction state, ImGui settings, and tablet touch preferences. The clean app
  passed strict deep signature verification, used the intended application
  identifier, and contained no retail ROM or save. This closes signing,
  installation, launch, and data-preservation checks only. Major audio behavior
  and the current tablet layout have owner acceptance; complete audible-route,
  corrected-preview, multi-touch/gameplay, lifecycle, performance, thermals,
  and long-session stability still require physical testing.

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
- **MAC-AUDIO-01 — no duplicated menu synthesis reproduced; audible route
  acceptance remains open:** cartridge synthesis and the dedicated producer
  emit nonzero PCM. A focused title/menu review found one `BGM_TITLE ->
  BGM_SELECT` transition, one consumed effect per rapid selection change, no
  surviving title note, and no LLE/HLE or dedicated/legacy duplication. The
  original same-frame confirmation pair is coalesced by channel 1 before the
  sequence script consumes it. The reproducible proof uses SDL's dummy device,
  so owner listening plus speaker/headphone delivery, volume, route changes,
  interruptions, and latency remain separate acceptance gates.
- **MAC-PERF-01 — resolved:** the ordinary render path ended the POST sub-timer
  without beginning it, so its default steady-clock epoch appeared as millions
  of milliseconds. POST now begins in the shared post-render tail and every
  sub-timer ignores an unmatched end. The focused `gdx_perf_tests` regression
  and a rebuilt Fire Field run pass; real summaries report 0.02-0.03 ms rather
  than the former 52,607,636 ms. This was telemetry-only; game behavior was
  never involved.
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
- **MAC-RACE-TEX-01 — resolved for the reproduced machine-settings route:**
  two overlapping 32x32 I4 loads previously invalidated the untouched prefix
  of the first TMEM range. Per-word replacement now preserves that prefix;
  `gdx_tmem_load_map_tests` passes and the packaged pre-race route reaches mode
  9 without `ImportTexture: null texture address`. Physical-device and broader
  course/machine texture acceptance remain under the normal hardware matrix.

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
