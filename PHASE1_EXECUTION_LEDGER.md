# Phase 1 Execution Ledger (BANXE AI BANK)

Status: BASELINE-LOCKED — synced with actual project state 2026-04-17.

## P0 Domains (EMI Core Foundation)

| service | domain | target module | classification | status | verified |
|---|---|---|---|---|---|
| payments-service | payments | services/payment/ | REWRITE | DI wired (PaymentService+LedgerPort), 59+ tests pass, router aligned | yes |
| paymentaccounts-service | accounts/ledger | services/ledger/ | REWRITE | MidazLedgerAdapter+StubLedgerAdapter, wired via DI | yes |
| identity-service | identity/KYC/KYB | services/kyc/ | EVALUATE-CANDIDATE | kyc_port 97% coverage, mock workflow exists, Ballerine target | no |
| auth-backend | auth | services/auth/ | WRAP-CANDIDATE | token_manager+sca_service+two_factor+DI wired (api/deps.py) | yes |
| acl-service | ACL/IAM | services/iam/ | WRAP-CANDIDATE | iam_port+mock_iam_adapter+DI wired (get_iam+require_auth) | yes |
| twofa-service | 2FA | services/auth/ | WRAP-CANDIDATE | two_factor.py+DI wired (get_totp_service) | yes |

## P1 Domains (Product Surfaces)

| service | domain | target module | classification | status | verified |
|---|---|---|---|---|---|
| cards-service | cards | services/card_issuing/ | IMPLEMENTED | Phase 19 done, models 85%, lifecycle+fraud+spend control | yes |
| crypto-api | crypto | — | REWRITE-CANDIDATE | not yet started | no |
| crypto-processing | crypto | — | REWRITE-CANDIDATE | not yet started | no |
| sepa-service | payments/SEPA | services/payment/ | WRAP-CANDIDATE | PaymentRail.SEPA_CT+SEPA_INSTANT in payment_port | partial |
| acquiring-service | acquiring | services/merchant_acquiring/ | IMPLEMENTED | Phase 20 done, onboarding+gateway+settlement+chargeback | yes |
| transactions-service | transactions | services/transaction_monitor/ | IMPLEMENTED | scoring+alerts+velocity, models 95-100% | yes |
| companies-service | companies | services/customer/ | WRAP-CANDIDATE | customer_port 91%, service exists | partial |
| tariff-service | tariff | src/billing/ | KEEP-CANDIDATE | fee_engine exists | no |
| notification-service | notifications | services/notification_hub/ | IMPLEMENTED | Phase 18 done, channel dispatcher+templates+preferences | yes |
| core-service | core | services/config/ | EVALUATE-CANDIDATE | config_port+config_service exist | no |

## Supporting Systems (Already Implemented)

| service | domain | target module | phase | status |
|---|---|---|---|---|
| fx-exchange | FX | services/fx_exchange/ | Phase 21 | IMPLEMENTED |
| multi-currency | multi-currency | services/multi_currency/ | Phase 22 | IMPLEMENTED |
| treasury | treasury | services/treasury/ | Phase 17 | IMPLEMENTED |
| open-banking | PSD2/AISP/PISP | services/open_banking/ | Phase 15 | IMPLEMENTED |
| audit-dashboard | governance | services/audit_dashboard/ | Phase 16 | IMPLEMENTED |
| fraud | AML/fraud | services/fraud/ | — | IMPLEMENTED |
| recon | reconciliation | services/recon/ | — | IMPLEMENTED |
| safeguarding | FCA CASS | src/safeguarding/ | — | IMPLEMENTED |
| settlement | settlement | src/settlement/ | — | IMPLEMENTED |
| compliance-kb | compliance | services/compliance_kb/ | — | IMPLEMENTED |
| consumer-duty | consumer duty | services/consumer_duty/ | — | IMPLEMENTED |
| support | customer support | services/support/ | — | IMPLEMENTED |
| webhooks | integrations | services/webhooks/ | — | IMPLEMENTED |
| events | event bus | services/events/ | — | IMPLEMENTED |
| statements | account statements | services/statements/ | — | IMPLEMENTED |
| complaints | complaints | services/complaints/ | — | IMPLEMENTED |
| case-management | cases | services/case_management/ | — | IMPLEMENTED |
| design-pipeline | UI generation | services/design_pipeline/ | — | IMPLEMENTED |
| agent-routing | AI agents | services/agent_routing/ | — | IMPLEMENTED |
| experiment-copilot | experiments | services/experiment_copilot/ | — | IMPLEMENTED |
| compliance-automation | compliance | services/compliance_automation/ | — | NEW (untracked) |
| document-management | documents | services/document_management/ | — | NEW (untracked) |

## Summary

### Ledger totals
- Total modules: 38+
- P0 verified: 2 of 6 (payments, ledger)
- P0 pending: 4 (identity, auth, ACL/IAM, 2FA) — code exists, DI wiring needed
- P1 implemented: 5 of 10 (cards, acquiring, transactions, notifications, fx)
- Supporting systems implemented: 20+
- Tests: 4103+ passed
- Coverage: ~49% (target 80%)

### Next actions
1. Wire auth/IAM/2FA into deps.py (Phase 2 P0 closure)
2. Add auth guards to sensitive routers
3. Raise coverage from 49% toward 80%
4. Resolve identity-service EVALUATE (Ballerine vs SumSub decision)
