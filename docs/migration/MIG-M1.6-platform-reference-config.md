# MIG-M1.6 — platform-core + reference-data + config (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M1.6-platform-reference-config.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | advisory-only, audit-only reads | No code, no merge. -->

> **Track:** cross-context migration (MIG-M1.x). **Mode:** advisory-only — from **read-only** audit of
> `/tmp/bx-legacy/banxe-code/banxe`; no code, no EMI-repo branches, no merges. **CSV v0 rows:**
> `banxe-core → platform-core → banxe-platform|banxe-emi-stack (adapt)`; `banxe-system →
> reference-data-system → banxe-platform|banxe-emi-stack (adapt)`; `banxe-config → config →
> banxe-platform|infra (adapt, config/env only not product logic)`.

## 1. Legacy scope ×3

### A. `banxe-core` (`@banxe/core`) — platform-core library
- **Form:** npm **library package** (`lib/`, not a service) — the **platform foundation**.
- **lib pieces:** `constants`, `discovery` + `discovery-events`, `graphql`, **`graphql-connectors`**,
  `grpc` (**`protos/gql-transport.proto`** — the graphql-through-grpc transport), `shared`, `index.ts`.
- **Signals:** connector(35), graphql(26), grpc(25), proto(4) — owns the **GraphQL↔gRPC transport** +
  connector base + service discovery + shared platform utils.
- **Consumers: 133** — the single most-depended-on package (every domain service builds on it).

### B. `banxe-system` (`banxe-system`) — reference-data service
- **Form:** NestJS service (GraphQL). Modules: **`currencies`** (graphql), **`atm`**
  (resolver/service/entities/graphql), `config`, `shared`. **3 `@Entity`.**
- **Access:** via `banxe-common` **`dictionary-connector`** + **`rates-connector`**.
- **Role:** reference-data SoT — currencies / FX rates / dictionary + ATM/branch locator.

### C. `banxe-config` (`banxe-config`) — config/env (infra)
- **Form:** **pure config-as-data** — `stable/` + `stage/` (`fiat-config.json`, `gateway-config.json`,
  `rabbitmq-config.json`) + `update-pm2.js` (ops script). **No `src/`, 0 product TS logic.**
- **Confirmed:** **config/env only, NOT product logic** (matches CSV note).

## 2. Classification — platform vs reference-data vs infra-config

| Bucket | Components | Nature |
|---|---|---|
| **Platform-core** | `@banxe/core` (gql-transport proto, graphql-connectors, grpc, discovery, shared) + `banxe-common` (25 domain connectors) + **discovered:** `banxe-apollo-gateway` (GraphQL federation), `grpc-proxy-server`, `banxe-shared-libs` (packages/core+common — consolidated home) | **platform foundation / connector mesh** |
| **Reference-data** | `banxe-system` — currencies / FX rates / dictionary (cross-cutting) + ATM/branch locator (product-facing) | **shared reference data** |
| **Infra-config** | `banxe-config` — `fiat`/`gateway`/`rabbitmq` config JSON, pm2 | **infra config-as-data (not product)** |

> **Discovered (NOT in CSV v0, flagged):** `banxe-apollo-gateway`, `grpc-proxy-server`,
> `banxe-shared-libs` (a monorepo with `packages/core` + `packages/common` that mirrors
> `@banxe/core` + `banxe-common` — likely the consolidated/newer platform home). Recommend mapping-v0
> update; confirm whether `banxe-shared-libs` supersedes `banxe-core`/`banxe-common`.

## 3. Seams — connector-mesh as the platform layer

- **`@banxe/core` is the platform contract owner:** `gql-transport.proto` + `graphql-connectors` base;
  the `banxe-common` **25 connectors** (auth/identity/accounts/payments/transaction/cards/tariff/
  sumsub/companies/dictionary/rates/…) are built **on top of** it. The connector mesh **is** the
  platform integration layer every domain (payments/accounts/identity/abs/open-banking/sepa) depends on.
- **Reference-data seam:** domains reach currencies/rates/dictionary via `dictionary-connector` +
  `rates-connector` → `banxe-system`. Currencies/FX are **cross-cutting reference** consumed by
  payments/accounts/sepa/abs.
- **Config seam:** `banxe-config` JSON (gateway/rabbitmq/fiat) is consumed at **deploy/runtime** by
  services + the gateway — infra wiring, not a code dependency (0 code consumers).
- **Highest blast radius:** `@banxe/core` (133 consumers) + the connector mesh — any contract change
  ripples across every domain. This is the **most contract-sensitive** migration.

## 4. Target split

| Slice | EMI target |
|---|---|
| **Platform-core** (`@banxe/core`: gql-transport, graphql-connectors, grpc, discovery, shared) | **`banxe-platform`** |
| **Connector mesh** (`banxe-common` 25 connectors) | **`banxe-platform`** (platform integration layer) |
| **GraphQL federation / proxy** (`banxe-apollo-gateway`, `grpc-proxy-server`) | **`banxe-platform`** (flag — confirm vs `banxe-shared-libs`) |
| **Reference-data: currencies / FX rates / dictionary** | **`banxe-platform`** (cross-cutting shared reference SoT; CSV `platform\|emi-stack` → **platform**) |
| **Reference-data: ATM / branch locator** | **`banxe-emi-stack`** (EMI product-facing feature) |
| **Config / env** (`banxe-config`) | **infra** (config-as-data; deployment/infra, **not a product repo, not product logic**) |
| **`banxe-shared-libs`** (consolidated core+common) | flag — likely the platform home; reconcile with `@banxe/core`/`banxe-common` |

## 5. Invariants & contracts

- **Config-over-hardcoding (CLAUDE.md 30.N+1.9):** all thresholds/limits/retention/env stay
  **config-as-data** (`banxe-config` → infra); **no product logic in config**, **no hardcoded values
  in code**. `banxe-config` migrates as **infra config**, never as a product module.
- **Single reference-data SoT:** exactly **one** currencies / FX-rates / dictionary source
  (`banxe-system` → platform), consumed via `dictionary-connector`/`rates-connector` — **no duplicate
  currency tables per domain** (payments/accounts/sepa must reference, not copy).
- **Connector-mesh contract stability (highest priority):** `gql-transport.proto`, the
  `graphql-connectors` base, the 25 domain connectors, and the apollo federation schema are **stable
  contracts** — pinned by contract tests; **no breaking change** (133 `@banxe/core` consumers).
- **gRPC/GraphQL transport invariant:** the GraphQL↔gRPC transport semantics (`@banxe/core`) preserved
  exactly; connector signatures stable across the migration.
- **Operator-gated (canon):** platform/reference changes that could alter prod state or client funds
  are operator-gated; M2 scaffolds advisory/read-only first.

## 6. Risks & mitigations

| Risk | Mitigation (MIG-M2.7 / later) |
|---|---|
| Product logic leaking into `banxe-config` during migration | Keep `banxe-config` strictly config-as-data → infra; lint/review gate that no TS product logic enters; config-over-hardcoding canon. |
| Reference-data duplication (per-domain currency tables) | Single currencies/rates SoT (platform) behind `dictionary`/`rates` connectors; forbid domain-local currency copies. |
| Breaking the connector mesh / `gql-transport` contract (133 consumers) | Migrate platform-core **first**, behind the **same** `gql-transport.proto` + connector contracts; comprehensive contract tests before any domain migration. |
| `banxe-shared-libs` vs `banxe-core`/`banxe-common` divergence | Confirm canonical platform home (likely shared-libs); dedup-audit before platform scaffold; avoid two platform cores. |
| ATM vs currencies mis-homed | currencies/rates → platform (shared); ATM/branch → emi-stack (product) — explicit split. |
| Apollo federation / gRPC proxy coupling | Treat as platform edge; contract-test the federation schema + gQL transport before cutover. |

## 7. Preconditions for MIG-M2.7 (first platform/reference slice)

1. This audit (MIG-M1.6) accepted + IL recorded.
2. **First slice = platform-core transport/connector base** (`@banxe/core` gql-transport +
   `graphql-connectors` base) → **`banxe-platform`**, behind the **same `gql-transport.proto` +
   connector contracts**, advisory/read-only — **everything depends on it, so it migrates first.**
3. **Then reference-data currencies/rates/dictionary** (`banxe-system` → platform) behind
   `dictionary`/`rates` connectors; ATM/branch → emi-stack.
4. **`banxe-config` → infra config-as-data** (not a product migration; config-over-hardcoding).
5. **Resolve `banxe-shared-libs` canonical-platform question** (dedup-audit) before scaffolding to
   avoid two platform cores.
6. **Contracts to capture as tests:** `gql-transport.proto`, the 25 connectors, apollo federation
   schema, `dictionary`/`rates` connectors, currency reference shape.
7. **No lift-and-shift; config = infra-only; no live/prod-state mutation in M2** (operator-gated).

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0, advisory); CSV rows `banxe-core`
(platform-core, banxe-platform|banxe-emi-stack) + `banxe-system` (reference-data-system, banxe-platform|
banxe-emi-stack) + `banxe-config` (config, banxe-platform|infra); legacy (read-only):
`banxe-core` (`@banxe/core` `lib/grpc/protos/gql-transport.proto`, `graphql-connectors`),
`banxe-common` (25 connectors), `banxe-system` (currencies/atm), `banxe-config` (stable/stage config),
`banxe-apollo-gateway` + `grpc-proxy-server` + `banxe-shared-libs` (discovered); ADR-102, ADR-103,
ADR-059-A; CLAUDE.md §10/30.N+1.9 (config-over-hardcoding); MIG-M1/M2 roadmap; siblings MIG-M1.1–M1.5.
