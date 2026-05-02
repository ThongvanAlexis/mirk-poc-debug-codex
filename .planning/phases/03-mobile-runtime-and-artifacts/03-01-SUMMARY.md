---
phase: 03-mobile-runtime-and-artifacts
plan: 01
subsystem: mobile-platform
tags: [flutter, ios, android, permissions, privacy, dependencies]
requires:
  - phase: 02-same-pipeline-map-and-fog
    provides: same-stack map/fog runtime and GeoFix seam
provides:
  - Exact-pinned permission_handler and share_plus dependencies with dependency audit rows
  - Foreground-only iOS and Android location metadata guarded by tests
  - iOS Podfile PERMISSION_LOCATION=1 macro for permission_handler
  - iOS PrivacyInfo.xcprivacy required-reason API declarations
affects: [phase-3-runtime, phase-3-ci, phase-4-uat]
tech-stack:
  added: [permission_handler 12.0.1, share_plus 12.0.2]
  patterns: [foreground-only permission metadata, Apple required-reason privacy manifest]
key-files:
  created: [ios/Podfile, ios/Runner/PrivacyInfo.xcprivacy]
  modified: [pubspec.yaml, pubspec.lock, DEPENDENCIES.md, ios/Runner/Info.plist, ios/Runner.xcodeproj/project.pbxproj, android/app/src/main/AndroidManifest.xml, test/platform/platform_metadata_test.dart]
key-decisions:
  - "Kept Phase 3 location scope foreground-only: when-in-use iOS string and fine/coarse Android permissions only."
  - "Declared FileTimestamp C617.1 and UserDefaults CA92.1 in PrivacyInfo.xcprivacy before adding logger/share runtime paths."
patterns-established:
  - "Static platform metadata tests guard permission_handler macros, usage strings, forbidden background permissions, and privacy reasons."
requirements-completed: [CI-04, CI-05]
duration: 42 min
completed: 2026-05-02
---

# Phase 3 Plan 01: Dependency And Platform Metadata Summary

**Foreground location and share-log platform contract with exact dependency pins, iOS permission macro, and Apple privacy manifest**

## Performance

- **Duration:** 42 min
- **Started:** 2026-05-02T12:04:39Z
- **Completed:** 2026-05-02T12:46:55Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- Added exact-pinned `permission_handler: 12.0.1` and `share_plus: 12.0.2`, refreshed `pubspec.lock`, and updated `DEPENDENCIES.md` for direct and transitive packages.
- Committed foreground-only iOS/Android location metadata, including the `ios/Podfile` `PERMISSION_LOCATION=1` macro required by `permission_handler`.
- Added `ios/Runner/PrivacyInfo.xcprivacy` with FileTimestamp `C617.1` and UserDefaults `CA92.1`, included it in the Runner resources, and extended platform metadata tests.

## Task Commits

1. **Task 1: Add exact-pinned permission and share dependencies** - `e3d0942` (`chore(03-01): add permission and share dependencies`)
2. **Task 2: Commit foreground-only iOS and Android permission metadata** - `cd20a3d` (`feat(03-01): add foreground permission metadata`)
3. **Task 3: Add Apple required-reason privacy manifest** - `54e926c` (`feat(03-01): add iOS privacy manifest`)

## Files Created/Modified

- `pubspec.yaml` - Added exact direct pins for `permission_handler` and `share_plus`.
- `pubspec.lock` - Resolved the Phase 3 permission/share dependency graph.
- `DEPENDENCIES.md` - Added audit rows for new direct/transitive packages.
- `ios/Podfile` - Added standard Flutter Podfile shape and `PERMISSION_LOCATION=1`.
- `ios/Runner/Info.plist` - Added foreground when-in-use location usage text while preserving `CFBundleName`.
- `android/app/src/main/AndroidManifest.xml` - Added fine/coarse foreground location permissions only.
- `ios/Runner/PrivacyInfo.xcprivacy` - Declared required-reason API usage.
- `ios/Runner.xcodeproj/project.pbxproj` - Added privacy manifest to Runner resources.
- `test/platform/platform_metadata_test.dart` - Extended static guards for permissions and privacy metadata.

## Decisions Made

- Used the planned exact pins without version substitution.
- Kept permission metadata strictly foreground-only; no background location, foreground service, notifications, or `UIBackgroundModes` were added.

## Deviations from Plan

None - plan implementation followed the planned scope.

## Issues Encountered

- The first executor was shut down after producing task commits but before creating this summary. The committed work was preserved and the remaining task was completed inline.
- Literal `flutter` commands are blocked in this sandbox by denied write access to `C:\flutter_windows_3.41.7-stable\bin\cache\lockfile`. Direct `dart.exe` verification was used where possible.
- `dart run test` and `dart analyze` also hit sandbox process/signal access limits. Static metadata assertions, direct Dart formatting, and policy scripts passed.

## Verification

- `dart.exe format --line-length 160 --set-exit-if-changed .` - passed.
- `dart.exe --packages=.dart_tool/package_config.json tool/check_licenses.dart` - passed.
- `dart.exe --packages=.dart_tool/package_config.json tool/check_dependencies_md.dart` - passed.
- `dart.exe --packages=.dart_tool/package_config.json tool/check_headers.dart` - passed.
- PowerShell metadata assertion check for Podfile macro, usage strings, forbidden background permissions, privacy reason codes, and Xcode resource membership - passed.
- `flutter test test/platform/platform_metadata_test.dart` - not runnable in this sandbox because the Flutter SDK lockfile is outside writable roots.
- `flutter analyze --fatal-infos --fatal-warnings` - not runnable in this sandbox for the same Flutter SDK lockfile reason.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Wave 2 can build logging on top of the committed dependency and privacy contract. The logging implementation can rely on `path_provider`, `logging`, and the new Apple FileTimestamp privacy declaration.

---
*Phase: 03-mobile-runtime-and-artifacts*
*Completed: 2026-05-02*
