# Feature Research: POC Scope

**Date:** 2026-05-02

## Table Stakes For This POC

These features are required to produce useful evidence:

1. App launches through a foreground location permission gate.
2. App renders the Melun PMTiles map offline from bundled data.
3. App paints atmospheric fog in a `flutter_map` custom layer, not as a platform-view overlay.
4. App stores reveal discs in memory from GPS fixes and rebuilds the 256x256 SDF when discs change.
5. App exposes a recenter control for returning to the current GPS position at zoom 15.
6. App logs detailed timing and renderer events to disk.
7. App shares the active log file through the platform share sheet.
8. CI uploads both unsigned iOS IPA and Android debug APK artifacts.
9. The user can run the explicit UAT gesture checks on iOS.

## Differentiators Worth Keeping

- Atmospheric shader fidelity from MirkFall, including curl, hue, boundary bleed, and SDF sampling.
- SDF rebuild latency logging around `RevealedSdfBuilder.buildFromDiscs`.
- Frame timing logging during gestures and static fog animation.
- Optional wisp particles only after primary fog-map sync and fps checks are passable.

## Deferred Or Excluded

- Persistent session history.
- Database-backed reveal storage.
- Background tracking.
- Multi-country map support.
- Full settings/debug menu.
- Tuner sheet.
- Multiple map styles.
- Full localization.
- Remote PMTiles download flow.

## Notes From Research

- The PMTiles provider supports local filesystem paths and remote URLs, not direct Flutter asset URIs. The UX feature should therefore be "copy bundled PMTiles to app support on first launch" rather than "open `asset:///...` directly."
- `share_plus` file sharing is available on iOS and Android; this is enough for log export.
- `permission_handler` needs the Podfile macro at the same time as Dart permission code.

## Sources

- https://pub.dev/packages/vector_map_tiles_pmtiles
- https://pub.dev/packages/vector_map_tiles_pmtiles/example
- https://pub.dev/packages/share_plus
- https://pub.dev/packages/permission_handler
