# Phase 2 Pattern Map

**Created:** 2026-05-02
**Purpose:** Map planned Phase 2 files to closest existing analogs so execution can reuse proven patterns.

## Current Repo Patterns

| Target | Closest local analog | Pattern to preserve |
|--------|----------------------|---------------------|
| `lib/main.dart` map bootstrap | Current `PmtilesBootstrapScreen` | Keep the copied PMTiles path future as the app's startup boundary, but hand it to `MapScreen` instead of displaying the raw path. |
| `lib/config/constants.dart` | Existing PMTiles constants | Add map/fog constants in the same simple const style; no runtime config or generated files. |
| `pubspec.yaml` / `DEPENDENCIES.md` | Phase 1 dependency gate setup | Exact direct pins only; update the dependency audit after `flutter pub get`. |
| `tool/check_licenses.dart` | Existing license policy | Direct and transitive package additions must pass GPL/AGPL/LGPL/SSPL/telemetry denial rules. |
| Tests under `test/infrastructure/pmtiles/` | `pmtiles_asset_copier_test.dart` | Prefer temp directories, fake seams, and pure-Dart validation when Flutter/plugin surfaces are hard to run in the sandbox. |

## Parent MirkFall Patterns

| Target | Parent analog | Notes |
|--------|---------------|-------|
| `assets/shaders/atmospheric_fog.frag` | `GOSL-MirkFall/assets/shaders/atmospheric_fog.frag` | Copy unchanged. If altered, update `FogShaderUniforms` and tests in the same commit. |
| `lib/domain/revealed/reveal_disc.dart` | `GOSL-MirkFall/lib/domain/revealed/reveal_disc.dart` | Keep Haversine, bbox intersection, and metre semantics; remove session persistence complexity if needed. |
| `lib/domain/mirk/mirk_viewport_bbox.dart` | Parent Freezed bbox | Handwrite an immutable class to avoid Freezed/codegen in the POC. |
| `lib/infrastructure/mirk/sdf/revealed_sdf_builder.dart` | Parent SDF builder | Preserve 256x256 RGBA midpoint-128 encoding and metre-space distance. |
| `lib/infrastructure/mirk/mirk_projection.dart` | Parent projection | Preserve viewport north-to-screen-y=0 convention. |
| `lib/infrastructure/mirk/shader/fog_shader_uniforms.dart` | Parent uniform setter | Preserve 41 float slots and sampler index 0 exactly. |
| `lib/infrastructure/mirk/animation_helpers.dart` | Parent triangle wave helper | Use for curl-scale animation. |

## Sibling POC Patterns

The sibling checkout `C:\claude_checkouts\mirk-poc-debug` already contains working patterns worth consulting during execution:

| Target | Sibling analog |
|--------|----------------|
| `MapScreen` with `FlutterMap` and PMTiles provider | `lib/presentation/screens/map_screen.dart` |
| `FogLayer` using `MobileLayerTransformer`, one camera snapshot, ticker repaint, and identity SDF rect | `lib/presentation/widgets/fog_layer.dart` |
| In-memory reveal disc repository | `lib/domain/revealed/reveal_disc_repository.dart` |
| SDF caching and rebuild logging | `lib/infrastructure/mirk/sdf/sdf_cache.dart`, `lib/infrastructure/mirk/sdf_rebuild_logger.dart` |
| Blue dot marker | `lib/presentation/widgets/blue_dot_marker.dart` |
| Recenter FAB | `lib/presentation/widgets/recenter_fab.dart` |

Use sibling code as a pattern, not as a blind copy. This repo has a simpler Phase 1 scaffold, no l10n, and Phase 3 owns durable logging and permission flow.

## Anti-Patterns To Avoid

- Do not add MapLibre, Mapbox, or overlay compensation code.
- Do not add Freezed, Drift, session persistence, background GPS, or production map abstractions.
- Do not use `asset:///...` as the PMTiles source; Phase 1 already gives a copied filesystem path.
- Do not use `ProtomapsThemes.lightV4()` unless execution also proves no runtime sprite network fetch.
- Do not wrap the fog layer in a separate sibling `Stack` overlay outside `FlutterMap`.
- Do not rebuild the vector tile theme or PMTiles provider on every build.
