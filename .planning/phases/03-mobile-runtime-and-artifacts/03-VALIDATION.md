---
phase: 03
slug: mobile-runtime-and-artifacts
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-02
---

# Phase 3 - Validation Strategy

Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter `flutter_test` plus existing Dart `package:test` tool tests |
| **Config file** | `analysis_options.yaml` |
| **Quick run command** | `flutter test test/infrastructure/logging test/presentation/screens test/presentation/widgets` |
| **Full suite command** | `flutter test; dart test tool/test/; dart run tool/check_headers.dart; dart run tool/check_licenses.dart; dart run tool/check_dependencies_md.dart` |
| **Estimated runtime** | 60-240 seconds locally, depending on Flutter tool availability |

## Sampling Rate

- **After every task commit:** Run the plan's targeted `flutter test` or `dart test` command plus `dart format --line-length 160 --set-exit-if-changed` on touched Dart paths.
- **After every plan wave:** Run `flutter analyze --fatal-infos --fatal-warnings` and the relevant policy scripts.
- **Before `$gsd-verify-work`:** Full suite and policy gates must be green in CI or in an unsandboxed local shell.
- **Max feedback latency:** One task commit.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | CI-04, CI-05 | T-3-01 | Permission metadata is foreground-only and SideStore-safe | static | `flutter test test/platform/platform_metadata_test.dart` | yes | pending |
| 03-01-02 | 01 | 1 | CI-04, CI-05 | T-3-02 | New packages are exact-pinned and license/telemetry-clean | policy | `flutter pub get; dart run tool/check_licenses.dart; dart run tool/check_dependencies_md.dart` | yes | pending |
| 03-02-01 | 02 | 2 | LOG-01, LOG-02, LOG-03 | T-3-03 | Logger writes JSONL synchronously and never deletes the active log | unit | `flutter test test/infrastructure/logging/file_logger_test.dart` | W2 | pending |
| 03-02-02 | 02 | 2 | LOG-05 | T-3-04 | Evidence timing markers are emitted without destabilizing rendering | unit/static | `flutter test test/infrastructure/logging test/presentation/widgets/fog_layer_test.dart test/presentation/screens/map_screen_test.dart` | W2 | pending |
| 03-03-01 | 03 | 3 | LOC-01, LOC-02, LOC-03 | T-3-05 | Permission request is user-triggered and denial recovery works | widget/unit | `flutter test test/presentation/screens/permission_gate_test.dart test/infrastructure/location` | W3 | pending |
| 03-03-02 | 03 | 3 | LOC-02, LOG-04, LOG-05 | T-3-06 | Live fixes feed existing reveal seam and share-log uses active file only | widget/unit | `flutter test test/presentation/screens/map_screen_location_test.dart test/presentation/widgets/share_log_button_test.dart` | W3 | pending |
| 03-04-01 | 04 | 4 | CI-02, CI-03 | T-3-07 | CI uploads debug APK and unsigned IPA in the required shape | static | `flutter test test/ci/ci_workflow_test.dart` | yes | pending |
| 03-04-02 | 04 | 4 | CI-01..CI-05 | T-3-08 | Final gates keep format, analysis, headers, licenses, tests, and artifacts intact | full | `flutter test; dart test tool/test/; dart run tool/check_headers.dart; dart run tool/check_licenses.dart; dart run tool/check_dependencies_md.dart` | yes | pending |

## Wave 0 Requirements

Existing infrastructure covers planning-time validation. Each execution plan creates its own missing tests before or with production code.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| iOS permission dialog appears from sideloaded app | LOC-01, LOC-02, CI-04, CI-05 | Requires real unsigned IPA installed through SideStore | Phase 4 UAT installs the IPA, taps `Enable Location`, and confirms the native when-in-use dialog appears. |
| Share sheet appears with active log attached | LOG-04 | Requires platform share UI on device/simulator | Phase 4 UAT taps `Share active log` and confirms the log file is offered as an attachment. |
| GPS stream emits during foreground walking | LOC-02 | Requires device location hardware or simulator route | Phase 4 UAT verifies blue dot/reveal updates and checks JSONL events. |

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or explicit manual deferral.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify.
- [x] No watch-mode flags.
- [x] Feedback latency is one task commit.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** pending execution
