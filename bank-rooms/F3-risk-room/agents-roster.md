# F3-risk-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 6 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F3-011 | RiskAgent | services/risk_management/risk_agent.py | RiskAgent | CRO | SMF4 | decision | - | active |
| AG-F3-012 | RiskOversightAgent | services/agents/risk_oversight_agent.py | RiskOversightAgent | CRO | SMF4 | decision `[pending human ratification]` | - | proposed |
| AG-F3-017 | RiskMetricsPort | services/risk/risk_metrics_port.py | RiskMetricsPort | - | - | tooling (MASK/port) | - | active |
| AG-F3-038 | CreditScoringAgent | services/agents/credit_scoring_agent.py | CreditScoringAgent | CRO | SMF4 | decision [gated-counsel] — Annex III credit scoring | - | [gated-counsel] |
| AG-F3-039 | AtoAgent | services/ato_prevention/ato_agent.py | AtoAgent | CRO | SMF4 | decision (HITLProposal) | - | active |
| AG-F3-040 | ConsumerDutyAgent | services/consumer_duty/consumer_duty_agent.py | ConsumerDutyAgent | CRO | SMF4 | decision `[pending human ratification]` — Consumer Duty PS22/9; board SMF champion = ACTION-5 | - | proposed |

---
**This does not replace legal advice.**
