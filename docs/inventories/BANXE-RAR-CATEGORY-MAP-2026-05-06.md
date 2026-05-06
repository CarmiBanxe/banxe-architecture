# BANXE.RAR — category map (Phase 3, 2026-05-06)

**Source listing:** `docs/inventories/BANXE-RAR-LISTING-2026-05-06.txt` (100488 entries, 7.6 MB, SHA-256 of source archive `420913292bf38c50543cbcecd8c2079e050f8d3fc588b1f7f145605af0e1bf13`).
**Method:** file counts derived per repo via `grep -c "^<repo>/" <listing>`.
**Canon:** ADR-015 + ADR-025 §16 + AUTH_IMPORT_ORDER.md.

---

## Master matrix

| Category | BANXE.RAR repo | Files | EMI target boundary | Port | Wave |
|---|---|---:|---|---|:-:|
| AUTH/IAM | `banxe/banxe_auth` | 764 | `services/auth/auth_application_service.py` | `TokenManagerPort`, `IAMPort` | A |
| AUTH/IAM | `banxe/common_auth_web` | 593 | `services/auth/` web helpers | `TokenManagerPort` | A |
| AUTH/IAM | `banxe/auth-service` | 87 | `services/auth/` orchestration glue | `IAMPort` | A |
| AUTH/IAM | `banxe/banxe-auth` | 137 | candidate REWRITE → AuthApplicationService | `TokenManagerPort` | A |
| AUTH/IAM | `banxe/banxe-auth-old` | 64 | likely REJECT (legacy duplicate) | — | A |
| AUTH/IAM | `banxe/banxe-tx-auth` | 278 | `services/auth/` transaction-bound auth | `TokenManagerPort` | A |
| AUTH/IAM | `banxe/banxe-id-frontend` | 247 | UI — out of EMI scope | — | A |
| AUTH/IAM | `banxe/banxe-identity-config-manager` | 67 | `services/auth/identity_config/` | `IAMPort` | A |
| AUTH/IAM | `banxe_site/auth_client` | 642 | reference impl — REJECT or sample-only | — | A |
| AUTH/IAM | `neuron/neuron-auth` | 64 | likely REJECT | — | A |
| AUTH/IAM | `neuron/neuron-auth-backend` | 348 | likely REJECT | — | A |
| **AUTH/IAM subtotal** | | **3291** | | | A |
| SCA/2FA | `banxe/sumsub-test` | 49 | `services/auth/sca/` + `services/auth/two_factor.py` | `TwoFactorPort` | B |
| SCA/2FA | OTP fragments in `banxe/banxe_auth` | (in A) | `services/auth/two_factor.py` | `TwoFactorPort` | B |
| **SCA/2FA subtotal** | | **49** | | | B |
| PAYMENTS | `banxe/sepa-service` | 280 | `services/payment/sepa/` | `PaymentRailPort` | C |
| PAYMENTS | `banxe/banxe-fiat-backend` | 11519 | `services/payment/` core | `PaymentRailPort` | C |
| PAYMENTS | `banxe/binance-pay-backend` | 307 | `services/payment/binance/` | `PaymentRailPort` | C |
| PAYMENTS | `banxe/mass-payout` | 413 | `services/payment/payout/` | `PaymentRailPort` | C |
| PAYMENTS | `banxe/paysend` | 289 | `services/payment/paysend/` | `PaymentRailPort` | C |
| PAYMENTS | `banxe/banxe-paysend` | 65 | candidate REWRITE | `PaymentRailPort` | C |
| PAYMENTS | `banxe/banxe-acquiring` | 222 | `services/payment/acquiring/` | `PaymentRailPort` | C |
| PAYMENTS | `banxe/banxe-checkout-api` | 69 | `services/payment/checkout/` | `PaymentRailPort` | C |
| PAYMENTS | `banxe/banxe-manual-payments` | 248 | `services/payment/manual/` | `PaymentRailPort` | C |
| PAYMENTS | `banxe/banxe-tranzaxis-mock-server` | 65 | mock — test only | — | C |
| PAYMENTS | `banxe/banxe-wallester` | 200 | `services/payment/wallester/` | `PaymentRailPort` | C |
| PAYMENTS | `banxe/wallester-poc` | 61 | likely REJECT (PoC) | — | C |
| PAYMENTS | `banxe/tompayment-web` | 2827 | likely REWRITE/REJECT (UI heavy) | — | C |
| PAYMENTS | `banxe/banxe-open-banking` | 261 | `services/openbanking/` | dedicated port | C |
| PAYMENTS | `banxe/elpaso-common` | 274 | shared lib — extract types only | — | C |
| PAYMENTS | `banxe/banxe-transactions` | 579 | `services/payment/tx/` | `PaymentRailPort` | C |
| PAYMENTS | `banxe/temenos_r19-apis` | 378 | `services/payment/temenos/` legacy | `PaymentRailPort` | C |
| PAYMENTS | `banxe/temenos_r19.12` | 385 | likely REJECT (older Temenos) | — | C |
| PAYMENTS | `banxe/temenos_r20` | 398 | likely REJECT (older Temenos) | — | C |
| PAYMENTS | `neuron/neuron-gambling-acquiring` | 70 | likely REJECT (out of EMI scope) | — | C |
| PAYMENTS | `neuron/neuron-gambling-backend` | 137 | likely REJECT (out of EMI scope) | — | C |
| **PAYMENTS subtotal** | | **19047** | | | C |
| KYC/COMPLIANCE | `banxe-digital/binance-kyc` | 248 | `services/kyc/` | `KYCProviderPort` | D |
| KYC/COMPLIANCE | `banxe/company-house` | 61 | `services/kyc/companies_house/` | `KYCProviderPort` | D |
| KYC/COMPLIANCE | `banxe/confero-dummy` | 46 | mock — test only | — | D |
| KYC/COMPLIANCE | `banxe-digital/v-accounting` | 785 | `services/compliance/` accounting/AML hooks | dedicated port | D |
| **KYC/COMPLIANCE subtotal** | | **1140** | | | D |
| CRYPTO/LEDGER | `crypto-api/` (24 sub-repos) | 2751 | `services/ledger/` midaz adapter | `LedgerPort` | E |
| CRYPTO/LEDGER | `crypto-processing/` (10 sub-repos) | 10604 | `services/ledger/` + `services/crypto/` | `LedgerPort` | E |
| CRYPTO/LEDGER | `banxe/banxe-crypto-earn` | 214 | likely REJECT (product-level) | — | E |
| CRYPTO/LEDGER | `banxe/banxe-crypro-processing-api` | 607 | `services/crypto/processing/` | `LedgerPort` | E |
| CRYPTO/LEDGER | `banxe/banxe-crypro-processing-wrapper` | 196 | adapter glue | `LedgerPort` | E |
| CRYPTO/LEDGER | `banxe-digital/crypto-exchange-api` | 665 | `services/crypto/exchange/` | `LedgerPort` | E |
| CRYPTO/LEDGER | `dcard/crypto-accounts` | 62 | `services/ledger/accounts/` | `LedgerPort` | E |
| CRYPTO/LEDGER | `neuron/neuron-crypto-api` | 96 | likely REJECT (neuron legacy) | — | E |
| CRYPTO/LEDGER | `neuron/neuron-blockchain` | 490 | likely REJECT | — | E |
| CRYPTO/LEDGER | `neuron/neuron-blockchain-client` | 1108 | likely REJECT | — | E |
| CRYPTO/LEDGER | `neuron/neuron-bitshares-ui` | 1409 | likely REJECT (UI) | — | E |
| CRYPTO/LEDGER | `neuron/neuron-exchange-admin-2` | 133 | likely REJECT | — | E |
| CRYPTO/LEDGER | `neuron/neuron-exchange-backend` | 41 | likely REJECT | — | E |
| CRYPTO/LEDGER | `neuron/cex-proxy` | 64 | likely REJECT | — | E |
| CRYPTO/LEDGER | `cex/cex` | 41 | likely REJECT | — | E |
| CRYPTO/LEDGER | `cex/gql-cex` | 41 | likely REJECT | — | E |
| **CRYPTO/LEDGER subtotal** | | **18522** | | | E |

---

## Totals

| Category | Repos | Files | Wave |
|---|---:|---:|:-:|
| AUTH/IAM | 11 | 3291 | A |
| SCA/2FA | 1 (+ overlap) | 49 | B |
| PAYMENTS | 21 | 19047 | C |
| KYC/COMPLIANCE | 4 | 1140 | D |
| CRYPTO/LEDGER | 16 | 18522 | E |
| **Categorised** | **53** | **42049** | — |
| Deferred (infra / UI / .git histories / dup clones / internal dev) | — | ~58439 | deferred |
| **Inventory total** | — | **100488** | — |

---

## Verification commands (reproducible)

```
LISTING=docs/inventories/BANXE-RAR-LISTING-2026-05-06.txt
wc -l "$LISTING"                                          # 100488
awk -F/ '{print $1}' "$LISTING" | sort -u | wc -l         # 14 top-level entries
grep -c '^banxe/banxe_auth/' "$LISTING"                   # 764
grep -c '^banxe/banxe-fiat-backend/' "$LISTING"           # 11519
grep -c '^crypto-processing/' "$LISTING"                  # 10604
```

All counts above are reproducible from the same listing artefact in the repo.
