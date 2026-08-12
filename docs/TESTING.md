# Testing ledger

## 2026-08-11 — Gate 0 source audit

- **Environment:** Apple Silicon macOS 26.6, Xcode 26.6, CMake 4.4.0, Ninja
  1.13.2.
- **Pinned source:** recursively cloned `Zorkats/G-Diffuser` at `719fd82`.
- **Verified by source:** non-Windows currently selects `gdx_fiber_ucontext.c`;
  G-Diffuser's public README documents Windows/Linux only; the current default
  has `GDX_EXPANSION_KIT=ON`; Fast3D/libultraship is the renderer layer.
- **HarkinianPad benchmark inspected:** README and build/release/evidence
  documentation at commit `1197472`; its clear install-status table, strict
  ROM-free audit, source pinning, evidence-led claims, and separation of
  physical-device from Simulator proof are adopted as F0X documentation rules.
- **Not yet tested:** configure, compile, renderer initialization, fibers,
  game boot, controller, audio, save, Simulator, or physical hardware.

## 2026-08-11 — Gate 1 macOS ARM64 compile/link

- **Command:** `cmake -S ref/G-Diffuser -B build/macos-baseline-clean -G Ninja -DCMAKE_BUILD_TYPE=Debug -DGDX_EXPANSION_KIT=OFF -DPython3_EXECUTABLE=build/python-build-tools/bin/python && cmake --build build/macos-baseline-clean --target G-Diffuser --parallel 4`
- **Result:** passed. `build/macos-baseline-clean/port/G-Diffuser` is a Mach-O 64-bit arm64 executable; Metal, QuartzCore, CoreAudio, and AudioToolbox are linked.
- **Smallest fixes, all source-proven:** Darwin private-libc header compatibility; `_XOPEN_SOURCE=700` for the existing ucontext backend; Darwin relative `nanosleep` implementation of the existing absolute pacer; Linux-only ELF RPATH/version script; cartridge-only stubs for dormant Expansion Kit references.
- **Build-only Python environment:** ignored `build/python-build-tools` with PyYAML and Pillow; no host Python was modified.
- **Boundary at this historical checkpoint:** process launch, Metal initialization, fiber switching, ROM loading, title screen, gameplay, input, audio, and persistence had not yet been tested; later dated entries below supersede several of those unknowns.

## 2026-08-11 — Gate 2 Apple ARM64 fiber proof

- **Command:** `cmake --build build/macos-baseline-clean --target gdx_fiber_smoketest --parallel 4 && ./build/macos-baseline-clean/port/gdx_fiber_smoketest`
- **Result:** passed: three independent default-size stacks made 30,000 deterministic switches with per-fiber canaries intact.
- **Fix discovered by the regression:** `_XOPEN_SOURCE` exposed Darwin's ucontext declarations but hid `MAP_ANON`; adding `_DARWIN_C_SOURCE=1` restored anonymous stack mappings. Darwin uses the existing `pthread_self` fallback instead of the Linux-only `syscall(SYS_gettid)` path.
- **Boundary:** this is macOS host evidence only. The same proof remains required on physical ARM64 iPad before device support may be claimed.

## 2026-08-11 — Gate 3 macOS ARM64 Metal boot and scripted input

- **Command:** `env GDX_SEED_BOOT_LOGO=1 GDX_PRESENT_PATH_TRACE=1 GDX_INPUT_SCRIPT="$PWD/title_smoke.gdx" ./G-Diffuser`, from `build/macos-baseline-clean/port`.
- **Runtime reached:** native ARM64 process initialized Metal/SDL, the dedicated audio thread, host ucontext scheduler, raw 16 MiB ROM loading, game threads, and the display-list bridge. The present trace recorded `vifb-vi-scanout x241`, then `task-render x1` and `hold-recomposite x8`.
- **Input proof:** the port loaded the deterministic six-command script, issued `START`, and completed both named capture requests. This proves the input harness reaches the game polling path; it does not prove title interaction is visible.
- **Capture result:** `autotest/title_before_start.bmp` and `autotest/after_start.bmp` were both 320×240 and SHA-256 `e7a8dfc80ea86fb37199df7a61585499e40930c00d8a9763644adbb4986a7f54` (all-black after conversion/inspection). No title, menu, or race claim is warranted.
- **Visual correction:** a fresh desktop capture of the current native Metal window visibly showed the complete F-Zero X title artwork and `PUSH START`. A stale crash report and an unanswered microphone-permission prompt overlaid part of the desktop, but not the game window. Therefore the all-black BMPs are a framebuffer-readback artifact, not proof that the renderer is blank.
- **ImGui/macOS stability regression and fix:** a later long-running local-archive run aborted in Dear ImGui because SDL supplied a non-empty usable-monitor rectangle outside its full display bounds. The maintained ImGui patch now intersects usable bounds with the enclosing display (or falls back to the full display). The complete patch series was applied in a clean temporary ImGui checkout, the native build and fiber regression passed, and a bounded rerun exited normally.
- **Bounded rerun:** `GDX_LOG=1 GDX_SEED_BOOT_LOGO=1 GDX_INPUT_SCRIPT="$PWD/menu_smoke.gdx" ./G-Diffuser` loaded a locally generated, ignored `assets/extracted/generic.o2r` only to accelerate this developer test, reached game mode `7` after the scripted three-frame Start, then processed `QUIT` and returned status 0. This is macOS execution evidence only; the derived archive is not tracked, packaged, or a substitute for the required in-process importer.
- **GP race route:** the corrected `race_exact.gdx` script crossed `GAMEMODE_MAIN_MENU` (7), `GAMEMODE_COURSE_SELECT` (10), `GAMEMODE_MACHINE_SELECT` (8), and `GAMEMODE_MACHINE_SETTINGS` (9) without a `WAITMODE` timeout, then emitted `reached_gp_race` and reached `GAMEMODE_GP_RACE` (1). The native run loaded HUD and machine-global segments, initialized course/racer/camera/effects, and repeatedly converted 148–152 display lists with roughly 3,350–3,840 output commands for venue 0 before the scripted clean exit. This establishes internal macOS race execution, not a visually verified race.
- **Archive boundary:** the child Torch extractor consistently produced SHA-256 `7d60d975bdbce24ba544c6ed3cc3a06f365cfe88e6a8096b5a6d63940513181a`, not the configured golden `1b95e89586efb9d3df87e6334586d3c072aff0dba534ed1612354bfc7fa2654a`; it was correctly discarded and the runtime used raw-ROM fallback.
- **Fixes already evidenced during this loop:** macOS memory-region discovery now uses Mach VM queries (rather than Linux `/proc/self/maps`), preventing all display-list roots from being rejected; the Metal frame-uniform allocation and Prism template syntax no longer cause the earlier startup crashes.
- **Boundary at this historical checkpoint:** a visible title had not yet been captured in this particular run; later entries establish a stable packaged-app title. A visible/playable race, audible speakers, save round-trip, controller hardware, performance, and physical-device behavior remain open.

## Current next experiment

Use the current F0X Home build for owner flashing confirmation, then run a
player-controlled completed race and save/relaunch/load round trip. Keep
`scripts/macos-packaged-race.gdx` as the boot/race regression and keep the
extraction golden plus all-black internal BMP readback as separate gates.

## 2026-08-12 — Signed packaged raw-ROM GP race proof

- **Regression harness:** the input-script language now has `WAITTITLE`, which holds neutral input until title mode is accepting Start (`gGameMode == 0`, update state, attract demo inactive, and the title readiness counter at least 95). This replaces a fixed boot delay that could let attract mode consume Start. `scripts/macos-packaged-race.gdx` then gates every major transition on its game mode.
- **Build and seal:** `cmake --build build/macos-f0x-bundle --target G-Diffuser -j 6` completed. The rebuilt app and nested extractor passed `codesign --verify --deep --strict --verbose=2`.
- **Route proof:** the signed app booted the authorized local US rev0 `.z64` after rejecting the mismatched extracted archive, loaded the 28-command script, traversed game modes `0 -> 7 -> 10 -> 8 -> 9 -> 1`, emitted `packaged_gp_race_capture_interval`, and completed all commands with no `WAITTITLE` or `WAITMODE` timeout.
- **Direct visual proof:** direct inspection of the raised `F0X (Metal)` app window showed an active GP race: a track, the player's craft, rival craft, and lap / position / energy HUD were visibly rendered. This closes the former direct-window evidence gap and independently confirms the internal black BMPs are not representative of the live Metal window.
- **Visual failure retained:** the same image has large black/clipped areas through the right and bottom HUD and visibly incomplete machine surfaces. Runtime logs report missing `machine_custom_gfx` filepath resources and null TMEM texture addresses. This is race-reached proof, not a visually correct or player-controlled completed-race pass.

## 2026-08-12 — Gate 4 macOS F0X application-bundle foundation

- **Build:** `cmake -S ref/G-Diffuser -B build/macos-f0x-bundle -G Ninja -DCMAKE_BUILD_TYPE=Debug -DGDX_EXPANSION_KIT=OFF -DGDX_MACOS_BUNDLE=ON -DPython3_EXECUTABLE=build/python-build-tools/bin/python && cmake --build build/macos-f0x-bundle --target G-Diffuser --parallel 2` completed successfully.
- **Bundle identity:** `build/macos-f0x-bundle/port/F0X.app/Contents/MacOS/F0X` is a Mach-O 64-bit arm64 executable. Its Info.plist declares `CFBundleIdentifier=com.chrissotraidis.f0x`, executable and bundle name `F0X`, version `0.1.0`, and macOS minimum version 13.0. The engine archive, extraction helper, controller database, notices, and recipe files are packaged beside the executable; immutable fonts are in `Contents/Resources`.
- **Writable-data proof:** launching that `.app` reached `InitWindow` and recorded `[firstboot] data directory: /Users/chrissotraidis/Library/Application Support/F0X (working directory set)`. It created `gdiffuser.cfg.json`, `gdiffuser-run.log`, and `logs/G-Diffuser.log` there, while reading the bundled engine archive from `F0X.app/Contents/MacOS/gdiffuser.o2r`.
- **Crash report and fix:** the first bundle launch produced a native ARM64 crash report showing `ImFontAtlas::AddFontFromFileTTF` aborting from `gdx_gui.cpp`: the data/bundle split made the GUI search `Application Support` for immutable fonts. The source now resolves fonts through `LocateFileAcrossAppDirs` and bundled builds install them in `F0X.app/Contents/Resources/fonts`, where macOS `NSBundle` exposes resources. A rebuild verified the packaged font bytes match their source counterpart.
- **First-launch UI proof:** the rebuilt F0X app was launched through the local app service and exposed an accessible `G-Diffuser (Metal)` window owned by F0X. Direct screen inspection showed `G-Diffuser - First-Time Setup`, the three expected F-Zero X ROM / Expansion Kit disk / 64DD IPL rows, all marked Missing at paths under `~/Library/Application Support/F0X`, and the explicit statement that nothing is uploaded. The test window was then closed cleanly.
- **Boundary:** this remains a Debug application foundation, not a distributable, signed macOS product. No authorized game media was dropped into the setup flow, so completed import/extraction, save round trip, and playable bundled gameplay are still unproven.

## 2026-08-12 — Gate 4 macOS bundle integrity and native setup refinement

- **Failure reproduced:** Finder's “F0X may be damaged or incomplete” dialog corresponded to a real invalid seal: `codesign --verify --deep --strict` reported `code has no resources but signature indicates they must be present`. The original post-build rules copied payload after CMake's link-time bundle signature.
- **Packaging correction:** the maintained macOS bundle path now stages app data in `Contents/Resources`, the executable helper in `Contents/Helpers/gdx-extract`, and `Info.plist` explicitly in `Contents/Info.plist`. The helper is ad-hoc-signed first and the finished bundle is ad-hoc-signed last. Runtime lookup was updated for the resource archive and recipes, while user data remains under `~/Library/Application Support/F0X`.
- **Clean-build proof:** after removing only the generated `build/macos-f0x-bundle/port/F0X.app`, a new `cmake --build build/macos-f0x-bundle --target G-Diffuser -j 6` completed. `codesign --verify --deep --strict --verbose=2` passed and reported both `F0X.app` and its nested `Helpers/gdx-extract` as validated. `plutil -lint` passed; the plist contains executable `F0X`, identifier `com.chrissotraidis.f0x`, version `0.1.0`, type `APPL`, and minimum macOS `13.0`.
- **Layout proof:** `Contents/MacOS` contains only the arm64 `F0X` executable. The arm64 helper is in `Contents/Helpers`; `gdiffuser.o2r`, `gamecontrollerdb.txt`, fonts, notices, and `decomp-recipes/config.yml` are sealed in `Contents/Resources`.
- **Observed launch:** macOS launched that exact sealed `.app` into the `F0X (Metal)` window. Its visible panel is titled `F0X - First-Time Setup`, says `Welcome to F0X`, requests only `F-Zero X ROM (US rev0, .z64)`, and points at the Application Support data directory. The native AppKit picker bridge is compiled and linked against AppKit plus UniformTypeIdentifiers; it uses `NSOpenPanel` with modern `allowedContentTypes` filters rather than deprecated file-type filtering.
- **Boundary:** this is local ad-hoc signing, sufficient to prevent the incomplete-bundle error during local launch. It is not Developer ID signing, notarization, a release package, a completed import, or evidence that a physical Mac other than this host will accept the app.

## 2026-08-12 — F0X Metal drawable-order stability regression

- **Symptom and root cause:** the sealed F0X bundle intermittently flashed black. In the normal host loop, `gdx_vi_tick()` synchronously wakes the game fiber and submits its Metal graphics task before `StartDraw()`/`StartFrame()` acquired the current CAMetalLayer drawable. Metal therefore encoded game work against the prior (or absent) screen target, then the later frame setup acquired and presented a different drawable.
- **Fix:** the non-interpolated path now opens the GUI/Metal frame and drains deferred wakes immediately before `gdx_vi_tick()`. The existing interpolation path remains unchanged because it owns complete frame brackets per subframe.
- **Build and package validation:** `cmake --build build/macos-f0x-bundle --target G-Diffuser -j 6` completed successfully. The rebuilt `F0X.app` and its `gdx-extract` helper passed `codesign --verify --deep --strict --verbose=2`.
- **Live validation:** direct macOS app inspection of that exact rebuilt bundle showed the complete F-Zero X title artwork and `PUSH START`, with a second inspection 2.5 seconds after a title input still showing a stable rendered title rather than the former black strobe. The app then closed cleanly.
- **Diagnostic boundary:** a temporary persisted present-path trace showed normal startup `vifb-vi-scanout`, followed by a real task and held-frame presentation; it did not show the historical alternating task/hold signature. The trace setting was removed after this run. This is title-screen stability proof, not yet a visual GP-race or controller proof.

## 2026-08-12 — Metal strobe and race-address regression

- **Measured baseline:** one packaged raw-ROM process running the deterministic
  GP route produced 38 black frames in 60 direct window captures sampled at
  roughly 150 ms. This reproduced the owner's repeating whole-window flash.
- **Root cause and isolation:** transition snapshot readback set a live Metal
  game framebuffer to use a second command queue permanently. Later main-queue
  window composites sampled that texture without an explicit cross-queue
  dependency. Keeping the live target on the main queue changed the same dense
  sample to 0 black frames in 120 race captures. Restoring the separately tested
  SDL OpenGL-swap hypothesis did not regress the result, so that speculative
  change was removed.
- **Resize/fullscreen proof:** the current packaged build produced 0 black frames
  in 80 captures across 720x540 and 1100x820 window sizes, plus 0 in 60 captures
  after native macOS fullscreen entry. One all-black image during the scripted
  menu-to-race transition was retained as a transition/fade observation, not
  counted as a stable-race strobe.
- **Crash report reconciliation:** incident
  `DF817CB7-AF39-45B1-A2BB-CB49BBB60BA5` was reproduced during the longer soak as
  `SIGBUS` in `Hud_PortRestoreCharacterPortrait -> GdxSegmentSourceRead`. A valid
  segment-4 RDRAM physical offset collided with a PIE module low address, and the
  generic resolver selected read-only `__TEXT`. Segment setter APIs now prefer
  RDRAM for in-range physical bases. The rebuilt process passed the former crash
  point and remained alive throughout the direct race/resize/fullscreen samples.
- **Reusable route:** `scripts/macos-metal-stability.gdx` follows the packaged GP
  route and holds a live race for 18,000 VI ticks so future intermittent-present
  and race-lifetime regressions have a reproducible window.
- **Boundary:** current-build direct evidence supports the fix, but owner
  confirmation of the originally observed flashing is still required. This does
  not close the missing product-interface or player-completed-race gates.

## 2026-08-12 — F0X Home and packaged-launch regression

- **Visible product surface:** the exact sealed bundle opened on a centered,
  borderless F0X Home panel. Direct macOS inspection showed `READY TO PLAY`, the
  verified local-data statement, `PLAY F-ZERO X`, Manage Game Data, Open Data
  Folder, VSync/widescreen/fullscreen, recovery guidance, and Quit.
- **Recovery flow:** Manage Game Data reuses the existing validator/import state
  machine in-process with management-specific title and copy. An observed
  click-through into `Replace...` was fixed with a two-frame input guard. The
  management-specific surface was directly observed; the final styled-build
  click transition remains automation-limited because ImGui controls are absent
  from macOS accessibility and synthetic one-frame clicks are intermittently
  missed by the GUI-only frame pump.
- **Launch-path fix:** a relative shell launch changed cwd to Application Support
  before archive discovery and consequently missed sealed
  `Contents/Resources/gdiffuser.o2r`, producing `OTR file not found`. Discovery
  now reuses FirstBootRun's already-resolved executable directory. The same
  relative command then mounted the engine archive and booted normally.
- **Automation compatibility:** `GDX_INPUT_SCRIPT` deliberately bypasses Home.
  The rebuilt signed bundle ran `scripts/macos-packaged-race.gdx`, emitted
  `packaged_gp_race_capture_interval`, completed all 28 commands, closed the
  window normally, and returned status 0. No `WAITMODE` timeout occurred.
- **Package and patch proof:** the rebuilt app passed
  `codesign --verify --deep --strict` and plist lint. The G-Diffuser, decomp, and
  libultraship maintained patches all passed reverse-apply checks against the
  live nested checkouts.
- **Boundary:** this is a functional macOS interface foundation, not a release
  sign-off. Owner UX/flashing confirmation, broader accessibility review,
  Developer ID/notarization, and player-completed race/save persistence remain.

## 2026-08-12 — SRAM relaunch round trip

- **Route:** `scripts/macos-sram-toggle.gdx` enters F-Zero X's own Options menu
  from the cartridge-only main-menu grid, toggles the first persisted setting,
  exits back to main menu, and quits. This exercises `Save_SaveSettingsProfiles`
  and the normal host SRAM write-through path rather than a test-only write.
- **First launch:** the runtime logged `[sram] loaded 32768 bytes from
  fzerox.sav`, reached `sram_toggle_saved_and_returned`, completed all 18
  commands, and exited 0. The file remained exactly 32,768 bytes, its mtime
  advanced, and SHA-256 changed from
  `aaf4cc308fa7b257a82566ab25fe0981062e1781944381f0158279e99417ba52` to
  `a13e7eb3e6e2dae75e9bcf1707c0449b8c5dcbb161a69d19d473ef73b732ac2a`.
- **Second launch/load proof:** the identical route explicitly logged another
  32,768-byte load, completed all 18 commands, and exited 0. Its second toggle
  restored the exact original SHA-256 `aaf4cc30...`, proving the first launch's
  changed bytes were loaded and used rather than merely written to an existing
  file. Neither run logged a `WAITMODE` timeout.
- **Boundary:** this closes macOS settings-SRAM save/relaunch/load persistence.
  It does not substitute for player-controlled race completion or a new race
  record/ghost save.

## 2026-08-12 — physical-input race attempt (not completed)

- **Handoff:** `scripts/macos-race-handoff.gdx` performed menu setup only, then
  ended at `player_control_handoff` in live GP race mode. The runtime logged
  `script complete (26 commands)`, after which its normal keyboard/controller
  mappings exclusively owned input.
- **Real mapped input:** macOS Computer Use sent ordinary keyboard events to the
  focused F0X window. The default X-to-N64-A mapping accelerated the Blue Falcon
  from 0 to 211 km/h and later 438 km/h; A/D analog-stick mappings visibly
  steered and recovered the craft from a stopped rail contact. Energy, position,
  speed, world view, and minimap all changed in the live Metal frame.
- **Failed attempts retained:** attempt 1 accumulated rail damage and exploded
  before completing lap 1. Attempt 2 progressed farther with shorter visual
  sampling, then left the suspended crossover and remained off-course at 0
  km/h. The process was closed normally. These are input-path and gameplay
  diagnostics, not completed-race evidence.
- **External boundary:** this host currently reports Bluetooth off and no USB
  gamepad/controller. The available UI driver emits discrete key taps rather
  than sustained key-down/analog state, which is inadequate for honest
  three-lap acceptance. A connected physical controller or direct owner play is
  still required to close `MAC-RACE-CONTROL-01`.

## 2026-08-11 — Gate 3 cartridge PCM synthesis proof

- **Fixes:** the cartridge build (`GDX_EXPANSION_KIT=OFF`) now feeds the active ROM AI buffer into the PCM seam. Its permanent allocator returns its allocation on host ABIs, sequence-font offsets are decoded as big-endian bytes, and soundfont blobs are converted into persistent host-native objects instead of rewriting 32-bit N64 offsets as host pointers.
- **Build and unit regression:** `cmake --build build/macos-baseline-clean --target G-Diffuser gdx_pcm_capture_tests --parallel 4` passed. `gdx_pcm_capture_tests` passed all 5 cases and 28 sub-checks.
- **Dedicated-thread runtime:** from `build/macos-baseline-clean/port`, an SDL dummy-device run with `GDX_AUDIO_THREAD=1`, `GDX_PCM_CAPTURE_FRAMES=180000`, and `menu_smoke.gdx` exited 0. It captured 720,000 bytes (180,000 stereo frames); 108,416 of 360,000 signed samples were nonzero, with maximum absolute value 12,903 and RMS 1,189.649. SHA-256: `6e9444c63682bfc88334517e8f5f7423707ceb007eef7ca331e47f690a83e490`.
- **Boundary:** this proves native cartridge command processing, DMA, soundfont decoding, task synthesis, and the dedicated producer path. SDL dummy output is deliberately not speaker/headphone evidence; the normal CoreAudio setting was restored after the test.
- **Normal-output attempt:** the restored CoreAudio configuration stalled before game boot in Apple `AudioComponentInstanceNew` / `HALC_ProxyIOContext::_TellServerAboutStreamUsage`. A two-second process sample places the wait wholly inside CoreAudio device creation, so it is not evidence against the now-proven cartridge synthesis path.
- **Direct-window attempt:** `race_window_capture.gdx` reached its named GP interval and exited cleanly under SDL dummy audio, but this ad-hoc executable is not enumerated as a selectable window by the available accessibility service. No window image was therefore captured; the old black framebuffer BMPs remain unsuitable as a substitute for visual race proof.

## 2026-08-12 — deterministic archive install and ROM-absent boot

- **Determinism gauntlet:** `tools/o2r_harness/verify_determinism.py` ran the
  sealed bundle's `Contents/Helpers/gdx-extract` twice against the authorized
  US-rev0 ROM and packaged recipes. Both outputs were byte-identical at SHA-256
  `7d60d975bdbce24ba544c6ed3cc3a06f365cfe88e6a8096b5a6d63940513181a`.
  `validate_archive.py` found 3,610 records, 3,610 unique paths, version CRC
  `0x78D90EB3`, and all 33 expected families complete or absent. The generated
  expected header and family manifest were refreshed from that validated
  candidate; the earlier golden artifact was unavailable, so no unsupported
  claim is made about why it differed.
- **Install and warm boot:** the rebuilt sealed app reported `extracted and
  installed fzerox.o2r`, mounted the Application Support archive, reached
  `packaged_gp_race_capture_interval`, and exited 0. A second launch reported
  `up to date (fzerox.o2r already valid)`, never started Torch, left the
  archive mtime/size unchanged, reached the same race marker, and exited cleanly.
- **Regression exposed:** with only the original ROM temporarily renamed, the
  archive mounted and the setup row said it satisfied the ROM requirement, but
  `FirstBootRun` still entered setup. The cartridge-only raw-ROM shortcut ran
  before archive validation and depended on a setup state file that the shortcut
  never writes.
- **Fix and negative-ROM proof:** cartridge-only first boot now validates and
  accepts `fzerox.o2r` before trying the raw-ROM fallback. With the ROM again
  temporarily absent, logs explicitly reported archive-only first boot, no ROM
  image, validated archive fallback, `packaged_gp_race_capture_interval`, all 28
  script commands, and normal window shutdown. A shell trap restored the ROM and
  removed the temporary name. The rebuilt app and nested helper passed strict
  ad-hoc signature verification; its plist passed lint.
- **Boundary:** this proves deterministic desktop extraction, atomic install,
  warm reuse, and archive-only packaged gameplay. It does not yet prove the
  complete first-time visible import/progress experience or the required
  in-process iOS/iPadOS importer.

## 2026-08-12 — visible first-run import and same-process hot mount

- **First-run routing correction:** a cartridge-only macOS bundle with a valid
  ROM but no archive previously returned through the raw-ROM shortcut before a
  window existed. The bundle now defers that state to F0X First-Time Setup;
  portable/development cartridge builds retain their existing raw-ROM shortcut.
- **Product copy and input:** the setup surface says it will build verified local
  game data, future launches will be faster, and the original ROM becomes
  optional. Setup and Home now enable standard ImGui keyboard navigation with
  default focus on Browse/Build/Play. Dear ImGui controls still appear as one
  macOS accessibility window rather than individual native controls.
- **Direct visual proof:** the sealed app visibly rendered the verified-ROM
  consent screen and then `Extracting game assets...`, a determinate `0 / 3610`
  progress bar, and live scrollback containing the Torch game/CRC/version/
  country/hash/recipe lines. The window remained stable and responsive during
  extraction.
- **End-to-end regression:** when `GDX_INPUT_SCRIPT` is present, setup renders at
  least one frame and then confirms only already-verified inputs. This narrow
  regression seam uses the same async extraction, validation, progress state,
  and hot-mount code as an ordinary click; normal launches still require user
  confirmation. With the installed archive temporarily held aside, logs recorded
  first-run setup, async US/rev0 extraction, 3,610 entries and verified SHA-256,
  same-process hot mount, `packaged_gp_race_capture_interval`, all 28 commands,
  and normal shutdown. A guard restored the original archive; disposable outputs
  were moved to Trash.
- **Package proof:** the rebuilt app and nested helper passed strict ad-hoc
  signature verification and plist lint.
- **Boundary:** desktop UX and child-process import are now verified. The mobile
  gate still requires Torch/extraction to run in process, without `fork`/`exec`.

## 2026-08-12 — in-process Torch extraction core

- **API:** Torch static-library mode now exposes `GdxRunInProcessO2R`. It accepts
  a ROM byte buffer, recipe directory, unique destination, version stamp, and an
  optional atomic progress counter. It calls the same `Companion` F-Zero factory
  registration, recipe walk, and O2R writer as the CLI; no extractor logic was
  duplicated. Invalid inputs and exceptions return an actionable error, and an
  existing `generic.o2r` is never overwritten.
- **Build:** a focused Release harness built with `USE_STANDALONE=OFF`,
  `GDX_DETERMINISTIC=ON`, F-Zero plus NAudio enabled, and unrelated game
  factories disabled.
- **Golden proof:** the harness read the authorized ROM into memory and wrote a
  3,610-record archive at SHA-256
  `7d60d975bdbce24ba544c6ed3cc3a06f365cfe88e6a8096b5a6d63940513181a`.
  `validate_archive.py` passed record count, unique paths, golden SHA, US-rev0
  version CRC, and all 33 complete-or-absent families.
- **Same-process proof:** two sequential calls in one harness process both
  completed, processed 31 recipe nodes, produced byte-identical golden archives,
  and demonstrated that Torch's singleton/cache cleanup survives reimport.
  A separate call against a destination containing `generic.o2r` returned 1
  with `destination already contains generic.o2r` and left it untouched.
- **Boundary:** this proves the callable extraction core on macOS. The F0X
  runtime does not yet link it, the port layer still owns validation/atomic
  activation, and iOS/iPadOS compilation and device execution remain unproven.

## 2026-08-12 — in-process Torch integrated into F0X

- **Build graph:** `GDX_INPROCESS_TORCH=ON` adds Torch as a static subdirectory,
  enables only F-Zero/NAudio factories, and reuses the parent build's YAML,
  spdlog, and tinyxml targets. The combined native arm64 F0X executable linked;
  `nm` contains `GdxRunInProcessO2R`. The sealed bundle and nested fallback
  helper passed strict ad-hoc signature verification and plist lint.
- **Runtime selection:** with the installed archive held aside, the app logged
  `backend: in-process Torch (ROM bytes, no fork/exec)`. The callable API read
  the verified ROM bytes, processed the existing recipes on the setup worker,
  and returned `generic.o2r` into the port's unique staging directory. The UI
  uses an indeterminate recipe-processing stage because Torch reports 31 YAML
  recipe nodes, not the final 3,610 ZIP records; validation remains a separate
  stage instead of presenting a false percentage.
- **End-to-end result:** the unchanged port gates counted 3,610 entries, verified
  SHA-256 `7d60d975bdbce24ba544c6ed3cc3a06f365cfe88e6a8096b5a6d63940513181a`,
  atomically installed and hot-mounted the archive, reached
  `packaged_gp_race_capture_interval`, completed all 28 commands, and shut down
  normally. The guard restored the user's prior archive and the test duplicate
  was moved to Trash.
- **Default regression:** the ordinary `GDX_INPROCESS_TORCH=OFF` bundle rebuilt,
  sealed, and passed plist lint after the integration changes. Its child-process
  backend remains the desktop default/fallback.
- **Boundary:** macOS linkage and execution are verified. No iOS/iPadOS target,
  Simulator compile, signing, or device run is claimed yet.
