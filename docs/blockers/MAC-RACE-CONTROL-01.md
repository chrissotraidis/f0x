# MAC-RACE-CONTROL-01 — player-completed macOS race: blocker report

Written 2026-08-12 after more than three consecutive repetitions of the same
blocker with no progress on the gate itself. This is not a product-defect
claim: the game boots, real mapped input reaches the game, races start, the
GP loop advances, and the input path is proven. The blocker is that no
available input path on this host can navigate a full F-Zero X race.

## Source revision and platform

- Repository `main` HEAD `7564850` (touch system and evidence commit);
  G-Diffuser pinned source `719fd82`; maintained five-patch series applied.
- Apple Silicon macOS (arm64), sealed local bundle
  `build/macos-f0x-bundle/port/F0X.app` rebuilt 2026-08-12 21:05 (Debug,
  cartridge-only, ad-hoc signed); Metal window `F0X (Metal)` 1440x870 at
  (0,30), screencapture region `-R0,30,1440,870`.
- No connected Apple device, zero code-signing identities, Bluetooth off, and
  `0 joystick(s) present at boot` in the runtime log (no controller input
  path exists on this host).

## Commands and artifacts

- `scripts/macos-race-handoff.gdx` — deterministic menu setup ending in a live
  GP race (`player_control_handoff`); reaches mode 1 with TIME running.
- Live-input driver pattern (System Events keystrokes):
  `python3 /tmp/f0x-drive/one-shot3.py <seconds>` — launches F0X, waits,
  activates the window once, clicks window center, then runs one background
  `osascript` keystroke driver while the same Python process captures frames.
- Internal-harness probes (focus-free, deterministic):
  `GDX_INPUT_SCRIPT=scripts/macos-wallhug-probe.gdx` — after the same menu
  setup, `INPUT A -80 0 5400` holds accelerator plus full-left stick for 90 s
  through the in-process pad seam.
- Logs (local, untracked): `/tmp/f0x-drive/probe1.log`,
  `/tmp/f0x-drive/probe2.log`; frames
  `/tmp/f0x-drive/probe2-frames/` (1 fps for 175 s) and
  `/tmp/f0x-drive/macdense/`.

## Result sequence (internal harness, reproduced twice)

1. Race reached (mode 1); sustained A + full-left wall-rides at 51-171 km/h.
2. Energy drains on wall contact; the HUD shows **RETIRE** at TIME 00'22"05,
   LAP 1/3 (capture `f-064`; energy bar empty, LAP never left 1/3).
3. Race ends and the GP advances: mode 1 -> 15 (`GP_RACE_NEXT_COURSE`) ->
   (A press) -> 18 (`GP_RACE_NEXT_MACHINE_SETTINGS`). The JACK CUP / MUTE
   CITY next-course intro panel is visible at captures `f-072`/`f-088`.

The earlier coast-drive observation of mode sequence 1 -> 15 -> 18 -> 1 is
now explained: it was retirement plus GP continuation, not a completed race.

## Technical cause (source-proven)

- Blind input cannot navigate Mute City (a figure-eight): the craft wall-rides;
  sustained wall contact drains energy; energy 0 -> explosion ->
  `Racer_RetireRacer` (`decomp/src/game/racer.c:769`) sets
  `RACER_STATE_RETIRED`, increments `gPlayerRacersRetired`, and in GP mode sets
  `D_800F80C4 = -1`.
- At race end (`racer.c:5512`, `D_800F80B8` counter, case 60)
  `func_80095144` -> `Racer_DecreaseLife` (`racer.c:4922`, `750`), and the GP
  continues via `MENU_CHANGE_NEXT_COURSE` (`game.c:263`) with the life
  penalty. Mode 15/18 are the retire/continue loop, not a finish path.
- Live-input fidelity: only System Events keystrokes reach SDL input (proved
  by a 763 km/h acceleration with exhaust trails); CGEvent and `postToPid`
  do not reach the game. Any intervening shell command steals focus from the
  F0X window (Ghostty/ChatGPT/Simulator windows); the one-shot single-process
  pattern mitigates focus loss but cannot add track awareness.

## Attempted fixes and results

1. System Events tap driver, accel-only: 0 -> 211 -> 438 km/h, rail damage,
   explosion before lap 1 (~00'19" RETIRE).
2. System Events tap driver, alternation steering + boost: RETIRE.
3. Pulse-throttle + steering taps; continuous accel + gentle taps: craft
   moves, but every captured frame shows LAP 1/3, TIME 01'24" -> 04'10",
   speed 0 km/h, wall-riding; no lap visibly completed.
4. Coast drive: mode 1 -> 15 -> 18 -> 1; now explained as retirement.
5. Internal-harness wall-hug probes (two runs): RETIRE at 00'22", next-course
   panel captured. Definitively not a finish.

## Upstream / HarkinianPad comparison

G-Diffuser upstream (Windows/Linux) and HarkinianPad complete races with
human or physical-controller input; neither claims automated blind
completion. HarkinianPad acceptance is human playtested. F0X's input seam is
proven (N64 bits reach the game; the touch merge is Simulator-verified), so
this is a human-play/input-fidelity boundary, not a port defect.

## Why it is fundamental on this host

Completing a three-lap race requires track-aware steering and energy
management. Every sustained automated input pattern that was tried provably
retires the craft (energy death from wall contact). A minimap-based computer-
vision driver is a research-scale effort, would still be scripted input
rather than player acceptance, and is not a reasonable local gate.

## Smallest action to resume

The owner (or any human) plays with the working keyboard mapping on this Mac
(Space=Start, X=A, C=B, WASD=stick, arrows=C), or connects any USB/Bluetooth
controller, completes a race, and repeats it on representative courses. The
settings-SRAM save/relaunch/load round trip is already verified; scripted
race entry and this probe are supporting evidence only, not acceptance.
