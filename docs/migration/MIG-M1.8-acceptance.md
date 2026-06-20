# MIG-M1.8 — M1 acceptance checkpoint (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M1.8-acceptance.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | advisory-only | No code, no merge. Consolidated acceptance of the MIG-M1.x audit cycle. -->

> **Track:** cross-context migration (MIG-M1.x) — **acceptance checkpoint** consolidating M1.1–M1.7 +
> M1.4.1. **Mode:** advisory-only; no code, no EMI-repo branches, no merges. Closes the M1 audit cycle
> and states M2 readiness conditions.

## 1. M1.x audit cycle — closed substeps

| Substep | Bounded context | IL | Decision (summary) |
|---|---|---|---|
| **M1.1** | open-banking | IL-352 | Canonical = top-level `banxe-open-banking` (PSD2 + consents + 10-entity); nested → merge-then-retire (api-keys/auth→identity, transactions→payments). |
| **M1.2** | abs-integration | IL-353 | **Layered** (not dup): nested `abs-api` = operational ABS (canonical); top-level = retained Bifrost upstream `AbsBifrostPort` adapter. |
| **M1.3** | payments + accounts | IL-359 | payments engine → payment-core; account/balance SoT (+virtual-accounts) → emi-stack; payments `accounts` = projection-over-SoT. |
| **M1.4** | identity + auth | IL-354 | identity-core → emi-stack; **KYC/KYB/AML carve-out operator-gated**; auth → platform (pipe resolved). |
| **M1.4.1** | auth duplication | IL-360 | **Historical tail**: canonical auth = `banxe-auth-backend` → platform; `banxe-auth` (auth-api) → retire. |
| **M1.5** | sepa-fiat-ops (split) | IL-362 | SEPA core + Papaya/SWIFT rails → payment-core; reporting (dwh-*) → emi-stack; embedded accounts = projection; sumsub KYC carve-out. |
| **M1.6** | platform-core + reference-data + config | IL-363 | platform-core (`@banxe/core` gql-transport + connector mesh) → platform; currencies/rates/dictionary → platform, ATM → emi-stack; config → infra. |
| **M1.7** | frontend-admin + crypto-earn | IL-364 | All 5 React FE → banxe-ui (distinct shells; admin-panel-new canonical admin); crypto-earn backend → emi-stack (advisory earn stays trading-backend). |

(Governance batch-merge records: IL-355, IL-358, IL-365.) **Ledger consistent; il_ts monotonic;
`build_ledger --check` = exit 0.**

## 2. Resolved target-matrix (one canonical EMI target per context)

| Legacy bounded context | Canonical EMI repo | transfer_mode | Key preconditions |
|---|---|---|---|
| open-banking (top-level canonical) | **banxe-emi-stack** | adapt (nested retire) | re-point `banxe-config`; re-home nested slices (M1.4/M1.3) |
| abs-integration (operational nested) | **banxe-emi-stack** | adapt (+ Bifrost adapter) | `@abs/common` + RMQ + ABS error-maps contract-tests |
| abs Bifrost upstream (top-level) | **banxe-emi-stack** (`AbsBifrostPort`) | adapt (retain adapter) | Bifrost wire contract |
| payments engine | **banxe-payment-core** | adapt | idempotency + payments-connector + RMQ contracts |
| accounts / balance SoT (+virtual-accounts) | **banxe-emi-stack** | adapt | accounts-connector; Decimal balances (I-01) |
| identity-core | **banxe-emi-stack** | adapt | identity-connector; **KYC/KYB/AML carve-out operator-gated** |
| auth (canonical `banxe-auth-backend`) | **banxe-platform** | adapt (auth-api retire) | auth-connector gRPC contract; SRP/session/token/api-key |
| sepa core + Papaya/SWIFT rails | **banxe-payment-core** | split | Papaya/SWIFT + webhook idempotency contracts |
| sepa reporting (dwh-*) | **banxe-emi-stack** | split | derived/rebuild |
| platform-core + connector mesh (+apollo/grpc-proxy) | **banxe-platform** | adapt | `gql-transport.proto` + 25 connectors + federation contracts; **migrate first** |
| reference-data: currencies/rates/dictionary | **banxe-platform** | adapt | single reference SoT; dictionary/rates connectors |
| reference-data: ATM/branch | **banxe-emi-stack** | adapt | product-facing |
| config/env (`banxe-config`) | **infra** | adapt | config-as-data only; config-over-hardcoding |
| frontends (admin/customer/auth/product) | **banxe-ui** | adapt | apollo-gateway GraphQL contract; no secrets in FE |
| crypto-earn (operational DeFi-invest) | **banxe-emi-stack** | adapt | `defi-invest-connector`; advisory earn stays trading-backend |

## 3. M2-preconditions (consolidated checklist)

- [ ] **KYC/KYB/AML carve-out** — operator/governance **sign-off** on scope (M1.4 identity + M1.5
  sumsub); excluded from default M2 scope until signed off (canon: KYC/AML deferred, never bypassed).
- [ ] **Connector + transport contract-tests** captured before any cutover: `auth-connector`,
  `identity-connector`, `payments-connector`, `accounts-connector`, `transaction-connector`,
  `cards-connector`, `tariff-connector`, `neuronex-transactions-connector`, `dictionary-connector`,
  `rates-connector`, `defi-invest-connector`, **`@abs/common`**, **RMQ patterns**,
  **`gql-transport.proto`** + **apollo federation schema**.
- [ ] **Platform-core / gateway migrates FIRST** (everything depends on `@banxe/core` + apollo-gateway).
- [ ] **Accounts SoT before payments** (account/balance SoT scaffolded before the payment engine
  consumes it as a projection).
- [ ] **No `banxe-fiat-backend` lift-and-shift** — every context migrated per bounded context.
- [ ] **No live mutation in M2** (no live execution/balances/postings/payments/fund movement) —
  scaffolds advisory/read-only first; live wiring **operator-gated** (ADR-103 PART 2).
- [ ] **I-01** — balances/amounts `Decimal`/`DecimalString` only; integer meta counts only.
- [ ] **No secrets in FE**; ProWallet self-custodial keys client-side only.
- [ ] **`banxe-shared-libs` dedup-audit** vs `banxe-core`/`banxe-common` before platform scaffold
  (avoid two platform cores).

## 4. M2-sequencing (dependency-ordered)

1. **M2.7 — platform-core + apollo-gateway → `banxe-platform`** (foundation; 133 consumers depend on
   `@banxe/core` gql-transport + connector mesh — **must be first**).
2. **M2.2 — accounts / balance SoT → `banxe-emi-stack`** (the SoT payments/sepa project over).
3. **M2.1 — payments engine → `banxe-payment-core`** (projection-consumer of the accounts SoT).
4. **M2.6 — SEPA outgoing core → `banxe-payment-core`** (payment rail; needs payments + accounts).
5. **M2.4 — open-banking → `banxe-emi-stack`** (initiates payments / reads accounts; needs 2–4).
6. **M2.5 — abs-integration → `banxe-emi-stack`** (+ Bifrost adapter; needs accounts/payments seams).
7. **M2.3 — identity / auth → `banxe-emi-stack` / `banxe-platform`** (auth via auth-connector; identity
   SoT; KYC carve-out gated). Consumed by most of the above via connectors, so its contract is pinned
   early (M2.7) but the service migration lands here.
8. **M2.8 — frontends → `banxe-ui`** (depend on the gateway GraphQL contract from M2.7; admin shell
   first).

*Rationale:* platform/gateway is the universal dependency (1st); the account SoT precedes payments (no
second balance store); rails (sepa) follow payments; open-banking/abs sit above the payment/account
seams; identity/auth contracts are pinned at the platform layer but the service migrates with its data;
frontends last (depend on the stabilised gateway schema).

## 5. CSV-v0 update recommendation (discovered services)

| Discovered service | Proposed domain | Proposed target | Note |
|---|---|---|---|
| `banxe-fiat-backend/banxe-auth-backend` | auth (canonical) | banxe-platform | M1.4.1 canonical auth |
| `banxe_auth` (underscore) | frontend-auth | banxe-ui | React FE, not a backend |
| `banxe-identity-config-manager` | config | infra/banxe-platform | config service |
| `@abs/common` (`banxe-fiat-backend/abs-common`) | abs-integration | banxe-emi-stack | ABS shared contract lib |
| `banxe-manual-payments` | frontend-admin | banxe-ui | React FE (back-office) |
| `tompayment-web` (`banxe-tompayment`) | frontend-product | banxe-ui | React FE (product) |
| `transfer_accounts` | payments/transfer | banxe-payment-core | Express transfer micro-service |
| `banxe-apollo-gateway` | platform-core | banxe-platform | GraphQL federation gateway |
| `grpc-proxy-server` | platform-core | banxe-platform | gRPC proxy |
| `banxe-shared-libs` | platform-core | banxe-platform | **dedup-audit vs `banxe-core`/`banxe-common`** (consolidated core+common) |
| `banxe-admin-panel-new` (`banxe-admin-panel`) | frontend-admin | banxe-ui | canonical admin shell |

> **Recommendation:** update `migration-mapping-v0` (the CSV matrix) with these 11 audit-discovered
> services; run a **dedup-audit for `banxe-shared-libs` vs `banxe-core`/`banxe-common`** to confirm the
> canonical platform home before MIG-M2.7.

## 6. Open governance items

- **KYC/KYB/AML carve-out sign-off** (M1.4 identity + M1.5 sumsub) — **pending operator/governance**;
  blocks the regulated slices of M2.3.
- **Operator gates:** all live execution / balances / payments / fund movement remain operator-gated
  (ADR-103 PART 2); no M2 substep performs live mutation.
- **PR status:** the consolidated MIG-M1.x governance log (**PR #607**, IL-365) is **OPEN** (awaiting
  governance-merge); this acceptance doc (MIG-M1.8) is its sibling. M1.1–M1.7 + M1.4.1 are **merged**.
- **`banxe-shared-libs` dedup-audit** — pending; precondition for MIG-M2.7 platform scaffold.

## 7. Acceptance statement

The **MIG-M1.x audit cycle (M1.1–M1.7 + M1.4.1) is CLOSED**: every legacy bounded context in
migration-mapping-v0 has a confirmed canonical EMI target (§2), the ledger is consistent
(`build_ledger --check` = exit 0) with monotonic il_ts, and no code/legacy/EMI mutation occurred (all
advisory-only, audit-only). **M1 is accepted.** **M2 may begin once the §3 preconditions are met** —
notably the KYC/KYB/AML carve-out sign-off, the connector/transport contract-tests, the
platform-core/gateway-first ordering, the accounts-SoT-before-payments ordering, and the
`banxe-shared-libs` dedup-audit. No M2 substep performs a `banxe-fiat-backend` lift-and-shift or any
live mutation (operator-gated).

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0); `docs/migration/MIG-M1.1`..`MIG-M1.7` +
`MIG-M1.4.1` (merged audits); ledger IL-352/353/354/358/359/360/362/363/364/365; ADR-102 (duplication
audit), ADR-103 (server-only + promotion gate), ADR-059-A (sharded ledger); CLAUDE.md §10/30.N+1.9
(config-over-hardcoding), I-01, I-28; MIG-M1/M2 roadmap.
