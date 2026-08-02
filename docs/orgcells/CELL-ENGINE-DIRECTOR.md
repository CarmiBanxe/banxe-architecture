# CELL — ENGINE DIRECTOR (root of the ENGINE tree)

**STATUS: PROPOSED — pending MC-C1 counsel-review. NOT canon.** · Sandbox-only · no push
Schema: `docs/orgcells/SCHEMA.md` (12 fields, validation V1–V6)

---

```yaml
cell_id: engine-director
name: Banksy Engine — Bank Director
kind: ENGINE_DIRECTOR
reporting_line: ENGINE_HIERARCHY
vertical:
  manager_ref: null          # V1: root of the ENGINE tree — no node above it
department_ref: null
data_policy: "sandbox-only; no secrets, no credentials, no real data"
status: PROPOSED             # V5: no activation evidence cited → PROPOSED
```

## functions[] (PRIMARY)

| # (exec order) | name | description | input → output |
|---|---|---|---|
| 1 | `intent_dispatch` | Receives a client/business intent from the entry floor and dispatches it to the responsible department cell. This is the engine acting as Director, not as a tool. | client intent (FLOOR 1 entry) → routed task assigned to a department cell |
| 2 | `plan_orchestration` | Plans and sequences multi-step work across department cells (planner + agent bus + model routing are the mechanism, not the authority). | routed task → ordered execution plan with per-step owner cells |
| 3 | `department_supervision` | Holds the vertical line for every `ENGINE_HIERARCHY` department: assigns, monitors, and accepts/returns their output. | department output → accepted result or returned task |
| 4 | `escalation_to_human` | Raises any step whose confidence or class requires a human decision to the HITL gate; the engine proposes, a human decides. | decision candidate + confidence → HITL proposal (never an auto-approval above its authority) |
| 5 | `audit_emission` | Emits every significant step to the append-only audit trail so the Director's own actions are reconstructible. | executed step → audit record |

## horizontal[]

| peer_ref | interaction |
|---|---|
| `mlro-root` | **Cooperation only, never authority (V4).** The engine submits AML/financial-crime matters to the MLRO line and receives binding determinations back; it cannot task, instruct, or overrule that line, and no `vertical` edge to it can be expressed (see SCHEMA §4). |

## authority

- **Alone:** dispatch, planning, sequencing, supervision and acceptance of department output inside `ENGINE_HIERARCHY`; audit emission.
- **Escalated (never alone):** any decision above its HITL band, any client-funds or production-state mutation, and **anything on the MLRO line** — the latter is not "escalated" but simply **outside its authority**.
- **HITL binding:** AUTO > 90 confidence · REVIEW 70–90 (human notified, decision paused) · BLOCK < 70 (full stop, human confirmation mandatory). Gate definitions are referenced, not restated — `banxe-emi-stack: services/hitl/org_roles.py` (cross-repo).
- **Non-delegable exclusions:** SAR filing, PEP approval and sanctions reversal are MLRO/SMF17 acts; the Director has **no** path to them.

## source_refs[] (paths only — ADR-102, never duplicated)

| Path | Resolution | What is referenced |
|---|---|---|
| `docs/architecture/BANK-OPERATING-MODEL-FOUR-FLOORS-2026-07-18.md` | **repo-local** | FLOOR 2 orchestration layer (planner, agent bus, model routing, dept-head twins) and the floor-to-floor operating logic |
| `governance/CANONICAL-ORG-CHART-v2.md` | **repo-local** | the 8-department structure the Director supervises; 3 lines of defence |
| `banxe-emi-stack: services/hitl/org_roles.py` | cross-repo (path-only) | HITL gate definitions and SMF role mapping this cell must respect |

## Notes

- Functions above are **specification only**. Per the canonical rule (SCHEMA §0), Banksy code is refactored **into** this cell afterwards — functions and their order only, never secrets, credentials, or real data.
- No child cells are declared in this bootstrap; departments attach in a later step under V2 (`manager_ref = engine-director`, `reporting_line = ENGINE_HIERARCHY`).

---
**This does not replace legal advice.**
