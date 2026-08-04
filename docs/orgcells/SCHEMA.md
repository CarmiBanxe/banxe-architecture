# ORG-CELL SCHEMA — 2026-08-03

**STATUS: PROPOSED — pending MC-C1 counsel-review. NOT canon.**
**Case:** BANXE-EMI / org-structure (AI-BANK model) · **Role:** FACTORY · **Sandbox-only, no push.**
**Executes:** Fable-5 ruling `FABLE5-CONSULTATION-RESPONSE-MT10-AND-ORGCELLS-2026-08-01.md` §4 (not reopened).

> **MC-C1 `[counsel]`:** the MLRO-independence encoding below binds **regulatory structure**
> (SM&CR **SMF17** independence). This schema is **not declared canon** until counsel review.
> Everything created under it is `status: PROPOSED`.

---

## 0. The ONE canonical rule (verbatim — governs every cell built from this schema)

> **«Сначала подготовь клетку — функции, вертикальная связь, горизонтальные связи,
> полномочия — как спецификацию; только затем рефактори рабочий код Banksy В эту клетку,
> извлекая исключительно функции и порядок их работы (как банк работает сегодня) и
> никогда — секреты, credentials или реальные данные (sandbox-only); этот рефактор есть
> пере-осмысление под модель AI-банка (движок-Директор), а не механический порт кода
> bank-with-agents.»**

## 1. Model — a forest of exactly TWO trees

| Tree | Root | Root `kind` | `reporting_line` of the whole tree |
|---|---|---|---|
| **ENGINE tree** | the Banksy engine acting as Director | `ENGINE_DIRECTOR` | `ENGINE_HIERARCHY` |
| **MLRO tree** | the MLRO cell | `MLRO_ROOT` | `MLRO_LINE` |

Both roots carry `vertical.manager_ref: null`. There is **no node above either root** and **no
edge between the trees**. AI-BANK model (invariant ii): the engine **is** the Director; agents
are the org's constituents, not decorations on a human org chart.

## 2. Cell record — 12 fields

| # | Field | Content |
|---|---|---|
| 1 | `cell_id` | stable kebab-case slug; **never renumbered** (ADR-119 spirit) |
| 2 | `name` | human-readable |
| 3 | `kind` | `ENGINE_DIRECTOR` \| `MLRO_ROOT` \| `DEPARTMENT` \| `CELL` |
| 4 | `functions[]` | **PRIMARY.** Per function: `name`, `description`, `input→output`, `execution order` |
| 5 | `reporting_line` | `ENGINE_HIERARCHY` \| `MLRO_LINE` |
| 6 | `vertical.manager_ref` | manager's `cell_id`; `null` **only** for the two roots; MUST match own `reporting_line` |
| 7 | `horizontal[]` | per peer: `peer_ref` + interaction (what this cell does **with** that peer) |
| 8 | `authority` | decisions taken **alone** vs **escalated**; HITL binding — AUTO > 90 / REVIEW 70–90 / BLOCK < 70 (refs) |
| 9 | `department_ref` | owning department `cell_id`; `null` for roots and departments |
| 10 | `source_refs[]` | legacy Banksy modules the functions were EXTRACTED from — **paths only**, never content |
| 11 | `data_policy` | constant: `sandbox-only; no secrets, no credentials, no real data` |
| 12 | `status` | `PROPOSED` \| `ACTIVE` — **ACTIVE only with cited activation evidence** (passport lesson: the body is the truth, not the field) |

## 3. Validation rules (a violating record is schema-INVALID, not merely discouraged)

- **V1 — two roots only.** Exactly one `ENGINE_DIRECTOR` and exactly one `MLRO_ROOT`; both with `vertical.manager_ref: null`. Any other cell with a null manager is INVALID.
- **V2 — same-line management.** `vertical.manager_ref` MUST resolve to an existing cell whose `reporting_line` equals this cell's `reporting_line`. **A cross-line manager reference is INVALID.**
- **V3 — compliance ⇒ MLRO line.** Any cell carrying a compliance-monitoring function class MUST have `reporting_line: MLRO_LINE`.
- **V4 — no inter-tree edges in `vertical`.** `horizontal[]` MAY cross lines (that is cooperation, not authority); `vertical` MAY NOT (that would be authority).
- **V5 — ACTIVE needs evidence.** `status: ACTIVE` requires a cited activation reference; absent it, the record is `PROPOSED` regardless of any claim.
- **V6 — sources by path.** `source_refs[]` carry paths only; duplicating source content into a cell record is INVALID (ADR-102: complete over existing, reference don't duplicate).

## 4. MLRO-INVARIANT PROOF — why "MLRO via the engine" is unrepresentable

Let `L(c)` be `reporting_line` of cell `c`, and `M(c)` its `vertical.manager_ref`.

1. `L(MLRO_ROOT) = MLRO_LINE` and `M(MLRO_ROOT) = null` (V1) — the MLRO root **has no parent**, so no edge can place the engine above it.
2. For any MLRO-line cell `c` (`L(c) = MLRO_LINE`), V2 forces `L(M(c)) = MLRO_LINE`. Every manager of an MLRO-line cell is itself MLRO-line.
3. By induction over the `vertical` chain, every ancestor of any MLRO-line cell is MLRO-line, terminating at `MLRO_ROOT` (V1 — it is the only MLRO-line cell with a null manager).
4. `L(ENGINE_DIRECTOR) = ENGINE_HIERARCHY ≠ MLRO_LINE`. Therefore the engine **cannot appear anywhere** on the vertical chain of any MLRO-line cell — the record that would express it fails V2 and cannot be written.
5. The only cross-tree relation the schema can express is `horizontal[]` — cooperation, explicitly not authority (V4).

**Conclusion:** MLRO independence is a property of the **data model**, not a caption. A reorganisation that subordinated MLRO to the engine could not be expressed as a valid record at all; it would have to change this schema — which is exactly the change counsel must gate (MC-C1).

*(SM&CR alignment reference, paths only: `governance/CANONICAL-ORG-CHART-v2.md` — Dept-6 MLRO/Financial-Crime, independent 2nd line reporting to Board, "NOT inside Compliance; NOT under CFO/COO"; `banxe-emi-stack: services/hitl/org_roles.py` (cross-repo) — MLRO = SMF17, SAR/PEP/sanctions-reversal non-delegable.)*

## 5. Frozen / not-to-touch

- **MT-05 `[pending]` — `aml_orchestrator` identity conflict (3 passports / 2 ids) is FROZEN.** Cells may carry a **placeholder reference only**. Do **not** resolve, deduplicate, re-passport, or pick an id under this schema.

## 6. Source register (paths only — ADR-102 reference, never duplicate)

| Source | Path | Resolution |
|---|---|---|
| Parent org canon (8 depts, 3 lines of defence, Dept-6 MLRO→Board SMF17) | `governance/CANONICAL-ORG-CHART-v2.md` | **repo-local** |
| MLRO operating-model delta | `governance/SPRINT-4-MLRO-LINE.md` | **repo-local** |
| Four-floors operating model (FLOOR1..4) | `docs/architecture/BANK-OPERATING-MODEL-FOUR-FLOORS-2026-07-18.md` | **repo-local** |
| MLRO human passport | `docs/canon/passports/mlro.yaml` | **repo-local** |
| SMF-mapped roles + HITL gates | `banxe-emi-stack: services/hitl/org_roles.py` | cross-repo (path-only) |
| MLRO agent soul | `banxe-emi-stack: agents/compliance/soul/mlro_agent.soul.md` | cross-repo (path-only) |

> **Placement — RESOLVED.** These records live in **banxe-architecture**, alongside the parent
> org canon they extend; the earlier split-brain caveat is withdrawn. Four of the six sources
> resolve **repo-locally**; the two implementation sources stay **cross-repo, path-only** by
> design — the code plane is referenced, never copied into the governance plane (ADR-102).

---
**This does not replace legal advice.**
