# Phase 3 Pattern Map

**Created:** 2026-05-02
**Purpose:** Map planned Phase 3 files to closest existing analogs so execution can reuse proven local patterns.

## Current Repo Patterns

| Target | Closest local analog | Pattern to preserve |
|--------|----------------------|---------------------|
| Runtime shell in `lib/main.dart` | Current `MirkPocApp` and `PmtilesBootstrapScreen` | Keep PMTiles bootstrap as the map startup boundary, but place it behind the permission gate and logger bootstrap. |
| Live GPS input | `MapScreenServices.latestFixStream` and `GeoFix` | Adapt plugin data outside map/fog widgets; emit `GeoFix` into the existing stream seam. |
| Reveal updates | `RevealDiscRepository.appendFix` | Every accepted finite/in-range fix becomes one 25 m in-memory reveal disc. |
| Map controls | `MapModeToggle`, `RecenterFab`, `MapScreen` overlay positioning | Add share-log as another compact SafeArea overlay; do not create a debug/settings shell. |
| Constants | `lib/config/constants.dart` | Add logging cap and any runtime constants in the same flat `const` style. |
| Platform guard tests | `test/platform/platform_metadata_test.dart` | Extend with static metadata assertions for Podfile, privacy manifest, usage strings, and Android foreground location permissions. |
| CI guard tests | `test/ci/ci_workflow_test.dart` | Evolve from gates-only assertions to gates-plus-artifact assertions. |
| Dependency audit | `DEPENDENCIES.md`, `tool/check_licenses.dart`, `tool/check_dependencies_md.dart` | Exact pins and explicit telemetry/license rows for all new packages and transitives. |

## Parent And Sibling Patterns

| Target | Reference | Notes |
|--------|-----------|-------|
| `FileLogger` | `C:\claude_checkouts\mirk-poc-debug\docs\flutter-ios-specifics.md` | Follow the documented RAF sync-write pattern exactly; do not modernize to `IOSink`. |
| `FileLoggerLifecycleObserver` | Same iOS specifics doc | Observer calls the logger flush compatibility hook on inactive/paused/detached transitions. |
| iOS `Podfile` macros | Same iOS specifics doc and local `permission_handler` README | Add `PERMISSION_LOCATION=1` in `post_install`. |
| Share-log API | Same iOS specifics doc and local `share_plus` source | Use `SharePlus.instance.share(ShareParams(files: <XFile>[...]))`. |
| IPA packaging | `C:\claude_checkouts\GOSL-MirkFall\docs\POC-flutter-map-mirk.md` | Package `Payload/Runner.app` into an unsigned `.ipa` for SideStore. |

## Planned File Ownership

| Plan | Primary ownership | Notes |
|------|-------------------|-------|
| 03-01 | Dependency and platform metadata files | Avoid editing runtime UI beyond tests that guard metadata. |
| 03-02 | Logging infrastructure and diagnostic hooks | Owns logger core, lifecycle observer, frame timing logger, and instrumentation hooks. |
| 03-03 | Permission/location runtime and share-log UI | Owns permission gate screens, location stream service, MapScreen share control, and app shell state transitions. |
| 03-04 | CI workflow and final guard tests | Owns `.github/workflows/ci.yml` and workflow tests. |

## Anti-Patterns To Avoid

- Do not add `locationAlways`, `ACCESS_BACKGROUND_LOCATION`, `UIBackgroundModes`, notification permission, Android foreground services, or production background tracking UI.
- Do not request location automatically on app start before showing the rationale screen.
- Do not import `permission_handler`, `geolocator`, or `share_plus` directly inside `FogLayer` or reveal domain objects.
- Do not use `IOSink`, async logger writes, broad `catch (Object)`, or recursive `Logger` calls from logger failure handling.
- Do not add analytics, crash reporting, telemetry SDKs, MapLibre, Mapbox, GPL, AGPL, LGPL, or SSPL dependencies.
- Do not upload raw `Runner.app` as the iOS artifact; SideStore needs the unsigned IPA zip shape.
- Do not replace the map/fog screen with a debug dashboard; Phase 4 needs the center gesture area clear.
