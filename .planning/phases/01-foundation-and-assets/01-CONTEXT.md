# Phase 1: Foundation And Assets - Context

**Gathered:** 2026-05-02
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 1 delivers the smallest compliant Flutter foundation for the POC: project scaffold and identity, strict Dart/tooling gates, GOSL/header/license checks, the bundled Melun PMTiles asset, and a first-launch service that copies that asset to an app-support filesystem path. It does not deliver the live map, fog shader rendering, GPS permission flow, file logging/share UI, APK/IPA artifact builds, or UAT evidence; those remain in later roadmap phases.

</domain>

<decisions>
## Implementation Decisions

### App Identity And Scaffold
- **D-01:** Use the proven sibling-POC identity unless the user explicitly overrides it during planning: Dart package `mirk_poc_debug`, iOS bundle identifier `com.thongvan.mirkPocDebug`, Android application ID `com.thongvan.mirk_poc_debug`, display name `MirkFall POC`, and iOS `CFBundleName` `MirkPocDebug`.
- **D-02:** `CFBundleName` must never contain underscores or hyphens. Keep it SideStore-safe from the first scaffold commit because changing the bundle identifier after a sideload burns Apple free-account quota.
- **D-03:** Generate only the mobile platform scaffolds needed for this POC by default: iOS primary and Android secondary. Do not add web, macOS, Linux, or Windows app targets unless planning finds a concrete verification need.
- **D-04:** If the repo is still empty at execution time, scaffold with `flutter create --org com.thongvan --project-name mirk_poc_debug --platforms ios,android .`. If a scaffold already exists, adopt it and surgically fix metadata rather than re-running `flutter create` over existing platform files.

### PMTiles Asset Copy Contract
- **D-05:** Phase 1 bundles only `Fra_Melun.pmtile` as the required asset. The atmospheric shader and MirkFall fog/SDF donor Dart files remain Phase 2 work unless the planner deliberately pulls them forward for a test-only reason.
- **D-06:** Copy `C:\claude_checkouts\countries-pmtiles\Fra_Melun.pmtile` to `assets/maps/Fra_Melun.pmtile` and declare it in `pubspec.yaml` under `flutter.assets`.
- **D-07:** The runtime copy service writes to app support under `maps/Fra_Melun.pmtile`, uses filesystem paths only, and returns the copied absolute path for Phase 2's PMTiles provider.
- **D-08:** The copy service should be idempotent but self-healing: if the destination is missing, has the wrong byte length, or fails checksum validation, rewrite it via a temporary file and rename into place. Expected source size is `4,176,302` bytes and SHA-256 is `6BC39C03501D99DADC5C08994663FD07CDB18F6149FB5425C2AA933C7B09DDF1`.
- **D-09:** Add focused tests around the asset declaration and copy service. Do not build a polished asset-status UI; a minimal scaffold/error surface is enough for Phase 1.

### Dependency And License Gate
- **D-10:** Use exact dependency pins and commit `pubspec.lock`. No caret ranges for direct dependencies.
- **D-11:** Planning must verify that the map package chain actually resolves before locking it. Prior sibling research found that `flutter_map 8.x + vector_map_tiles 8.0.0 + vector_map_tiles_pmtiles 1.5.0` can be an incompatible mix; if map packages are added in Phase 1, use a resolver-coherent chain and document any deviation from `.planning/research/STACK.md`.
- **D-12:** Port or adapt the existing parent/sibling guard scripts instead of reimplementing them from scratch: `tool/check_headers.dart`, `tool/check_licenses.dart`, and `tool/check_dependencies_md.dart`.
- **D-13:** The license gate fails on GPL, AGPL, LGPL, SSPL, telemetry/analytics SDKs, and unknown licenses unless an explicit reviewed allowlist entry exists. `DEPENDENCIES.md` should include a telemetry column so the "no automatic network egress" rule is reviewable.
- **D-14:** Every committed `.dart` file in `lib/`, `test/`, and `tool/` must start with the required three-line GOSL header. Generated files may be excluded by exact patterns only.

### CI And Platform Baseline
- **D-15:** Phase 1 CI should implement the gates job from CI-01: `flutter pub get`, `dart format --line-length 160 --set-exit-if-changed .`, `flutter analyze --fatal-infos --fatal-warnings`, tests, header check, license check, and dependency-table freshness check.
- **D-16:** APK and unsigned IPA artifact jobs are Phase 3 scope. Do not expand Phase 1 into artifact delivery unless the roadmap is updated.
- **D-17:** Set SideStore-sensitive iOS metadata in Phase 1 (`CFBundleName`, display name, bundle identifier, and no non-exempt encryption). Add the `permission_handler` Podfile macro in the same phase/commit that first adds a Dart permission request; do not add background-location metadata in Phase 1.
- **D-18:** Keep strict analyzer settings enabled from the first scaffold commit: `strict-casts`, `strict-inference`, and `strict-raw-types`; use `dart format --line-length 160`.

### Agent Discretion
- The planner may decide whether the asset-copy service runs before `runApp()` or behind a tiny bootstrap screen, as long as MAP-02 is objectively testable and failures are not swallowed.
- The planner may decide whether to port guard scripts from `GOSL-MirkFall` or the sibling `mirk-poc-debug` checkout; prefer the version with fewer adaptations for this repo.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Current Project
- `.planning/PROJECT.md` - Project scope, required external references, file-header constraint, PMTiles source path, Flutter/iOS constraints.
- `.planning/REQUIREMENTS.md` - Phase 1 requirement mapping: FOUND-01..05, MAP-01..02, CI-01.
- `.planning/ROADMAP.md` - Phase 1 boundary, success criteria, and later-phase exclusions.
- `.planning/STATE.md` - Current phase and project status.
- `.planning/research/STACK.md` - Local stack findings; verify package compatibility before locking pins.
- `.planning/research/PITFALLS.md` - PMTiles asset-loading pitfall, iOS permission macro pitfall, dependency-drift pitfall.
- `.planning/research/ARCHITECTURE.md` - Same-pipeline architecture context; mostly Phase 2, but explains why Phase 1 must not reintroduce MapLibre.

### Parent And Sibling References
- `C:\claude_checkouts\GOSL-MirkFall\docs\POC-flutter-map-mirk.md` - Original POC spec and target behavior.
- `C:\claude_checkouts\GOSL-MirkFall\docs\phase09-bug-tracking\BUG-014-sdf-rect-offset-axes.md` - Root BUG-014 evidence; do not plan MapLibre overlay compensation.
- `C:\claude_checkouts\mirk-poc-debug\docs\flutter-ios-specifics.md` - SideStore `CFBundleName`, permission macro, privacy manifest, and CI/iOS gotchas.
- `C:\claude_checkouts\mirk-poc-debug\.planning\phases\01-foundation\01-01-SUMMARY.md` - Proven scaffold identity, asset bundling, strict pins, and asset tests from sibling POC.
- `C:\claude_checkouts\mirk-poc-debug\.planning\phases\01-foundation\01-02-SUMMARY.md` - Proven header/license/dependency guard scripts and iOS metadata decisions from sibling POC.
- `C:\claude_checkouts\mirk-poc-debug\.planning\research\STACK.md` - Important package-chain compatibility warning and exact-pin strategy.

### Source Assets
- `C:\claude_checkouts\countries-pmtiles\Fra_Melun.pmtile` - Required Melun PMTiles source, 4,176,302 bytes, SHA-256 `6BC39C03501D99DADC5C08994663FD07CDB18F6149FB5425C2AA933C7B09DDF1`.
- `C:\claude_checkouts\GOSL-MirkFall\tool\check_headers.dart` - Parent GOSL header gate candidate.
- `C:\claude_checkouts\GOSL-MirkFall\tool\check_licenses.dart` - Parent license gate candidate.
- `C:\claude_checkouts\GOSL-MirkFall\tool\check_dependencies_md.dart` - Parent dependency-table freshness gate candidate.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Current checkout: no Flutter scaffold exists yet; the repo contains planning docs and `AGENTS.md`.
- PMTiles source: `Fra_Melun.pmtile` exists at the required external path and is small enough for direct asset bundling.
- Guard scripts: parent and sibling checkouts contain mature Dart scripts for GOSL header, license, and dependency-audit gates.
- Sibling POC: `C:\claude_checkouts\mirk-poc-debug` contains a proven implementation of the SideStore identity and CI guard pattern, but this phase should copy only foundation pieces that match the current roadmap.

### Established Patterns
- Use exact pins and a committed lockfile for reproducibility.
- Keep generated Dart files out of header checks by exact exclusion patterns.
- Use structured Dart tooling/tests for policy checks; do not rely on ad hoc shell greps in CI.
- Use filesystem paths for PMTiles at runtime; Flutter asset URIs are packaging inputs only.

### Integration Points
- `pubspec.yaml` owns package name, asset declaration, exact pins, and Flutter SDK constraints.
- `analysis_options.yaml` owns strict analyzer settings.
- `.github/workflows/ci.yml` owns CI-01 gates only in Phase 1.
- `ios/Runner/Info.plist` and Xcode project settings own SideStore-sensitive app identity.
- The PMTiles copy service should live in an infrastructure module with injectable filesystem/asset dependencies so it can be tested without real device storage.

</code_context>

<specifics>
## Specific Ideas

- Agent fallback defaults were used because Codex interactive question UI is unavailable in Default mode. The defaults are based on current project docs plus the proven sibling POC.
- Preserve the current roadmap split: Phase 1 foundation and PMTiles copy only; Phase 2 proves map/fog same-pipeline rendering; Phase 3 adds permissions/logging/artifacts.
- The planner should explicitly call out any package-version choice that differs from either `.planning/research/STACK.md` or the sibling compatibility warning.

</specifics>

<deferred>
## Deferred Ideas

- Atmospheric shader bundling, MirkFall fog/SDF donor Dart files, seeded reveal discs, map-only mode, and blue GPS dot are Phase 2 decisions.
- Permission rationale UI, foreground GPS request, synchronous file logging/share diagnostics, Podfile `PERMISSION_LOCATION=1`, and unsigned IPA/APK artifact jobs are Phase 3 decisions unless the roadmap is updated.
- iOS/Android UAT evidence and final migration decision are Phase 4 decisions.

</deferred>

---

*Phase: 1-Foundation And Assets*
*Context gathered: 2026-05-02*
