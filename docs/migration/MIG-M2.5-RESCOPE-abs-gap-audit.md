# MIG-M2.5 — RE-SCOPE: ABS reconcile / gap-audit (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M2.5-RESCOPE-abs-gap-audit.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. ADR-102 Duplication Audit. Resolves the MIG-M2.5 blocker (PR #627 / IL-385) per operator decision A (reconcile/gap-audit). -->

> **Resolves** the MIG-M2.5 blocker (ABS already exists in banxe-emi-stack as `LegacyAbsPaymentAdapter`;
> PR #627 / IL-385). **Operator decision (2026-06-21): A — reconcile/gap-audit** (mirror of MIG-M2.4).
> ADR-102 Duplication Audit of the legacy `abs-api` vs the existing Python ABS surface → delta +
> keep/merge/retire. **No scaffold, no code, no merge.** Audited read-only.

## 1. Re-scope rationale (anti-duplication)

Mandatory preflight found the ABS surface **already implemented** in banxe-emi-stack
(`services/payment/legacy/legacy_abs_payment_adapter.py` = `LegacyAbsPaymentAdapter`, a Python rewrite
of `abs-customer-payment.service.ts`). Scaffolding a new `AbsPort`/`AbsBifrostPort` would duplicate it
→ **ADR-102 HARD RULE: STOP, reconcile not scaffold** (same posture as MIG-M2.4 open-banking).

## 2. Legacy `abs-api` scope (canonical, per MIG-M1.2)

Legacy `banxe-fiat-backend/abs-api` (NestJS/TypeORM) — a **broad** ABS module. Services:
`abs-customer-payment`, `abs-posting`, `abs-scoring`, `abs-agreement`, `abs-customer-contract`,
`abs-credential`, `abs-legal-entity`, `abs-customer`, `abs-info-field`, `abs-process` +
`abs-cron-process`, `abs.service`, `handler-incoming-messages-from-gcp` (Bifrost inbound). Domains:
`abs`, `abs-cache`, `assets`, `common`, `config`, `files`, `messenger-notifications`, `migrations`,
`user`. `@abs/common` contract = `banxe-shared-libs/packages/abs-common` (canonical, MIG-M2.0); nested
`banxe-fiat-backend/abs-common` = mirror. Also a separate top-level `abs-api` + `vabs2` exist (legacy
variants).

## 3. Existing emi-stack ABS surface (audited)

`LegacyAbsPaymentAdapter` (`services/payment/legacy/`), REWRITE-2 of `abs-customer-payment.service.ts`:
- Implements `PaymentRailPort` (`services/payment/payment_port.py`).
- `AbsPaymentStatus` (Enum state-machine), `AbsPaymentRecord` (frozen DTO), `AbsAuditRecord`,
  `AbsApplicationError(code)`.
- `submit_payment` (← `createOrUpdateCustomerPayment`), `advance_to` (← `approveCustomerPayment`,
  `assert_valid_transition`), `get_payment_status`, `list_payments`, `collect_audit_records`.
- **Bifrost**: GCP Bifrost XML transport dropped in rewrite; **planned Wave D production adapter**
  behind `PaymentRailPort` (ADR-025 §15-16). Decimal (I-01). Tested.

**Only `abs-customer-payment` is ported** (confirmed: the sole `*abs*` module under `services/`).

## 4. Delta / gap-matrix (legacy vs emi-stack)

| Legacy abs-api capability | emi-stack | Status |
|---|---|---|
| `abs-customer-payment` (submit/approve/status) | `LegacyAbsPaymentAdapter` | **covered** |
| Bifrost transport (outbound `requestToGCPProcessing` + inbound `handler-incoming-messages-from-gcp`) | modelled, **not implemented** | **GAP → Wave D adapter** (behind `PaymentRailPort`, ADR-025 §15-16) |
| `abs-posting` (ledger postings) | — | **GAP → re-home to ledger/Midaz** (NOT a 2nd ledger; via LedgerPort) |
| `abs-scoring` (risk/credit scoring) | — | **GAP → port** (own substep) |
| `abs-agreement` / `abs-customer-contract` | — | **GAP → port** |
| `abs-credential` | — | **GAP → port** (or re-home to auth) |
| `abs-legal-entity` | — | **GAP → port** (or re-home to identity/KYB) |
| `abs-info-field` | — | **GAP → port** |
| `abs-process` / `abs-cron-process` | — | **GAP → port** (workflow/cron) |
| `abs-customer` | — | **re-home → identity/customers (M2.3)** |
| embedded `user` / `files` / `messenger-notifications` | — | **re-home → auth (M2.3) / documents / notifications** (not ABS) |

## 5. Decision (keep / merge / retire) — ADR-102

| Item | Decision | Rationale |
|---|---|---|
| `LegacyAbsPaymentAdapter` (+`PaymentRailPort`) | **KEEP — canonical operational ABS surface** | rewrite-2, tested, ADR-025-wired; MIG-M1.2 LAYERED operational layer |
| Bifrost (in/outbound) | **MERGE → Wave D adapter behind `PaymentRailPort`** | the actual remaining ABS work (ADR-025 §15-16); not a new parallel port |
| `abs-posting` | **MERGE → ledger/Midaz via LedgerPort** | postings belong to the live ledger SoT (ADR-013), not a 2nd store |
| `abs-scoring` / `abs-agreement` / `abs-customer-contract` / `abs-credential` / `abs-legal-entity` / `abs-info-field` / `abs-process`+cron | **MERGE → port additively** as per-capability substeps | only if product-required; ADR-102 + Quality-Gate each |
| `abs-customer` | **RE-HOME → identity/customers (M2.3)** | customer domain, not ABS |
| embedded `user` / `files` / `messenger-notifications` | **RE-HOME** → auth / documents / notifications | not ABS |
| Legacy `abs-api` (top-level + nested + `vabs2`) | **RETIRE after delta ported** | merge-then-retire (M1.2) |
| `@abs/common` | **KEEP canonical = `banxe-shared-libs/packages/abs-common`** (M2.0); nested mirror retire | single contract |

**Single ABS bounded context confirmed:** operational ABS = `LegacyAbsPaymentAdapter` behind
`PaymentRailPort`; Bifrost = adapter behind the same port. No second/parallel ABS port.

## 6. Integration / Bifrost recommendations

- **MIG-M2.5-BIF (Wave D)**: implement the GCP Bifrost XML adapter (outbound `requestToGCPProcessing` +
  inbound message handler) **behind `PaymentRailPort`** (ADR-025 §15-16) — advisory/sandbox first, **no
  live Bifrost calls**, operator-gated (ADR-103 PART 2).
- Where the adapter references accounts, consume the **accounts SoT (M2.2) projection** by `account_ref`
  (no balances; Midaz LedgerPort stays the live SoT, not duplicated).
- Each delta port (§4) = its own ADR-102 + Quality-Gate substep, paired PR, no merge.

## 7. Preconditions / next

- **Unblocks MIG-M2.3 (identity/auth)** — the next sequencing candidate (gate: **KYC carve-out
  sign-off**); ABS reconcile does not block it. `abs-customer` + embedded `user` re-home aligns with M2.3.
- Optional follow-ups: **MIG-M2.5-BIF** (Bifrost Wave D) + per-capability delta ports
  (scoring/agreement/contract/credential/legal-entity/info-field/process), scheduled, no merge.
- Correct the M2-sequencing note: **M2.5 = reconcile (done), not scaffold.**

## References
`docs/migration/MIG-M2.5-RESCOPE-abs-gap-audit.md`; `MIG-M2.5-BLOCKER-abs-already-exists.md` (IL-385,
PR #627); read-only legacy `banxe-fiat-backend/abs-api` (+ top-level `abs-api`, `vabs2`,
`banxe-shared-libs/packages/abs-common`) + banxe-emi-stack `services/payment/legacy/legacy_abs_payment_adapter.py`
+ `services/payment/payment_port.py`; MIG-M1.2 (ABS LAYERED), MIG-M2.0 (@abs/common canonical), MIG-M2.2
(accounts SoT), MIG-M2.4 (reconcile precedent); ADR-013 (Midaz LedgerPort), ADR-025 §15-16 (Bifrost),
ADR-102, ADR-103, ADR-059-A, I-01, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
