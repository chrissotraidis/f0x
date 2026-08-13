# Paste-ready F0X builder goal loop

Copy everything inside the block into the next builder as its goal.

```text
You are the continuation builder for F0X in:

  /Users/chrissotraidis/GitHub/f0x

MISSION

Finish F0X through the original master implementation objective: a polished,
ROM-free native Apple F-Zero X product based on G-Diffuser, native decompiled
game logic, libultraship/Fast3D, and Metal for Apple Silicon macOS, iPhone, and
iPad. Do not replace it with an emulator, another engine, or a bespoke renderer.
Continue until every applicable base completion condition is proven or a genuine
fundamental blocker is rigorously demonstrated.

MANDATORY READ-FIRST ORDER

Before changing source or accepting any inherited claim, read these files fully:

1. README.md
2. docs/STATUS.md
3. docs/NEXT_BUILDER.md
4. docs/TOUCH_CONTROLS_IMPLEMENTATION.md
5. docs/TESTING.md
6. docs/KNOWN_ISSUES.md
7. docs/IMPLEMENTATION_PLAN.md
8. docs/ARCHITECTURE.md
9. docs/BUILDING.md
10. docs/GAME_DATA.md
11. docs/APPLE_PLATFORM.md
12. docs/PERFORMANCE.md
13. docs/LEGAL_AND_PROVENANCE.md
14. docs/G-Diffuser_Apple_Port_Research_Plan.md
15. the supplied original F0X master goal, if attached

Also read the pinned HarkinianPad touch references named by
docs/TOUCH_CONTROLS_IMPLEMENTATION.md before implementing touch. Inspect the
actual current checkout, `git status`, HEAD, maintained patches, pinned SHAs,
device/signing state, Simulator state, and relevant build artifacts. Treat paths,
PIDs, bundle UUIDs, device availability, signing, and prior logs as potentially
stale until cheaply reverified.

CANONICAL CURRENT TRUTH

- The native macOS/Metal/fiber/app/import foundation is real and evidenced.
- iPad Simulator Files import, in-process extraction, archive hot mount, and a
  visible race are real and evidenced, including one uninterrupted picker-to-race
  process.
- An unsigned arm64 iPhoneOS app compiles and passes a ROM-free payload audit.
- Gameplay touch controls and their menu options ARE implemented and
  Simulator-verified (phone and tablet) — but the owner reports the controls
  and menu LOOK different from the HarkinianPad reference they asked to copy,
  so visual parity work is the highest-priority touch item
  (IOS-TOUCH-VISUAL-01).
- iOS/iPadOS launches are currently SILENT: the Apple auto audio backend
  resolves to the macOS-only CoreAudio player, falling through to the Null
  player on iOS (IOS-AUDIO-01; fix drafted in the working tree, uncommitted).
- A live iPhone 17 Pro Simulator race crashed in the display-list bridge
  (`gConvertedWideIsF3d.find()` at n64_gfx_bridge.cpp:5155, IOS-GFX-CRASH-01);
  reproduction/instrumentation is the next step.
- Physical iPad/iPhone signing, install, controller, touch, lifecycle, audible
  audio, performance, and thermal acceptance remain open.
- A player-completed macOS race remains open.
- The current-bundle automated flashing regressions pass, but owner confirmation
  of the previously reported rapid flashing remains open.
- 60 Hz correctness, high refresh, release hardening, final public documentation,
  and Expansion Kit remain open.

NON-NEGOTIABLE BOUNDARIES

- Preserve F-Zero X decomp -> G-Diffuser -> libultraship/Fast3D -> Metal.
- Keep game-specific Apple work concentrated in G-Diffuser port/product seams.
- Never commit or package ROMs, Nintendo assets, fzerox.o2r, disk/IPL images,
  saves, ghosts, provisioning profiles, certificates, keys, credentials, or
  private diagnostic contents.
- HarkinianPad is a behavioral/product reference, not F0X's engine. Adapt its
  proven UIKit/layout/editor/lifecycle patterns; do not blindly apply its Zelda
  patches or synthesize keyboard input when F0X has a direct N64 pad seam.
- Use one runtime executable and one booted Simulator for a validation run.
- Compilation is not runtime proof. Simulator is not physical-device proof.
  Scripted race entry is not player acceptance. File existence is not load/use
  proof.
- Preserve unrelated user changes. Use small falsifiable changes and recheck
  button/menu wiring after every change.

HIGHEST-PRIORITY LOCAL WORK

The touch system's behavior is implemented and Simulator-verified; the
remaining LOCAL gates, in order:

1. TOUCH/MENU VISUAL PARITY (owner priority): render F0X's overlay on the iPad
   and iPhone 17 Pro Simulators, render the pinned HarkinianPad reference
   overlay side by side, and close every visible difference (button
   shape/pill vs circle, colors/alpha, sizes, spacing, labels, fonts, stick
   look, the ••• slot, the Settings -> Controls -> Touch Controls page, and
   the editor chrome). Do not trust the geometry tables alone; prove it
   pixel-by-pixel with before/after captures. Keep the 87-check merge tests
   green.
2. IOS AUDIO: build and verify the working-tree fix (auto -> SDL on iOS) on
   the Simulator, compare how the reference/upstream selects the iOS backend,
   and commit it with the diagnostics wiring as one unit.
3. IOS-GFX-CRASH-01: reproduce with guard malloc, find the clobbering write or
   lifetime/thread bug, add the smallest regression, fix, and re-run.
4. FINISH the in-game/iOS Share Diagnostic Log (the Settings -> General
   button, runtime collector, and error-tail ring are drafted uncommitted;
   exercise the macOS menu trigger and the iOS share sheet).
5. Then the remaining queue below (physical acceptance, representative-course
   60 Hz, high refresh, packaging, README, Expansion Kit).

Do this in coherent slices. After each slice, build and test the smallest affected
artifact before extending it, and recheck the touch/menu wiring after every change.

CONTINUATION QUEUE AFTER TOUCH

1. Obtain owner confirmation on the exact corrected macOS F0X.app flashing
   behavior; if flashing remains, capture a human-visible video and correlate it
   with the present path rather than relying only on automated luma checks.
2. Complete real macOS races with sustained mapped input and verify every core
   action, results, repeated races, representative courses, audio, and persistence.
3. On signing-capable hardware, run physical iPad controller-first engine proof:
   sign/install, device fiber test, Files import/extraction, full race, Metal,
   audible audio, lifecycle, save/reload, reconnect, memory, thermals, and soak.
4. Run physical touch-only acceptance on iPad and iPhone, true concurrent contact
   stress, controller handoff, editor ergonomics, safe areas, interruptions, audio,
   saves, thermals, and long sessions.
5. Finish and test Share Diagnostic Log with useful system/runtime state and
   strict privacy exclusions (the macOS Home action is verified; the in-game
   entry and iOS share-sheet wiring are drafted uncommitted).
6. Prove correct 60 Hz simulation/timer/physics/AI/input/audio/presentation on
   named hardware and tracks.
7. Only then add Match Display/120 Hz through existing interpolation without
   changing simulation speed; test transitions, Low Power Mode, audio, and heat.
8. Harden reproducible packaging, signing/notarization or re-signable IPA
   boundaries, clean-machine builds, hashes, update behavior, and artifact scans.
9. Bring README and linked docs to or above HarkinianPad quality using only real
   captures and verified install/import/controls/settings/diagnostics/performance
   claims.
10. After cartridge completion, re-enable and independently validate Expansion
    Kit import, IPL, writable media, editors, DD content, persistence, lifecycle,
    and package safety.

GOAL-BASED EXECUTION LOOP

Repeat continuously:

1. Reconcile repository state and docs; identify the highest-priority unmet
   evidence gate that is locally actionable.
2. State its expected observable exit condition and the smallest regression or
   experiment that can falsify the intended fix.
3. Inspect current source and the precise reference implementation; do not code
   from memory.
4. Implement the smallest clean change through the narrowest existing seam.
5. Build the focused target.
6. Run the actual app/test.
7. Interact with and visually inspect the relevant behavior, using a real window,
   Simulator, or physical device as the gate requires.
8. Capture compact evidence: commands, logs, screenshots/video, test output,
   crash trace, timing, and artifact identity. Keep private/game data out of Git.
9. Diagnose every failure, reduce it, fix it, and rerun. Do not hide failed
   attempts or relabel partial milestones as passes.
10. Update docs/TESTING.md with date, expectation, command/environment, result,
    failure/fix, boundary, and next gate. Update STATUS, KNOWN_ISSUES, architecture,
    build/data/touch/performance docs, and README whenever their truth changes.
11. Regenerate maintained patch artifacts. Prove reverse-apply against the tested
    tree and clean apply/check against the pinned source. Run diff/link/safety and
    package audits proportional to risk.
12. Inspect the staged set for ROMs, archives, saves, private paths/logs, signing
    material, credentials, and unrelated files.
13. Make one focused commit for the coherent unit.
14. Immediately select the next unmet gate and continue.

DOCUMENTATION REQUIREMENT

Document rigorously while working, not only at the end. Keep one source-of-truth
queue in docs/NEXT_BUILDER.md. Mark every claim as planned, implemented, compiled,
Simulator verified, macOS verified, physical iPhone verified, physical iPad
verified, gameplay verified, partially working, blocked, or not tested. When a
public fact changes, update README in the same coherent unit. Store useful compact
evidence under docs/evidence/<gate>/.

BLOCKER RULE

Difficulty, long builds, missing automation, one failed approach, or unavailable
physical hardware are not reasons to stop while meaningful local gates remain.
After three consecutive repetitions of the same blocker with no new safe local
progress, write an exact blocker report: source revision, platform, command,
artifact, logs/crash, technical cause, attempted fixes and results, relevant
upstream/HarkinianPad comparison, why it is fundamental, and the smallest action
needed to resume. Do not switch architectures to manufacture success.

COMPLETION

Stop only when every applicable base condition from the original master goal is
proven—including native macOS/iPhone/iPad, Metal, Files import/in-process local
extraction, complete/repeated gameplay, all controls, touch on both device classes,
physical controller handoff, audio, saves, lifecycle, diagnostics, correct 60 Hz,
measured hardware performance, audited artifacts, current documentation, and a
HarkinianPad-quality README—or when a genuine fundamental blocker has been proven
and documented under the rule above.
```
