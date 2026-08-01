# Impact–Org Overlay Spec — report-time join of detect_impact + org-contour

**Date:** 2026-08-01 | **Status:** SPEC (implementation = separate future PR)
**Canon:** ADR-176 (Accepted — GitNexus red line), GITNEXUS-PHASE3-CROSSLINK-INTEGRATION-NOTE.md
(additive contract), GITNEXUS-PHASE3-ORG-CONTOUR-VERDICT.md (B/B3).
**Consumer:** docs/architecture/DIRECTOR-CONTROL-PLANE.md — director view reads
`accountable_agents` / `impacted_departments` from the merged report.
**Env:** GITNEXUS_ENV=sandbox (PolyForm-NC — sandbox use only without a license).

## Purpose

Wire `scripts/gitnexus/build_org_contour.build_overlay()` into the
`scripts/gitnexus/detect_impact.py` JSON report as ADDITIVE org fields, so every
impact report carries department blast-radius (B2) and agent accountability (B1)
— joined at REPORT TIME only, per ADR-176.

## Interface (future code PR; detect_impact.py NOT modified in this PR)

1. detect_impact computes `risk` / `blast_radius` / `files` exactly as today (unchanged).
2. It then calls `build_org_contour.build_overlay(staged_files())` (module import, same
   staged-file set).
3. The overlay's 4 keys are merged into the top-level JSON report:
   `impacted_departments`, `accountable_agents`, `unresolved_departments`, `unowned_paths`.

```python
# sketch (NOT shipped here):
report = compute_phase1_report()            # risk / blast_radius / files — untouched
try:
    from build_org_contour import build_overlay, staged_files
    report.update(build_overlay(staged_files()))
except Exception as exc:                    # ANY overlay failure degrades, never blocks
    report.update({"impacted_departments": [], "accountable_agents": [],
                   "unresolved_departments": [], "unowned_paths": [],
                   "org_overlay_note": f"org overlay unavailable: {exc}"})
    print(f"[org-overlay] degraded: {exc}", file=sys.stderr)
# exit-code logic below this point is byte-for-byte the Phase-1 logic
```

## HARD invariants (binding; ADR-176 + crosslink-note)

1. **`risk` / `blast_radius` / `files` are NEVER modified** — org fields are added
   alongside, nothing existing is rewritten (crosslink-note additive contract).
2. **Exit codes NEVER change**: 0 (OK) / 1 (HIGH without `GITNEXUS_ACK=1`, fail-closed)
   / 78 (MCP not connected, NO-MOCK) stay exactly as in Phase 1. An org-join failure
   MUST NOT alter the exit code: org fields degrade to empty + `org_overlay_note`,
   never block, and NEVER lower risk (they may not raise it either — the optional
   escalation rule from the crosslink-note stays operator-configured and default-off).
3. **NO write-back into `.gitnexus`** — the org overlay is computed at report time from
   map/rosters/passports; org data never enters the code graph store (ADR-176 red line).
4. **Fail-closed preserved**: HIGH without ACK still exits 1; org fields are
   informational and cannot be used to bypass or soften the gate.
5. **NO-MOCK**: `unowned_paths` and `unresolved_departments` are surfaced honestly —
   an unmatched path is a signal for the S2 census, never an invented owner.
6. **Exit-78 path**: when MCP/code-graph is not connected, the org overlay MAY still be
   computed (it is independent of KuzuDB — sources are map.yaml + rosters + passports),
   but the report MUST keep exit 78 and label the output
   (`"org_overlay_note": "code graph unavailable (78); org overlay from map/rosters only"`).

## Merged output shape (example)

```json
{
  "risk": "MEDIUM",
  "blast_radius": ["<phase-1 nodes — unchanged>"],
  "files": ["bank-rooms/F2-payments-room/runtime/x.py", "services/aml/tx_monitor.py"],
  "impacted_departments": [
    {"room": "F2-payments-room", "owner_line": "COO / Operations (SMF24)", "core_exempt": false}
  ],
  "accountable_agents": [
    {"agent_id": "AG-F2-014", "name": "PaymentService", "room": "F2-payments-room",
     "human_double": "COO", "smf": "SMF24", "status": "active",
     "matched_by": "room-roster", "provenance": "agents-roster.md"}
  ],
  "unresolved_departments": [],
  "unowned_paths": []
}
```

## Dry-run evidence (NO-MOCK)

Real run on origin/main (14f9920f), sandbox, real map/rosters/passports —
`python3 scripts/gitnexus/build_org_contour.py bank-rooms/F2-payments-room/runtime/x.py
services/aml/tx_monitor.py totally/unmapped/path.py` (agents list truncated to 3 of 28
for readability; full output reproducible with the same command):

```json
{
  "impacted_departments": [
    {"room": "F2-payments-room", "owner_line": "COO / Operations (SMF24)", "core_exempt": false},
    {"room": "F3-aml-room", "owner_line": "MLRO / Financial Crime (SMF17)", "core_exempt": false}
  ],
  "accountable_agents": [
    {"agent_id": "AG-F2-014", "name": "PaymentService", "room": "F2-payments-room",
     "human_double": "COO", "smf": "SMF24", "status": "active",
     "matched_by": "room-roster", "provenance": "agents-roster.md"},
    {"agent_id": "AG-F2-015", "name": "PaymentProcessingService", "room": "F2-payments-room",
     "human_double": "COO", "smf": "SMF24", "status": "active",
     "matched_by": "room-roster", "provenance": "agents-roster.md"},
    {"agent_id": "AG-F2-016", "name": "PaymentAuthGuard", "room": "F2-payments-room",
     "human_double": "COO", "smf": "SMF24", "status": "active",
     "matched_by": "room-roster", "provenance": "agents-roster.md"},
    {"...": "truncated for spec, 28 total"}
  ],
  "unresolved_departments": [],
  "unowned_paths": ["totally/unmapped/path.py"]
}
```

Proven: F2 path → department + SMF owner line (COO/SMF24); `services/aml/tx_monitor.py`
→ precise B1 via roster `source_path` (F3/MLRO SMF17); unmapped path → `unowned_paths`
(honest signal, no invented owner); `unresolved_departments` empty because the map's
`todo_operator` list is currently empty (all prior rows operator-resolved 2026-07-27).

## Out of scope (this PR)

- Any change to `detect_impact.py` (wiring = next, separate PR after operator go).
- CI behavior changes (gitnexus-impact stays informational; promotion = post-#1166 gate).
- Freshness SLO / contract registry (later steps of the ADR-176 bounded surface set).
