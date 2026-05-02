# Phase 3: Mobile Runtime And Artifacts - Research

**Researched:** 2026-05-02
**Domain:** Foreground mobile permissions, live GPS ingestion, synchronous JSONL diagnostics, compact share-log UI, iOS privacy/SideStore metadata, and GitHub Actions APK/unsigned IPA artifacts.
**Confidence:** High on the implementation shape and platform metadata requirements; medium on final iOS behavior until Phase 4 sideload UAT proves the permission prompt and artifact install path on device.

## Phase Boundary

Phase 3 turns the Phase 2 renderer proof into a real-device POC package:

- Add a foreground location rationale gate before the map and request only when-in-use location.
- Add deny/permanent-deny recovery with a system settings action and app-resume recheck.
- Adapt `geolocator` positions into the existing `GeoFix` and `MapScreenServices.latestFixStream` seam.
- Bootstrap a synchronous JSONL file logger before `runApp()`, prune logs to 10 MB, and keep diagnostics always on.
- Add a compact share-log action that uses `SharePlus.instance.share(ShareParams(files: <XFile>[...]))`.
- Add iOS/Android permission metadata, `ios/Podfile` permission macros, and `PrivacyInfo.xcprivacy`.
- Extend CI so every relevant run uploads an Android debug APK and an unsigned iOS IPA for SideStore.

It does not run the iOS gesture/fps UAT or write the final migrate/reject decision. Those remain Phase 4.

## Package And Platform Decisions

The current repo already pins `geolocator 14.0.2`, `logging 1.3.0`, and `path_provider 2.1.5`. Phase 3 should add only the missing runtime packages:

| Package | Pin | Purpose | Notes |
|---------|-----|---------|-------|
| `permission_handler` | `12.0.1` | Foreground permission status/request and app settings action. | Local package source and sibling notes confirm iOS macros are mandatory. |
| `share_plus` | `12.0.2` | Share the active log file. | Local source exposes the non-deprecated `SharePlus.instance.share(ShareParams(...))` API required by the UI spec. |

Use exact pins and update `pubspec.lock` and `DEPENDENCIES.md` in the same plan. If execution deliberately chooses a newer `share_plus` because the solver already resolves it, the change must stay exact-pinned, license-clean, analyzer-clean, and documented in the dependency table.

Platform metadata is part of the acceptance surface:

- `ios/Podfile` must set `PERMISSION_LOCATION=1` in `GCC_PREPROCESSOR_DEFINITIONS` in the same change that adds Dart permission requests.
- `ios/Runner/Info.plist` must keep `CFBundleName` as `MirkPocDebug` and add `NSLocationWhenInUseUsageDescription`.
- `android/app/src/main/AndroidManifest.xml` must declare only `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION`; no background location or foreground-service permissions.
- `ios/Runner/PrivacyInfo.xcprivacy` must declare FileTimestamp reason `C617.1` and UserDefaults reason `CA92.1`.

## Runtime Architecture

```text
main()
  WidgetsFlutterBinding.ensureInitialized()
  FileLogger.bootstrap()
  WidgetsBinding.addObserver(FileLoggerLifecycleObserver())
  runApp(MirkPocApp)

MirkPocApp / runtime shell
  Permission rationale
    Enable Location -> Permission.locationWhenInUse.request()
  Permission denied
    Open Settings -> openAppSettings()
    Check Permission / app resume -> Permission.locationWhenInUse.status
  On grant:
    start foreground location stream
    run PMTiles bootstrap
    MapScreenServices(
      pmtilesPath,
      latestFixStream,
      shareLog callback,
      runtime diagnostic callbacks
    )
```

Keep plugin coupling outside `MapScreen`, `FogLayer`, and reveal domain objects. A permission/location service can import `permission_handler` and `geolocator`, convert `Position` to `GeoFix`, and log events. The map widgets should receive only the already established seams.

## Logging Architecture

The file logger must follow the sibling iOS notes exactly:

- Bootstrap before `runApp()`.
- Use `Logger.root.onRecord.listen(_onRecord)` with synchronous `_onRecord`.
- Open `RandomAccessFile` with `FileMode.writeOnlyAppend`.
- For every record, `writeStringSync('${jsonEncode(entry)}\n')` then `flushSync()`.
- Catch only `FileSystemException`, log failures with `dart:developer.log`, then disable the active RAF to avoid recursive logging.
- Write under `<app_documents_dir>/logs/` using UTC basic filenames like `20260502T112133Z_logs.txt`.
- Include millisecond UTC timestamps, level, logger name, message, optional error/stack fields, and bootstrap active path.
- Prune old logs to `kMaxLogsDirBytes = 10 * 1024 * 1024` without deleting the active log file.
- Keep `FileLogger.flush()` as a compatibility no-op because each record is already durable.

Phase 4 evidence markers should be logged in Phase 3:

- PMTiles copy/open events and durations.
- Tile provider init/open duration.
- Shader load success/failure duration.
- SDF rebuild duration, disc count, and viewport key.
- Permission outcomes and settings launches.
- Location stream start/stop/error, accepted/rejected fixes, out-of-Melun markers, and reveal-disc append counts.
- Map mode changes, map movement/gesture event categories where available from `flutter_map` callbacks.
- Aggregated `FrameTiming` samples so map-only and map+fog cost can be separated.
- Share-log start/result/failure.

## UI Implications

The approved UI spec is evidence-first:

- Permission rationale: title `Enable foreground location`, body from UI-SPEC, primary CTA `Enable Location`.
- Denied: title `Location is disabled`, primary CTA `Open Settings`, secondary `Check Permission`.
- Map runtime: keep full-bleed map/fog; top-right mode toggle remains; bottom-right recenter remains; add bottom-left share-log icon/control with tooltip `Share active log`.
- Map bootstrap copy must change from `Preparing Melun PMTiles` to `Preparing Melun map`; map open stays `Opening Melun map`.
- Error state should be concise, with share-log available where possible.

Do not add a debug menu, settings shell, background tracking UI, or UAT results UI.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Flutter `flutter_test` plus existing Dart `package:test` tool tests |
| Config | `analysis_options.yaml` with strict casts/inference/raw-types |
| Quick command | `flutter test test/infrastructure/logging test/presentation/screens test/presentation/widgets` |
| Full command | `flutter test; dart test tool/test/; dart run tool/check_headers.dart; dart run tool/check_licenses.dart; dart run tool/check_dependencies_md.dart` |

### Requirement Test Map

| Req ID | Behavior | Suggested automated coverage |
|--------|----------|-------------------------------|
| LOC-01 | First launch shows rationale before map | Widget test drives initial app state and asserts no permission request until CTA tap. |
| LOC-02 | Grant proceeds to map and starts foreground updates | Fake permission/location service test asserts map bootstrap and stream start after grant. |
| LOC-03 | Deny/permanent-deny state with settings action | Widget/service tests assert denied state, `openAppSettings`, and resume recheck. |
| LOG-01 | Logger bootstraps under documents/logs before app launch | FileLogger unit test with temp directory plus main bootstrap source/behavior test. |
| LOG-02 | Synchronous RAF writes and flushes | Static/behavior test rejects `IOSink` and checks `writeStringSync`/`flushSync`. |
| LOG-03 | Prunes to 10 MB without active-file delete | Temp-directory test with old files and active open handle. |
| LOG-04 | Share active log through share sheet | Share service test with fake share function and MapScreen share button widget test. |
| LOG-05 | Evidence event markers are emitted | Logger fake tests around PMTiles, shader, SDF, location, frame timing, and share paths. |
| CI-02 | Android debug APK artifact | CI workflow test asserts `flutter build apk --debug` and upload path/name. |
| CI-03 | Unsigned iOS IPA artifact | CI workflow test asserts `flutter build ios --no-codesign`, `Payload/Runner.app`, zip, and upload. |
| CI-04 | iOS Podfile permission macro | Platform metadata test asserts committed Podfile includes `PERMISSION_LOCATION=1`. |
| CI-05 | iOS/Android metadata and privacy manifest | Platform metadata test asserts Info.plist string, Android location permissions, SideStore name, and required-reason API codes. |

## Pitfalls

| Pitfall | Prevention |
|---------|------------|
| iOS permission no-op | Add `ios/Podfile` with `PERMISSION_LOCATION=1` in the same plan as `permission_handler` request code. |
| Background scope creep | Request only `Permission.locationWhenInUse`; do not add background permissions, foreground services, notifications, or always-location strings. |
| Logger loses the failure window | Use synchronous RAF writes plus `flushSync` per record; do not use `IOSink`. |
| Recursive logger failure | On file write errors, use `dart:developer.log`, not `Logger.*`. |
| Share API deprecation | Use `SharePlus.instance.share(ShareParams(files: <XFile>[...]))`, not `Share.shareXFiles`. |
| Wrong artifact shape | Zip `Payload/Runner.app` into `.ipa`; do not upload only `Runner.app`. |
| Diagnostics pollute map testing | Keep share/log controls compact and out of the map center gesture area. |

## Sources

- `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`
- `.planning/phases/03-mobile-runtime-and-artifacts/03-CONTEXT.md`
- `.planning/phases/03-mobile-runtime-and-artifacts/03-UI-SPEC.md`
- `.planning/research/SUMMARY.md`, `STACK.md`, `ARCHITECTURE.md`, `FEATURES.md`, `PITFALLS.md`
- `C:\claude_checkouts\mirk-poc-debug\docs\flutter-ios-specifics.md`
- `C:\claude_checkouts\GOSL-MirkFall\docs\POC-flutter-map-mirk.md`
- Local pub-cache source for `permission_handler 12.0.1`, `share_plus 12.0.2`, `geolocator 14.0.2`, and `flutter_map 7.0.2`

## Research Complete

Phase 3 can be planned as four executable waves:

1. Dependency and platform permission/privacy contract.
2. Synchronous file logger and evidence instrumentation.
3. Permission-gated runtime, live GPS ingestion, and share-log UI.
4. APK/unsigned IPA artifact CI and final guard tests.
