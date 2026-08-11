# Architecture

```text
User-owned supported F-Zero X ROM
        ↓ local validation and preparation
G-Diffuser native host runtime + matching decompilation
        ↓
libultraship / Fast3D
        ↓
Metal
        ↓
F0X on macOS, iPadOS, and iOS
```

The pinned upstream already supplies the host scheduler, controller bridge,
audio bridge, ROM/resource layer, and Fast3D renderer selection. F0X's job is
to make those capabilities first-class Apple targets—not to rewrite them.

Current desktop extraction is an external `gdx-extract` child process. The
final iOS design must retain its validated Torch processing logic while moving
it in process, with temporary output and atomic activation.
