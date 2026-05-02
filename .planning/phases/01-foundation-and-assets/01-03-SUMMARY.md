---
phase: 01-foundation-and-assets
plan: 03
subsystem: infra
tags: [ci, dependency-audit, licenses, headers, telemetry]

requires:
  - phase: 01-foundation-and-assets
    provides: "Flutter scaffold, pubspec.lock, and workspace package config."
provides:
  - "GOSL header gate for hand-written Dart files under lib, test, tool, and integration_test."
  - "License and telemetry policy gate for every non-SDK pubspec.lock package."
  - "DEPENDENCIES.md freshness gate tied to pubspec.lock versions."
  - "Dependency audit document with direct, dev, and transitive package rows."
  - "GitHub Actions CI-01 gates-only workflow."
  - "Guard script and workflow tests."
affects: [phase-2-map-fog, phase-3-artifacts]

tech-stack:
  added: []
  patterns:
    - "Policy scripts are plain Dart entrypoints runnable through `dart run tool/...` in CI."
    - "DEPENDENCIES.md is complete for non-SDK lockfile packages and checked by version."
    - "CI-01 explicitly excludes APK/IPA builds and artifact upload until Phase 3."

key-files:
  created:
    - "tool/check_headers.dart"
    - "tool/check_licenses.dart"
    - "tool/check_dependencies_md.dart"
    - "tool/test/check_headers_test.dart"
    - "tool/test/check_licenses_test.dart"
    - "tool/test/check_dependencies_md_test.dart"
    - "DEPENDENCIES.md"
    - ".github/workflows/ci.yml"
    - "test/ci/ci_workflow_test.dart"
  modified: []

key-decisions:
  - "The license gate fails closed on unresolved package licenses instead of relying only on DEPENDENCIES.md prose."
  - "Telemetry/ad/analytics/MapLibre/Mapbox package names are denied before license resolution."
  - "The workflow test protects Phase 1 from accidentally growing Phase 3 build or upload jobs."

patterns-established:
  - "Use workspace-only APPDATA/LOCALAPPDATA/PUB_CACHE when running Dart commands in this sandbox."
  - "When the package:test runner is unavailable, direct pure-Dart verifier scripts can still exercise guard logic without changing committed code."

requirements-completed: [FOUND-02, FOUND-03, FOUND-04, FOUND-05, CI-01]

duration: 39 min
completed: 2026-05-02
---

# Phase 1 Plan 03: Policy Gates and CI Summary

**Executable compliance gates for formatting, analysis, tests, GOSL headers, license/telemetry policy, dependency audit freshness, and CI-01 workflow scope.**

## Performance

- **Duration:** 39 min
- **Completed:** 2026-05-02
- **Tasks:** 3
- **Files modified:** 9

## Accomplishments

- Added three guard scripts: `check_headers.dart`, `check_licenses.dart`, and `check_dependencies_md.dart`.
- Added focused tests for all guard scripts plus a CI workflow test that requires CI-01 commands and rejects build/upload artifact jobs.
- Generated `DEPENDENCIES.md` with all 75 non-SDK packages from `pubspec.lock`, including license, source, telemetry review, and audit date columns.
- Added `.github/workflows/ci.yml` with the gates-only job on `workflow_dispatch`, `pull_request`, and `push`.

## Task Commits

1. **Tasks 1-3: Guard scripts, dependency audit, and CI workflow** - `a9e8ed9` (feat)

## Verification

- `dart pub get --offline` - passed with workspace `PUB_CACHE`.
- `dart format --line-length 160 --set-exit-if-changed .` - passed.
- `dart --packages=.dart_tool/package_config.json tool/check_headers.dart` - passed, 15 files.
- `dart --packages=.dart_tool/package_config.json tool/check_licenses.dart` - passed, 75 packages.
- `dart --packages=.dart_tool/package_config.json tool/check_dependencies_md.dart` - passed, 75 packages.
- Custom pure-Dart verifier `.tmp/verify_policy.dart` - passed positive and negative paths for headers, dependency freshness, license denial, MapLibre denial, and CI workflow scope.

## Deviations from Plan

### Environment-limited Verification

**1. [Rule 3 - Blocking] `dart test` and `flutter test` cannot run inside this sandbox**
- **Found during:** Task 1 and Task 3 verification
- **Issue:** `dart test` triggers Dart native asset hooks that spawn child compile processes through `cmd.exe`, and this sandbox rejects that process creation with `Access is denied`. Direct package test runner also fails while registering SIGINT.
- **Fix:** Kept the committed `package:test` coverage in place for CI and added a temporary direct verifier under `.tmp/` to exercise the same policy logic locally without the test harness.
- **Verification:** `.tmp/verify_policy.dart` exited 0 and demonstrated both pass and fail cases for the guard behavior.

**2. [Rule 3 - Blocking] `flutter analyze` / `flutter test` remain wrapper-blocked locally**
- **Found during:** Task 3 verification
- **Issue:** Flutter commands cannot complete in this sandbox because helper process and SDK/user-cache access are denied or hang behind the wrapper.
- **Fix:** The CI workflow now runs the exact intended Flutter gates in GitHub Actions; direct Dart policy gates were verified locally.
- **Verification:** Workflow text is covered by `test/ci/ci_workflow_test.dart` and `.tmp/verify_policy.dart`.

**Total deviations:** 2 environment-limited verification gaps.
**Impact on plan:** Committed CI and test artifacts are present; local sandbox cannot execute the full Flutter/test runner surface.

## Issues Encountered

No product-scope issues. The remaining unverified commands are environment blocked, not code failures observed from the guard scripts.

## User Setup Required

None.

## Next Phase Readiness

Phase 2 can add map/fog dependencies and code under executable guardrails: every new Dart file must carry the GOSL header, every package must pass the license/telemetry gate, and `DEPENDENCIES.md` must stay synchronized with `pubspec.lock`.

## Self-Check: PASSED WITH SANDBOX LIMITATIONS

All Wave 3 files exist, direct policy gates pass, dependency audit covers every non-SDK lockfile package, and the CI workflow remains gates-only. Full `dart test`, `flutter analyze`, and `flutter test` execution is deferred to CI or an unsandboxed local shell.

---
*Phase: 01-foundation-and-assets*
*Completed: 2026-05-02*
