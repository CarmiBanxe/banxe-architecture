# MIG-M1.7 — frontend-admin + crypto-earn (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M1.7-frontend-crypto-earn.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | advisory-only, audit-only reads | No code, no merge. -->

> **Track:** cross-context migration (MIG-M1.x). **Mode:** advisory-only — from **read-only** audit of
> `/tmp/bx-legacy/banxe-code/banxe`; no code, no EMI-repo branches, no merges. **CSV v0 rows:**
> `banxe-dashboard → frontend-admin → banxe-ui (adapt)`; `banxe-crypto-earn → crypto-earn →
> banxe-emi-stack (adapt)`. Consolidates the frontends discovered across MIG-M1.4/M1.3.

## 1. Legacy scope — frontends (×5, all React) + crypto-earn (backend)

| Service | package | Stack | Nature / audience |
|---|---|---|---|
| `banxe-dashboard` | `banxe-dashboard` | React 17 (FSD) | **Customer / business-banking UI** (Invoices, BusinessCards, CashAccounts, CompanyProfile, ConvertCrypto, employees) — **not admin** (CSV label imprecise) |
| `banxe-admin-panel-new` | `banxe-admin-panel` | **React 18 + Vite** (FSD) | **Internal admin / back-office** (accounts, bank-create, identities, onboarding, banners, developer-sandbox) — the **newer** admin |
| `banxe_auth` (underscore) | `banxe-auth` | React 17 (FSD) | **Auth FE** (login / 2fa / verification flows) |
| `banxe-manual-payments` | `banxe-manual-payments` | React 17 (CRA) | **Manual-payments admin FE** (back-office payment ops) |
| `tompayment-web` | `banxe-tompayment` | React 17 (FSD) | **TomPayment** product UI (largest FE — 177 GraphQL ops) |
| `banxe-crypto-earn` | `banxe-crypto-earn` | **NestJS backend** (gRPC-first: grpc 10) | **Operational crypto-earn / DeFi-invest** (modules `crypto-earn-api`/`earn`/`earn-config`/`earn-transactions`; 4 entities, 13 migrations); reached via `defi-invest-connector` |

- **All 5 frontends:** 0 entities, React, **Apollo/GraphQL-first** (gateway-consumed); no backend deps.
- **crypto-earn:** pure backend (no FE), 4 entities / 13 migrations, gRPC via `defi-invest-connector`.

## 2. Frontend consolidation vs separate

- **`banxe-dashboard` vs `banxe-admin-panel-new` are NOT duplicates** — different audiences:
  **dashboard = customer/business-banking UI**; **admin-panel-new = internal admin/back-office**.
  Keep as **distinct shells** (do not merge customer ↔ admin).
- **Internal admin consolidation:** `banxe-admin-panel-new` (React 18 + Vite, newest) = **canonical
  admin shell**; **`banxe-manual-payments`** (back-office payment ops) → **fold into the admin shell**
  as a module.
- **Customer-facing:** `banxe-dashboard` (modernise React 17 → 18) = customer shell; `tompayment-web`
  (`banxe-tompayment`) = a sizeable product UI — keep as its own product surface (or banxe-ui module).
- **Auth FE:** `banxe_auth` = login/2fa flows → fold into banxe-ui auth module (talks to the auth
  backend **only via gateway/`auth-connector`**, per MIG-M1.4.1).
- All land in **`banxe-ui`** (as distinct shells/modules), not one monolithic app.

## 3. Seams

- **frontends ↔ apollo-gateway / connector-mesh:** all FEs are **Apollo/GraphQL-first** and consume the
  **`banxe-apollo-gateway`** (platform, MIG-M1.6) over the GraphQL schema — the migration seam is the
  **gateway GraphQL contract**, not direct service calls.
- **frontends ↔ auth:** auth flows go through the **gateway / `auth-connector`** → `banxe-auth-backend`
  (MIG-M1.4.1 canonical). FE never calls auth services directly.
- **crypto-earn ↔ trading-backend earn-lane (no duplication):** the **advisory** earn surface lives in
  `banxe-trading-backend` (the M1.1–M1.26 advisory lane: `/earn/rates`, `/earn/statement`,
  `/earn/taxonomy`, `EarnMetrics`/`EarnTaxonomy` — **read-only**). Legacy `banxe-crypto-earn` is the
  **operational DeFi-invest earn backend** (earn-transactions/config, via `defi-invest-connector`).
  These are **complementary** (advisory read-only vs operational) and **must not duplicate surfaces**.
- **crypto-earn UI:** crypto-earn has **no FE**; earn-facing UI (e.g. dashboard `ConvertCrypto`) lives
  in the customer dashboard → `banxe-ui`.

## 4. Target split

| Slice | EMI target |
|---|---|
| `banxe-admin-panel-new` (canonical admin shell) + `banxe-manual-payments` (folded) | **`banxe-ui`** (admin) |
| `banxe-dashboard` (customer/business banking, modernised) | **`banxe-ui`** (customer) |
| `tompayment-web` (`banxe-tompayment` product UI) | **`banxe-ui`** (product module / separate surface) |
| `banxe_auth` (auth FE, via gateway/`auth-connector`) | **`banxe-ui`** (auth module) |
| **crypto-earn backend** (`crypto-earn-api`/`earn`/`earn-config`/`earn-transactions`) | **`banxe-emi-stack`** (operational DeFi-invest earn, via `defi-invest-connector`) |
| crypto-earn **advisory** surface (rates/taxonomy/statement) | **stays `banxe-trading-backend`** (existing advisory lane — not duplicated) |

## 5. Invariants & contracts

- **No secrets/keys in FE:** audit found **no embedded server secrets** — hits were DTO field names
  (`apiKey` query params), i18n labels, and **`banxe-dashboard` ProWallet `privateKey`** =
  **client-side self-custodial wallet keys** (user-owned, handled client-side). **Special-care:**
  ProWallet keys must remain **client-side only**, never transmitted/stored server-side; carry the
  self-custodial pattern into `banxe-ui` carefully (no server-side key custody).
- **Auth only via gateway/connector:** FE authenticates **only** through the gateway / `auth-connector`
  → `banxe-auth-backend` (MIG-M1.4.1); no direct auth-service calls, no FE-embedded auth secrets.
- **Advisory↔operational earn separation:** the `banxe-trading-backend` advisory earn-lane
  (read-only rates/taxonomy/statement) and the operational `banxe-crypto-earn` (earn-transactions)
  are **distinct surfaces** — EMI must **not duplicate** the advisory earn surface; coordinate so one
  advisory SoT (trading-backend) + one operational SoT (emi-stack) coexist without conflict.
- **Gateway GraphQL contract stability:** FE depends on the apollo-gateway GraphQL schema (MIG-M1.6);
  schema changes are contract-gated (FE breakage risk).
- **I-01:** any earn numeric (APY/yield/amounts) = `Decimal`/`DecimalString`; no float; FE displays
  only, no client-side money math beyond formatting.

## 6. Risks & mitigations

| Risk | Mitigation (MIG-M2.8 / later) |
|---|---|
| Admin FE duplication (dashboard mis-labelled "admin" vs admin-panel-new) | Audit clarifies: dashboard = customer, admin-panel-new = admin; keep distinct shells; consolidate only true admin (admin-panel-new + manual-payments). |
| crypto-earn EMI ↔ trading-backend advisory earn desync | One advisory SoT (trading-backend) + one operational SoT (emi-stack); contract-test both surfaces; no duplicate `/earn/*` advisory endpoints in EMI. |
| Breaking the apollo-gateway GraphQL contract (all 5 FEs) | Migrate platform-core/gateway first (MIG-M1.6/M2.7); pin gateway schema as contract tests before FE migration. |
| ProWallet self-custodial private keys mishandled | Keep client-side only; never server-custody; security review of the key-handling path on migration. |
| React 17 → 18 / Vite migration churn | Modernise per-shell; admin-panel-new (already React18+Vite) as the template. |
| `banxe_auth` (FE) confused with auth backends (MIG-M1.4.1) | Explicitly FE → banxe-ui; backend auth = `banxe-auth-backend` → platform (separate track). |
| CSV-v0 incompleteness (4 extra frontends discovered) | Recorded; recommend mapping-v0 update (admin-panel-new, banxe_auth, manual-payments, tompayment). |

## 7. Preconditions for MIG-M2.8 (first frontend slice)

1. This audit (MIG-M1.7) accepted + IL recorded.
2. **First FE slice = unified admin shell** — `banxe-admin-panel-new` (canonical, React18+Vite) →
   `banxe-ui`, behind the **apollo-gateway GraphQL contract**, advisory/read-only first; fold
   `banxe-manual-payments` next. Customer dashboard + tompayment follow.
3. **Platform/gateway first:** depends on MIG-M2.7 (platform-core + apollo-gateway) — the gateway
   GraphQL contract must be captured as tests before FE migration.
4. **crypto-earn backend boundary:** operational earn → `banxe-emi-stack` via `defi-invest-connector`;
   the trading-backend advisory earn-lane stays untouched (no surface duplication).
5. **No secrets in FE; ProWallet keys client-side; auth only via gateway/`auth-connector`.**
6. **No lift-and-shift; no live mutation in M2** (operator-gated); FE migrated per shell behind
   gateway contracts.

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0, advisory); CSV rows `banxe-dashboard`
(frontend-admin, banxe-ui) + `banxe-crypto-earn` (crypto-earn, banxe-emi-stack); legacy (read-only):
`banxe-dashboard`, `banxe-admin-panel-new` (`banxe-admin-panel`), `banxe_auth`, `banxe-manual-payments`,
`tompayment-web` (`banxe-tompayment`), `banxe-crypto-earn` (`crypto-earn-api`/`earn`/`earn-config`/
`earn-transactions`); `banxe-apollo-gateway` + `banxe-common/defi-invest-connector` + `auth-connector`;
ADR-102, ADR-103, ADR-059-A; I-01; MIG-M1/M2 roadmap; siblings MIG-M1.4.1 (auth canonical), MIG-M1.6
(platform/gateway); `banxe-trading-backend` advisory earn-lane (M1.1–M1.26).
