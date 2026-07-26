# AGENT REGISTRY — Floor 1 (Front Office / People) — 2026-07-21

**GOVERNANCE / AGENT REGISTRY F1 (ACTION-3, final floor) / DOCS-ONLY / READ-ONLY RUNTIME**
Populated per `AGENT-REGISTRY-TEMPLATE.md`, classified per `AGENT-CLASSIFICATION-CRITERION-2026-07-21.md`, same 12-column schema as F4/F3/F2. F1 only (support/marketing/customer-ops/hr-legal). `human_double`/`SMF` from `../ORG-STRUCTURE.md`: Head of Support/COO (support), Head of Marketing/COO (marketing), Head of Customer Ops/COO (customer-ops), HR-lead + Legal Counsel + Compliance Admin with CEO(SMF1) gate on SMF-hires (hr-legal).

**F1 flags (conduct/data, not licensing carve-out):** `[cobs4]` financial promotion; `[gdpr-consent]` data/consent; SM&CR CEO-gate on SMF-hires. Read-only over `~/banxe-emi-stack`.

## Registry rows (F1)

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F1-001 | CustomerSupportAgent | services/support/customer_support_agent.py | CustomerSupportAgent | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - | active |
| AG-F1-002 | ComplaintTriageAgent | services/support/complaint_triage_agent.py | ComplaintTriageAgent | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - (FOS relevance) | active |
| AG-F1-003 | EscalationAgent | services/support/escalation_agent.py | EscalationAgent | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - | active |
| AG-F1-004 | FeedbackAnalyticsAgent | services/support/feedback_analytics_agent.py | FeedbackAnalyticsAgent | F1-support | Support | F1 | - | - | tooling | - | active |
| AG-F1-005 | TicketRoutingAgent | services/support/ticket_routing_agent.py | TicketRoutingAgent | F1-support | Support | F1 | - | - | tooling | - | active |
| AG-F1-006 | ComplaintsAgent | services/complaints/complaints_agent.py | ComplaintsAgent | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - (FOS) | active |
| AG-F1-007 | ComplaintsEngine | services/complaints/complaints_engine.py | ComplaintsEngine | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - (FOS) | active |
| AG-F1-008 | FosEscalation | services/complaints/fos_escalation.py | FosEscalation | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - (FOS) | active |
| AG-F1-009 | CampaignAgent | services/agents/campaign_agent.py | CampaignAgent | F1-marketing | Marketing | F1 | Head of Marketing/COO | SMF24 | decision | `[cobs4]` | active |
| AG-F1-010 | CrmAgent | services/agents/crm_agent.py | CrmAgent | F1-marketing | Marketing | F1 | Head of Marketing/COO | SMF24 | decision | `[cobs4]` | active |
| AG-F1-011 | ReferralAgent | services/referral/referral_agent.py | ReferralAgent | F1-marketing | Marketing | F1 | Head of Marketing/COO | SMF24 | decision | `[cobs4]` | active |
| AG-F1-012 | LoyaltyAgent | services/loyalty/loyalty_agent.py | LoyaltyAgent | F1-marketing | Marketing | F1 | Head of Marketing/COO | SMF24 | decision | `[cobs4]` | active |
| AG-F1-013 | LeadScoringAgent | services/agents/lead_scoring_agent.py | LeadScoringAgent | F1-marketing | Marketing | F1 | - | - | tooling | `[cobs4]` | active |
| AG-F1-014 | NpsAgent | services/agents/nps_agent.py | NpsAgent | F1-marketing | Marketing | F1 | - | - | tooling | - | active |
| AG-F1-015 | NotificationAgent | services/agents/notification_agent.py | NotificationAgent | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | `[gdpr-consent]` | active |
| AG-F1-016 | NotificationHubAgent | services/notification_hub/notification_agent.py | NotificationAgent | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | `[gdpr-consent]` | active |
| AG-F1-017 | PreferencesAgent | services/user_preferences/preferences_agent.py | PreferencesAgent | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | `[gdpr-consent]` | active |
| AG-F1-018 | DocumentAgent | services/document_management/document_agent.py | DocumentAgent | F1-customer-ops | Customer-Ops | F1 | - | - | tooling | `[gdpr-consent]` | active |
| AG-F1-019 | RetentionEngine | services/document_management/retention_engine.py | RetentionEngine | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | `[gdpr-consent]` | active |
| AG-F1-020 | NotificationService | services/notifications/notification_service.py | NotificationService | F1-customer-ops | Customer-Ops | F1 | - | - | tooling | `[gdpr-consent]` | active |
| AG-F1-021 | CustomerService | services/customer/customer_service.py | CustomerService | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-022 | SavingsAgent | services/savings/savings_agent.py | SavingsAgent | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-023 | SavingsAccrualEngine | services/savings/accrual_engine.py | AccrualEngine | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-024 | SavingsMaturityHandler | services/savings/maturity_handler.py | MaturityHandler | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-025 | SavingsRateManager | services/savings/rate_manager.py | RateManager | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-026 | InsuranceAgent | services/insurance/insurance_agent.py | InsuranceAgent | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision `[pending human ratification]` | - | proposed |
| AG-F1-027 | InsurancePolicyManager | services/insurance/policy_manager.py | PolicyManager | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-028 | InsuranceClaimsProcessor | services/insurance/claims_processor.py | ClaimsProcessor | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision | - | active |
| AG-F1-029 | InsurancePremiumCalculator | services/insurance/premium_calculator.py | PremiumCalculator | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision `[pending human ratification]` — Annex III if life/health `[counsel]` | - | proposed |
| AG-F1-030 | ChurnPredictionAgent | services/agents/churn_prediction_agent.py | ChurnPredictionAgent | F1-customer-ops | Customer-Ops | F1 | - | - | tooling `[pending human ratification]` — possible F3-finbi | - | proposed |
| AG-F1-031 | DocumentStore | services/document_management/document_store.py | DocumentStore | F1-customer-ops | Customer-Ops | F1 | - | - | tooling | `[gdpr-consent]` | active |
| AG-F1-032 | HrAgent | services/agents/hr_agent.py | HrAgent | F1-hr-legal | HR-Legal | F1 | HR-lead + Legal Counsel | - | decision | CEO gate on SMF-hires (SMF1) | active |
| AG-F1-033 | ContractAgent | services/agents/contract_agent.py | ContractAgent | F1-hr-legal | HR-Legal | F1 | Legal Counsel + Compliance Admin | - | tooling (MASK-ONLY) | - | active |

## Verdict note

- **F1 rows:** 33 (19 from `*_agent.py`; 14 from the functional shortlist).
- **decision:** 24 (all with a human_double; hr-legal uses HR-lead/Legal Counsel roles, CEO/SMF1 gate on SMF-hires).
- **tooling:** 9 (AG-F1-004, 005, 013, 014, 018, 020, 030, 031, 033).
- **[pending human ratification]:** 3 (AG-F1-026 insurance-agent, AG-F1-029 premium-calculator [Annex III?], AG-F1-030 churn-prediction [possible F3-finbi]).
- **`[cobs4]` flagged:** 5 (AG-F1-009, 010, 011, 012, 013) — financial-promotion conduct.
- **`[gdpr-consent]` flagged:** 6 (AG-F1-015, 016, 017, 018, 019, 020, 031) — data/consent.
- **SM&CR CEO-gate:** 1 (AG-F1-032 hr-agent, SMF-hires).

**Cross-floor honesty (excluded from F1):**
- `services/consumer_duty/consumer_duty_agent.py` (+ subservices) → **F3-risk** (per CONFIRMED-3: consumer_duty_agent in F3-risk).
- BI/finance agents (`bi_agent`, `forecast_agent`, `fpa_agent`, `data_quality_agent`) → **F3-finbi**; `credit_scoring_agent` → **F3-risk** (Annex III credit scoring).
- `AG-F1-029` premium_calculator and `AG-F1-030` churn flagged pending precisely because they may belong to F3 (Annex III insurance pricing / FinBI) — not silently absorbed.

Open: `[factory]` confirm counting canon vs files(86)/classes(77); `[audit]` ratify the 3 pending rows and confirm customer-ops membership; conduct flags `[cobs4]`/`[gdpr-consent]` are pointers, not legal determinations. All legal → `[counsel]`.

---
**This does not replace legal advice.**

## Reconciliation append — 2026-07-22 (coverage closure: UNPLACED placement)

Append-only; existing rows above unchanged. Rows added per REGISTRY-COVERAGE-CLOSURE-2026-07-21.md.

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F1-034 | LendingAgent | services/lending/lending_agent.py | LendingAgent | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision `[pending human ratification]` — F1-customer-ops vs F3-risk (credit) | - | proposed |
