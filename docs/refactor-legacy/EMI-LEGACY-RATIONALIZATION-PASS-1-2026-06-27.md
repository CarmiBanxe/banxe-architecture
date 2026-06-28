# EMI legacy / v2 rationalization — pass #1 (read-only audit)

**Plane:** docs-plane (audit/matrix; no runtime). **Base:** banxe-emi-stack `origin/main @ eb09e9c`.
**Date:** 2026-06-27. **NO code changed** — read-only audit only.

> **Result:** **0 new safe orphan deletions this pass.** The only true orphans (legacy SCA/TOTP)
> were already removed in EMI **#248 (`39742b7`)**. All remaining legacy is **LIVE / transitively-live
> / PARKED-protected**. Verify-before-delete: surface "0-live" modules (`jwks_models`, `jwt_strategy`,
> `legacy_abs_payment`) are **transitively live** via kept anchors (`role_guard`, `bifrost`).
> ⚠ **CORRECTED 2026-06-27** (independent shell-audit on EMI `fe27f4d`) — the `bifrost`/`legacy_abs_payment`
> half is wrong: dependency runs **`bifrost → legacy_abs_payment`** (bifrost imports `AbsPaymentStatus`
> from it, `bifrost_adapter.py:19`), so `legacy_abs_payment` is NOT transitively-live *via* bifrost. The
> `role_guard → jwt_strategy → jwks_models` chain is unaffected. See **Correction note** below.

## Correction note (2026-06-27, independent shell-audit on EMI `fe27f4d`)
Three payment-cluster facts in this pass-1 audit were mis-read; original lines are kept (struck/marked) for trail.
- **FACT-1 — `to_minor_units` is a DUPLICATE, not a dependency.** Defined in **two** places — `services/payment/legacy/bifrost_adapter.py:51` **and** `services/open_banking/m24_int_bridge.py:31` (near-identical). `open_banking` (`intl_scheduled.py:25`) imports from its **own** `m24_int_bridge`, NOT bifrost. So bifrost's "2 (`to_minor_units`)" live-count was a duplicate-definition mis-read.
- **FACT-2 — `bifrost_adapter` is a Wave-D SCAFFOLD, class = PARKED.** Docstring: `MIG-M2.5-BIF, Wave-D`, `ADR-025 §15-16`, **advisory / sandbox** (no live GCP calls), with characterization tests. It is NOT `LIVE_MIGRATE_NEXT` and NOT an orphan → **PARKED (intentional scaffold)**.
- **FACT-3 — dependency direction reversed.** `bifrost → legacy_abs_payment` (`bifrost_adapter.py:19` imports `AbsPaymentStatus`). `legacy_abs_payment` is not transitively-live *via* bifrost.
- **Consequence for the stream:** the real action on `to_minor_units` is **DE-DUPLICATE both copies into a `services/shared` money-util (ADR-102)**, NOT "extract bifrost's and repoint open_banking" (open_banking already has its own). De-dup does **not** park or remove bifrost (it stays as the Wave-D scaffold).

## Correction note (2026-06-28, ADR-102 recon audit on EMI `4f93870`) — recon merge-pair direction

The earlier `reconciliation_engine_v2 → v1` direction ("migrate 4 consumers → unify → **delete v2**", rows
§1/§3/§7 below) is **BACKWARDS and SUPERSEDED**. Verified facts (EMI `4f93870`): `services/recon` holds
**THREE distinct engines**, not a v2→v1 pair.
- **`reconciliation_engine_v2.py` = CANONICAL** live runtime — CASS 7.15 V2 (IL-REC-01/Phase 51B), wired
  REST via `recon_agent.py → api/routers/safeguarding_recon.py` (`/v1/safeguarding-recon/*`), CAMT.053
  ingestion (`camt053_parser.py`), `compliance_sync/matrix_scanner.py`. Carries `ReconStorePort` /
  `HITLProposal` / `StatementEntry` / `ReconciliationReport`.
- **`reconciliation_engine.py` (v1) = LEGACY-cron** — CASS 7.15 (IL-007), used **only** by the cron-CLI
  `midaz_reconciliation.py` (`daily-recon.sh`) + 2 tests.
- **`recon_engine.py` = SEPARATE domain** — CASS 7 *safeguarding* recon (IL-SAF-01, DI-wired via
  `api/deps.py`); **not part of this pair** (name collision below is incidental).
- **Corrected direction:** if ever consolidated, it is **`v1 → v2`** (migrate the cron-CLI off v1's model),
  and it is **non-trivial** (different models/signatures, live cron contract). **The pair is PARKED** — no
  code action without operator + a fresh ADR-102 dup-audit.
- **ADR-102 name collisions to track (wrong-import risk):** `class ReconciliationEngine` defined **twice**
  (`reconciliation_engine.py` `.reconcile`, CASS 7.15 — vs `recon_engine.py` `.run_daily_recon`, CASS 7
  safeguarding); `@dataclass ReconResult` defined **twice** (same two files, distinct frozen dataclasses).
- **Cross-ref (not duplicated here):** `docs/paybis-dossier/PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md`
  already records this pair as MERGE-PLANNED / PARKED with both engines live + v2's ReconStorePort/HITLProposal.

## Correction note (2026-06-28, ADR-102 fin060 audit on EMI `4f93870`) — fin060 merge-pair direction

The earlier `fin060_generator_v2 → v1` direction ("migrate matrix_scanner + reporting_agent → unify",
rows §1/§3/§7 below) is **BACKWARDS and SUPERSEDED** (same pattern as the recon correction above).
Verified facts (EMI `4f93870`): FIN060 is **THREE complementary contours**, not a v2→v1 pair.
- **`fin060_generator_v2.py` = GOVERNANCE-API canonical** — HITL/CFO gate (I-01/I-24/I-27, BT-006:
  *never auto-submits*, returns `HITLProposal`), IL-FIN060-01/Phase 51C. Wired `reporting_agent.py →
  api/routers/fin060_reporting.py` (`/v1/fin060/*`) + `compliance_sync/matrix_scanner.py`. Explicitly
  *"Does NOT overwrite fin060_generator.py (backward compat)"*.
- **`fin060_generator.py` (v1) = SUBMISSION engine (REQUIRED)** — PDF render (WeasyPrint) + RegData upload
  (CASS 15 / PS25-12), `generate_fin060(start,end)→Path`. Wrapped by `regdata_return.py::RealFIN060Generator`
  (impl of the `FIN060Generator(Protocol)` port) → `api/deps.py` → `/v1/reporting/fin060/*` + `regdata_gabriel_adapter`.
- **`src/safeguarding/fin060_generator.py` = SEPARATE domain** — safeguarding return-data (`FIN060Return`,
  `build(...)`, CASS 15.12.4R), wired `api/routers/safeguarding.py` (`/v1/safeguarding…fca-return`).
- **Corrected status:** the three are **complementary by design** (governance gate / submission engine /
  safeguarding data) — deleting v2 would regress the I-27/BT-006 HITL gate. **The pair is PARKED**; any
  consolidation is an **architecture decision** (should the v2 gate wrap the v1 engine via the
  `FIN060Generator` Protocol port, or stay parallel layers) — no code action without operator + fresh ADR-102.
- **ADR-102 name collisions (wrong-import risk):** `class FIN060Generator` defined **three times** —
  `fin060_generator_v2.py` (concrete V2 HITL), `regdata_return.py` (Protocol port),
  `src/safeguarding/fin060_generator.py` (concrete data-builder) = 1 port + 2 domain impls. `generate_fin060`
  defined **twice** — `fin060_generator.py` (function→`Path`, PDF) vs `fin060_generator_v2.py`
  (method→`HITLProposal`); the `generate_fin060_view` in `design_pipeline` is unrelated.
- **Cross-ref (not duplicated here):** `docs/paybis-dossier/PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md:78`
  already records this pair as MERGE-PLANNED / PARKED with both live + v2's FIN060Generator+HITLProposal.

## Correction note (2026-06-28, ADR-102 legacy_otp audit on EMI `4f93870`) — legacy_otp is a BASE CLASS, not a migrate target

The earlier `legacy_otp_adapter → production/{twilio,sendgrid}` framing ("LIVE_MIGRATE_NEXT / repoint 4
consumers / provider parity", rows §1/§3/§4/§7 below) is a **MISCLASSIFICATION and SUPERSEDED**.
Verified facts (EMI `4f93870`) — this is an **inheritance hierarchy**, not a duplicate pair:
- **`LegacyOtpAdapter` (`services/auth/legacy/legacy_otp_adapter.py`) = LIVE_KEEP SHARED BASE CLASS** —
  in-memory `generate/send/verify/can_resend` (REWRITE-1), implements `OtpDeliveryPort`. It is **inherited
  by** `TwilioOtpAdapter`, `SendGridOtpAdapter`, `TwilioOtpStub`, `SendGridOtpStub`
  (`class X(LegacyOtpAdapter)`). Deleting/retiring it **breaks all production adapters + stubs** → NOT a
  migrate/retire target. (The "4 consumers" are its **subclasses**, not migration sites.)
- **`TwilioOtpAdapter` / `SendGridOtpAdapter` = PARKED production-scaffold** — built, but **NOT wired**
  (0 DI/route in `api/**`/`services/**`); **gated** on provider creds (BT-*) + an OTP-delivery route
  decision + live delivery (out of sandbox). Stubs are sandbox-only.
- **`OtpDeliveryPort` (SMS/email OTP delivery) is a SEPARATE 2FA channel** from the **wired** runtime SCA
  path `TOTPService` / `TwoFactorPort` (`two_factor.py` → `sca_service.py` → auth-router, authenticator-app
  TOTP). Two distinct channels — not duplicates.
- **Corrected status:** `legacy_otp_adapter` = **LIVE_KEEP (base class)**; Twilio/SendGrid = **PARKED**
  (creds + route gated). No code action without operator + fresh ADR-102.
- **Cross-ref (not duplicated here):** `PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md:98` (auth/legacy incl
  legacy_otp_adapter already PARKED); `docs/architecture/EMI-IMPL-STATE-REFRESH-2026-06-26.md:43,174`
  (twilio_otp_stub → OtpDeliveryPort; provider-wiring stubs creds-gated).

### Pass-1 update log (2026-06-27)
- Stream **#1 DONE** — `consumer_duty/models_v2 → models` rename (EMI #255 / `78207c0`; ruff-debt unblock EMI #257 / `36418d9`). Matrix otherwise unchanged; no new orphan deletions; remaining streams (`to_minor_units` extraction, `recon_v2`/`fin060_v2` merge-pairs, `otp`/`sepa` → production) stay OPEN.

## 1. Live / orphan matrix (24 modules — verified on eb09e9c)
| Module | Live-consumers (non-legacy) | Class |
|---|---|---|
| `api/routers/consumer_duty_v2.py` | mounted `/v1` | LIVE_KEEP |
| `api/routers/crypto_legacy.py` | mounted `/v1/crypto-legacy` | LIVE_KEEP (PAYBIS-controlled) |
| `services/_legacy_common/audit.py` | 6 | LIVE_KEEP |
| `services/_legacy_common/state_machine.py` | 4 | LIVE_KEEP |
| `services/auth/legacy/legacy_otp_adapter.py` | 4 | ⚠ CORRECTED → **LIVE_KEEP (shared BASE CLASS)** — the "4" are subclasses (Twilio/SendGrid/stubs) inheriting it, not migrate sites; Twilio/SendGrid = PARKED scaffold — see Correction note 2026-06-28 |
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
| ~~`services/payment/legacy/bifrost_adapter.py`~~ | ~~2 (`to_minor_units`)~~ | ~~LIVE_MIGRATE_NEXT~~ ⚠ **CORRECTED → PARKED** (Wave-D scaffold, MIG-M2.5-BIF / ADR-025 §15-16, advisory-sandbox, has characterization tests); the "2 (`to_minor_units`)" count was a DUPLICATE-definition mis-read, not a live dependency |
| `services/payment/legacy/legacy_transactions_adapter.py` | 2 | LIVE_KEEP |
| `services/payment/legacy/legacy_abs_payment_adapter.py` | ~~transitive via bifrost~~ ⚠ **CORRECTED → consumed BY bifrost** (`bifrost_adapter.py:19` imports `AbsPaymentStatus`); direction is bifrost→abs_payment, abs_payment is NOT transitively-live *via* bifrost | LIVE_KEEP (coupled) |
| `services/payment/legacy/legacy_sepa_adapter.py` | 1 | LIVE_MIGRATE_NEXT |
| `services/recon/reconciliation_engine_v2.py` | 4 | ⚠ CORRECTED → **CANONICAL live engine, PARKED** (v1 is legacy-cron; direction is v1→v2, not v2→v1 — see Correction note 2026-06-28) |
| `services/reporting/fin060_generator_v2.py` | 2 | ⚠ CORRECTED → **GOVERNANCE-API canonical (HITL/CFO), PARKED** (v1 = required submission engine; src/safeguarding = separate; direction v2→v1 is wrong — see Correction note 2026-06-28) |

## 2. ORPHAN_REMOVE_CANDIDATE
**NONE this pass.** (Legacy SCA/TOTP already removed in EMI #248 / `39742b7`.)

## 3. LIVE_MIGRATE_NEXT streams (target | thinnest seam | blocker)
| Module | Modern target | Thinnest seam | Blocker |
|---|---|---|---|
| ~~`reconciliation_engine_v2`~~ | ~~`recon/reconciliation_engine.py` (v1)~~ | ~~migrate 4 consumers → unify → delete v2~~ ⚠ **SUPERSEDED 2026-06-28** — direction is **v1→v2** (v2 canonical), pair **PARKED**, non-trivial; see Correction note | PARKED (ADR-102) |
| ~~`fin060_generator_v2`~~ | ~~`reporting/fin060_generator.py` (v1)~~ | ~~migrate matrix_scanner + reporting_agent → unify~~ ⚠ **SUPERSEDED 2026-06-28** — three complementary contours (v2 governance / v1 submission / src-safeguarding data); pair **PARKED**; see Correction note | PARKED (ADR-102) |
| `consumer_duty/models_v2` | rename → `models.py` | atomic rename + 12+ import update | ✅ **DONE** (EMI #255, `78207c0`; ruff-debt unblock EMI #257 / `36418d9`) |
| ~~`bifrost_adapter` (`to_minor_units`)~~ | `services/shared` money util | ~~move helper, repoint open_banking ×2~~ ⚠ **CORRECTED → DE-DUPLICATE** both copies (`bifrost:51` + `open_banking/m24_int_bridge:31`) into a shared money-util (ADR-102); open_banking already uses its own copy. bifrost stays (Wave-D scaffold); de-dup neither parks nor removes it | de-dup (ADR-102) |
| ~~`legacy_otp_adapter`~~ | ~~`auth/production/{twilio,sendgrid}_otp_adapter`~~ | ~~repoint 4 consumers~~ ⚠ **SUPERSEDED 2026-06-28** — legacy_otp is the BASE CLASS the production adapters inherit (no repoint); Twilio/SendGrid PARKED (creds/route gated) — see Correction note | PARKED (ADR-102) |
| `legacy_sepa_adapter` | `payment/production/modulr_sepa_stub` | repoint 1 consumer | Modulr live-wiring |
| `crypto_legacy` router + `ledger/legacy/legacy_crypto_*` | `PaybisCryptoAdapter` | route cutover + DI swap | **GATED on PAYBIS Wave C** (SRC-06 + ADR-114) |

## 4. Duplicates / replacements map
- **legacy ↔ current:** `legacy_otp_adapter` ↔ `production/{twilio,sendgrid}_otp_adapter` *(⚠ CORRECTED 2026-06-28: this is a base-class↔subclass **inheritance**, not a legacy↔replacement pair — see Correction note)* · `legacy_crypto_*` ↔ `PaybisCryptoAdapter` (gated) · `legacy_sepa_adapter` ↔ `production/modulr_sepa_stub` · `crypto_legacy` router ↔ future PAYBIS routes.
- **v2 ↔ current:** `reconciliation_engine_v2` ↔ `reconciliation_engine` · `fin060_generator_v2` ↔ `fin060_generator` · `models_v2` ↔ `models` *(✅ unified — rename done, EMI #255 / `78207c0`)*.
- **parked vs genuinely redundant:** `role_guard` = parked, **NOT redundant** (security invariant, no replacement proven) · `binancekyc`/`bkyc` = parked I-27 · `legacy_abs_payment`/`jwt_strategy`/`jwks_models` = parked-coupled (transitive live), not redundant. *(⚠ CORRECTED: `legacy_abs_payment` is a **dependency of** bifrost, not transitively-live via it — see Correction note; `jwt_strategy`/`jwks_models` unaffected.)*

## 5. Protected (do NOT remove)
- `role_guard` — role/status **security invariant** (3 functional tests); no replacement proven.
- `legacy_binancekyc` / `legacy_bkyc` — **I-27 KYC perimeter**; removal needs operator + MLRO/HITL-L4.
- **Coupled chains migrate as units:** `role_guard → jwt_strategy → jwks_models`; `bifrost → legacy_abs_payment` *(✓ this arrow direction is correct: bifrost depends on abs_payment — see Correction note; the matrix row L36 wording is what was fixed)*.

## 6. Bittrex / NeuroNext
**0 footprint** in `services/`/`app/` (E9 guard `banxe-no-{neuronext,bitrix}-reintroduction` active). Removal = **forward-guard** against reintroduction + PAYBIS replacement path.

## 7. Recommended next batch
- **Deletion batch: EMPTY** (smallest-safe = zero new deletions this pass).
- **Highest-value next (each its own scoped PR — ADR-102 dup-audit + full-suite green; NOT this pass):**
  1. ✅ **DONE** — `consumer_duty/models_v2 → models` rename (EMI #255 / `78207c0`; ruff-debt unblock #257 / `36418d9`).
  2. ~~extract `bifrost.to_minor_units → shared` money util (unlocks bifrost + `legacy_abs_payment` parking)~~ ⚠ **CORRECTED → DE-DUPLICATE `to_minor_units`** (bifrost:51 + open_banking/m24_int_bridge:31) into a `services/shared` money-util (ADR-102). It does NOT unlock parking — bifrost is a Wave-D scaffold (already PARKED) and `legacy_abs_payment` is its dependency, not its dependent.
  3. `reconciliation_engine_v2` / `fin060_generator_v2` merge-pairs. *(⚠ **both PARKED** — recon: direction is **v1→v2**; fin060: **three complementary contours** (v2 governance / v1 submission / src-safeguarding), not a v2→v1 merge — see the two Correction notes 2026-06-28.)*
  4. ~~`legacy_otp`~~ / `legacy_sepa` → production adapters. *(⚠ `legacy_otp` **SUPERSEDED 2026-06-28**: it is a LIVE_KEEP base class, not a migrate target; Twilio/SendGrid PARKED — see Correction note. `legacy_sepa` unaffected.)*
  5. **GATED on PAYBIS Wave C:** `crypto_legacy` router + `ledger/legacy/legacy_crypto_*` cutover.

### Refs
EMI `origin/main @ eb09e9c` (read-only `git grep`/`git ls-tree`); EMI #248 (`39742b7`, SCA/TOTP removal); PAYBIS dossier ADR-126/138, ADR-108/114; PLAN §1A E10 (consolidation track); ADR-102 (dup-audit); I-20/I-24/I-27.
