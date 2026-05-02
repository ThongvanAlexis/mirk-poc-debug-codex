---
phase: 1
slug: foundation-and-assets
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-05-02
---

# Phase 1 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter SDK `flutter_test` plus Dart `test: 1.30.0` for `tool/test/` |
| **Config file** | `analysis_options.yaml` |
| **Quick run command** | `flutter test test/assets/asset_bundle_test.dart test/infrastructure/pmtiles/pmtiles_asset_copier_test.dart` |
| **Full suite command** | `dart format --line-length 160 --set-exit-if-changed .; flutter analyze --fatal-infos --fatal-warnings; dart test tool/test/; flutter test; dart run tool/check_headers.dart; dart run tool/check_licenses.dart; dart run tool/check_dependencies_md.dart` |
| **Estimated runtime** | ~60 seconds locally after dependencies are cached |

---

## Sampling Rate

- **After every task commit:** Run the task-specific `<automated>` command from the active plan.
- **After every plan wave:** Run that plan's verification command set.
- **Before `$gsd-verify-work`:** Full suite must be green.
- **Max feedback latency:** 60 seconds for focused tests; full gates may exceed this on cold Flutter caches.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 1-01-01 | 01 | 1 | FOUND-01 | T-1-01 | SideStore-safe identity is asserted before execution proceeds. | static/unit | `flutter test test/platform/platform_metadata_test.dart` | W0 | pending |
| 1-01-02 | 01 | 1 | FOUND-02, FOUND-03, FOUND-04 | T-1-02 | Strict analyzer and required headers are enforced from first scaffold. | tooling | `dart format --line-length 160 --set-exit-if-changed .; flutter analyze --fatal-infos --fatal-warnings` | built in | pending |
| 1-02-01 | 02 | 2 | MAP-01 | T-1-03 | Bundled PMTiles bytes match the expected file identity. | unit | `flutter test test/assets/asset_bundle_test.dart` | W0 | pending |
| 1-02-02 | 02 | 2 | MAP-02 | T-1-03 | Existing destination is trusted only after size and SHA-256 validation. | unit | `flutter test test/infrastructure/pmtiles/pmtiles_asset_copier_test.dart` | W0 | pending |
| 1-02-03 | 02 | 2 | MAP-02 | T-1-03 | Launch path surfaces copy success or error; failures are not swallowed. | unit/widget | `flutter test test/infrastructure/pmtiles/pmtiles_asset_copier_test.dart test/widget_test.dart` | W0 | pending |
| 1-03-01 | 03 | 3 | FOUND-04, FOUND-05 | T-1-04 | Policy scripts fail closed on missing headers, unknown licenses, disallowed licenses, and telemetry packages. | tooling | `dart test tool/test/` | W0 | pending |
| 1-03-02 | 03 | 3 | CI-01 | T-1-04 | CI gates invoke the same checks required locally and omit Phase 3 artifact jobs. | static/unit | `flutter test test/ci/ci_workflow_test.dart` | W0 | pending |
| 1-03-03 | 03 | 3 | FOUND-02, FOUND-03, FOUND-04, FOUND-05, CI-01 | T-1-04 | Full gates pass together after pub resolution. | tooling | `dart format --line-length 160 --set-exit-if-changed .; flutter analyze --fatal-infos --fatal-warnings; dart test tool/test/; flutter test; dart run tool/check_headers.dart; dart run tool/check_licenses.dart; dart run tool/check_dependencies_md.dart` | built in | pending |

*Status: pending / green / red / flaky*

---

## Wave 0 Requirements

- [ ] `test/platform/platform_metadata_test.dart` - static assertions for package identity, Android app ID, iOS bundle ID, `CFBundleName`, display name, and no non-exempt encryption.
- [ ] `test/assets/asset_bundle_test.dart` - asset declaration and PMTiles size/hash assertions.
- [ ] `test/infrastructure/pmtiles/pmtiles_asset_copier_test.dart` - copy service first-copy, idempotent valid-copy, size mismatch, checksum mismatch, temp-file rewrite, and error propagation.
- [ ] `tool/test/check_headers_test.dart` - GOSL header gate behavior.
- [ ] `tool/test/check_licenses_test.dart` - license, unknown license, telemetry denylist, and manual allowlist behavior.
- [ ] `tool/test/check_dependencies_md_test.dart` - `DEPENDENCIES.md` freshness behavior.
- [ ] `test/ci/ci_workflow_test.dart` - CI-01 workflow content and Phase 3 artifact-job exclusion.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| None | N/A | Phase 1 can be verified through static checks and local tests. | N/A |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify.
- [x] Wave 0 covers all MISSING references.
- [x] No watch-mode flags.
- [x] Feedback latency target documented.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** pending execution
