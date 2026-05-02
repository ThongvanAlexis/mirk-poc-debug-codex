---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
current_phase: Phase 4 - Device UAT And Decision
status: ready_to_plan
last_updated: "2026-05-02T13:20:00.000Z"
progress:
  total_phases: 4
  completed_phases: 3
  total_plans: 11
  completed_plans: 11
---

# Project State

**Project:** MirkFall Flutter Map Fog POC
**Initialized:** 2026-05-02
**Current phase:** Phase 4 - Device UAT And Decision
**Status:** Ready to plan

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-05-02)

**Core value:** Produce a defensible yes/no answer: does the fog stay visually locked to the map during pan, zoom, and combined pan+zoom gestures at 30+ fps on iOS?
**Current focus:** Plan and run Phase 4 iOS-first device UAT, Android comparison, and final renderer decision evidence.

## Roadmap Progress

| Phase | Status | Plans | Progress |
|-------|--------|-------|----------|
| 1 | Completed | 3/3 | 100% |
| 2 | Completed | 4/4 | 100% |
| 3 | Completed | 4/4 | 100% |
| 4 | Ready to plan | 0/0 | 0% |

## Key Constraints

- iOS sideload UAT is primary; Android Pixel 4a is secondary.
- No GPL/AGPL/LGPL dependencies, no telemetry, no analytics SDKs.
- Every `.dart` file needs the GOSL header.
- Use `dart format --line-length 160`.
- Strict Dart analyzer settings are required.
- CI now includes gates plus unsigned IPA and Android debug APK artifacts.

## Planning Notes

- Phase 2 planning created four plans under `.planning/phases/02-same-pipeline-map-and-fog/`.
- Planning resolved a package constraint conflict by pinning the stable PMTiles-compatible chain: `flutter_map 7.0.2`, `vector_map_tiles 8.0.0`, and `vector_map_tiles_pmtiles 1.5.0`.
- Plan 02-01 completed the exact dependency graph, copied atmospheric shader asset, dependency audit update, and renderer-critical constants/tests.
- Plan 02-02 completed offline Melun PMTiles rendering through `FlutterMap`/`VectorTileLayer`, custom no-sprite neutral styling, and a map-only/map+fog toggle seam.
- Plan 02-03 completed parent-derived reveal geometry, 256x256 metre-space SDF bytes, projection, fog clip path, 41-slot shader uniforms, triangle wave, and deterministic SDF cache.
- Plan 02-04 completed same-stack `FogLayer` mounting inside `FlutterMap.children`, seeded/latest-fix reveal discs, safe shader loading, blue dot, recenter, and final integration/static tests.
- Phase 3 completed permission rationale, durable synchronous file logging, active-log sharing, and APK/IPA artifact jobs.
- Phase 3 UI design contract approved in `.planning/phases/03-mobile-runtime-and-artifacts/03-UI-SPEC.md`, locking the permission rationale, denied/settings recovery, compact share-log/recenter/mode controls, atmospheric color contract, and evidence-first copy.
- Phase 3 planning created and executed four plans under `.planning/phases/03-mobile-runtime-and-artifacts/`.
- Plan 03-01 completed exact-pinned permission/share dependencies, foreground-only iOS/Android metadata, Podfile `PERMISSION_LOCATION=1`, and `PrivacyInfo.xcprivacy`.
- Plan 03-02 completed synchronous JSONL logging, lifecycle flush, log pruning, frame timing aggregation, and runtime evidence markers.
- Plan 03-03 completed permission-gated launch, denied/settings recovery, foreground GPS adaptation into `GeoFix`, and compact active-log sharing.
- Plan 03-04 completed GitHub Actions Android debug APK and unsigned iOS IPA artifact jobs plus final Phase 3 traceability updates.

## Next Command

Plan Phase 4 device UAT and decision evidence.

---
*Last updated: 2026-05-02 after Phase 3 execution*
