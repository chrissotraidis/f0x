# Known issues

## F0X-specific

No F0X build has run yet, so no F0X runtime issue has been established.

## Baseline risks requiring proof

- Apple ARM64 correctness of the current `ucontext` fiber backend is unknown.
- The linker reduced one oversized common-data alignment from 0x8000 to 0x4000; this is a warning until runtime pointer/address validation proves otherwise.
- Current G-Diffuser public documentation and platform matrix are Windows/Linux
  only; Apple link and runtime assumptions must be tested against `719fd82`.
- Current mobile extraction cannot retain the desktop child-process model.
- The local development ROM is `.v64`; the pinned runtime's documented direct
  input is `.z64`, so conversion/validation behavior needs a safe, explicit
  implementation rather than an assumption.
