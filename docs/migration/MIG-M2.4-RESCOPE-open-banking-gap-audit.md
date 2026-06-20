# MIG-M2.4 — RE-SCOPE: open-banking reconcile / gap-audit (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M2.4-RESCOPE-open-banking-gap-audit.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. ADR-102 Duplication Audit. Resolves the MIG-M2.4 blocker (PR #624 / IL-381) per operator decision A (reconcile/gap-audit). Supersedes the lighter reconcile note (same branch) with the deep audit. -->

> **Resolves** the MIG-M2.4 blocker (PSD2 open-banking already exists in banxe-emi-stack; PR #624 /
> IL-381). **Operator decision (2026-06-21): A — reconcile/gap-audit.** ADR-102 Duplication Audit of
> the legacy canonical `banxe-open-banking` **vs** the existing emi-stack surface, with mock-vs-live,
> mount/registration, M2.1/M2.2 wiring, consumers, and FCA-wiring status. **No scaffold, no code, no
> merge.** Audit performed read-only on origin/main `1a90a41`.

## 1. Re-scope rationale (anti-duplication)

Read-only preflight found an **existing, FCA-wired PSD2 surface** in banxe-emi-stack. Scaffolding a new
`open_banking` model/router/port would **collide on the `open_banking.py` filename** and duplicate a
more mature surface — forbidden by the **ADR-102 HARD RULE** (no new structure without repo-wide
duplication verification; fail-closed). Therefore MIG-M2.4 is **reconcile, not scaffold** (same
anti-dup posture as the MIG-M2.7 blocker → re-scope).

## 2. Legacy canonical scope (per MIG-M1.1)

Top-level `banxe-open-banking` (NestJS/TypeORM, full OBIE/PSD2 read+write) — controllers:
`account-access-consents`, `accounts` (+`/balances`, `/transactions`), `domestic-payment-consents` +
`domestic-payments`, `domestic-scheduled`, `standing-order`, `file-payment-consents` + `file-payments`,
`funds-confirmation-consents` + `funds-confirmations`, `international-payment-consents` +
`international-payments`, `international-scheduled-payment-consents` + `international-scheduled-payments`.
Domains: `accounts`, `domestic`, `file`, `funds-confirmations`, `international`. Nested
`banxe-fiat-backend/banxe-open-banking` = duplicate mirror.

## 3. Existing emi-stack surface (audited on origin/main `1a90a41`)

| Router | Lines | Mounted? (main.py) | Mock vs live | FCA wiring (HITL) | M2.1/M2.2 wiring |
|---|---|---|---|---|---|
| `api/routers/open_banking.py` (IL-OBK-01) | 224 | **import ✓ + include_router ✓ (MOUNTED)** | PISP `/payments/{id}/status` = **mock**; 3 live-client refs | HITL ×1 | **none (0)** |
| `api/routers/psd2_gateway.py` (IL-PSD2GW-01, adorsys XS2A) | 197 | **import ✓ but include_router ✗ (NOT mounted)** | live adorsys XS2A; `BalanceResponseSchema.balance_amount: str` (DecimalString I-01) | HITL ×5 | **none (0)** |
| `api/routers/consent_management.py` (IL-CNS-01) | 379 | **import ✓ but include_router ✗ (NOT mounted)** | live (7 client refs) | HITL ×10 | **none (0)** |

Models: no dedicated `open_banking`/`psd2`/`consent` model module — inline schemas + `api/models/payments.py`.
**Consumers:** `open_banking` mounted in `api/main.py`; `psd2_gateway` + `consent_management` have
extensive test suites (`tests/test_psd2_gateway/*`, `tests/test_consent_management/*`) but are **not
mounted** into the app.

## 4. Delta / gap-matrix

| OBIE capability | Legacy | emi-stack | Gap |
|---|---|---|---|
| Account-access consents (AISP) | yes | open_banking (mounted) + consent_management (unmounted) | **covered** (consent_management richer but unmounted) |
| Accounts + balances + transactions | yes | open_banking `/accounts` (mounted) + psd2_gateway balances/transactions (**unmounted**) | **partial** — psd2 detail not exposed |
| Domestic payments + consents | yes | open_banking `/payments` (mock status) | **partial** — initiation mock, no engine wiring |
| Domestic **scheduled** payments (+consents) | yes | — | **GAP → port** |
| **Standing orders** | yes | — | **GAP → port** |
| **File (bulk/batch) payments** (+consents) | yes | — | **GAP → port** |
| **International scheduled** payments (+consents) | yes | — | **GAP → port** |
| International payments — per-consent funds-confirmation | yes | generic `/payments` only | **partial GAP → port** |
| **CBPII funds-confirmation consent lifecycle** | yes | consent_management `/cbpii/check` (unmounted) | **partial** — check only, unmounted |
| **account_ref projection vs own logic** | own entities | own inline logic | **NOT wired** to accounts SoT (M2.2) — 0 refs |
| **PaymentEnginePort (M2.1) wiring** | n/a | **0 refs** | **NOT wired** — PISP uses mock/own |
| TPP registry / HITL gating / adorsys XS2A | partial | yes (HITL ×16 total) | emi-stack-only (keep) |

**Mock vs live summary:** open_banking PISP status is **mock**; psd2_gateway + consent_management are
live-wired (adorsys XS2A) but **not mounted**; **none consume M2.1/M2.2** (no accounts-SoT projection,
no PaymentEnginePort) — they use their own/inline logic.

## 5. Decision (keep / merge / retire) — ADR-102

| Item | Decision | Rationale |
|---|---|---|
| emi-stack `open_banking` + `psd2_gateway` + `consent_management` | **KEEP — canonical open-banking bounded context (home)** | FCA-wired (HITL, I-01, adorsys XS2A); tested; single home confirmed |
| Mount gap (`psd2_gateway`/`consent_management` not in app) | **REVIEW/MOUNT** (own substep) | present + tested but unmounted — decide expose vs intentional |
| Legacy delta (domestic-scheduled, standing-orders, file-payments, international-scheduled, intl funds-confirmation, CBPII lifecycle) | **MERGE — port additively** as per-capability HITL-gated substeps (consume M2.1/M2.2) | not a parallel scaffold |
| Legacy top-level `banxe-open-banking` | **RETIRE after delta ported** (merge-then-retire, M1.1) | |
| Legacy nested `fiat-backend/banxe-open-banking` | **RETIRE (duplicate)** | mirror |
| Three emi-stack PSD2 routers | **CONSOLIDATE** (separate governance-gated substep) | pre-existing internal overlap |

**Single open-banking bounded context = banxe-emi-stack (confirmed).** No second/parallel surface.

## 6. Integration recommendations (MIG-M2.4-INT, optional follow-up)

A dedicated **integration-only** substep (no new scaffold) is recommended where the existing surface
uses mock/own logic:
- Wire PISP initiation (`open_banking /payments`) to **PaymentEnginePort (M2.1)** instead of the mock
  status; wire account reads to the **accounts SoT (M2.2) projection** by `account_ref`.
- Mount `psd2_gateway` / `consent_management` if exposure is intended (decide per §5).
- **Constraint:** no live payment initiation/execution and **no funds-confirmation against live
  balances** in the advisory path — funds-confirmation stays descriptive/sandbox; live execution stays
  operator-gated (ADR-103 PART 2). Each item ADR-102 + Quality-Gate, paired PR, no merge.

## 7. Preconditions / next

- **Unblocks MIG-M2.5 (ABS)** — LAYERED (nested operational → emi-stack canonical + top-level Bifrost
  `AbsBifrostPort` adapter, per MIG-M1.2): no dependency on the open-banking delta ports.
- **Optional MIG-M2.4-INT** (integration-only, §6) + per-capability delta ports (M2.4a domestic-
  scheduled, M2.4b standing-orders, M2.4c file-payments, M2.4d international-scheduled, M2.4e CBPII
  lifecycle) — scheduled, HITL-gated, no merge.
- Correct the M2-sequencing note: **M2.4 = reconcile (done), not scaffold.**

## References
`docs/migration/MIG-M2.4-RESCOPE-open-banking-gap-audit.md`; `MIG-M2.4-BLOCKER-open-banking-already-exists.md`
(IL-381, PR #624); read-only origin/main `1a90a41` banxe-emi-stack `api/routers/{open_banking,psd2_gateway,consent_management}.py`
+ `api/main.py` + `api/models/payments.py` + `tests/test_{psd2_gateway,consent_management}/*`; legacy
`banxe-open-banking` (top-level + nested); MIG-M1.1, MIG-M2.1 (payment engine), MIG-M2.2 (accounts SoT);
ADR-102, ADR-103, ADR-059-A, I-01, I-02, I-27, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
