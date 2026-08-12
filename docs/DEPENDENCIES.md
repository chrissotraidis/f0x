# Pinned dependencies

Baseline captured 2026-08-11. `ref/` is local-only and ignored.

| Role | Repository | Pinned SHA | License | F0X modification |
| --- | --- | --- | --- | --- |
| Runtime foundation | `Zorkats/G-Diffuser` | `719fd82a3af605b064fb53ad6eecb020090b4c5d` | MIT | `patches/gdiffuser-apple-macos.patch`, `patches/gdiffuser-fiber-smoketest.patch` |
| Fast3D/runtime submodule | `Zorkats/libultraship` | `a4919b181e637193f2b8ae975e31505abbf99e71` | MIT | `patches/libultraship-apple-metal.patch` |
| Extraction submodule | `Zorkats/Torch` | `c1bdc6fde97fbaa4495c9e859f635290840a12d3` | MIT | `patches/torch-inprocess-apple.patch` |
| F-Zero X matching decomp | `Zorkats/fzerox` | `f7fd0fd0242f8dfb5f357f604bb73b6a4e990809` | CC0-1.0 | `patches/fzerox-decomp-apple.patch` |
| Expansion Kit reference | `Zorkats/fzerox-expansion-kit` | `6cd71e6fff1714fbfbda22d61dc8bce190d9632d` | CC0-1.0 | None yet |
| Apple product benchmark | `chrissotraidis/harkinianpad` | `1197472956cd2c4dd3f03fb6fe5f2dfb28d30ad7` | See its repository | Read-only reference |

The G-Diffuser clone was initialized recursively. Its nested submodule SHAs are
retained by the upstream superproject. Source checkouts under `ref/` are ignored
and disposable; all F0X-owned changes must remain reproducible from the tracked
patch series. `scripts/apply-apple-baseline-patches.sh` applies the current
series idempotently.
