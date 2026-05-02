# Phase 1: Foundation And Assets - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-05-02
**Phase:** 1-Foundation And Assets
**Areas discussed:** App identity and scaffold, PMTiles copy contract, Dependency and license gate, CI and platform baseline

---

## App Identity And Scaffold

| Option | Description | Selected |
|--------|-------------|----------|
| Reuse sibling POC identity | `mirk_poc_debug`, `com.thongvan.mirkPocDebug`, `com.thongvan.mirk_poc_debug`, `MirkFall POC`, `MirkPocDebug`; already proven through SideStore in the sibling checkout. | yes |
| Invent a fresh identity | Pick a new package and bundle identifier for this checkout. Increases SideStore/App-ID risk without helping the renderer question. | |
| Let planner decide | Defer identity until plan time. Risky because identity is load-bearing for scaffold, imports, and sideload quota. | |

**Choice:** Reuse sibling POC identity.
**Notes:** Selected by workflow fallback because the interactive picker is unavailable in this runtime. The choice is backed by `C:\claude_checkouts\mirk-poc-debug` Phase 1 summaries and iOS-specific docs.

---

## PMTiles Copy Contract

| Option | Description | Selected |
|--------|-------------|----------|
| Idempotent self-healing copy | Bundle `Fra_Melun.pmtile`, copy to app support on first launch, verify size/checksum, rewrite corrupted copies via temp-file rename. | yes |
| Copy only if missing | Simpler, but a partial/corrupt file can survive and confuse Phase 2 map loading. | |
| Always overwrite on launch | Simple, but wastes startup IO and hides whether copy-once behavior works. | |

**Choice:** Idempotent self-healing copy.
**Notes:** Phase 1 owns PMTiles asset packaging and copy service only. Shader and fog assets stay deferred to Phase 2 under the current roadmap.

---

## Dependency And License Gate

| Option | Description | Selected |
|--------|-------------|----------|
| Exact pins plus strict guard scripts | Commit lockfile, use exact direct pins, port proven header/license/dependency scripts, fail unknown/disallowed licenses and telemetry packages. | yes |
| Minimal direct-dependency review | Faster initially, but weak against transitive drift and inconsistent with project constraints. | |
| Let pub ranges float | Easier maintenance, but poor fit for a narrow POC where reproducibility matters more than automatic upgrades. | |

**Choice:** Exact pins plus strict guard scripts.
**Notes:** Prior sibling research found a possible version-chain mismatch around `flutter_map` and `vector_map_tiles`. The planner/researcher must verify resolver compatibility instead of copying version tables blindly.

---

## CI And Platform Baseline

| Option | Description | Selected |
|--------|-------------|----------|
| Phase 1 gates only | Implement CI-01: pub get, format, analyze, tests, header/license/dependency checks; defer APK/IPA artifacts to Phase 3. | yes |
| Full mobile artifact CI now | Produces more early proof, but expands Phase 1 into CI-02/CI-03 work assigned to Phase 3. | |
| Local-only checks | Faster to scaffold, but misses the requirement that CI enforce compliance. | |

**Choice:** Phase 1 gates only.
**Notes:** SideStore-sensitive metadata should be correct in Phase 1, but permission flow, logging/share diagnostics, and artifact jobs remain later-phase scope.

---

## Agent Discretion

- The planner may choose whether asset copy happens before `runApp()` or from a small bootstrap screen.
- The planner may choose parent or sibling versions of the Dart guard scripts after comparing adaptation cost.

## Deferred Ideas

- Atmospheric fog shader and donor fog/SDF Dart files: Phase 2.
- Foreground permission UX, file logging, share-log action, Podfile permission macro, APK/IPA artifacts: Phase 3.
- Device UAT and final migration decision: Phase 4.
