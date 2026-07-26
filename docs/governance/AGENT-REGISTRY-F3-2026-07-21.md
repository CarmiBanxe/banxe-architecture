# AGENT REGISTRY — Floor 3 — 2026-07-21

**GOVERNANCE / AGENT REGISTRY F3 (ACTION-3) / DOCS-ONLY / READ-ONLY RUNTIME**
Populated per `AGENT-REGISTRY-TEMPLATE.md`, classified per `AGENT-CLASSIFICATION-CRITERION-2026-07-21.md`, same 12-column schema as `AGENT-REGISTRY-F4-2026-07-21.md`. F3 only (AML/Risk/Treasury/FinBI/RegRep). `human_double`/`SMF` from `../ORG-STRUCTURE.md`: MLRO/SMF17 (aml), CRO/SMF4 (risk), CFO/SMF2 (treasury/finbi/regrep). Read-only over `~/banxe-emi-stack`.

## Registry rows (F3)

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F3-001 | SanctionsScreeningAgent | services/sanctions_screening/sanctions_agent.py | SanctionsAgent | F3-aml | AML | F3 | MLRO | SMF17 | decision | HITL-003/004 | active |
| AG-F3-002 | SwarmSanctionsAgent | services/swarm/agents/sanctions_agent.py | SanctionsAgent | F3-aml | AML | F3 | MLRO | SMF17 | decision | HITL-003/004 | active |
| AG-F3-003 | FraudTracerAgent | services/fraud_tracer/tracer_agent.py | TracerAgent | F3-aml | AML | F3 | MLRO | SMF17 | decision | - | active |
| AG-F3-004 | TxMonitor | services/aml/tx_monitor.py | TxMonitor | F3-aml | AML | F3 | MLRO | SMF17 | decision | - (TM SLA) | active |
| AG-F3-005 | FraudAmlPipeline | services/fraud/fraud_aml_pipeline.py | FraudAmlPipeline | F3-aml | AML | F3 | MLRO | SMF17 | decision | - | active |
| AG-F3-006 | TMRiskScorer | services/transaction_monitor/scoring/risk_scorer.py | RiskScorer | F3-aml | AML | F3 | MLRO | SMF17 | decision | - | active |
| AG-F3-007 | TMRuleEngine | services/transaction_monitor/scoring/rule_engine.py | RuleEngine | F3-aml | AML | F3 | MLRO | SMF17 | decision | - | active |
| AG-F3-008 | TMAlertGenerator | services/transaction_monitor/alerts/alert_generator.py | AlertGenerator | F3-aml | AML | F3 | MLRO | SMF17 | decision | - | active |
| AG-F3-009 | TMExplanationEngine | services/transaction_monitor/alerts/explanation_engine.py | ExplanationEngine | F3-aml | AML | F3 | - | - | tooling | - | active |
| AG-F3-010 | FraudPort | services/fraud/fraud_port.py | FraudPort | F3-aml | AML | F3 | - | - | tooling | - | active |
| AG-F3-011 | RiskAgent | services/risk_management/risk_agent.py | RiskAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision | - | active |
| AG-F3-012 | RiskOversightAgent | services/agents/risk_oversight_agent.py | RiskOversightAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision `[pending human ratification]` | - | proposed |
| AG-F3-013 | GeoRiskAgent | services/swarm/agents/geo_risk_agent.py | GeoRiskAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision | - | active |
| AG-F3-014 | BehaviorAgent | services/swarm/agents/behavior_agent.py | BehaviorAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision | - | active |
| AG-F3-015 | ProductLimitsAgent | services/swarm/agents/product_limits_agent.py | ProductLimitsAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision | - | active |
| AG-F3-016 | ProfileHistoryAgent | services/swarm/agents/profile_history_agent.py | ProfileHistoryAgent | F3-risk | Risk | F3 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-017 | RiskMetricsPort | services/risk/risk_metrics_port.py | RiskMetricsPort | F3-risk | Risk | F3 | - | - | tooling (MASK/port) | - | active |
| AG-F3-018 | TreasuryAgent | services/treasury/treasury_agent.py | TreasuryAgent | F3-treasury | Treasury | F3 | CFO | SMF2 | decision | HITL-016 | active |
| AG-F3-019 | TreasuryAgentAlt | services/agents/treasury_agent.py | TreasuryAgent | F3-treasury | Treasury | F3 | - | - | tooling (MASK-ONLY) | - | active |
| AG-F3-020 | FxRateAgent | services/fx_rates/fx_rate_agent.py | FxRateAgent | F3-treasury | Treasury | F3 | CFO | SMF2 | decision | - | active |
| AG-F3-021 | FxEngineAgent | services/fx_engine/fx_agent.py | FxAgent | F3-treasury | Treasury | F3 | CFO | SMF2 | decision `[pending human ratification]` | - | proposed |
| AG-F3-022 | FxExchangeAgent | services/fx_exchange/fx_agent.py | FxAgent | F3-treasury | Treasury | F3 | CFO | SMF2 | decision `[pending human ratification]` | - | proposed |
| AG-F3-023 | MultiCurrencyAgent | services/multi_currency/multicurrency_agent.py | MultiCurrencyAgent | F3-treasury | Treasury | F3 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-024 | SweepEngine | services/treasury/sweep_engine.py | SweepEngine | F3-treasury | Treasury | F3 | CFO | SMF2 | decision | - | active |
| AG-F3-025 | LiquidityMonitor | services/treasury/liquidity_monitor.py | LiquidityMonitor | F3-treasury | Treasury | F3 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-026 | FxExposurePort | services/treasury/fx_exposure_port.py | FxExposurePort | F3-treasury | Treasury | F3 | - | - | tooling (port) | - | active |
| AG-F3-027 | BalanceEngine | services/multi_currency/balance_engine.py | BalanceEngine | F3-treasury | Treasury | F3 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-028 | AnalyticsAgent | services/agents/analytics_agent.py | AnalyticsAgent | F3-finbi | FinBI | F3 | CFO | SMF2 | decision | - | active |
| AG-F3-029 | ReportingAnalyticsAgent | services/reporting_analytics/analytics_agent.py | AnalyticsAgent | F3-finbi | FinBI | F3 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-030 | RegulatoryReportingAgent | services/regulatory_reporting/regulatory_reporting_agent.py | RegulatoryReportingAgent | F3-regrep | RegRep | F3 | CFO | SMF2 | decision | HITL-010 | active |
| AG-F3-031 | ReportingAgent | services/reporting/reporting_agent.py | ReportingAgent | F3-regrep | RegRep | F3 | CFO | SMF2 | decision | HITL-010 (I-24 append-only) | active |
| AG-F3-032 | FIN060GeneratorV2 | services/reporting/fin060_generator_v2.py | FIN060Generator | F3-regrep | RegRep | F3 | CFO | SMF2 | decision | HITL-010 (I-24 append-only) | active |
| AG-F3-033 | RegDataReturn | services/reporting/regdata_return.py | RegDataReturn | F3-regrep | RegRep | F3 | CFO | SMF2 | decision | HITL-010 | active |

## Verdict note

- **F3 rows:** 33 (19 from `*_agent.py` incl. F3 swarm domains; 14 from the functional shortlist).
- **decision-agents:** 23 (all with `human_double`+`SMF`; three `proposed`/`[pending]`: AG-F3-012, -021, -022).
- **tooling-agents:** 10 (AG-F3-009, -010, -016, -017, -019, -023, -025, -026, -027, -029).
- **[pending human ratification]:** 8 (AG-F3-012 risk-oversight, -016 profile-history, -021 fx-engine, -022 fx-exchange, -023 multicurrency, -025 liquidity-monitor, -027 balance-engine, -029 reporting-analytics) — lineage/decision ambiguity, not self-decided.
- **Functional non-suffix passing filter into F3:** 14 (per the shortlist).
- **Swarm domains landed in correct F3 rooms** (NOT F4): sanctions → F3-aml (AG-F3-002); geo_risk / behavior / product_limits / profile_history → F3-risk (AG-F3-013/014/015/016). `base_agent` remains F4-ai-platform (framework/abstract, in the F4 pilot).
- **Cross-floor note:** `services/support/feedback_analytics_agent.py` is support-domain → **F1-support**, deliberately excluded from F3.

Open: `[factory]` confirm counting canon vs files(86)/classes(77); `[audit]` ratify the 8 pending rows and confirm decision-vs-tooling for TM/treasury/FX entities. All legal → `[counsel]`.

---
**This does not replace legal advice.**

## Reconciliation append — 2026-07-22 (coverage closure: UNPLACED placement)

Append-only; existing rows above unchanged. Rows added per REGISTRY-COVERAGE-CLOSURE-2026-07-21.md.

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F3-034 | BiAgent | services/agents/bi_agent.py | BiAgent | F3-finbi | FinBI | F3 | - | - | tooling (L1-Auto) | - | active |
| AG-F3-035 | DataQualityAgent | services/agents/data_quality_agent.py | DataQualityAgent | F3-finbi | FinBI | F3 | - | - | tooling (L1-Auto) | - | active |
| AG-F3-036 | ForecastAgent | services/agents/forecast_agent.py | ForecastAgent | F3-finbi | FinBI | F3 | - | - | tooling (MASK) | - | active |
| AG-F3-037 | FpaAgent | services/agents/fpa_agent.py | FpaAgent | F3-finbi | FinBI | F3 | - | - | tooling (L1-Auto) | - | active |
| AG-F3-038 | CreditScoringAgent | services/agents/credit_scoring_agent.py | CreditScoringAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision [gated-counsel] — Annex III credit scoring | - | [gated-counsel] |
| AG-F3-039 | AtoAgent | services/ato_prevention/ato_agent.py | AtoAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision (HITLProposal) | - | active |

## Reconciliation append #2 — 2026-07-22 (coverage-closure gap fix)

Append-only. `consumer_duty_agent` was previously only a prose cross-floor note (excluded from F1 per CONFIRMED-3) but never rowed — now placed.

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F3-040 | ConsumerDutyAgent | services/consumer_duty/consumer_duty_agent.py | ConsumerDutyAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision `[pending human ratification]` — Consumer Duty PS22/9; board SMF champion = ACTION-5 | - | proposed |
