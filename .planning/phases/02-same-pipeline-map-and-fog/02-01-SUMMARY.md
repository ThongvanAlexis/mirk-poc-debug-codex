---
phase: 02-same-pipeline-map-and-fog
plan: 01
subsystem: map-fog-foundation
tags: [flutter_map, pmtiles, vector_tiles, shader, constants, dependency-audit]

requires:
  - phase: 01-foundation-and-assets
    provides: Flutter scaffold, PMTiles asset copy path, strict analyzer/header/license/dependency gates
provides:
  - Exact-pinned Phase 2 map/fog dependency graph
  - Parent atmospheric fog shader copied unchanged and declared under flutter.shaders
  - Phase 2 renderer constants for Melun camera, PMTiles source key, reveal radius, atmospheric fog defaults, and identity SDF rect
  - Focused shader asset and constants tests
affects: [02-02-offline-map-rendering, 02-03-fog-infrastructure, 02-04-same-stack-fog-layer]

tech-stack:
  added: [flutter_map 7.0.2, vector_map_tiles 8.0.0, vector_map_tiles_pmtiles 1.5.0, vector_tile_renderer 5.2.0, pmtiles 1.2.0, latlong2 0.9.1, geolocator 14.0.2, logging 1.3.0]
  patterns: [exact pub pins, shader hash parity, constants locked by focused tests, MPL-2.0 license recognition]

key-files:
  created: [assets/shaders/atmospheric_fog.frag, test/assets/shader_asset_test.dart, test/config/constants_test.dart]
  modified: [pubspec.yaml, pubspec.lock, DEPENDENCIES.md, lib/config/constants.dart, tool/check_licenses.dart]

key-decisions:
  - "Kept the resolver-coherent stable PMTiles chain: flutter_map 7.0.2, vector_map_tiles 8.0.0, vector_map_tiles_pmtiles 1.5.0."
  - "Recognized MPL-2.0 as license-clean for this project because the hard deny list is GPL/AGPL/LGPL/SSPL/telemetry/analytics/MapLibre/Mapbox."
  - "Kept SDF rect defaults as identity constants for the initial same-pipeline implementation."

patterns-established:
  - "Dependency graph changes must update DEPENDENCIES.md for every non-SDK lockfile package."
  - "Copied parent shader assets should be hash-checked against the parent source."
  - "Renderer-critical constants should be locked by focused tests before downstream widget work."

requirements-completed: [MAP-03, FOG-01, FOG-02, FOG-05, FOG-07]

duration: 27min
completed: 2026-05-02
---

# Phase 2 Plan 01: Dependency Graph, Shader, And Constants Summary

**Resolver-coherent flutter_map/PMTiles graph with the unchanged MirkFall atmospheric shader and locked Phase 2 map/fog constants**

## Performance

- **Duration:** 27 min
- **Started:** 2026-05-02T09:17:22Z
- **Completed:** 2026-05-02T09:44:00Z
- **Tasks:** 3
- **Files modified:** 8 implementation/audit files

## Accomplishments

- Added exact Phase 2 pins for `flutter_map`, `vector_map_tiles`, `vector_map_tiles_pmtiles`, `vector_tile_renderer`, `pmtiles`, `latlong2`, `geolocator`, and `logging`.
- Copied `C:\claude_checkouts\GOSL-MirkFall\assets\shaders\atmospheric_fog.frag` unchanged to `assets/shaders/atmospheric_fog.frag` and declared it under `flutter.shaders`.
- Added constants for Melun map camera/source, reveal radius, geodesy, identity SDF rect defaults, SDF resolution, and atmospheric fog palette/animation/boundary defaults.
- Updated dependency audit coverage for all 111 non-SDK packages in `pubspec.lock`.

## Task Commits

| Task | Name | Commit | Files |
| --- | --- | --- | --- |
| 1 | Add exact-pinned map/fog dependency graph | `f241d6b` | `pubspec.yaml`, `pubspec.lock`, `DEPENDENCIES.md`, `tool/check_licenses.dart` |
| 2 | Copy and declare atmospheric shader asset | `951ba5d` | `assets/shaders/atmospheric_fog.frag`, `pubspec.yaml`, `lib/config/constants.dart`, `test/assets/shader_asset_test.dart` |
| 3 | Add Phase 2 constants and tests | `490b960` | `lib/config/constants.dart`, `test/config/constants_test.dart` |

## Files Created/Modified

- `pubspec.yaml` - Exact Phase 2 dependency pins and `flutter.shaders` declaration.
- `pubspec.lock` - Resolver output for the stable Phase 2 package graph.
- `DEPENDENCIES.md` - Audit rows for all added direct and transitive packages.
- `assets/shaders/atmospheric_fog.frag` - Parent atmospheric shader copied unchanged.
- `lib/config/constants.dart` - Phase 2 map, fog, SDF, geodesy, and atmospheric defaults.
- `test/assets/shader_asset_test.dart` - Shader declaration and uniform-name asset test.
- `test/config/constants_test.dart` - Renderer-critical constants tests.
- `tool/check_licenses.dart` - MPL-2.0 license recognition for packages whose MPL text mentions GPL-family secondary licenses.

## Decisions Made

- Used the planned stable dependency chain rather than upgrading to `flutter_map` 8.x or beta vector packages.
- Treated MPL-2.0 as allowed because project policy forbids GPL/AGPL/LGPL/SSPL and telemetry/analytics SDKs; MPL-2.0 is neither.
- Added `kPocFogShaderAssetPath` with the shader asset commit so the planned asset test could import the constant before the broader constants task.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed MPL-2.0 false positives in the license checker**
- **Found during:** Task 1
- **Issue:** `dbus`, `geoclue`, and `gsettings` use MPL-2.0, but the checker flagged GPL words inside MPL's secondary-license definition.
- **Fix:** Added MPL-2.0 detection before forbidden-marker scanning and included `MPL-2.0` in the allowed SPDX set.
- **Files modified:** `tool/check_licenses.dart`
- **Verification:** `dart ... tool\check_licenses.dart` passed with 111 packages.
- **Committed in:** `f241d6b`

**2. [Rule 3 - Blocking] Added shader asset path constant one task early**
- **Found during:** Task 2
- **Issue:** The planned shader asset test imports `kPocFogShaderAssetPath`, but the broader constants task came after the shader task.
- **Fix:** Added only `kPocFogShaderAssetPath` in Task 2, then added the remaining Phase 2 constants in Task 3.
- **Files modified:** `lib/config/constants.dart`
- **Verification:** Header check passed; constants test passed after Task 3.
- **Committed in:** `951ba5d`

**Total deviations:** 2 auto-fixed (1 bug, 1 blocking issue)
**Impact on plan:** Both fixes preserve the plan intent and keep downstream Phase 2 work unblocked.

## Verification

| Command | Outcome |
| --- | --- |
| `flutter pub get` | Blocked in this Codex shell: Flutter SDK access failed on `bin\cache\lockfile` or Flutter's internal git version call. |
| `dart pub get --offline` via bundled `dart.exe` | Passed; resolved from the local package cache and wrote `pubspec.lock`/`.dart_tool/package_config.json`. |
| `flutter test test/assets/shader_asset_test.dart test/config/constants_test.dart` | Blocked by the same Flutter SDK git access error before tests started. |
| Direct constants test: `dart.exe test\config\constants_test.dart` | Passed: `+5: All tests passed!` |
| Shader parity/uniform static checks | Passed: parent and copied shader SHA-256 match; SDF rect uniforms are present. |
| `dart run tool/check_headers.dart` equivalent direct script invocation | Passed: `check_headers: OK (17 files)` |
| `dart run tool/check_licenses.dart` equivalent direct script invocation | Passed: `check_licenses: OK (111 packages)` |
| `dart run tool/check_dependencies_md.dart` equivalent direct script invocation | Passed: `check_dependencies_md: OK (111 packages)` |
| `dart format --line-length 160 --set-exit-if-changed .` | Passed: `Formatted 17 files (0 changed)` |
| `flutter analyze --fatal-infos --fatal-warnings` | Blocked by Flutter SDK git access error before analysis started. |
| `dart analyze --fatal-infos --fatal-warnings` | Also blocked in this sandbox while launching the analysis server process. |

## Issues Encountered

- The `flutter`/`dart` batch shims hang or fail in this sandbox because the SDK lives under `C:\flutter_windows_3.41.7-stable` with access restrictions for the sandbox user.
- Network access to pub.dev is restricted, so dependency resolution used the local pub cache with `--offline`.
- A repo-local ignored Pub metadata/cache wrapper under `.dart_tool` was used only to let direct Dart pub commands write active-root and telemetry metadata without touching the restricted user profile.

## Known Stubs

None.

## User Setup Required

None.

## Next Phase Readiness

Plan 02-02 can now build against the exact `flutter_map`/PMTiles graph and the `protomaps` source key. Plan 02-03 can rely on the copied shader path, SDF resolution, atmospheric defaults, and identity SDF rect constants.

## Self-Check: PASSED

- Created files exist: `assets/shaders/atmospheric_fog.frag`, `test/assets/shader_asset_test.dart`, `test/config/constants_test.dart`.
- Task commits exist: `f241d6b`, `951ba5d`, `490b960`.
- No tracked files were deleted by task commits.

---
*Phase: 02-same-pipeline-map-and-fog*
*Completed: 2026-05-02*
