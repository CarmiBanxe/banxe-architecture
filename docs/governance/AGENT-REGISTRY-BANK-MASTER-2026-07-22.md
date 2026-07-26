# AGENT REGISTRY — BANK MASTER (bank employees only) — 2026-07-22

**GOVERNANCE / BANK AGENT REGISTRY / SOURCE OF TRUTH FOR BANK HEADCOUNT / DOCS-ONLY / READ-ONLY RUNTIME**
BANK-owned agents only = AGENT-REGISTRY-MASTER-2026-07-22.md **minus ENGINE-MANUS (12) minus REPAIR-BRIGADE (6)**. Company split per ownership-by-declaration R2 (see AGENT-OWNERSHIP-SPLIT-2026-07-22.md). Rows collected verbatim; agent_id preserved. Read-only over ~/banxe-emi-stack.

**True bank agent count = 129.**

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
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
| AG-F1-034 | LendingAgent | services/lending/lending_agent.py | LendingAgent | F1-customer-ops | Customer-Ops | F1 | Head of Customer Ops/COO | SMF24 | decision `[pending human ratification]` — F1-customer-ops vs F3-risk (credit) | - | proposed |
| AG-F1-032 | HrAgent | services/agents/hr_agent.py | HrAgent | F1-hr-legal | HR-Legal | F1 | HR-lead + Legal Counsel | - | decision | CEO gate on SMF-hires (SMF1) | active |
| AG-F1-033 | ContractAgent | services/agents/contract_agent.py | ContractAgent | F1-hr-legal | HR-Legal | F1 | Legal Counsel + Compliance Admin | - | tooling (MASK-ONLY) | - | active |
| AG-F1-009 | CampaignAgent | services/agents/campaign_agent.py | CampaignAgent | F1-marketing | Marketing | F1 | Head of Marketing/COO | SMF24 | decision | `[cobs4]` | active |
| AG-F1-010 | CrmAgent | services/agents/crm_agent.py | CrmAgent | F1-marketing | Marketing | F1 | Head of Marketing/COO | SMF24 | decision | `[cobs4]` | active |
| AG-F1-011 | ReferralAgent | services/referral/referral_agent.py | ReferralAgent | F1-marketing | Marketing | F1 | Head of Marketing/COO | SMF24 | decision | `[cobs4]` | active |
| AG-F1-012 | LoyaltyAgent | services/loyalty/loyalty_agent.py | LoyaltyAgent | F1-marketing | Marketing | F1 | Head of Marketing/COO | SMF24 | decision | `[cobs4]` | active |
| AG-F1-013 | LeadScoringAgent | services/agents/lead_scoring_agent.py | LeadScoringAgent | F1-marketing | Marketing | F1 | - | - | tooling | `[cobs4]` | active |
| AG-F1-014 | NpsAgent | services/agents/nps_agent.py | NpsAgent | F1-marketing | Marketing | F1 | - | - | tooling | - | active |
| AG-F1-001 | CustomerSupportAgent | services/support/customer_support_agent.py | CustomerSupportAgent | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - | active |
| AG-F1-002 | ComplaintTriageAgent | services/support/complaint_triage_agent.py | ComplaintTriageAgent | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - (FOS relevance) | active |
| AG-F1-003 | EscalationAgent | services/support/escalation_agent.py | EscalationAgent | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - | active |
| AG-F1-004 | FeedbackAnalyticsAgent | services/support/feedback_analytics_agent.py | FeedbackAnalyticsAgent | F1-support | Support | F1 | - | - | tooling | - | active |
| AG-F1-005 | TicketRoutingAgent | services/support/ticket_routing_agent.py | TicketRoutingAgent | F1-support | Support | F1 | - | - | tooling | - | active |
| AG-F1-006 | ComplaintsAgent | services/complaints/complaints_agent.py | ComplaintsAgent | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - (FOS) | active |
| AG-F1-007 | ComplaintsEngine | services/complaints/complaints_engine.py | ComplaintsEngine | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - (FOS) | active |
| AG-F1-008 | FosEscalation | services/complaints/fos_escalation.py | FosEscalation | F1-support | Support | F1 | Head of Support/COO | SMF24 | decision | - (FOS) | active |
| AG-F2-001 | KycOnboardingAgent | services/agents/kyc_onboarding_agent.py | KycOnboardingAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision | HITL-006 | active |
| AG-F2-002 | KybAgent | services/kyb_onboarding/kyb_agent.py | KybAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision [gated-counsel] — KYB↔acquiring | HITL-002/007 | [gated-counsel] |
| AG-F2-003 | ConsentAgent | services/consent_management/consent_agent.py | ConsentAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision | - (register #5 consent/DPO) | active |
| AG-F2-004 | LifecycleAgent | services/customer_lifecycle/lifecycle_agent.py | LifecycleAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision | - | active |
| AG-F2-045 | FatcaAgent | services/fatca_crs/fatca_agent.py | FatcaAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision `[pending human ratification]` — room F2-identity vs F3-aml/regrep | - | proposed |
| AG-F2-046 | ComplianceAutomationAgent | services/compliance_automation/compliance_automation_agent.py | ComplianceAutomationAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision `[pending human ratification]` — room/type contested | - | proposed |
| AG-F2-047 | ComplianceSyncAgent | services/compliance_sync/compliance_agent.py | ComplianceAgent | F2-identity | Identity | F2 | - | - | tooling `[pending human ratification]` — sync utility, room contested | - | proposed |
| AG-F2-048 | ComplianceCalendarAgent | services/compliance_calendar/calendar_agent.py | CalendarAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision `[pending human ratification]` — room F2-identity vs F3-regrep | - | proposed |
| AG-F2-005 | MidazMcpAgent | services/midaz_mcp/midaz_agent.py | MidazAgent | F2-ledger | Ledger | F2 | CFO | SMF2 | decision [gated-counsel] — Midaz/MCP→ledger | - (external review) | [gated-counsel] |
| AG-F2-006 | MidazClient | services/midaz_mcp/midaz_client.py | MidazClient | F2-ledger | Ledger | F2 | CFO | SMF2 | decision [gated-counsel] — Midaz/MCP→ledger | - | [gated-counsel] |
| AG-F2-007 | GLService | services/ledger/gl_service.py | GLService | F2-ledger | Ledger | F2 | CFO | SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-008 | PaymentPostingService | services/ledger/payment_posting_service.py | PaymentPostingService | F2-ledger | Ledger | F2 | CFO | SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-009 | PostingRuleEngine | services/ledger/posting_rules.py | PostingRuleEngine | F2-ledger | Ledger | F2 | CFO | SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-010 | MidazAdapter | services/ledger/midaz_adapter.py | MidazAdapter | F2-ledger | Ledger | F2 | CFO | SMF2 | decision [gated-counsel] — Midaz/MCP→ledger | - | [gated-counsel] |
| AG-F2-011 | CryptoApplicationService | services/ledger/crypto_application_service.py | CryptoApplicationService | F2-ledger | Ledger | F2 | CFO | SMF2 | decision [gated-counsel] — crypto/CASP | - | [gated-counsel] |
| AG-F2-012 | CryptoLedgerPort | services/ledger/crypto_ledger_port.py | CryptoLedgerPort | F2-ledger | Ledger | F2 | - | - | tooling [gated-counsel] — crypto/CASP | - | [gated-counsel] |
| AG-F2-013 | ApprovalModels | services/ledger/approval_models.py | (models) | F2-ledger | Ledger | F2 | - | - | tooling | - | active |
| AG-F2-014 | PaymentService | services/payment/payment_service.py | PaymentService | F2-payments | Payments | F2 | COO | SMF24 | decision | HITL-016 | active |
| AG-F2-015 | PaymentProcessingService | services/payment/payment_processing_service.py | PaymentProcessingService | F2-payments | Payments | F2 | COO | SMF24 | decision | - | active |
| AG-F2-016 | PaymentAuthGuard | services/payment/payment_auth_guard.py | PaymentAuthGuard | F2-payments | Payments | F2 | COO | SMF24 | decision | - | active |
| AG-F2-017 | BatchPaymentsAgent | services/batch_payments/batch_agent.py | BatchAgent | F2-payments | Payments | F2 | COO | SMF24 | decision | HITL-016 | active |
| AG-F2-018 | ScheduledPaymentsAgent | services/scheduled_payments/scheduled_payments_agent.py | ScheduledPaymentsAgent | F2-payments | Payments | F2 | COO | SMF24 | decision | - | active |
| AG-F2-019 | StatementAgent | services/agents/statement_agent.py | StatementAgent | F2-payments | Payments | F2 | COO | SMF24 | decision | - | active |
| AG-F2-020 | ClientStatementAgent | services/client_statements/statement_agent.py | StatementAgent | F2-payments | Payments | F2 | COO | SMF24 | decision | - | active |
| AG-F2-021 | CardsAgent | services/agents/cards_agent.py | CardsAgent | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — cards (register #2 RED) | - | [gated-counsel] |
| AG-F2-022 | CardIssuingAgent | services/card_issuing/card_agent.py | CardAgent | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — cards (register #2 RED) | - | [gated-counsel] |
| AG-F2-023 | CryptoAgent | services/crypto_custody/crypto_agent.py | CryptoAgent | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — crypto/CASP | - | [gated-counsel] |
| AG-F2-024 | OpenBankingAgent | services/open_banking/open_banking_agent.py | OpenBankingAgent | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — AISP/PISP [needs-function-clarification] | - | [gated-counsel] |
| AG-F2-025 | MerchantAgent | services/merchant_acquiring/merchant_agent.py | MerchantAgent | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — KYB↔acquiring | - | [gated-counsel] |
| AG-F2-026 | SettlementEngine | services/merchant_acquiring/settlement_engine.py | SettlementEngine | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — KYB↔acquiring | - | [gated-counsel] |
| AG-F2-027 | AcquiringPaymentGateway | services/merchant_acquiring/payment_gateway.py | PaymentGateway | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — KYB↔acquiring | - | [gated-counsel] |
| AG-F2-028 | ChargebackHandler | services/merchant_acquiring/chargeback_handler.py | ChargebackHandler | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — KYB↔acquiring | - | [gated-counsel] |
| AG-F2-029 | MerchantOnboarding | services/merchant_acquiring/merchant_onboarding.py | MerchantOnboarding | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — KYB↔acquiring | - | [gated-counsel] |
| AG-F2-030 | CryptoTransferEngine | services/crypto_custody/transfer_engine.py | TransferEngine | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — crypto/CASP | - | [gated-counsel] |
| AG-F2-031 | TravelRuleEngine | services/crypto_custody/travel_rule_engine.py | TravelRuleEngine | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — crypto/Travel Rule | - | [gated-counsel] |
| AG-F2-032 | WalletManager | services/crypto_custody/wallet_manager.py | WalletManager | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — crypto/custody | - | [gated-counsel] |
| AG-F2-033 | CustodyReconciler | services/crypto_custody/custody_reconciler.py | CustodyReconciler | F2-payments | Payments | F2 | - | - | tooling [gated-counsel] — crypto/custody | - | [gated-counsel] |
| AG-F2-038 | ChargebackAgent | services/agents/chargeback_agent.py | ChargebackAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2) | - | active |
| AG-F2-039 | GatewayAgent | services/api_gateway/gateway_agent.py | GatewayAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2) | - | active |
| AG-F2-040 | Psd2Agent | services/psd2_gateway/psd2_agent.py | Psd2Agent | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — PSD2/open-banking AISP/PISP [needs-function-clarification] | - | [gated-counsel] |
| AG-F2-041 | DisputeAgent | services/dispute_resolution/dispute_agent.py | DisputeAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2) | - | active |
| AG-F2-042 | FeeAgent | services/fee_management/fee_agent.py | FeeAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (HITLProposal) | - | active |
| AG-F2-043 | BeneficiaryAgent | services/beneficiary_management/beneficiary_agent.py | BeneficiaryAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2) | - | active |
| AG-F2-044 | SwiftAgent | services/swift_correspondent/swift_agent.py | SwiftAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (HITLProposal) | - | active |
| AG-F2-034 | ReconAgent | services/recon/recon_agent.py | ReconAgent | F2-safeguarding | Safeguarding | F2 | COO+CFO | SMF24+SMF2 | decision | HITL-011 | active |
| AG-F2-035 | ReconEngine | services/recon/recon_engine.py | ReconEngine | F2-safeguarding | Safeguarding | F2 | COO+CFO | SMF24+SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-036 | ReconciliationEngine | services/recon/reconciliation_engine.py | ReconciliationEngine | F2-safeguarding | Safeguarding | F2 | COO+CFO | SMF24+SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-037 | BreachNotifyPort | services/recon/breach_notify_port.py | BreachNotifyPort | F2-safeguarding | Safeguarding | F2 | COO+CFO | SMF24+SMF2 | decision | HITL-011 | active |
| AG-F3-001 | SanctionsScreeningAgent | services/sanctions_screening/sanctions_agent.py | SanctionsAgent | F3-aml | AML | F3 | MLRO | SMF17 | decision | HITL-003/004 | active |
| AG-F3-003 | FraudTracerAgent | services/fraud_tracer/tracer_agent.py | TracerAgent | F3-aml | AML | F3 | MLRO | SMF17 | decision | - | active |
| AG-F3-004 | TxMonitor | services/aml/tx_monitor.py | TxMonitor | F3-aml | AML | F3 | MLRO | SMF17 | decision | - (TM SLA) | active |
| AG-F3-005 | FraudAmlPipeline | services/fraud/fraud_aml_pipeline.py | FraudAmlPipeline | F3-aml | AML | F3 | MLRO | SMF17 | decision | - | active |
| AG-F3-006 | TMRiskScorer | services/transaction_monitor/scoring/risk_scorer.py | RiskScorer | F3-aml | AML | F3 | MLRO | SMF17 | decision | - | active |
| AG-F3-007 | TMRuleEngine | services/transaction_monitor/scoring/rule_engine.py | RuleEngine | F3-aml | AML | F3 | MLRO | SMF17 | decision | - | active |
| AG-F3-008 | TMAlertGenerator | services/transaction_monitor/alerts/alert_generator.py | AlertGenerator | F3-aml | AML | F3 | MLRO | SMF17 | decision | - | active |
| AG-F3-009 | TMExplanationEngine | services/transaction_monitor/alerts/explanation_engine.py | ExplanationEngine | F3-aml | AML | F3 | - | - | tooling | - | active |
| AG-F3-010 | FraudPort | services/fraud/fraud_port.py | FraudPort | F3-aml | AML | F3 | - | - | tooling | - | active |
| AG-F3-028 | AnalyticsAgent | services/agents/analytics_agent.py | AnalyticsAgent | F3-finbi | FinBI | F3 | CFO | SMF2 | decision | - | active |
| AG-F3-029 | ReportingAnalyticsAgent | services/reporting_analytics/analytics_agent.py | AnalyticsAgent | F3-finbi | FinBI | F3 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-034 | BiAgent | services/agents/bi_agent.py | BiAgent | F3-finbi | FinBI | F3 | - | - | tooling (L1-Auto) | - | active |
| AG-F3-035 | DataQualityAgent | services/agents/data_quality_agent.py | DataQualityAgent | F3-finbi | FinBI | F3 | - | - | tooling (L1-Auto) | - | active |
| AG-F3-036 | ForecastAgent | services/agents/forecast_agent.py | ForecastAgent | F3-finbi | FinBI | F3 | - | - | tooling (MASK) | - | active |
| AG-F3-037 | FpaAgent | services/agents/fpa_agent.py | FpaAgent | F3-finbi | FinBI | F3 | - | - | tooling (L1-Auto) | - | active |
| AG-F3-030 | RegulatoryReportingAgent | services/regulatory_reporting/regulatory_reporting_agent.py | RegulatoryReportingAgent | F3-regrep | RegRep | F3 | CFO | SMF2 | decision | HITL-010 | active |
| AG-F3-031 | ReportingAgent | services/reporting/reporting_agent.py | ReportingAgent | F3-regrep | RegRep | F3 | CFO | SMF2 | decision | HITL-010 (I-24 append-only) | active |
| AG-F3-032 | FIN060GeneratorV2 | services/reporting/fin060_generator_v2.py | FIN060Generator | F3-regrep | RegRep | F3 | CFO | SMF2 | decision | HITL-010 (I-24 append-only) | active |
| AG-F3-033 | RegDataReturn | services/reporting/regdata_return.py | RegDataReturn | F3-regrep | RegRep | F3 | CFO | SMF2 | decision | HITL-010 | active |
| AG-F3-011 | RiskAgent | services/risk_management/risk_agent.py | RiskAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision | - | active |
| AG-F3-012 | RiskOversightAgent | services/agents/risk_oversight_agent.py | RiskOversightAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision `[pending human ratification]` | - | proposed |
| AG-F3-017 | RiskMetricsPort | services/risk/risk_metrics_port.py | RiskMetricsPort | F3-risk | Risk | F3 | - | - | tooling (MASK/port) | - | active |
| AG-F3-038 | CreditScoringAgent | services/agents/credit_scoring_agent.py | CreditScoringAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision [gated-counsel] — Annex III credit scoring | - | [gated-counsel] |
| AG-F3-039 | AtoAgent | services/ato_prevention/ato_agent.py | AtoAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision (HITLProposal) | - | active |
| AG-F3-040 | ConsumerDutyAgent | services/consumer_duty/consumer_duty_agent.py | ConsumerDutyAgent | F3-risk | Risk | F3 | CRO | SMF4 | decision `[pending human ratification]` — Consumer Duty PS22/9; board SMF champion = ACTION-5 | - | proposed |
| AG-F3-018 | TreasuryAgent | services/treasury/treasury_agent.py | TreasuryAgent | F3-treasury | Treasury | F3 | CFO | SMF2 | decision | HITL-016 | active |
| AG-F3-019 | TreasuryAgentAlt | services/agents/treasury_agent.py | TreasuryAgent | F3-treasury | Treasury | F3 | - | - | tooling (MASK-ONLY) | - | active |
| AG-F3-020 | FxRateAgent | services/fx_rates/fx_rate_agent.py | FxRateAgent | F3-treasury | Treasury | F3 | CFO | SMF2 | decision | - | active |
| AG-F3-022 | FxExchangeAgent | services/fx_exchange/fx_agent.py | FxAgent | F3-treasury | Treasury | F3 | CFO | SMF2 | decision `[pending human ratification]` | - | proposed |
| AG-F3-023 | MultiCurrencyAgent | services/multi_currency/multicurrency_agent.py | MultiCurrencyAgent | F3-treasury | Treasury | F3 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-024 | SweepEngine | services/treasury/sweep_engine.py | SweepEngine | F3-treasury | Treasury | F3 | CFO | SMF2 | decision | - | active |
| AG-F3-025 | LiquidityMonitor | services/treasury/liquidity_monitor.py | LiquidityMonitor | F3-treasury | Treasury | F3 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-026 | FxExposurePort | services/treasury/fx_exposure_port.py | FxExposurePort | F3-treasury | Treasury | F3 | - | - | tooling (port) | - | active |
| AG-F3-027 | BalanceEngine | services/multi_currency/balance_engine.py | BalanceEngine | F3-treasury | Treasury | F3 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F4-020 | MlPipelineAgent | services/agents/ml_pipeline_agent.py | MlPipelineAgent | F4-ai-platform | AI Platform | F4 | CTO | SMF26 | decision (L3) | HITL-014 | active |
| AG-F4-004 | AuditAgent | services/audit_trail/audit_agent.py | AuditAgent | F4-audit-cell | Audit | F4 | Internal Audit | SMF5 | decision | - (I-24 append-only) | active |
| AG-F4-013 | AuditQueryService | services/audit/audit_query.py | AuditQueryService | F4-audit-cell | Audit | F4 | Internal Audit | SMF5 | decision | - (I-24 append-only) | active |
| AG-F4-014 | RetentionEnforcer | services/audit_trail/retention_enforcer.py | RetentionEnforcer | F4-audit-cell | Audit | F4 | Internal Audit | SMF5 | decision | - (I-24 append-only) | active |
| AG-F4-015 | ComplianceMonitor | services/observability/compliance_monitor.py | ComplianceReport/Port | F4-audit-cell | Audit | F4 | Internal Audit | SMF5 | decision | - | active |
| AG-F4-016 | RiskScorer | services/audit_dashboard/risk_scorer.py | RiskScorer | F4-audit-cell | Audit | F4 | Internal Audit | SMF5 | decision `[pending human ratification]` | - | proposed |
| AG-F4-017 | GovernanceReporter | services/audit_dashboard/governance_reporter.py | GovernanceReporter | F4-audit-cell | Audit | F4 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F4-018 | AuditAggregator | services/audit_dashboard/audit_aggregator.py | AuditAggregator | F4-audit-cell | Audit | F4 | - | - | tooling | - | active |
| AG-F4-001 | DeployAgent | services/agents/deploy_agent.py | DeployAgent | F4-devops | DevOps | F4 | CTO | SMF26 | decision | HITL-013 | active |
| AG-F4-005 | ObservabilityAgent | services/observability/observability_agent.py | ObservabilityAgent | F4-devops | DevOps | F4 | CTO | SMF26 | tooling `[pending human ratification]` | - | proposed |
| AG-F4-019 | HealthAggregator | services/observability/health_aggregator.py | HealthAggregator | F4-devops | DevOps | F4 | - | - | tooling | - | active |
| AG-F4-002 | IncidentResponseAgent | services/agents/incident_response_agent.py | IncidentResponseAgent | F4-security | Security | F4 | CTO | SMF26 | decision | HITL-015 | active |
| AG-F4-021 | FingerprintAgent | services/device_fingerprint/fingerprint_agent.py | FingerprintAgent | F4-security | Security | F4 | CTO | SMF26 | decision (HITLProposal) | - | active |

## Counters (BANK only)

- **True bank agent count = 129** (was 147 in the combined MASTER; −12 ENGINE-MANUS, −6 REPAIR-BRIGADE).
- **Per-floor:** F1 = 34 · F2 = 48 · F3 = 34 · F4 = 13.
- **Per-room:** F1-support 8 · F1-marketing 6 · F1-customer-ops 18 · F1-hr-legal 2 · F2-identity 8 · F2-ledger 9 · F2-payments 27 · F2-safeguarding 4 · F3-aml 9 · F3-risk 6 · F3-treasury 9 · F3-finbi 6 · F3-regrep 4 · F4-ai-platform 1 · F4-devops 3 · F4-security 2 · F4-audit-cell 7.
- **Note:** flags `[gated-counsel]` / `[pending human ratification]` carried verbatim from MASTER; not resolved here.

## Verdict

- BANK-MASTER is the corrected source of truth for **bank** agents (129). The combined 147-row MASTER is superseded for bank-headcount purposes.
- Removed to their owning companies: ENGINE-MANUS (12, see COMPANY-REGISTRY-ENGINE-MANUS), REPAIR-BRIGADE (6 watchdog, see COMPANY-REGISTRY-REPAIR-BRIGADE).
- FACTORY: no declarations in this repo → empty skeleton `[pending: confirm external repo]`.
- Contested ownership (fx_engine, design_pipeline ×4) parked in ENGINE-MANUS with `[pending human ratification]`; if `[audit]` rules them BANK, they return here (bank count would rise to ≤134).
- All legal → `[counsel]`.

---
**This does not replace legal advice.**

## S-B0 addition — 2026-07-23 (3 new ADR-049 client-facing masks; bank count 129 → 132)

Append-only; existing rows unchanged. Found by the S-B0 spot-check of `banxe-payment-core/src/agents/` — genuinely new ADR-049 §D3 client-facing L2 masks (Payments, FX/Exchange, Wallet), completing the 6-mask series (KYC-onboarding, Notifications, Referral/CRM already present as AG-F2-001, AG-F1-015, AG-F1-010). New path `src/agents/` (not `services/`); dup-check: no emi-stack `services/agents` payments/wallet/fx client-mask exists → not a mirror. See `../audit/SB0-NEW-BANK-AGENTS-2026-07-23.md`.

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F2-049 | PaymentsMaskAgent | banxe-payment-core/src/agents/payments_agent.py | PaymentsAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2 client-facing mask, ADR-049) | HITL step-up (ADR-049 §D4) | active |
| AG-F2-050 | FxExchangeMaskAgent | banxe-payment-core/src/agents/fx_exchange_agent.py | FxExchangeAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2 client-facing mask, ADR-049) `[pending human ratification]` room F2-payments vs F3-treasury | HITL threshold (ADR-049 §D4) | active |
| AG-F2-051 | WalletMaskAgent | banxe-payment-core/src/agents/wallet_agent.py | WalletAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2 client-facing mask, ADR-049; Mixed autonomy §D3) | HITL step-up on mutations (ADR-049 §D4) | active |

**Updated bank count: 132** (129 + 3). `[verify not-duplicate of emi-stack payments]` — checked: no dup under `services/agents` client-mask pattern; distinct from `services/payment/*` (AG-F2-014 etc.).
