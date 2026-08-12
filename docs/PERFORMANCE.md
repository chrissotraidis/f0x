# Performance

F0X has render-path diagnostic evidence but does not yet have a release-grade
performance baseline.

## Existing measurements

- A live macOS scripted race produced a dense 462-frame, 8.000-second window
  capture with no near-black frame or brightness jump.
- Finder-launched F0X Home produced 544 frames over 9.500 seconds with no
  near-black frame or brightness jump.
- During the latest Simulator picker-to-race artifact, venue translation logs
  commonly reported roughly 4.5–6.5 ms for 76 display lists and about
  1,765–1,795 output commands. This is a diagnostic sample, not an FPS or device
  recommendation.

## Open measurements

Before publishing performance claims, measure during real player-controlled
races on named hardware:

- simulation rate and race-timer accuracy;
- presentation FPS and frame pacing at 60 Hz;
- CPU, memory, startup time, and extraction duration;
- Metal validation errors and late frames;
- audio synchronization and underruns;
- physical-device thermal behavior and sustained sessions;
- representative tracks, machines, effects, collisions, and repeated races.

High refresh comes only after correct 60 Hz simulation/presentation is proven.
120 Hz or Match Display must never accelerate game simulation.
