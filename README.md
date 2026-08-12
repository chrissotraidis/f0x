# F0X

F0X is an in-progress native Apple port of **F-Zero X** built on
[G-Diffuser](https://github.com/Zorkats/G-Diffuser). It runs the decompiled
game logic as native host code and renders through libultraship/Fast3D's Metal
backend. It is not a generic N64 emulator frontend.

F0X never includes F-Zero X, a ROM, extracted Nintendo assets, saves, or a
ROM-derived archive. The current product validates a user-owned US revision 0
big-endian `.z64` locally and creates its private resource archive on the
device. Nothing is uploaded.

## Current status

| Area | Evidence-backed status |
| --- | --- |
| Apple Silicon macOS | Native arm64 `F0X.app` builds, seals, launches, shows F0X Home, imports game data, and renders a live Metal race |
| iPad Simulator | Native arm64 app launches, uses the Files picker, performs in-process extraction, and reaches a visible live race |
| iPhoneOS | Complete arm64 app compiles and passes a ROM-free unsigned payload audit; no physical-device run yet |
| Metal stability | Current bundle passed dense race and Finder/Home capture tests; owner confirmation of the previously reported flashing remains open |
| Saves | A real 32 KiB settings-SRAM write, relaunch, load, and exact reversal are verified on macOS |
| Audio | Cartridge synthesis produces nonzero PCM; audible speaker/headphone delivery is not verified |
| Touch controls | Implemented; core Simulator-verified. The UIKit overlay writes direct N64 pad state merged at the port-1 seam, with settings, auto-hide, opacity, haptics, permanent menu access, and an editor. Simulator evidence covers the full control set, menu open/close with overlay hiding, controller auto-hide, and a touch-driven GP flow to a live race; physical-device acceptance remains open |
| Physical controller/device | Not verified on iPhone or iPad; this Mac currently has no connected device or signing identity |
| Timing/high refresh | Not measured or accepted |
| Expansion Kit | Deferred; current builds are cartridge-only |

The visible Simulator picker-to-race run and the unsigned iPhoneOS compile are
not physical-device acceptance. Likewise, scripted entry into a race is not a
player-completed race.

## Architecture

```text
Your supported F-Zero X ROM
        ↓ local validation and Torch preparation
G-Diffuser native F-Zero X runtime
        ↓
libultraship / Fast3D
        ↓
Metal
        ↓
F0X on macOS, iPhone, and iPad
```

The active engineering checkpoint, exact open gates, and evidence boundaries
are in [`docs/STATUS.md`](docs/STATUS.md). Builders should start with
[`docs/NEXT_BUILDER.md`](docs/NEXT_BUILDER.md), then use
[`docs/TOUCH_CONTROLS_IMPLEMENTATION.md`](docs/TOUCH_CONTROLS_IMPLEMENTATION.md)
for the F-Zero-specific touch work. The paste-ready autonomous loop is
[`docs/BUILDER_GOAL_LOOP.md`](docs/BUILDER_GOAL_LOOP.md).

## Repository map

- `docs/STATUS.md` — canonical evidence and gate ledger
- `docs/NEXT_BUILDER.md` — exact ordered continuation plan
- `docs/TOUCH_CONTROLS_IMPLEMENTATION.md` — input mappings, reference mapping,
  file-by-file design, and touch acceptance tests
- `docs/TESTING.md` — dated engineering evidence
- `docs/KNOWN_ISSUES.md` — open defects and boundaries
- `docs/BUILDING.md` — current macOS, Simulator, and unsigned-device recipes
- `docs/GAME_DATA.md` — supported input and private-data lifecycle
- `patches/` — maintained changes applied to ignored pinned sources
- `ref/README.md` — ignored reference/source policy

## Legal boundary

F0X is an unofficial community integration. Nintendo game data is neither
distributed nor licensed by this repository. See
[`docs/LEGAL_AND_PROVENANCE.md`](docs/LEGAL_AND_PROVENANCE.md).
