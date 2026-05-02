---
phase: 03-mobile-runtime-and-artifacts
plan: 02
subsystem: diagnostics
tags: [flutter, logging, jsonl, frame-timing, pmtiles, fog]
requires:
  - phase: 03-mobile-runtime-and-artifacts
    provides: permission/share dependency and iOS privacy metadata foundation
provides:
  - Synchronous JSONL file logger under app documents logs
  - Lifecycle flush observer registered before app launch
  - Frame timing aggregation and Phase 4 evidence markers
  - PMTiles, tile-provider, shader, SDF, map-mode, and map-event instrumentation
affects: [phase-3-runtime, phase-4-uat-evidence]
tech-stack:
  added: []
  patterns: [synchronous RandomAccessFile logging, throttled renderer evidence logging, frame timing batching]
key-files:
  created: [lib/infrastructure/logging/file_logger.dart, lib/infrastructure/logging/file_logger_lifecycle_observer.dart, lib/infrastructure/logging/frame_timing_logger.dart, test/infrastructure/logging/file_logger_test.dart, test/infrastructure/logging/frame_timing_logger_test.dart]
  modified: [lib/config/constants.dart, lib/main.dart, lib/infrastructure/pmtiles/pmtiles_asset_copier.dart, lib/infrastructure/pmtiles/flutter_pmtiles_asset_copier.dart, lib/infrastructure/mirk/sdf/sdf_cache.dart, lib/presentation/screens/map_screen.dart, lib/presentation/widgets/fog_layer.dart, test/config/constants_test.dart, test/widget_test.dart, test/presentation/screens/map_screen_test.dart, test/presentation/widgets/fog_layer_test.dart]
key-decisions:
  - "Logger write path uses RandomAccessFile.writeStringSync plus flushSync per record, matching the parent iOS notes."
  - "Frame timings are logged as batches by current map/fog mode instead of one record per frame."
patterns-established:
  - "Runtime evidence markers use named package:logging loggers and compact key/value message strings."
requirements-completed: [LOG-01, LOG-02, LOG-03, LOG-05]
duration: 10 min
completed: 2026-05-02
---

# Phase 3 Plan 02: Synchronous Logging And Evidence Summary

**Durable JSONL logging with lifecycle flush hooks and renderer evidence markers for Phase 4 UAT**

## Performance

- **Duration:** 10 min
- **Started:** 2026-05-02T12:47:00Z
- **Completed:** 2026-05-02T12:57:19Z
- **Tasks:** 3
- **Files modified:** 14

## Accomplishments

- Added `FileLogger` with UTC-basic active filenames, JSONL records, synchronous `RandomAccessFile.writeStringSync` plus `flushSync`, active log path access, log listing, and 10 MB pruning that preserves the active file.
- Bootstrapped file logging before `runApp()` and registered `FileLoggerLifecycleObserver` for non-resumed lifecycle transitions.
- Added `FrameTimingLogger` and evidence markers for PMTiles copy/open, root bundle load, tile provider open, shader load, SDF build latency, map mode changes, map movement, latest fixes, and lifecycle events.

## Task Commits

1. **Task 1: Implement synchronous FileLogger core** - `1a7757e` (`feat(03-02): add synchronous file logger`)
2. **Task 2: Bootstrap logger before runApp and register lifecycle flush observer** - `a17a0a5` (`feat(03-02): bootstrap file logging before app launch`)
3. **Task 3: Add Phase 4 evidence logging hooks** - `d4e5240` (`feat(03-02): add runtime evidence logging`)

## Files Created/Modified

- `lib/infrastructure/logging/file_logger.dart` - JSONL logger, active log path, prune, flush shim, and test reset.
- `lib/infrastructure/logging/file_logger_lifecycle_observer.dart` - Flush hook for inactive/paused/detached/hidden lifecycle states.
- `lib/infrastructure/logging/frame_timing_logger.dart` - Batched frame timing summaries by current map display mode.
- `lib/main.dart` - Logger bootstrap before app launch and updated map loading/error copy.
- `lib/infrastructure/pmtiles/*.dart` - PMTiles asset load/copy/validation markers.
- `lib/infrastructure/mirk/sdf/sdf_cache.dart` - SDF build start/success/failure markers with disc count and key marker.
- `lib/presentation/screens/map_screen.dart` - Tile provider, shader, map mode, map event, recenter, fix, and frame timing markers.
- `lib/presentation/widgets/fog_layer.dart` - SDF image ready/failure markers.
- Logging and presentation tests - Static and behavior coverage for the new contracts.

## Decisions Made

- Kept `FileLogger.flush()` as a compatibility no-op because durability is per-record.
- Logged PMTiles/tile source basenames instead of full copied paths, except the active logger bootstrap path required by the parent iOS notes.
- Used throttled map-event logging to avoid flooding logs during gestures.

## Deviations from Plan

None - plan implementation followed the planned scope.

## Issues Encountered

- Literal `flutter` test/analyze commands remain blocked by sandboxed access to the Flutter SDK lockfile outside writable roots.
- Direct `dart test` is not a substitute for Flutter tests because Flutter imports require `dart:ui`, which is only available through the Flutter test runner.

## Verification

- `dart.exe format --line-length 160 --set-exit-if-changed .` - passed.
- `dart.exe --packages=.dart_tool/package_config.json tool/check_headers.dart` - passed.
- `dart.exe --packages=.dart_tool/package_config.json tool/check_licenses.dart` - passed.
- `dart.exe --packages=.dart_tool/package_config.json tool/check_dependencies_md.dart` - passed.
- PowerShell evidence-marker scan for lifecycle, PMTiles, tile provider, shader, SDF, map, and frame timing events - passed.
- `flutter test ...` and `flutter analyze --fatal-infos --fatal-warnings` - not runnable in this sandbox because the Flutter SDK lockfile is outside writable roots.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Wave 3 can build permission, foreground GPS, and share-log runtime paths on top of the active log path and instrumentation seams created here.

---
*Phase: 03-mobile-runtime-and-artifacts*
*Completed: 2026-05-02*
