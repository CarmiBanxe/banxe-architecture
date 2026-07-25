# ENGINE-MANUS — BANK CORE (heart of the bank) — 2026-07-22 (reframed 2026-07-23)

**BANK CORE / NOT AN EXTERNAL COMPANY / DOCS-ONLY / READ-ONLY RUNTIME**

**ENGINE-MANUS = HEART OF THE BANK (chief orchestrator + client personal-manager). Compiled on open-source (LangGraph / A2A / MCP / LiteLLM / governance). Created, integration pending.**

Reframing (2026-07-23): ENGINE-MANUS is **not** an external company. It is the bank's core engine — a Manus-like compiled runtime with two roles:
1. **Chief conductor (CEO-brain):** knows the full bank structure and technology, coordinates every department head, so the bank runs like a Swiss watch — precise and consistent.
2. **Client personal-manager & friend:** resolves each client's questions across bank functions and helps/suggests solutions within a friendly relationship.

Status: **created, NOT integrated/installed** — currently a "label-heap" of helper files. To be assembled into a single multi-layer heart. Full stack, layers, and integration plan: `../../bank-rooms/F0-engine-manus-room/`.

## Heart stack (summary — full table in engine-manus-stack.md)

The heart is 4 layers. Enumerated & verified heart files across layers = **32** (Layer A 12, B 8, C 5, D 7).
**Count reconciliation `[reconcile]`:** the audit stated *"heart-стек = 21 файл"*; the enumerated 4-layer list verifies **32 present files**. The two figures differ — recorded, **not force-fit**; `[audit]` to reconcile whether "21" excludes the Layer-A shell (12 helper files) or counts modules differently.

- **Layer A — shell (absorbed as sub-modules, NOT distributed to other rooms):** swarm/agents ×6, design_pipeline/agents ×4, fx_engine/fx_agent, webhook_orchestrator/webhook_agent — the 12 helper "label-heap" files, pulled **inward** into the heart.
- **Layer B — orchestrator:** graph_sandbox, tier_workers, swarm/orchestrator, design_pipeline/orchestrator, sca_orchestrator, midaz_agent, midaz_client, budget.
- **Layer C — client-PM:** api/routers/{intent,support,notifications_hub,quant_advisory}, quant_advisory/service.
- **Layer D — substrate:** intent_layer/{canary,composition,observability,shadow}, agents/{_lineage,recorders}, banking-engine/compliance/guardrails_config.yaml.

## Ownership note

- ENGINE-MANUS = **BANK CORE (internal to the bank)** — no longer classified as an external company.
- Its Layer-A sub-modules are absorbed into the heart; they are **not** bank-room employees and are **not** part of the 129 bank agents (BANK-MASTER). They serve the core, which in turn serves all 17 departments and the client directly.
- Contested Layer-A rows (fx_engine, design_pipeline ×4) stay `[pending human ratification]`: whether they are pure heart sub-modules or also bank-room product is for `[audit]`.
- FACTORY (9) and REPAIR-BRIGADE (6) remain **external** companies (see AGENT-OWNERSHIP-SPLIT company-map revision).

## Layer-A inventory (prior AG-ids retained for trace; now heart sub-modules)

| source_path | layer | prior_id | role in heart |
|---|---|---|---|
| services/swarm/agents/base_agent.py | A | AG-F4-006 | swarm base sub-module |
| services/swarm/agents/behavior_agent.py | A | AG-F3-014 | swarm behavior sub-module |
| services/swarm/agents/geo_risk_agent.py | A | AG-F3-013 | swarm geo-risk sub-module |
| services/swarm/agents/product_limits_agent.py | A | AG-F3-015 | swarm product-limits sub-module |
| services/swarm/agents/profile_history_agent.py | A | AG-F3-016 | swarm profile-history sub-module |
| services/swarm/agents/sanctions_agent.py | A | AG-F3-002 | swarm sanctions sub-module |
| services/design_pipeline/agents/compliance_ui_agent.py | A | AG-F4-022 | UI-pipeline sub-module `[pending]` |
| services/design_pipeline/agents/onboarding_agent.py | A | AG-F4-025 | UI-pipeline sub-module `[pending]` |
| services/design_pipeline/agents/report_ui_agent.py | A | AG-F4-023 | UI-pipeline sub-module `[pending]` |
| services/design_pipeline/agents/transaction_ui_agent.py | A | AG-F4-024 | UI-pipeline sub-module `[pending]` |
| services/fx_engine/fx_agent.py | A | AG-F3-021 | fx sub-module `[pending]` (fx_engine vs fx_exchange) |
| services/webhook_orchestrator/webhook_agent.py | A | AG-F4-003 | webhook sub-module |

---
**This does not replace legal advice.**
