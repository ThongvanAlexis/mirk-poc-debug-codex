---
phase: 02
slug: same-pipeline-map-and-fog
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-02
---

# Phase 2 - Validation Strategy

Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter `flutter_test` plus existing Dart `package:test` tool tests |
| **Config file** | `analysis_options.yaml` |
| **Quick run command** | `flutter test test/presentation/screens/map_screen_test.dart test/presentation/widgets/fog_layer_test.dart` |
| **Full suite command** | `flutter test; dart test tool/test/; dart run tool/check_headers.dart; dart run tool/check_licenses.dart; dart run tool/check_dependencies_md.dart` |
| **Estimated runtime** | 60-180 seconds locally, depending on Flutter tool availability |

## Sampling Rate

- **After every task commit:** Run the plan's targeted `flutter test` command plus `dart format --line-length 160 --set-exit-if-changed` on touched Dart paths.
- **After every plan wave:** Run `flutter analyze --fatal-infos --fatal-warnings` and the relevant policy scripts.
- **Before `$gsd-verify-work`:** Full suite and policy gates must be green in CI or in an unsandboxed local shell.
- **Max feedback latency:** One task commit.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | MAP-03, FOG-01 | T-2-01 | Dependency graph stays license-clean and exact-pinned | policy | `dart run tool/check_licenses.dart && dart run tool/check_dependencies_md.dart` | yes | pending |
| 02-01-02 | 01 | 1 | FOG-01, FOG-05 | T-2-02 | Shader asset is declared and uniform layout is pinned | unit/static | `flutter test test/assets/shader_asset_test.dart test/infrastructure/mirk/shader/fog_shader_uniforms_test.dart` | W1 | pending |
| 02-02-01 | 02 | 2 | MAP-03, MAP-04 | T-2-03 | PMTiles opens from copied filesystem path only | widget | `flutter test test/presentation/screens/map_screen_test.dart` | W2 | pending |
| 02-02-02 | 02 | 2 | MAP-05, MAP-06 | T-2-04 | No remote-sprite theme and map-only mode stays available | widget/static | `flutter test test/presentation/screens/map_screen_test.dart test/presentation/widgets/map_mode_toggle_test.dart` | W2 | pending |
| 02-03-01 | 03 | 3 | FOG-02, FOG-04 | T-2-05 | SDF/reveal math remains metre-space and bounded | unit | `flutter test test/infrastructure/mirk/sdf/revealed_sdf_builder_test.dart test/domain/revealed/reveal_disc_test.dart` | W3 | pending |
| 02-03-02 | 03 | 3 | FOG-05, FOG-06, FOG-07 | T-2-06 | Shader slots and identity SDF rect are defended | unit/widget | `flutter test test/infrastructure/mirk/shader/fog_shader_uniforms_test.dart test/presentation/widgets/fog_clip_path_test.dart` | W3 | pending |
| 02-04-01 | 04 | 4 | FOG-03, FOG-07 | T-2-07 | Fog layer is inside `FlutterMap.children` and uses one camera snapshot | widget | `flutter test test/presentation/widgets/fog_layer_test.dart test/presentation/screens/map_screen_fog_test.dart` | W4 | pending |
| 02-04-02 | 04 | 4 | LOC-04, LOC-05, LOC-06 | T-2-08 | Fixes only mutate in-memory state and recenter uses latest fix | unit/widget | `flutter test test/domain/revealed/reveal_disc_repository_test.dart test/presentation/widgets/recenter_fab_test.dart` | W4 | pending |

## Wave 0 Requirements

Existing infrastructure covers planning-time validation. Each execution plan creates its own missing tests before or with production code.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Visual fog-map lock during gestures | FOG-03, FOG-07 | Requires interactive pan/zoom/combo gestures and target device perception | Phase 4 UAT records pass/fail. Phase 2 only needs app surfaces and map-only toggle ready. |
| iOS FPS with fog | MAP-06, FOG-03 | Target device performance is the POC decision | Phase 4 UAT measures and logs. Phase 2 adds the toggle so the cost can be isolated. |

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or explicit manual deferral.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify.
- [x] No watch-mode flags.
- [x] Feedback latency is one task commit.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** pending execution
