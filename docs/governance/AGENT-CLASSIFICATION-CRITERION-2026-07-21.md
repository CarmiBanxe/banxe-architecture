# Agent Classification Criterion — decision-agent vs tooling-agent (ACTION-1) — 2026-07-21

**GOVERNANCE / CLASSIFICATION CRITERION / DOCS-ONLY / READ-ONLY RUNTIME**
Implements ACTION-1 of `../briefs/CONSULTANT-RESPONSE-ORGCHART-CENSUS-2026-07-21.md`. Built on the lineage tags that already exist in the runtime (L1-Auto / L2 / L3, HITLProposal, MASK-ONLY) — no new taxonomy is introduced.

## §1 Purpose

- Defines which agents are **mandatory** in the AGENT-REGISTRY with `human_double` + `SMF` (decision-agent), and which may be marked `tooling`.
- Based on **CONFIRMED-5** (registry = source of truth) and ACTION-1.
- Draft criterion for `[factory]`/`[audit]` ratification; it does not itself assign agents.

## §2 Criterion (based on existing lineage tags)

**Decision-agent** — an agent for which **at least one** holds:
- lineage **L2 or L3** (participates in orchestration / decision), **OR**
- **produces or carries `HITLProposal`**, **OR**
- **affects a regulated outcome** (client / KYC / payment / ledger / AML / consumer-duty / reporting).

**Tooling-agent** — an agent for which:
- lineage **L1-Auto** with **no `HITLProposal`** and **no regulated-outcome impact** (pure read / dashboard / metric / infra utility), **OR**
- **MASK-ONLY** over a domain with no independent decision.

**Contested cases** → mark **`[pending human ratification]`**; do not self-decide. (Lineage tag counts are the runtime baseline: L1-Auto ~66, L2 ~62, L3 ~49 — informational, not re-derived here.)

## §3 Application rules for the registry

- **decision-agent:** mandatory in the registry; `human_double` + `SMF` fields are **required**.
- **tooling-agent:** may appear in the registry as `tooling`; `human_double` is **optional**.
- **Non-`*_agent.py` functional entities** (e.g. `services/watchdog/*` decision/repair, `retention_enforcer.py`, `audit_query.py`, and the others in `../audit/F4-DEVOPS-AUDIT-FUNCTIONAL-CENSUS-GAP-2026-07-21.md`) are classified by **the same criterion** — a missing `*_agent.py` suffix does not exempt an entity from being a decision-agent.

## §4 Edge cases / open items

- **[factory]** Confirm that the L1 / L2 / L3 lineage tags are the canonical signal of autonomy level.
- **[audit]** Confirm which `watchdog/*` and audit entities count as decision vs tooling (e.g. `RepairEngine.evaluate_and_act` and guarded-action executors likely decision; read-only dashboards likely tooling).
- Any legal/regulatory characterisation → **[counsel]**; no legal conclusions are drawn here.

---
**This does not replace legal advice.**
