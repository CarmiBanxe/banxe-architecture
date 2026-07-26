# F1-customer-ops-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 18 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F1-015 | NotificationAgent | services/agents/notification_agent.py | NotificationAgent | Head of Customer Ops/COO | SMF24 | decision | `[gdpr-consent]` | active |
| AG-F1-016 | NotificationHubAgent | services/notification_hub/notification_agent.py | NotificationAgent | Head of Customer Ops/COO | SMF24 | decision | `[gdpr-consent]` | active |
| AG-F1-017 | PreferencesAgent | services/user_preferences/preferences_agent.py | PreferencesAgent | Head of Customer Ops/COO | SMF24 | decision | `[gdpr-consent]` | active |
| AG-F1-018 | DocumentAgent | services/document_management/document_agent.py | DocumentAgent | - | - | tooling | `[gdpr-consent]` | active |
| AG-F1-019 | RetentionEngine | services/document_management/retention_engine.py | RetentionEngine | Head of Customer Ops/COO | SMF24 | decision | `[gdpr-consent]` | active |
| AG-F1-020 | NotificationService | services/notifications/notification_service.py | NotificationService | - | - | tooling | `[gdpr-consent]` | active |
| AG-F1-021 | CustomerService | services/customer/customer_service.py | CustomerService | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-022 | SavingsAgent | services/savings/savings_agent.py | SavingsAgent | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-023 | SavingsAccrualEngine | services/savings/accrual_engine.py | AccrualEngine | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-024 | SavingsMaturityHandler | services/savings/maturity_handler.py | MaturityHandler | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-025 | SavingsRateManager | services/savings/rate_manager.py | RateManager | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-026 | InsuranceAgent | services/insurance/insurance_agent.py | InsuranceAgent | Head of Customer Ops/COO | SMF24 | decision `[pending human ratification]` | - | proposed |
| AG-F1-027 | InsurancePolicyManager | services/insurance/policy_manager.py | PolicyManager | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-028 | InsuranceClaimsProcessor | services/insurance/claims_processor.py | ClaimsProcessor | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-029 | InsurancePremiumCalculator | services/insurance/premium_calculator.py | PremiumCalculator | Head of Customer Ops/COO | SMF24 | decision `[pending human ratification]` — Annex III if life/health `[counsel]` | - | proposed |
| AG-F1-030 | ChurnPredictionAgent | services/agents/churn_prediction_agent.py | ChurnPredictionAgent | - | - | tooling `[pending human ratification]` — possible F3-finbi | - | proposed |
| AG-F1-031 | DocumentStore | services/document_management/document_store.py | DocumentStore | - | - | tooling | `[gdpr-consent]` | active |
| AG-F1-034 | LendingAgent | services/lending/lending_agent.py | LendingAgent | Head of Customer Ops/COO | SMF24 | decision `[pending human ratification]` — F1-customer-ops vs F3-risk (credit) | - | proposed |

---
**This does not replace legal advice.**
