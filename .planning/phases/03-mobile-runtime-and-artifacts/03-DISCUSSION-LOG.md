# Phase 3: Mobile Runtime And Artifacts - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-05-02
**Phase:** 3-Mobile Runtime And Artifacts
**Areas discussed:** Permission Gate Behavior, Live GPS Ingestion Policy, Diagnostic Log Surface, Artifact CI Contract

---

## Permission Gate Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Strict launch gate | Show rationale before map, request foreground location by explicit user action, proceed to map only after grant. | yes |
| Map first with inline banner | Show map immediately and prompt from an overlay/banner. | |
| Planner discretion | Let planner choose the smallest implementation that satisfies LOC-01..03. | |

**User's choice:** Workflow fallback selected the recommended strict launch gate because LOC-01 explicitly requires a rationale screen before the map.
**Notes:** Keep this foreground-only. Add denied/permanent-denied state, settings action, and resume recheck. Do not add background GPS or notification permissions.

---

## Live GPS Ingestion Policy

| Option | Description | Selected |
|--------|-------------|----------|
| Foreground high-accuracy stream with light filtering | Start geolocator after grant, use walking-friendly settings, and feed accepted fixes through `MapScreenServices.latestFixStream`. | yes |
| Every raw platform fix | Append every platform emission without distance/time filtering. | |
| Manual test fixes only | Keep Phase 2 injection only and defer real GPS. | |

**User's choice:** Workflow fallback selected foreground high-accuracy streaming with light filtering.
**Notes:** Preserve the existing widget seam. Accepted emitted fixes become 25 m reveal discs. Invalid fixes are rejected and logged; valid out-of-Melun fixes are logged but not silently dropped.

---

## Diagnostic Log Surface

| Option | Description | Selected |
|--------|-------------|----------|
| Always-on POC diagnostics plus compact share action | Synchronous JSONL logging before `runApp()`, focused evidence markers, and a visible share-log control. | yes |
| Full debug menu | Add settings, runtime verbosity toggles, and richer diagnostic UI. | |
| Post-run file only | Write logs but do not expose sharing in-app. | |

**User's choice:** Workflow fallback selected always-on POC diagnostics plus compact share action.
**Notes:** Follow the sibling `flutter-ios-specifics.md` logger recipe: `RandomAccessFile.writeStringSync`, `flushSync`, 10 MB prune, skip active log file, and `share_plus` non-deprecated API.

---

## Artifact CI Contract

| Option | Description | Selected |
|--------|-------------|----------|
| Gates plus artifact jobs on existing triggers | Keep gates and add Android APK plus unsigned iOS IPA artifact jobs for the existing workflow triggers. | yes |
| Manual artifact workflow only | Build artifacts only through `workflow_dispatch`. | |
| Planner discretion | Let planner decide job layout and triggers. | |

**User's choice:** Workflow fallback selected gates plus artifact jobs on existing triggers.
**Notes:** Existing CI tests currently assert no artifact builds; update them. iOS IPA packaging must zip `Payload/Runner.app` for SideStore.

---

## Agent Discretion

- Exact class names, file splits, and UI placement are open as long as plugin coupling stays out of map/fog widgets.
- Exact `geolocator` stream settings should be verified against current APIs during planning.
- CI can remain one workflow with multiple jobs or split artifact jobs if that keeps tests and triggers clearer.

## Deferred Ideas

- Background GPS, notification permission, foreground services, and locationAlways.
- Full debug menu and production log browser.
- Phase 4 UAT, final pass/fail decision, and production migration recommendation.
