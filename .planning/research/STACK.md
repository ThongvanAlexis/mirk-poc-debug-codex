# Stack Research: MirkFall Flutter Map Fog POC

**Date:** 2026-05-02
**Purpose:** Decide whether the proposed package stack is plausible, license-compatible, and focused on BUG-014.

## Recommendation

Use the proposed `flutter_map` stack for the POC, with one correction: treat the bundled Melun PMTiles as a Flutter asset only for packaging, then copy it to app support and open it by filesystem path.

The reason is structural. BUG-014 is not mainly a math problem; it is a render-pipeline synchronization problem. A pure Flutter map plus a Flutter custom fog layer is the cleanest experiment that can falsify or validate the migration hypothesis.

## Package Set

| Package | Use | Current finding | License | Decision |
|---------|-----|-----------------|---------|----------|
| `flutter_map: ^8.3.0` | Map widget | Pub.dev describes it as vendor-free, cross-platform, and 100 percent pure Flutter. | BSD-3-Clause | Use |
| `vector_map_tiles: ^8.0.0` | Vector tile layer | Renders vector tiles as a layer on `flutter_map`; stable 8.0.0 is old but active enough for a POC. | BSD-3-Clause | Use, measure hard |
| `vector_map_tiles_pmtiles: ^1.5.0` | PMTiles provider | Supports URL and local filesystem PMTiles sources; Flutter assets are explicitly unsupported in the example docs. | MIT | Use with asset-copy step |
| `geolocator: ^14.0.2` | GPS fixes | Cross-platform location plugin with iOS/Android support. | MIT | Use |
| `permission_handler: ^12.0.1` | Runtime permission gate | Requires iOS Podfile macros; use `PERMISSION_LOCATION=1` or location prompt can no-op. | MIT-like package ecosystem, verify transitive scan | Use carefully |
| `logging: ^1.3.0` | Logger API | Dart team package, BSD-3-Clause. | BSD-3-Clause | Use |
| `path_provider: ^2.1.5` | App support/docs dirs | Flutter team package, BSD-3-Clause. | BSD-3-Clause | Use |
| `share_plus: ^13.1.0` | Share log file | Supports files on iOS/Android. Requires Flutter >=3.38.1 and Dart >=3.10.0. | BSD-3-Clause | Use only with Flutter 3.41.7 parent CI; otherwise pin lower |

## Toolchain

Start with the parent CI toolchain:

- Flutter stable `3.41.7`
- Dart format line length 160
- Strict analyzer settings copied from MirkFall
- JDK 21 for Android CI
- macOS runner for iOS no-codesign build and IPA packaging

This is conservative because `share_plus` 13.1.0 advertises Flutter >=3.38.1 / Dart >=3.10.0 requirements, and the parent CI already runs Flutter 3.41.7.

## License Notes

The proposed direct dependencies are GOSL-compatible based on pub.dev package metadata. Still implement a simple dependency license gate in CI because transitive dependencies can drift.

Minimum gate:

- Run `flutter pub deps --json`.
- Fail on GPL, LGPL, AGPL, SSPL, or unknown licenses unless explicitly allowlisted after review.
- Commit a generated `DEPENDENCIES.md` if the POC keeps enough tooling to justify it.

## Key Risk

`flutter_map` itself is the right renderer hypothesis. `vector_map_tiles` is the risk. If the fog is locked but vector tiles are too slow or ugly on iOS, the decision is not "BUG-014 solved"; it is "same-pipeline strategy works, but this vector tile stack may not be production-acceptable."

## Sources

- https://pub.dev/packages/flutter_map
- https://pub.dev/packages/flutter_map/license
- https://pub.dev/packages/vector_map_tiles
- https://pub.dev/packages/vector_map_tiles/license
- https://pub.dev/packages/vector_map_tiles_pmtiles
- https://pub.dev/packages/vector_map_tiles_pmtiles/example
- https://pub.dev/packages/geolocator/license
- https://pub.dev/packages/permission_handler
- https://pub.dev/packages/logging/license
- https://pub.dev/packages/path_provider
- https://pub.dev/packages/share_plus
