---
phase: 01-foundation-and-assets
plan: 02
subsystem: infra
tags: [pmtiles, assets, checksum, app-support]

requires:
  - phase: 01-foundation-and-assets
    provides: "Flutter scaffold, path_provider/path/crypto pins, and app shell."
provides:
  - "assets/maps/Fra_Melun.pmtile bundled and declared in pubspec.yaml."
  - "PMTiles constants for asset path, filename, support subdir, byte length, and SHA-256."
  - "Checksum-validating PMTiles app-support copy service."
  - "Startup UI that surfaces copied path or copy failure."
  - "Focused asset, copier, and widget tests."
affects: [phase-2-map-fog]

tech-stack:
  added: []
  patterns:
    - "PMTiles source bytes are packaged as a Flutter asset, then copied to app support before use."
    - "Existing app-support files are trusted only after byte length and SHA-256 validation."
    - "Core copy logic is pure Dart; Flutter rootBundle/path_provider access stays in a small adapter."

key-files:
  created:
    - "assets/maps/Fra_Melun.pmtile"
    - "lib/config/constants.dart"
    - "lib/infrastructure/pmtiles/pmtiles_asset_copier.dart"
    - "lib/infrastructure/pmtiles/flutter_pmtiles_asset_copier.dart"
    - "test/assets/asset_bundle_test.dart"
    - "test/infrastructure/pmtiles/pmtiles_asset_copier_test.dart"
  modified:
    - "pubspec.yaml"
    - "lib/main.dart"
    - "test/widget_test.dart"

key-decisions:
  - "Separated pure Dart copy validation from Flutter asset/path lookup so checksum behavior can be verified even when the Flutter test runner is unavailable."
  - "Used the exact documented PMTiles size and SHA-256; invalid bundled bytes fail before any destination path is returned."

patterns-established:
  - "Write invalid or missing app-support copies via a same-directory `.tmp` file, validate the temp file, then rename."
  - "Startup exposes the copied filesystem path as POC evidence instead of hiding MAP-02 behind a polished UI."

requirements-completed: [MAP-01, MAP-02, FOUND-02, FOUND-03, FOUND-04]

duration: 24 min
completed: 2026-05-02
---

# Phase 1 Plan 02: PMTiles Asset Copy Summary

**Bundled Melun PMTiles archive with SHA-256-validated app-support copy service and startup proof path.**

## Performance

- **Duration:** 24 min
- **Completed:** 2026-05-02
- **Tasks:** 3
- **Files modified:** 9

## Accomplishments

- Copied `Fra_Melun.pmtile` into `assets/maps/` and declared it under `flutter.assets`.
- Added PMTiles constants with byte length `4,176,302` and SHA-256 `6BC39C03501D99DADC5C08994663FD07CDB18F6149FB5425C2AA933C7B09DDF1`.
- Implemented `PmtilesAssetCopier.ensureCopied()` with missing/truncated/same-size corrupt repair, temp-file rewrite, and typed failures.
- Wired app launch to run the copy contract and render either `PMTiles ready` with the copied path or `PMTiles copy failed`.

## Task Commits

1. **Tasks 1-3: Bundle asset, copy service, launch wiring, and tests** - `a5a3e02` (feat)

## Verification

- `dart pub get --offline` - passed with workspace `PUB_CACHE`.
- `dart format --line-length 160 --set-exit-if-changed lib test` - passed.
- `Get-FileHash assets/maps/Fra_Melun.pmtile -Algorithm SHA256` - matched expected hash.
- Custom pure-Dart verifier `.tmp/verify_pmtiles.dart` - passed first-copy, truncated-file repair, same-size corrupt-file repair, byte length, and SHA-256 checks.
- `flutter test` remains blocked by the sandboxed Flutter wrapper; see `01-01-SUMMARY.md`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Pure Dart testability seam added**
- **Found during:** Task 2 verification
- **Issue:** `dart run test` and `flutter test` are blocked in this sandbox, but the high-risk PMTiles logic still needed executable verification.
- **Fix:** Split the Flutter adapter into `flutter_pmtiles_asset_copier.dart` and kept `pmtiles_asset_copier.dart` pure Dart with injected asset/support-directory providers.
- **Verification:** `.tmp/verify_pmtiles.dart` executed the core copy and repair paths successfully.
- **Committed in:** `a5a3e02`

**Total deviations:** 1 auto-fixed blocking environment issue.
**Impact on plan:** The production behavior is unchanged; testability improved.

## Issues Encountered

The Flutter and package:test runners remain blocked by sandbox process/signal restrictions, so asset-bundle and widget tests are present but not locally runnable in this environment.

## User Setup Required

None.

## Next Phase Readiness

Phase 2 can consume `ensureFlutterPmtilesAssetCopied()` or `PmtilesAssetCopier` and pass the returned absolute filesystem path to `vector_map_tiles_pmtiles`.

## Self-Check: PASSED

All claimed files exist, the PMTiles asset hash matches the required source file, and the pure Dart copy verifier passed the critical MAP-02 behaviors.

---
*Phase: 01-foundation-and-assets*
*Completed: 2026-05-02*
