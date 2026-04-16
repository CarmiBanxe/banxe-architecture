# Phase 1 Execution Ledger (BANXE AI BANK)

Status: BASELINE-LOCKED — all 16 domains classified, 0 UNKNOWN. Verification ongoing.

| service | domain | legacy refs | classification | note | verified |
|---|---|---|---|---|---|
| payments-service | payments | srvstagingbanxe.rar / services/payments/* | REWRITE-CANDIDATE | P0 payments core; structurally coupled to paymentaccounts; target core should be rebuilt with explicit source-to-target mapping and FX split retained | no |
| paymentaccounts-service | accounts/ledger | srvstagingbanxe.rar / services/paymentaccounts/* | REWRITE-CANDIDATE | P0 ledger/accounts; must migrate together with payments domain and preserve reconciliation semantics | no |
| identity-service | identity/KYC/KYB | srvstagingbanxe.rar / identity* | EVALUATE-CANDIDATE | P0 identity & KYC/KYB backbone; depends on actual KYC/KYB flows and SumSub/other provider usage; decision KEEP/WRAP/REWRITE requires ENTITYINVENTORY+MIGRATIONPLANDETAIL review | no |
| auth-backend | auth | srvstagingbanxe.rar / auth-backend* | WRAP-CANDIDATE | P0 auth/JWT/session model; likely reusable as wrapper around legacy auth-backend with cleaned interfaces and security review | no |
| acl-service | ACL | srvstagingbanxe.rar / acl* | WRAP-CANDIDATE | P0 roles/permissions/ACL engine; candidate for wrapping legacy ACL while defining target policy contracts | no |
| twofa-service | 2FA | srvstagingbanxe.rar / 2fa* | WRAP-CANDIDATE | P0 2FA/OTP/approval flows; likely to be wrapped to preserve existing OTP/2FA operations with new auth/UX integration | no |

| cards-service | cards | srvstagingbanxe.rar / cards* | EVALUATE-CANDIDATE | P1 card lifecycle; depends on external card provider decision (WRAP vs REWRITE) | no |
| crypto-api | crypto | srvstagingbanxe.rar / crypto-api* | REWRITE-CANDIDATE | P1 crypto API; separate stream, likely full rewrite for target crypto-service | no |
| crypto-processing | crypto | srvstagingbanxe.rar / crypto-processing* | REWRITE-CANDIDATE | P1 crypto processing; coupled to crypto-api, same rewrite stream | no |
| sepa-service | payments/SEPA | srvstagingbanxe.rar / sepa-service* | WRAP-CANDIDATE | P1 SEPA; likely wrappable as payment-method adapter in target payments core | no |
| acquiring-service | acquiring | srvstagingbanxe.rar / acquiring* | WRAP-CANDIDATE | P1 acquiring; likely wrappable as provider adapter | no |
| transactions-service | transactions | srvstagingbanxe.rar / transactions* | REWRITE-CANDIDATE | P1 transactions; tightly coupled to payments/accounts, must align with target ledger | no |
| companies-service | companies | srvstagingbanxe.rar / companies* | WRAP-CANDIDATE | P1 companies; KYB entity mgmt, likely wrappable with identity-service alignment | no |
| tariff-service | tariff | srvstagingbanxe.rar / tariff* | KEEP-CANDIDATE | P1 tariff; reference/config data, likely retainable with minimal changes | no |
| notification-service | notifications | srvstagingbanxe.rar / notification* | WRAP-CANDIDATE | P1 notifications; likely wrappable, channel adapters reusable | no |
| core-service | core | srvstagingbanxe.rar / core* | EVALUATE-CANDIDATE | P1 core; shared utilities scope unclear, needs inventory before decision | no |

## Phase 1 — Full Baseline Summary

### P0 Classification candidates (all verified = no)

- **REWRITE-CANDIDATE** (2): payments-service, paymentaccounts-service
- **WRAP-CANDIDATE** (3): auth-backend, acl-service, twofa-service
- **EVALUATE-CANDIDATE** (1): identity-service

### P1 Classification candidates (all verified = no)

- **REWRITE-CANDIDATE** (3): crypto-api, crypto-processing, transactions-service
- **WRAP-CANDIDATE** (4): sepa-service, acquiring-service, companies-service, notification-service
- **EVALUATE-CANDIDATE** (2): cards-service, core-service
- **KEEP-CANDIDATE** (1): tariff-service

### Blockers before Phase 1 closure

1. All P0 classifications require verification against ENTITYINVENTORY + MIGRATIONPLANDETAIL
2. identity-service EVALUATE cannot be resolved without KYC/KYB flow analysis
3. cards-service EVALUATE depends on external card provider decision
4. core-service EVALUATE needs shared utilities inventory
5. No critical UNKNOWN allowed for P0 before declaring Phase 1 done

### Ledger totals

- Total services: 16
- P0 classified: 6 (2 REWRITE, 3 WRAP, 1 EVALUATE) — 0 UNKNOWN
- P1 classified: 10 (3 REWRITE, 4 WRAP, 2 EVALUATE, 1 KEEP) — 0 UNKNOWN
- Verified: 0 of 16
- Phase 1 status: BASELINE-LOCKED (ready for P0 execution start)
