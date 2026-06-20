# MIG-M1.2 — abs-integration duplication audit (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M1.2-abs-dup-audit.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | ADR-102 | advisory-only, audit-only reads | No code, no merge. -->

> **Track:** cross-context migration (MIG-M1.x). **Mode:** advisory-only — from **read-only** audit of
> `/tmp/bx-legacy/banxe-code/banxe`; no code, no EMI-repo branches, no merges. **CSV v0 rows in
> scope:** `abs-api` + `banxe-fiat-backend/abs-api` → `abs-integration → banxe-emi-stack (dup-audit)`.
> **Audit conclusion up front:** the two services are **layered, not a true duplicate** — see §3/§5.

## 1. Legacy scope — `abs-api` (top-level)

- **Package:** `abs-api`. NestJS boilerplate-scaffolded (README = "Banxe NestJS boilerplate").
- **Modules:** `bifrost-api`, `bifrost-api-client`, `config`, `shared`, `app.module.ts`, `main.ts`.
- **Role:** a **thin upstream client/adapter to the external "Bifrost" ABS core** (Agency/Account
  Banking System). `bifrost-api` + `bifrost-api-client` = request/response wrapper around the external
  Bifrost API.
- **Persistence:** **0 `@Entity`, 0 migrations** — **stateless integration layer** (no owned data).
- **Dependencies:** external Bifrost core; standalone NestJS app.

## 2. Legacy scope — `banxe-fiat-backend/abs-api` (nested)

- **Package:** `abs-api` (same name, different service). NestJS.
- **Modules:** `abs` (full domain: `dtos`/`entities`/`enums`/`graphql`/`resolvers`/`services`),
  `abs-api`, `abs-cache`, `user`, `files`, `assets`, `messenger-notifications`, `common`, `config`,
  `migrations`, `version`, `app.controller.ts`. Has `devops/` (k8s/docker/gitlab) + e2e tests.
- **Role:** the **operational ABS domain service** — exposes the ABS bounded context to the platform
  (GraphQL resolvers), with caching (`abs-cache`), user/files/notifications, and persistence.
- **Persistence:** **6 `@Entity` + 3 migrations** + `generate-ormconfig.ts` — **data-owning**.
- **Dependencies:** under `banxe-fiat-backend` — **bounded-context only, no lift-and-shift**; depends
  conceptually on the Bifrost upstream (top-level abs-api) for external core access.

## 3. Overlap & divergence

| Aspect | top-level `abs-api` | nested `banxe-fiat-backend/abs-api` |
|---|---|---|
| Role | **upstream Bifrost client/adapter** | **operational ABS domain service** |
| Modules | bifrost-api, bifrost-api-client | abs (graphql/resolvers/entities/services), abs-cache, user, files, notifications |
| Persistence | **0 entities / 0 migrations** (stateless) | **6 entities / 3 migrations** (data-owning) |
| API style | upstream REST client | GraphQL domain resolvers |
| Caching | none | `abs-cache` |
| devops | minimal | k8s/docker/gitlab + e2e |

- **Not a true duplicate:** the two are **layered** — top-level is the **external-core (Bifrost) port**;
  nested is the **operational ABS domain** that sits above it. The CSV-v0 `dup-audit` hypothesis is
  **rejected** by the audit (no behavioural duplication; complementary layers).
- **Divergence:** all domain logic, persistence, GraphQL surface, caching, user/files/notifications
  live **only** in the nested service; the Bifrost wire-protocol client lives **only** in the top-level.
- **Overlap:** `config` + `shared` scaffolding only (boilerplate), not domain.

## 4. Consumers

Read-only repo-wide grep (`abs-api|bifrost`, excl `node_modules`/lock/the two services/vendor) →
**111 external files** (ABS is **deeply integrated**, unlike the standalone open-banking). Key seams:

- **`@abs/common` (`banxe-fiat-backend/abs-common`)** — **the ABS shared-contract library**
  (`lib/abs/{dtos,enums,interfaces}`, e.g. `abs-get-customer-payment.dto`). This is the canonical
  integration contract (analogous to the `banxe-common` connectors, but ABS-specific). **Discovered —
  NOT in CSV v0** (flagged).
- **`banxe-common` ABS error maps/enums** — `abs-api-error-status.map`, `abs-api-error-code.enum`,
  `abs-api-error-code-title.map` (ABS errors surfaced in the shared error library).
- **RabbitMQ** — `banxe-common/lib/enums/rabbit-mq-patterns.enum.ts` → ABS is wired **via RabbitMQ
  message patterns** (not gRPC; **no `abs-connector` exists** in `banxe-common`).
- **Direct domain consumer:** `banxe-fiat-backend/banxe-identity/src/users/users.service.ts` (identity
  calls ABS for customer data).

**Finding:** the ABS integration contract is **`@abs/common` + `banxe-common` ABS error maps +
RabbitMQ patterns** — these (not a gRPC connector) are the hard constraints to preserve.

## 5. Decision (ADR-102 style)

- **Canonical operational ABS = `banxe-fiat-backend/abs-api` (nested).**
  Rationale: it owns the ABS **domain model (6 entities/3 migrations)**, the **GraphQL surface
  (resolvers/services)**, caching, and is the service consumed across the platform via `@abs/common`.
  Migrate as the **ABS bounded context → `banxe-emi-stack`** (bounded-context only, no
  `banxe-fiat-backend` lift-and-shift).
- **`abs-api` (top-level) = RETAIN as the upstream Bifrost adapter/port (not retire, not a duplicate).**
  It is the **external-core integration layer**; in EMI it becomes the **`AbsBifrostPort` adapter**
  the operational ABS service depends on. "Retire" is **rejected** (it is the only Bifrost client);
  "merge into operational" is **rejected** (clean port/adapter separation is the right architecture).
- **`@abs/common` (discovered) = shared ABS contract package** → migrate **with** the ABS bounded
  context as a shared contracts package (or fold into the EMI ABS module's public contract). Flagged
  as a CSV-v0 discrepancy; recommend mapping-v0 update.

## 6. Risks & mitigations

| Risk | Mitigation (MIG-M2.x / later) |
|---|---|
| Breaking the `@abs/common` contract (111 consumers) | Pin `@abs/common` dtos/enums/interfaces as **contract tests** before any cutover; migrate the operational ABS behind the same contract surface. |
| Breaking ABS RabbitMQ message patterns (`rabbit-mq-patterns.enum`) | Preserve the RMQ pattern contract; characterization tests for ABS message flows; no live broker cutover in M2. |
| Losing the Bifrost upstream client by mis-treating it as a duplicate | Top-level abs-api **retained** as `AbsBifrostPort` adapter; explicitly not retired. |
| ABS error-map drift (`banxe-common` abs-api error enums) | Migrate ABS error codes/maps alongside the bounded context; contract-test the error surface. |
| `abs-cache` consistency on migration | Treat cache as derived; rebuild on EMI side; no stateful cache lift. |
| 111-consumer blast radius / hidden consumer | Re-run repo-wide grep at MIG-M2.5 scaffold time (fail-closed: block cutover if an unhandled consumer/contract appears). |

## 7. EMI mapping & preconditions for MIG-M2.x

- **EMI target (mapping v0):** **`banxe-emi-stack`** — confirmed for the **operational ABS bounded
  context** (nested). The **top-level Bifrost adapter** also lands in `banxe-emi-stack` as the
  external-core **port/adapter** (not a separate dup).
- **`dup-audit` resolved → layered (operational service + upstream Bifrost adapter)**, not a
  retire-one duplicate.
- **CSV-v0 discrepancy recorded:** `@abs/common` (`banxe-fiat-backend/abs-common`) is an
  audit-discovered shared contract lib not in mapping v0 — recommend adding it.
- **Preconditions for MIG-M2.5 (abs-integration migration):**
  1. This audit (MIG-M1.2) accepted + IL recorded.
  2. `@abs/common` contracts + `banxe-common` ABS error maps + RabbitMQ patterns captured as
     contract tests.
  3. MIG-M2.5 scaffolds the EMI ABS bounded context (`banxe-emi-stack`) **+ `AbsBifrostPort` adapter**
     (advisory/read-only first; behind the `@abs/common` + RMQ contracts) — **no merge**.
  4. No `banxe-fiat-backend` lift-and-shift; ABS migrated per bounded context.

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0, advisory); CSV rows `abs-api` +
`banxe-fiat-backend/abs-api` (`abs-integration`, `banxe-emi-stack`, `dup-audit`); legacy (read-only):
`/tmp/bx-legacy/banxe-code/banxe/abs-api`, `banxe-fiat-backend/abs-api`,
`banxe-fiat-backend/abs-common` (`@abs/common`, discovered),
`banxe-common/lib/errors/...abs-api-error-*`, `banxe-common/lib/enums/rabbit-mq-patterns.enum.ts`;
ADR-102 (duplication audit), ADR-103 (server-only); MIG-M1/M2 roadmap; sibling MIG-M1.1 (open-banking)
+ MIG-M1.4 (identity/auth).
