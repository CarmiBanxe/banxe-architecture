# CELL — AML / EDD (department under MLRO_ROOT)

**STATUS: PROPOSED — pending MC-C1 counsel-review. NOT canon.** · Sandbox-only · no push
Schema: `docs/orgcells/SCHEMA.md` (12 fields, validation V1–V6)
**Exemplar-first:** this is the FIRST child cell — one cell only, not a full tree.

---

```yaml
cell_id: aml-edd
name: AML / Enhanced Due Diligence
kind: DEPARTMENT
reporting_line: MLRO_LINE
vertical:
  manager_ref: mlro-root    # V2: same reporting_line as this cell
department_ref: null        # schema field 9: null for roots AND departments
data_policy: "sandbox-only; no secrets, no credentials, no real data"
status: PROPOSED            # V5: no activation evidence cited → PROPOSED
```

**Why `kind: DEPARTMENT` and not `CELL`:** the schema's field 9 defines `department_ref` as
"owning department `cell_id`; `null` for roots **and departments**". This unit owns a function
area and will itself own child cells (analyst/triage cells attach later), so it is the
department layer between the MLRO root and future leaf cells — hence `DEPARTMENT` with
`department_ref: null`. A `CELL` here would need an owning department that does not exist.

## functions[] (PRIMARY)

| # (exec order) | name | description | input → output |
|---|---|---|---|
| 1 | `threshold_monitoring` | Watches the cumulative-amount accumulator against the configured EDD trigger. The threshold is config-as-data, never a literal in this record. | rolling cumulative amount per customer/window + configured EDD threshold → threshold-met signal / no signal |
| 2 | `aml_signal_triage` | Receives AML and velocity signals, deduplicates and ranks them, and decides which become EDD cases. Triage is a judgement of *what to look at*, not a determination. | AML/velocity signals → triaged case queue (case / no case, with rank) |
| 3 | `edd_determination` | Produces the enhanced-due-diligence outcome for a triaged case. **Determination is HUMAN_MLRO L4 — no automatic band exists** (see `authority`). | EDD case file → EDD outcome (proceed / restrict / refuse), reasoning recorded |
| 4 | `escalation_to_mlro` | Escalates to the MLRO root anything reaching SAR/PEP/sanctions territory — those determinations are the root's, not this department's. | case exceeding this department's authority → escalation to `mlro-root` |
| 5 | `audit_of_determination` | Emits every determination and escalation to the append-only audit trail so the EDD decision path is reconstructible. | determination / escalation → audit record |

## horizontal[]

| peer_ref | interaction |
|---|---|
| `transaction-monitor` *(ENGINE_HIERARCHY)* | **Cross-line cooperation — permitted by V4, explicitly NOT authority.** This department **receives** velocity and threshold-met signals produced on the engine line and consumes them as input to triage. It does **not** task, instruct, direct or supervise that peer, and the peer holds no authority over this department. Neither direction is expressible as a `vertical` edge (V2). |
| `engine-director` *(ENGINE_HIERARCHY)* | Receives referrals and HITL proposals; returns determinations. Cooperation only — same V4 constraint. |

## authority

- **Alone:** threshold monitoring, signal triage, case formation, audit emission.
- **HUMAN_MLRO L4 (no AUTO band):** `edd_determination`. **EDD, SAR and PEP determinations have no automatic path** — a human MLRO decides. The engine may *propose*; it can never dispose.
- **HITL bands as applied here:** **BLOCK < 70** (full stop, human confirmation mandatory) · **REVIEW 70–90** (paused, MLRO/deputy notified) · **no AUTO > 90 band for EDD** — the >90 band that exists elsewhere does not apply to these determinations.
- **Escalated to `mlro-root` (outside this department's authority):** SAR filing, PEP approval, sanctions determination including reversal.
- **Derivation:** this department's authority flows from `mlro-root`, i.e. from the independent line to the Board — never from the engine.

## source_refs[] (paths only — ADR-102, V6: reference, never duplicate)

| Path | Resolution | What is referenced |
|---|---|---|
| `governance/CANONICAL-ORG-CHART-v2.md` | **repo-local** | Dept-6 MLRO / Financial Crime — independent 2nd line, reports to Board; not inside Compliance, not under CFO/COO |
| `governance/SPRINT-4-MLRO-LINE.md` | **repo-local** | MLRO operating-model delta (ADR-102 companion) |
| `banxe-emi-stack: services/aml/*` | cross-repo (path-only) | AML service surface the triage and determination functions were extracted from |
| `banxe-emi-stack: services/transaction_monitor/scoring/velocity_tracker.py` | cross-repo (path-only) | the EDD accumulator: cumulative-amount tracking and the `requires_edd` / `edd_threshold_individual_gbp` comparison (behaviour as fixed under MT-12 — exact, integer minor units) |
| `banxe-emi-stack: services/hitl/org_roles.py` | cross-repo (path-only) | SMF17 role mapping and the non-delegable SAR / PEP / sanctions-reversal gates |

## INVARIANT CHECK (exercises V1–V6 on this record)

- **V2 — SATISFIED.** `vertical.manager_ref = mlro-root`; `reporting_line(aml-edd) = MLRO_LINE` and `reporting_line(mlro-root) = MLRO_LINE` — the manager resolves within the **same** line, so the edge is valid.
- **An ENGINE ancestor would be schema-INVALID.** Writing `manager_ref: engine-director` (or any `ENGINE_HIERARCHY` cell) here would require `reporting_line(engine-director) = MLRO_LINE`, which is false — the record fails V2 and cannot be written. By induction (SCHEMA §4) every ancestor of this cell is `MLRO_LINE` and terminates at `mlro-root`, which itself has `manager_ref: null` (V1). **There is no expressible path from this department up to the engine.**
- **V3 — SATISFIED and load-bearing.** This cell carries compliance-monitoring functions (threshold monitoring, AML triage, EDD determination), so `reporting_line: MLRO_LINE` is not a choice but a validation requirement.
- **V4 — exercised deliberately.** The `transaction-monitor` peer sits on `ENGINE_HIERARCHY`; the relation is `horizontal` (cooperation) and would be invalid as `vertical` (authority). This record is the intended stress-test of that distinction.
- **V1 — untouched.** No second root introduced; this cell has a non-null manager.
- **V5 — PROPOSED.** No activation evidence exists for this department, so `status: PROPOSED`; it is not claimed ACTIVE anywhere.
- **V6 — satisfied.** All sources are paths; no source content is copied here.

## Placeholder — MT-05 FROZEN (do not resolve)

`aml_orchestrator` is referenced **as a placeholder only**. Its identity conflict (3 passports / 2 ids) is FROZEN under MT-05 `[pending human ratification]`. Not resolved, not deduplicated, not re-passported, no id chosen here. When ratified, the resolved unit attaches under this line (`manager_ref` within `MLRO_LINE`) — V2 makes any other attachment invalid.

## Notes

- Functions above are **specification only**. Per the canonical rule (SCHEMA §0), Banksy code is refactored **into** this cell afterwards — functions and their order only, never secrets, credentials, or real data.
- No child cells are declared here (exemplar-first). Analyst/triage leaf cells attach later with `department_ref: aml-edd` and `reporting_line: MLRO_LINE`.

---
**This does not replace legal advice.**
