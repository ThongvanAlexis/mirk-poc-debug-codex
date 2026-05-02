---
phase: 02-same-pipeline-map-and-fog
verified: 2026-05-02T11:09:24.526Z
status: passed
score: 19/19 must-haves verified
overrides_applied: 0
deferred:
  - truth: "Real-device visual sync and fps during pan, zoom, combined gestures"
    addressed_in: "Phase 4"
    evidence: "Phase 4 success criteria cover iOS gesture sync, 30+ fps with fog, 50+ fps static animated fog, SDF latency evidence, Android comparison, and final decision output."
---

# Phase 2: Same-Pipeline Map And Fog Verification Report

**Phase Goal:** Prove the core renderer hypothesis in-app: `flutter_map` vector tiles and atmospheric fog paint in the same Flutter map stack.  
**Verified:** 2026-05-02T11:09:24.526Z  
**Status:** passed  
**Re-verification:** No, initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Map opens offline on Melun from the copied PMTiles filesystem path. | VERIFIED | `main.dart` routes `ensureFlutterPmtilesAssetCopied()` into `MapScreenServices.pmtilesPath`; `MapScreen._openProvider()` rejects `http`, `https`, and `asset://`, then calls `PmTilesVectorTileProvider.fromSource(pmtilesPath)`. PMTiles copier tests passed and asset hash/size match constants. |
| 2 | Fog shader can render above the map using the copied atmospheric shader and 256x256 SDF sampler. | VERIFIED | `pubspec.yaml` declares `assets/shaders/atmospheric_fog.frag`; local shader hash equals the parent MirkFall shader hash `4E18352D...AAB6FF`; `FogLayer` uses `FogShaderUniforms.setAll()`, `FogShaderUniforms.identitySdfRect`, and `SdfCache<ui.Image>`. |
| 3 | Reveal discs create holes in fog, and clip path/SDF geometry use the same metre-space convention. | VERIFIED | `RevealDiscRepository` seeds Melun discs and appends 25 m discs from accepted fixes; `RevealedSdfBuilder` builds midpoint-128 RGBA SDF bytes using metre-space x/y distances; `buildViewportFogClipPathFromDiscs()` subtracts projected reveal-disc circles using the same viewport/bbox convention. |
| 4 | Fog layer lives inside the `FlutterMap` child stack, not as a stale external overlay. | VERIFIED | `createPocMapChildren()` creates `VectorTileLayer`, conditionally adds `FogLayer`, then adds the latest-fix `CircleLayer`; anti-pattern scan found no `Positioned.fill(child: FogLayer)`, `RepaintBoundary`, MapLibre, or Mapbox references in Phase 2 implementation files. |
| 5 | Map-only mode or equivalent toggle exists so vector tile cost can be separated from fog cost. | VERIFIED | `MapModeToggle` selects `MapDisplayMode.mapOnly` or `mapWithFog`; `createPocMapChildren()` always keeps `VectorTileLayer` mounted and only gates `FogLayer` on `mapWithFog`. |
| 6 | MAP-03: app loads Melun vector tiles through `vector_map_tiles_pmtiles` from the copied filesystem path. | VERIFIED | `pubspec.yaml` pins `vector_map_tiles_pmtiles: 1.5.0`; provider wiring uses `PmTilesVectorTileProvider.fromSource(widget.services.pmtilesPath)` after local-path validation. |
| 7 | MAP-04: user sees a `flutter_map` map centered on Melun at `48.5397`, `2.6553`, zoom `13`. | VERIFIED | `createPocMapOptions()` returns `MapOptions(initialCenter: LatLng(kPocInitialLatitude, kPocInitialLongitude), initialZoom: kPocInitialZoom)` and constants lock `48.5397`, `2.6553`, and `13.0`. |
| 8 | MAP-05: map styling approximates MirkFall neutral basemap colors. | VERIFIED | `createPocMapThemeStyle()` defines background, land, landcover, water, buildings, roads, and boundaries with neutral MirkFall-derived colors and no remote sprite/glyph metadata. |
| 9 | MAP-06: app can render map without fog for performance comparison. | VERIFIED | Default `MapScreenServices.initialDisplayMode` is `mapOnly`; map-only gating removes only `FogLayer` while leaving `VectorTileLayer` in `FlutterMap.children`. |
| 10 | FOG-01: atmospheric shader is copied from MirkFall without visual simplification. | VERIFIED | Local and parent shader SHA-256 hashes match exactly; shader is declared under `flutter.shaders`. |
| 11 | FOG-02: reveal disc, viewport bbox, SDF, projection, clip, uniforms, animation, and fog constants are ported/adapted. | VERIFIED | Implementation exists under `lib/domain/mirk`, `lib/domain/revealed`, `lib/infrastructure/mirk`, and `lib/presentation/widgets/fog_clip_path.dart`; direct tests for constants, reveal, bbox, cache, uniforms, and animation passed. |
| 12 | FOG-03: fog renders as a `flutter_map` custom Flutter layer in the same map child stack as vector tiles. | VERIFIED | `FogLayer extends StatefulWidget`, wraps `CustomPaint` in `MobileLayerTransformer`, and is added from `createPocMapChildren()` after `VectorTileLayer`. |
| 13 | FOG-04: fog layer builds a 256x256 SDF from reveal discs using metre-space distance. | VERIFIED | `RevealedSdfBuilder.resolution = kMirkFogSdfResolution`; `kMirkFogSdfResolution = 256`; builder converts viewport degrees to metres per pixel before distance sampling. |
| 14 | FOG-05: fog layer binds 41 float uniforms and one SDF sampler. | VERIFIED | `FogShaderUniforms.totalFloatSlots = 41`; source writes float slots 0 through 40 and calls `shader.setImageSampler(0, sdfImage)`. |
| 15 | FOG-06: fog layer clips shader rect to unrevealed map area using reveal-disc screen geometry. | VERIFIED | `_FogPainter.paint()` calls `buildViewportFogClipPathFromDiscs(...)`, clips the canvas, then draws the shader rect. |
| 16 | FOG-07: atmospheric defaults, curl-scale triangle wave, and identity SDF rect are used. | VERIFIED | `FogLayer` uses atmospheric constants, `triangleWave(...)`, and `FogShaderUniforms.identitySdfRect`; constants lock identity `(0, 0, 1, 1)`. |
| 17 | LOC-04: latest GPS position renders as a blue dot above fog. | VERIFIED | `latestFix != null` adds `CircleLayer` after `FogLayer`; `BlueDotMarker.build()` uses blue fill, white stroke, and pixel radius constants. |
| 18 | LOC-05: app creates an in-memory 25 m reveal disc for each accepted GPS fix. | VERIFIED | `GeoFix.isAcceptedForReveal` validates finite/range coordinates; `RevealDiscRepository.appendFix()` appends a `RevealDisc` with `kPocRevealDiscRadiusMeters = 25.0` and notifies listeners. |
| 19 | LOC-06: user can tap recenter to latest GPS fix at zoom `15`. | VERIFIED | `RecenterFab` disables when `latestFix == null`; `_recenterToLatestFix()` calls `_mapController.move(fix.latLng, kPocRecenterZoom)` with `kPocRecenterZoom = 15.0`. |

**Score:** 19/19 must-haves verified

### Deferred Items

Items not yet met but explicitly addressed in later milestone phases.

| # | Item | Addressed In | Evidence |
|---|------|-------------|----------|
| 1 | Real-device proof that fog stays visually locked during iOS pan, zoom, and combined gestures at target fps. | Phase 4 | ROADMAP Phase 4 success criteria and UAT-02 through UAT-07 cover gesture sync, 30+ fps with fog, 50+ fps static animated fog, and SDF latency. |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `pubspec.yaml` / `pubspec.lock` | Resolver-coherent Phase 2 map/fog package graph | VERIFIED | Exact pins include `flutter_map 7.0.2`, `vector_map_tiles 8.0.0`, `vector_map_tiles_pmtiles 1.5.0`, `vector_tile_renderer 5.2.0`, `pmtiles 1.2.0`, `latlong2 0.9.1`, `geolocator 14.0.2`, and `logging 1.3.0`. |
| `assets/maps/Fra_Melun.pmtile` | Bundled Melun PMTiles asset | VERIFIED | Size is `4,176,302` bytes and SHA-256 is `6bc39c03501d99dadc5c08994663fd07cdb18f6149fb5425c2aa933c7b09ddf1`. |
| `assets/shaders/atmospheric_fog.frag` | Parent MirkFall atmospheric fog shader | VERIFIED | SHA-256 matches parent source exactly and scalar SDF rect uniforms are present. |
| `lib/config/constants.dart` | Renderer-critical constants | VERIFIED | Melun camera, source key `protomaps`, reveal radius 25 m, SDF resolution 256, atmospheric defaults, blue-dot constants, and identity SDF rect exist. |
| `lib/infrastructure/pmtiles/*` | Copy bundled PMTiles to app support filesystem path | VERIFIED | Copier validates length/hash, repairs invalid copies, and returns absolute filesystem path. |
| `lib/presentation/screens/map_screen.dart` | PMTiles-backed `FlutterMap` with vector/fog/blue-dot child stack | VERIFIED | Owns `MapController`, provider lifecycle, shader/cache/reveal state, map-only toggle, latest-fix stream, and recenter. |
| `lib/infrastructure/map/poc_map_theme.dart` | Neutral Protomaps basemap style | VERIFIED | Custom style uses local `protomaps` source key and no remote sprite/glyph metadata. |
| `lib/domain/revealed/*`, `lib/domain/mirk/*`, `lib/domain/location/*` | Domain values for reveal, viewport, and latest fix | VERIFIED | Handwritten immutable values and in-memory repository with seeded Melun discs and accepted-fix validation. |
| `lib/infrastructure/mirk/*` and `lib/presentation/widgets/fog_clip_path.dart` | Fog SDF/projection/uniform/animation infrastructure | VERIFIED | 256x256 metre-space SDF, projection, clip path, SDF cache, 41-slot uniforms, and triangle-wave helper exist. |
| `lib/presentation/widgets/fog_layer.dart` | Same-stack custom Flutter fog layer | VERIFIED | Uses `MobileLayerTransformer`, one `MapCamera` snapshot per build, `CustomPaint`, SDF cache, clip path, and shader uniform binding. |
| `lib/presentation/widgets/blue_dot_marker.dart` / `recenter_fab.dart` | Latest-fix marker and recenter controls | VERIFIED | Blue dot appears above fog when latest fix exists; recenter control drives latest fix at zoom 15. |
| Phase 2 tests | Focused source, unit, static, and Flutter-ready checks | VERIFIED | Direct package-test spot checks passed; Flutter wrapper checks remain sandbox-blocked as documented below. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `main.dart` startup | Copied PMTiles filesystem path | `ensureFlutterPmtilesAssetCopied()` -> `MapScreenServices(pmtilesPath: snapshot.requireData)` | WIRED | Phase 1 copy service is still the bootstrap path. |
| `MapScreen` | `vector_map_tiles_pmtiles` provider | `PmTilesVectorTileProvider.fromSource(widget.services.pmtilesPath)` | WIRED | Remote and asset URI schemes are rejected before provider construction. |
| `MapScreen` | `FlutterMap.children` | `createPocMapChildren(...)` | WIRED | Child order is vector tiles, conditional fog, then blue dot. |
| `VectorTileLayer` | Protomaps source key | `TileProviders(<String, VectorTileProvider>{kPocTileProviderSourceKey: tileProvider})` | WIRED | `kPocTileProviderSourceKey` is `protomaps`; tests assert the provider is mapped by that key. |
| Map-only toggle | Fog isolation | `displayMode == MapDisplayMode.mapWithFog` gates only `FogLayer` | WIRED | Vector tile layer remains mounted in both modes. |
| Latest fix stream | In-memory reveal discs | `latestFixStream.listen(_acceptLatestFix)` -> `RevealDiscRepository.appendFix()` | WIRED | Accepted fixes append one fixed-radius 25 m disc and update `_latestFix`. |
| Reveal repository | `FogLayer` repaint/SDF | repository listener -> `_resolveSdfImage()` -> `SdfCache.getOrBuild()` | WIRED | Disc snapshot and viewport key trigger SDF builds; cache deduplicates identical work. |
| `FogLayer` | Map camera snapshot | `final MapCamera camera = MapCamera.of(context)` | WIRED | Source and test confirm one camera read per build; same snapshot feeds viewport, painter, and size. |
| `FogLayer` | Shader/SDF inputs | `_FogPainter.paint()` -> clip path -> `FogShaderUniforms.setAll()` -> `canvas.drawRect` | WIRED | Uses identity SDF rect, 41 uniforms, sampler 0, and atmospheric defaults. |
| Recenter FAB | Latest fix camera move | `_mapController.move(fix.latLng, kPocRecenterZoom)` | WIRED | Disabled without latest fix; zoom constant is 15. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|--------------------|--------|
| `MapScreen` | `pmtilesPath` | Phase 1 copy future and `MapScreenServices.pmtilesPath` | Yes | FLOWING |
| `VectorTileLayer` | `tileProvider` | `PmTilesVectorTileProvider.fromSource(local filesystem path)` | Yes | FLOWING |
| `FogLayer` | `discs` | `RevealDiscRepository.seededMelunDiscs` plus accepted `GeoFix` stream values | Yes | FLOWING |
| `FogLayer` | `viewport` | `MapCamera.visibleBounds` captured once in build | Yes | FLOWING |
| `FogLayer` | `sdfImage` | `SdfCache<ui.Image>` backed by `RevealedSdfBuilder.buildFromDiscs()` | Yes | FLOWING |
| `_FogPainter` | shader uniforms and sampler | `FogShaderUniforms.setAll()` with atmospheric constants, identity SDF rect, and SDF image | Yes | FLOWING |
| Blue dot layer | `latestFix` | `initialLatestFix` or `latestFixStream` accepted by `_acceptLatestFix()` | Yes | FLOWING |
| Recenter control | `latestFix.latLng` | Same latest-fix state used for blue dot | Yes | FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Constants lock Melun camera, source key, fog defaults, SDF resolution, identity rect | Direct `dart.exe --enable-asserts --packages=.dart_tool/package_config.json test/config/constants_test.dart` | `+5: All tests passed!` | PASS |
| PMTiles copier writes and validates absolute app-support copy | Direct `dart.exe ... test/infrastructure/pmtiles/pmtiles_asset_copier_test.dart` | `+6: All tests passed!` | PASS |
| Seeded discs and accepted GPS fixes create in-memory 25 m reveal discs | Direct `dart.exe ... test/domain/revealed/reveal_disc_repository_test.dart` | `+4: All tests passed!` | PASS |
| Reveal disc and viewport geometry use expected distance/bbox semantics | Direct `dart.exe ... reveal_disc_test.dart` and `mirk_viewport_bbox_test.dart` | `+5` and `+4`: all tests passed | PASS |
| Fog layer source has `MobileLayerTransformer`, one camera read, SDF cache, clip path, triangle wave, identity uniforms, no `RepaintBoundary` | Direct `dart.exe ... test/presentation/widgets/fog_layer_test.dart` | `+4: All tests passed!` | PASS |
| `MapScreen` source orders vector tiles, fog, and blue dot, and gates only fog in map-only mode | Direct `dart.exe ... test/presentation/screens/map_screen_fog_test.dart` | `+5: All tests passed!` | PASS |
| Fog uniform surface has 41 slots and sampler 0 | Direct `dart.exe ... test/infrastructure/mirk/shader/fog_shader_uniforms_test.dart` | `+4: All tests passed!` | PASS |
| SDF cache deduplicates builds and disposes stale cached image | Direct `dart.exe ... test/infrastructure/mirk/sdf/sdf_cache_test.dart` | `+4: All tests passed!` | PASS |
| Blue dot and recenter surfaces exist and are wired | Direct `dart.exe ... blue_dot_marker_test.dart` and `recenter_fab_test.dart` | `+2` and `+2`: all tests passed | PASS |
| Header policy | Direct `dart.exe --packages=.dart_tool/package_config.json tool/check_headers.dart` | `check_headers: OK (51 files)` | PASS |
| Dependency license policy | Direct `dart.exe --packages=.dart_tool/package_config.json tool/check_licenses.dart` | `check_licenses: OK (111 packages)` | PASS |
| Dependency audit table freshness | Direct `dart.exe --packages=.dart_tool/package_config.json tool/check_dependencies_md.dart` | `check_dependencies_md: OK (111 packages)` | PASS |
| Formatting | Direct `dart.exe format --line-length 160 --set-exit-if-changed .` with writable workspace app-data env | `Formatted 51 files (0 changed)` | PASS |

### Blocked Sandbox Checks

| Check | Result | Impact |
|-------|--------|--------|
| `flutter --version` | Timed out in this sandbox per orchestrator note | Sandbox/tooling limitation; not a code gap. |
| `flutter analyze --fatal-infos --fatal-warnings` | Timed out in this sandbox per orchestrator note | Strict analyzer settings and source are present; analyzer runtime must run in CI or unsandboxed shell. |
| `flutter test ...` / `flutter test` | Timed out in this sandbox per orchestrator note | Direct package tests and source checks passed; Flutter runtime/widget tests remain to CI or unsandboxed shell. |
| `dart analyze --fatal-infos --fatal-warnings` | Failed to spawn analysis server with `CreateFile failed 5 (Access is denied)` | Sandbox process-spawn restriction; not an observed code failure. |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| MAP-03 | 02-01, 02-02 | Load Melun vector tiles through `vector_map_tiles_pmtiles` from copied filesystem path. | SATISFIED | Local PMTiles copy path flows into `PmTilesVectorTileProvider.fromSource`; remote/asset sources rejected. |
| MAP-04 | 02-02 | Show `flutter_map` centered on Melun at `48.5397`, `2.6553`, zoom `13`. | SATISFIED | `FlutterMap` uses `createPocMapOptions()` with locked Melun constants. |
| MAP-05 | 02-02 | Approximate neutral MirkFall basemap colors. | SATISFIED | Custom no-sprite Protomaps theme covers background, landcover, water, boundaries, roads, and buildings. |
| MAP-06 | 02-02, 02-04 | Render map without fog for comparison. | SATISFIED | `MapDisplayMode.mapOnly` removes only `FogLayer`; vector layer remains. |
| FOG-01 | 02-01 | Include atmospheric shader copied from MirkFall. | SATISFIED | Shader hash matches parent and `pubspec.yaml` declares it under `flutter.shaders`. |
| FOG-02 | 02-01, 02-03 | Port reveal, bbox, SDF, projection, clip, uniforms, animation, constants. | SATISFIED | Required modules exist and direct tests passed. |
| FOG-03 | 02-04 | Render fog as `flutter_map` custom Flutter layer in same stack as vector tiles. | SATISFIED | `FogLayer` is a `FlutterMap.children` child using `MobileLayerTransformer` and `CustomPaint`. |
| FOG-04 | 02-03, 02-04 | Build 256x256 SDF from reveal discs using metre-space distance. | SATISFIED | `RevealedSdfBuilder` uses `kMirkFogSdfResolution = 256` and metre-per-pixel distance. |
| FOG-05 | 02-01, 02-03, 02-04 | Bind 41 float uniforms and one SDF sampler. | SATISFIED | `FogShaderUniforms` writes slots 0..40 and sampler 0; test passed. |
| FOG-06 | 02-03, 02-04 | Clip shader rect to unrevealed area using reveal-disc screen geometry. | SATISFIED | Painter clips to `buildViewportFogClipPathFromDiscs(...)` before shader draw. |
| FOG-07 | 02-01, 02-03, 02-04 | Use atmospheric defaults, curl triangle wave, identity SDF rect. | SATISFIED | Constants, `triangleWave`, and `FogShaderUniforms.identitySdfRect` are wired. |
| LOC-04 | 02-04 | Render latest GPS position as blue dot above fog. | SATISFIED | Latest fix adds `CircleLayer` after fog layer; marker has blue fill and white stroke. |
| LOC-05 | 02-04 | Create in-memory 25 m reveal disc for each accepted GPS fix. | SATISFIED | `RevealDiscRepository.appendFix()` validates `GeoFix` and appends 25 m disc. |
| LOC-06 | 02-04 | Recenter control moves to latest GPS fix at zoom `15`. | SATISFIED | `RecenterFab` calls `_mapController.move(fix.latLng, kPocRecenterZoom)`. |

**Coverage:** 14/14 Phase 2 requirement IDs accounted for. No additional Phase 2 requirements were found outside plan frontmatter and `REQUIREMENTS.md`.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `assets/shaders/atmospheric_fog.frag` | 63 | Parent shader comment mentions MapLibre camera. | INFO | Not an implementation dependency or overlay path; local shader intentionally matches parent source hash exactly. |

Static scans found no `RepaintBoundary`, MapLibre, or Mapbox references in Phase 2 implementation files, and no TODO/FIXME/placeholder implementation stubs. Null/empty branches found in fog and recenter code are readiness guards, not placeholder implementations.

### Human Verification Required

None before Phase 2 completion. Real-device visual lock and fps measurement are Phase 4 UAT responsibilities and are listed under Deferred Items.

### Residual Risks

| Risk | Why It Remains | Owner |
|------|----------------|-------|
| Real iOS gesture sync and fps are not proven in this sandbox. | Flutter runtime cannot start here, and the actual POC question depends on device rendering behavior. | Phase 4 UAT |
| Flutter analyzer and widget/runtime tests were not executable in this sandbox. | `flutter` commands timed out and `dart analyze` could not spawn the analysis server due access restrictions. | CI or unsandboxed local shell |
| Shader first-frame readiness paints no fog until shader/SDF are available. | This is intentional no-crash behavior, but the visible startup transition needs real-device observation. | Phase 4 UAT |

### Gaps Summary

No Phase 2 implementation gaps found. The codebase satisfies the same-pipeline renderer proof surface at the artifact, wiring, and data-flow levels. Remaining visual/performance proof is explicitly scheduled for Phase 4 UAT.

## Verification Metadata

**Verification approach:** Goal-backward from Phase 2 roadmap success criteria, Phase 2 plan must-haves, and mapped requirement IDs.  
**Must-haves source:** `ROADMAP.md`, `REQUIREMENTS.md`, `02-01-PLAN.md`, `02-02-PLAN.md`, `02-03-PLAN.md`, and `02-04-PLAN.md`.  
**Previous verification:** none found for Phase 2.  
**Automated checks:** 13 direct checks passed; Flutter/analyzer checks blocked by sandbox limitations.  
**Human checks required before Phase 2 completion:** 0  

---
_Verified: 2026-05-02T11:09:24.526Z_  
_Verifier: the agent (gsd-verifier)_
