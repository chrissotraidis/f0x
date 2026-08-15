# Apple platform status

F0X now has real native Apple targets rather than a platform plan only.

| Platform | Current proof | Not yet proven |
| --- | --- | --- |
| Apple Silicon macOS | Native arm64 build, sealed Finder-launchable `F0X.app`, F0X Home, managed data, Metal title/race, SRAM relaunch, dense presentation captures | Owner confirmation of prior flashing, player-completed race, audible route, release signing/notarization, long acceptance matrix |
| iPad Simulator | Native arm64 SDL/UIKit/Metal app, Files picker, one-process ROM selection/extraction/hot mount, visible race, touch overlay with settings/editor/persistence and live cancel/latch captures | Complete human touch race, subjective audio, physical ergonomics |
| iPhone Simulator | Native arm64 app, live race, compact touch defaults, responsive Input Editor, and background/foreground suspension accepted on iPhone 17 Pro | Subjective audio, physical ergonomics |
| Physical iPad Pro | Corrected signed arm64 app installed and updated in place with protected data preserved; owner accepted normal game start, touch gameplay, audio, course presentation, and racing on 2026-08-15 | Alternate audio routes, lifecycle/interruptions, controller behavior, stress multi-touch, performance, thermals, and long sessions |
| Physical iPhone 14 | Universal signed build installed and running; ROM/archive/save read back with matching hashes; owner-arranged `phone-v1` layout promoted independently to source defaults; archive mounted and 600 audio buffers submitted with zero drops/errors | Touch gameplay, audible fidelity, lifecycle, performance, thermals, controllers, and long sessions |
| iPhoneOS/iPadOS SDK | Complete arm64 app compiles, validates as ROM-free, and supports local development signing | Public distribution signing, App Store/TestFlight, and full hardware matrix |

The app is landscape-only with an iOS 16 minimum. A local Apple Development
identity and Xcode-managed wildcard profile have been verified on the attached
iPad. That establishes only this local development deployment; do not convert it
into public distribution or untested-device claims.

Mobile uses SDL's UIKit entry point, Metal, SDL audio, a native document picker,
and in-process Torch. Immutable bundle resources and writable Documents are
explicitly separate. Desktop-only Discord, folder, fullscreen, process-spawn,
and CoreAudio assumptions are excluded where inappropriate.

Touch gameplay is implemented and Simulator-verified: a UIKit overlay writes
direct atomic N64 pad state merged at the port-1 seam, with settings, an
editor, versioned profiles that survive relaunch, hold-to-cancel, and the
one-second A-button accelerator latch requested for racing.
The existing SDL finger-to-ImGui mouse path only operates
menus/setup; it is not an N64 gameplay controller.

The libultraship Input Editor is also mobile-adapted: a safe-viewport wrapper
prevents stale desktop window rectangles, iPad uses a two-column primary
layout, iPhone uses one column, mapping controls align in tables, and the
gameplay overlay/menu affordance is suppressed for the entire editor session.
