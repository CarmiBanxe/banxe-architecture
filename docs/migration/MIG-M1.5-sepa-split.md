# MIG-M1.5 — sepa-service split (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M1.5-sepa-split.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | advisory-only, audit-only reads | No code, no merge. -->

> **Track:** cross-context migration (MIG-M1.x). **Mode:** advisory-only — from **read-only** audit of
> `/tmp/bx-legacy/banxe-code/banxe`; no code, no EMI-repo branches, no merges. **CSV v0 row:**
> `sepa-service → sepa-fiat-ops → banxe-payment-core|banxe-emi-stack (split)` — *"sepa + accounts +
> transactions + swift mix"*. This audit decomposes the mix; bounded-context only, **no lift-and-shift.**

## 1. Legacy scope — `sepa-service`

- **Package:** `sepa-service` (NestJS). **REST(12) + 2 cron jobs**; **no GraphQL/gRPC**; **webhook-driven**
  (19 webhook refs) — a **SEPA rail edge integration**, not part of the gRPC connector mesh.
- **Modules (mix):** SEPA core — `sepa-accounts`, **`sepa-papaya`** (Papaya BaaS SEPA rail:
  account/auth/transaction/**loro** services), `sepa-webhooks`, **`swift`**, `emitters`, `webhooks`;
  embedded — `fiat-accounts`, `company-master-accounts`, `balance`, `fiat-payments`, `transactions`,
  `customers`, `fiat-companies`, `identity-integration`, **`sumsub-integration`**, `auth`,
  **`gcp-bifrost`** (ABS), `ai`, plus `common`/`models`/`redis`/`seeder`/`filters`/`validators`/`logger`.
- **Persistence:** **16 `@Entity`, 15 migrations.** Entities span SEPA (`sepa-account`, `sepa-customer`,
  `sepa-business-customer`), accounts (`fiat-account`, `company-master-account`), payments
  (`fiat-payments`, `transaction`, `dwh-payment`), identity (`identity-user`,
  `customer-business-details`, `user-identity-doc`, `fiat-company`, `admin-user`), and **`dwh-*`**
  warehouse/reporting (`dwh-payment`, `dwh-customer`, `dwh-contract`).
- **Flows:** SEPA `outgoing` + `inbound`; SWIFT rail; 2 cron jobs (rail file/batch processing).
- **Consumers:** **0** in the gRPC connector mesh (standalone edge); integrations are **webhook + REST**
  (no `sepa`/`papaya`/`swift` connector in `banxe-common`).

## 2. Sub-domain decomposition — clean SEPA core vs embedded

| Sub-domain | Modules / entities | Nature |
|---|---|---|
| **Clean SEPA core / rails** | `sepa-accounts`, `sepa-papaya` (Papaya rail + loro), `swift`, `emitters`, `sepa-webhooks`, outgoing/inbound, 2 cron jobs | **belongs to payments rails** |
| **Embedded accounts** | `fiat-accounts`, `company-master-accounts`, `balance`, entities `fiat-account`/`company-master-account` | **account concern → projection-over-SoT** (not a 2nd balance store) |
| **Embedded payments/tx** | `fiat-payments`, `transactions`, entities `fiat-payments`/`transaction`/`dwh-payment` | **payment engine concern** (coordinate M1.3) |
| **Embedded identity/KYC** | `identity-integration`, **`sumsub-integration`**, `customers`, `fiat-companies`, `auth`, entities `identity-user`/`customer-business-details`/`user-identity-doc`/`fiat-company` | **identity context** (M1.4); **sumsub = KYC operator-gated carve-out** |
| **Embedded ABS** | `gcp-bifrost`, bifrost (9 refs) | **ABS context** (M1.2, AbsBifrostPort / `@abs/common`) |
| **Reporting/warehouse** | `dwh-payment`/`dwh-customer`/`dwh-contract` | **compliance/reporting** (EMI-facing) |
| **AI** | `ai` | **out-of-scope flag** (not SEPA) |

## 3. Seams (sepa ↔ payments ↔ accounts(SoT) ↔ SWIFT ↔ ABS/open-banking ↔ identity)

- **sepa ↔ payments:** `fiat-payments`/`transactions` (39 transaction refs) overlap the payment engine
  (M1.3) — SEPA is a payment **rail**; status/transaction flow must stay consistent with payment-core.
- **sepa ↔ accounts (SoT):** `fiat-accounts`/`company-master-accounts`/`balance` (35 account, 6 balance
  refs) — these are **projections** over the account/balance SoT (`banxe-accounts` → emi-stack, M1.3),
  **never a second balance store**.
- **sepa ↔ SWIFT:** `swift` module (6 refs) — SWIFT rail alongside SEPA/Papaya; both → payment-core.
- **sepa ↔ ABS:** `gcp-bifrost` (9 refs) → ABS core via `@abs/common` (M1.2).
- **sepa ↔ identity/KYC:** `identity-integration`/`sumsub-integration` → identity context (M1.4) via
  `identity-connector`; sumsub KYC = operator-gated carve-out.
- **sepa ↔ open-banking:** SEPA payment initiation may be triggered via open-banking (M1.1) — preserve
  the payment-initiation contract.
- **Integration style:** **webhooks (19) + REST + cron**, not gRPC — the rail-event/webhook contract is
  the seam to preserve (no connector to re-point).

## 4. Target split

| Slice | EMI target |
|---|---|
| **SEPA core + Papaya rail + SWIFT rail** (sepa-accounts, sepa-papaya, swift, emitters, outgoing/inbound, cron) | **`banxe-payment-core`** |
| **SEPA webhooks / rail-event ingress** | **`banxe-payment-core`** (rail edge) |
| **EMI-facing compliance / reporting** (`dwh-*` warehouse, SEPA reporting) | **`banxe-emi-stack`** |
| **Embedded accounts** (fiat-accounts/company-master-accounts/balance) | **projection-over-SoT** — SoT = `banxe-accounts` → `banxe-emi-stack` (M1.3); **no 2nd balance store** |
| **Embedded payments/tx** (fiat-payments/transactions) | **`banxe-payment-core`** payment engine (coordinate M1.3) |
| **Embedded identity/KYC** (identity-integration/sumsub/customers/fiat-companies) | **identity context** → `banxe-emi-stack` (M1.4); **sumsub KYC = operator-gated carve-out** |
| **ABS** (`gcp-bifrost`) | ABS context → `banxe-emi-stack` (M1.2, AbsBifrostPort) |
| **AI** module | out-of-scope flag |

## 5. Invariants & contracts

- **Idempotency:** SEPA is **webhook + batch-file driven** (19 webhooks, 2 cron) — duplicate file/
  message/webhook delivery is expected; the migration must enforce **webhook/file idempotency
  (dedup keys)** end-to-end (no double payment/posting on re-delivery).
- **Status consistency:** SEPA transaction/payment statuses must stay consistent with payment-core +
  accounts across outgoing/inbound + SWIFT + returns; reconcile via the rail webhook contract (no
  status divergence on cutover).
- **I-01 (numeric):** balances/amounts = **`Decimal`/`DecimalString` only — never float/BigNumber**;
  account-balance integrity preserved (projection over SoT).
- **SEPA scheme conformance:** outgoing/inbound flows conform to the **Papaya SEPA rail** + SWIFT
  message contracts; rail message/format conformance pinned by contract tests before cutover.
- **Account SoT singularity:** SEPA `fiat-accounts`/`company-master-accounts` are **projections** over
  the single account SoT (`banxe-accounts`) — never a second ledger of record.
- **Operator-gated (canon):** live SEPA/SWIFT payment execution, fund movement, balance mutation are
  **out of scope** for M1/M2 advisory waves — scaffolds advisory/read-only; live rail wiring is
  operator-gated.

## 6. Risks & mitigations

| Risk | Mitigation (MIG-M2.6 / later) |
|---|---|
| Mixed monolith: 16 entities span 6 domains — high decomposition risk | Strict sub-domain decomposition (§2); migrate clean SEPA core first; embedded slices re-home to their owning contexts (M1.3/M1.4/M1.2). |
| Account SoT duplication via embedded `fiat-accounts`/`balance` | Enforce projection-over-SoT; payment-core/SEPA consumes the accounts SoT; no second balance store. |
| Webhook/file re-delivery → double processing | Idempotency keys + dedup on webhook/file ingestion; characterization tests for re-delivery. |
| KYC/AML embedded (`sumsub-integration`) migrated casually | sumsub → identity KYC **operator-gated carve-out** (M1.4); excluded from default M2 scope. |
| SEPA/SWIFT scheme regression (Papaya rail) | Contract tests for Papaya + SWIFT message formats; staged rollout; fallback to legacy rail. |
| `dwh-*` reporting coupling | Treat warehouse as derived; rebuild on EMI reporting side; no warehouse lift. |
| Regulatory: SEPA/SWIFT are P0/live payment rails | All live flows operator-gated; M2 advisory/read-only; Decimal-only balances. |
| No connector mesh seam (webhook/REST edge) | Preserve webhook/REST rail contracts (no connector to re-point); contract-test the edge. |

## 7. Preconditions for MIG-M2.6 (first clean SEPA slice)

1. This decomposition (MIG-M1.5) accepted + IL recorded.
2. **First slice = SEPA outgoing core** — `sepa-accounts` + `sepa-papaya` outgoing + `emitters` + `swift`
   outgoing → **`banxe-payment-core`**, behind the **Papaya/SWIFT rail + webhook contracts**,
   advisory/read-only first. Inbound + returns/R-message handling follow.
3. **Dependencies/contracts to capture as tests:** Papaya rail (account/auth/transaction/loro) + SWIFT
   message formats + webhook idempotency/dedup + status reconciliation + Decimal-balance invariant.
4. **Coordinate with:** M1.3 (payments/accounts SoT — accounts as projection), M1.2 (ABS gcp-bifrost via
   `@abs/common`), M1.4 (identity-connector + **sumsub KYC carve-out, operator-gated**), M1.1
   (open-banking payment initiation).
5. **No `banxe-fiat-backend`/sepa-service lift-and-shift; no live SEPA/SWIFT execution or balance
   mutation in M2** (operator-gated). Embedded accounts/identity/ABS slices re-home to their contexts,
   not folded into the SEPA migration.

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0, advisory); CSV row `sepa-service`
(`sepa-fiat-ops`, `banxe-payment-core|banxe-emi-stack`, `split`); legacy (read-only):
`/tmp/bx-legacy/banxe-code/banxe/sepa-service` (`sepa-accounts`, `sepa-papaya`, `swift`, `emitters`,
`fiat-accounts`, `company-master-accounts`, `balance`, `fiat-payments`, `transactions`,
`identity-integration`, `sumsub-integration`, `gcp-bifrost`, `dwh-*`); ADR-102, ADR-103, ADR-059-A;
I-01; MIG-M1/M2 roadmap; siblings MIG-M1.1 (open-banking), MIG-M1.2 (ABS `@abs/common`), MIG-M1.3
(payments/accounts SoT), MIG-M1.4 (identity/auth + KYC carve-out), MIG-M1.4.1 (auth canonical).
