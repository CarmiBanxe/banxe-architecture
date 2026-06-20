# MIG-M1.3 — payments + accounts domain boundary (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M1.3-payments-accounts-boundary.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | advisory-only, audit-only reads | No code, no merge. -->

> **Track:** cross-context migration (MIG-M1.x). **Mode:** advisory-only — from **read-only** audit of
> `/tmp/bx-legacy/banxe-code/banxe`; no code, no EMI-repo branches, no merges. **CSV v0 rows in
> scope:** `banxe-fiat-backend/banxe-payments → payments → banxe-payment-core|banxe-emi-stack (adapt)`;
> `banxe-fiat-backend/banxe-accounts → accounts → banxe-emi-stack (adapt)`. Bounded-context only —
> **no `banxe-fiat-backend` lift-and-shift.**

## 1. Legacy scope — payments

- **`banxe-fiat-backend/banxe-payments`** (package **`payments-api`**) — **the main payment engine.**
  - **Modules:** `payments` (dtos/entities/graphql/**resolvers**/services + **`payments.consumer.ts`**
    RMQ + `payments.controller.ts` REST), `checkout` (card/checkout integration), `contomobile`
    (Contomobile BaaS partner), `currencies`, `accounts` (payment-side **projection**, not the SoT),
    `cache-manager`, `templates`, `messenger-notifications`, `migrations`, `version`.
  - **Persistence:** **12 `@Entity`, 52 migrations** — heavy, data-owning (payments, statuses, refs).
  - **Integrations (in-code seams):** **SWIFT (36 refs)**, **identity (15)**, **ABS (9)**, **SEPA (3)** —
    payments is the deeply-wired hub (SWIFT/SEPA rails + ABS core + identity).
- **Discovered (NOT in CSV v0):** `banxe-manual-payments` (package `banxe-manual-payments`) =
  **frontend** (React) → `banxe-ui` track; `tompayment-web` (`banxe-tompayment`) = **frontend**
  (React/FSD) → `banxe-ui`; `transfer_accounts` (`transfer_accounts`) = **backend** transfer
  micro-service (Express controllers/routes/services) → flag for the payments/transfer domain.

## 2. Legacy scope — accounts

- **`banxe-fiat-backend/banxe-accounts`** (package **`accounts-api`**) — **account / balance bounded
  context.**
  - **Modules:** `accounts` (dtos/entities/enums/graphql/inputs/**resolvers** + `accounts.service.ts`
    + **`virtual-accounts.service.ts`** + `accounts.consumer.ts` RMQ + `accounts.controller.ts`),
    `intermediaries` (intermediary banks), `assets`, `currencies`, `users`, `files`, `contomobile`,
    `messenger-notifications`, `migrations`, `version`.
  - **Persistence:** **10 `@Entity`, 19 migrations** — data-owning (accounts, balances, virtual
    accounts, intermediaries).
  - **Role:** the **canonical account/balance SoT** (incl. **virtual accounts** + intermediary-bank
    routing). The `accounts` module inside `banxe-payments` is a **payment-side projection** of this —
    **not** a second account SoT.

## 3. Overlap & seams (payments ↔ accounts ↔ open-banking ↔ ABS ↔ identity/auth ↔ SEPA)

- **payments ↔ accounts:** payments holds a payment-side `accounts` projection; the **account/balance
  SoT is `banxe-accounts`**. Overlap must be resolved as **projection (payments) over SoT
  (accounts)** — not duplicated.
- **payments ↔ SEPA/SWIFT:** 36 SWIFT + 3 SEPA refs in payments → payment **rails**; SEPA decomposition
  handled in **MIG-M1.5** (`sepa-service` split) and must stay coordinated with the payment engine.
- **payments ↔ ABS:** 9 ABS refs → payments calls the ABS core via **`@abs/common` + RMQ** (per
  MIG-M1.2); preserve those contracts.
- **payments ↔ identity:** 15 identity refs → payments resolves customer/KYC context via the
  **identity-connector** (per MIG-M1.4); identity remains its own SoT.
- **payments/accounts ↔ open-banking:** open-banking (MIG-M1.1) initiates payments / reads accounts via
  the payment/account contracts — re-point at MIG-M2.4.
- **gRPC connector seam (`banxe-common`):** `payments-connector`, `accounts-connector`,
  `transaction-connector`, `cards-connector`, `tariff-connector`, `neuronex-transactions-connector`
  (NB: per parallel ADR-108 the Neuronext→Paybis transaction path is in flux) — **all must be
  preserved as contracts.**

## 4. EMI vs payment-core vs platform — target split

| Slice | Legacy source | EMI target |
|---|---|---|
| **Payment engine** (payments core, statuses, RMQ consumer, checkout, payment rails) | `banxe-payments` | **`banxe-payment-core`** (CSV `payment-core\|emi-stack` → **payment-core**) |
| **Account / balance SoT** (accounts core, **virtual-accounts**, intermediaries) | `banxe-accounts` | **`banxe-emi-stack`** (CSV confirmed) |
| **Payment-side account projection** | `banxe-payments/src/accounts` | **`banxe-payment-core`** as a *read projection* over the accounts SoT — **not** a second account store |
| **Currencies / reference data** (shared) | both `currencies` | coordinate with **reference-data** (MIG-M1.6 `banxe-system` → platform); don't duplicate |
| **SWIFT/SEPA rails** | payments + `sepa-service` | **`banxe-payment-core`** (SEPA split per MIG-M1.5) |
| **Card/checkout** | `banxe-payments/src/checkout` | `banxe-payment-core` (payment-adjacent) |
| **Frontends** (`banxe-manual-payments`, `tompayment-web`) | discovered | **`banxe-ui`** track (not payments backend) |
| **`transfer_accounts`** (transfer micro-service) | discovered | flag → evaluate as a payment-core transfer adapter |

## 5. Invariants & contracts

- **I-01 (numeric):** balances / amounts = **`Decimal`/`DecimalString` only — never float/BigNumber**.
  Account-balance integrity (incl. virtual-accounts) is a hard invariant on migration.
- **Transaction idempotency:** payments shows idempotency handling (`idempoten*` refs) — the
  **idempotency-key contract** must be preserved end-to-end (payment-core).
- **Status consistency across rails:** payment/transaction statuses must stay consistent across
  **SEPA / SWIFT / ABS / open-banking** — driven by RMQ consumers (`payments.consumer`,
  `accounts.consumer`) + `transaction-connector`. No status divergence on cutover.
- **Account SoT singularity:** exactly **one** account/balance SoT (`banxe-accounts` → emi-stack);
  payment-side `accounts` is a **projection**, never a second ledger of record.
- **Connector/RMQ contract preservation:** `payments-connector`/`accounts-connector`/
  `transaction-connector`/`cards-connector`/`tariff-connector` gRPC + RMQ patterns pinned by contract
  tests before any cutover.
- **Operator-gated (canon):** live payments / fund movement / balance mutation are **out of scope**
  for M1/M2 advisory waves — scaffolds are advisory/read-only first; live wiring is operator-gated.

## 6. Dependencies & risks

| Risk | Mitigation (MIG-M2.x / later) |
|---|---|
| Deep embedding: payments wired to SWIFT(36)/identity(15)/ABS(9)/SEPA(3) — high blast radius | Migrate behind preserved gRPC + RMQ contracts; contract tests per seam; sequence after MIG-M1.5 (SEPA) coordination. |
| Account SoT duplication (payments' own `accounts` module) | Enforce projection-over-SoT; payment-core consumes accounts via `accounts-connector`, no second balance store. |
| Transaction path in flux (Neuronext→Paybis per ADR-108) | Align `transaction-connector`/`neuronex-transactions-connector` migration with ADR-108; re-confirm at MIG-M2.1 scaffold. |
| 52 payment migrations / 19 account migrations — schema-heavy | No DB lift-and-shift; EMI re-models schema; characterization tests pin behaviour, not schema. |
| Regulatory: payments + balances + SWIFT/SEPA are P0/live | All live flows operator-gated; M2 scaffolds advisory/read-only; balances `Decimal`-only (I-01). |
| Frontends mis-filed into payments backend | `banxe-manual-payments` + `tompayment-web` → `banxe-ui`; `transfer_accounts` flagged separately. |
| CSV v0 incompleteness (3 discovered services) | Recorded; recommend mapping-v0 update. |

## 7. Preconditions for MIG-M2.x (first payments/accounts slices)

1. This boundary audit (MIG-M1.3) accepted + IL recorded.
2. **Accounts before payments:** scaffold the **account/balance SoT** (`banxe-emi-stack`, incl.
   virtual-accounts) **first** (MIG-M2.2), behind `accounts-connector` contract — advisory/read-only.
3. Then **payment engine** (`banxe-payment-core`, MIG-M2.1) as a **projection-consumer** of the
   accounts SoT, behind `payments-connector` + RMQ + idempotency contracts — advisory/read-only.
4. Coordinate with MIG-M1.5 (SEPA), MIG-M1.2 (ABS `@abs/common`), MIG-M1.4 (identity-connector),
   MIG-M1.1 (open-banking) before any live rail wiring.
5. Capture contract tests: `payments-connector`/`accounts-connector`/`transaction-connector` gRPC +
   RMQ patterns + idempotency-key + balance `Decimal` invariants.
6. **No `banxe-fiat-backend` lift-and-shift; no live payment/balance mutation in M2** (operator-gated).

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0, advisory); CSV rows `banxe-fiat-backend/
banxe-payments` (payments, banxe-payment-core|banxe-emi-stack) + `banxe-fiat-backend/banxe-accounts`
(accounts, banxe-emi-stack); legacy (read-only): `banxe-fiat-backend/banxe-payments`,
`banxe-fiat-backend/banxe-accounts`, `banxe-manual-payments` (frontend, discovered),
`tompayment-web` (frontend, discovered), `transfer_accounts` (backend, discovered),
`banxe-common/lib/graphql-through-grpc-connectors/{payments,accounts,transaction,cards,tariff,neuronex-transactions}-connector`;
ADR-102, ADR-103, ADR-059-A, ADR-108 (Neuronext→Paybis); I-01; MIG-M1/M2 roadmap; siblings MIG-M1.1/
M1.2/M1.4; MIG-M1.5 (SEPA, pending).
