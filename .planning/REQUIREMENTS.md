# Requirements: MirkFall Flutter Map Fog POC

**Defined:** 2026-05-02
**Core Value:** Produce a defensible yes/no answer: does the fog stay visually locked to the map during pan, zoom, and combined pan+zoom gestures at 30+ fps on iOS?

## v1 Requirements

### Project Foundation

- [x] **FOUND-01**: Developer can run a Flutter app scaffold whose package, bundle ID, iOS display/internal names, and committed platform files are compatible with SideStore sideloading.
- [x] **FOUND-02**: Developer can run `dart format --line-length 160 --set-exit-if-changed .` without diffs.
- [x] **FOUND-03**: Developer can run `flutter analyze --fatal-infos --fatal-warnings` with strict Dart settings enabled.
- [x] **FOUND-04**: Every committed `.dart` file starts with the required GOSL copyright/license header.
- [x] **FOUND-05**: CI rejects disallowed dependency licenses, including GPL, AGPL, LGPL, SSPL, and unknown licenses unless explicitly allowlisted.

### Map Data And Rendering

- [x] **MAP-01**: App bundles `Fra_Melun.pmtile` under app assets and includes it in `pubspec.yaml`.
- [x] **MAP-02**: App copies the bundled PMTiles file to an app support filesystem path on first launch.
- [x] **MAP-03**: App loads Melun vector tiles through `vector_map_tiles_pmtiles` from the copied filesystem path.
- [x] **MAP-04**: User sees a `flutter_map` map centered on Melun at latitude `48.5397`, longitude `2.6553`, zoom `13`.
- [x] **MAP-05**: Map styling approximates MirkFall's neutral basemap colors for background, landcover, water, boundaries, and roads.
- [x] **MAP-06**: App can render the map without the fog layer for map-only performance comparison.

### Fog Rendering

- [x] **FOG-01**: App includes `assets/shaders/atmospheric_fog.frag` copied from MirkFall without visual simplification.
- [ ] **FOG-02**: App ports or minimally adapts MirkFall reveal disc, viewport bbox, SDF builder, projection, clip path, shader uniform, animation helper, and relevant fog constants.
- [ ] **FOG-03**: App renders the fog as a `flutter_map` custom Flutter layer in the same map child stack as the vector tiles.
- [ ] **FOG-04**: Fog layer builds a 256x256 SDF image from reveal discs using metre-space distance.
- [ ] **FOG-05**: Fog layer binds 41 float uniforms and one SDF sampler according to the MirkFall shader layout.
- [ ] **FOG-06**: Fog layer clips the shader rect to unrevealed map area using reveal-disc screen geometry.
- [ ] **FOG-07**: Fog animation uses the atmospheric defaults, including curl-scale triangle wave and identity SDF rect unless measurement proves a change is needed.

### Location And Interaction

- [ ] **LOC-01**: On first launch, user sees a foreground location permission rationale screen before the map.
- [ ] **LOC-02**: On grant, user reaches the map and the app starts foreground location updates.
- [ ] **LOC-03**: On deny or permanent deny, user sees a denied state with a system settings action.
- [ ] **LOC-04**: App renders the latest GPS position as a blue dot above the fog.
- [ ] **LOC-05**: App creates an in-memory 25 m reveal disc for each accepted GPS fix.
- [ ] **LOC-06**: User can tap a recenter control that animates the map to the latest GPS fix at zoom `15`.

### Logging And Diagnostics

- [ ] **LOG-01**: App bootstraps a file logger before `runApp()` and writes JSONL logs under `<app_documents_dir>/logs/`.
- [ ] **LOG-02**: Logger writes synchronously with `RandomAccessFile.writeStringSync` and `flushSync`, not async `IOSink`.
- [ ] **LOG-03**: Logger prunes old logs to a 10 MB cap without deleting the active log file.
- [ ] **LOG-04**: User can share the active log file through the platform share sheet.
- [ ] **LOG-05**: App logs tile provider init time, PMTiles copy/open events, shader load time, SDF rebuild duration, GPS fix ingestion, frame timing markers, permission outcomes, and share-log outcomes.

### iOS And Android Build Artifacts

- [x] **CI-01**: GitHub Actions lint job runs `flutter pub get`, format check with line length 160, analyze with fatal infos/warnings, dependency/license/header checks, and tests.
- [ ] **CI-02**: GitHub Actions Android job builds `flutter build apk --debug` and uploads a downloadable APK artifact.
- [ ] **CI-03**: GitHub Actions iOS job runs on macOS, builds `flutter build ios --no-codesign`, packages `Payload/Runner.app` into an unsigned `.ipa`, and uploads it.
- [ ] **CI-04**: iOS platform files include a Podfile with the location permission macro required by `permission_handler`.
- [ ] **CI-05**: iOS platform files include SideStore-safe `CFBundleName`, location usage description, and required privacy manifest entries for file timestamp and user defaults APIs.

### UAT And Decision Evidence

- [ ] **UAT-01**: User can sideload the unsigned IPA on iOS via SideStore and open the map in Melun.
- [ ] **UAT-02**: During iOS pan gestures, fog remains visually locked to the map with zero visible displacement.
- [ ] **UAT-03**: During iOS zoom gestures, fog remains visually locked to the map with zero visible displacement.
- [ ] **UAT-04**: During combined iOS pan+zoom gestures, fog remains visually locked to the map with zero visible displacement.
- [ ] **UAT-05**: During iOS gestures with fog enabled, observed or logged frame rate is at least 30 fps.
- [ ] **UAT-06**: During static iOS map view with animated fog active, observed or logged frame rate is at least 50 fps.
- [ ] **UAT-07**: SDF rebuild latency for fewer than 100 reveal discs is logged and remains below 16 ms on target device class.
- [ ] **UAT-08**: User can install the Android debug APK on Pixel 4a and run the same gesture checks as secondary comparison.
- [ ] **UAT-09**: Final POC decision document records pass/fail results and recommends migrate, reject, or investigate alternate native rendering.

## v2 Requirements

Deferred to future release or production migration. Tracked but not in current POC roadmap.

### Production Migration

- **PROD-01**: MirkFall production code migrates MapLibre map abstraction to a `flutter_map` implementation.
- **PROD-02**: MirkFall persists reveal discs in the existing database instead of in memory.
- **PROD-03**: MirkFall supports background GPS and locationAlways permission flow.
- **PROD-04**: MirkFall supports country switching and PMTiles download/install infrastructure.
- **PROD-05**: MirkFall supports all production fog styles and user-facing tuners.
- **PROD-06**: MirkFall keeps or rebuilds full production map style parity.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Database and Drift persistence | The POC only needs in-memory reveal discs to answer renderer sync. |
| Background GPS | Foreground walking tests are enough for the renderer decision. |
| Multiple countries | Melun is the only required test area. |
| Remote PMTiles downloads | Bundled PMTiles removes network and storage pipeline complexity. |
| Full UX polish | The user explicitly prioritizes working implementation evidence over polish. |
| Analytics or telemetry | Forbidden by GOSL v1.0 project constraints. |
| GPL/AGPL/LGPL dependencies | Incompatible with parent project constraints. |
| MapLibre overlay compensation | BUG-014 already exhausted this line of attack. |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| FOUND-01 | Phase 1 | Complete |
| FOUND-02 | Phase 1 | Complete |
| FOUND-03 | Phase 1 | Complete |
| FOUND-04 | Phase 1 | Complete |
| FOUND-05 | Phase 1 | Complete |
| MAP-01 | Phase 1 | Complete |
| MAP-02 | Phase 1 | Complete |
| MAP-03 | Phase 2 | Complete |
| MAP-04 | Phase 2 | Complete |
| MAP-05 | Phase 2 | Complete |
| MAP-06 | Phase 2 | Complete |
| FOG-01 | Phase 2 | Complete |
| FOG-02 | Phase 2 | Pending |
| FOG-03 | Phase 2 | Pending |
| FOG-04 | Phase 2 | Pending |
| FOG-05 | Phase 2 | Pending |
| FOG-06 | Phase 2 | Pending |
| FOG-07 | Phase 2 | Pending |
| LOC-01 | Phase 3 | Pending |
| LOC-02 | Phase 3 | Pending |
| LOC-03 | Phase 3 | Pending |
| LOC-04 | Phase 2 | Pending |
| LOC-05 | Phase 2 | Pending |
| LOC-06 | Phase 2 | Pending |
| LOG-01 | Phase 3 | Pending |
| LOG-02 | Phase 3 | Pending |
| LOG-03 | Phase 3 | Pending |
| LOG-04 | Phase 3 | Pending |
| LOG-05 | Phase 3 | Pending |
| CI-01 | Phase 1 | Complete |
| CI-02 | Phase 3 | Pending |
| CI-03 | Phase 3 | Pending |
| CI-04 | Phase 3 | Pending |
| CI-05 | Phase 3 | Pending |
| UAT-01 | Phase 4 | Pending |
| UAT-02 | Phase 4 | Pending |
| UAT-03 | Phase 4 | Pending |
| UAT-04 | Phase 4 | Pending |
| UAT-05 | Phase 4 | Pending |
| UAT-06 | Phase 4 | Pending |
| UAT-07 | Phase 4 | Pending |
| UAT-08 | Phase 4 | Pending |
| UAT-09 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 43 total
- Mapped to phases: 43
- Unmapped: 0

---
*Requirements defined: 2026-05-02*
*Last updated: 2026-05-02 after Plan 02-02 execution*
