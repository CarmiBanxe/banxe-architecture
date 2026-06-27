# EMI legacy / v2 rationalization — pass #1 (read-only audit)

**Plane:** docs-plane (audit/matrix; no runtime). **Base:** banxe-emi-stack `origin/main @ eb09e9c`.
**Date:** 2026-06-27. **NO code changed** — read-only audit only.

> **Result:** **0 new safe orphan deletions this pass.** The only true orphans (legacy SCA/TOTP)
> were already removed in EMI **#248 (`39742b7`)**. All remaining legacy is **LIVE / transitively-live
> / PARKED-protected**. Verify-before-delete: surface "0-live" modules (`jwks_models`, `jwt_strategy`,
> `legacy_abs_payment`) are **transitively live** via kept anchors (`role_guard`, `bifrost`).

### Pass-1 update log (2026-06-27)
- Stream **#1 DONE** — `consumer_duty/models_v2 → models` rename (EMI #255 / `78207c0`; ruff-debt unblock EMI #257 / `36418d9`). Matrix otherwise unchanged; no new orphan deletions; remaining streams (`to_minor_units` extraction, `recon_v2`/`fin060_v2` merge-pairs, `otp`/`sepa` → production) stay OPEN.

## 1. Live / orphan matrix (24 modules — verified on eb09e9c)
| Module | Live-consumers (non-legacy) | Class |
|---|---|---|
| `api/routers/consumer_duty_v2.py` | mounted `/v1` | LIVE_KEEP |
| `api/routers/crypto_legacy.py` | mounted `/v1/crypto-legacy` | LIVE_KEEP (PAYBIS-controlled) |
| `services/_legacy_common/audit.py` | 6 | LIVE_KEEP |
| `services/_legacy_common/state_machine.py` | 4 | LIVE_KEEP |
| `services/auth/legacy/legacy_otp_adapter.py` | 4 | LIVE_MIGRATE_NEXT |
| `services/auth/legacy/role_guard.py` | 0 + 3 security tests | PARKED_REVIEW |
| `services/auth/legacy/jwt_strategy.py` | transitive via role_guard | LIVE_KEEP (coupled) |
| `services/auth/legacy/jwks_models.py` | transitive via jwt_strategy | LIVE_KEEP (coupled) |
| `services/compliance/legacy/_edd.py` | 1 | LIVE_KEEP |
| `services/compliance/legacy/_jurisdictions.py` | 1 | LIVE_KEEP |
| `services/compliance/legacy/legacy_sumsub_adapter.py` | 1 (I-27) | LIVE_KEEP |
| `services/compliance/legacy/legacy_binancekyc_adapter.py` | 0 test-only (I-27) | PARKED_REVIEW |
| `services/compliance/legacy/legacy_bkyc_adapter.py` | 0 test-only (I-27) | PARKED_REVIEW |
| `services/consumer_duty/models_v2.py` | 1 sole impl (no `models.py`) | ✅ DONE — renamed → `models.py` (EMI #255 / `78207c0`) |
| `services/ledger/legacy/legacy_crypto_processing_adapter.py` | 2 (api/deps DI) | LIVE_KEEP (PAYBIS-controlled) |
| `services/ledger/legacy/legacy_crypto_rpc_adapter.py` | 1 | LIVE_KEEP (PAYBIS-controlled) |
| `services/ledger/legacy/legacy_crypto_wallet_adapter.py` | 1 | LIVE_KEEP (PAYBIS-controlled) |
| `services/payment/legacy/bifrost_adapter.py` | 2 (`to_minor_units`) | LIVE_MIGRATE_NEXT |
| `services/payment/legacy/legacy_transactions_adapter.py` | 2 | LIVE_KEEP |
| `services/payment/legacy/legacy_abs_payment_adapter.py` | transitive via bifrost | LIVE_KEEP (coupled) |
| `services/payment/legacy/legacy_sepa_adapter.py` | 1 | LIVE_MIGRATE_NEXT |
| `services/recon/reconciliation_engine_v2.py` | 4 | LIVE_MIGRATE_NEXT (merge-pair) |
| `services/reporting/fin060_generator_v2.py` | 2 | LIVE_MIGRATE_NEXT (merge-pair) |

## 2. ORPHAN_REMOVE_CANDIDATE
**NONE this pass.** (Legacy SCA/TOTP already removed in EMI #248 / `39742b7`.)

## 3. LIVE_MIGRATE_NEXT streams (target | thinnest seam | blocker)
| Module | Modern target | Thinnest seam | Blocker |
|---|---|---|---|
| `reconciliation_engine_v2` | `recon/reconciliation_engine.py` (v1) | migrate 4 consumers → unify → delete v2 | scoped PR |
| `fin060_generator_v2` | `reporting/fin060_generator.py` (v1) | migrate matrix_scanner + reporting_agent → unify | scoped PR |
| `consumer_duty/models_v2` | rename → `models.py` | atomic rename + 12+ import update | ✅ **DONE** (EMI #255, `78207c0`; ruff-debt unblock EMI #257 / `36418d9`) |
| `bifrost_adapter` (`to_minor_units`) | `services/shared` money util | move helper, repoint open_banking ×2 | helper extraction |
| `legacy_otp_adapter` | `auth/production/{twilio,sendgrid}_otp_adapter` | repoint 4 consumers | provider parity |
| `legacy_sepa_adapter` | `payment/production/modulr_sepa_stub` | repoint 1 consumer | Modulr live-wiring |
| `crypto_legacy` router + `ledger/legacy/legacy_crypto_*` | `PaybisCryptoAdapter` | route cutover + DI swap | **GATED on PAYBIS Wave C** (SRC-06 + ADR-114) |

## 4. Duplicates / replacements map
- **legacy ↔ current:** `legacy_otp_adapter` ↔ `production/{twilio,sendgrid}_otp_adapter` · `legacy_crypto_*` ↔ `PaybisCryptoAdapter` (gated) · `legacy_sepa_adapter` ↔ `production/modulr_sepa_stub` · `crypto_legacy` router ↔ future PAYBIS routes.
- **v2 ↔ current:** `reconciliation_engine_v2` ↔ `reconciliation_engine` · `fin060_generator_v2` ↔ `fin060_generator` · `models_v2` ↔ `models` *(✅ unified — rename done, EMI #255 / `78207c0`)*.
- **parked vs genuinely redundant:** `role_guard` = parked, **NOT redundant** (security invariant, no replacement proven) · `binancekyc`/`bkyc` = parked I-27 · `legacy_abs_payment`/`jwt_strategy`/`jwks_models` = parked-coupled (transitive live), not redundant.

## 5. Protected (do NOT remove)
- `role_guard` — role/status **security invariant** (3 functional tests); no replacement proven.
- `legacy_binancekyc` / `legacy_bkyc` — **I-27 KYC perimeter**; removal needs operator + MLRO/HITL-L4.
- **Coupled chains migrate as units:** `role_guard → jwt_strategy → jwks_models`; `bifrost → legacy_abs_payment`.

## 6. Bittrex / NeuroNext
**0 footprint** in `services/`/`app/` (E9 guard `banxe-no-{neuronext,bitrix}-reintroduction` active). Removal = **forward-guard** against reintroduction + PAYBIS replacement path.

## 7. Recommended next batch
- **Deletion batch: EMPTY** (smallest-safe = zero new deletions this pass).
- **Highest-value next (each its own scoped PR — ADR-102 dup-audit + full-suite green; NOT this pass):**
  1. ✅ **DONE** — `consumer_duty/models_v2 → models` rename (EMI #255 / `78207c0`; ruff-debt unblock #257 / `36418d9`).
  2. extract `bifrost.to_minor_units → shared` money util (unlocks bifrost + `legacy_abs_payment` parking).
  3. `reconciliation_engine_v2` / `fin060_generator_v2` merge-pairs.
  4. `legacy_otp` / `legacy_sepa` → production adapters.
  5. **GATED on PAYBIS Wave C:** `crypto_legacy` router + `ledger/legacy/legacy_crypto_*` cutover.

### Refs
EMI `origin/main @ eb09e9c` (read-only `git grep`/`git ls-tree`); EMI #248 (`39742b7`, SCA/TOTP removal); PAYBIS dossier ADR-126/138, ADR-108/114; PLAN §1A E10 (consolidation track); ADR-102 (dup-audit); I-20/I-24/I-27.
