# Phase 1: Foundation And Assets - Research

**Researched:** 2026-05-02
**Domain:** Flutter mobile scaffold, PMTiles asset packaging, dependency policy gates, CI lint gates
**Confidence:** HIGH for project constraints and reusable local patterns; MEDIUM for package currency because registry access is deferred to execution-time `flutter pub get`

## Summary

Phase 1 should establish a small, compliant Flutter mobile app and the policy gates that keep later renderer work honest. The work should not attempt to render `flutter_map`, request GPS permission, add file logging, or build IPA/APK artifacts; those are explicitly later roadmap phases. [VERIFIED: `.planning/ROADMAP.md`, `.planning/phases/01-foundation-and-assets/01-CONTEXT.md`]

The load-bearing implementation detail for this phase is PMTiles packaging: `Fra_Melun.pmtile` must be copied from `C:\claude_checkouts\countries-pmtiles\Fra_Melun.pmtile` into `assets/maps/Fra_Melun.pmtile`, declared in `pubspec.yaml`, then copied on first launch to an app-support filesystem path. The copy service must be idempotent and self-healing with both size and SHA-256 validation because Phase 2's PMTiles provider consumes a real filesystem path, not a Flutter asset URI. [VERIFIED: `.planning/PROJECT.md`, `.planning/research/PITFALLS.md`, `01-CONTEXT.md`]

**Primary recommendation:** scaffold iOS+Android only, pin the Phase 1 dependencies exactly, implement a tested checksum-validating PMTiles copy service, port the proven Dart guard scripts, and wire only the CI-01 gates job in GitHub Actions. [VERIFIED: `.planning/REQUIREMENTS.md`, sibling summaries under `C:\claude_checkouts\mirk-poc-debug\.planning\phases\01-foundation\`]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| Flutter project scaffold and app identity | Mobile app platform layer | Flutter app shell | Bundle ID, Android app ID, and SideStore-safe `CFBundleName` live in generated platform files and must be correct before sideloading. |
| Strict analyzer, headers, and formatting | Tooling / CI | Flutter app source | Local analyzer config and CI gates enforce code quality for every later phase. |
| PMTiles asset packaging | Flutter asset bundle | App support filesystem | Flutter assets package the source bytes; runtime map loaders need a copied filesystem path. |
| PMTiles copy service | Flutter app infrastructure | Platform filesystem plugin | `path_provider` supplies app-support storage; app code owns checksum, temp-file write, and returned absolute path. |
| Dependency/license/telemetry gates | Tooling / CI | Dependency audit document | Dart scripts and `DEPENDENCIES.md` enforce GOSL policy before later features add more packages. |

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Use the proven sibling-POC identity unless the user explicitly overrides it during planning: Dart package `mirk_poc_debug`, iOS bundle identifier `com.thongvan.mirkPocDebug`, Android application ID `com.thongvan.mirk_poc_debug`, display name `MirkFall POC`, and iOS `CFBundleName` `MirkPocDebug`.
- **D-02:** `CFBundleName` must never contain underscores or hyphens. Keep it SideStore-safe from the first scaffold commit because changing the bundle identifier after a sideload burns Apple free-account quota.
- **D-03:** Generate only the mobile platform scaffolds needed for this POC by default: iOS primary and Android secondary. Do not add web, macOS, Linux, or Windows app targets unless planning finds a concrete verification need.
- **D-04:** If the repo is still empty at execution time, scaffold with `flutter create --org com.thongvan --project-name mirk_poc_debug --platforms ios,android .`. If a scaffold already exists, adopt it and surgically fix metadata rather than re-running `flutter create` over existing platform files.
- **D-05:** Phase 1 bundles only `Fra_Melun.pmtile` as the required asset. The atmospheric shader and MirkFall fog/SDF donor Dart files remain Phase 2 work unless the planner deliberately pulls them forward for a test-only reason.
- **D-06:** Copy `C:\claude_checkouts\countries-pmtiles\Fra_Melun.pmtile` to `assets/maps/Fra_Melun.pmtile` and declare it in `pubspec.yaml` under `flutter.assets`.
- **D-07:** The runtime copy service writes to app support under `maps/Fra_Melun.pmtile`, uses filesystem paths only, and returns the copied absolute path for Phase 2's PMTiles provider.
- **D-08:** The copy service should be idempotent but self-healing: if the destination is missing, has the wrong byte length, or fails checksum validation, rewrite it via a temporary file and rename into place. Expected source size is `4,176,302` bytes and SHA-256 is `6BC39C03501D99DADC5C08994663FD07CDB18F6149FB5425C2AA933C7B09DDF1`.
- **D-09:** Add focused tests around the asset declaration and copy service. Do not build a polished asset-status UI; a minimal scaffold/error surface is enough for Phase 1.
- **D-10:** Use exact dependency pins and commit `pubspec.lock`. No caret ranges for direct dependencies.
- **D-11:** Planning must verify that the map package chain actually resolves before locking it. Prior sibling research found that `flutter_map 8.x + vector_map_tiles 8.0.0 + vector_map_tiles_pmtiles 1.5.0` can be an incompatible mix; if map packages are added in Phase 1, use a resolver-coherent chain and document any deviation from `.planning/research/STACK.md`.
- **D-12:** Port or adapt the existing parent/sibling guard scripts instead of reimplementing them from scratch: `tool/check_headers.dart`, `tool/check_licenses.dart`, and `tool/check_dependencies_md.dart`.
- **D-13:** The license gate fails on GPL, AGPL, LGPL, SSPL, telemetry/analytics SDKs, and unknown licenses unless an explicit reviewed allowlist entry exists. `DEPENDENCIES.md` should include a telemetry column so the "no automatic network egress" rule is reviewable.
- **D-14:** Every committed `.dart` file in `lib/`, `test/`, and `tool/` must start with the required three-line GOSL header. Generated files may be excluded by exact patterns only.
- **D-15:** Phase 1 CI should implement the gates job from CI-01: `flutter pub get`, `dart format --line-length 160 --set-exit-if-changed .`, `flutter analyze --fatal-infos --fatal-warnings`, tests, header check, license check, and dependency-table freshness check.
- **D-16:** APK and unsigned IPA artifact jobs are Phase 3 scope. Do not expand Phase 1 into artifact delivery unless the roadmap is updated.
- **D-17:** Set SideStore-sensitive iOS metadata in Phase 1 (`CFBundleName`, display name, bundle identifier, and no non-exempt encryption). Add the `permission_handler` Podfile macro in the same phase/commit that first adds a Dart permission request; do not add background-location metadata in Phase 1.
- **D-18:** Keep strict analyzer settings enabled from the first scaffold commit: `strict-casts`, `strict-inference`, and `strict-raw-types`; use `dart format --line-length 160`.

### the agent's Discretion
- The planner may decide whether the asset-copy service runs before `runApp()` or behind a tiny bootstrap screen, as long as MAP-02 is objectively testable and failures are not swallowed.
- The planner may decide whether to port guard scripts from `GOSL-MirkFall` or the sibling `mirk-poc-debug` checkout; prefer the version with fewer adaptations for this repo.

### Deferred Ideas (OUT OF SCOPE)
- Atmospheric shader bundling, MirkFall fog/SDF donor Dart files, seeded reveal discs, map-only mode, and blue GPS dot are Phase 2 decisions.
- Permission rationale UI, foreground GPS request, synchronous file logging/share diagnostics, Podfile `PERMISSION_LOCATION=1`, and unsigned IPA/APK artifact jobs are Phase 3 decisions unless the roadmap is updated.
- iOS/Android UAT evidence and final migration decision are Phase 4 decisions.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FOUND-01 | Developer can run a Flutter app scaffold with SideStore-compatible identity. | Use `flutter create --org com.thongvan --project-name mirk_poc_debug --platforms ios,android .`, then set iOS bundle ID, Android application ID, display name, `CFBundleName=MirkPocDebug`, and `ITSAppUsesNonExemptEncryption=false`. |
| FOUND-02 | `dart format --line-length 160 --set-exit-if-changed .` passes. | Commit `analysis_options.yaml`, run `dart format --line-length 160 .`, and wire CI format check. |
| FOUND-03 | `flutter analyze --fatal-infos --fatal-warnings` passes with strict settings. | Enable strict casts/inference/raw types from first scaffold commit. |
| FOUND-04 | Every committed `.dart` file starts with the GOSL header. | Port/adapt `tool/check_headers.dart` and add it to CI. |
| FOUND-05 | CI rejects disallowed licenses and unknown licenses unless allowlisted. | Port/adapt `tool/check_licenses.dart`, add telemetry/package denylist, and keep `DEPENDENCIES.md` fresh. |
| MAP-01 | App bundles `Fra_Melun.pmtile` and declares it in `pubspec.yaml`. | Copy verified source file to `assets/maps/Fra_Melun.pmtile`, declare under `flutter.assets`, and test bundle loading. |
| MAP-02 | App copies bundled PMTiles to app support filesystem path on first launch. | Implement `PmtilesAssetCopier.ensureCopied()` with size/hash validation, temp-file rewrite, app-support `maps/` target, and tests using fake assets/temp dirs. |
| CI-01 | GitHub Actions lint job runs pub get, format, analyze, dependency/license/header checks, and tests. | Add one gates job only; APK/IPA build jobs remain Phase 3. |
</phase_requirements>

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter SDK | 3.41.7 | Mobile scaffold and CI toolchain | Matches `.planning/PROJECT.md` and parent CI baseline. |
| Dart SDK | bundled with Flutter 3.41.7 | Language/runtime | Do not pin separately; use `environment.sdk` compatible with the bundled Dart. |
| `path_provider` | 2.1.5 | Application support directory | Parent and sibling projects already use this package for app directories. |
| `path` | 1.9.1 | Cross-platform path joins | Required by guard scripts and filesystem code; avoids slash concatenation. |
| `crypto` | 3.0.7 | SHA-256 validation for PMTiles copy | Required by D-08 checksum validation; parent pins this version. |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `cupertino_icons` | 1.0.9 | Default Flutter icon font | Keep scaffold conventional; no telemetry. |
| `flutter_lints` | 6.0.0 | Base lint rules | Combine with strict analyzer settings. |
| `yaml` | 3.1.3 | Tool script parsing | Used by license and dependency-table guard scripts. |
| `test` | 1.30.0 | Dart `tool/test/` runner | Required because the parent guard script tests use `package:test/test.dart`. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Add map packages in Phase 1 | `flutter_map` + vector tile chain | Not required for MAP-01/MAP-02; deferring avoids locking a renderer chain before Phase 2 and respects D-11. |
| Size-only copy validation | No `crypto` dependency | Faster but violates D-08; checksum validation is locked. |
| Reimplement guard scripts | New small scripts | Higher policy risk than adapting parent/sibling scripts that already handle BOMs, generated files, SPDX parsing, and dependency markdown drift. |

**Installation:** use exact pins in `pubspec.yaml`; run `flutter pub get` and commit `pubspec.lock`.

## Architecture Patterns

### System Architecture Diagram

```text
Flutter app launch
  -> WidgetsFlutterBinding.ensureInitialized()
  -> PmtilesAssetCopier.ensureCopied()
      -> rootBundle.load("assets/maps/Fra_Melun.pmtile")
      -> getApplicationSupportDirectory()
      -> validate existing support/maps/Fra_Melun.pmtile by length + SHA-256
      -> write temp file + validate temp + rename into place when needed
  -> runApp(MirkPocApp(copiedPath or bootError))
```

### Recommended Project Structure

```text
assets/
  maps/Fra_Melun.pmtile
lib/
  config/constants.dart
  infrastructure/pmtiles/pmtiles_asset_copier.dart
  main.dart
test/
  assets/asset_bundle_test.dart
  infrastructure/pmtiles/pmtiles_asset_copier_test.dart
tool/
  check_headers.dart
  check_licenses.dart
  check_dependencies_md.dart
  test/
```

### Pattern 1: PMTiles Copy Service

**What:** A single infrastructure class returns the absolute app-support path, recopying only when the destination is missing, has the wrong byte length, or fails SHA-256 validation.

**When to use:** Phase 2 map loading should consume this returned path rather than asset URIs.

**Implementation notes:** load the bundled bytes once per check, compute SHA-256 with `crypto`, write to a same-directory temp path, validate the temp file, then rename into place. On Windows, deleting an existing corrupt destination before rename is acceptable because the next run self-heals if interrupted.

### Pattern 2: Policy-as-Dart Tools

**What:** Keep header, license, and dependency freshness checks as Dart scripts under `tool/` with dedicated tests under `tool/test/`.

**When to use:** CI-01 must run these scripts after `flutter pub get`, so they can inspect `pubspec.lock`, `.dart_tool/package_config.json`, and the checked-in source tree.

### Anti-Patterns to Avoid

- Do not use `asset:///assets/maps/...` as the runtime PMTiles source; Phase 2 needs a filesystem path.
- Do not add MapLibre, MapLibre compensation layers, telemetry SDKs, analytics SDKs, or ad SDKs.
- Do not add permission requests or `PERMISSION_LOCATION=1` in Phase 1; D-17 ties that macro to the phase that first adds Dart permission code.
- Do not add iOS/Android build artifact jobs in Phase 1; D-16 assigns them to Phase 3.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| App support directory discovery | Platform channel or hardcoded paths | `path_provider` | Handles iOS/Android support directories correctly. |
| SHA-256 | Custom hash implementation | `crypto` | D-08 needs real SHA-256; cryptographic primitives should not be hand-written. |
| YAML parsing for guard scripts | String-splitting YAML | `yaml` | `pubspec.lock` and `pubspec.yaml` need structured parsing. |
| Header/license policy logic | Shell greps only | Dart guard scripts | Cross-platform, testable, and easier to keep in CI. |

## Common Pitfalls

### Pitfall 1: PMTiles Copy Looks Green But Cannot Feed Phase 2
**What goes wrong:** The app can load the asset through `rootBundle`, but no copied filesystem path exists.
**Why it happens:** Flutter assets are packaged resources, not stable file paths.
**How to avoid:** MAP-02 must return the absolute app-support path and tests must assert it is absolute and under `maps/Fra_Melun.pmtile`.
**Warning signs:** Code passes `asset:///...` or `rootBundle` data directly to a future PMTiles provider.

### Pitfall 2: Scaffold Metadata Burns SideStore Time
**What goes wrong:** `CFBundleName` contains `mirk_poc_debug`, causing SideStore/App-ID errors later.
**Why it happens:** `flutter create` defaults `CFBundleName` from the snake_case project name.
**How to avoid:** Patch `CFBundleName` to `MirkPocDebug` in Phase 1 and add an automated Info.plist test or static assertion.
**Warning signs:** `CFBundleName` contains `_` or `-`.

### Pitfall 3: Header Gate Fails On Generated Files
**What goes wrong:** The header checker scans generated Dart files under `.dart_tool`, `build`, or generated suffixes.
**Why it happens:** The scanner lacks exact exclusions.
**How to avoid:** Port parent exclusion patterns and test them.
**Warning signs:** `check_headers` reports `.g.dart`, `.freezed.dart`, platform generated files, or `.dart_tool` files.

### Pitfall 4: License Gate Only Checks Direct Dependencies
**What goes wrong:** Transitive package drift introduces a forbidden or unknown license.
**Why it happens:** `DEPENDENCIES.md` is not cross-checked against `pubspec.lock`.
**How to avoid:** CI must run both license resolution and dependency-table freshness after `flutter pub get`.
**Warning signs:** `DEPENDENCIES.md` lacks transitive rows after `pubspec.lock` changes.

## Code Examples

### PMTiles Copy Sketch

```dart
final supportDir = await getApplicationSupportDirectory();
final mapsDir = Directory(p.join(supportDir.path, kPmtilesMapsSubdir));
await mapsDir.create(recursive: true);
final destination = File(p.join(mapsDir.path, kPmtilesBasename));
if (await _isValidCopy(destination)) {
  return destination.path;
}
final bytes = await rootBundle.load(kPmtilesAssetPath);
final temp = File('${destination.path}.tmp');
await temp.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
await _validateFile(temp);
if (await destination.exists()) {
  await destination.delete();
}
await temp.rename(destination.path);
return destination.path;
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Open PMTiles from asset URI | Copy asset to app support and pass filesystem path | Current project research, 2026-05-02 | Prevents Phase 2 provider failures. |
| Float direct dependency ranges | Exact pins plus committed lockfile | Current project context | Reproducible CI and license audit. |
| Full artifact CI in foundation | CI-01 gates only | Current roadmap | Keeps Phase 1 from absorbing Phase 3. |

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| None | All planning-critical claims come from local project docs, parent/sibling files, or execution-time verification commands. | All | N/A |

## Open Questions (RESOLVED)

1. **Should Phase 1 add the map renderer dependency chain?** RESOLVED: No. Phase 1 does not render a map, and D-11 warns that the map chain must be resolver-coherent if added. Phase 2 should choose and lock that chain when it implements MAP-03..06.
2. **Is `crypto` justified despite the sibling POC avoiding it?** RESOLVED: Yes. This project's D-08 explicitly requires SHA-256 validation for the copied PMTiles file.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Flutter CLI | Scaffold, pub get, analyze, tests | To be checked during execution | Target 3.41.7 | If missing, executor should stop with setup blocker. |
| Source PMTiles file | MAP-01 asset copy | Verified at `C:\claude_checkouts\countries-pmtiles\Fra_Melun.pmtile` | 4,176,302 bytes, SHA-256 `6BC39C03501D99DADC5C08994663FD07CDB18F6149FB5425C2AA933C7B09DDF1` | No fallback; this exact file is required. |
| GitHub Actions | CI-01 | Remote service, workflow file only in Phase 1 | N/A | Local commands are the fallback verification if CI cannot be triggered. |

**Missing dependencies with no fallback:**
- Flutter CLI if not installed or not matching the required SDK range.

**Missing dependencies with fallback:**
- None.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` from Flutter SDK plus `test: 1.30.0` for `tool/test/` |
| Config file | `analysis_options.yaml` |
| Quick run command | `flutter test test/assets/asset_bundle_test.dart test/infrastructure/pmtiles/pmtiles_asset_copier_test.dart` |
| Full suite command | `dart format --line-length 160 --set-exit-if-changed .; flutter analyze --fatal-infos --fatal-warnings; dart test tool/test/; flutter test; dart run tool/check_headers.dart; dart run tool/check_licenses.dart; dart run tool/check_dependencies_md.dart` |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| FOUND-01 | Scaffold identity and platform metadata are SideStore-safe. | unit/static | `flutter test test/platform/platform_metadata_test.dart` | Wave 0 |
| FOUND-02 | Formatting is stable at 160 columns. | tooling | `dart format --line-length 160 --set-exit-if-changed .` | Built in |
| FOUND-03 | Strict analyzer passes. | tooling | `flutter analyze --fatal-infos --fatal-warnings` | Built in |
| FOUND-04 | Dart files have GOSL headers. | tooling | `dart run tool/check_headers.dart` | Wave 3 |
| FOUND-05 | Disallowed/unknown licenses and telemetry packages fail. | tooling | `dart run tool/check_licenses.dart` | Wave 3 |
| MAP-01 | PMTiles asset is declared and loadable. | widget/unit | `flutter test test/assets/asset_bundle_test.dart` | Wave 2 |
| MAP-02 | PMTiles copy service returns a valid app-support filesystem path and self-heals corrupt copies. | unit | `flutter test test/infrastructure/pmtiles/pmtiles_asset_copier_test.dart` | Wave 2 |
| CI-01 | GitHub Actions gates run all required checks. | static/tooling | `flutter test test/ci/ci_workflow_test.dart` | Wave 3 |

### Sampling Rate
- **Per task commit:** Run the task-specific automated command.
- **Per wave merge:** Run all commands for that wave's plan.
- **Phase gate:** Full suite green before `$gsd-execute-phase` completes.

### Wave 0 Gaps
- `test/platform/platform_metadata_test.dart` - covers FOUND-01.
- `test/assets/asset_bundle_test.dart` - covers MAP-01.
- `test/infrastructure/pmtiles/pmtiles_asset_copier_test.dart` - covers MAP-02.
- `tool/test/check_headers_test.dart`, `tool/test/check_licenses_test.dart`, `tool/test/check_dependencies_md_test.dart` - cover FOUND-04/FOUND-05.
- `test/ci/ci_workflow_test.dart` - covers CI-01 workflow content.

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no | No accounts or sessions in Phase 1. |
| V3 Session Management | no | No sessions in Phase 1. |
| V4 Access Control | no | Local single-user POC. |
| V5 Input Validation | yes | Validate asset byte length, SHA-256, and filesystem paths before returning them. |
| V6 Cryptography | yes | Use `crypto` SHA-256; do not hand-roll hashing. |
| V14 Configuration | yes | CI gates enforce dependency, license, telemetry, format, analyzer, and header policy. |

### Known Threat Patterns for This Phase

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Corrupt or partial PMTiles copy reused | Tampering | Validate size and SHA-256 before returning existing copies; rewrite via temp file. |
| Disallowed transitive dependency lands unnoticed | Tampering / Information Disclosure | License/dependency freshness gates parse `pubspec.lock` after `flutter pub get`. |
| Telemetry SDK introduced by dependency | Information Disclosure | Deny known analytics/telemetry packages and require telemetry column in `DEPENDENCIES.md`. |
| Platform identity drift | Spoofing | Automated metadata test for bundle ID, app ID, display name, and `CFBundleName`. |

## Sources

### Primary (HIGH confidence)
- `.planning/PROJECT.md` - scope, PMTiles source, Flutter/iOS constraints, hard constraints.
- `.planning/REQUIREMENTS.md` - Phase 1 requirement IDs and traceability.
- `.planning/ROADMAP.md` - Phase boundary and later-phase exclusions.
- `.planning/phases/01-foundation-and-assets/01-CONTEXT.md` - locked implementation decisions D-01..D-18.
- `.planning/research/STACK.md`, `.planning/research/PITFALLS.md`, `.planning/research/ARCHITECTURE.md` - package and architecture findings.
- `C:\claude_checkouts\countries-pmtiles\Fra_Melun.pmtile` - required asset, verified size and SHA-256.

### Secondary (MEDIUM confidence)
- `C:\claude_checkouts\mirk-poc-debug\.planning\phases\01-foundation\01-01-SUMMARY.md` and `01-02-SUMMARY.md` - proven sibling scaffold and guard-script patterns.
- `C:\claude_checkouts\mirk-poc-debug\docs\flutter-ios-specifics.md` - SideStore, `CFBundleName`, Podfile, and CI gotchas from sibling UAT.
- `C:\claude_checkouts\GOSL-MirkFall\tool\check_headers.dart`, `check_licenses.dart`, `check_dependencies_md.dart` - parent guard script candidates.

### Tertiary (LOW confidence)
- None used for planning-critical claims.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH for Phase 1 pins from parent/sibling, MEDIUM for package currency until `flutter pub get` resolves.
- Architecture: HIGH because Phase 1 only concerns local Flutter assets, app support storage, and CI tooling.
- Pitfalls: HIGH because they are documented in current project context and sibling UAT summaries.

**Research date:** 2026-05-02
**Valid until:** 2026-06-01 for local project constraints; revalidate package versions whenever `pubspec.lock` changes.
