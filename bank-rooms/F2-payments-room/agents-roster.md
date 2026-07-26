# F2-payments-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 27 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F2-014 | PaymentService | services/payment/payment_service.py | PaymentService | COO | SMF24 | decision | HITL-016 | active |
| AG-F2-015 | PaymentProcessingService | services/payment/payment_processing_service.py | PaymentProcessingService | COO | SMF24 | decision | - | active |
| AG-F2-016 | PaymentAuthGuard | services/payment/payment_auth_guard.py | PaymentAuthGuard | COO | SMF24 | decision | - | active |
| AG-F2-017 | BatchPaymentsAgent | services/batch_payments/batch_agent.py | BatchAgent | COO | SMF24 | decision | HITL-016 | active |
| AG-F2-018 | ScheduledPaymentsAgent | services/scheduled_payments/scheduled_payments_agent.py | ScheduledPaymentsAgent | COO | SMF24 | decision | - | active |
| AG-F2-019 | StatementAgent | services/agents/statement_agent.py | StatementAgent | COO | SMF24 | decision | - | active |
| AG-F2-020 | ClientStatementAgent | services/client_statements/statement_agent.py | StatementAgent | COO | SMF24 | decision | - | active |
| AG-F2-021 | CardsAgent | services/agents/cards_agent.py | CardsAgent | COO | SMF24 | decision [gated-counsel] — cards (register #2 RED) | - | [gated-counsel] |
| AG-F2-022 | CardIssuingAgent | services/card_issuing/card_agent.py | CardAgent | COO | SMF24 | decision [gated-counsel] — cards (register #2 RED) | - | [gated-counsel] |
| AG-F2-023 | CryptoAgent | services/crypto_custody/crypto_agent.py | CryptoAgent | COO | SMF24 | decision [gated-counsel] — crypto/CASP | - | [gated-counsel] |
| AG-F2-024 | OpenBankingAgent | services/open_banking/open_banking_agent.py | OpenBankingAgent | COO | SMF24 | decision [gated-counsel] — AISP/PISP [needs-function-clarification] | - | [gated-counsel] |
| AG-F2-025 | MerchantAgent | services/merchant_acquiring/merchant_agent.py | MerchantAgent | COO | SMF24 | decision [gated-counsel] — KYB↔acquiring | - | [gated-counsel] |
| AG-F2-026 | SettlementEngine | services/merchant_acquiring/settlement_engine.py | SettlementEngine | COO | SMF24 | decision [gated-counsel] — KYB↔acquiring | - | [gated-counsel] |
| AG-F2-027 | AcquiringPaymentGateway | services/merchant_acquiring/payment_gateway.py | PaymentGateway | COO | SMF24 | decision [gated-counsel] — KYB↔acquiring | - | [gated-counsel] |
| AG-F2-028 | ChargebackHandler | services/merchant_acquiring/chargeback_handler.py | ChargebackHandler | COO | SMF24 | decision [gated-counsel] — KYB↔acquiring | - | [gated-counsel] |
| AG-F2-029 | MerchantOnboarding | services/merchant_acquiring/merchant_onboarding.py | MerchantOnboarding | COO | SMF24 | decision [gated-counsel] — KYB↔acquiring | - | [gated-counsel] |
| AG-F2-030 | CryptoTransferEngine | services/crypto_custody/transfer_engine.py | TransferEngine | COO | SMF24 | decision [gated-counsel] — crypto/CASP | - | [gated-counsel] |
| AG-F2-031 | TravelRuleEngine | services/crypto_custody/travel_rule_engine.py | TravelRuleEngine | COO | SMF24 | decision [gated-counsel] — crypto/Travel Rule | - | [gated-counsel] |
| AG-F2-032 | WalletManager | services/crypto_custody/wallet_manager.py | WalletManager | COO | SMF24 | decision [gated-counsel] — crypto/custody | - | [gated-counsel] |
| AG-F2-033 | CustodyReconciler | services/crypto_custody/custody_reconciler.py | CustodyReconciler | - | - | tooling [gated-counsel] — crypto/custody | - | [gated-counsel] |
| AG-F2-038 | ChargebackAgent | services/agents/chargeback_agent.py | ChargebackAgent | COO | SMF24 | decision (L2) | - | active |
| AG-F2-039 | GatewayAgent | services/api_gateway/gateway_agent.py | GatewayAgent | COO | SMF24 | decision (L2) | - | active |
| AG-F2-040 | Psd2Agent | services/psd2_gateway/psd2_agent.py | Psd2Agent | COO | SMF24 | decision [gated-counsel] — PSD2/open-banking AISP/PISP [needs-function-clarification] | - | [gated-counsel] |
| AG-F2-041 | DisputeAgent | services/dispute_resolution/dispute_agent.py | DisputeAgent | COO | SMF24 | decision (L2) | - | active |
| AG-F2-042 | FeeAgent | services/fee_management/fee_agent.py | FeeAgent | COO | SMF24 | decision (HITLProposal) | - | active |
| AG-F2-043 | BeneficiaryAgent | services/beneficiary_management/beneficiary_agent.py | BeneficiaryAgent | COO | SMF24 | decision (L2) | - | active |
| AG-F2-044 | SwiftAgent | services/swift_correspondent/swift_agent.py | SwiftAgent | COO | SMF24 | decision (HITLProposal) | - | active |

---
**This does not replace legal advice.**
