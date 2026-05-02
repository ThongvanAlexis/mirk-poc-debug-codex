# MirkFall Flutter Map Fog POC

## What This Is

This is a greenfield Flutter proof of concept for the MirkFall BUG-014 renderer problem. It tests whether replacing the current MapLibre platform-view map with `flutter_map` and `vector_map_tiles` lets the atmospheric fog-of-war shader paint in the same Flutter rendering pipeline as the map tiles, eliminating the visible fog lag during camera gestures.

The POC is intentionally narrow: one bundled Melun PMTiles file, one map screen, one fog layer, foreground GPS only, file logging, and CI artifacts for iOS and Android. iOS sideload UAT is the primary decision input; Android on Pixel 4a is secondary for quick comparison.

## Core Value

Produce a defensible yes/no answer: does the fog stay visually locked to the map during pan, zoom, and combined pan+zoom gestures at 30+ fps on iOS?

## Current State

Phase 2 is complete at the code-verification level: the app opens the copied Melun PMTiles path through `flutter_map`/`vector_map_tiles`, mounts the atmospheric fog as a same-stack `FlutterMap` child, uses the parent-derived SDF/projection/uniform pipeline, and exposes map-only, latest-fix blue dot, reveal-disc, and recenter surfaces. Real iOS visual sync and fps evidence remains Phase 4 UAT.

## Requirements

### Validated

- [x] Create a Flutter app that uses `flutter_map` as the map renderer instead of MapLibre. Validated in Phase 2: PMTiles-backed `FlutterMap` is wired from the copied local map path.
- [x] Render Melun vector tiles from the bundled `C:\claude_checkouts\countries-pmtiles\Fra_Melun.pmtile` file. Validated in Phase 2: the app opens the Phase 1 copied filesystem path through `vector_map_tiles_pmtiles`.
- [x] Render the atmospheric fog shader as a `flutter_map` custom Flutter layer in the same frame pipeline as the map. Validated in Phase 2: `FogLayer` is mounted inside `FlutterMap.children` after `VectorTileLayer`.
- [x] Reuse the battle-tested MirkFall fog/SDF/projection code rather than reimplementing it from scratch. Validated in Phase 2: reveal discs, viewport bbox, 256x256 metre-space SDF, projection, clip path, 41-slot uniforms, triangle-wave animation, and constants are ported/adapted with tests.

### Active

- [ ] Request foreground location permission and feed live GPS fixes into the Phase 2 in-memory 25 m reveal-disc pipeline.
- [ ] Measure fog-map sync, gesture fps, static fps, SDF rebuild latency, map quality, and memory on iOS first.
- [ ] Build downloadable unsigned iOS IPA and Android debug APK artifacts in GitHub Actions.

### Out of Scope

- Database, Drift, migrations, session persistence - not needed to answer the renderer question.
- Full MirkFall UX polish, settings, menus, country switching, map download infrastructure - not needed for POC evidence.
- Background GPS/locationAlways flow - foreground-only is enough for walking tests.
- MapLibre compensation workarounds - six BUG-014 iterations already showed the separate-pipeline architecture is the problem.
- Multiple fog styles and live tuner - atmospheric fog only is enough to test the real product-critical shader.
- Analytics, telemetry, crash SDKs, GPL dependencies - forbidden by the parent project constraints.

## Context

BUG-014 in `C:\claude_checkouts\GOSL-MirkFall` is the reason this project exists. The current MirkFall implementation paints fog as a Flutter `CustomPainter` overlay above a native MapLibre map. MapLibre renders through the native platform pipeline while the fog overlay repaints through Flutter, so camera gestures can put the two 1-3 frames out of sync. Iterations 1-6 tried shader slot fixes, SDF remapping, geo-pinned MapLibre image sources, and canvas affine transforms; all failed or were reverted because the architecture remained split across render pipelines.

The hypothesis is that `flutter_map` removes the split by rendering map tiles and custom fog layers through Flutter. That makes it the right POC to run, not a guaranteed migration target. The main risk is whether vector tile rendering through `vector_map_tiles` is fast enough on iOS and on a Pixel 4a class Android device.

The implementation should start from the parent spec at `C:\claude_checkouts\GOSL-MirkFall\docs\POC-flutter-map-mirk.md`, the BUG-014 record at `C:\claude_checkouts\GOSL-MirkFall\docs\phase09-bug-tracking\BUG-014-sdf-rect-offset-axes.md`, and the iOS recipes at `C:\claude_checkouts\mirk-poc-debug\docs\flutter-ios-specifics.md`.

Files to copy from MirkFall as-is or with minimal package-name/freezed adaptation:

| Source | Purpose |
|--------|---------|
| `C:\claude_checkouts\GOSL-MirkFall\assets\shaders\atmospheric_fog.frag` | Atmospheric fog shader |
| `C:\claude_checkouts\GOSL-MirkFall\lib\infrastructure\mirk\sdf\revealed_sdf_builder.dart` | 256x256 metre-space SDF builder |
| `C:\claude_checkouts\GOSL-MirkFall\lib\domain\revealed\reveal_disc.dart` | Reveal disc domain type |
| `C:\claude_checkouts\GOSL-MirkFall\lib\domain\mirk\mirk_viewport_bbox.dart` | Viewport bbox type |
| `C:\claude_checkouts\GOSL-MirkFall\lib\infrastructure\mirk\tile_cell_iteration.dart` | Fog clip path from reveal discs |
| `C:\claude_checkouts\GOSL-MirkFall\lib\infrastructure\mirk\mirk_projection.dart` | Lat/lon to screen projection |
| `C:\claude_checkouts\GOSL-MirkFall\lib\infrastructure\mirk\shader\fog_shader_uniforms.dart` | Shader uniform slot layout |
| `C:\claude_checkouts\GOSL-MirkFall\lib\infrastructure\mirk\animation_helpers.dart` | Triangle-wave animation helper |
| `C:\claude_checkouts\GOSL-MirkFall\lib\infrastructure\mirk\wisp\wisp_particle_system.dart` | Optional wisp particles |
| `C:\claude_checkouts\GOSL-MirkFall\lib\config\constants.dart` | Relevant fog, geography, logging constants |

Relevant constants from MirkFall include `kMaxLogsDirBytes = 10 MB`, `kDefaultRevealRadiusMeters = 25.0`, `kEarthRadiusMeters = 6371008.8`, `kMetersPerDegreeLat = 111320.0`, atmospheric palette `0xFF3A4358 / 0xFF7C8AA3 / 0xFF1E2536`, fog drift/scale/opacity/curl/light/hue/boundary defaults, `kMirkFogSdfResolution = 256`, and optional wisp caps/timings.

Research findings to carry into implementation:

- `flutter_map` 8.3.0 is BSD-3 and describes itself as 100 percent pure Flutter, which directly matches the renderer hypothesis.
- `vector_map_tiles` 8.0.0 is BSD-3 and renders vector tiles as a `flutter_map` layer; it is the likely performance bottleneck and must be measured honestly.
- `vector_map_tiles_pmtiles` 1.5.0 is MIT and supports URL or filesystem PMTiles sources, but its example explicitly says Flutter assets are not supported. Bundle the PMTiles asset, copy it to app support on first run, then open by filesystem path.
- `permission_handler` 12.x requires iOS Podfile preprocessor macros. For this POC, commit a Podfile with `PERMISSION_LOCATION=1` or the iOS location prompt can silently no-op.
- `share_plus` 13.1.0 currently requires Flutter >=3.38.1 and Dart >=3.10.0. If using Flutter 3.41.7 from the parent CI, this is acceptable; otherwise pin share_plus lower or update the toolchain deliberately.

## Constraints

- **License**: Good Old Software License v1.0. No GPL or AGPL dependencies. No telemetry or analytics SDKs.
- **File headers**: Every `.dart` file must start with:

  ```dart
  // Copyright (c) 2026 THONGVAN Alexis
  // Licensed under the Good Old Software License v1.0
  // See LICENSE file for details
  ```

- **Dart style**: `dart format --line-length 160`; strict analyzer language settings: `strict-casts`, `strict-inference`, `strict-raw-types`.
- **Platforms**: iOS sideload via SideStore is primary; Android debug APK on Pixel 4a is secondary.
- **CI**: GitHub Actions must build both unsigned IPA (`flutter build ios --no-codesign`, then zip `Payload/Runner.app`) and debug APK (`flutter build apk --debug`) because the user does not own a Mac.
- **Map data**: Use only `C:\claude_checkouts\countries-pmtiles\Fra_Melun.pmtile`, 4,176,302 bytes, covering the Melun UAT area.
- **Initial camera**: Melun, France, lat `48.5397`, lon `2.6553`, zoom `13`; recenter to last GPS position at zoom `15`.
- **iOS specifics**: Use a committed `ios/Podfile` with permission macros, `CFBundleName` without underscores for SideStore, `PrivacyInfo.xcprivacy` for required reason APIs, and synchronous file logging before `runApp()`.
- **Scope discipline**: Prefer the fastest implementation that produces reliable renderer evidence over polish or generalization.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Test `flutter_map` first | It directly removes the split MapLibre-native versus Flutter-overlay rendering pipeline that caused BUG-014. | Code-level Phase 2 proof complete; real-device sync/fps UAT pending. |
| Use `vector_map_tiles` and `vector_map_tiles_pmtiles` for the POC | They keep the map in Flutter and can read PMTiles, but performance is the primary risk to measure. | Implemented with resolver-coherent pins: `flutter_map 7.0.2`, `vector_map_tiles 8.0.0`, `vector_map_tiles_pmtiles 1.5.0`; performance UAT pending. |
| Copy PMTiles asset to app support before opening | `vector_map_tiles_pmtiles` supports local filesystem paths, not Flutter bundled assets directly. | Validated in Phase 1 copy service and Phase 2 provider wiring. |
| Keep foreground-only GPS | The renderer question does not require background tracking and foreground permission avoids unnecessary iOS complexity. | Phase 2 added injected latest-fix/reveal seams; Phase 3 owns permission/runtime flow. |
| Reuse MirkFall fog/SDF code | The shader, SDF, uniforms, and reveal geometry are battle-tested; reinventing them would weaken the POC evidence. | Validated in Phase 2 with copied shader parity and focused fog infrastructure tests. |
| Generate CI artifacts for iOS and Android | The user has no Mac, and real acceptance depends on sideloadable iOS UAT. | Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? -> Move to Out of Scope with reason
2. Requirements validated? -> Move to Validated with phase reference
3. New requirements emerged? -> Add to Active
4. Decisions to log? -> Add to Key Decisions
5. "What This Is" still accurate? -> Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check -> still the right priority?
3. Audit Out of Scope -> reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-02 after Phase 2 verification*
