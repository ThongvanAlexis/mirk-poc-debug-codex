# Research Summary: MirkFall Flutter Map Fog POC

**Date:** 2026-05-02

## Stack

Use `flutter_map` 8.3.0 plus `vector_map_tiles` 8.0.0 and `vector_map_tiles_pmtiles` 1.5.0 for the POC. This is the correct experiment because `flutter_map` is pure Flutter and can put map and fog painting in the same frame pipeline. Keep the parent Flutter 3.41.7 CI baseline to satisfy current package requirements, especially `share_plus`.

## Table Stakes

- Bundled Melun PMTiles copied to app support and loaded from a filesystem path.
- `flutter_map` vector tile map centered on Melun.
- Custom fog layer using the atmospheric shader, MirkFall SDF builder, reveal discs, projection helpers, and uniform slots.
- Foreground location permission and blue GPS dot.
- Recenter button.
- Synchronous file logger and share-log action.
- CI with lint, format, analyze, tests, unsigned iOS IPA, and Android debug APK.

## Watch Out For

- Do not rely on `asset:///` PMTiles loading; copy to filesystem first.
- Measure map-only and map+fog performance separately, or vector tile slowness will blur the conclusion.
- Keep the POC simple enough to reach iOS UAT quickly.
- Treat the fragment shader as the correct test for the real product fog; simpler polygon/raster approaches do not prove the desired migration.
- Add iOS Podfile permission macros before testing location.

## Decision Framing

Pass condition:

- On iOS, fog remains visually locked to the map during pan, zoom, and combined pan+zoom gestures.
- Gesture fps is at least 30 fps with fog enabled.

If that passes, migration from MapLibre to `flutter_map` is justified for the fog requirement, subject to broader production hardening. If sync passes but fps fails, the project has learned that same-pipeline rendering is necessary but this package stack may not be sufficient. If sync fails, `flutter_map` does not solve BUG-014 as expected and the next serious option is native map-pipeline rendering.

## Sources

- https://pub.dev/packages/flutter_map
- https://pub.dev/packages/vector_map_tiles
- https://pub.dev/packages/vector_map_tiles_pmtiles
- https://pub.dev/packages/vector_map_tiles_pmtiles/example
- https://pub.dev/packages/geolocator/license
- https://pub.dev/packages/permission_handler
- https://pub.dev/packages/logging/license
- https://pub.dev/packages/path_provider
- https://pub.dev/packages/share_plus
