---
phase: 02-same-pipeline-map-and-fog
plan: 03
subsystem: fog-infrastructure
tags: [fog, sdf, shader, projection, flutter_map, tdd]

requires:
  - phase: 02-same-pipeline-map-and-fog
    provides: Exact Phase 2 constants, copied atmospheric shader, and offline FlutterMap PMTiles rendering seam
provides:
  - Parent-derived reveal disc and viewport bbox domain types without Freezed or generated files
  - 256x256 midpoint-128 RGBA SDF builder using metre-space reveal-disc distance
  - MirkProjection and viewport fog clip path using matching metre-space geometry
  - 41-slot FogShaderUniforms surface with SDF sampler index 0 and identity SDF rect defaults
  - Triangle-wave helper and deterministic in-flight SDF cache
affects: [02-04-same-stack-fog-layer, phase-4-uat]

tech-stack:
  added: []
  patterns: [handwritten immutable domain records, metre-space SDF bytes before ui.Image decode, generic SDF cache with disposal callback, static shader layout test]

key-files:
  created:
    - lib/domain/mirk/mirk_viewport_bbox.dart
    - lib/domain/revealed/reveal_disc.dart
    - lib/infrastructure/mirk/animation_helpers.dart
    - lib/infrastructure/mirk/mirk_projection.dart
    - lib/infrastructure/mirk/sdf/revealed_sdf_builder.dart
    - lib/infrastructure/mirk/sdf/sdf_cache.dart
    - lib/infrastructure/mirk/shader/fog_shader_uniforms.dart
    - lib/presentation/widgets/fog_clip_path.dart
  modified:
    - test/domain/mirk/mirk_viewport_bbox_test.dart
    - test/domain/revealed/reveal_disc_test.dart
    - test/infrastructure/mirk/animation_helpers_test.dart
    - test/infrastructure/mirk/mirk_projection_test.dart
    - test/infrastructure/mirk/sdf/revealed_sdf_builder_test.dart
    - test/infrastructure/mirk/sdf/sdf_cache_test.dart
    - test/infrastructure/mirk/shader/fog_shader_uniforms_test.dart
    - test/presentation/widgets/fog_clip_path_test.dart

key-decisions:
  - "Kept reveal and bbox types handwritten and immutable to preserve parent semantics without introducing Freezed/codegen."
  - "Exposed SDF byte construction before ui.Image decode so the exact midpoint-128 RGBA semantics are testable."
  - "Made SdfCache generic with a disposal callback so duplicate-build and disposal behavior can be tested without dart:ui."
  - "Used a static shader layout test because ui.FragmentShader cannot be faked in direct Dart tests."

patterns-established:
  - "Fog geometry should use MirkViewportBbox.longitudeSpanDegrees and normalizeLongitudeForProjection for consistent antimeridian-aware projection."
  - "SDF and clip path radius calculations should both use geometric-mean metres-per-pixel at viewport mean latitude."
  - "Shader uniform changes must update the 41-slot static layout test and atmospheric_fog.frag together."

requirements-completed: [FOG-02, FOG-04, FOG-05, FOG-06, FOG-07]

duration: 14min
completed: 2026-05-02
---

# Phase 2 Plan 03: Fog Infrastructure Summary

**MirkFall reveal geometry, metre-space SDF bytes, fog clip path, 41-slot shader uniforms, and SDF cache are ready for same-stack FogLayer wiring**

## Performance

- **Duration:** 14 min
- **Started:** 2026-05-02T10:18:11Z
- **Completed:** 2026-05-02T10:31:47Z
- **Tasks:** 3
- **Files modified:** 16 implementation/test files

## Accomplishments

- Ported `RevealDisc` and `MirkViewportBbox` without Freezed, preserving Haversine distance, conservative bbox intersection, equality, assertions, and antimeridian bbox support.
- Ported SDF/projection/clip-path infrastructure with 256x256 RGBA SDF bytes, midpoint-128 encoding, metre-space distances, and viewport-minus-reveal-circle clipping.
- Ported `FogShaderUniforms` with exactly 41 float slots, sampler index 0, identity SDF rect defaults, parent triangle wave, and a deterministic in-flight `SdfCache`.
- Added focused tests for domain geometry, SDF bytes, projection, clip path, animation, cache behavior, and shader uniform layout.

## Task Commits

| Task | Name | Commit | Files |
| --- | --- | --- | --- |
| 1 RED | Add failing tests for reveal geometry | `5b28209` | `test/domain/mirk/mirk_viewport_bbox_test.dart`, `test/domain/revealed/reveal_disc_test.dart` |
| 1 GREEN | Port reveal geometry domain types | `fdcf789` | `lib/domain/mirk/mirk_viewport_bbox.dart`, `lib/domain/revealed/reveal_disc.dart` |
| 2 RED | Add failing tests for SDF projection and clip path | `6300a5d` | `test/infrastructure/mirk/mirk_projection_test.dart`, `test/infrastructure/mirk/sdf/revealed_sdf_builder_test.dart`, `test/presentation/widgets/fog_clip_path_test.dart` |
| 2 GREEN | Port SDF projection and fog clip geometry | `a120010` | `lib/infrastructure/mirk/mirk_projection.dart`, `lib/infrastructure/mirk/sdf/revealed_sdf_builder.dart`, `lib/presentation/widgets/fog_clip_path.dart` |
| 3 RED | Add failing tests for uniforms animation and cache | `087af31` | `test/infrastructure/mirk/animation_helpers_test.dart`, `test/infrastructure/mirk/sdf/sdf_cache_test.dart`, `test/infrastructure/mirk/shader/fog_shader_uniforms_test.dart` |
| 3 GREEN | Port uniforms animation and cache | `a987eb2` | `lib/infrastructure/mirk/animation_helpers.dart`, `lib/infrastructure/mirk/sdf/sdf_cache.dart`, `lib/infrastructure/mirk/shader/fog_shader_uniforms.dart` |
| Fix | Keep SDF test pixel indices strictly typed | `c83d186` | `test/infrastructure/mirk/sdf/revealed_sdf_builder_test.dart` |

## Files Created/Modified

- `lib/domain/mirk/mirk_viewport_bbox.dart` - Handwritten immutable bbox with antimeridian span/projection helpers.
- `lib/domain/revealed/reveal_disc.dart` - Reveal disc with Haversine distance and conservative metre-to-degree bbox intersection.
- `lib/infrastructure/mirk/sdf/revealed_sdf_builder.dart` - 256x256 midpoint-128 RGBA metre-space SDF builder and image decode surface.
- `lib/infrastructure/mirk/mirk_projection.dart` - Viewport lat/lon to screen projection.
- `lib/presentation/widgets/fog_clip_path.dart` - Viewport rect minus reveal-disc circle clip path.
- `lib/infrastructure/mirk/shader/fog_shader_uniforms.dart` - Atmospheric shader uniform writer with 41 slots and sampler 0.
- `lib/infrastructure/mirk/animation_helpers.dart` - Parent triangle-wave animation helper.
- `lib/infrastructure/mirk/sdf/sdf_cache.dart` - Deterministic cache that deduplicates identical in-flight SDF builds.
- `test/**` Plan 02-03 files - Focused domain, static, pure-Dart, and Flutter-only tests for the new surfaces.

## Decisions Made

- Kept the SDF cache generic instead of `ui.Image`-specific so cache semantics can be tested in this restricted shell; Plan 02-04 can use `SdfCache<ui.Image>`.
- Added `buildRgbaBytesFromDiscs` as the shared byte path before `ui.decodeImageFromPixels`, keeping image production and byte tests aligned.
- Used static source inspection for `FogShaderUniforms` slot order because `ui.FragmentShader` is not directly fakeable outside Flutter.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed strict typing in the Flutter SDF test**
- **Found during:** Final static verification after Task 3
- **Issue:** `num.clamp` returned a `num` where `_redAt` expected an `int`, which would fail strict analysis in `revealed_sdf_builder_test.dart`.
- **Fix:** Replaced the clamp call with an explicit `_clampedPixel(double)` helper returning `int`.
- **Files modified:** `test/infrastructure/mirk/sdf/revealed_sdf_builder_test.dart`
- **Verification:** `rg "\.clamp\(" test\infrastructure\mirk\sdf\revealed_sdf_builder_test.dart` returned no matches; full format check passed.
- **Committed in:** `c83d186`

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The fix only made the planned test source strict-analysis compatible.

## Verification

| Command | Outcome |
| --- | --- |
| `dart.exe --enable-asserts --packages=.dart_tool\package_config.json test\domain\revealed\reveal_disc_test.dart` | Passed: `+5: All tests passed!` |
| `dart.exe --enable-asserts --packages=.dart_tool\package_config.json test\domain\mirk\mirk_viewport_bbox_test.dart` | Passed: `+4: All tests passed!` |
| `dart.exe --enable-asserts --packages=.dart_tool\package_config.json test\infrastructure\mirk\animation_helpers_test.dart` | Passed: `+3: All tests passed!` |
| `dart.exe --enable-asserts --packages=.dart_tool\package_config.json test\infrastructure\mirk\sdf\sdf_cache_test.dart` | Passed: `+4: All tests passed!` |
| `dart.exe --enable-asserts --packages=.dart_tool\package_config.json test\infrastructure\mirk\shader\fog_shader_uniforms_test.dart` | Passed: `+4: All tests passed!` |
| `dart format --line-length 160 --set-exit-if-changed lib test` via direct `dart.exe` with repo-local env | Passed: `Formatted 34 files (0 changed)` |
| Direct header script: `dart.exe --packages=.dart_tool\package_config.json tool\check_headers.dart` | Passed: `check_headers: OK (40 files)` |
| Static SDF/clip scan for resolution, midpoint bytes, RGBA decode, projection normalization, and path difference | Passed: expected patterns present in implementation files. |
| `flutter test test/domain/revealed test/domain/mirk test/infrastructure/mirk test/presentation/widgets/fog_clip_path_test.dart` | Blocked: Flutter tool timed out after 45s before producing test output in this sandbox. |
| `flutter analyze --fatal-infos --fatal-warnings` | Blocked: Flutter tool timed out after 45s before producing analyzer output in this sandbox. |
| `dart analyze --fatal-infos --fatal-warnings` | Blocked: analysis server failed to start with `CreateFile failed 5 (Access is denied)`. |
| `dart run tool/check_headers.dart` | Blocked: native hook compilation failed with `CreateFile failed 5`; direct script invocation passed. |

## Issues Encountered

- Flutter-dependent tests for `ui.Image`, `Path`, and `Offset` are committed but could not run locally because the sandbox cannot start Flutter commands. These need CI or an unsandboxed local shell.
- `dart run` and `dart analyze` also hit the known Flutter SDK/native-hook access restrictions. Direct `dart.exe --packages` remained viable for pure/static tests and policy scripts.

## Known Stubs

None.

## Threat Flags

None - the new GPS/reveal geometry to shader sampler surface is the threat boundary already covered by T-2-07, T-2-08, and T-2-09 in the plan.

## User Setup Required

None.

## Next Phase Readiness

Plan 02-04 can mount `FogLayer` inside `FlutterMap.children` using the ported domain geometry, SDF builder/cache, clip path, and shader uniform writer. Remaining validation is Flutter-runtime execution of the committed image/path tests plus analyzer in an environment without SDK access restrictions.

## Self-Check: PASSED

- Created files exist: all 17 summary/implementation/test paths listed in the self-check command were found.
- Task commits exist: `5b28209`, `fdcf789`, `6300a5d`, `a120010`, `087af31`, `a987eb2`, `c83d186`.
- No tracked files were deleted by task commits.

---
*Phase: 02-same-pipeline-map-and-fog*
*Completed: 2026-05-02*
