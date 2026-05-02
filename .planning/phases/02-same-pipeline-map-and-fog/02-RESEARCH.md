# Phase 2: Same-Pipeline Map And Fog - Research

**Researched:** 2026-05-02
**Domain:** Offline PMTiles vector rendering in `flutter_map`, same-Canvas atmospheric fog rendering, seeded and in-memory reveal discs, and map/fog isolation controls for POC evidence.
**Confidence:** High on the implementation shape and parent fog code reuse; medium on final iOS FPS because that is the POC question.

## Phase Boundary

Phase 2 must turn the Phase 1 bootstrap shell into a usable renderer proof:

- Open the copied `Fra_Melun.pmtile` filesystem path through `vector_map_tiles_pmtiles`.
- Show a `flutter_map` map centered on Melun at `48.5397, 2.6553`, zoom `13`.
- Render the copied MirkFall atmospheric shader as a custom Flutter layer inside the same `FlutterMap.children` list as the vector tile layer.
- Port the MirkFall SDF, reveal disc, viewport bbox, projection, clip path, uniform slots, animation helper, and constants with minimal adaptation.
- Keep reveal discs in memory and seed at least one Melun disc so renderer validation does not depend on Phase 3's permission flow.
- Wire latest-fix blue dot and recenter surfaces through an injected location stream, while leaving foreground permission UI to Phase 3.
- Provide a map-only mode or toggle so vector tile cost can be separated from fog cost.

## Resolver-Correct Package Stack

Local pub-cache source inspection found a planning-critical version conflict: `vector_map_tiles 8.0.0` declares `flutter_map: ^7.0.2`, while the project initialization note mentioned `flutter_map 8.3.0`. The stable PMTiles chain in this repo must be solver-coherent:

| Package | Pin | Reason |
|---------|-----|--------|
| `flutter_map` | `7.0.2` | Resolver-compatible with `vector_map_tiles 8.0.0`; still pure Flutter and sufficient for the same-pipeline hypothesis. |
| `vector_map_tiles` | `8.0.0` | Stable vector tile layer package; `VectorTileLayerMode.raster` is the default and documented as best frame rate. |
| `vector_map_tiles_pmtiles` | `1.5.0` | PMTiles provider for local filesystem paths; depends on `vector_map_tiles ^8.0.0`. |
| `vector_tile_renderer` | `5.2.0` | Direct import only if needed to disambiguate its `Theme` type from Material `Theme`. |
| `pmtiles` | `1.2.0` | Direct import only if needed for archive lifecycle typing; provider exposes `archive.close()`. |
| `latlong2` | `0.9.1` | Required by `flutter_map` public APIs. |
| `geolocator` | `14.0.2` | Provides `Position` and the Phase 3 live stream adapter; Phase 2 does not request permission. |
| `logging` | `1.3.0` | Optional simple timing/event logging before Phase 3 file logger hardens output. |

Do not switch to `vector_map_tiles 9.0.0-beta.8` just to use `flutter_map 8.x`: the PMTiles adapter currently pins the stable 8.x vector layer, and beta rendering changes would weaken the POC evidence.

## Current Scaffold Facts

- Phase 1 has a valid Flutter app, strict analyzer config, exact direct dependency pins, guard scripts, and `DEPENDENCIES.md`.
- The PMTiles asset is bundled at `assets/maps/Fra_Melun.pmtile`, declared in `pubspec.yaml`, copied to app support under `maps/Fra_Melun.pmtile`, and validated by byte length/SHA-256.
- `lib/main.dart` currently displays the copied PMTiles filesystem path; Phase 2 should replace that proof screen with the map proof once the path future resolves.
- `.github/workflows/ci.yml` is gates-only; APK/IPA artifact jobs remain Phase 3.

## Target Architecture

```text
MirkPocApp
  PmtilesBootstrapScreen / MapBootstrap
    MapScreen(pmtilesPath)
      FlutterMap
        VectorTileLayer(PmTilesVectorTileProvider.fromSource(pmtilesPath))
        if fog enabled: FogLayer(CustomPaint + FragmentShader + SDF sampler)
        if latest fix exists: CircleLayer(blue dot)
      Floating controls
        Fog/map-only toggle
        Recenter latest fix
```

The fog layer must be a child of the same `FlutterMap` as the vector tile layer. For `flutter_map` 7.x, wrap the custom layer in `MobileLayerTransformer` so it receives the current map transform correctly. Avoid sibling overlays, delayed camera streams, external transform compensation, `RepaintBoundary` isolation around the fog layer, and MapLibre-style compensation math.

## Parent Code To Reuse

Copy or minimally adapt these MirkFall files:

| Parent file | Phase 2 target |
|-------------|----------------|
| `assets/shaders/atmospheric_fog.frag` | `assets/shaders/atmospheric_fog.frag` copied unchanged. |
| `lib/domain/revealed/reveal_disc.dart` | `lib/domain/revealed/reveal_disc.dart`, with no Freezed dependency. |
| `lib/domain/mirk/mirk_viewport_bbox.dart` | `lib/domain/mirk/mirk_viewport_bbox.dart`, handwritten immutable class. |
| `lib/infrastructure/mirk/sdf/revealed_sdf_builder.dart` | Same path, package names adapted. |
| `lib/infrastructure/mirk/tile_cell_iteration.dart` | `lib/presentation/widgets/fog_clip_path.dart` or same infrastructure path. |
| `lib/infrastructure/mirk/mirk_projection.dart` | Same path. |
| `lib/infrastructure/mirk/shader/fog_shader_uniforms.dart` | Same path, preserving 41 float slots and sampler 0. |
| `lib/infrastructure/mirk/animation_helpers.dart` | Same path, for curl-scale triangle wave. |
| `lib/config/constants.dart` | Add only relevant POC map/fog constants. |

The existing sibling POC at `C:\claude_checkouts\mirk-poc-debug` is also a useful pattern source for `MapScreen`, `FogLayer`, `SdfCache`, `BlueDotMarker`, and `RecenterFab`, but this repo's plan should remain scoped to its current simpler Phase 1 scaffold.

## Key Implementation Decisions

- Use `ProtomapsThemes.lightV3()` with source key `protomaps`. V4 themes embed remote sprite URLs and are not appropriate for the no-network POC.
- Leave `VectorTileLayer.layerMode` at its default `VectorTileLayerMode.raster` because the package source documents it as best frame rate.
- Keep `uSdfRectOriginX/Y = 0.0` and `uSdfRectSizeX/Y = 1.0`. Same-pipeline rendering should not need BUG-014 compensation.
- Read `MapCamera.of(context)` once per fog build and pass that camera snapshot into the painter; the painter must not re-read context.
- Use a live `Stopwatch` or ticker-backed repaint so `uTime` advances during idle animated fog without rebuilding the whole map.
- Build or cache the 256x256 SDF when the reveal disc list or viewport changes; do not rebuild on every animation tick.
- Seed one or more reveal discs around Melun and optionally expose a development tap-to-reveal action if it helps manual local validation.
- The production location stream can be an injected service seam in Phase 2. Phase 3 owns the permission rationale, grant/deny states, and durable logging.

## Pitfalls

| Pitfall | Prevention |
|---------|------------|
| Dependency solver conflict | Pin `flutter_map 7.0.2`, not `8.3.0`, unless the executor deliberately upgrades the whole vector/PMTiles chain and proves the license/solver graph. |
| Proving the wrong thing | Fog must be inside `FlutterMap.children`, not a sibling `Stack` overlay outside the map. |
| Stale or split camera state | One `MapCamera` read per `FogLayer.build`; pass it into projection, clip path, and painter. |
| Vector tile cost masking fog result | Add a map-only mode or toggle and keep it visible enough for UAT. |
| Shader slot regression | Preserve the 41-slot `FogShaderUniforms` layout and add a test that counts/records slots. |
| Degree-space reveal math | SDF and clip path compute distances in metres, including longitude cosine at mean latitude. |
| Shader first-frame failure | Load shader asynchronously and render a clear no-fog state or fallback until the shader is ready; tests must assert no crash before load. |
| Parent complexity drag | Do not import Freezed, Drift, sessions, or production map abstractions just to port fog math. |

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` plus existing `package:test` tool tests |
| Config | `analysis_options.yaml` with strict casts/inference/raw-types |
| Quick command | `flutter test test/presentation/screens/map_screen_test.dart test/presentation/widgets/fog_layer_test.dart` |
| Full command | `flutter test; dart test tool/test/; dart run tool/check_headers.dart; dart run tool/check_licenses.dart; dart run tool/check_dependencies_md.dart` |

### Requirement Test Map

| Req ID | Behavior | Suggested automated coverage |
|--------|----------|-------------------------------|
| MAP-03 | PMTiles provider opens copied filesystem path | MapScreen provider seam test or integration widget test with temp file/asset copy. |
| MAP-04 | Initial camera Melun z13 | Widget test inspects `FlutterMap.options.initialCenter` and `initialZoom`. |
| MAP-05 | Neutral basemap colors/theme | Test asserts V3 Protomaps/custom theme path and no V4 sprite URL. |
| MAP-06 | Map-only mode | Widget test toggles fog off and asserts `VectorTileLayer` remains while `FogLayer` is absent. |
| FOG-01 | Shader asset copied and declared | Asset bundle test plus `pubspec.yaml` static assertion. |
| FOG-02 | Parent fog/SDF/projection code ported | Unit tests for reveal disc bbox, metres distance, projection, constants. |
| FOG-03 | Fog layer inside map child stack | Widget test inspects `FlutterMap.children` order: tiles, fog, blue dot. |
| FOG-04 | 256x256 SDF image | Unit test samples empty, single-disc, and outside-disc SDF bytes. |
| FOG-05 | 41 float uniforms plus sampler 0 | Recording renderer or fake shader wrapper test verifies every slot value. |
| FOG-06 | Clip path subtracts reveal discs | Path bounds/center sample tests around seeded disc geometry. |
| FOG-07 | Atmospheric defaults and identity SDF rect | Uniform test verifies constants and `(0,0,1,1)` SDF rect. |
| LOC-04 | Blue dot above fog | Widget test emits latest fix and checks `CircleLayer` order after `FogLayer`. |
| LOC-05 | In-memory 25 m reveal discs from fixes | Controller/repository unit test appends one disc per accepted fix. |
| LOC-06 | Recenter to latest fix at zoom 15 | Widget test drives FAB animation and checks `MapController.move` calls. |

## Sources

- `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`
- `.planning/research/SUMMARY.md`, `STACK.md`, `ARCHITECTURE.md`, `FEATURES.md`, `PITFALLS.md`
- `C:\claude_checkouts\GOSL-MirkFall\docs\POC-flutter-map-mirk.md`
- `C:\claude_checkouts\GOSL-MirkFall\docs\phase09-bug-tracking\BUG-014-sdf-rect-offset-axes.md`
- MirkFall fog/SDF/shader source files listed in `.planning/PROJECT.md`
- Local pub-cache source for `flutter_map 7.0.2`, `flutter_map 8.3.0`, `vector_map_tiles 8.0.0`, `vector_map_tiles_pmtiles 1.5.0`, `pmtiles 1.2.0`, and `vector_tile_renderer 5.2.0`

## Research Complete

Phase 2 can be planned as four executable waves:

1. Dependencies, shader asset, constants, and audit updates.
2. Offline `FlutterMap` PMTiles rendering and map-only mode.
3. Fog domain/SDF/shader infrastructure port with focused tests.
4. Same-stack `FogLayer`, in-memory reveal discs, blue dot, recenter, and integration tests.
