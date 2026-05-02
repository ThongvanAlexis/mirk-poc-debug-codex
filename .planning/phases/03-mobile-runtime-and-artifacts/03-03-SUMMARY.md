---
phase: 03-mobile-runtime-and-artifacts
plan: 03
subsystem: runtime
tags: [flutter, permissions, gps, geofix, share-log, ui-contract]
requires:
  - phase: 03-mobile-runtime-and-artifacts
    provides: permission/share dependencies, foreground metadata, and active file logging
provides:
  - Foreground location rationale and denied/settings recovery flow
  - Foreground Geolocator stream adapted to the existing GeoFix seam
  - Compact active-log share control backed by SharePlus.instance.share
  - Bootstrap/map runtime loading and error copy aligned with the Phase 3 UI spec
affects: [phase-3-runtime, phase-4-uat-evidence]
tech-stack:
  added: []
  patterns: [plugin adapter seams, lifecycle-scoped foreground stream, compact SafeArea diagnostics controls]
key-files:
  created: [lib/infrastructure/permissions/location_permission_service.dart, lib/infrastructure/location/foreground_location_service.dart, lib/infrastructure/sharing/active_log_share_service.dart, lib/presentation/screens/permission_gate_screen.dart, lib/presentation/widgets/share_log_button.dart, test/infrastructure/permissions/location_permission_service_test.dart, test/infrastructure/location/foreground_location_service_test.dart, test/infrastructure/sharing/active_log_share_service_test.dart, test/presentation/screens/permission_gate_screen_test.dart, test/presentation/screens/map_screen_location_test.dart, test/presentation/widgets/share_log_button_test.dart]
  modified: [lib/main.dart, lib/domain/map/map_screen_services.dart, lib/presentation/screens/map_screen.dart, test/presentation/screens/map_screen_test.dart, test/widget_test.dart]
key-decisions:
  - "Kept permission_handler and geolocator calls outside MapScreen by adapting platform values into app-owned service seams."
  - "Started the foreground GPS stream only after permission grant and stopped it on non-resumed lifecycle states."
  - "Shared only the active log file by explicit user action through the non-deprecated SharePlus API."
patterns-established:
  - "Runtime plugin dependencies terminate at infrastructure services; presentation receives app-owned states, streams, and callbacks."
requirements-completed: [LOC-01, LOC-02, LOC-03, LOG-04, LOG-05]
duration: 10 min
completed: 2026-05-02
---

# Phase 3 Plan 03: Permission Runtime, GPS, And Share Log Summary

**Foreground permission gate, live GPS ingestion, and explicit active-log sharing for on-device UAT**

## Performance

- **Duration:** 10 min
- **Started:** 2026-05-02T13:01:05Z
- **Completed:** 2026-05-02T13:11:08Z
- **Tasks:** 4
- **Files modified:** 16

## Accomplishments

- Added `LocationPermissionService` and `PermissionGateScreen` so first launch shows the foreground-location rationale before any system request, with denied/settings recovery and app-resume recheck.
- Added `ForegroundLocationService` to start a high-accuracy foreground Geolocator stream, convert `Position` to `GeoFix`, log invalid/out-of-Melun fixes, and stop on lifecycle/dispose.
- Wired live `GeoFix` values into `MapScreenServices.latestFixStream` without importing platform plugins in `MapScreen`, `FogLayer`, or `RevealDiscRepository`.
- Added `ActiveLogShareService` and `ShareLogButton`, with a bottom-left SafeArea map control and PMTiles bootstrap error-state action for sharing the active log.
- Aligned runtime loading/error copy with the approved UI spec: `Preparing Melun map`, `Opening Melun map`, and the map-data failure text.

## Task Commits

1. **Task 1: Add fakeable permission service and rationale/denied screens** - `41bc380` (`feat(03-03): add foreground permission gate`)
2. **Task 2: Add foreground location service feeding GeoFix stream** - `5b4b79f` (`feat(03-03): feed foreground GPS into map runtime`)
3. **Task 3: Add active-log share service and compact map control** - `63187c5` (`feat(03-03): add active log sharing control`)
4. **Task 4: Finalize runtime copy, loading, and error states against UI-SPEC** - `7f9f43e` (`feat(03-03): align runtime states with UI contract`)

## Files Created/Modified

- `lib/infrastructure/permissions/location_permission_service.dart` - Fakeable foreground permission wrapper using `Permission.locationWhenInUse`.
- `lib/presentation/screens/permission_gate_screen.dart` - Rationale, denied, settings, check-permission, and resume recheck UI.
- `lib/infrastructure/location/foreground_location_service.dart` - Geolocator-to-GeoFix adapter with validation, logging, start/stop, and dispose.
- `lib/infrastructure/sharing/active_log_share_service.dart` - Active file share service using `SharePlus.instance.share(ShareParams(files: <XFile>[...]))`.
- `lib/presentation/widgets/share_log_button.dart` - Compact 44 px accessible share-log icon control.
- `lib/main.dart` - Permission-gated runtime shell, lifecycle-scoped GPS service, share-log injection, and bootstrap error action.
- `lib/domain/map/map_screen_services.dart` and `lib/presentation/screens/map_screen.dart` - Share callback seam and bottom-left map control.
- Runtime, infrastructure, and widget tests - Permission flow, GPS adapter, plugin boundary, map latest-fix, share service, share control, and bootstrap error coverage.

## Decisions Made

- Kept the PMTiles bootstrap error recovery to a single share-log action because retry semantics were not present in the existing one-shot future shell.
- Treated out-of-Melun but finite GPS fixes as evidence-worthy values: they are logged and emitted, then map/reveal boundaries remain responsible for downstream behavior.
- Used `IconButton.filledTonal` with Material `Icons.ios_share` to keep diagnostics compact and away from the map gesture center.

## Deviations from Plan

None - plan implementation followed the planned scope.

## Issues Encountered

- Literal `flutter` test/analyze commands remain blocked by sandboxed access to the Flutter SDK lockfile outside writable roots.
- Direct `dart analyze` also failed to launch the analysis server due sandbox process access restrictions.

## Verification

- `dart.exe format --line-length 160 --set-exit-if-changed` on changed Dart files - passed.
- `dart.exe --packages=.dart_tool/package_config.json tool/check_headers.dart` - passed.
- `dart.exe --packages=.dart_tool/package_config.json tool/check_licenses.dart` - passed.
- `dart.exe --packages=.dart_tool/package_config.json tool/check_dependencies_md.dart` - passed.
- `flutter test ...` and `flutter analyze --fatal-infos --fatal-warnings` - not runnable in this sandbox because the Flutter SDK lockfile is outside writable roots.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Wave 4 can package artifacts and CI around a permission-gated runtime that creates logs, ingests foreground fixes, and exposes explicit log sharing for device UAT.

---
*Phase: 03-mobile-runtime-and-artifacts*
*Completed: 2026-05-02*
