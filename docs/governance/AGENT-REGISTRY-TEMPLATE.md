# AGENT REGISTRY — TEMPLATE (ACTION-3) — 2026-07-21

**GOVERNANCE / SOURCE-OF-TRUTH TEMPLATE / DOCS-ONLY / EMPTY (no rows in this step)**

Per **CONFIRMED-5** (`../briefs/CONSULTANT-RESPONSE-ORGCHART-CENSUS-2026-07-21.md`): this **registry is the source of truth** (agent → room → human-double → SMF). File count (86) / class count (77) are **reconciliation metrics only**, not the source of truth.

This step delivers the **empty template + fill rules**. Rows are NOT populated here.

## Registry table

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |  |  |  |  |  |

## Fill rules

- **agent_id** — stable unique id (e.g. `AG-0001`); never reused.
- **canonical_name** / **class** / **source_path** — from the runtime; where the entity is not a `*_agent.py` file (see the functional census `../audit/F4-DEVOPS-AUDIT-FUNCTIONAL-CENSUS-GAP-2026-07-21.md`), record the actual class/script/workflow path.
- **room / department / floor** — from the room model (F1–F4); placement is governance mapping, not legal ownership.
- **human_double / SMF** — the accountable human and SM&CR function (only known SMFs: SMF1/2/4/5/17/24/26).
- **decision_or_tooling** — `decision` or `tooling`:
  - **decision-agent** — affects a regulated outcome and is HITL-gated → **MANDATORY** in the registry **with a human_double**.
  - **tooling-agent** — CI script / embedded function with no regulated-outcome authority → marked `tooling`; **may have no human_double**.
  - Criterion pending formalisation → mark such rows **[pending ACTION-1]** until the decision-vs-tooling criterion is ratified.
- **hitl_gate** — the applicable HITL-MATRIX gate id (e.g. `HITL-0xx`) or `-` for none; do not modify `HITL-MATRIX.yaml` from here.
- **status** — lifecycle marker (e.g. `active`, `proposed`, `deprecated`, `[pending ACTION-1]`).

## Reconciliation note

- Files(86)/classes(77) are compared **against** this registry, not vice-versa. Divergence (registry entry with no file, or agent-like entity with no registry row — including the non-`*_agent.py` functional candidates) is a reconciliation finding, not a source-of-truth change.
- Populating rows is a later step; it requires the ACTION-1 criterion (decision vs tooling) and `[audit]`/`[factory]` sign-off on which functional candidates qualify.

## Append-note (2026-07-21)

**ACTION-1 criterion ratified draft → see `AGENT-CLASSIFICATION-CRITERION-2026-07-21.md`.** Every `[pending ACTION-1]` marker in the fill rules above is now resolved by that criterion (decision-agent = L2/L3 OR carries HITLProposal OR affects a regulated outcome → mandatory row with human_double+SMF; tooling-agent = L1-Auto без HITLProposal и без регулируемого исхода, ИЛИ MASK-ONLY → human_double optional; contested → `[pending human ratification]`). Table above unchanged.

---
**This does not replace legal advice.**
