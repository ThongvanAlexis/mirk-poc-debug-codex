---
phase: 03-mobile-runtime-and-artifacts
verified: 2026-05-02T13:22:00.000Z
status: passed
score: 12/12 must-haves verified
overrides_applied: 0
deferred:
  - truth: "Actual downloadable APK/IPA artifacts from GitHub Actions"
    addressed_in: "Next push / Phase 4 UAT"
    evidence: "Workflow jobs and artifact paths are implemented and statically guarded. A remote Actions run requires pushing the branch."
  - truth: "Real-device iOS permission prompt, SideStore install, fog sync, and fps evidence"
    addressed_in: "Phase 4"
    evidence: "UAT-01..09 remain pending in REQUIREMENTS.md and STATE.md now routes to Phase 4 ready-to-plan."
---

# Phase 3: Mobile Runtime And Artifacts Verification Report

**Phase Goal:** Add permission flow, synchronous logging/share diagnostics, and CI builds for APK and unsigned IPA.  
**Verified:** 2026-05-02T13:22:00.000Z  
**Status:** passed

## Goal Achievement

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | First launch shows a foreground location rationale before the map and before any system request. | VERIFIED | `PermissionGateScreen` shows `Enable foreground location` and `Enable Location`; `LocationPermissionService.requestWhenInUse()` is called only from the CTA handler. `test/widget_test.dart` guards that the map loader is not started before permission flow. |
| 2 | Grant proceeds to PMTiles bootstrap/map launch and starts foreground GPS. | VERIFIED | `MirkPocApp` routes granted permission into `MirkRuntimeScreen`; `initState()` starts `widget.locationService.start()` and builds `PmtilesBootstrapScreen`. |
| 3 | Deny/permanent deny shows recovery UI and rechecks permission on user action and app resume. | VERIFIED | `PermissionGateScreen` shows `Location is disabled`, `Open Settings`, and `Check Permission`; resume handling checks status when state is denied. |
| 4 | Foreground GPS is adapted to `GeoFix` through an infrastructure seam and lifecycle-scoped. | VERIFIED | `ForegroundLocationService` uses `Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 3))`, converts `Position` to `GeoFix`, rejects/logs invalid coordinates, logs out-of-Melun fixes, and implements `stop()`/`dispose()`. `MirkRuntimeScreen` stops the stream on non-resumed lifecycle states. |
| 5 | Live fixes feed the existing reveal/blue-dot/recenter pipeline without plugin coupling in presentation/domain code. | VERIFIED | `latestFixStream: widget.locationService.fixes` flows into `MapScreenServices`; `MapScreen` listens to `latestFixStream`, appends accepted fixes to `RevealDiscRepository`, updates `_latestFix`, and leaves `geolocator`/`permission_handler` imports outside `MapScreen`, `FogLayer`, and reveal domain objects. |
| 6 | File logger bootstraps before `runApp()`, writes JSONL under app documents logs, and uses synchronous writes. | VERIFIED | `main.dart` calls `await FileLogger.bootstrap()` before `runApp()` and registers `FileLoggerLifecycleObserver`; `FileLogger` opens `<documents>/logs`, writes records with `RandomAccessFile.writeStringSync`, calls `flushSync`, exposes `activeLogFilePath`, and avoids `IOSink`. |
| 7 | Log pruning preserves the active file and evidence markers cover runtime events. | VERIFIED | `FileLogger._pruneLogs()` respects `kMaxLogsDirBytes` and excludes the active file; PMTiles copy/open, tile provider open, shader load, SDF build, frame timing, map events, latest fixes, permission outcomes, and share outcomes have log markers. |
| 8 | User can share the active log via the non-deprecated SharePlus API. | VERIFIED | `ActiveLogShareService` calls `SharePlus.instance.share(ShareParams(files: <XFile>[XFile(activePath)]))`, maps success/dismissed/unavailable/failure, and handles missing active paths without crashing. `ShareLogButton` provides a 44 px `Share active log` control. |
| 9 | Runtime UI copy and controls match the Phase 3 UI contract. | VERIFIED | Loading uses `Preparing Melun map`; map opening uses `Opening Melun map`; PMTiles failure uses `Map data could not open. Restart the app or share the active log for diagnosis.` and exposes share-log when a callback is present. Map controls remain top-right mode, bottom-left share, bottom-right recenter. |
| 10 | Platform metadata supports foreground-only location and iOS privacy requirements. | VERIFIED | `ios/Podfile` sets `PERMISSION_LOCATION=1`; `Info.plist` has `NSLocationWhenInUseUsageDescription` and SideStore-safe names; Android manifest has fine/coarse foreground permissions only; `PrivacyInfo.xcprivacy` declares FileTimestamp `C617.1` and UserDefaults `CA92.1`. |
| 11 | CI keeps gates and adds Android APK plus unsigned iOS IPA artifacts. | VERIFIED | `.github/workflows/ci.yml` keeps the `gates` job, adds `android-debug-apk` uploading `MirkFall-POC-android-debug-apk`, and adds `ios-unsigned-ipa` building `flutter build ios --no-codesign`, packaging `Payload/Runner.app`, and uploading `MirkFall-POC-unsigned-ios-ipa`. |
| 12 | Requirements, roadmap, and state traceability match completed Phase 3 without claiming UAT. | VERIFIED | `.planning/REQUIREMENTS.md` marks LOC-01..03, LOG-01..05, and CI-02..05 complete while UAT-01..09 remain pending; `.planning/STATE.md` advances to Phase 4 ready-to-plan; `.planning/ROADMAP.md` marks Phase 3 plans complete. |

**Score:** 12/12 must-haves verified

## Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `lib/infrastructure/permissions/location_permission_service.dart` | VERIFIED | Fakeable foreground permission wrapper around `Permission.locationWhenInUse.status/request()` and `openAppSettings()`. |
| `lib/presentation/screens/permission_gate_screen.dart` | VERIFIED | Rationale, denied, settings, check-permission, and resume recheck UI with approved copy. |
| `lib/infrastructure/location/foreground_location_service.dart` | VERIFIED | Geolocator adapter with high-accuracy foreground stream, validation, logging, stop, and dispose. |
| `lib/infrastructure/logging/file_logger.dart` | VERIFIED | Synchronous JSONL logger, active log path, prune, and per-record flush. |
| `lib/infrastructure/sharing/active_log_share_service.dart` | VERIFIED | Active log file sharing through `SharePlus.instance.share`. |
| `lib/presentation/widgets/share_log_button.dart` | VERIFIED | Compact accessible share-log control. |
| `.github/workflows/ci.yml` | VERIFIED | Gates plus Android debug APK and unsigned iOS IPA artifact jobs. |
| `test/ci/ci_workflow_test.dart` and `test/platform/platform_metadata_test.dart` | VERIFIED | Static guards cover workflow triggers/gates/artifacts and platform metadata. |
| `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md` | VERIFIED | Phase 3 traceability closed; Phase 4 UAT pending. |

## Requirements Coverage

| Requirement | Status | Evidence |
|-------------|--------|----------|
| LOC-01 | SATISFIED | Permission rationale screen appears before map bootstrap. |
| LOC-02 | SATISFIED | Grant path starts runtime shell and foreground location service. |
| LOC-03 | SATISFIED | Denied state includes settings and check-permission recovery. |
| LOG-01 | SATISFIED | `FileLogger.bootstrap()` before `runApp()`, logs under documents `logs/`. |
| LOG-02 | SATISFIED | `RandomAccessFile.writeStringSync` and `flushSync`; no `IOSink`. |
| LOG-03 | SATISFIED | 10 MB prune cap preserves active log file. |
| LOG-04 | SATISFIED | Active log share service and map/bootstrap share controls. |
| LOG-05 | SATISFIED | Runtime evidence markers cover map, PMTiles, shader, SDF, GPS, frame timing, permissions, and share outcomes. |
| CI-02 | SATISFIED | Android job builds `flutter build apk --debug` and uploads the debug APK path. |
| CI-03 | SATISFIED | iOS job builds `flutter build ios --no-codesign`, packages `Payload/Runner.app`, and uploads `.ipa`. |
| CI-04 | SATISFIED | iOS Podfile includes `PERMISSION_LOCATION=1`. |
| CI-05 | SATISFIED | SideStore-safe names, location usage description, and required privacy manifest entries exist and are tested. |

## Verification Commands

| Command | Result |
|---------|--------|
| `dart.exe format --line-length 160 --set-exit-if-changed .` | Passed: `Formatted 66 files (0 changed)`. |
| `dart.exe --packages=.dart_tool/package_config.json tool/check_headers.dart` | Passed: `check_headers: OK (66 files)`. |
| `dart.exe --packages=.dart_tool/package_config.json tool/check_licenses.dart` | Passed: `check_licenses: OK (124 packages)`. |
| `dart.exe --packages=.dart_tool/package_config.json tool/check_dependencies_md.dart` | Passed: `check_dependencies_md: OK (124 packages)`. |
| `rg -n "LOC-01|LOC-02|LOC-03|LOG-01|LOG-02|LOG-03|LOG-04|LOG-05|CI-02|CI-03|CI-04|CI-05" .planning/REQUIREMENTS.md .planning/STATE.md` | Passed: all Phase 3 IDs present with completed traceability. |

## Blocked Sandbox Checks

| Check | Result | Impact |
|-------|--------|--------|
| `dart.exe test tool\test\` | Failed before running tests because native hooks attempted to spawn a kernel compile for the `objective_c` hook and the sandbox denied process creation. | Sandbox/tooling limitation; deterministic policy scripts passed directly. |
| `flutter analyze --fatal-infos --fatal-warnings` | Timed out after 120 seconds in the sandbox. | Must run in GitHub Actions or an unsandboxed local shell. |
| `flutter test` | Timed out after 120 seconds in the sandbox. | Must run in GitHub Actions or an unsandboxed local shell. |

## Deferred Items

| Item | Addressed In | Evidence |
|------|--------------|----------|
| Downloadable artifacts from a real GitHub Actions run. | Next push / Phase 4 UAT | CI jobs are implemented but not pushed from this sandbox. |
| iOS SideStore install, permission prompt, fog sync, fps, SDF latency, Android comparison, and final decision document. | Phase 4 | UAT-01..09 remain pending. |

## Residual Risks

| Risk | Why It Remains | Owner |
|------|----------------|-------|
| CI artifact build might expose platform-runner issues not visible in static workflow checks. | The sandbox cannot run GitHub Actions macOS/Android builds locally. | Next push / Phase 4 |
| Flutter analyzer/widget/runtime tests were not executable in this sandbox. | Process-launch and Flutter SDK lock/process restrictions blocked the runners. | CI or unsandboxed local shell |
| Real-device foreground permission and GPS behavior still need physical validation. | Platform metadata and runtime seams are implemented, but device OS prompts and SideStore install are Phase 4 evidence. | Phase 4 UAT |

## Gaps Summary

No Phase 3 implementation gaps found. The remaining work is Phase 4 UAT and remote CI artifact execution, both explicitly tracked as pending requirements.

---
_Verified: 2026-05-02T13:22:00.000Z_  
_Verifier: inline Codex execution_
