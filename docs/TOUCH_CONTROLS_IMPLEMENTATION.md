# F0X touch-controls implementation reference

This document is the implementation contract for the next builder. It is based
on the current F0X source at G-Diffuser `719fd82` and the pinned read-only
HarkinianPad reference at `1197472`.

## Current truth

F0X has **no gameplay touch controller today**.

- `ref/G-Diffuser/libultraship/src/fast/backends/gfx_sdl2.cpp` translates a
  single SDL finger into ImGui mouse input for setup/menu interaction. That is
  not an N64 pad, not analog steering, and not gameplay multi-touch.
- There is no F0X UIKit overlay, virtual stick, racing button layout, layout
  editor, touch opacity setting, touch/gamepad handoff, or interruption cancel.
- `ref/harkinianpad` and its patches are references only. None of those touch
  sources is compiled into F0X.
- Existing F0X settings pages are General, Graphics, Audio, Controls/Input
  Editor, Input Viewer, Enhancements, Workshop, Online, and Dev Tools. No Touch
  Controls menu exists.

Do not claim touch as implemented until source, build, live input, and UI
evidence all exist.

## What to reuse from HarkinianPad

Read these files before editing:

1. `ref/harkinianpad/docs/touch-controls-design.md`
2. `ref/harkinianpad/docs/customizable-touch-controls.md`
3. `ref/harkinianpad/docs/touch-control-transparency.md`
4. `ref/harkinianpad/patches/shipwright-ios-touch-controls.patch`
5. `ref/harkinianpad/patches/shipwright-ios-customizable-touch-controls.patch`
6. `ref/harkinianpad/patches/shipwright-ios-touch-control-transparency.patch`

Reuse these proven product patterns:

- UIKit overlay attached to the SDL-created `UIWindow`;
- independent phone and tablet default geometries;
- true per-control UIKit touch tracking;
- safe-area clamping;
- normalized persisted centers, scalar sizes, and hidden IDs;
- 70%–150% scaling, Hide/Show, Reset, and Done;
- a permanent `•••` menu control that cannot strand the user;
- gameplay overlay hidden and all inputs released while the menu is visible;
- all inputs released when disabled, editing, backgrounded, interrupted, or
  removed from the window;
- full-opacity editor without changing saved gameplay opacity;
- accessibility labels/identifiers for every control and editor action;
- optional haptic confirmation for a deliberate latch or editor action.

Do **not** copy these HarkinianPad specifics:

- Zelda HUD/native A/B/C artwork;
- keyboard-event synthesis as F0X's primary bridge;
- the eight-way digital WASD stick;
- Zelda-specific Z targeting behavior or Zelda screen-state assumptions;
- the exact grip geometry or labels.

F0X already owns a better native N64 pad-state seam. Use it directly.

## Source-proven F-Zero X mappings

The bit values come from `decomp/include/controller.h`. Gameplay meanings are
verified in the current decomp, especially `decomp/src/game/racer.c` and
`decomp/src/game/camera.c`.

| Touch control | N64 bit / range | F-Zero X behavior | Required in default layout |
| --- | --- | --- | --- |
| Analog stick | X/Y `-80…80` | X steers; Y pitches/tilts the craft and also navigates menus | Yes, continuous analog |
| Accelerator | `BTN_A` / `0x8000` | Hold to accelerate; A also confirms menu choices | Yes, largest right-thumb target |
| Boost | `BTN_B` / `0x4000` | Press to boost after boost is available; B cancels/backs out in menus | Yes |
| Brake | `BTN_CDOWN` / `0x0004` | Hold to brake | Yes; label `BRAKE`, not merely `C↓` |
| Left slide/attack | `BTN_Z` / `0x2000` | Hold for left-side slide behavior; press/tap combinations initiate side/spin attacks; changes machine skin backward in settings | Yes |
| Right slide/attack | `BTN_R` / `0x0010` | Hold for right-side slide behavior; press/tap combinations initiate side/spin attacks; changes machine skin forward in settings | Yes |
| Start/pause | `BTN_START` / `0x1000` | Title/menu confirm and in-race pause | Yes |
| Camera change | `BTN_CRIGHT` / `0x0001` | Cycles race camera | Yes, smaller secondary target |
| Look back | `BTN_CUP` / `0x0008` | Hold to look back during a race | Yes, smaller secondary target |
| C-left | `BTN_CLEFT` / `0x0002` | Context-dependent secondary action; split-race minimap/lap-counter toggle and editor/machine functions | Present but may be hidden by default after playtest |
| L | `BTN_L` / `0x0020` | Context-dependent menu/editor and secret-combination input | Present but secondary |
| D-pad up/down/left/right | `0x0800/0x0400/0x0200/0x0100` | Deterministic menu navigation and editor functions | Yes as a compact group; hideable only after menu coverage is proven |

Important attack semantics: source also defines synthetic `BTN_R_Z_COMBO`
(`0x0080`, hold R and double-tap Z) and `BTN_Z_R_COMBO` (`0x0040`, hold Z and
double-tap R). The touch layer should **not** emit those private bits directly.
It should emit truthful Z/R press/current transitions; the existing game/input
logic remains responsible for combinations and edge timing.

Use player-facing labels based on actions:

- `ACCEL` for A;
- `BOOST` for B;
- `BRAKE` for C-down;
- `SLIDE L` and `SLIDE R` for Z/R, with accessibility hints mentioning attack;
- `VIEW` for C-right;
- `LOOK` for C-up;
- `START` and `•••` for pause and F0X menu.

Do not label B as brake. The current source clearly uses B for manual boost and
C-down for braking.

## Required architecture

### 1. Cross-language API

Add `ref/G-Diffuser/port/gdx_touch_controls.h` with an `extern "C"` API. Keep
the API small and state-oriented. Equivalent naming is fine, but it must cover:

```c
typedef struct GdxTouchPadState {
    unsigned short buttons;
    signed char stickX;
    signed char stickY;
    unsigned char stickActive;
} GdxTouchPadState;

int  gdx_touch_controls_available(void);
void gdx_touch_controls_start(void);
void gdx_touch_controls_tick(int menuVisible,
                             int physicalGamepadConnected,
                             int enabled,
                             float opacity);
void gdx_touch_controls_read(GdxTouchPadState* outState);
void gdx_touch_controls_cancel_all(void);
void gdx_touch_controls_begin_layout_editor(void);
void gdx_touch_controls_reset_current_layout(void);
void gdx_touch_controls_shutdown(void);
```

Add callback registration or one narrow exported host callback for toggling the
live `GdxMenu`; do not mutate only `gOpenMenuBar`, because a constructed
`GuiWindow` owns live visibility and must use `ToggleVisibility()`.

Provide a non-iOS stub source so common C/C++ call sites stay simple and macOS,
Linux, and Windows builds remain neutral. In CMake, compile exactly one of:

- `gdx_touch_controls_ios.mm` on iOS;
- `gdx_touch_controls_stub.c` elsewhere.

### 2. Atomic pad state

UIKit callbacks and the host poll must not race. Keep the shared state in the
Objective-C++ bridge using atomics:

- atomic 16-bit/32-bit button mask;
- atomically packed X/Y/active stick state, or a small lock-free snapshot with
  a generation counter;
- no raw UIKit object access from `input_bridge.c`.

Each button uses atomic OR on touch-down and atomic AND-not on touch-up,
touch-cancel, removal, state transition, and shutdown. The analog stick clamps
its vector to a circle, applies a modest deadzone, maps continuously to
`-80…80`, and publishes `stickActive=1` only while owned by a live touch.

### 3. Merge at the existing N64 seam

Edit `ref/G-Diffuser/port/input_bridge.c` inside `gdx_controller_poll()`.
Immediately after the one `gdx_lus_read_pads()` call and before
`gdx_autoinput_apply()`:

1. read one touch snapshot;
2. OR `touch.buttons` into `buttons[0]`;
3. when `touch.stickActive`, replace only `stick_x[0]` and `stick_y[0]`;
4. keep `connected[0] = 1` as today;
5. leave developer auto-input and `GDX_INPUT_SCRIPT` later in the order so
   deterministic tests retain explicit override ownership.

Do not compute edges in the touch layer. `gdx_update_port_inputs()` already
correctly accumulates host-frame edges across slower game ticks, derives digital
stick thresholds, handles repeats, and publishes current/pressed/released state.

Merge behavior must be tested:

- physical buttons + touch buttons are both visible;
- inactive touch stick leaves physical analog untouched;
- active touch stick owns only the two analog axes;
- releasing touch restores physical analog on the next poll;
- menu/script/autoinput semantics remain unchanged.

### 4. UIKit overlay

Add `ref/G-Diffuser/port/gdx_touch_controls_ios.mm`.

Use one transparent root view whose empty area returns `nil` from `hitTest` so
normal menu/setup interaction passes through. Use independent `UIControl`
subclasses or direct touch tracking per actionable control. Do not use one
single-finger gesture recognizer for the entire pad.

The base overlay must support simultaneous stick + accelerator + any two action
buttons without cancelling one another. `multipleTouchEnabled` must be set where
needed, but separate UIControls are preferable because UIKit naturally tracks
independent touches.

Overlay visibility rules:

- do not cover first-time setup or F0X Home;
- start only after product setup/home has handed off to game boot;
- show during game/title/menu screens when enabled and no physical-controller
  auto-hide condition applies;
- hide the gameplay controls while the F0X ImGui menu is open;
- keep `•••` available whenever the game window is active, including when
  gameplay touch is disabled;
- editor mode temporarily owns the overlay and disables gameplay emission.

### 5. Independent layouts

Use separate hand-authored defaults. Do not scale the tablet rectangles to make
the phone rectangles.

Tablet intent:

- analog stick low-left, reachable without covering track center;
- compact D-pad above/inside the left rail;
- large accelerator at the lower-right natural thumb rest;
- brake and boost immediately above/left of accelerator for chords;
- slide L/Z reachable by left or inner-right thumb and slide R on the right rail;
- View/Look/C-left/L smaller and peripheral;
- Start below the playfield centerline; permanent menu at upper-right safe area.

Phone intent:

- smaller independent stick lower-left;
- omit unused visual gaps and keep all required race actions in thumb arcs;
- place accelerator lower-right with boost/brake above it;
- keep shoulder actions reachable without crossing the screen;
- place `•••` in a dedicated safe slot that does not collide with the Dynamic
  Island/notch or menu tabs;
- validate both left- and right-landscape safe areas.

Default controls should use translucent dark fills, thin high-contrast outlines,
pressed-state feedback, concise action labels, and at least 44-point practical
hit targets. Hit regions may be larger than artwork but must not overlap in ways
that make one action ambiguous.

### 6. Layout editor and persistence

Adapt the HarkinianPad editor behavior:

- tap selects;
- pan moves within the current safe area;
- Size slider supports 70%–150%;
- Hide/Show applies to optional buttons only;
- analog stick, accelerator, Start, and permanent menu cannot be hidden;
- Reset removes the current override profile and rebuilds from code defaults;
- Done persists and returns to the prior game/menu state;
- opening the editor first cancels all gameplay input;
- controls render at full opacity while editing.

Persist property-list-safe dictionaries in `NSUserDefaults` under versioned,
device-specific keys:

```text
F0X.TouchLayout.phone-v1
F0X.TouchLayout.tablet-v1
```

Store normalized center X/Y, scalar size, and hidden control IDs. Rebuild from
the current defaults first, then apply saved overrides and clamp to the live safe
area. This lets future default changes survive old profiles.

### 7. Settings

Register these CVars in `GdxMenu::GdxMenu()` with iOS-safe defaults:

```text
gSettings.Touch.Enabled                 = 1
gSettings.Touch.Opacity                 = 0.55
gSettings.Touch.AutoHideWithController  = 1
gSettings.Touch.Haptics                 = 1
```

Add a Touch Controls section under Settings → Controls in
`gdx_menu_registry.cpp`, hidden when `gdx_touch_controls_available()==0`:

- Touch Controls checkbox;
- Touch Control Opacity, clamped 25%–100%;
- Auto-hide with Physical Controller;
- Haptics;
- Customize Touch Layout button;
- Reset Current Layout button with confirmation or unambiguous copy.

Callbacks apply live. Persist through the existing CVar save mechanism. Do not
create a second settings store for ordinary switches; only layout geometry uses
`NSUserDefaults` because it is a native structured profile.

### 8. Menu and physical-controller handoff

Expose a read-only physical-gamepad-present query from the existing ControlDeck
connected-gamepad state; do not treat the pinned logical port 1 as physical
hardware. When Auto-hide is enabled and an actual SDL gamepad is connected:

- cancel touch input before hiding controls;
- retain the permanent menu affordance if the controller cannot open the menu;
- restore touch immediately and neutrally when the gamepad disconnects;
- never let a disconnected controller leave acceleration or slide latched.

The `•••` action must toggle the live menu object. Opening the menu cancels all
touch input before removing gameplay controls. Closing restores only if Touch
Controls is still enabled and the physical-controller policy allows it.

### 9. Lifecycle

Observe or route the existing SDL/UIKit lifecycle events. Cancel all input on:

- will/did resign active;
- background;
- interruption/termination;
- overlay removal;
- menu opening;
- editor opening;
- touch setting disabled;
- physical-controller auto-hide transition.

Lifecycle work must also pause simulation/audio/presentation and persist config
as required by the master goal. Touch cancellation alone is not complete mobile
lifecycle support.

## File-by-file implementation order

Make the smallest coherent sequence, building after each numbered slice:

1. Add `gdx_touch_controls.h`, iOS implementation, non-iOS stub, and CMake
   selection. Implement only atomic state, cancel, and availability first.
2. Add a focused merge helper/regression, then integrate the snapshot in
   `input_bridge.c`. Verify macOS neutral behavior before drawing UI.
3. Implement tablet virtual stick plus Accelerator/Boost/Brake/Slide L/Slide R/
   Start and permanent menu. Reach a race and prove mapped state in F0X's Input
   Viewer/log seam.
4. Add D-pad, View, Look, C-left, and L; verify menus, machine settings, camera,
   brake, boost, and attacks.
5. Add CVars/settings, menu hiding, auto-hide handoff, and cancellation paths.
6. Add separate phone defaults and validate on one phone Simulator without
   disturbing the single booted tablet Simulator workflow.
7. Add editor/persistence/reset/opacity/haptics.
8. Run full Simulator matrix, macOS regression, unsigned device build, patch
   reverse/replay, payload audit, and documentation update.

After each source change, regenerate or update
`patches/gdiffuser-apple-macos.patch` so a clean pinned checkout reproduces the
tested source. Do not leave the only implementation inside ignored `ref/`.

## Tests and evidence

### Focused deterministic tests

Add tests that fail before the merge/cancel implementation and cover:

- every N64 button bit;
- analog clamp, sign, deadzone, and active flag;
- physical/touch OR merge;
- physical-stick preservation and touch-stick override;
- simultaneous accelerator + steering + brake/boost/Z/R;
- release/cancel clears all buttons/axes;
- menu/editor/background transitions clear state;
- profile encode/decode, phone/tablet separation, reset, clamp, hide protections;
- opacity never changes hit geometry.

### Simulator interaction

Use one runtime and one booted Simulator. Capture:

- clean launch with tablet controls;
- title/menu navigation using touch only;
- visible race with steering, acceleration, brake, boost, Z/R attacks, camera,
  look-back, and pause;
- Settings → Controls live toggle and opacity;
- editor move/resize/hide/reset/done and relaunch persistence;
- menu hides gameplay controls and releases a held accelerator;
- background/foreground returns neutral;
- phone layout on a phone Simulator with both landscape safe-area directions;
- no new flashing or black-frame behavior.

Simulator automation may not establish true multi-touch ergonomics. If the test
driver cannot generate concurrent contacts, record that limitation and leave the
physical multi-touch gate open.

### Build/package regressions

- arm64 Simulator build succeeds;
- unsigned arm64 iPhoneOS build succeeds;
- macOS `F0X.app` rebuilds, seals, and runs its Metal route;
- patch reverse-check and clean apply-check pass;
- app/IPA audit finds no ROM, `fzerox.o2r`, saves, signing secrets, or profiles;
- public docs state exactly which touch claims are Simulator-only.

### Physical acceptance

On real iPad and iPhone, prove:

- sustained simultaneous steering + acceleration + brake/boost/attack;
- no dropped or stuck inputs under four-contact stress;
- comfortable reach without unsafe overlap;
- layout persistence and safe-area correctness;
- controller connect/disconnect handoff;
- menu/editor/background/phone-call/audio-route interruption clearing;
- complete touch-only race, repeated races, and representative courses;
- audio, save/reload, memory, thermals, and long-session stability.

Only physical evidence closes the master goal's mobile product gate.
