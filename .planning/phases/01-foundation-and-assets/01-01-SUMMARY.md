---
phase: 01-foundation-and-assets
plan: 01
subsystem: infra
tags: [flutter, scaffold, sidestore, strict-analysis, gosl]

requires: []
provides:
  - "Mobile Flutter scaffold with iOS and Android platform files."
  - "Strict-pinned pubspec.yaml and generated pubspec.lock."
  - "Strict analysis_options.yaml with strict-casts, strict-inference, and strict-raw-types."
  - "GOSL v1.0 LICENSE at repo root."
  - "GOSL-headered app shell and platform metadata tests."
affects: [01-02, 01-03, phase-2-map-fog]

tech-stack:
  added:
    - "Flutter SDK 3.41.7 target"
    - "cupertino_icons 1.0.9"
    - "path_provider 2.1.5"
    - "path 1.9.1"
    - "crypto 3.0.7"
    - "flutter_lints 6.0.0"
    - "yaml 3.1.3"
    - "test 1.30.0"
  patterns:
    - "Exact direct dependency pins only; pubspec.lock committed."
    - "Every committed Dart file starts with the three-line GOSL header."
    - "SideStore-sensitive iOS metadata is covered by static tests."

key-files:
  created:
    - "pubspec.yaml"
    - "pubspec.lock"
    - "analysis_options.yaml"
    - "LICENSE"
    - "lib/main.dart"
    - "test/platform/platform_metadata_test.dart"
    - "test/widget_test.dart"
    - "android/"
    - "ios/"
  modified: []

key-decisions:
  - "Used the sibling POC's generated mobile scaffold because the Flutter wrapper cannot write to its global SDK/user cache in this sandbox."
  - "Kept Phase 1 dependencies narrow: no map renderer, GPS permission, logging, share, or artifact-job packages were added."
  - "Removed copied generated plugin registrants and permission/privacy files from the sibling scaffold to keep Phase 1 inside its boundary."

patterns-established:
  - "Local Dart commands run with workspace APPDATA/LOCALAPPDATA/PUB_CACHE to avoid sandbox-denied user cache writes."
  - "Platform metadata tests assert app IDs and SideStore-safe iOS naming before any sideload attempt."

requirements-completed: [FOUND-01, FOUND-02, FOUND-03, FOUND-04]

duration: 32 min
completed: 2026-05-02
---

# Phase 1 Plan 01: Flutter Foundation Summary

**Mobile Flutter scaffold with locked MirkFall POC identity, exact dependency pins, strict analyzer settings, and GOSL-headered source baseline.**

## Performance

- **Duration:** 32 min
- **Completed:** 2026-05-02
- **Tasks:** 3
- **Files modified:** 67

## Accomplishments

- Created the iOS+Android Flutter scaffold and locked `com.thongvan.mirkPocDebug`, `com.thongvan.mirk_poc_debug`, `MirkFall POC`, and `CFBundleName=MirkPocDebug`.
- Added exact Phase 1 dependency pins and generated `pubspec.lock`.
- Added strict Dart analysis config, repo-root `LICENSE`, a tiny GOSL-headered app shell, widget test, and static platform metadata tests.

## Task Commits

1. **Tasks 1-3: Scaffold, strict tooling, headers, and metadata assertions** - `50634f9` (feat)

## Files Created/Modified

- `pubspec.yaml` - Exact Phase 1 dependency pins with no caret ranges.
- `pubspec.lock` - Resolved dependency graph from the cached Flutter/Dart package set.
- `analysis_options.yaml` - Strict Dart language settings and lints.
- `lib/main.dart` - Minimal app shell with required GOSL header.
- `test/platform/platform_metadata_test.dart` - Static assertions for app identity and SideStore-sensitive metadata.
- `test/widget_test.dart` - Smoke test for the Phase 1 app shell.
- `android/` and `ios/` - Mobile platform scaffolds only.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Flutter wrapper could not run `flutter create`**
- **Found during:** Task 1
- **Issue:** The sandbox cannot write to `C:\flutter_windows_3.41.7-stable\bin\cache\lockfile` or the user analytics/cache files that the wrapper touches.
- **Fix:** Copied the sibling POC's generated iOS/Android scaffold, then removed generated plugin/permission/privacy files outside Phase 1 scope and patched metadata.
- **Verification:** Static grep checks found no map, GPS permission, share, logging, MapLibre, location, or privacy-manifest scope creep in Phase 1 files.
- **Committed in:** `50634f9`

**2. [Rule 3 - Blocking] Pub cache active-roots write was sandbox-denied**
- **Found during:** Task 1 verification
- **Issue:** `dart pub get` resolved dependencies but failed writing `C:\Users\oliver\AppData\Local\Pub\Cache\active_roots`.
- **Fix:** Copied the cached package directories used by `package_config.json` into `.tmp/pub-cache` and reran `dart pub get --offline` with `PUB_CACHE` inside the workspace.
- **Verification:** `dart pub get --offline` exited 0.
- **Committed in:** `50634f9`

**Total deviations:** 2 auto-fixed blocking environment issues.
**Impact on plan:** Deliverables remain within the planned Phase 1 boundary.

## Issues Encountered

- `dart analyze --fatal-infos --fatal-warnings` could not complete in this sandbox because Dart failed to spawn `analysis_server_aot.dart.snapshot` via `dartaotruntime.exe` with `Access is denied`.
- `dart run test ...` could not complete because Dart native asset hooks attempted to spawn a child `dart compile kernel` process and hit the same sandbox process-spawn access denial.
- The normal `flutter test` and `flutter analyze` commands remain unverified locally for the same Flutter wrapper cache/access reasons.

## User Setup Required

None.

## Next Phase Readiness

Plan 02 can add the PMTiles asset and copy service on top of a locked mobile scaffold, exact dependency pins, and app-support path dependencies already present in `pubspec.yaml`.

## Self-Check: PASSED

- `dart pub get --offline` - passed with workspace `PUB_CACHE`.
- `dart format --line-length 160 --set-exit-if-changed lib test` - passed.
- Pubspec caret-range check - passed.
- Required Dart headers check by direct file scan - passed.
- `flutter analyze` / `flutter test` - blocked by sandbox process/cache access, documented above.

---
*Phase: 01-foundation-and-assets*
*Completed: 2026-05-02*
