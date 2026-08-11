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

## 2026-08-11 — Gate 3 cartridge PCM capture wiring and silence proof

- **Cause fixed:** this Apple baseline is configured with `GDX_EXPANSION_KIT=OFF`, so it compiles `decomp/src/audio/rom/lib/thread.c`. The existing PCM tap was only present in the uncompiled disk/Expansion-Kit audio thread. The active ROM thread now calls `gdx_pcm_capture_feed` immediately before `osAiSetNextBuffer`, under `PORT`; it is inert unless `GDX_PCM_CAPTURE` is set.
- **Build and unit regression:** `cmake --build build/macos-baseline-clean --target G-Diffuser gdx_pcm_capture_tests --parallel 4` passed. `gdx_pcm_capture_tests` passed all 5 cases and 28 sub-checks.
- **Runtime result:** a bounded startup capture reached its configured 128,000 stereo frames and wrote a 512,000-byte PCM file, proving the active cartridge feed is connected. That short window was all zero and ended before the scripted delayed Start input.
- **GP-route result:** a longer captured run emitted `reached_gp_race` and wrote 1,835,008 stereo frames (3,670,016 samples; 7,340,032 bytes). Every sample was zero (`min=0`, `max=0`, `RMS=0`). The process ended before its scripted clean exit and left no crash artifact, so that termination is not attributed to the capture change.
- **Conclusion:** the earlier empty-file observation was a missing cartridge capture hook; the remaining failure is that the cartridge audio task/synthesis path delivers silence. CoreAudio device output has not been accepted as evidence, and audio remains an open Gate 3 blocker.
