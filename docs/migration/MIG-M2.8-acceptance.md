# MIG-M2.8 — M2-cycle acceptance checkpoint (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M2.8-acceptance.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no merge. Acceptance checkpoint for the M2 backend cycle (M2.1–M2.7). -->

> **M2 core cycle (M2.1–M2.7) is closed and on `main`.** This is the docs-only acceptance checkpoint
> (analogous to MIG-M1.8 for the M1 cycle): summary, target-matrix, anti-dup ledger, the KYC/KYB/AML
> carve-out gate, the follow-up backlog, mapping-v0 corrections, and the acceptance statement. No code,
> no merge.

## 1. M2-cycle summary (M2.1–M2.7)

| Substep | Domain | Result | Backend home | Merge SHA | IL |
|---|---|---|---|---|---|
| **M2.7** | platform-core (`@banxe/*`) | **re-scope** (consume, not scaffold) | consume from `banxe-shared-libs` | `db6a8dd` | IL-373 |
| **M2.2** | accounts/balance SoT | **scaffold** (advisory, balance-free) | `banxe-emi-stack` | `fb1d431` | IL-374 |
| **M2.1** | payments engine | **scaffold** (advisory, no live exec) | `banxe-payment-core` | `09f7825` | IL-378 |
| **M2.6** | SEPA outgoing rail | **scaffold** (advisory, no live exec) | `banxe-payment-core` | `428d75c` | IL-380 |
| **M2.4** | open-banking (PSD2) | **reconcile** (already exists) | `banxe-emi-stack` | `0b70728` | IL-384 |
| **M2.5** | ABS | **reconcile** (already exists) | `banxe-emi-stack` | `4fd425d` | IL-388 |
| **M2.3** | identity/auth | **reconcile** (already exists) | `banxe-emi-stack` | `f6322b8` | IL-392 |

3 scaffolds (M2.2/M2.1/M2.6) + 3 reconciles (M2.4/M2.5/M2.3) + 1 re-scope (M2.7). Each landed as a
paired backend-PR (+ arch IL) or paired blocker+reconcile docs (arch IL), squash-merged, no `--admin`.

## 2. Resolved target-matrix

| Capability | Canonical home | Notes |
|---|---|---|
| Accounts/balance SoT | **`banxe-emi-stack`** (`api/models/account_sot.py`, advisory) | balance-free; Midaz LedgerPort = live balance SoT (ADR-013), not duplicated |
| Payments engine | **`banxe-payment-core`** (`PaymentEnginePort`) | projection over accounts SoT; idempotent; I-05 |
| SEPA outgoing rail | **`banxe-payment-core`** (`SepaRailPort`) | rail-consumer over payment engine; live Papaya/SWIFT = Wave-D |
| Platform-core (`@banxe/core`/`@banxe/common`) | **consume from `banxe-shared-libs`** (external pkgs) | NOT a target repo; `banxe-platform` = frontend |
| Open-banking (PSD2 AISP/PISP/CBPII) | **`banxe-emi-stack`** (open_banking/psd2_gateway/consent_management) | reconcile; legacy delta = port-substeps |
| ABS | **`banxe-emi-stack`** (`LegacyAbsPaymentAdapter` behind `PaymentRailPort`) | reconcile; Bifrost = Wave-D adapter |
| Identity/auth | **`banxe-emi-stack`** (auth.py + customers/lifecycle) | reconcile; canonical auth source = `banxe-auth-backend` |
| Shared contracts (`@banxe/*`, `@abs/common`, auth-connector) | **`banxe-shared-libs`** | single contract source (MIG-M2.0) |

## 3. Anti-dup ledger (ADR-102 in action)

The mandatory preflight + ADR-102 Duplication Audit **prevented 3 parallel duplicates**:

| Substep | Pre-existing surface found | Action |
|---|---|---|
| M2.4 open-banking | `open_banking.py` + `psd2_gateway.py` + `consent_management.py` (mounted/tested) | blocker → reconcile (no scaffold) |
| M2.5 ABS | `LegacyAbsPaymentAdapter` (rewrite of legacy `abs-api`, `PaymentRailPort`) | blocker → reconcile (no scaffold) |
| M2.3 identity/auth | `auth.py` + `customers.py` + `customer_lifecycle.py` + KYC carve-out (mounted) | blocker → reconcile (no scaffold) |

Plus M2.7 (target mismatch: `banxe-platform` = frontend) → re-scope. **Preflight-discipline is now
canon** (the MIG-M2.7 lesson): every M2 substep ran a read-only preflight (api/ + repo-wide
`services/`/`src/`) **before** any scaffold. Filename-collision + repo-wide-search are mandatory.

## 4. KYC/KYB/AML carve-out status (gate)

**PENDING operator/governance sign-off (I-27 HITL-L4).** The regulated layer (KYC `bkyc`/documents,
Sumsub connector(+applicant), scoring/risk-level, KYB/companies-documents, adverse-media/sanctions,
MLRO approve-EDD) is **advisory-descriptive only** in the migration — **no code written/changed without
sign-off** (CLAUDE.md never-skip-AML/KYC; I-27). Not touched in M2.1–M2.7. This is an explicit gate on
any identity/auth/KYC follow-up.

## 5. Follow-up backlog

| Item | Scope | Gate |
|---|---|---|
| **M2.4-INT** | wire open_banking PISP → PaymentEnginePort (M2.1) + accounts SoT (M2.2) projection; mount `psd2_gateway`/`consent_management` | no live initiation / no funds-confirmation vs live balances |
| **M2.4a–e** | OB delta ports: domestic-scheduled, standing-orders, file-payments, international-scheduled, CBPII consent lifecycle | ADR-102 + Quality-Gate each |
| **M2.5-BIF** | Bifrost Wave-D GCP XML adapter behind `PaymentRailPort` (ADR-025 §15-16) | advisory/sandbox; no live calls |
| **ABS delta/re-home** | abs-posting→ledger/Midaz; scoring/agreement/contract/credential/legal-entity/info-field/cron port; abs-customer→identity | per-capability |
| **M2.3 auth delta** | SRP / JWKS / api-key / scope / project / session / login-history (canonical `banxe-auth-backend`) + identity-adjacent (dictionary/crm/files) re-home | per-capability |
| **KYC/KYB/AML** | regulated carve-out work | **I-27 HITL-L4 sign-off (blocking)** |
| **M2.8 frontend** | frontend migration (banxe_auth FE etc.) | **after frontend roster audit** (banxe-platform vs banxe-ui, MIG-M2.7 deferral) |

## 6. mapping-v0 corrections (consolidated)

| Row | Previous (mapping-v0) | Corrected |
|---|---|---|
| platform-core | `→ banxe-platform` (scaffold) | **consume `@banxe/*` from `banxe-shared-libs`** (external pkgs; not a target repo) |
| `banxe-platform` | backend platform-core | **frontend Web+Mobile UI monorepo** (role pending roster audit) |
| open-banking | migrate → emi-stack (new) | **already in emi-stack** (reconcile; legacy delta = port-substeps) |
| ABS | migrate → emi-stack (new) | **already in emi-stack** (`LegacyAbsPaymentAdapter`; Bifrost Wave-D) |
| identity/auth | migrate → emi-stack (new) | **already in emi-stack** (auth + identity-core); canonical auth source `banxe-auth-backend`; auth-api + auth-variants **retire** |
| frontend (M1.7 shells) | `→ banxe-ui` | **pending frontend roster audit** (banxe-platform vs banxe-ui) |

## 7. Acceptance statement + preconditions

**M2 core (M2.1–M2.7) is ACCEPTED and on `main`** — backend homes resolved, 3 scaffolds advisory/
read-only (no live execution/balances/fund movement), 3 reconciles (no duplicates), 1 re-scope; all
ADR-102/ADR-103/ADR-059-A compliant; banxe-emi-stack/payment-core regulated surfaces untouched beyond
the advisory scaffolds; KYC/KYB/AML carve-out intact.

**Preconditions for the follow-up wave / M3:**
1. **KYC/KYB/AML carve-out** — I-27 HITL-L4 operator/governance sign-off (blocks identity/KYC follow-ups).
2. **Frontend roster audit** (banxe-platform vs banxe-ui) — precondition for M2.8.
3. **Connector contract-tests** — `@banxe/*` / `@abs/common` / auth-connector consumption verified
   against the `banxe-shared-libs` pinned baseline before INT/delta ports merge.
4. Each follow-up substep stays advisory/server-side/paired-PR/no-merge until its gate clears.

## References
`docs/migration/MIG-M2.8-acceptance.md`; M2 substep docs + IL: MIG-M2.7 (IL-373), M2.2 (IL-374), M2.1
(IL-378), M2.6 (IL-380), M2.4 (IL-381/384), M2.5 (IL-385/388), M2.3 (IL-389/392); MIG-M1.8 (M1
acceptance precedent), MIG-M2.0 (shared-libs canonical); ADR-013, ADR-025 §15-16, ADR-102, ADR-103,
ADR-059-A, I-01, I-05, I-27, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
