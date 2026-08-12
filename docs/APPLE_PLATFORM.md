# Apple platform status

F0X now has real native Apple targets rather than a platform plan only.

| Platform | Current proof | Not yet proven |
| --- | --- | --- |
| Apple Silicon macOS | Native arm64 build, sealed Finder-launchable `F0X.app`, F0X Home, managed data, Metal title/race, SRAM relaunch, dense presentation captures | Owner confirmation of prior flashing, player-completed race, audible route, release signing/notarization, long acceptance matrix |
| iPad Simulator | Native arm64 SDL/UIKit/Metal app, Files picker, one-process ROM selection/extraction/hot mount, visible race | Touch gameplay, lifecycle, subjective audio, physical ergonomics |
| iPhone Simulator | Build architecture exists | Compact-layout implementation and direct phone-Simulator acceptance |
| iPhoneOS/iPadOS SDK | Complete unsigned arm64 app compiles and validates as ROM-free | Signing, installation, physical launch, controller, touch, lifecycle, audio, performance, thermal behavior |

The app is landscape-only with an iOS 16 minimum. The current host has one
booted iPad Pro 11-inch (M5) Simulator, no connected physical Apple device, and
no valid code-signing identity. Do not convert SDK/Simulator results into
physical-device claims.

Mobile uses SDL's UIKit entry point, Metal, SDL audio, a native document picker,
and in-process Torch. Immutable bundle resources and writable Documents are
explicitly separate. Desktop-only Discord, folder, fullscreen, process-spawn,
and CoreAudio assumptions are excluded where inappropriate.

Touch is not implemented. The existing SDL finger-to-ImGui mouse path only
operates menus/setup; it is not an N64 gameplay controller.
