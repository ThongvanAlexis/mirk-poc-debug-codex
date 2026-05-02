# Architecture Research: Same-Pipeline Fog Rendering

**Date:** 2026-05-02

## Target Architecture

```text
FlutterMap
  VectorTileLayer(PMTiles provider -> Melun PMTiles on filesystem)
  FogLayer(CustomPainter + FragmentShader + SDF sampler)
  MarkerLayer(user location)
  Floating controls
```

The fog layer must be a Flutter-painted child of the map, not an overlay synchronized from outside the map. It should derive projection data from the current `flutter_map` camera during paint/build, compute screen-space reveal holes, bind the SDF sampler, set the 41 float uniforms, and draw a full-viewport shader rect clipped to unrevealed fog.

## Why This Is The Right POC

BUG-014 showed that compensating for a native MapLibre camera from Flutter creates stale viewport data during combined gestures. A pure Flutter map changes the synchronization problem: both map tiles and fog are painted by Flutter in the same frame, so there is no platform-channel camera lag to compensate for.

## Fragment Shader Decision

Keep the fragment shader for this POC.

Rationale:

- The current visual quality depends on per-pixel animated fog at screen resolution.
- The MapLibre image-source attempt failed because geo-pinned rasters pixelated, stretched on zoom, and snapped when re-pinned.
- Polygon/fill-layer approaches could be map-locked but would not answer whether the real atmospheric fog can ship.
- The shader already runs in Flutter today; the problem is not shader feasibility, it is map/fog frame alignment.

The shader is not a blanket final architecture decision. If `flutter_map` sync is perfect but fps fails, the migration decision may shift to a native custom layer or future Flutter GPU path.

## Critical Implementation Choices

- Copy `Fra_Melun.pmtile` into `assets/maps/Fra_Melun.pmtile`, then on first launch copy it to app support and pass the real file path to `PmTilesVectorTileProvider.fromSource`.
- Keep SDF rect uniforms identity `(0, 0, 1, 1)` for the POC unless evidence shows otherwise. The same-pipeline test should not need BUG-014 compensation math.
- Compute fog clip path from reveal discs using current `flutter_map` camera state and canvas size.
- Rebuild SDF only when disc list changes or when a deliberately chosen viewport dependency changes. For the primary sync test, avoid viewport-debounced snapping that would hide the result.
- Log timings for tile provider init, shader compile/load, SDF rebuild, paint cadence, GPS fix ingestion, and share/export actions.

## Alternatives Challenged

| Approach | Why not first |
|----------|---------------|
| Stay on MapLibre with Flutter overlay compensation | Six failed iterations show the split pipeline remains the root problem. |
| MapLibre geo-pinned image source | Already failed on pixelation, zoom stretching, and re-pin snapping. |
| MapLibre polygon/fill layer | Could lock to map but drops the atmospheric shader, so it does not test the real product requirement. |
| MapLibre custom native GL/Metal layer | More production-plausible if `flutter_map` fps fails, but much higher effort and not the fastest falsifiable POC. |
| Raster fog tiles | Map-locked, but costly to update for animated per-pixel fog and likely repeats image-source quality issues. |

## Sources

- `C:\claude_checkouts\GOSL-MirkFall\docs\POC-flutter-map-mirk.md`
- `C:\claude_checkouts\GOSL-MirkFall\docs\phase09-bug-tracking\BUG-014-sdf-rect-offset-axes.md`
- https://pub.dev/packages/flutter_map
- https://pub.dev/packages/vector_map_tiles
- https://pub.dev/packages/vector_map_tiles_pmtiles
