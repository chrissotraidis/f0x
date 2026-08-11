# Game data

F0X does not distribute F-Zero X, Nintendo assets, Expansion Kit media, save
files, or generated archives. The local `ref/` area may contain a user-owned
ROM for private engineering work but is ignored and prohibited from commits
and packages.

The pinned runtime currently accepts the US rev0 cartridge profile and its
public documentation requires a big-endian `.z64` dump; its raw loader does
not byte-swap `.v64`/`.n64` inputs. F0X must verify the exact profile constants
and implement safe conversion/import behavior before exposing a user flow.

The eventual product flow is: Files selection → validate → private staging →
local Torch preparation → validate output → atomic activation. Removing game
data must not remove independent saves or ghosts.
