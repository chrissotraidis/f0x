# Building F0X

No F0X Apple build exists yet. The first reproducibility probe uses the
locally pinned G-Diffuser source in `ref/G-Diffuser` and intentionally starts
cartridge-only:

```sh
cmake -S ref/G-Diffuser -B build/macos-baseline -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug -DGDX_EXPANSION_KIT=OFF
cmake --build build/macos-baseline --target G-Diffuser
```

These commands are a pending baseline experiment, not a verified build recipe.
They must not read, bundle, or copy a ROM. Device builds will require the
owner's Apple signing configuration and will be documented only after they
exist.
