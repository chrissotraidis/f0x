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
- **Not established:** process launch, Metal initialization, fiber switching, ROM loading, title screen, gameplay, input, audio, or persistence.

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
- **Not established:** visible title/menu, playable race, audible speakers, saves, controller hardware, performance, or physical-device behavior.

## Next experiment

Capture the active game window directly during the now-reproducible GP race;
desktop-wide captures are currently obscured by unrelated system UI. Keep the
all-black BMP readback issue separate from the renderer gate, then verify it
independently before relying on it for transition evidence.

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

## 2026-08-11 — Gate 3 cartridge PCM synthesis proof

- **Fixes:** the cartridge build (`GDX_EXPANSION_KIT=OFF`) now feeds the active ROM AI buffer into the PCM seam. Its permanent allocator returns its allocation on host ABIs, sequence-font offsets are decoded as big-endian bytes, and soundfont blobs are converted into persistent host-native objects instead of rewriting 32-bit N64 offsets as host pointers.
- **Build and unit regression:** `cmake --build build/macos-baseline-clean --target G-Diffuser gdx_pcm_capture_tests --parallel 4` passed. `gdx_pcm_capture_tests` passed all 5 cases and 28 sub-checks.
- **Dedicated-thread runtime:** from `build/macos-baseline-clean/port`, an SDL dummy-device run with `GDX_AUDIO_THREAD=1`, `GDX_PCM_CAPTURE_FRAMES=180000`, and `menu_smoke.gdx` exited 0. It captured 720,000 bytes (180,000 stereo frames); 108,416 of 360,000 signed samples were nonzero, with maximum absolute value 12,903 and RMS 1,189.649. SHA-256: `6e9444c63682bfc88334517e8f5f7423707ceb007eef7ca331e47f690a83e490`.
- **Boundary:** this proves native cartridge command processing, DMA, soundfont decoding, task synthesis, and the dedicated producer path. SDL dummy output is deliberately not speaker/headphone evidence; the normal CoreAudio setting was restored after the test.
- **Normal-output attempt:** the restored CoreAudio configuration stalled before game boot in Apple `AudioComponentInstanceNew` / `HALC_ProxyIOContext::_TellServerAboutStreamUsage`. A two-second process sample places the wait wholly inside CoreAudio device creation, so it is not evidence against the now-proven cartridge synthesis path.
- **Direct-window attempt:** `race_window_capture.gdx` reached its named GP interval and exited cleanly under SDL dummy audio, but this ad-hoc executable is not enumerated as a selectable window by the available accessibility service. No window image was therefore captured; the old black framebuffer BMPs remain unsuitable as a substitute for visual race proof.
