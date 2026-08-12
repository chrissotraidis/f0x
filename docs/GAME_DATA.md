# Game data

F0X does not distribute F-Zero X, Nintendo assets, Expansion Kit media, save
files, or generated archives. A user-owned ROM may exist only in ignored local
storage or an installed app container.

## Supported cartridge input

| Property | Current accepted value |
| --- | --- |
| Game | F-Zero X |
| Region/revision | US revision 0 |
| Byte order | Big-endian `.z64` |
| Size | 16 MiB (`16,777,216` bytes) |
| SHA-1 | `5f658e88ffa9de23cba6986a8fd3d3a90d7b4340` |
| Generated archive | `fzerox.o2r`, 3,610 unique records |
| Verified archive SHA-256 | `7d60d975bdbce24ba544c6ed3cc3a06f365cfe88e6a8096b5a6d63940513181a` |

`.v64` and `.n64` byte-swapped inputs are not currently advertised. Add them
only with explicit conversion, identity validation, negative tests, and updated
product copy.

## Verified flow

On iPad Simulator, one uninterrupted live process performed:

```text
Choose ROM…
  → native Files picker
  → select authorized US-rev0 .z64
  → copy to the app sandbox as baserom.us.rev0.z64
  → validate SHA-1/profile
  → explicit Build game data and continue
  → in-process Torch (no fork/exec)
  → validate 3,610-record archive
  → atomic activation and hot mount
  → visible live GP race
```

Archive-only relaunch without the ROM is separately verified. Removal/reimport
must never silently delete SRAM, ghosts, or configuration. The same workflow
still needs physical-device acceptance and failure-path testing under storage
pressure, cancellation, interruption, and invalid inputs.
