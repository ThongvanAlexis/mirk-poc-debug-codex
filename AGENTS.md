# AGENTS.md

This repository follows the GSD planning workflow in `.planning/`.

## Project Context

Before making changes, read:

1. `.planning/PROJECT.md`
2. `.planning/REQUIREMENTS.md`
3. `.planning/ROADMAP.md`
4. `.planning/STATE.md`
5. Relevant files in `.planning/research/`

The project is a Flutter POC for MirkFall BUG-014. The primary question is whether `flutter_map` can keep an atmospheric fog-of-war shader perfectly locked to the map during pan, zoom, and combined gestures on iOS at 30+ fps.

## Hard Constraints

- No GPL, AGPL, LGPL, SSPL, telemetry, or analytics SDKs.
- Every `.dart` file must begin with:

  ```dart
  // Copyright (c) 2026 THONGVAN Alexis
  // Licensed under the Good Old Software License v1.0
  // See LICENSE file for details
  ```

- Use `dart format --line-length 160`.
- Keep strict Dart analysis enabled: `strict-casts`, `strict-inference`, `strict-raw-types`.
- iOS sideload IPA is the primary artifact. Android APK is secondary.
- Prefer POC evidence over UX polish or production generality.

## Implementation Guidance

- Reuse the battle-tested MirkFall fog/SDF/shader code listed in `.planning/PROJECT.md`.
- Keep the fog as a `flutter_map` custom Flutter layer inside the map child stack.
- Do not reintroduce MapLibre overlay compensation approaches; BUG-014 already ruled those out.
- Bundle `Fra_Melun.pmtile`, copy it to app support, and open the copied filesystem path.
- Keep foreground-only GPS for the POC.
- Use synchronous file logging as documented in `.planning/PROJECT.md` and parent iOS specifics.

## Workflow

- Plan Phase 1 with `$gsd-plan-phase 1`.
- Execute phase plans with focused commits.
- Update `.planning/STATE.md` when phase status changes.
- Update `.planning/REQUIREMENTS.md` traceability after phase completion.
