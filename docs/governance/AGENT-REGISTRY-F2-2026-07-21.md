# AGENT REGISTRY — Floor 2 (Core Banking) — 2026-07-21

**GOVERNANCE / AGENT REGISTRY F2 (ACTION-3) / DOCS-ONLY / READ-ONLY RUNTIME**
Populated per `AGENT-REGISTRY-TEMPLATE.md`, classified per `AGENT-CLASSIFICATION-CRITERION-2026-07-21.md`, same 12-column schema as F4/F3. F2 only (identity/ledger/payments/safeguarding). `human_double`/`SMF` from `../ORG-STRUCTURE.md`: Compliance-Officer/MLRO (identity), CFO/SMF2 (ledger), COO/SMF24 (payments), COO+CFO (safeguarding).

**Carve-out rule:** crypto/CASP, open-banking AISP/PISP, KYB↔merchant-acquiring, Midaz/MCP→ledger (and cards, register #2 RED) are marked `decision [gated-counsel]` / status `[gated-counsel]` — **not** ordinary decision-agents, consistent with the OPEN-REGULATORY-QUESTIONS addendum + CONSULTANT-RESPONSE brief. Not closed here; no legal conclusion. Read-only over `~/banxe-emi-stack`.

## Registry rows (F2)

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F2-001 | KycOnboardingAgent | services/agents/kyc_onboarding_agent.py | KycOnboardingAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision | HITL-006 | active |
| AG-F2-002 | KybAgent | services/kyb_onboarding/kyb_agent.py | KybAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision [gated-counsel] — KYB↔acquiring | HITL-002/007 | [gated-counsel] |
| AG-F2-003 | ConsentAgent | services/consent_management/consent_agent.py | ConsentAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision | - (register #5 consent/DPO) | active |
| AG-F2-004 | LifecycleAgent | services/customer_lifecycle/lifecycle_agent.py | LifecycleAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision | - | active |
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
| AG-F2-034 | ReconAgent | services/recon/recon_agent.py | ReconAgent | F2-safeguarding | Safeguarding | F2 | COO+CFO | SMF24+SMF2 | decision | HITL-011 | active |
| AG-F2-035 | ReconEngine | services/recon/recon_engine.py | ReconEngine | F2-safeguarding | Safeguarding | F2 | COO+CFO | SMF24+SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-036 | ReconciliationEngine | services/recon/reconciliation_engine.py | ReconciliationEngine | F2-safeguarding | Safeguarding | F2 | COO+CFO | SMF24+SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-037 | BreachNotifyPort | services/recon/breach_notify_port.py | BreachNotifyPort | F2-safeguarding | Safeguarding | F2 | COO+CFO | SMF24+SMF2 | decision | HITL-011 | active |

## Verdict note

- **F2 rows:** 37 (15 from `*_agent.py`; 22 from the functional shortlist).
- **decision (ordinary):** 15 — AG-F2-001, 003, 004, 007, 008, 009, 014, 015, 016, 017, 018, 019, 020, 034, 035, 036, 037 (all with human_double+SMF; safeguarding = COO+CFO double).
- **tooling:** 2 — AG-F2-013 (approval models), AG-F2-033 (custody reconciler, also gated).
- **decision [gated-counsel] / status [gated-counsel]:** 19 — the carve-out surfaces.
- **[pending human ratification]:** 0 in this floor (signals were unambiguous; ambiguity here is regulatory → gated-counsel, not lineage-pending).

**Gated-counsel entities and why (not closed here, no legal conclusion):**
- **Crypto / CASP (MiCA):** AG-F2-011, 012, 023, 030, 031, 032, 033 — custody/ledger/transfer/Travel-Rule; CASP ownership unresolved (register #3).
- **Open-banking AISP/PISP:** AG-F2-024 — licence depends on AISP (read) vs PISP (initiation); `[needs-function-clarification]`.
- **KYB ↔ merchant-acquiring:** AG-F2-002, 025, 026, 027, 028, 029 — KYB gates acquiring activation; joint perimeter unresolved (register #4).
- **Midaz / MCP → ledger:** AG-F2-005, 006, 010 — direct-write path is an architecture-control question for external review, **not asserted as fact** (register #6).
- **Cards:** AG-F2-021, 022 — register #2 CARDS RED (functional scope undefined; BIN sponsor).

**Cross-floor honesty (excluded from F2):**
- `services/design_pipeline/agents/onboarding_agent.py` → F4-ai-platform (UI design pipeline, not identity onboarding).
- `services/support/customer_support_agent.py` → F1-support.

Open: `[factory]` confirm counting canon vs files(86)/classes(77); `[audit]` review room placement; **`[counsel]` all gated-counsel entities remain open** — this registry records placement only, not legal ownership or classification.

---
**This does not replace legal advice.**

## Reconciliation append — 2026-07-22 (coverage closure: UNPLACED placement)

Append-only; existing rows above unchanged. Rows added per REGISTRY-COVERAGE-CLOSURE-2026-07-21.md.

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F2-038 | ChargebackAgent | services/agents/chargeback_agent.py | ChargebackAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2) | - | active |
| AG-F2-039 | GatewayAgent | services/api_gateway/gateway_agent.py | GatewayAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2) | - | active |
| AG-F2-040 | Psd2Agent | services/psd2_gateway/psd2_agent.py | Psd2Agent | F2-payments | Payments | F2 | COO | SMF24 | decision [gated-counsel] — PSD2/open-banking AISP/PISP [needs-function-clarification] | - | [gated-counsel] |
| AG-F2-041 | DisputeAgent | services/dispute_resolution/dispute_agent.py | DisputeAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2) | - | active |
| AG-F2-042 | FeeAgent | services/fee_management/fee_agent.py | FeeAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (HITLProposal) | - | active |
| AG-F2-043 | BeneficiaryAgent | services/beneficiary_management/beneficiary_agent.py | BeneficiaryAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (L2) | - | active |
| AG-F2-044 | SwiftAgent | services/swift_correspondent/swift_agent.py | SwiftAgent | F2-payments | Payments | F2 | COO | SMF24 | decision (HITLProposal) | - | active |
| AG-F2-045 | FatcaAgent | services/fatca_crs/fatca_agent.py | FatcaAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision `[pending human ratification]` — room F2-identity vs F3-aml/regrep | - | proposed |
| AG-F2-046 | ComplianceAutomationAgent | services/compliance_automation/compliance_automation_agent.py | ComplianceAutomationAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision `[pending human ratification]` — room/type contested | - | proposed |
| AG-F2-047 | ComplianceSyncAgent | services/compliance_sync/compliance_agent.py | ComplianceAgent | F2-identity | Identity | F2 | - | - | tooling `[pending human ratification]` — sync utility, room contested | - | proposed |
| AG-F2-048 | ComplianceCalendarAgent | services/compliance_calendar/calendar_agent.py | CalendarAgent | F2-identity | Identity | F2 | Compliance-Officer/MLRO | SMF17 | decision `[pending human ratification]` — room F2-identity vs F3-regrep | - | proposed |
