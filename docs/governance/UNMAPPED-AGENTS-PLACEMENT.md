# UNMAPPED-Agents Placement — proposal for the 2 §UNMAPPED agents (awaiting operator ratification)

> **Status:** governance **PROPOSAL** (prepare-only). **Additive, pointer-first (ADR-102).** Closes the
> `§UNMAPPED` gap in `AGENT-ORG-ASSIGNMENT-MATRIX.md` (#1006) by proposing an org placement for the two agents
> that carried **no `department` field**. **Placement is derived ONLY from each agent's passport function** —
> **nothing invented.** The **final org-call is the operator's**; this record recommends + justifies. No
> passport is edited, no agent activated, no GUIYON / specproj / NOVELTY-REGISTER touched, no secret read.

## Evidence basis
- `agents/passports/clickhouse_writer.yaml` · `agents/passports/spec_first_auditor.yaml` (read-only).
- `governance/STAFF-MATRIX-v3.md` (both listed: `clickhouse_writer` active, `spec_first_auditor` L2_REVIEW ACTIVE — no department).
- `governance/CANONICAL-ORG-CHART-v2.md` (8 departments) + `AGENT-ORG-ASSIGNMENT-MATRIX.md` §5 CTO/Data-Analytics.

## 1. `clickhouse_writer` → **PROPOSED: CTO / Technology-Data-AI · Data-Analytics**
| field | value |
|---|---|
| **passport function (evidence)** | *"ClickHouse Audit Writer"* — Level-3 **GREEN** adapter that **persists DecisionEvents to ClickHouse** (`banxe` DB, `decision_events` table, 5-yr TTL for I-17 DORA retention); append-only audit-trail writer (ARP prohibited on it, I-24). `bounded_context: CTX-03`. |
| **proposed department** | **CTO / Technology-Data-AI → Data-Analytics** · `human_double: Head of Data` · `reports_to: CTO (SMF26)` · **1st Line** |
| **rationale (by function)** | It is a **data-pipeline adapter that writes to ClickHouse** — the same class and sub-dept as the already-placed `data_lake_elt_agent` (GREEN) and `bi_dashboard_governor` under **Data-Analytics / Head of Data** (matrix §5). GREEN trust-zone + data-persistence function ⇒ Data-Engineering, not a compliance/finance line. |
| **alternative** | **Internal Audit (3rd Line)** — because it writes the *audit trail* (`decision_events`, DORA retention). Rejected as primary: it is an **infrastructure adapter that writes the data**, not an audit-decision agent; Internal Audit is the **consumer** of what it persists, so ownership sits with CTO/Data (the pipeline owner), with Internal Audit as a downstream stakeholder. |
| **H-links** | `data_lake_elt_agent`, `bi_dashboard_governor` (Data-Analytics peers) |

## 2. `spec_first_auditor` → **PROPOSED: Developer/Factory plane — governance-tooling (OUT-OF-BANK-ORG)**
| field | value |
|---|---|
| **passport function (evidence)** | *"Spec-First Auditor"* — *"Контролёр исполнения Spec-First Methodology"*; `bounded_context: **CTX-00-DEVELOPER**`; `audit_script: ~/developer/spec-first/audit/spec_first_auditor.py`; enforces that Spec-First files live only under `~/developer/`. `trust_zone: AMBER`, `L2_REVIEW`. |
| **proposed placement** | **Developer / Factory plane — governance-tooling** (Architecture-Enablement / Spec-First methodology enforcement). **OUT-OF-BANK-ORG** — it is a **developer-plane factory tool**, not a bank C-suite function. `reports_to:` factory-lead / CTO-as-plane-owner. |
| **rationale (by function)** | `CTX-00-DEVELOPER` + a `~/developer/`-scoped audit script + "methodology controller" ⇒ it governs the **software-delivery/factory plane**, not a banking domain. It is the tooling analogue of a CI guardian, not a bank operational agent — so it does **not** belong in the 8 bank departments. |
| **alternative (if it MUST sit in-bank)** | **CTO / Technology-Data-AI → Engineering / Developer-Platform** · `human_double: Head of Platform Engineering` — alongside the existing "Developer Platform" governors (`design_pipeline_agent`, `sandbox_rails_governor`, `sdk_release_governor`, `multi_tenancy_agent`) in matrix §5. Choose this only if every agent must be inside the bank org chart; otherwise the developer/factory-plane placement is the accurate one. |
| **H-links** | (developer-plane) — `design_pipeline_agent` / factory guardians, if placed under Developer-Platform |

## 3. Net effect on the matrix
`AGENT-ORG-ASSIGNMENT-MATRIX.md` §UNMAPPED moves from **2 escalated/unmapped** → **0 unmapped**: both are now
**`PROPOSED → <dept> (pending ratification)`** — i.e. the fleet is **70/70 placed as proposals**, with the two
former "homeless" agents carrying an evidence-grounded recommendation the operator ratifies.

## 4. Boundaries
- **PROPOSAL only** — the operator ratifies the final org-call; this record does not decide it.
- **No passport edited, no agent activated, no department invented** (both derived from passport function).
- **No GUIYON / specproj / NOVELTY-REGISTER touched; no secret read.** Only this doc + the matrix §UNMAPPED note + shard.

## Anchors
`docs/governance/AGENT-ORG-ASSIGNMENT-MATRIX.md` (#1006 — the §UNMAPPED gap this closes; §5 Data-Analytics /
Developer-Platform sub-depts) · `agents/passports/clickhouse_writer.yaml` + `agents/passports/spec_first_auditor.yaml`
(the evidence, read-only, unedited) · `governance/CANONICAL-ORG-CHART-v2.md` (8 departments, CTO/SMF26) ·
`governance/STAFF-MATRIX-v3.md` (both agents active, no department) · ADR-102 (restates none). Operator directive
2026-07-04 (close the 2-UNMAPPED gap by placement proposal; derive from passport function only; operator
ratifies the final org-call).
