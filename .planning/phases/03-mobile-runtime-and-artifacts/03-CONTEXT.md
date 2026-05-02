# Phase 3: Mobile Runtime And Artifacts - Context

**Gathered:** 2026-05-02
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 3 makes the existing Flutter map/fog POC installable and diagnosable on real devices. It adds a foreground location permission flow, connects live GPS fixes into the Phase 2 `GeoFix` and reveal-disc seam, bootstraps durable synchronous JSONL logging with share-log support, adds required iOS/Android permission and privacy metadata, and extends GitHub Actions to upload Android debug APK and unsigned iOS IPA artifacts.

This phase does not run the real iOS gesture/fps UAT or make the migrate/reject decision. Those remain Phase 4. It also does not add background GPS, notification permission, foreground services, database persistence, MapLibre compensation, or production UX polish.

</domain>

<decisions>
## Implementation Decisions

### Permission Gate Behavior
- **D-01:** Use a strict launch gate before the map for first-run foreground location permission. The user should see a concise rationale screen first, then explicitly trigger the system when-in-use location request.
- **D-02:** Use `permission_handler` for the foreground permission request and settings action, and add the iOS `PERMISSION_LOCATION=1` Podfile macro in the same plan/commit as the Dart request code. Without the macro, iOS can no-op the request.
- **D-03:** Request only foreground/when-in-use location for this POC. Do not add `locationAlways`, notification permission, `UIBackgroundModes`, Android background location, Android foreground service permissions, or production tracking affordances.
- **D-04:** On grant, proceed to the existing PMTiles bootstrap/map flow and start foreground location updates. On deny or permanent deny, show a denied state with a system settings action. Include an app-resume recheck so returning from Settings can enter the map without restarting the app.
- **D-05:** Add `NSLocationWhenInUseUsageDescription` to `ios/Runner/Info.plist`, Android fine/coarse location permissions to `android/app/src/main/AndroidManifest.xml`, and keep `CFBundleName` as the SideStore-safe `MirkPocDebug`.

### Live GPS Ingestion Policy
- **D-06:** Keep the Phase 2 widget seam: runtime location code adapts plugin positions into `GeoFix` and feeds `MapScreenServices.latestFixStream`. `MapScreen`, `FogLayer`, and reveal widgets should not depend directly on `geolocator` or `permission_handler`.
- **D-07:** Use `geolocator` for a foreground high-accuracy walking stream after permission grant. A small distance filter is acceptable to avoid duplicate SDF rebuilds, but every accepted emitted fix should become an in-memory 25 m reveal disc.
- **D-08:** Reject only invalid coordinates at the adapter/repository boundary. Do not silently drop valid fixes just because they are outside the Melun PMTiles bounds; log an out-of-bounds marker instead so UAT can diagnose wrong physical location or simulator state.
- **D-09:** Stop the GPS subscription with the runtime widget/app lifecycle. This phase should not keep receiving locations in the background.
- **D-10:** Log permission outcomes, stream start/stop, accepted fixes, rejected fixes with reason, and reveal-disc append counts. These logs are evidence inputs for Phase 4 but do not replace real-device visual checks.

### Diagnostic Log Surface
- **D-11:** Implement `lib/infrastructure/logging/file_logger.dart` and `file_logger_lifecycle_observer.dart` following the sibling iOS notes: `RandomAccessFile.writeStringSync`, `flushSync` per record, `FileMode.writeOnlyAppend`, catch only `FileSystemException`, and use `dart:developer` for logger write failures to avoid recursive logging.
- **D-12:** Bootstrap file logging before `runApp()` in `main.dart`, after `WidgetsFlutterBinding.ensureInitialized()`. Register the lifecycle observer so background/inactive/detached transitions call the logger flush compatibility hook.
- **D-13:** Write JSONL records under `<app_documents_dir>/logs/` with UTC ISO-8601 basic filenames such as `20260502T112133Z_logs.txt`. Use millisecond timestamps in each record and include the active absolute path in the bootstrap record.
- **D-14:** Prune old log files to the 10 MB cap from the parent project while never deleting the active log file. Add `kMaxLogsDirBytes = 10 * 1024 * 1024` to constants if it is not already present.
- **D-15:** Keep INFO-level diagnostics always on for the POC. A `--dart-define=DEBUG=true` verbose path is acceptable, but a full debug settings UI is not required in Phase 3.
- **D-16:** Add a compact share-log action in the map/runtime UI, not a full debug menu. Use `share_plus` with the non-deprecated `SharePlus.instance.share(ShareParams(files: <XFile>[...]))` API shape from the iOS notes, and log share outcomes.
- **D-17:** Add Phase 4 evidence markers now: tile provider init/open events, PMTiles copy/open events, shader load duration, SDF rebuild duration, location ingestion events, map movement/gesture markers where available, and aggregated frame timings from Flutter's timing callbacks. The logs should help separate map-only cost from map+fog cost.

### Artifact CI Contract
- **D-18:** Keep the existing gates job as the first CI job: dependency resolve, format line length 160, strict analyze, header check, license check, dependency manifest check, guard tests, and Flutter tests.
- **D-19:** Add an Android artifact job on Ubuntu that runs after gates, builds `flutter build apk --debug`, and uploads `build/app/outputs/flutter-apk/app-debug.apk` with a clear artifact name.
- **D-20:** Add an iOS artifact job on macOS that runs after gates, builds `flutter build ios --no-codesign`, packages `build/ios/iphoneos/Runner.app` as `Payload/Runner.app` inside a zipped unsigned `.ipa`, and uploads it for SideStore sideloading.
- **D-21:** Artifact jobs should run on the existing workflow triggers (`workflow_dispatch`, `pull_request`, and `push` to `main`) unless the planner finds a concrete runner-cost reason to narrow artifact builds. The POC priority is fast downloadable evidence.
- **D-22:** Update CI tests that currently assert the workflow is gates-only. Add tests for artifact upload steps, Podfile `PERMISSION_LOCATION=1`, location usage description, Android location permissions, SideStore-safe `CFBundleName`, and `PrivacyInfo.xcprivacy` required-reason API declarations.
- **D-23:** Add `permission_handler` and `share_plus` with exact pins, update `DEPENDENCIES.md`, and keep the license gate strict against GPL, AGPL, LGPL, SSPL, telemetry, analytics, and unknown licenses.
- **D-24:** Add `ios/Runner/PrivacyInfo.xcprivacy` declaring required-reason API usage for file timestamps and UserDefaults as documented in `flutter-ios-specifics.md`.

### Agent Discretion
- The planner may choose exact file/class names for permission and location services as long as plugin coupling stays outside map/fog widgets.
- The planner may choose the exact location stream settings after checking current `geolocator` APIs, but should optimize for short foreground walking UAT rather than production battery life.
- The planner may choose whether the share-log action is an icon button, overflow action, or small floating control, provided it is easy to find during UAT and does not obscure map/fog testing.
- The planner may split CI into one workflow with multiple jobs or a second artifact workflow if that is cleaner, provided artifacts are downloadable from GitHub Actions without a Mac.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Current Project Planning
- `.planning/PROJECT.md` - Project scope, active Phase 3 requirements, hard constraints, parent source references, logging and iOS specifics.
- `.planning/REQUIREMENTS.md` - Phase 3 requirement mapping: LOC-01..03, LOG-01..05, CI-02..05.
- `.planning/ROADMAP.md` - Phase 3 boundary, success criteria, exclusions, and Phase 4 separation.
- `.planning/STATE.md` - Current project state and Phase 2 completion notes.
- `.planning/research/ARCHITECTURE.md` - Same-pipeline architecture and instrumentation events that should be logged.
- `.planning/research/FEATURES.md` - POC table-stakes features, including permission, logs, share, and artifacts.
- `.planning/research/PITFALLS.md` - iOS permission no-op, sync logger, and IPA packaging pitfalls.
- `.planning/research/STACK.md` - Package stack, toolchain baseline, and dependency/license notes.
- `.planning/research/SUMMARY.md` - Research summary and decision framing.
- `.planning/phases/01-foundation-and-assets/01-CONTEXT.md` - Locked app identity, SideStore metadata, exact pins, and Phase 3 deferrals.

### Current Project Code
- `lib/main.dart` - Current bootstrap order and `PmtilesBootstrapScreen`; logging and permission gate must integrate before map launch.
- `lib/domain/map/map_screen_services.dart` - Existing `latestFixStream`, `initialLatestFix`, and injection seam for Phase 3 live GPS.
- `lib/domain/location/geo_fix.dart` - Runtime location value object consumed by map/fog code.
- `lib/domain/revealed/reveal_disc_repository.dart` - In-memory reveal-disc append path for accepted GPS fixes.
- `lib/presentation/screens/map_screen.dart` - Current `FlutterMap`, map/fog children order, mode toggle, blue dot, and recenter wiring.
- `lib/config/constants.dart` - Existing POC constants; add logging cap and any runtime diagnostics constants here.
- `.github/workflows/ci.yml` - Current gates-only workflow that Phase 3 must extend.
- `test/ci/ci_workflow_test.dart` - Current test explicitly forbids artifact builds and must be updated.
- `ios/Runner/Info.plist` - Existing SideStore-safe metadata; add foreground location usage string.
- `android/app/src/main/AndroidManifest.xml` - Existing Android manifest; add foreground location permissions.
- `pubspec.yaml` and `DEPENDENCIES.md` - Exact dependency pins and dependency/license audit table.

### Parent And Sibling References
- `C:\claude_checkouts\mirk-poc-debug\docs\flutter-ios-specifics.md` - Mandatory recipes for Podfile permission macros, synchronous file logger, share-log API, privacy manifest, and SideStore gotchas.
- `C:\claude_checkouts\GOSL-MirkFall\docs\POC-flutter-map-mirk.md` - Original POC spec, target artifacts, permission/logging/share requirements, and UAT evidence framing.
- `C:\claude_checkouts\GOSL-MirkFall\docs\phase09-bug-tracking\BUG-014-sdf-rect-offset-axes.md` - Root BUG-014 evidence and the reason Phase 3 must support iOS-first artifact/UAT flow.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `MapScreenServices.latestFixStream` already lets Phase 3 inject live `GeoFix` values without making presentation widgets depend on permission/location plugins.
- `RevealDiscRepository.appendFix` already creates 25 m in-memory reveal discs from accepted `GeoFix` values and notifies the fog layer through its listener pattern.
- `MapScreen` already handles latest-fix blue dot and recenter behavior; Phase 3 should feed it rather than rewrite map/fog UI.
- `tool/check_headers.dart`, `tool/check_licenses.dart`, `tool/check_dependencies_md.dart`, and `DEPENDENCIES.md` already enforce GOSL headers, license policy, and exact dependency audit shape.
- The existing Flutter/iOS/Android scaffold already has SideStore-safe `CFBundleName`, app identity, map assets, shader asset, and strict analyzer baseline.

### Established Patterns
- Direct dependencies use exact pins and `pubspec.lock` is committed.
- `.dart` files in `lib/`, `test/`, and `tool/` must start with the three-line GOSL header.
- Tests include both behavior-level widget tests and source/metadata guard tests; Phase 3 should add similarly focused tests instead of relying on manual checks.
- PMTiles is opened through a copied filesystem path. Phase 3 should preserve this and log it, not change map loading.
- The POC favors evidence over polish. Use compact controls and clear states, not a production navigation shell.

### Integration Points
- `main.dart` needs the new bootstrap order: binding, file logger bootstrap, lifecycle observer registration, then app launch.
- A permission/location runtime service should sit between `main.dart`/app shell and `MapScreenServices`.
- `pubspec.yaml`, `pubspec.lock`, `DEPENDENCIES.md`, and license tests must change together when adding `permission_handler` and `share_plus`.
- `ios/Podfile`, `ios/Runner/Info.plist`, `ios/Runner/PrivacyInfo.xcprivacy`, and `android/app/src/main/AndroidManifest.xml` are part of the Phase 3 acceptance surface, not incidental platform files.
- `.github/workflows/ci.yml` and `test/ci/ci_workflow_test.dart` must evolve from Phase 1 gates-only to Phase 3 gates-plus-artifacts.

</code_context>

<specifics>
## Specific Ideas

- Codex interactive question UI was unavailable in Default mode, so the workflow fallback selected all four gray areas and used conservative defaults. Review this file before planning if you want to override any decision.
- The permission screen should stay short and practical: the POC needs foreground GPS to draw the blue dot, reveal 25 m fog discs, and produce logs for the renderer decision.
- Share-log should be easy to find during UAT, but should not become a settings/debug-menu project.
- Artifact naming should make the primary artifact obvious, for example `MirkFall-POC-unsigned-ios.ipa` and `MirkFall-POC-android-debug.apk`.

</specifics>

<deferred>
## Deferred Ideas

- Background GPS, notification permission, foreground services, Android background location, and iOS `locationAlways` are production migration scope, not Phase 3.
- A full debug menu, runtime log-level settings screen, historical log browser, gzip archive management, and production support tooling are deferred.
- Real-device gesture/fps UAT, threshold pass/fail analysis, and `docs/POC-RESULTS.md` belong to Phase 4.
- TestFlight/App Store signing, release APKs, app bundles, and production distribution are out of scope for this POC.

</deferred>

---

*Phase: 3-Mobile Runtime And Artifacts*
*Context gathered: 2026-05-02*
