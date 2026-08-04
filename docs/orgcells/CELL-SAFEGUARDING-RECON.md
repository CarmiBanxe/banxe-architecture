# CELL — SAFEGUARDING / RECONCILIATION (department under ENGINE_DIRECTOR)

**STATUS: PROPOSED — pending MC-C1 counsel-review. NOT canon.** · Sandbox-only · no push
Schema: `docs/orgcells/SCHEMA.md` (12 fields, validation V1–V6)
**Exemplar-first:** second exemplar — the ENGINE-line mirror of `aml-edd`; one cell, not a tree.

---

```yaml
cell_id: safeguarding-recon
name: Safeguarding & Reconciliation
kind: DEPARTMENT
reporting_line: ENGINE_HIERARCHY
vertical:
  manager_ref: engine-director   # V2: same reporting_line as this cell
department_ref: null             # schema field 9: null for roots AND departments
data_policy: "sandbox-only; no secrets, no credentials, no real data"
status: PROPOSED                 # V5: no activation evidence cited → PROPOSED
```

**Why `kind: DEPARTMENT`:** same reasoning as `aml-edd` — schema field 9 defines
`department_ref` as "owning department `cell_id`; `null` for roots **and departments**".
This unit owns a function area (safeguarding + reconciliation + breach reporting) and will
own leaf cells later (daily-recon, breach-triage), so it is the department layer directly
under the engine root. A `CELL` here would require an owning department that does not exist.

**Why `ENGINE_HIERARCHY` and not `MLRO_LINE`:** safeguarding and reconciliation are
**banking / rails operations** (FLOOR-3 money movement and its books), not
compliance-monitoring. V3 therefore does **not** force `MLRO_LINE` here. Breach findings do
have a financial-crime dimension, but that is handled by **cooperation across lines**
(`horizontal` to `aml-edd`), never by placing this department on the MLRO line — see
INVARIANT CHECK.

## functions[] (PRIMARY)

| # (exec order) | name | description | input → output |
|---|---|---|---|
| 1 | `account_balance_recording` | Creates and maintains safeguarding account records and their balances as the book of record for client money. | account event / balance observation → recorded account state |
| 2 | `safeguarding_position` | Computes the safeguarding position (positions by date, history, detail) from recorded balances. | recorded account states + as-of date → safeguarding position |
| 3 | `reconciliation_daily` | Reconciles internal records against the external position on a daily cycle — the primary control rhythm. | internal records + external statement, per day → reconciliation result (matched / exceptions) |
| 4 | `reconciliation_monthly` | Periodic reconciliation over the monthly cycle, with history and per-item detail retained for audit. | daily results + month scope → monthly reconciliation result + retained history |
| 5 | `shortfall_detection` | Detects a shortfall between required and held client money — the condition the whole control exists to catch. | safeguarding position vs required position → shortfall / no shortfall, with magnitude |
| 6 | `breach_report` | Raises, lists and resolves breach records arising from shortfall or reconciliation exceptions. | shortfall / recon exception → breach record (raised → tracked → resolved) |
| 7 | `status_surface` | Exposes recon status, position and breach-report reads for supervision and health checks. | query → status/position/breach view |

## horizontal[]

| peer_ref | interaction |
|---|---|
| `aml-edd` *(MLRO_LINE)* | **Cross-line cooperation — the mirror of the AML/EDD peer entry; permitted by V4, explicitly NOT authority.** Where a breach or reconciliation exception carries a financial-crime dimension, this department **hands the signal across** to the MLRO line and receives back whatever determination that line makes. It does **not** direct that line, cannot task it, and — crucially — **does not thereby acquire any SAR/PEP/sanctions authority of its own**; those determinations stay with the MLRO tree. Equally, `aml-edd` does not supervise this department. Neither direction is expressible as a `vertical` edge (V2). |
| `engine-director` *(ENGINE_HIERARCHY)* | This is the **vertical** manager, not a horizontal peer — listed here only to state the distinction explicitly: supervision flows on the vertical edge above, not as cooperation. |

## authority

- **Alone (operational, under ENGINE HITL bands):** balance recording, position computation, daily/monthly reconciliation, status surfacing. These are engine-line operational acts and use the standard confidence bands — **AUTO > 90** · **REVIEW 70–90** · **BLOCK < 70**.
- **Escalated on the vertical (to `engine-director`):** anything above its band, and any action that would mutate client-funds or production state — such mutation is never automatic.
- **Escalated across the line (horizontal to `aml-edd`):** breach/exception signals with a financial-crime dimension. This is **referral, not delegation** — the determination is made on the MLRO line, and this department has **no** path to SAR filing, PEP approval or sanctions determination.
- **Contrast with `aml-edd`:** that cell has functions with **no AUTO band at all** (HUMAN_MLRO L4); this one legitimately does have an AUTO band, because its functions are operational rather than determinative. The two exemplars differ exactly where the model says they should.

## source_refs[] (paths only — ADR-102, V6: reference, never duplicate)

| Path | Resolution | What is referenced |
|---|---|---|
| `docs/architecture/BANK-OPERATING-MODEL-FOUR-FLOORS-2026-07-18.md` | **repo-local** | FLOOR-3 banking/rails placement — why this department sits on the engine line |
| `banxe-emi-stack: services/safeguarding-engine/app/api/*` | cross-repo (path-only) | the operational surface the functions were extracted from: reconciliation (daily/monthly/history/detail), safeguarding (record/positions/shortfall/by-date), accounts (create/list/get/update/balance), breach (report/list/get/resolve) |
| `banxe-emi-stack: services/safeguarding-engine/app/mcp/*` | cross-repo (path-only) | the supervision/status surface: position, breach_report, recon_status, health |

## INVARIANT CHECK (exercises V1–V6 on this record)

- **V2 — SATISFIED.** `vertical.manager_ref = engine-director`; `reporting_line(safeguarding-recon) = ENGINE_HIERARCHY` and `reporting_line(engine-director) = ENGINE_HIERARCHY` — the manager resolves within the **same** line.
- **A `vertical` edge to `mlro-root` (or any MLRO-line cell) would be schema-INVALID.** It would require `reporting_line(mlro-root) = ENGINE_HIERARCHY`, which is false; the record fails V2 and cannot be written. The invariant cuts **both ways** — just as no MLRO-line cell can report through the engine (`CELL-AML-EDD.md`), no engine-line cell can be slipped under the MLRO root to borrow its independence.
- **The `horizontal` edge to `aml-edd` IS legitimate (V4).** Cross-line cooperation is expressible and intended; cross-line authority is not. This record and `aml-edd` now demonstrate the same rule from opposite sides.
- **V3 — correctly NOT triggered.** This cell carries banking/rails functions, not compliance-monitoring, so `MLRO_LINE` is not required. Had it carried monitoring functions, V3 would have forced the other line — the rule is discriminating, not decorative.
- **V1 — untouched.** No new root; this cell has a non-null manager.
- **V5 — PROPOSED.** No activation evidence exists; not claimed ACTIVE anywhere.
- **V6 — satisfied.** All sources are paths; no source content copied here.

## Notes

- Functions above are **specification only**. Per the canonical rule (SCHEMA §0), Banksy code is refactored **into** this cell afterwards — functions and their order only, never secrets, credentials, or real data.
- No child cells are declared here (exemplar-first). Leaf cells (e.g. daily-recon, breach-triage) attach later with `department_ref: safeguarding-recon` and `reporting_line: ENGINE_HIERARCHY`.

---
**This does not replace legal advice.**
