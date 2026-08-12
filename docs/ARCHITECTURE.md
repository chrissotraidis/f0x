# Architecture

```text
User-owned F-Zero X US rev0 ROM
        ↓ local SHA-1/profile validation
Torch extraction (in process on iOS; optional in process on macOS)
        ↓ validated, atomically installed private fzerox.o2r
G-Diffuser native host runtime + matching decompilation
        ↓ N64 controller/audio/graphics seams
libultraship / Fast3D
        ↓
Metal
        ↓
F0X on macOS, iPadOS, and iOS
```

The pinned upstream supplies the host scheduler, controller bridge, audio
bridge, ROM/resource layer, and Fast3D renderer selection. F0X makes those
capabilities first-class Apple targets; it does not replace them with a new
engine or an emulator frontend.

## Product and data boundaries

- Immutable app resources live in the app bundle.
- macOS mutable state lives under `~/Library/Application Support/F0X`.
- iOS/iPadOS mutable state lives in the app's Files-visible Documents sandbox.
- ROM-derived `fzerox.o2r`, SRAM, ghosts, configuration, logs, and staging data
  are private runtime state and never source/package inputs.
- Desktop may use the signed `gdx-extract` helper or the in-process Torch API.
  iOS must use in-process Torch and never `fork`/`exec`.
- Archive output is validated before atomic activation; a failed import must
  preserve the previous valid archive.

## Input boundary

All gameplay input converges on one host seam:

```text
keyboard / mouse / physical controller       UIKit touch overlay
                    \                         /
                     libultraship pad state
                              ↓
                  port/input_bridge.c
                              ↓
          decomp Controller structures and edge state
                              ↓
                       F-Zero X logic
```

Touch must merge into port 1 immediately after `gdx_lus_read_pads()` and before
developer-script overrides. Buttons are OR-merged with live input. Touch analog
overrides the port-1 stick only while the touch stick is engaged. The existing
`gdx_update_port_inputs()` remains the sole owner of pressed/released edges,
digital-stick thresholds, repeats, and game-frame alignment. No touch handling
belongs in decompiled F-Zero X source.

See [`TOUCH_CONTROLS_IMPLEMENTATION.md`](TOUCH_CONTROLS_IMPLEMENTATION.md) for
the complete contract.
