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

Have the owner confirm the corrected Finder launch after legacy-bundle removal,
then run a player-controlled completed race. The save/relaunch/load round trip
is already verified. Keep
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
  Developer ID/notarization and a player-completed race remain.

## 2026-08-12 — Duplicate-bundle launch and dense Metal-video regression

- **Contradiction audited:** the owner continued to report regular flashing and
  an absent interface, while the exact current `F0X.app` visibly showed Home and
  passed the earlier direct-image samples. The build directory contained both
  current `F0X.app` and an older `G-Diffuser.app`. Their executables had different
  SHA-256 values, the legacy binary did not contain `F0X Home`, and both plists
  declared `com.chrissotraidis.f0x`. Spotlight had indexed both products.
- **Smallest durable fix:** the macOS packaged target now depends on a cleanup
  target that removes only `${CMAKE_CURRENT_BINARY_DIR}/G-Diffuser.app`. A full
  packaged rebuild completed, left only `F0X.app`, and passed strict deep
  ad-hoc signature validation plus plist lint. The maintained G-Diffuser patch
  passed its reverse-apply check.
- **Normal-launch proof:** Launch Services was refreshed to current `F0X.app`,
  and `/usr/bin/open` launched the expected `F0X (Metal)` Home surface from that
  exact bundle. Spotlight then returned only the current app for the bundle ID.
- **Dense presentation proof:** `scripts/analyze-metal-capture.swift` decodes a
  window video with AVFoundation, samples the inner viewport, and fails on a
  mean-luma near-black frame or a large adjacent-frame brightness change. A live
  scripted race produced 462 frames over 8.000 seconds (luma 97.30–98.05,
  maximum adjacent difference 1.35); the Finder-launched Home produced 544
  frames over 9.500 seconds (luma 8.20–8.22, maximum adjacent difference 0.13).
  Both had zero near-black frames and zero brightness jumps.
- **Boundary:** the stale duplicate provides a concrete mechanism that can
  explain the owner seeing the unfixed, interface-free binary while current-build
  captures were stable; it does not prove which path was launched. Owner
  confirmation after this corrected launch is still required.

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

## 2026-08-12 — genuine iPad Simulator build and first-run interface

- **Build identity:** F0X was configured through the pinned iOS toolchain with
  `PLATFORM=SIMULATORARM64`, deployment target 16.0, cartridge-only mode, and
  `GDX_INPROCESS_TORCH=ON`. Xcode produced a native arm64 Simulator application
  (`LC_BUILD_VERSION` platform 7) with bundle ID `com.chrissotraidis.f0x`; the
  integrated F0X/Torch graph built without a child extractor.
- **Compile closure:** iOS-specific fixes cover duplicate Xcode object basenames,
  ucontext feature macros, unavailable Annex K probes, Mach VM enumeration,
  desktop Discord/folder/fullscreen/CoreAudio leakage, and Homebrew zstd
  cross-link contamination. The shared macOS `F0X.app` rebuilt afterward and
  passed strict deep signature verification plus plist lint.
- **Crash reproduction and fix:** PID 8811 aborted at
  `ImFontAtlas::AddFontFromFileTTF` because the fonts were not in the actual app
  bundle and the iOS bundle lookup returned Documents. The rebuilt package
  contains both TTFs under `F0X.app/fonts`, distinguishes immutable bundle
  resources from writable Documents, checks each font before asking ImGui to
  load it, and supplies a default-font fallback. Subsequent launches logged
  `ImGui init complete` and stayed alive.
- **Visible product proof:** on the one booted iPad Pro 11-inch (M5) Simulator,
  the live Metal surface renders a stable landscape F0X First-Time Setup panel.
  The panel uses larger mobile spacing and controls, shows a canonical path
  under the app's Documents sandbox, and exposes `Choose ROM...` rather than an
  impossible iOS drag-and-drop instruction. Activating it visibly presented the
  native Files document picker.
- **Report reconciliation:** the later supplied 611-line crash report is the
  same 08:24 PID 8811 font incident and contains no second failure signature;
  it is superseded by the later live process and package evidence above.
- **Boundary:** Simulator compilation, launch, landscape setup rendering, and
  Files-picker presentation are verified. No authorized ROM was selected in the
  Simulator, so in-process iOS extraction, archive activation, title/gameplay,
  touch gameplay, lifecycle, audio, physical signing, and physical iPad are not
  yet claimed. The owner also continues to report regular visible flashing on
  the macOS game despite automated black-frame soaks, so that gate remains open.

## 2026-08-12 — iPad Simulator in-process extraction and GP race

- **Authorized local input:** an ignored US-rev0 ROM was copied only into the
  installed Simulator app's Documents sandbox. It was never added to the source
  tree, build product, patch ledger, or Git history.
- **In-process extraction:** the genuine arm64 Simulator app logged `backend:
  in-process Torch (ROM bytes, no fork/exec)`, installed `fzerox.o2r [us/rev0]`
  with 3,610 entries and verified SHA-256, and mounted it from Documents. The
  archive matched the established golden
  `7d60d975bdbce24ba544c6ed3cc3a06f365cfe88e6a8096b5a6d63940513181a`.
- **Game route and direct visual proof:** the unchanged 28-command packaged GP
  script reached `packaged_gp_race_capture_interval`. Direct inspection of the
  live Simulator showed the Blue Falcon on the starting grid with the race HUD
  and 30-racer field on the landscape Metal surface. The script then requested
  quit, completed all commands, and the F0X window closed normally.
- **Archive-only negative run:** the ROM was temporarily renamed inside the
  sandbox for a second launch. F0X explicitly logged `booting archive-only`,
  `asset extraction: up to date`, and `no ROM image found`; it again reached the
  packaged GP race marker, completed all 28 commands, and closed normally. The
  app process and console wrapper were stopped and the single local ROM was
  restored to its original sandbox path.
- **Boundary:** this proves iOS in-process extraction, validated atomic archive
  activation, archive-only reuse, game-mode traversal, and visible Simulator
  race output. Native Files-picker presentation was proven separately. Because
  the test injected the authorized ROM directly into Documents, this is not yet
  one uninterrupted manual picker-selection-to-race proof. It also is not touch,
  lifecycle, audible-output, signing, or physical-iPad evidence. The owner's
  separate macOS flashing report remains open.

## 2026-08-12 — unsigned iPhoneOS compile and package audit

- **Device configuration:** a separate Xcode tree used the pinned iOS toolchain
  with `PLATFORM=OS64`, arm64, iOS 16.0 deployment, cartridge-only mode, and
  in-process Torch. It reused the already-fetched dependency sources without
  modifying the proven Simulator build.
- **Build result:** `xcodebuild` completed with `CODE_SIGNING_ALLOWED=NO` and
  `** BUILD SUCCEEDED **`. The first packaging attempt exposed that the selected
  host Python lacked PyYAML; reconfiguration selected the existing ignored
  `build/python-build-tools` interpreter with PyYAML 6.0.3. The incremental retry
  generated the recipe tables, linked F0X, generated its dSYM, and passed Xcode's
  shallow bundle validation.
- **Binary and plist:** `F0X.app/F0X` is a 64-bit arm64 Mach-O whose
  `LC_BUILD_VERSION` is platform `IOS`, minimum 16.0, SDK 26.5. `Info.plist`
  passed `plutil`, identifies `com.chrissotraidis.f0x`, supports device families
  1 and 2, requires arm64, and declares only landscape orientations.
- **Payload audit:** the unsigned app is 33 MiB with 73 files. It contains the
  engine-only `gdiffuser.o2r`, two fonts and their licenses, US-rev0 extraction
  recipes, controller mappings, notices, and the F0X executable. A targeted scan
  found no `.z64`, `.n64`, `.v64`, `.ndd`, `.sav`, or generated `fzerox.o2r`.
- **Physical boundary:** `devicectl` reported no connected devices and the
  keychain reported zero valid code-signing identities. The app is intentionally
  unsigned. This is device-SDK compile/package evidence only; signing,
  installation, launch, controller gameplay, lifecycle, audible output, and
  physical iPad acceptance remain untested.

## 2026-08-12 — uninterrupted native Files picker to visible race

- **Clean product state:** the installed Simulator app's generated Documents
  data was cleared while an authorized ROM was retained only in the Simulator's
  Files-provider storage. The app was installed and launched once on the single
  booted iPad Pro 11-inch (M5) Simulator; the run used one F0X PID.
- **Actual picker interaction:** the visible `Choose ROM...` action presented
  Apple's Files picker. `On My iPad > F0X Import Test` was opened and the
  authorized US-rev0 `.z64` was selected. F0X copied it into its new sandbox as
  `baserom.us.rev0.z64` and verified SHA-1
  `5f658e88ffa9de23cba6986a8fd3d3a90d7b4340`.
- **Same-process extraction:** choosing `Build game data and continue` used
  `in-process Torch (ROM bytes, no fork/exec)`, validated and atomically installed
  the 3,610-entry archive at the established SHA-256, hot-mounted it, and
  continued without relaunching.
- **Direct visible result:** the same process visibly rendered a live landscape
  GP race on the Simulator Metal surface. The captured frame shows the player's
  craft, track, field, position/lap/speed/energy HUD, and minimap. The process was
  then explicitly terminated and the same PID exited.
- **Boundary:** this closes the prior uninterrupted picker-selection-to-race gap
  for Simulator. It does not prove physical Files-provider behavior, device
  extraction performance, touch gameplay, lifecycle, audible output, signing,
  or physical iPad acceptance. The private screenshot/log remain ignored build
  artifacts; the compact tracked summary is
  `docs/evidence/ios-picker-to-race/2026-08-12.txt`.

## 2026-08-12 — touch implementation audit

- **Audit result (historical, superseded below):** at this checkpoint no
  gameplay touch implementation existed in current F0X.
  SDL finger events translate only to ImGui mouse interaction. No
  `gdx_touch_controls` bridge, UIKit gameplay overlay, racing controls, touch
  CVars/settings, editor, phone/tablet profiles, lifecycle cancel, or controller
  handoff was compiled. The later "touch system implemented and
  Simulator-verified" entry and the 2026-08-12 live-captures entry supersede
  this audit.
- **Reference boundary:** HarkinianPad `1197472` contains proven UIKit overlay,
  editor, profile, menu-lifecycle, and opacity patterns, but its patches target
  Shipwright and synthesize keyboard inputs. They have not been applied to F0X
  and must be adapted to F0X's direct `input_bridge.c` N64 pad seam.
- **Source-proven mapping:** current F-Zero X code uses A for acceleration, B
  for boost, C-down for brake, Z/R for slide/attack, C-right for camera change,
  and C-up for look-back. This mapping is now fixed in
  `TOUCH_CONTROLS_IMPLEMENTATION.md` for the next builder.
- **Boundary:** this is a read-only implementation audit and documentation
  checkpoint, not a touch build or runtime pass.

## 2026-08-12 — next-builder documentation checkpoint

- **Scope reconciliation:** README, platform/build/data/performance/architecture
  docs, the status ledger, known issues, and the historical handoff were checked
  against current source, commits, tracked evidence, the latest private
  picker-to-race artifact, current device/signing state, and HarkinianPad
  `1197472`. Stale Gate-0, “Apple not built,” and “picker still open” claims were
  removed. Touch remained explicitly not implemented at that checkpoint;
  the implementation entry below supersedes it.
- **New source-of-truth references:** `NEXT_BUILDER.md` records verified/open/
  blocked state and the exact remaining queue;
  `TOUCH_CONTROLS_IMPLEMENTATION.md` records source-proven F-Zero mappings,
  HarkinianPad adaptation boundaries, architecture, file sequence, and acceptance
  tests; `BUILDER_GOAL_LOOP.md` holds the paste-ready autonomous continuation.
- **Command verification:** generated Xcode projects expose the `G-Diffuser`
  scheme and the latest successful Simulator logs use explicit `xcodebuild`
  project/scheme/SDK/destination syntax. `BUILDING.md` now records those concrete
  commands and the ios-cmake pin instead of the obsolete untested plan.
- **Integrity checks:** `git diff --check` passed; all 18 tracked Markdown files
  passed relative-link validation; the five maintained patch artifacts passed
  reverse-apply checks against their current source trees; the tracked-file scan
  found no ROM/archive/save/app/IPA/provisioning/key extension and no private-key
  or certificate marker.
- **Boundary:** documentation does not close touch, physical hardware, audible
  audio, lifecycle, completed-race, timing, packaging, README-quality, or
  Expansion Kit acceptance. It makes those gates executable by the next builder.

## 2026-08-12 — touch system implemented and Simulator-verified

- **Scope:** the full F0X touch layer landed as one coherent unit: a
  cross-platform API (`port/gdx_touch_controls.h`), a platform-neutral atomic
  state/layout/profile core (`port/gdx_touch_state.c`), a UIKit overlay
  (`port/gdx_touch_controls_ios.mm`), a neutral stub for desktop
  (`port/gdx_touch_controls_stub.c`), the port-1 merge in `input_bridge.c`
  (immediately after the one ControlDeck read, before developer overrides),
  the per-frame host tick and menu/gamepad host callbacks in `main.cpp`, touch
  CVars in `GdxMenu::GdxMenu()`, and the Settings -> Controls -> Touch Controls
  section in `gdx_menu_registry.cpp`.
- **Deterministic regression:** `gdx_touch_merge_tests` passed 87 sub-checks
  against the unmodified `gdx_touch_state.c`: every N64 button bit OR-merges and
  clears; the normalized stick maps continuously to -80..80 with circle
  clamping, sign correctness, deadzone, and `stickActive`; an inactive touch
  stick preserves the physical analog and an active one owns only the two axes;
  simultaneous accelerator + steering + brake/boost/Z/R merge; cancel clears
  buttons and stick; layout overrides apply by id, clamp into the safe rect,
  clamp scale into 70%..150%, and never hide protected controls (stick,
  accelerator, Start, permanent menu); the versioned profile text round-trips.
- **macOS neutral regression:** the rebuilt sealed `F0X.app` (stub touch path)
  passed `codesign --verify --deep --strict`, and the packaged GP script still
  traversed modes `0 -> 7 -> 10 -> 8 -> 9 -> 1`, reached
  `packaged_gp_race_capture_interval`, completed all 28 commands, and exited 0.
  `gdx_fiber_smoketest` still passes.
- **Simulator build:** the genuine arm64 Simulator app compiled and linked with
  the UIKit overlay (ARC on), installed, and launched on the single booted
  iPad Pro 11-inch (M5) Simulator.
- **Live overlay and input chain:** the overlay renders the hand-authored
  tablet layout (stick, D-pad, ACCEL/BOOST/BRAKE, SLIDE L/R, START,
  VIEW/LOOK/C-left/L, and the permanent ••• button). Real synthesized UIKit
  touches produced the exact N64 state input_bridge.c merges: START=0x1000,
  L=0x0020, ACCEL=0x8000, BOOST=0x4000, BRAKE=0x0004, D-pad down=0x0400, and
  continuous analog stick values that change with the drag and clear on
  release.
- **Gameplay flow:** touch START advanced the title; a complete touch-driven GP
  route reached a live race (SELECT MODE -> GP RACE -> STANDARD -> JACK CUP /
  MUTE CITY -> BLUE FALCON -> machine settings -> starting grid), where holding
  ACCEL accelerated the craft from 0 to 41 km/h before a wall stall.
- **Menu and auto-hide:** the ••• button opened the live GdxMenu (log: "touch
  menu visible -> gameplay overlay hidden") and closed it ("menu closed ->
  overlay restored"). With the Simulator's two SDL-visible MFi gamepads
  connected, `gSettings.Touch.AutoHideWithController=1` hid the gameplay
  overlay; setting it to 0 restored it for touch testing.
- **Device build:** the unsigned arm64 iPhoneOS app rebuilt successfully with
  the touch sources and passed the ROM-free payload scan (0 prohibited files).
- **Patch replay:** `patches/gdiffuser-apple-macos.patch` was regenerated and
  verified: reverse-check against the tested working tree passes, and the full
  five-patch series applies cleanly to a pristine pinned clone with the touch
  files byte-identical to the tested tree.
- **Boundary:** Simulator-only. The Settings page's Touch Controls widgets are
  compiled and registered (the Controls page itself renders), but synthetic
  clicks could not scroll the embedded ImGui Input Editor page to reveal them;
  the layout editor, NSUserDefaults profile persistence, phone defaults, and
  physical-device multi-touch acceptance remain to be exercised. The private
  gameplay screenshots are local artifacts and are not tracked.

## 2026-08-12 — layouts aligned to the HarkinianPad reference

- **Default geometry:** the tablet and phone default tables were reworked to
  the accepted HarkinianPad physical layouts: the promoted normalized centers
  (customizable-touch-controls.patch) plus the grip-first base rail frames,
  using full-window normalized centers exactly like the reference. The live
  iPad Simulator overlay's reported frames match the reference fractions for
  every control (stick 0.164/0.745, ACCEL 0.893/0.693, BOOST 0.826/0.635,
  BRAKE 0.902/0.905, VIEW 0.948/0.853, LOOK 0.903/0.805, C-left 0.857/0.854,
  SLIDE L 0.193/0.613, SLIDE R 0.921/0.518, L 0.059/0.518, START 0.845/0.518,
  D-pad 0.079/0.606; the phone table uses the accepted compact fractions).
- **Reference styling:** A blue, B green, C buttons amber, L/Z/R neutral dark
  pills/faces, Start red; the permanent ••• follows the reference slots
  (tablet upper-right, phone top-center gameplay / bottom-center menu-open).
- **Z hold-to-latch:** SLIDE L (Z) adopts the reference's shared Z latch —
  a ~0.5 s hold locks the button with a medium haptic pulse, a later tap
  releases it, and every cancel path clears it. Haptics now fire only on
  deliberate actions (latch, editor Done/Reset), gated by the Haptics CVar.
- **Editor gating:** gameplay emission is disabled per control while the
  editor is open (layoutEditing), matching the reference, so editor touches
  cannot leak N64 state.
- **Phone layout:** on an iPhone 17 Pro Simulator (run separately — one
  Simulator booted at a time), the compact reference layout rendered over a
  live race and the ••• sat in the top-center slot clear of the Dynamic Island
  (safe.left=62). The phone Simulator was shut down before the iPad-only runs.
- **Regressions:** `gdx_touch_merge_tests` still passes 87/87; the unsigned
  arm64 iPhoneOS build succeeds.
- **Boundary:** the Z-latch live capture and the menu-open-while-holding cancel
  capture could not be recorded on the Simulator (repeated window/safe-area
  drift made the synthesized clicks miss; the latch logic mirrors the
  reference and the overlay-removal path clears the unit-tested atomic state).

## 2026-08-12 — live hold-to-cancel, Z-latch, and editor persistence captures

- **Interaction seams:** with one booted iPad Pro 11-inch (M5) Simulator and
  one F0X process (archive-only boot), AX element clicks (System Events) and
  CGEvent mouse down/up/hold were calibrated against the app's own `[F0X]
  touch state` log seam. ACCEL, SLIDE L, and Menu anchor positions were
  verified by the exact N64 bits they produced before the captures below.
- **Hold-to-cancel while pressing Menu:** ACCEL held produced repeated
  `buttons=0x8000`; pressing the ••• button via AX cleared it to
  `touch state neutral (input released)` at the press instant (18:44:38.263),
  and the menu then opened. No stuck control. This is the first live capture
  of the menu-press cancel path on the Simulator.
- **Z hold-to-latch:** holding SLIDE L ~0.9 s left `buttons=0x2000` latched
  after the finger was released (19:09:59.666, 19:10:01.673), AX
  `accessibilityValue = "Locked"`, and the capture shows the blue fill on
  SLIDE L. A later tap released to neutral (19:10:41.722) with AX value nil.
- **Cancel clears latch:** with SLIDE L latched at 0x2000, opening the menu
  produced `touch menu visible -> gameplay overlay hidden` and
  `touch state neutral (input released)` at the same instant (19:11:48.426).
- **Editor and profile persistence:** Customize Touch Layout logged
  `touch layout editor opened` (19:52:13.504); a control override was edited
  and Done logged `touch layout saved` (19:56:41.556). The NSUserDefaults
  tablet profile now carries a non-default D-pad group override
  (`v1 11 0.078500 0.318030 1.000 0` vs the code default y=0.6058), and after
  relaunch the live overlay applied it (D-pad up arrow frame y=191.24 vs the
  pre-edit launch's 383.24). The saved profile survives relaunch and drives
  layout.
- **Lifecycle:** Simulator Home backgrounded F0X; relaunch re-attached the
  overlay neutrally (`hidden=0 userInteraction=1`).
- **Boundary:** Simulator-only; physical-device multi-touch contact stress,
  controller handoff, interruptions, haptics feel, and long sessions remain
  open. The libultraship Input Editor pop-out window overlays part of the
  session and is unrelated to the touch layout profile.
- **Evidence:** `docs/evidence/touch-ios-live/2026-08-12-live-captures.txt`
  plus the log line/timestamp references quoted above.

## 2026-08-12 — macOS race-control experiments and wall-hug probe (blocker audit)

- **Expectation before editing:** determine, with dated evidence, whether any
  available input path on this host can complete a real F-Zero X race, and
  explain the earlier mode-sequence observation (1 -> 15 -> 18 -> 1) that
  superficially resembled a completed race.
- **Environment:** one macOS runtime (`build/macos-f0x-bundle/port/F0X.app`,
  rebuilt 2026-08-12 21:05, HEAD `7564850`, G-Diffuser `719fd82`), window
  `F0X (Metal)` 1440x870 at (0,30); one booted iPad Pro 11-inch (M5)
  Simulator preserved untouched. No controller: `0 joystick(s) present at
  boot`, Bluetooth off.
- **Input paths compared:** (a) System Events keystrokes to the focused
  window — the only live path that reaches SDL input (proved earlier at
  763 km/h with exhaust trails); CGEvent and `postToPid` do not reach the
  game; any intervening shell command steals focus. (b) The internal
  `GDX_INPUT_SCRIPT` harness, which drives the N64 pad seam in-process with
  no window focus requirement — new this turn.
- **Internal-harness probe (reproduced twice):** `scripts/macos-wallhug-probe.gdx`
  (tracked) reaches the live GP race, then `INPUT A -80 0 5400` holds
  accelerator + full-left for 90 s. Frames captured at 1 fps for 175 s
  (`/tmp/f0x-drive/probe2-frames/`): the craft wall-rides at 51-171 km/h,
  energy drains, and the HUD shows **RETIRE** at TIME 00'22"05 with LAP 1/3
  (frame `f-064`, energy bar empty, LAP never left 1/3). The race then ends
  and the GP advances: mode 1 -> 15 (`GP_RACE_NEXT_COURSE`) -> 18
  (`GP_RACE_NEXT_MACHINE_SETTINGS`); the JACK CUP / MUTE CITY next-course
  intro panel is visible (`f-072`, `f-088`).
- **Decompiled explanation:** `Racer_RetireRacer` (racer.c:769) sets
  `D_800F80C4 = -1` for a GP player retirement; at race end
  (racer.c:5512, case 60) `func_80095144` -> `Racer_DecreaseLife`, and the GP
  continues via `MENU_CHANGE_NEXT_COURSE` (game.c:263). The observed
  1 -> 15 -> 18 loop is retirement continuation with a life penalty, not a
  finished race.
- **All attempts, honestly retained:** two documented tap attempts; this
  turn's accel-only (crash, RETIRE ~00'19"), alternation + boost (RETIRE),
  pulse-throttle and continuous-accel gentle-tap variants (LAP 1/3 with TIME
  01'24" -> 04'10" and speed 0, craft wall-riding), and the coast drive whose
  mode sequence is now explained. None completed a lap.
- **Flashing evidence re-verified for owner confirmation:** the current
  bundle's dense race-region captures (`/tmp/f0x-drive/macdense/region-*.png`,
  34 frames) and `q-*.png` (8 frames) contain 0 near-black frames and 0
  brightness jumps; owner confirmation of the corrected Finder launch remains
  open.
- **Result and boundary:** a player-completed macOS race is not achievable
  with the input paths available on this host; every sustained automated
  pattern retires the craft (energy death on wall contact). Full exact report
  in `docs/blockers/MAC-RACE-CONTROL-01.md`. This is not a claim that the game
  or input seam is broken: races start, run, retire, and the GP loop advances
  correctly.
- **Next gate:** the macOS race acceptance resumes with owner/human play or a
  connected controller; meanwhile the locally actionable queue continues at
  the Share Diagnostic Log gate.

## 2026-08-13 — Share Diagnostic Log implemented and macOS-verified

- **Expectation before editing:** an accessible Share Diagnostic Log action
  that collects useful system/runtime state (app/OS/device, renderer/Metal
  device, game-data validation, save class, controller/touch, scheduler,
  audio, timing, errors) with strict privacy exclusions, writes a text
  artifact, and presents the standard Share sheet; a deterministic unit test
  covers the formatter and the privacy scrub.
- **Implementation (maintained patch, `port/`):** `gdx_diagnostics.h/.c` is the
  platform-neutral bounded report builder with defense-in-depth redaction
  (values containing token/password/secret/api-key/private-key markers render
  `[REDACTED]`); `gdx_diagnostics_share.mm` fills Apple platform/Metal-device
  fields and presents `NSSharingServicePicker` (macOS; `UIActivityViewController`
  path compiled for iOS but not yet wired); the F0X Home surface gains a
  "Share Diagnostic Log" button that collects live Home state (window size,
  refresh, interpolation target, archive/save presence and sizes, SDL joystick
  count, touch build class, scheduler backend) and shares the report.
- **Unit regression:** `gdx_diagnostics_tests` passes all checks: every
  section/field present, empty source renders "unknown", deterministic output,
  tiny-buffer truncation stays NUL-terminated, NULL source tolerated, and
  secret-like values (token, BEGIN PRIVATE KEY, device "secret name") are
  redacted from the output.
- **macOS live verification:** rebuilt sealed `F0X.app` (codesign
  `--verify --deep --strict` passes) launches to F0X Home; keyboard-nav focus
  (System Events Shift+Tab from the focus ring) activated "Share Diagnostic
  Log"; log `[diag] shared N-byte diagnostic report`; the macOS Share sheet
  appeared for `F0X-Diagnostics-2026-08-13-000459.txt` (Text Document, 1 KB);
  the artifact contains: Apple macOS / Version 26.5.2 / arm64, Fast3D / Metal
  with Metal device Apple M1, window 1440x838, 60 Hz, interpolation target
  "Match Display refresh", data-dir class "user Application Support (mutable)"
  (no absolute private path), archive `fzerox.o2r present (15499571 bytes),
  validated at setup`, save `fzerox.sav present (32768 bytes)`, 0 SDL
  joysticks, desktop touch stub, ucontext scheduler, pre-game Home state. No
  ROM/save contents, signing material, or private paths are in the artifact.
- **Standing regressions:** `gdx_touch_merge_tests` 87/87; the packaged GP
  script traversed modes `0 -> 7 -> 10 -> 8 -> 9 -> 1`, reached
  `packaged_gp_race_capture_interval`, completed all 28 commands, exit 0; the
  unsigned arm64 iPhoneOS build succeeds with the new sources (including the
  iOS share-sheet path) and the device bundle passes the ROM-free payload
  audit (only the engine's own `gdiffuser.o2r` archive; no game data/signing
  material).
- **Patch replay:** `patches/gdiffuser-apple-macos.patch` regenerated;
  reverse-check against the tested tree passes; the five-patch series
  clean-applies to a pristine pinned `719fd82` clone with the diagnostics and
  touch files byte-identical to the tested tree.
- **Boundary:** macOS Home action verified. The in-game menu entry and the iOS
  Share-sheet wiring (triggering `UIActivityViewController` from the touch
  overlay/menu) remain the next slice; the collector is platform-neutral and
  already compiled into the iOS build.

## 2026-08-13 — macOS 60 Hz simulation/timer/pacing measurement

- **Expectation before editing:** prove the simulation and race timer advance
  at the correct 60 Hz rate against wall clock during a live race on named
  hardware, with frame pacing and audio-thread behavior measured from the
  same run.
- **Probe (small, opt-in):** `GDX_RACE_TIME_PROBE=1` in `main.cpp` logs the
  decompiled race frame counter (`sRaceFrameCount`), the global game frame
  counter, the masked game mode, and the host steady clock every 64 host
  frames. Zero cost when unset; the run also enabled the existing perf
  telemetry (`GDX_PERF=1`) and the run-log sink (`GDX_LOG=1`).
- **Run:** sealed `F0X.app` on Apple M1 MacBook Air, macOS 26.5.2, Debug
  cartridge-only, one windowed runtime, `GDX_INPUT_SCRIPT=scripts/macos-wallhug-probe.gdx`
  (Jack Cup / Mute City, sustained A + full-left via the internal harness).
- **Simulation/timer rate:** during a 37.36 s wall-clock race window the race
  frame counter advanced 2240 and the game frame counter advanced the same
  2240: **59.954 race frames/s** (0.08% from 60.00 — the N64 NTSC field
  cadence). The race TIME is derived from these frames, so the timer advances
  1 s per wall second at the same rate. Per-second deltas were uniform (64
  frames per probe cadence).
- **Frame pacing (perf summaries, 600-frame windows):** steady race windows
  show p50 16.62-16.68 ms, p95 17.43-18.33 ms, p99 17.92-19.15 ms, and
  **0 spikes**; startup/menu windows have transient spikes (GUI/archive load),
  with maxima 88-105 ms in the first windows settling to <=34 ms.
- **Audio thread:** dedicated producer tick p95 2.9-4.0 ms and max 4.7-7.1 ms
  in the clean race windows (well inside the 16.68 ms frame budget); the
  post-race transition window shows a transient 25.9 ms audio max.
- **Telemetry artifact found (pre-existing, not a game defect):** the perf
  summary's `post=` sub-mean reports millions of ms in early windows
  (accumulator/normalization issue in the perf sub-timers); the race-window
  sub-breakdowns are sane (decomp 0.22-0.39 ms, xlate 1.9-3.4 ms, run
  2.8-6.5 ms). Recorded in KNOWN_ISSUES.
- **Boundary:** one named macOS host, one track (Mute City), one scripted
  race pattern, default 60 Hz VSync path (interpolation off). Remaining for
  full acceptance: representative courses, physical-device timing, high
  refresh/Match Display transitions, and Low Power Mode behavior.

## 2026-08-13 — phone-defaults re-run on the current build (iPhone 17 Pro Simulator)

- **Expectation before editing:** the current build (touch system + diagnostics
  compiled) must select the phone default table on an iPhone device class,
  render every control at its normalized default position, keep the ••• in the
  phone top-center gameplay slot clear of the Dynamic Island, and attach the
  overlay over a live race. One Simulator at a time: the iPad Pro Simulator was
  shut down, the iPhone 17 Pro Simulator booted, the fresh build installed and
  launched (archive-only boot).
- **Result:** device class selected the `kPhoneSpecs` table. All 12 controls
  rendered at their full-window normalized default centers exactly (stick
  0.2145/0.7222, ACCEL 0.8764/0.7376, BOOST 0.8057/0.6650, BRAKE 0.8665/0.5701,
  SLIDE L 0.2425/0.4991, START 0.8670/0.1443, VIEW/LOOK/C-left, D-pad), with
  the two edge pills L/SLIDE R safely clamped inward by exactly 14 pt to the
  landscape safe boundaries (left/right 62 pt). The menu button sat at
  (0.500, 0.075) — the phone top-center slot, clear of the Dynamic Island
  (safe.left=62). The overlay attached live (`hidden=0 userInteraction=1`) over
  a running race. No saved NSUserDefaults profile exists in this container, so
  the frames are the code defaults.
- **Evidence:** `docs/evidence/touch-ios-phone/2026-08-13-phone-defaults.txt`
  (control-by-control verification table) plus the app console lines quoted
  there. The local screenshot shows the compact overlay over the live race.
- **Boundary:** Simulator-only; physical iPhone multi-touch acceptance remains
  open. The iPad Pro Simulator was re-booted afterward to restore the standing
  environment.
