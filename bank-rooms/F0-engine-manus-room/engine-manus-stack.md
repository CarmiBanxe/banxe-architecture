# ENGINE-MANUS heart stack — 2026-07-23

**BANK CORE / DOCS-ONLY / READ-ONLY RUNTIME**
All heart files by layer, verified present (read-only) in `~/banxe-emi-stack`. Source: audit heart-stack list + file-existence check. Nothing invented.

**Count CLOSED = 32.** HEART_STACK = **32 verified files** (A 12 · B 8 · C 5 · D 7). The earlier audit figure "21" is superseded — the enumerated, existence-checked stack is 32. No reconcile outstanding.

## Layer A — shell (absorbed as sub-modules; NOT distributed to other rooms) — 12

| layer | path | role | notes |
|---|---|---|---|
| A | services/swarm/agents/base_agent.py | swarm base | verified |
| A | services/swarm/agents/behavior_agent.py | behavior scoring | verified |
| A | services/swarm/agents/geo_risk_agent.py | geo-risk scoring | verified |
| A | services/swarm/agents/product_limits_agent.py | product limits | verified |
| A | services/swarm/agents/profile_history_agent.py | profile history | verified |
| A | services/swarm/agents/sanctions_agent.py | sanctions screening | verified |
| A | services/design_pipeline/agents/compliance_ui_agent.py | UI (compliance) | verified · `[pending human ratification]` |
| A | services/design_pipeline/agents/onboarding_agent.py | UI (onboarding) | verified · `[pending human ratification]` |
| A | services/design_pipeline/agents/report_ui_agent.py | UI (report) | verified · `[pending human ratification]` |
| A | services/design_pipeline/agents/transaction_ui_agent.py | UI (transaction) | verified · `[pending human ratification]` |
| A | services/fx_engine/fx_agent.py | fx | verified · `[pending human ratification]` (fx_engine vs fx_exchange) |
| A | services/webhook_orchestrator/webhook_agent.py | webhook | verified |

## Layer B — orchestrator — 8

| layer | path | role | notes |
|---|---|---|---|
| B | services/banking-engine/graph_sandbox.py | LangGraph sandbox | verified |
| B | services/agent_routing/tier_workers.py | tier routing (workers) | verified |
| B | services/swarm/orchestrator.py | swarm orchestration | verified |
| B | services/design_pipeline/orchestrator.py | design-pipeline orchestration | verified |
| B | services/open_banking/sca_orchestrator.py | SCA orchestration | verified |
| B | services/midaz_mcp/midaz_agent.py | Midaz MCP agent | verified · gated (Midaz/MCP→ledger) `[counsel]` |
| B | services/midaz_mcp/midaz_client.py | Midaz MCP client | verified · gated (Midaz/MCP→ledger) `[counsel]` |
| B | services/runtime_gate/budget.py | budget gate | verified |

## Layer C — client-PM — 5

| layer | path | role | notes |
|---|---|---|---|
| C | api/routers/intent.py | client intent surface | verified |
| C | api/routers/support.py | client support surface | verified |
| C | api/routers/notifications_hub.py | client notifications | verified |
| C | api/routers/quant_advisory.py | advisory surface | verified |
| C | services/quant_advisory/service.py | advisory service | verified |

## Layer D — substrate — 7

| layer | path | role | notes |
|---|---|---|---|
| D | services/intent_layer/canary.py | canary rollout | verified |
| D | services/intent_layer/composition.py | composition | verified |
| D | services/intent_layer/observability.py | observability | verified |
| D | services/intent_layer/shadow.py | shadow execution | verified |
| D | services/agents/_lineage.py | lineage tagging | verified |
| D | services/agents/recorders.py | decision recorders | verified |
| D | services/banking-engine/compliance/guardrails_config.yaml | guardrails config | verified |

**Totals:** A 12 · B 8 · C 5 · D 7 = **32 verified files** (count closed at 32; the "21" figure is superseded).

---
**This does not replace legal advice.**
