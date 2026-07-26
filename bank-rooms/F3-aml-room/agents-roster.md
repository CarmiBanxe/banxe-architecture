# F3-aml-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 9 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F3-001 | SanctionsScreeningAgent | services/sanctions_screening/sanctions_agent.py | SanctionsAgent | MLRO | SMF17 | decision | HITL-003/004 | active |
| AG-F3-003 | FraudTracerAgent | services/fraud_tracer/tracer_agent.py | TracerAgent | MLRO | SMF17 | decision | - | active |
| AG-F3-004 | TxMonitor | services/aml/tx_monitor.py | TxMonitor | MLRO | SMF17 | decision | - (TM SLA) | active |
| AG-F3-005 | FraudAmlPipeline | services/fraud/fraud_aml_pipeline.py | FraudAmlPipeline | MLRO | SMF17 | decision | - | active |
| AG-F3-006 | TMRiskScorer | services/transaction_monitor/scoring/risk_scorer.py | RiskScorer | MLRO | SMF17 | decision | - | active |
| AG-F3-007 | TMRuleEngine | services/transaction_monitor/scoring/rule_engine.py | RuleEngine | MLRO | SMF17 | decision | - | active |
| AG-F3-008 | TMAlertGenerator | services/transaction_monitor/alerts/alert_generator.py | AlertGenerator | MLRO | SMF17 | decision | - | active |
| AG-F3-009 | TMExplanationEngine | services/transaction_monitor/alerts/explanation_engine.py | ExplanationEngine | - | - | tooling | - | active |
| AG-F3-010 | FraudPort | services/fraud/fraud_port.py | FraudPort | - | - | tooling | - | active |

---
**This does not replace legal advice.**
