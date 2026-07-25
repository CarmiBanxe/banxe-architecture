# Agent Ownership Split (by declaration) — 2026-07-22

**GOVERNANCE-AUDIT / OWNERSHIP-BY-DECLARATION R2 / DOCS-ONLY / READ-ONLY RUNTIME**
The combined MASTER (147 rows) mixed agents owned by different companies. This report splits them by declared source-path ownership and records the corrected bank headcount. Read-only over `~/banxe-emi-stack`; declarations not overridden.

## Owner → count

| owner | count | registry | in bank headcount? |
|---|---|---|---|
| **BANK** (BANXE EMI Bank) | 129 | `../governance/AGENT-REGISTRY-BANK-MASTER-2026-07-22.md` | yes |
| **ENGINE-MANUS** (engine) | 12 | `../governance/COMPANY-REGISTRY-ENGINE-MANUS-2026-07-22.md` | no (engine component) |
| **REPAIR-BRIGADE** (self-healing infra) | 6 | `../governance/COMPANY-REGISTRY-REPAIR-BRIGADE-2026-07-22.md` | no (infra, 0 `*_agent.py`) |
| **FACTORY** | 0 | `../governance/COMPANY-REGISTRY-FACTORY-2026-07-22.md` | `[pending: confirm external repo]` |
| **TOTAL (old MASTER)** | 147 | `../governance/AGENT-REGISTRY-MASTER-2026-07-22.md` (superseded for bank) | — |

## Removed from bank MASTER

**ENGINE-MANUS (12):**
- swarm/* ×6 — AG-F3-002 (sanctions), AG-F3-013 (geo_risk), AG-F3-014 (behavior), AG-F3-015 (product_limits), AG-F3-016 (profile_history), AG-F4-006 (base_agent).
- webhook_orchestrator ×1 — AG-F4-003 (webhook_agent).
- fx_engine ×1 — AG-F3-021 (fx_agent) — **`[pending human ratification]`** ENGINE-MANUS vs BANK-F3-treasury.
- design_pipeline ×4 — AG-F4-022/023/024/025 (compliance_ui / report_ui / transaction_ui / onboarding) — **`[pending human ratification]`** ENGINE-MANUS (UI-pipeline) vs BANK ("BANXE EMI Bank" marker).

**REPAIR-BRIGADE (6):** watchdog/* — AG-F4-007..012 (repair_engine, guarded_actions, decision_policy, root_cause_classifier, best_solution, watchdog). Contains 0 `*_agent.py`; excluded from agent-registry entirely.

## New bank agent number

- **Bank agents = 129** (was 147). Removed: 12 ENGINE-MANUS + 6 REPAIR-BRIGADE = 18.
- **Per-floor (bank):** F1 = 34 · F2 = 48 · F3 = 34 · F4 = 13.
- Biggest change: F4 dropped 25 → 13 (all watchdog + design_pipeline + webhook + swarm-base left); F3 dropped 40 → 34 (swarm domain agents + fx_engine left).

## Contested (parked, not self-decided)

- `fx_engine/fx_agent` (AG-F3-021) — ENGINE-MANUS **or** BANK-F3-treasury (fx_engine vs fx_exchange, AG-F3-022 stays BANK). `[pending human ratification]` `[audit]`.
- `design_pipeline/*` ×4 (AG-F4-022..025) — ENGINE-MANUS (UI-pipeline) **or** BANK (declares "BANXE EMI Bank"). `[pending human ratification]` `[audit]`.
- If `[audit]` rules any contested row BANK, it returns to BANK-MASTER (bank count ≤ 134).

## Notes

- Old 147-row MASTER retained as the full pre-split consolidation; header now points to BANK-MASTER for bank headcount (superseded note added, not rewritten).
- FACTORY agents not fabricated — empty skeleton pending external-repo confirmation.
- Company/legal characterisation of ownership beyond the in-file declarations remains `[counsel]`.

---
**This does not replace legal advice.**

## Company-map revision — 2026-07-23 (ENGINE-MANUS = BANK CORE)

Append-only revision. ENGINE-MANUS is **re-classified from "external company" to BANK CORE (heart of the bank)** — an internal, compiled open-source engine (LangGraph/A2A/MCP/LiteLLM), created but integration-pending. Its Layer-A sub-modules are absorbed inward (not distributed to rooms), remain outside the 129 bank agents, and serve all 17 departments + the client directly.

| owner | count | scope | in bank headcount (129)? |
|---|---|---|---|
| **BANK** (departments) | 129 | internal — 17 rooms | yes |
| **ENGINE-MANUS** (heart/core) | heart stack (A12/B8/C5/D7 = 32 verified; audit "21" `[reconcile]`) | **BANK CORE — internal**, serves all departments + client | no (core, not a room employee) |
| **FACTORY** | 9 | **external company** — build + quality-gate + canon-enforcement (hw/machines/models dev + oversight) | no |
| **REPAIR-BRIGADE** | 6 | **external** — factory partner, self-healing infra | no |

- ENGINE-MANUS moved **inside** the bank (core) → `bank-rooms/F0-engine-manus-room/`.
- FACTORY and REPAIR-BRIGADE remain **external** companies.
- Contested Layer-A modules (fx_engine, design_pipeline ×4) stay `[pending human ratification]` `[audit]`.
- Count `[reconcile]`: heart audit figure 21 vs enumerated/verified 32 — see engine-manus-stack.md.

*This does not replace legal advice.*

## Company-map revision #2 — 2026-07-23 (BANKSY ENGINE = BANK CORE)

Append-only. The bank core engine (formerly "ENGINE-MANUS") is named **BANKSY ENGINE** — heart of the bank, Manus-like agentic engine compiled on open-source (OpenManus base + LangGraph/A2A/MCP/LiteLLM). Two roles: CEO-conductor + client personal-manager. Status: concept + parts exist, single stack NOT assembled (see `../../bank-rooms/F0-engine-manus-room/BANKSY-ENGINE-STACK-REGISTRY.md` + `…-INTEGRATION-PLAN.md`).

| owner | role | scope | in bank headcount (129)? |
|---|---|---|---|
| **BANK** (departments) | 17 rooms, 129 agents | internal | yes |
| **BANKSY ENGINE** (core) | heart: CEO-conductor + client-PM; 4 layers; expansion-agents | **BANK CORE — internal**, serves all departments + client | no (core, not a room employee) |
| **FACTORY** | build + quality-gate + canon-enforcement | **external partner** | no |
| **REPAIR-BRIGADE** | self-healing infra | **external partner** (factory-side) | no |

- BANKSY ENGINE is inside the bank (core); FACTORY (9) + REPAIR-BRIGADE (6) are external partners.
- Stack unified in a registry + plan (docs); code assembled later by the factory.
- Contested/expansion items → `[pending human ratification]` `[audit]`; count `[reconcile]` (21 vs 32).

*This does not replace legal advice.*
