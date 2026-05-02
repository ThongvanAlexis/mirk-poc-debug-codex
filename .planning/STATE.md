---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
current_phase: Phase 2 - Same-Pipeline Map And Fog
status: executing
last_updated: "2026-05-02T10:31:47.000Z"
progress:
  total_phases: 4
  completed_phases: 1
  total_plans: 7
  completed_plans: 6
---

# Project State

**Project:** MirkFall Flutter Map Fog POC
**Initialized:** 2026-05-02
**Current phase:** Phase 2 - Same-Pipeline Map And Fog
**Status:** Executing

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-05-02)

**Core value:** Produce a defensible yes/no answer: does the fog stay visually locked to the map during pan, zoom, and combined pan+zoom gestures at 30+ fps on iOS?
**Current focus:** Continue Phase 2 by mounting fog in the same `FlutterMap` stack.

## Roadmap Progress

| Phase | Status | Plans | Progress |
|-------|--------|-------|----------|
| 1 | Completed | 3/3 | 100% |
| 2 | Executing | 3/4 | 75% |
| 3 | Pending | 0/0 | 0% |
| 4 | Pending | 0/0 | 0% |

## Key Constraints

- iOS sideload UAT is primary; Android Pixel 4a is secondary.
- No GPL/AGPL/LGPL dependencies, no telemetry, no analytics SDKs.
- Every `.dart` file needs the GOSL header.
- Use `dart format --line-length 160`.
- Strict Dart analyzer settings are required.
- Phase 1 CI is gates-only; unsigned IPA and Android debug APK artifacts belong to Phase 3.

## Planning Notes

- Phase 2 planning created four plans under `.planning/phases/02-same-pipeline-map-and-fog/`.
- Planning resolved a package constraint conflict by pinning the stable PMTiles-compatible chain: `flutter_map 7.0.2`, `vector_map_tiles 8.0.0`, and `vector_map_tiles_pmtiles 1.5.0`.
- Plan 02-01 completed the exact dependency graph, copied atmospheric shader asset, dependency audit update, and renderer-critical constants/tests.
- Plan 02-02 completed offline Melun PMTiles rendering through `FlutterMap`/`VectorTileLayer`, custom no-sprite neutral styling, and a map-only/map+fog toggle seam.
- Plan 02-03 completed parent-derived reveal geometry, 256x256 metre-space SDF bytes, projection, fog clip path, 41-slot shader uniforms, triangle wave, and deterministic SDF cache.
- Phase 2 intentionally leaves permission rationale, durable synchronous file logging, and APK/IPA artifact jobs to Phase 3.

## Next Command

Continue Phase 2 with Plan 02-04 same-stack fog integration.

---
*Last updated: 2026-05-02 after Plan 02-03 execution*
