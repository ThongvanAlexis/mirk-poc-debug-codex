# Pitfalls Research: MirkFall Flutter Map Fog POC

**Date:** 2026-05-02

## Pitfall 1: Proving The Wrong Thing

**Risk:** The app shows fog on top of the map, but the fog layer is still outside the map camera state or repaints from stale data.

**Warning signs:** Fog tracks during pure pan but slips during combined pinch+pan; code uses delayed viewport streams; custom layer is placed above `FlutterMap` instead of inside the map child stack.

**Prevention:** Make the fog a `flutter_map` layer child and instrument gesture tests before adding optional polish.

**Phase:** Phase 2 and Phase 4.

## Pitfall 2: PMTiles Asset Loading Assumption

**Risk:** Following the spec's `asset:///assets/maps/...` hint fails because `vector_map_tiles_pmtiles` does not support Flutter assets directly.

**Warning signs:** Tile provider cannot open the asset path; works only with a filesystem path in local tests.

**Prevention:** Bundle the PMTiles file, copy it to app support at launch, then pass the copied path to `fromSource`.

**Phase:** Phase 1.

## Pitfall 3: Vector Tile Performance Masks Fog Result

**Risk:** Poor vector tile rendering fps makes the fog appear bad even if same-pipeline alignment works.

**Warning signs:** Jank occurs with fog disabled; map tiles alone fail 30 fps during gestures.

**Prevention:** Add a simple fog-disabled measurement mode or log markers so UAT can separate map renderer cost from fog shader cost.

**Phase:** Phase 2 and Phase 4.

## Pitfall 4: Ported Code Drags Parent Complexity Into The POC

**Risk:** Copying battle-tested code pulls Freezed, Drift, session IDs, generated files, or abstractions that are not needed.

**Warning signs:** POC spends time on code generation, persistence, or parent architecture seams before any sync test runs.

**Prevention:** Copy logic, headers, constants, and tests where useful, but simplify domain types if necessary. For example, replace Freezed bbox with a tiny immutable Dart class if that gets the POC to device faster.

**Phase:** Phase 1 and Phase 2.

## Pitfall 5: iOS Permission No-Op

**Risk:** `permission_handler` request silently returns denied because the iOS Podfile lacks `PERMISSION_LOCATION=1`.

**Warning signs:** No iOS permission dialog appears; settings link opens generic settings; logs show immediate denied.

**Prevention:** Commit Podfile with location macro in the same phase as permission code, and verify via sideloaded IPA.

**Phase:** Phase 1 and Phase 3.

## Pitfall 6: Logs Lost During The Exact Failure

**Risk:** Async file logging loses or corrupts records when diagnosing mobile plugin/rendering issues.

**Warning signs:** JSONL corruption, missing last seconds before app kill, or `StateError: StreamSink is bound`.

**Prevention:** Use the parent synchronous `RandomAccessFile.writeStringSync` plus `flushSync` pattern, bootstrap before `runApp()`, and register lifecycle observer.

**Phase:** Phase 3.

## Pitfall 7: CI Produces An App But Not A Sideloadable IPA

**Risk:** `flutter build ios --no-codesign` succeeds but no `.ipa` artifact is uploaded for SideStore.

**Warning signs:** CI artifact only contains `Runner.app` or no iOS artifact.

**Prevention:** Zip `Payload/Runner.app` into an unsigned `.ipa`, upload it, and use a SideStore-safe `CFBundleName` without underscores.

**Phase:** Phase 1 and Phase 3.

## Pitfall 8: Dependency Drift Violates GOSL Constraints

**Risk:** A transitive package introduces a disallowed license or telemetry behavior.

**Warning signs:** No license gate, dependency bumps accepted without review, analytics package appears in pub deps.

**Prevention:** Add a lightweight license/dependency scan and keep dependencies minimal.

**Phase:** Phase 1 and Phase 3.

## Sources

- `C:\claude_checkouts\mirk-poc-debug\docs\flutter-ios-specifics.md`
- https://pub.dev/packages/vector_map_tiles_pmtiles/example
- https://pub.dev/packages/permission_handler
- https://pub.dev/packages/share_plus
