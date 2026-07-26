# F3 Functional Agent Shortlist (filtered from raw grep) — 2026-07-21

**FLOOR-3 / FUNCTIONAL SHORTLIST (ACTION-3, step 1) / DOCS-ONLY / READ-ONLY RUNTIME**
Filters non-`*_agent.py` grep candidates in F3 zones (AML/Risk/Treasury/FinBI/RegRep) per `../governance/AGENT-CLASSIFICATION-CRITERION-2026-07-21.md`. Read-only over `~/banxe-emi-stack`.

## Filter applied
- **Kept:** L2/L3 lineage, OR carries `HITLProposal`, OR affects a regulated outcome (AML/risk/treasury/reporting).
- **Dropped:** tests, `__init__`, pure ports/utilities without a decision, duplicates, provider adapters with no independent decision.

## Shortlist (non-`*_agent.py` functional entities)

| path | signal | decision\|tooling | proposed-room |
|---|---|---|---|
| `services/aml/tx_monitor.py` | lineage **L3** — transaction monitoring/decision | decision | F3-aml |
| `services/fraud/fraud_aml_pipeline.py` | fraud/AML pipeline orchestration | decision | F3-aml |
| `services/transaction_monitor/scoring/risk_scorer.py` | TM risk scoring → drives alerts | decision | F3-aml |
| `services/transaction_monitor/scoring/rule_engine.py` | TM rule engine (decision logic) | decision | F3-aml |
| `services/transaction_monitor/alerts/alert_generator.py` | AML alert generation | decision | F3-aml |
| `services/transaction_monitor/alerts/explanation_engine.py` | explains alerts, no independent decision | tooling | F3-aml |
| `services/fraud/fraud_port.py` | port/contract, no independent decision | tooling | F3-aml |
| `services/reporting/fin060_generator_v2.py` | `HITLProposal` — FIN060 regulated report | decision | F3-regrep |
| `services/reporting/regdata_return.py` | RegData return generation (regulated) | decision | F3-regrep |
| `services/treasury/sweep_engine.py` | fund-sweep engine (operational fund movement) | decision | F3-treasury |
| `services/treasury/liquidity_monitor.py` | liquidity monitor (no HITL/lineage) | tooling `[pending human ratification]` | F3-treasury |
| `services/treasury/fx_exposure_port.py` | port/contract | tooling | F3-treasury |
| `services/multi_currency/balance_engine.py` | balance computation | tooling `[pending human ratification]` | F3-treasury |
| `services/risk/risk_metrics_port.py` | MASK/port (metrics contract) | tooling | F3-risk |

**Count into F3:** 14 non-`*_agent.py` functional entities passed the filter (rest = tests/`__init__`/ports-without-decision/adapters/duplicates/non-F3 domains).

---
**This does not replace legal advice.**
