# Phase 3 — BANXE.RAR controlled inventory (closed)

**Date:** 2026-05-06
**Status:** CLOSED
**Canon:** ADR-015 (auth ports) + ADR-025 §16 (shell hygiene) + AUTH_MATRIX.md + IL-CANON-OPERATOR-2026-05
**Gate closed:** G-RAR-PASS-01 (password received, archive integrity verified, full listing extracted)

---

## Archive provenance

| Field | Value |
|---|---|
| Source path | `/backup/banxe.rar` on host `evo1` |
| Size | 6.4 GB |
| Format | RAR v5 |
| SHA-256 | `420913292bf38c50543cbcecd8c2079e050f8d3fc588b1f7f145605af0e1bf13` |
| Total entries | **100488** files |
| Listing artefact | `docs/inventories/BANXE-RAR-LISTING-2026-05-06.txt` (verbatim, 7.6 MB, append-only canon) |
| Local-first | Archive remains on evo1 only — no cloud upload, no broader movement before refactor/anonymisation (§3.2 of canon ADR-025) |

---

## Top-level layout (14 entries — verified against listing)

12 directory roots + 2 standalone files:

| # | Entry | Type |
|---:|---|---|
| 1 | `banxe/` | dir (≈97 sub-repos) |
| 2 | `banxe-digital/` | dir (4 sub-repos) |
| 3 | `banxe_site/` | dir (13 sub-repos) |
| 4 | `binarity-team/` | dir (1 sub-repo) |
| 5 | `cex/` | dir (2 sub-repos) |
| 6 | `consul-configs/` | dir (3 envs) |
| 7 | `crypto-api/` | dir (24 sub-repos) |
| 8 | `crypto-processing/` | dir (10 sub-repos) |
| 9 | `dcard/` | dir (1 sub-repo) |
| 10 | `ilink/` | dir (1 sub-repo) |
| 11 | `internal_dev/` | dir (3 sub-repos) |
| 12 | `neuron/` | dir (≈24 sub-repos) |
| 13 | `gitlab_clone_all.py` | file |
| 14 | `report 07.04.txt` | file |

Note: spec mentioned 13 roots; verified count from inventory listing is 14 (12 dirs + 2 files). Canonical number is **14**.

---

## Mapping table — BANXE.RAR → EMI target (4 categories)

File counts are exact, derived from `docs/inventories/BANXE-RAR-LISTING-2026-05-06.txt` via `grep -c "^<repo>/"`. Fragment-level PASS / REWRITE / REJECT decisions are deferred to Phase 4 per-wave inventories.

### Category 1 — AUTH / IAM (Wave A target)

| BANXE.RAR repo | Files | EMI target boundary | Port |
|---|---:|---|---|
| `banxe/banxe_auth` | 764 | `services/auth/auth_application_service.py` (extend) | `TokenManagerPort`, `IAMPort` |
| `banxe/common_auth_web` | 593 | `services/auth/` (web auth helpers) | `TokenManagerPort` |
| `banxe/auth-service` | 87 | `services/auth/` (orchestration glue) | `IAMPort` |
| `banxe/banxe-auth` | 137 | candidate REWRITE → AuthApplicationService | `TokenManagerPort` |
| `banxe/banxe-auth-old` | 64 | likely REJECT (legacy duplicate) | — |
| `banxe/banxe-tx-auth` | 278 | `services/auth/` (transaction-bound auth) | `TokenManagerPort` |
| `banxe/banxe-id-frontend` | 247 | UI — out of EMI scope (frontend project) | — |
| `banxe/banxe-identity-config-manager` | 67 | `services/auth/identity_config/` | `IAMPort` |
| `banxe_site/auth_client` | 642 | reference impl — REJECT or sample-only | — |
| `neuron/neuron-auth` | 64 | likely REJECT (neuron exchange legacy) | — |
| `neuron/neuron-auth-backend` | 348 | likely REJECT | — |
| **subtotal** | **3291** | | |

### Category 2 — SCA / 2FA (Wave B target)

| BANXE.RAR repo | Files | EMI target boundary | Port |
|---|---:|---|---|
| `banxe/sumsub-test` | 49 | `services/auth/sca/` + `services/auth/two_factor.py` | `TwoFactorPort` |
| OTP fragments inside `banxe/banxe_auth` | (counted in Wave A) | `services/auth/two_factor.py` | `TwoFactorPort` |
| **subtotal (distinct files)** | **49** | | |

### Category 3 — PAYMENTS (Wave C target)

| BANXE.RAR repo | Files | EMI target boundary | Port |
|---|---:|---|---|
| `banxe/sepa-service` | 280 | `services/payment/` (SEPA rail) | `PaymentRailPort` |
| `banxe/banxe-fiat-backend` | 11519 | `services/payment/` core | `PaymentRailPort` |
| `banxe/binance-pay-backend` | 307 | `services/payment/binance/` | `PaymentRailPort` |
| `banxe/mass-payout` | 413 | `services/payment/payout/` | `PaymentRailPort` |
| `banxe/paysend` | 289 | `services/payment/paysend/` | `PaymentRailPort` |
| `banxe/banxe-paysend` | 65 | candidate REWRITE | `PaymentRailPort` |
| `banxe/banxe-acquiring` | 222 | `services/payment/acquiring/` | `PaymentRailPort` |
| `banxe/banxe-checkout-api` | 69 | `services/payment/checkout/` | `PaymentRailPort` |
| `banxe/banxe-manual-payments` | 248 | `services/payment/manual/` | `PaymentRailPort` |
| `banxe/banxe-tranzaxis-mock-server` | 65 | mock — test harness only | — |
| `banxe/banxe-wallester` | 200 | `services/payment/wallester/` | `PaymentRailPort` |
| `banxe/wallester-poc` | 61 | likely REJECT (PoC) | — |
| `banxe/tompayment-web` | 2827 | likely REWRITE/REJECT (UI heavy) | — |
| `banxe/banxe-open-banking` | 261 | `services/openbanking/` | dedicated port |
| `banxe/elpaso-common` | 274 | shared lib — extract types only | — |
| `banxe/banxe-transactions` | 579 | `services/payment/tx/` | `PaymentRailPort` |
| `banxe/temenos_r19-apis` | 378 | `services/payment/temenos/` (legacy core-bank) | `PaymentRailPort` |
| `banxe/temenos_r19.12` | 385 | likely REJECT (older Temenos) | — |
| `banxe/temenos_r20` | 398 | likely REJECT (older Temenos) | — |
| `neuron/neuron-gambling-acquiring` | 70 | likely REJECT (out of EMI scope) | — |
| `neuron/neuron-gambling-backend` | 137 | likely REJECT (out of EMI scope) | — |
| **subtotal** | **19047** | | |

### Category 4 — KYC / COMPLIANCE (Wave D target)

| BANXE.RAR repo | Files | EMI target boundary | Port |
|---|---:|---|---|
| `banxe-digital/binance-kyc` | 248 | `services/kyc/` | `KYCProviderPort` |
| `banxe/company-house` | 61 | `services/kyc/companies_house/` | `KYCProviderPort` |
| `banxe/confero-dummy` | 46 | mock — test harness only | — |
| `banxe-digital/v-accounting` | 785 | `services/compliance/` (accounting/AML hooks) | dedicated port |
| **subtotal** | **1140** | | |

### Category 5 — CRYPTO / LEDGER (Wave E target)

| BANXE.RAR repo | Files | EMI target boundary | Port |
|---|---:|---|---|
| `crypto-api/` (24 sub-repos) | 2751 | `services/ledger/` (midaz adapter) | `LedgerPort` |
| `crypto-processing/` (10 sub-repos) | 10604 | `services/ledger/` + `services/crypto/` | `LedgerPort` |
| `banxe/banxe-crypto-earn` | 214 | likely REJECT (product-level) | — |
| `banxe/banxe-crypro-processing-api` | 607 | `services/crypto/processing/` | `LedgerPort` |
| `banxe/banxe-crypro-processing-wrapper` | 196 | adapter glue | `LedgerPort` |
| `banxe-digital/crypto-exchange-api` | 665 | `services/crypto/exchange/` | `LedgerPort` |
| `dcard/crypto-accounts` | 62 | `services/ledger/accounts/` | `LedgerPort` |
| `neuron/neuron-crypto-api` | 96 | likely REJECT (neuron legacy) | — |
| `neuron/neuron-blockchain` | 490 | likely REJECT | — |
| `neuron/neuron-blockchain-client` | 1108 | likely REJECT | — |
| `neuron/neuron-bitshares-ui` | 1409 | likely REJECT (UI) | — |
| `neuron/neuron-exchange-admin-2` | 133 | likely REJECT | — |
| `neuron/neuron-exchange-backend` | 41 | likely REJECT | — |
| `neuron/cex-proxy` | 64 | likely REJECT | — |
| `cex/cex` | 41 | likely REJECT | — |
| `cex/gql-cex` | 41 | likely REJECT | — |
| **subtotal** | **18522** | | |

**Categorised subtotal:** 3291 + 49 + 19047 + 1140 + 18522 = **42049 files** (≈42 % of inventory). The remainder (~58400 files) is infrastructure, shared UI, .git histories of cloned repos, internal dev tooling, and duplicate-clone artefacts — Phase 3 marks them as **deferred** for Phase 4 per-wave fragment inventory.

---

## Wave plan for Phase 4

Order is fixed by AUTH_IMPORT_ORDER.md and ADR-015 — no cross-wave starts.

| Wave | Scope | Primary BANXE.RAR sources | Primary EMI port |
|---|---|---|---|
| **A — AUTH / IAM** | token lifecycle, login, IAM glue | `banxe/banxe_auth`, `banxe/common_auth_web`, `banxe/auth-service`, `banxe/banxe-tx-auth`, `banxe/banxe-identity-config-manager` | `TokenManagerPort`, `IAMPort`, `TwoFactorPort` |
| **B — SCA / 2FA** | challenge / verify / resend, OTP, recovery | `banxe/sumsub-test`, OTP fragments inside `banxe/banxe_auth` | `TwoFactorPort` (already wired in Sprint 4 Track A) |
| **C — PAYMENTS** | SEPA, fiat backend, acquiring, payouts, OpenBanking | `banxe/sepa-service`, `banxe/banxe-fiat-backend`, `banxe/banxe-acquiring`, `banxe/mass-payout`, `banxe/banxe-open-banking` | `PaymentRailPort` |
| **D — KYC / COMPLIANCE** | KYC providers + compliance hooks | `banxe-digital/binance-kyc`, `banxe/company-house`, `banxe-digital/v-accounting` | `KYCProviderPort` |
| **E — CRYPTO / LEDGER** | midaz ledger adapter, crypto processing | `crypto-api/*`, `crypto-processing/*`, `banxe/banxe-crypro-processing-api`, `dcard/crypto-accounts` | `LedgerPort` (midaz adapter) |

---

## Canon rules carried forward into Phase 4

1. **No direct BANXE.RAR import into `api/routers/auth.py`** (router stays transport-only).
2. **All legacy attach points behind ports/adapters** — no service-level imports outside `services/auth/`, `services/payment/`, `services/kyc/`, `services/ledger/`.
3. **PASS / REWRITE / REJECT** decision per fragment, recorded in per-wave session doc.
4. **Local-first handling** — RAR archive stays on evo1; no broader movement until each fragment is anonymised + classified.
5. **Append-only IL** — every wave gate (entry + exit) emits an IL entry.
6. **Per-wave exit criteria** — imported logic behind seam, tests updated, coverage ≥ 80 % for changed services.

---

## G-RAR-PASS-01 closure evidence

- Password successfully applied — RAR opened on evo1.
- Archive integrity verified (SHA-256 above).
- Listing of all 100488 entries persisted to repo at `docs/inventories/BANXE-RAR-LISTING-2026-05-06.txt`.
- Top-level layout cross-checked against `awk -F'/' '{print $1}' | sort -u` — matches.
- Phase 3 inventory **closed**. Phase 4 Wave A (AUTH/IAM) is now executable.

## Next action

Phase 4 Wave A — open `sprint5/wave-a-auth-iam-import` from `main`, read `banxe/banxe_auth/**` and `banxe/common_auth_web/**` from the listing, perform per-fragment PASS/REWRITE/REJECT classification, attach behind `TokenManagerPort` / `IAMPort` / `TwoFactorPort`. No router edits.
