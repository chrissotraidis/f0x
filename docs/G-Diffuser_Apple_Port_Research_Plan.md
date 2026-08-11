# G-Diffuser on Apple Platforms
## Research Brief, Feasibility Assessment, and Recommended Implementation Plan

**Research date:** August 11, 2026  
**Primary target:** G-Diffuser itself as the native Apple port of *F-Zero X*  
**Target platforms:** macOS (Apple Silicon), iPadOS, iOS  
**Graphics target:** Native Metal through libultraship/Fast3D  
**Project basis:** [`Zorkats/G-Diffuser`](https://github.com/Zorkats/G-Diffuser)

---

## Executive decision

The recommended project is **not a new F-Zero X port built beside G-Diffuser**.

The recommended project is:

> **Fork G-Diffuser and make G-Diffuser itself a first-class Apple-native port, preserving its existing architecture, enhancements, asset pipeline, and upstream lineage.**

This is the shortest path to a serious macOS/iPadOS/iOS build because most of the difficult N64-to-host work is already done:

- the original game is available as a matching C decompilation;
- G-Diffuser already compiles that game logic for a modern little-endian 64-bit host;
- the N64 hardware-facing portions have already been replaced or bridged;
- Fast3D already interprets the game's N64 display lists;
- libultraship already contains a Metal renderer;
- the G-Diffuser-pinned libultraship fork already contains explicit iOS build code;
- the same library already has Apple filesystem support, SDL mobile handling, ImGui/Metal handling, and Apple framework linkage;
- G-Diffuser already has a clean host-input bridge into the decompiled game's N64 controller state;
- G-Diffuser's Torch fork already supports **static-library mode** and can consume a ROM from an in-memory byte vector, which gives us a viable solution for iOS asset extraction without spawning a child executable.

This is therefore **not a renderer rewrite** and not a new decompilation project. The work is primarily an Apple platform integration project with a few real low-level risks.

### Feasibility estimate

These are engineering estimates based on the current source tree, not guarantees.

| Target | Assessment | Main uncertainty |
|---|---:|---|
| macOS Apple Silicon + Metal | **9/10** | build/platform cleanup and runtime validation |
| iPadOS + Metal + physical controller | **8/10** | iOS packaging, filesystem, scheduler, audio |
| iPadOS/iOS + polished touch controls | **7.5–8/10** | touch UX and lifecycle polish |
| Full 64DD Expansion Kit on iOS | **6.5–7/10** | multi-file import, persistence, editor UX |
| High-refresh / 120 Hz interpolation | **8/10 after base port works** | Apple presentation timing rather than game logic |

The recommended order is:

**macOS ARM64 → iPadOS controller-first → touch → high-refresh → 64DD → iPhone polish.**

---

# 1. What G-Diffuser actually is

G-Diffuser is a native source port of *F-Zero X*. It is based on the `fzerox` matching decompilation and compiles the game logic as host C rather than emulating an N64 CPU at runtime.

The relevant stack is:

```text
F-Zero X retail ROM
        │
        ├── matching C decompilation: Zorkats/fzerox
        │
        ▼
G-Diffuser host port layer
  - libultra replacements
  - host scheduling
  - graphics bridge
  - audio bridge
  - ROM/SRAM/64DD handling
  - asset bindings
  - enhancements
        │
        ▼
libultraship
  - Fast3D display-list interpreter
  - renderer backends
  - SDL window/input
  - audio
  - resource system
  - ImGui
        │
        ▼
Metal / OpenGL / D3D11
```

That architecture is materially better for this project than starting again from `inspectredc/fzerox`.

G-Diffuser's own architecture documentation describes a significant host adaptation layer. The decomp remains suitable for matching against retail while `PORT`-gated code allows it to run on modern hardware. The project documents hundreds of `PORT`-conditioned sites across the decompiled source.

**Recommendation:** do not discard that work. Apple-specific behavior should remain concentrated in `port/` and libultraship wherever possible.

---

# 2. Current upstream state as of August 11, 2026

The upstream repository is:

- [`Zorkats/G-Diffuser`](https://github.com/Zorkats/G-Diffuser)

Its submodules currently point to project-owned forks:

- [`Zorkats/libultraship`](https://github.com/Zorkats/libultraship)
- [`Zorkats/Torch`](https://github.com/Zorkats/Torch)
- [`Zorkats/fzerox`](https://github.com/Zorkats/fzerox)
- [`Zorkats/fzerox-expansion-kit`](https://github.com/Zorkats/fzerox-expansion-kit)

That matters because the Apple port cannot be treated as a one-repository change. The likely clean architecture is a fork of G-Diffuser plus a fork of the G-Diffuser libultraship submodule, with Torch forked only if the in-process extraction work cannot be implemented cleanly from the parent repository.

### Current release

The current public release is **G-Diffuser v1.0.1**, published August 11, 2026. Official binaries are currently Windows x64 and Linux x64.

The v1.0.1 release is also useful evidence because it includes touchscreen fixes for the enhancement menu on devices such as Steam Deck and ROG Ally. Touch is therefore not completely foreign to the current UI stack.

### Upstream Apple intent

There is already an open G-Diffuser issue titled **"macOS build instructions?"** in which a user attempted:

- x64 Darwin;
- ARM64 Darwin;
- ARM64 iOS.

The reported build progressed into the `gdx_extract_ext` external project before failing.

The maintainer responded that macOS was deliberately not targeted for the first release because of limited experience with the Metal renderer, and that macOS support is intended for a future v1.1.0 or v1.2.0.

That is a useful signal:

> The Apple path is not considered architecturally incompatible by upstream; it is simply unfinished.

**Strategic implication:** if the goal is to get there first, there is an unusually clear window right now. The renderer and much of the platform machinery already exist, while the finished G-Diffuser Apple integration does not.

---

# 3. Why Metal is not the hard part

The most important technical finding is that the G-Diffuser-pinned libultraship fork already has an Apple Metal backend.

Relevant files include:

- `src/fast/backends/gfx_metal.cpp`
- `src/fast/backends/gfx_metal_shader.cpp`
- `src/fast/Fast3dWindow.cpp`
- `src/fast/Fast3dGui.cpp`
- `cmake/dependencies/mac.cmake`
- `cmake/dependencies/ios.cmake`

`Fast3dWindow` already does the following on Apple:

1. tests `Metal_IsSupported()`;
2. registers `FAST3D_SDL_METAL`;
3. selects `GfxRenderingAPIMetal`;
4. pairs it with the SDL window backend.

The SDL window backend already has an iOS-specific path and creates an `SDL_WINDOW_METAL` window when Metal is selected.

The ImGui layer already:

- initializes ImGui for SDL + Metal;
- invokes `GfxRenderingAPIMetal::MetalInit`;
- calls Metal-specific new-frame and draw-data functions;
- disables multi-viewport behavior on iOS/mobile;
- enables SDL touch-to-mouse behavior.

### Existing iOS CMake support

The current libultraship fork has explicit iOS handling:

```text
CMAKE_SYSTEM_NAME == iOS
    → Objective-C++ enabled
    → iOS dependency file included
    → iOS toolchain populated
    → __IOS__ defined for libultraship
```

Its iOS dependency file already fetches:

- SDL2;
- nlohmann-json;
- tinyxml2;
- spdlog;
- libzip;
- metal-cpp;
- ImGui's Metal backend.

It also links the Apple frameworks required by the library, including Metal and QuartzCore.

### Conclusion

**Do not write a new F-Zero X Metal renderer.**

The correct task is to make G-Diffuser cleanly select and package the Metal path that already exists, then fix the Apple-specific leaks and incomplete platform assumptions around it.

---

# 4. Existing iOS precedent in the same ecosystem

The HarbourMasters ecosystem already contains an iOS packaging pattern in Ghostship.

Ghostship's CMake creates an iOS application bundle using:

- `MACOSX_BUNDLE`;
- an iOS `Info.plist`;
- launch storyboard/resources;
- bundle identifier;
- Xcode signing settings;
- a bundled engine `.o2r`;
- iOS-specific disabling of scripting and dynamic-library behavior.

Relevant reference:

- [`HarbourMasters/Ghostship`](https://github.com/HarbourMasters/Ghostship)
- [`Ghostship CMakeLists.txt`](https://github.com/HarbourMasters/Ghostship/blob/develop/CMakeLists.txt)
- [`Ghostship ios/plist.in`](https://github.com/HarbourMasters/Ghostship/blob/develop/ios/plist.in)

This is valuable because G-Diffuser does not need an invented Apple packaging architecture. The build can borrow the proven shape while keeping its own product identity and assets.

**Recommendation:** use Ghostship as a packaging reference, not as a codebase to rebase onto.

---

# 5. The real Apple blockers

The current source contains several concrete issues that explain why "libultraship supports iOS" does not mean "G-Diffuser builds on iOS today."

These are the first things to fix.

---

## 5.1 Linux linker behavior is currently applied to every non-Windows build

G-Diffuser's `port/CMakeLists.txt` currently puts Linux-specific behavior under broad `else()` / `NOT MSVC` conditions.

Two examples:

### `$ORIGIN`

The executable receives:

```cmake
INSTALL_RPATH "$ORIGIN/lib"
```

That is a Linux packaging convention, not an Apple bundle path.

### GNU linker version script

The executable also receives:

```cmake
-Wl,--version-script=.../gdx_hide_libm.map
```

under `NOT MSVC`.

This is specifically a Linux audio-symbol workaround and should not be handed to Apple's linker.

### Recommended change

Make these Linux-only:

```cmake
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    find_package(Threads REQUIRED)
    target_link_libraries(G-Diffuser PRIVATE Threads::Threads ${CMAKE_DL_LIBS})

    set_target_properties(G-Diffuser PROPERTIES
        BUILD_WITH_INSTALL_RPATH TRUE
        INSTALL_RPATH "$ORIGIN/lib"
    )

    target_link_options(G-Diffuser PRIVATE
        "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/gdx_hide_libm.map"
    )
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    find_package(Threads REQUIRED)
    target_link_libraries(G-Diffuser PRIVATE Threads::Threads)
elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    # Apple/mobile-specific linking only.
endif()
```

The exact final layout can differ, but Linux behavior must stop leaking into Darwin/iOS.

---

## 5.2 libultraship has a concrete iOS audio inconsistency

This is one of the strongest actual bugs found in the research.

`src/ship/audio/Audio.cpp` treats **all Apple platforms** as CoreAudio-capable:

```cpp
#ifdef __APPLE__
    // CoreAudio backend included / offered / selected by default
#endif
```

However, `src/ship/CMakeLists.txt` only compiles `CoreAudioAudioPlayer.cpp` when:

```cmake
CMAKE_SYSTEM_NAME STREQUAL "Darwin"
```

—not iOS.

That means an iOS build can select/reference a backend whose implementation is not in the target.

### Recommended first-port solution

Do **not** design a new native iOS audio system during initial bring-up.

For iOS:

- compile/use the existing SDL audio backend;
- expose CoreAudio only on macOS/Darwin;
- revisit native iOS audio after the game is proven.

Conceptually:

```cpp
#if defined(__APPLE__) && !defined(__IOS__)
    // CoreAudio desktop backend
#endif
```

or, preferably, use CMake-generated platform definitions instead of relying on compiler macros.

This makes audio a comparatively low-risk item.

---

## 5.3 macOS-only fullscreen code is gated as generic Apple code

The SDL backend currently includes macOS utilities on `__APPLE__` and calls:

- `toggleNativeMacOSFullscreen`;
- `isNativeMacOSFullscreenActive`.

But `macUtils.mm` is only built for Darwin/macOS, not iOS.

That creates an obvious iOS link/runtime hazard.

### Recommended change

Split the conditions:

```cpp
#if defined(__APPLE__) && !defined(__IOS__)
    // native macOS fullscreen implementation
#elif defined(__IOS__)
    // fullscreen is inherent in the mobile app/window model
#endif
```

For iOS, fullscreen toggling should effectively be a no-op or fixed-on state.

---

## 5.4 OpenGL is still registered as an available backend on iOS

`Fast3dWindow`:

1. adds Metal on Apple;
2. then unconditionally adds the SDL OpenGL backend.

But libultraship's iOS build intentionally does **not** define `ENABLE_OPENGL`.

Metal will normally be the first valid backend, so this may not break first boot, but an iOS build should not advertise a renderer that does not exist.

### Recommended change

```cpp
#if !defined(__IOS__)
    AddAvailableWindowBackend(WindowBackend::FAST3D_SDL_OPENGL);
#endif
```

Longer term, define explicit platform capability tables rather than rely on scattered macro checks.

---

## 5.5 Backend source filters appear stale

`src/fast/CMakeLists.txt` globs files relative to `src/fast`, where the actual paths look like:

```text
backends/gfx_metal.cpp
backends/gfx_opengl.cpp
```

Some subsequent filter regexes still reference an older-looking prefix:

```text
graphic/Fast3D/backends/...
```

The filters therefore appear unlikely to match the current relative paths.

Many backend source files have their own compile guards, so this is not necessarily the immediate cause of a failed build. It is nevertheless technical debt worth removing as part of the platform separation.

**Recommendation:** fix the filters while establishing a clean Apple platform matrix.

---

# 6. Introduce explicit G-Diffuser platform definitions

The code currently mixes:

- `_WIN32`;
- `WIN32`;
- `__APPLE__`;
- `__IOS__`;
- `CMAKE_SYSTEM_NAME`;
- generic non-Windows fallbacks.

For a project now targeting Windows, Linux, macOS and iOS, that is too ambiguous.

Recommended CMake definitions:

```cmake
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    target_compile_definitions(G-Diffuser PRIVATE
        GDX_PLATFORM_APPLE=1
        GDX_PLATFORM_MACOS=1
    )
elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    target_compile_definitions(G-Diffuser PRIVATE
        GDX_PLATFORM_APPLE=1
        GDX_PLATFORM_IOS=1
        __IOS__=1
    )
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_compile_definitions(G-Diffuser PRIVATE
        GDX_PLATFORM_LINUX=1
    )
endif()
```

Apply compatible definitions to targets that need them, including `gdiffuser_game`.

The goal is not macro proliferation. It is to make statements such as these explicit:

- macOS desktop behavior;
- iOS mobile behavior;
- Apple-shared behavior;
- Linux-only behavior.

That will prevent the class of bugs already visible in audio and fullscreen handling.

---

# 7. Filesystem and sandbox architecture

G-Diffuser currently follows a portable desktop model in which the executable directory effectively acts as the data directory.

That is inappropriate for a packaged iOS application because the app bundle is not the writable persistent-data location.

The current first-boot code also tries `/proc/self/exe` on the non-Windows path—another Linux assumption.

Fortunately, libultraship already ships `AppleFolderManager.mm`, which knows how to:

- locate the main bundle resource directory;
- locate Application Support;
- create an application-specific support directory;
- resolve standard Apple user directories.

### Recommended Apple layout

```text
G-Diffuser.app/
    bundled immutable resources
        gdiffuser.o2r
        fonts/
        decomp-recipes/
        licenses/
        controller database if needed

Application Support/G-Diffuser/
    gdiffuser.cfg.json
    imported ROM or managed ROM copy
    fzerox.o2r
    saves
    ghosts
    logs
    mods/
    64DD media/sidecars later
```

On iOS, user-provided files should be imported through Apple's document picker rather than assuming shell-visible filesystem paths.

Relevant Apple API:

- [`UIDocumentPickerViewController`](https://developer.apple.com/documentation/uikit/uidocumentpickerviewcontroller)

For a file outside the sandbox, Apple may return a security-scoped URL. The app should acquire access, validate/copy or internalize the file, and release the scope.

### Recommended first-boot flow

```text
Launch
  │
  ├─ bundled gdiffuser.o2r exists
  │
  ├─ Application Support has valid fzerox.o2r?
  │     └─ yes → boot
  │
  └─ no
        │
        ├─ present "Import F-Zero X ROM"
        ├─ user selects legal dump
        ├─ validate format/hash
        ├─ copy/read into app-managed storage
        ├─ extract locally
        └─ boot
```

Do not make the user manage G-Diffuser's internal directory structure manually.

---

# 8. Asset extraction: the largest desktop assumption, but not a dead end

G-Diffuser currently builds a separate `gdx-extract` executable as a CMake `ExternalProject`.

At runtime, first boot spawns that executable and monitors it while it uses Torch to create `fzerox.o2r`.

That architecture is fine on Windows/Linux and awkward on iOS.

### Important discovery: Torch already supports static-library mode

The G-Diffuser Torch fork has:

```cmake
option(USE_STANDALONE "Build as a standalone executable" ON)
```

When `USE_STANDALONE=OFF`, it creates a **static library** instead of an executable.

Its command-line entry point is guarded so the standalone `main` is not part of that library build.

Even better, `Companion` has constructors accepting either:

- a ROM filesystem path; or
- `std::vector<uint8_t>` containing the ROM.

This means the iOS solution can stay inside the existing asset technology.

### Recommended architecture

Do not delete the desktop extractor.

Create an extraction abstraction:

```text
GdxAssetExtractor
    │
    ├── DesktopProcessExtractor
    │       Windows/Linux/macOS initially
    │       wraps current gdx-extract executable behavior
    │
    └── InProcessTorchExtractor
            iOS/iPadOS
            links Torch STATIC
            reads ROM bytes in process
```

The orchestration code should retain current behavior:

- validate source ROM;
- extract into a temporary directory;
- preserve deterministic output;
- validate archive hash/entry count where applicable;
- atomically install `fzerox.o2r`;
- maintain sidecar state;
- never ship game-derived assets.

### iOS CMake direction

For iOS, conceptually:

```cmake
set(USE_STANDALONE OFF CACHE BOOL "" FORCE)
set(BUILD_STORMLIB OFF CACHE BOOL "" FORCE)
set(BUILD_UI OFF CACHE BOOL "" FORCE)

set(BUILD_FZERO ON CACHE BOOL "" FORCE)
set(BUILD_SM64 OFF CACHE BOOL "" FORCE)
set(BUILD_MK64 OFF CACHE BOOL "" FORCE)
set(BUILD_SF64 OFF CACHE BOOL "" FORCE)
set(BUILD_PM64 OFF CACHE BOOL "" FORCE)
set(BUILD_BK64 OFF CACHE BOOL "" FORCE)
set(BUILD_MARIO_ARTIST OFF CACHE BOOL "" FORCE)

add_subdirectory(torch)
target_link_libraries(G-Diffuser PRIVATE torch)
```

The exact list should be checked against Torch's dependency graph before finalizing it.

### Implementation warning

Do not guess the correct sequence of `Companion::Init`, `Process`, `Pack`, `ExportType`, version stamping, and recipe configuration.

Instead:

> Refactor the exact logic currently used by Torch's F-Zero command-line path into a shared callable function, then make both the CLI and the iOS adapter use that function.

That keeps desktop and mobile extraction behavior identical.

### Earliest bring-up shortcut

G-Diffuser already has a raw-ROM fallback if archive extraction fails.

For a private engineering bring-up, that is useful:

> **Do not block the first Metal race on the final iOS extractor.**

If raw-ROM boot works, use it to validate the game/renderer/scheduler/input path first. Then complete the in-process extraction path before calling the iOS port distributable.

---

# 9. Scheduler/fiber backend: the main low-level unknown

G-Diffuser runs the decompiled N64 cooperative threading model through a custom fiber abstraction.

Current choices:

```text
Windows → Win32 fibers
everything else → ucontext implementation
```

The POSIX implementation uses:

- `getcontext`;
- `makecontext`;
- `swapcontext`;
- `mmap`;
- guard pages;
- pthread/thread-local behavior.

### Why this needs an explicit spike

macOS ARM64 and iOS ARM64 are both little-endian 64-bit platforms, which is favorable for the rest of G-Diffuser's host model.

But the fiber layer is low-level enough that "it compiled on Linux" is not evidence that it is correct on Apple ARM64.

The correct plan is not to preemptively rewrite it. It is:

1. compile the existing backend for macOS ARM64;
2. run a standalone fiber smoke test;
3. compile it for iOS;
4. run on a **real ARM64 device**;
5. only replace it if compile/runtime behavior requires it.

### Add an explicit test

Create something like:

```text
gdx_fiber_smoketest
```

It should:

- convert the host thread;
- create multiple fibers;
- yield/switch repeatedly;
- verify preserved integer state;
- verify preserved floating/SIMD state if relevant;
- verify stack isolation;
- run a large number of deterministic switches;
- report failure loudly.

Then run the actual game scheduler tests.

### If ucontext fails

Do not touch the game scheduler.

Implement:

```text
gdx_fiber_apple_arm64.c / .S
```

behind the existing `gdx_fiber.h` API.

That is a contained problem: save/restore the required ARM64 context and maintain the same create/switch semantics.

### Additional ARM64 validation

G-Diffuser already documents complicated host-pointer / low-32-bit address reconstruction behavior.

Apple ASLR and ARM64 address layouts may expose assumptions that Windows/Linux did not.

Therefore the macOS bring-up should enable diagnostics around:

- host range registration;
- reconstructed 32-bit tokens;
- segment address resolution;
- graphics pointer translation;
- asset binding accesses.

This is a validation risk, not evidence of a necessary redesign.

---

# 10. Audio recommendation

### macOS

Use libultraship's existing CoreAudio backend after fixing platform conditionals.

### iOS/iPadOS first playable

Use SDL audio.

Reasons:

- SDL is already part of the dependency tree;
- G-Diffuser's audio bridge does not need to know that the final device backend changed;
- it avoids simultaneously debugging a platform port and a new audio implementation.

### Later option

If latency, interruptions, Bluetooth behavior or route changes justify it, implement a native iOS audio backend using Apple's mobile audio APIs.

Do not put that on the critical path to first playable.

---

# 11. Input architecture is unusually favorable

G-Diffuser already has a clear host input seam in `port/input_bridge.c`.

The original N64 controller polling path is disabled under `PORT`, and G-Diffuser fills the decompiled game's controller globals from libultraship's ControlDeck every frame.

The N64 button masks line up directly, and the analog stick is already represented in the expected N64 range.

That means Apple controls do **not** need to invade game code.

### Recommended layers

```text
Physical controller
      │
      ├── SDL/libultraship ControlDeck
      │
      ▼
host N64 pad state
      │
      ▼
G-Diffuser input_bridge.c
      │
      ▼
decompiled F-Zero X
```

For touch:

```text
Touch overlay / virtual controller
      │
      ▼
same host N64 pad state seam
      │
      ▼
G-Diffuser input_bridge.c
```

### First iPad milestone

Use physical controllers first.

SDL already provides the shortest route into the existing ControlDeck.

### Touch milestone

F-Zero X is a good touch candidate because its core driving interaction is much simpler than a free-camera 3D adventure game.

A good touch UI can focus on:

- analog steering;
- acceleration/braking;
- boost/attack/secondary controls;
- Start/pause;
- optional haptics;
- adjustable opacity/scale later.

Do not hard-code touch logic into the decomp.

Create either:

1. a dedicated virtual physical device inside the ControlDeck abstraction; or
2. an Apple virtual-controller layer that resolves into the same N64 pad state.

Apple's Game Controller framework also has virtual-control support:

- [`Game Controller`](https://developer.apple.com/documentation/gamecontroller)
- [`Adding virtual controls to games`](https://developer.apple.com/documentation/gamecontroller/adding-virtual-controls-to-games-that-support-game-controllers-in-ios)

A custom G-Diffuser overlay may still be preferable because F-Zero benefits from a purpose-built racing layout.

### Existing menu touch support

libultraship already enables SDL touch-to-mouse for the ImGui UI, and G-Diffuser v1.0.1 fixed touchscreen gesture conflicts in its enhancement menu.

Therefore:

> Do not build a second native settings menu unless the existing ImGui menu proves unusable on iPad.

Make the existing menu touch-friendly first.

---

# 12. iOS application shell

The G-Diffuser executable currently assumes a desktop process with a conventional `main`.

For iOS, follow the existing SDL/libultraship model and Ghostship's bundle pattern instead of replacing the runtime with Swift.

Recommended application-bundle components:

```text
ios/
    Info.plist.in
    Launch.storyboard or modern launch configuration
    Assets.xcassets / icon resources
    ApplePlatformBridge.mm
    DocumentImportBridge.mm
    LifecycleBridge.mm
```

CMake should create an Apple bundle and handle signing options.

Conceptually:

```cmake
if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    add_executable(G-Diffuser MACOSX_BUNDLE ${GDX_SOURCES})

    set_target_properties(G-Diffuser PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/ios/Info.plist.in"
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "..."
    )
endif()
```

The final bundle identifier can be selected later.

### Disable desktop-only features initially on iOS

Good candidates:

- Discord Rich Presence;
- child-process dump helpers;
- desktop file dialogs;
- dynamic scripting/TCC;
- dynamic-library loading;
- desktop-only crash UI;
- any tool that assumes launching another process.

Keep:

- core enhancements;
- ImGui menu;
- texture/resource system;
- save system;
- controller input;
- diagnostics that work inside the sandbox.

---

# 13. Application lifecycle

An iOS game must tolerate interruption and backgrounding.

At minimum, when the scene/app resigns active:

- stop accepting touch input;
- clear latched virtual controls;
- pause or suspend simulation;
- pause audio;
- flush SRAM;
- flush 64DD sidecar later;
- persist configuration;
- reduce/stop presentation work.

On resume:

- reacquire input/controller state;
- restore audio;
- resume rendering/simulation cleanly.

Apple reference:

- [`sceneWillResignActive`](https://developer.apple.com/documentation/uikit/uiscenedelegate/scenewillresignactive(_:))

Start with SDL application lifecycle events if they are sufficient for the runtime. Add a small Objective-C++ native bridge only where necessary.

---

# 14. High-refresh / ProMotion

This is one of the reasons the project is worth doing.

G-Diffuser already has frame interpolation in which the simulation remains at its intended ~60 Hz while rendering can produce intermediate frames at a higher presentation rate.

That is an excellent match for 120 Hz iPad Pro and iPhone Pro displays.

### Do not make it a first-boot requirement

First target:

> correct 60 Hz simulation + correct 60 Hz presentation.

Then add Apple-aware high-refresh presentation.

Relevant Apple APIs include:

- [`UIScreen.maximumFramesPerSecond`](https://developer.apple.com/documentation/uikit/uiscreen/maximumframespersecond)
- [`CAMetalDisplayLink.preferredFrameRateRange`](https://developer.apple.com/documentation/quartzcore/cametaldisplaylink/preferredframeraterange)

### Recommended behavior

Settings:

```text
Frame rate
  - 60 Hz
  - Match Display
  - 120 Hz (when supported)
```

The simulation remains fixed.

The renderer interpolation layer supplies the extra visual frames.

### Important implementation point

Do not copy G-Diffuser's Windows monitor-refresh probing into Apple code.

Use the Apple display/presentation APIs, and respect:

- Low Power Mode;
- thermal/system constraints;
- supported refresh ranges.

A Metal game does not automatically become a correctly paced 120 Hz game just because the panel supports 120 Hz.

---

# 15. 64DD Expansion Kit strategy

G-Diffuser's full 64DD support is a major advantage, but it should **not** be part of first Apple bring-up.

The build already exposes:

```cmake
GDX_EXPANSION_KIT=OFF
```

Use it.

### Initial Apple target

Cartridge-only:

```text
F-Zero X US rev0
Metal
audio
controller
save
```

### Restore 64DD after the base iOS architecture is stable

Then add:

- Expansion Kit disk import;
- IPL import;
- managed copies;
- `.o2r` generation/internalization;
- disk save sidecar;
- Course Edit;
- Create Machine;
- DD cups;
- ghost/content import/export.

### Why defer it

64DD multiplies the platform surface:

- three user-owned input media types;
- extra extraction stages;
- persistent writable disk behavior;
- additional UI;
- more file import/export;
- more save-state/lifecycle requirements.

None of that helps prove Metal or ARM64 correctness.

---

# 16. Legal/distribution model

The port should preserve G-Diffuser's current ROM-free model.

### Ship

- source code;
- MIT/CC0-compatible project material;
- engine shaders/resources that G-Diffuser already ships lawfully;
- application UI;
- extraction recipes;
- license notices.

### Do not ship

- the F-Zero X ROM;
- Nintendo-owned extracted game assets;
- a generated `fzerox.o2r` containing Nintendo assets;
- 64DD disk images;
- 64DD IPL dumps.

The user supplies their own source media, and the application generates its private derived archive locally.

Relevant licensing in the current dependency chain:

- G-Diffuser: MIT;
- Torch: MIT;
- libultraship: MIT;
- current `Zorkats/fzerox` repository: CC0;
- game assets remain a separate copyrighted matter.

The App Store/trademark/distribution question is separate from technical feasibility and should not be allowed to block the engineering proof.

For the first project milestone, target local developer signing/sideloading and a clean ROM-free public repository.

---

# 17. Recommended fork/upstream strategy

Because G-Diffuser is moving quickly, avoid turning the Apple port into an unmergeable fork.

### Fork these immediately

1. `Zorkats/G-Diffuser`
2. `Zorkats/libultraship`

Fork Torch only when needed.

### Git topology

```text
origin   → your G-Diffuser fork
upstream → Zorkats/G-Diffuser

submodule libultraship
    → your libultraship fork pinned to exact SHA
```

### Development branch

Use one obvious long-lived integration branch at first:

```text
apple-platform
```

Do not split macOS and iOS into unrelated forks.

### Principle

Apple fixes should be:

1. generic upstream fixes where possible;
2. platform abstractions in libultraship where appropriate;
3. G-Diffuser-specific behavior in `port/`;
4. decomp changes only when absolutely necessary.

### Avoid

- building a parallel Apple runtime beside G-Diffuser;
- copying the decomp into a new tree;
- rewriting Fast3D;
- replacing the entire SDL layer before first boot;
- deep edits throughout game code.

---

# 18. Recommended milestone plan

## Phase 0 — Freeze a reproducible baseline

Goal: know exactly what was forked.

- Fork G-Diffuser.
- Fork G-Diffuser's libultraship.
- Record upstream G-Diffuser commit SHA.
- Record all submodule SHAs.
- Confirm current desktop source builds before large structural changes.
- Add an `APPLE_PORT_STATUS.md` or equivalent internal ledger.
- Keep upstream remote configured from day one.

**Exit condition:** a known baseline commit and reproducible non-Apple build.

---

## Phase 1 — macOS ARM64 compile/link cleanup

Start with:

```text
GDX_EXPANSION_KIT=OFF
```

Tasks:

- define explicit macOS/iOS/Linux platform macros;
- make Linux RPATH Linux-only;
- make GNU version-script flag Linux-only;
- fix platform source filters;
- fix macOS/iOS fullscreen conditionals;
- fix Apple audio conditionals;
- ensure Metal backend is first/default on Apple;
- remove invalid iOS OpenGL registration;
- use Apple bundle/path helpers where needed;
- get the entire target compiling with AppleClang ARM64.

**Exit condition:** G-Diffuser links as a macOS ARM64 executable/app using its current source tree.

---

## Phase 2 — First macOS Metal race

Do not work on polished first-boot UX yet.

Tasks:

- initialize Fast3D Metal;
- mount `gdiffuser.o2r`;
- use cartridge-only mode;
- point a development build at a local legal US rev0 ROM;
- validate scheduler;
- validate asset pointer/address behavior under Apple ARM64;
- reach title;
- enter race;
- verify rendering;
- verify controller;
- verify audio;
- verify save.

**Exit condition:** a complete race is playable natively on Apple Silicon through Metal.

This is the most important proof in the project.

---

## Phase 3 — Clean macOS application behavior

Once gameplay works:

- Apple Application Support paths;
- proper `.app`;
- Finder-friendly first boot;
- native/file-picker ROM import;
- config/save paths;
- deterministic extraction;
- cleanup of desktop-only assumptions;
- packaging and signing.

**Exit condition:** macOS version behaves like an actual application, not a developer executable.

---

## Phase 4 — iPadOS/iOS compile target

Clone the successful ARM64/Metal logic, but now solve mobile platform constraints.

Tasks:

- iOS app bundle patterned after Ghostship;
- SDL/Metal window;
- landscape orientation;
- no macOS fullscreen calls;
- SDL audio;
- disable desktop-only subsystems;
- Application Support paths;
- lifecycle hooks;
- physical controller path;
- fiber smoke test on real device.

For the first run, use raw-ROM fallback or a development-installed archive if necessary.

**Exit condition:** title/race boots on a real iPad with Metal + physical controller.

---

## Phase 5 — In-process Torch extraction

Tasks:

- make Torch static for iOS;
- build only F-Zero-relevant factories where possible;
- factor shared extraction routine out of Torch CLI path;
- create `InProcessTorchExtractor`;
- document picker import;
- read/import ROM;
- verify expected ROM identity;
- generate `fzerox.o2r` in temporary storage;
- validate;
- atomically install to Application Support;
- boot without external developer-prepared files.

**Exit condition:** clean installation can turn a user-selected ROM into a playable local install entirely on-device.

---

## Phase 6 — Touch controls

Tasks:

- build transparent game overlay;
- feed existing N64 input seam;
- analog steering;
- driving/action buttons;
- safe-area-aware iPad layout;
- simultaneous multi-touch;
- reset controls on interruption;
- configurable opacity later;
- controller detection may hide/reduce overlay.

**Exit condition:** full single-player game is usable without a physical controller.

---

## Phase 7 — ProMotion / high-refresh

Tasks:

- keep simulation fixed at 60;
- discover Apple maximum/current supported frame rate;
- integrate display-link timing or verify SDL/Metal presentation path at 120;
- connect to G-Diffuser's existing interpolation;
- test 60/120 switching;
- test Low Power Mode;
- test frame pacing and audio stability.

**Exit condition:** 120 Hz-capable devices visibly present interpolated high-refresh output without speeding up the game.

---

## Phase 8 — Restore 64DD

Re-enable:

```text
GDX_EXPANSION_KIT=ON
```

Then:

- document-picker support for disk and IPL;
- in-process archive generation where required;
- managed writable media;
- sidecar persistence;
- Course Edit;
- Create Machine;
- DD cups;
- save/restore across backgrounding.

**Exit condition:** feature parity with desktop G-Diffuser's 64DD path.

---

## Phase 9 — iPhone and release polish

- smaller touch layout;
- dynamic safe areas;
- device rotation policy;
- haptics;
- external display behavior;
- UI scaling;
- import/export UX;
- diagnostics;
- CI;
- unsigned/signed development artifacts as appropriate;
- README/docs.

---

# 19. Must solve before first playable vs. defer

## Must solve for first macOS Metal proof

- AppleClang compile/link;
- Linux-only linker flags fixed;
- Metal backend selection;
- Apple audio conditional;
- macOS path handling sufficient to boot;
- fiber/scheduler works;
- input bridge works;
- raw ROM/assets load;
- no critical ARM64 pointer-resolution faults.

## Must solve for first iPad proof

Everything above plus:

- iOS app bundle;
- iOS fullscreen conditional;
- iOS audio path;
- writable Application Support;
- real-device fiber validation;
- physical controller;
- basic lifecycle.

## Can defer

- polished touch overlay;
- 64DD;
- 120 Hz;
- Discord Rich Presence;
- sophisticated mod browser;
- native replacement for ImGui settings;
- perfect first-boot UX;
- App Store submission;
- iPhone-specific layout;
- multiplayer UI polish.

---

# 20. Risk register

| Risk | Severity | Why | Response |
|---|---|---|---|
| Metal renderer | Low–medium | already implemented in pinned libultraship | integrate, do not rewrite |
| macOS CMake/linking | Medium | current Linux assumptions leak into non-Windows path | platform-gate build flags |
| iOS libultraship leakage | Medium | concrete audio/fullscreen/backend issues found | fix before app bring-up |
| fiber scheduler on Apple ARM64 | **High unknown** | low-level context API/ABI dependency | dedicated smoke test; Apple backend if required |
| pointer/address reconstruction | Medium | G-Diffuser performs unusual 32/64-bit host translation | enable diagnostics on ARM64 |
| iOS extraction | Medium | current child-process model cannot be copied directly | embed existing Torch static library |
| filesystem/import | Low–medium | standard Apple sandbox problem | App Support + document picker |
| iOS audio | Low with SDL | current CoreAudio conditional is wrong | use SDL first |
| touch | Medium | UX work, not game architecture | feed existing input bridge |
| ProMotion | Medium | pacing/presentation work | do after stable 60 Hz |
| 64DD | Medium–high | adds file + persistence complexity | defer until base port |
| upstream drift | Medium | G-Diffuser is new and changing quickly | small patches, pinned submodules, frequent upstream sync |

---

# 21. First technical spike: exact recommended task order

This is the order I would hand to an implementation agent.

### Repository setup

1. Fork `Zorkats/G-Diffuser`.
2. Fork `Zorkats/libultraship`.
3. Clone recursively.
4. Add `upstream` remotes.
5. Record exact SHAs.
6. Create `apple-platform`.
7. Set `GDX_EXPANSION_KIT=OFF`.

### Build cleanup

8. Add `GDX_PLATFORM_MACOS` / `GDX_PLATFORM_IOS` / `GDX_PLATFORM_LINUX`.
9. Gate `$ORIGIN` to Linux.
10. Gate GNU version script to Linux.
11. Fix stale renderer-source filters.
12. Fix iOS/macOS fullscreen macro split.
13. Fix iOS audio selection: SDL first.
14. Remove OpenGL from iOS available renderer list.
15. Confirm Metal is default Apple renderer.

### Scheduler proof

16. Add `gdx_fiber_smoketest`.
17. Run it on macOS ARM64.
18. If successful, keep `ucontext`.
19. If unsuccessful, implement Apple ARM64 backend behind `gdx_fiber.h`.

### First runtime proof

20. Build macOS ARM64.
21. Mount engine `.o2r`.
22. Use a legal US rev0 ROM in development path.
23. Boot.
24. Reach title.
25. Start race.
26. Validate textures/geometry/HUD.
27. Validate audio.
28. Validate controller.
29. Validate save.
30. Run repeated races/track transitions.

### iOS proof

31. Add iOS app bundle using Ghostship's CMake shape.
32. Bundle immutable engine resources.
33. Resolve Application Support paths.
34. Disable desktop-only helpers.
35. Build for a real iPad.
36. Run fiber test on device.
37. Boot cartridge-only G-Diffuser.
38. Validate Metal/controller/audio/lifecycle.

### Productize import

39. Add document picker.
40. Build Torch static for iOS.
41. Extract shared F-Zero processing function from Torch CLI path.
42. Implement in-process extraction.
43. Generate/validate/install `fzerox.o2r`.
44. Remove any development-only ROM-path assumptions.

Only then move to touch/120 Hz/64DD.

---

# 22. Definition of done

## Proof A — macOS native

A real Apple Silicon Mac can:

- launch G-Diffuser as ARM64;
- use Metal;
- load a user-owned F-Zero X ROM;
- reach a race;
- render correctly;
- play audio;
- accept controller input;
- save and reload.

No emulator is running.

## Proof B — iPad native

A real iPad can:

- launch a signed/sideloaded G-Diffuser app;
- render through Metal;
- run at correct 60 Hz;
- accept a physical controller;
- play audio;
- suspend/resume safely;
- persist a save.

## Apple v0.1

- macOS + iPadOS/iOS targets;
- ROM-free public source tree;
- document-picker ROM import;
- local on-device extraction;
- persistent save;
- controller;
- touch overlay;
- Metal;
- 60 Hz correctness;
- optional high-refresh interpolation.

## Apple feature-complete target

- 64DD Expansion Kit;
- Course Edit;
- disk saves;
- DD cups;
- texture packs/modding parity where platform-appropriate;
- controller and touch;
- high-refresh;
- iPhone/iPad/macOS packaging;
- maintained upstream sync.

---

# 23. What not to do

The fastest way to make this project take too long is to "clean up" things that are already solved.

Do **not**:

- start a fresh F-Zero X Apple engine;
- port directly from raw `inspectredc/fzerox` and discard G-Diffuser;
- replace Fast3D;
- rewrite the renderer in bespoke Metal;
- rewrite audio before SDL proves insufficient;
- solve 64DD before cartridge gameplay;
- build touch controls before physical-controller gameplay;
- build App Store packaging before the app works;
- fork all four submodules unnecessarily;
- spread Apple conditionals throughout decompiled game code.

The port should look like G-Diffuser gained Apple platforms, not like G-Diffuser was cannibalized to create a different project.

---

# 24. Recommended project statement

A useful internal definition is:

> **G-Diffuser Apple is a first-class macOS, iPadOS and iOS target for the existing G-Diffuser native F-Zero X source port. It preserves G-Diffuser's decompilation-based architecture and enhancement layer, uses libultraship/Fast3D's Metal backend, requires users to provide their own legally obtained game media, and performs any game-asset extraction locally. Apple platform code should remain isolated from the matching decompilation wherever possible.**

That statement is narrow enough to prevent scope drift.

---

# 25. Source map

## G-Diffuser

- [G-Diffuser repository](https://github.com/Zorkats/G-Diffuser)
- [G-Diffuser v1.0.1](https://github.com/Zorkats/G-Diffuser/releases/tag/v1.0.1)
- [Issue #8 — macOS build instructions?](https://github.com/Zorkats/G-Diffuser/issues/8)
- [Architecture](https://github.com/Zorkats/G-Diffuser/blob/main/docs/ARCHITECTURE.md)
- [Top-level CMake](https://github.com/Zorkats/G-Diffuser/blob/main/CMakeLists.txt)
- [Port CMake](https://github.com/Zorkats/G-Diffuser/blob/main/port/CMakeLists.txt)
- [First-boot implementation](https://github.com/Zorkats/G-Diffuser/blob/main/port/gdx_firstboot.cpp)
- [Extraction launcher](https://github.com/Zorkats/G-Diffuser/blob/main/port/gdx_extract_launch.cpp)
- [POSIX fiber backend](https://github.com/Zorkats/G-Diffuser/blob/main/port/gdx_fiber_ucontext.c)
- [Input bridge](https://github.com/Zorkats/G-Diffuser/blob/main/port/input_bridge.c)
- [Main runtime](https://github.com/Zorkats/G-Diffuser/blob/main/port/main.cpp)

## libultraship

- [Zorkats/libultraship](https://github.com/Zorkats/libultraship)
- [libultraship CMake](https://github.com/Zorkats/libultraship/blob/main/CMakeLists.txt)
- [iOS dependencies](https://github.com/Zorkats/libultraship/blob/main/cmake/dependencies/ios.cmake)
- [macOS dependencies](https://github.com/Zorkats/libultraship/blob/main/cmake/dependencies/mac.cmake)
- [Fast3dWindow](https://github.com/Zorkats/libultraship/blob/main/src/fast/Fast3dWindow.cpp)
- [Fast3dGui](https://github.com/Zorkats/libultraship/blob/main/src/fast/Fast3dGui.cpp)
- [SDL window backend](https://github.com/Zorkats/libultraship/blob/main/src/fast/backends/gfx_sdl2.cpp)
- [Metal renderer](https://github.com/Zorkats/libultraship/blob/main/src/fast/backends/gfx_metal.cpp)
- [Audio selection](https://github.com/Zorkats/libultraship/blob/main/src/ship/audio/Audio.cpp)
- [Ship CMake](https://github.com/Zorkats/libultraship/blob/main/src/ship/CMakeLists.txt)
- [AppleFolderManager](https://github.com/Zorkats/libultraship/blob/main/src/ship/utils/AppleFolderManager.mm)

## Torch

- [Zorkats/Torch](https://github.com/Zorkats/Torch)
- [Torch CMake / static-library option](https://github.com/Zorkats/Torch/blob/main/CMakeLists.txt)
- [Companion API](https://github.com/Zorkats/Torch/blob/main/src/Companion.h)

## Existing iOS pattern

- [HarbourMasters/Ghostship](https://github.com/HarbourMasters/Ghostship)
- [Ghostship iOS CMake pattern](https://github.com/HarbourMasters/Ghostship/blob/develop/CMakeLists.txt)
- [Ghostship iOS plist](https://github.com/HarbourMasters/Ghostship/blob/develop/ios/plist.in)

## Apple platform references

- [UIDocumentPickerViewController](https://developer.apple.com/documentation/uikit/uidocumentpickerviewcontroller)
- [Game Controller](https://developer.apple.com/documentation/gamecontroller)
- [Virtual game controls](https://developer.apple.com/documentation/gamecontroller/adding-virtual-controls-to-games-that-support-game-controllers-in-ios)
- [UIScreen maximumFramesPerSecond](https://developer.apple.com/documentation/uikit/uiscreen/maximumframespersecond)
- [CAMetalDisplayLink preferredFrameRateRange](https://developer.apple.com/documentation/quartzcore/cametaldisplaylink/preferredframeraterange)
- [UISceneDelegate sceneWillResignActive](https://developer.apple.com/documentation/uikit/uiscenedelegate/scenewillresignactive(_:))

---

# Final recommendation

**Proceed.**

Fork G-Diffuser now and treat the project as an upstream-compatible Apple platform bring-up.

The first objective should not be "F-Zero X on iPhone with touch." It should be much narrower:

> **G-Diffuser, cartridge-only, on Apple Silicon macOS, running a complete race through the existing Fast3D Metal backend.**

That milestone isolates the true low-level questions:

- Does the current host port survive Apple ARM64?
- Does the fiber scheduler work?
- Are the pointer/address bridges sound?
- Does the existing Metal backend render F-Zero X correctly?
- Does audio/input work after the platform-condition fixes?

Once that succeeds, iPadOS becomes an application-platform problem rather than a game-port problem.

The second objective is:

> **The same G-Diffuser runtime on a real iPad, Metal + SDL audio + physical controller, before touch and before 64DD.**

Then solve on-device Torch extraction, touch controls, ProMotion, and finally 64DD.

The source tree already contains more of the Apple port than the current Windows/Linux-only release suggests. The work is real, but it is bounded—and the highest-value first move is to exploit what is already there rather than rebuild it.
