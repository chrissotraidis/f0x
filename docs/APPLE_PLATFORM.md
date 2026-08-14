# Apple platform status

F0X now has real native Apple targets rather than a platform plan only.

| Platform | Current proof | Not yet proven |
| --- | --- | --- |
| Apple Silicon macOS | Native arm64 build, sealed Finder-launchable `F0X.app`, F0X Home, managed data, Metal title/race, SRAM relaunch, dense presentation captures | Owner confirmation of prior flashing, player-completed race, audible route, release signing/notarization, long acceptance matrix |
| iPad Simulator | Native arm64 SDL/UIKit/Metal app, Files picker, one-process ROM selection/extraction/hot mount, visible race, touch overlay with settings/editor/persistence and live cancel/latch captures | Complete human touch race, subjective audio, physical ergonomics |
| iPhone Simulator | Native arm64 app, live race, compact touch defaults, responsive Input Editor, and background/foreground suspension accepted on iPhone 17 Pro | Subjective audio, physical ergonomics |
| Physical iPad Pro | Corrected signed ROM-free arm64 app installed and launched in place; protected ROM/archive/save/preferences hashes preserved; corrected mapping ran through 2,400 audio buffers with its two-buffer startup-zero baseline and zero SDL drops/errors; owner reports major audio improvement | Complete owner acceptance of title/menu effects, GP countdown/race sync, touch/gameplay ergonomics, lifecycle/interruptions, controller behavior, performance, thermals, and long sessions |
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
