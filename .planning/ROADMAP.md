# Roadmap: MirkFall Flutter Map Fog POC

**Created:** 2026-05-02
**Granularity:** Coarse
**Core Value:** Produce a defensible yes/no answer: does the fog stay visually locked to the map during pan, zoom, and combined pan+zoom gestures at 30+ fps on iOS?

## Overview

| Phase | Name | Goal | Requirements | UI hint |
|-------|------|------|--------------|---------|
| 1 | Foundation And Assets | Establish a compliant Flutter project, copied Melun map asset, strict tooling, and dependency gates. | FOUND-01..05, MAP-01..02, CI-01 | no |
| 2 | Same-Pipeline Map And Fog | Render Melun vector tiles and atmospheric fog inside the `flutter_map` pipeline with in-memory reveal discs. | MAP-03..06, FOG-01..07, LOC-04..06 | yes |
| 3 | Mobile Runtime And Artifacts | Add permission flow, synchronous logging/share diagnostics, and CI builds for APK and unsigned IPA. | LOC-01..03, LOG-01..05, CI-02..05 | yes |
| 4 | Device UAT And Decision | Run iOS-first gesture/performance tests, Android comparison, and write the migrate/reject decision. | UAT-01..09 | no |

**Coverage:** 43 / 43 v1 requirements mapped.

## Phase 1: Foundation And Assets

**Goal:** Create the smallest compliant Flutter app foundation that can later build on Windows/Linux CI and macOS iOS CI without license, format, or SideStore blockers.

**Requirements:** FOUND-01, FOUND-02, FOUND-03, FOUND-04, FOUND-05, MAP-01, MAP-02, CI-01

**Success criteria:**

1. `flutter pub get`, `dart format --line-length 160 --set-exit-if-changed .`, and `flutter analyze --fatal-infos --fatal-warnings` pass locally or in CI.
2. All `.dart` files have the required GOSL header.
3. `Fra_Melun.pmtile` is present under app assets and a first-launch service copies it to app support.
4. Direct and transitive dependencies are scanned for disallowed licenses.
5. Project platform metadata uses SideStore-safe naming from the start.

**Notes:**

- Use Flutter 3.41.7 to match the parent CI and current package requirements.
- Do not add parent architecture layers unless required to unblock the POC.
- If copied MirkFall code depends on Freezed only for small records, prefer hand-written immutable classes to avoid generated-file friction.

**Plans:** 3 plans in 3 waves

Plans:
- **Wave 1**
  - [x] `01-01-PLAN.md` - Create the mobile Flutter scaffold, locked app identity, strict analyzer baseline, GOSL license, and platform metadata tests.
- **Wave 2** *(blocked on Wave 1 completion)*
  - [x] `01-02-PLAN.md` - Bundle `Fra_Melun.pmtile`, implement checksum-validating copy-to-app-support, and wire a focused launch proof.
- **Wave 3** *(blocked on Waves 1-2 completion)*
  - [x] `01-03-PLAN.md` - Add header/license/dependency guard scripts, `DEPENDENCIES.md`, and the CI-01 gates workflow.

Cross-cutting constraints:
- All direct dependencies must be exact pins with a committed `pubspec.lock`.
- Every committed Dart file must have the required GOSL three-line header.
- Phase 1 must not add map/fog rendering, permission flow, logging/share diagnostics, or APK/IPA artifact jobs.

## Phase 2: Same-Pipeline Map And Fog

**Goal:** Prove the core renderer hypothesis in-app: `flutter_map` vector tiles and atmospheric fog paint in the same Flutter map stack.

**Requirements:** MAP-03, MAP-04, MAP-05, MAP-06, FOG-01, FOG-02, FOG-03, FOG-04, FOG-05, FOG-06, FOG-07, LOC-04, LOC-05, LOC-06

**Success criteria:**

1. Map opens offline on Melun from the copied PMTiles filesystem path.
2. Fog shader visibly renders above the map using the copied atmospheric shader and 256x256 SDF sampler.
3. Reveal discs create clear holes in the fog, and clip path/SDF geometry agree visually.
4. The fog layer lives inside the `FlutterMap` child stack, not as a stale external overlay.
5. A map-only mode or toggle/log marker exists so vector tile cost can be separated from fog cost.

**Notes:**

- Start with one or more seeded reveal discs around Melun so renderer validation does not depend on GPS permission.
- Keep `uSdfRect*` identity for the first implementation. Adding compensation math would weaken the same-pipeline test.
- Logging can be simple in this phase; Phase 3 makes it durable and shareable.

**Plans:** 4 plans in 4 waves

Plans:
- **Wave 1**
  - [x] `02-01-PLAN.md` - Add the resolver-coherent map/fog dependency graph, copy the atmospheric shader, and lock Phase 2 constants/audit data.
- **Wave 2** *(blocked on Wave 1 completion)*
  - [x] `02-02-PLAN.md` - Render the copied Melun PMTiles file through `FlutterMap`/`VectorTileLayer`, add neutral styling, and expose map-only mode.
- **Wave 3** *(blocked on Wave 1 completion)*
  - [x] `02-03-PLAN.md` - Port MirkFall reveal-disc, SDF, projection, clip-path, shader-uniform, animation, and SDF-cache infrastructure with tests.
- **Wave 4** *(blocked on Waves 2-3 completion)*
  - [x] `02-04-PLAN.md` - Mount `FogLayer` inside the same `FlutterMap` child stack, wire seeded/latest-fix reveal discs, blue dot, recenter, and final integration tests.

Cross-cutting constraints:
- Use the stable resolver-coherent PMTiles chain: `flutter_map 7.0.2`, `vector_map_tiles 8.0.0`, `vector_map_tiles_pmtiles 1.5.0`.
- Fog must stay inside `FlutterMap.children`; no MapLibre, Mapbox, sibling overlay compensation, or dynamic SDF rect compensation.
- Keep map-only mode available so vector tile performance can be isolated from fog shader cost.
- Every Dart file added by Phase 2 must start with the required GOSL header and pass strict analysis.

## Phase 3: Mobile Runtime And Artifacts

**Goal:** Make the POC installable and diagnosable on the user's real devices, especially iOS via SideStore.

**Requirements:** LOC-01, LOC-02, LOC-03, LOG-01, LOG-02, LOG-03, LOG-04, LOG-05, CI-02, CI-03, CI-04, CI-05

**Success criteria:**

1. iOS permission dialog appears from the sideloaded app, proving Podfile macros and Info.plist strings are correct.
2. File logger bootstraps before `runApp()`, writes JSONL synchronously, prunes to 10 MB, and survives background transitions.
3. User can share the active log file from the app.
4. GitHub Actions uploads a debug APK and unsigned IPA artifact on every relevant run.
5. CI fails if format, analysis, tests, headers, or license checks regress.

**Notes:**

- Commit `ios/Podfile` manually if Windows Flutter scaffold does not generate it.
- Package IPA as `Payload/Runner.app` zipped to `.ipa`; SideStore will re-sign it.
- Keep foreground-only location in this POC. Background tracking belongs to production migration, not this renderer test.

## Phase 4: Device UAT And Decision

**Goal:** Gather enough iOS-first evidence to decide whether MirkFall should migrate from MapLibre to `flutter_map`.

**Requirements:** UAT-01, UAT-02, UAT-03, UAT-04, UAT-05, UAT-06, UAT-07, UAT-08, UAT-09

**Success criteria:**

1. User installs the unsigned IPA through SideStore and completes pan, zoom, and combined pan+zoom gesture tests in Melun.
2. Fog has zero visible displacement relative to map tiles during all iOS gesture categories.
3. iOS gesture fps with fog enabled is at least 30 fps.
4. Static iOS animated fog fps is at least 50 fps.
5. Final `docs/POC-RESULTS.md` records evidence and recommends migrate, reject, or pursue another renderer.

**Notes:**

- If map-only mode is already under 30 fps, separate "flutter_map vector tile performance failed" from "fog sync failed."
- If sync passes but fps fails, the result still proves the same-pipeline requirement and points toward a faster same-pipeline renderer.
- Android Pixel 4a results are useful, but iOS decides the POC.

## Requirement Coverage

| Requirement | Phase |
|-------------|-------|
| FOUND-01 | Phase 1 |
| FOUND-02 | Phase 1 |
| FOUND-03 | Phase 1 |
| FOUND-04 | Phase 1 |
| FOUND-05 | Phase 1 |
| MAP-01 | Phase 1 |
| MAP-02 | Phase 1 |
| MAP-03 | Phase 2 |
| MAP-04 | Phase 2 |
| MAP-05 | Phase 2 |
| MAP-06 | Phase 2 |
| FOG-01 | Phase 2 |
| FOG-02 | Phase 2 |
| FOG-03 | Phase 2 |
| FOG-04 | Phase 2 |
| FOG-05 | Phase 2 |
| FOG-06 | Phase 2 |
| FOG-07 | Phase 2 |
| LOC-01 | Phase 3 |
| LOC-02 | Phase 3 |
| LOC-03 | Phase 3 |
| LOC-04 | Phase 2 |
| LOC-05 | Phase 2 |
| LOC-06 | Phase 2 |
| LOG-01 | Phase 3 |
| LOG-02 | Phase 3 |
| LOG-03 | Phase 3 |
| LOG-04 | Phase 3 |
| LOG-05 | Phase 3 |
| CI-01 | Phase 1 |
| CI-02 | Phase 3 |
| CI-03 | Phase 3 |
| CI-04 | Phase 3 |
| CI-05 | Phase 3 |
| UAT-01 | Phase 4 |
| UAT-02 | Phase 4 |
| UAT-03 | Phase 4 |
| UAT-04 | Phase 4 |
| UAT-05 | Phase 4 |
| UAT-06 | Phase 4 |
| UAT-07 | Phase 4 |
| UAT-08 | Phase 4 |
| UAT-09 | Phase 4 |

---
*Roadmap created: 2026-05-02*
