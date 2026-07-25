# F4-devops-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 3 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F4-001 | DeployAgent | services/agents/deploy_agent.py | DeployAgent | CTO | SMF26 | decision | HITL-013 | active |
| AG-F4-005 | ObservabilityAgent | services/observability/observability_agent.py | ObservabilityAgent | CTO | SMF26 | tooling `[pending human ratification]` | - | proposed |
| AG-F4-019 | HealthAggregator | services/observability/health_aggregator.py | HealthAggregator | - | - | tooling | - | active |

---
**This does not replace legal advice.**
