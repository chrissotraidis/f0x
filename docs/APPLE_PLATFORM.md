# Apple platform status

Apple support is planned, not yet implemented in F0X. The pinned
libultraship source contains a Metal backend and platform machinery, but that
is source inspection—not an Apple build or gameplay result.

The first target is Apple Silicon macOS in cartridge-only mode. iOS/iPadOS
work follows the macOS Metal and fiber proof, then requires a real ARM64 iPad
controller test before touch investment. macOS-specific fullscreen and audio
behavior must never be assumed valid on iOS.
