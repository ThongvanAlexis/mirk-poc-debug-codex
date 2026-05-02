---
phase: 02-same-pipeline-map-and-fog
plan: 04
subsystem: same-stack-fog-location-ui
tags: [flutter_map, fog_layer, sdf, reveal_discs, blue_dot, recenter, tdd]

requires:
  - phase: 02-same-pipeline-map-and-fog
    provides: Offline Melun PMTiles FlutterMap rendering, map-only toggle seam, and MirkFall fog/SDF/shader infrastructure
provides:
  - FogLayer mounted inside FlutterMap.children between VectorTileLayer and latest-fix CircleLayer
  - Seeded in-memory reveal disc repository plus injected GeoFix latest-fix stream seam
  - Safe atmospheric shader loading with no-crash null shader behavior before shader/SDF readiness
  - Blue dot marker and recenter control for latest fix at kPocRecenterZoom
  - Static/pure-Dart tests covering layer order, map-only gating, SDF/uniform invariants, fix validation, blue dot, and recenter wiring
affects: [phase-3-location-permission, phase-4-uat, renderer-evidence]

tech-stack:
  added: []
  patterns: [constructor-injected latest-fix stream, ChangeNotifier-style pure-Dart repository, ticker-driven CustomPainter repaint, MapScreen-owned shader/cache lifecycle]

key-files:
  created:
    - lib/domain/location/geo_fix.dart
    - lib/domain/revealed/reveal_disc_repository.dart
    - lib/presentation/widgets/fog_layer.dart
    - lib/presentation/widgets/blue_dot_marker.dart
    - lib/presentation/widgets/recenter_fab.dart
    - test/domain/revealed/reveal_disc_repository_test.dart
    - test/presentation/screens/map_screen_fog_test.dart
    - test/presentation/screens/map_screen_location_test.dart
    - test/presentation/widgets/blue_dot_marker_test.dart
    - test/presentation/widgets/fog_layer_test.dart
    - test/presentation/widgets/recenter_fab_test.dart
  modified:
    - lib/config/constants.dart
    - lib/domain/map/map_screen_services.dart
    - lib/presentation/screens/map_screen.dart

key-decisions:
  - "Kept latest-fix input as an injected Stream<GeoFix> so Phase 3 can adapt a real foreground location stream without changing FogLayer."
  - "Used a pure-Dart ChangeNotifier-style repository surface instead of Flutter ChangeNotifier so reveal-state validation remains runnable when Flutter is blocked."
  - "Mounted FogLayer only inside FlutterMap.children and kept the map-only toggle as the only gate that removes it."
  - "Rendered nothing until shader/SDF inputs are ready rather than crashing or using an external fallback overlay."

patterns-established:
  - "FogLayer reads MapCamera once in build, derives viewport/SDF/clip/uniform inputs from that snapshot, and uses a ticker Listenable for repaint instead of per-frame setState."
  - "RevealDiscRepository accepts only finite in-range GeoFix values and appends one fixed-radius 25 m reveal disc per accepted fix."
  - "MapScreen child order is VectorTileLayer -> conditional FogLayer -> latest-fix CircleLayer."

requirements-completed: [MAP-06, FOG-03, FOG-04, FOG-05, FOG-06, FOG-07, LOC-04, LOC-05, LOC-06]

duration: 21min
completed: 2026-05-02
---

# Phase 2 Plan 04: Same-Stack Fog Integration Summary

**Same-pipeline FlutterMap fog layer with seeded/latest-fix reveal discs, blue dot, recenter, and map-only isolation**

## Performance

- **Duration:** 21 min
- **Started:** 2026-05-02T10:33:00Z
- **Completed:** 2026-05-02T10:54:19Z
- **Tasks:** 3
- **Files modified:** 14 implementation/test files

## Accomplishments

- Added `GeoFix` and `RevealDiscRepository` with seeded Melun discs, immutable snapshots, finite/range validation, and one 25 m reveal disc per accepted latest fix.
- Mounted `FogLayer` as a `FlutterMap.children` custom layer using `MobileLayerTransformer`, one `MapCamera` snapshot per build, `SdfCache`, `RevealedSdfBuilder`, clip path, triangle-wave animation, and identity SDF uniforms.
- Loaded `FragmentProgram.fromAsset(kPocFogShaderAssetPath)` through a safe async seam; null shader or pending SDF paints no fog instead of crashing.
- Wired `FlutterMap.children` order as vector tiles, conditional fog, then blue-dot `CircleLayer`, with map-only mode removing only `FogLayer`.
- Added `BlueDotMarker` and `RecenterFab`; recenter moves to the latest fix at zoom 15 and disables when no latest fix exists.
- Added focused RED/GREEN tests for repository behavior, latest-fix wiring, fog invariants, child order, blue dot styling, recenter wiring, and toggle behavior.

## Task Commits

| Task | Name | Commit | Files |
| --- | --- | --- | --- |
| 1 RED | Add failing tests for latest-fix reveal state | `36b98b1` | `test/domain/revealed/reveal_disc_repository_test.dart`, `test/presentation/screens/map_screen_location_test.dart` |
| 1 GREEN | Add latest-fix reveal state | `666d0bf` | `lib/domain/location/geo_fix.dart`, `lib/domain/revealed/reveal_disc_repository.dart`, `lib/domain/map/map_screen_services.dart`, `lib/presentation/screens/map_screen.dart` |
| 2 RED | Add failing tests for same-stack fog layer | `8eb403b` | `test/presentation/widgets/fog_layer_test.dart`, `test/presentation/screens/map_screen_fog_test.dart` |
| 2 GREEN | Mount fog inside FlutterMap children | `18e5dc8` | `lib/presentation/widgets/fog_layer.dart`, `lib/presentation/screens/map_screen.dart` |
| 3 RED | Add failing tests for blue dot and recenter controls | `b24727d` | `test/presentation/widgets/blue_dot_marker_test.dart`, `test/presentation/widgets/recenter_fab_test.dart`, `test/presentation/screens/map_screen_fog_test.dart` |
| 3 GREEN | Add blue dot and recenter controls | `3bda8b8` | `lib/config/constants.dart`, `lib/presentation/screens/map_screen.dart`, `lib/presentation/widgets/blue_dot_marker.dart`, `lib/presentation/widgets/recenter_fab.dart` |

## Files Created/Modified

- `lib/domain/location/geo_fix.dart` - Immutable latest-fix value with finite/range validation and `LatLng` conversion.
- `lib/domain/revealed/reveal_disc_repository.dart` - Seeded in-memory reveal repository with listener semantics and fixed 25 m disc creation.
- `lib/domain/map/map_screen_services.dart` - Added injected latest-fix stream, initial latest fix, repository, and shader loader seams.
- `lib/presentation/widgets/fog_layer.dart` - Same-stack fog layer with ticker repaint, SDF cache requests, clip path, and shader uniform binding.
- `lib/presentation/widgets/blue_dot_marker.dart` - Canonical latest-fix circle marker with blue fill and white stroke.
- `lib/presentation/widgets/recenter_fab.dart` - Compact recenter control disabled until a latest fix exists.
- `lib/presentation/screens/map_screen.dart` - Shader/cache lifecycle, latest-fix subscription, child order, map-only fog gating, blue dot, and recenter move.
- `lib/config/constants.dart` - Blue-dot styling constants.
- `test/**` Plan 02-04 files - Focused static, pure-Dart, and Flutter-ready tests for the new behavior.

## Decisions Made

- Kept location plugin types out of widgets and domain reveal state by adding `GeoFix`; Phase 3 can adapt `geolocator.Position` at the service boundary.
- Kept `FogLayer` null-shader tolerant so first frame and shader-load failures do not crash the POC.
- Used static source tests for Flutter-only layer invariants because this sandbox cannot run Flutter tests reliably.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Kept reveal repository testable without Flutter runtime**
- **Found during:** Task 1
- **Issue:** Extending Flutter `ChangeNotifier` made the repository unit test require `dart:ui`, which is unavailable to direct Dart tests in this sandbox.
- **Fix:** Implemented the same add/remove/notify/dispose listener semantics as a pure-Dart repository surface.
- **Files modified:** `lib/domain/revealed/reveal_disc_repository.dart`
- **Verification:** Direct repository test passed with `dart.exe --enable-asserts --packages=.dart_tool/package_config.json test/domain/revealed/reveal_disc_repository_test.dart`.
- **Committed in:** `666d0bf`

**Total deviations:** 1 auto-fixed (1 blocking issue)
**Impact on plan:** Preserved the required listener semantics while improving testability under the documented Flutter SDK restriction.

## Verification

| Command | Outcome |
| --- | --- |
| `dart.exe --enable-asserts --packages=.dart_tool/package_config.json test/domain/revealed/reveal_disc_repository_test.dart` | Passed: `+4: All tests passed!` |
| `dart.exe --enable-asserts --packages=.dart_tool/package_config.json test/presentation/widgets/fog_layer_test.dart` | Passed: `+4: All tests passed!` |
| `dart.exe --enable-asserts --packages=.dart_tool/package_config.json test/presentation/screens/map_screen_fog_test.dart` | Passed: `+5: All tests passed!` |
| `dart.exe --enable-asserts --packages=.dart_tool/package_config.json test/presentation/widgets/blue_dot_marker_test.dart` | Passed: `+2: All tests passed!` |
| `dart.exe --enable-asserts --packages=.dart_tool/package_config.json test/presentation/widgets/recenter_fab_test.dart` | Passed: `+2: All tests passed!` |
| `dart.exe --enable-asserts --packages=.dart_tool/package_config.json test/infrastructure/mirk/shader/fog_shader_uniforms_test.dart` | Passed: `+4: All tests passed!` |
| `dart.exe --enable-asserts --packages=.dart_tool/package_config.json test/infrastructure/mirk/sdf/sdf_cache_test.dart` | Passed: `+4: All tests passed!` |
| Direct header script: `dart.exe --packages=.dart_tool/package_config.json tool/check_headers.dart` | Passed: `check_headers: OK (51 files)` |
| Direct license script: `dart.exe --packages=.dart_tool/package_config.json tool/check_licenses.dart` | Passed: `check_licenses: OK (111 packages)` |
| Direct dependency-doc script: `dart.exe --packages=.dart_tool/package_config.json tool/check_dependencies_md.dart` | Passed: `check_dependencies_md: OK (111 packages)` |
| `dart format --line-length 160 --set-exit-if-changed .` with repo-local Dart app data | Passed: `Formatted 51 files (0 changed)` |
| Static scan: `rg "RepaintBoundary|MapLibre|Mapbox|maplibre|mapbox" lib/presentation/widgets/fog_layer.dart lib/presentation/screens/map_screen.dart` | Passed by no matches. |
| Static implementation scan for camera/shader/identity/blue-dot/recenter invariants | Passed: expected patterns found. |
| `dart test tool/test` | Blocked: native hook build failed with `CreateFile failed 5 (Access is denied)` while compiling `objective_c` hook. |
| `dart run tool/check_headers.dart`, `dart run tool/check_licenses.dart`, `dart run tool/check_dependencies_md.dart` | Blocked: timed out after 45s each in this sandbox; direct script invocation passed. |
| `flutter test` | Blocked: timed out after 60s before producing test output. |
| `flutter analyze --fatal-infos --fatal-warnings` | Blocked: timed out after 60s before producing analyzer output. |
| `dart analyze --fatal-infos --fatal-warnings` | Blocked: analysis server failed to start with `CreateFile failed 5 (Access is denied)`. |

## Issues Encountered

- `gsd-sdk` is unavailable on PATH in this shell, so SUMMARY/STATE/ROADMAP/REQUIREMENTS updates and commits were handled directly.
- Flutter and `dart run` native-hook paths remain blocked by sandbox access restrictions. Direct Dart script invocation and static tests were used where viable.

## Known Stubs

None.

## User Setup Required

None.

## Next Phase Readiness

Phase 2 now has the same-pipeline renderer proof surface ready for Phase 3. Phase 3 can replace the injected `Stream<GeoFix>` with real foreground location, add permission states, and add durable synchronous logging/share diagnostics without changing `FogLayer`.

## Self-Check: PASSED

- Created files exist: `lib/domain/location/geo_fix.dart`, `lib/domain/revealed/reveal_disc_repository.dart`, `lib/presentation/widgets/fog_layer.dart`, `lib/presentation/widgets/blue_dot_marker.dart`, `lib/presentation/widgets/recenter_fab.dart`, and this summary file.
- Task commits exist: `36b98b1`, `666d0bf`, `8eb403b`, `18e5dc8`, `b24727d`, `3bda8b8`.
- No tracked files were deleted by Plan 02-04 commits.

---
*Phase: 02-same-pipeline-map-and-fog*
*Completed: 2026-05-02*
