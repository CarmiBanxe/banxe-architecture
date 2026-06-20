# MIG-M1.4.1 — auth duplication audit: `banxe-auth` vs `banxe-auth-backend` (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M1.4.1-auth-dup-audit.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | ADR-102 | advisory-only, audit-only reads | No code, no merge. Child of MIG-M1.4 (identity/auth boundary); precondition for MIG-M2.3. -->

> **Track:** cross-context migration (MIG-M1.x), sub-step of **MIG-M1.4** (identity/auth boundary).
> **Mode:** advisory-only — from **read-only** audit of `/tmp/bx-legacy/banxe-code/banxe`; no code, no
> EMI-repo branches, no merges. Resolves the **auth duplication** flagged in MIG-M1.4 (the two auth
> backends `banxe-auth` vs `banxe-auth-backend`) — a **precondition for MIG-M2.3**.

## 1. Legacy scope — `banxe-auth` (`auth-api`)

- **Stack:** NestJS, **GraphQL-only** (5 GraphQL refs; **0 REST, 0 gRPC**).
- **Modules:** `auth` (`auth.resolver.ts` / `auth.service.ts` / `jwt.strategy.ts` / `guards` / `graphql`),
  `code` (verification codes), `user`, `_shared`, `config`.
- **Features:** JWT + **refresh token** (basic token issuance/verification).
- **Persistence:** **2 `@Entity`**, no migrations directory found — thin.
- **Integrations:** standalone GraphQL auth API.
- **Current consumers:** **18 references — but almost all are error-map/enum namespace** (`banxe-common`
  error maps, `banxe-crypro-processing-api`, `banxe-shared-libs` — `auth-api` as an *error-code title/
  status namespace*), **not** live service consumers. As a *service* it is **barely consumed**.

## 2. Legacy scope — `banxe-auth-backend` (`banxe-fiat-backend/banxe-auth-backend`)

- **Stack:** NestJS, **multi-protocol — GraphQL(8) + REST(3) + gRPC(11)**; **Redis** + **MongoDB**
  (`generate-migrate-mongo-config.ts`, 4 migrations).
- **Modules:** `auth`, **`srp`** (Secure Remote Password), **`session`**, **`token`**, **`api-key`**
  (TPP credentials), **`login-history`**, `scope`, `user`, `redis`, `project`, `plugins`, `middleware`,
  `migrations`, `version`.
- **Features:** **SRP authentication**, **sessions (Redis)**, tokens (JWT + refresh), **api-keys**,
  **login-history**, **scopes** — the full operational auth surface.
- **Persistence:** Mongo-backed (0 TypeORM `@Entity`; mongo config + 4 migrations) + Redis sessions.
- **Integrations:** **the gRPC target of the `banxe-common` `auth-connector`** (see §4).
- **Current consumers:** **8 real service consumers** — `auth-connector` (the platform seam),
  `banxe-identity/users.service`, `banxe-banners`, `banxe-manual-payments`, `banxe-bootstrap` (pm2),
  `banxe-config/gateway-config.json`, `banxe-docs`.

## 3. Overlap & divergence

| Aspect | `banxe-auth` (auth-api) | `banxe-auth-backend` |
|---|---|---|
| Stack | GraphQL-only | **GraphQL + REST + gRPC**, Redis + Mongo |
| Auth method | JWT/refresh | **SRP** + JWT/refresh + sessions |
| Sessions | — | **Redis sessions** |
| API keys (TPP) | — | **present** |
| Login history | — | **present** |
| Scopes | — | **present** |
| Persistence | 2 entities, no migrations | Mongo + 4 migrations + Redis |
| gRPC connector target | no (0 gRPC) | **yes — auth-connector points here** |
| Real service consumers | ~0 (error-namespace only) | 8 |

- **Shared flow:** basic **login / JWT / refresh token** exist in both.
- **Unique to auth-backend:** SRP, Redis sessions, api-keys, login-history, scopes, gRPC, multi-protocol.
- **Unique to auth-api:** nothing operationally distinctive (a thin GraphQL JWT facet) — its only broad
  footprint is the **`auth-api` error-code namespace** in shared error libs.
- **Contract divergence:** auth-api = GraphQL only; auth-backend = gRPC-first (the platform contract) +
  REST + GraphQL.

## 4. Consumers & connector seam

- **`banxe-common` `auth-connector` → targets `banxe-auth-backend`**: the connector uses
  `AUTH_BACKEND_SERVICE_NAME` / `AUTH_BACKEND_SERVICE_NAME_ENV` (11 refs) over **gRPC** (19 Grpc refs).
  The canonical platform auth seam is **auth-backend**, not auth-api.
- **Service consumers reach auth via the gRPC `auth-connector`** (→ auth-backend); identity, banners,
  manual-payments, bootstrap, gateway-config all wire to auth-backend.
- **`auth-api`** appears in **18 files but as an error-code namespace** (`banxe-common`/`crypro`/
  `shared-libs` error maps), not as a service dependency.
- **Frontends** (`banxe-dashboard`, `banxe-admin-panel-new`, `banxe_auth`) reference neither backend
  directly — they go through the gateway/connector layer.

## 5. Decision (ADR-102 style)

- **Classification: HISTORICAL TAIL** (not a true peer duplicate, not an active layered/sidecar pair).
  `banxe-auth-backend` has **superseded** `banxe-auth`: it owns SRP/sessions/api-keys/login-history/
  scopes, is the gRPC `auth-connector` target, and carries all real consumers; `banxe-auth` (`auth-api`)
  is a thin GraphQL JWT facet whose only broad footprint is an **error-code namespace**.
- **Canonical auth source-of-truth = `banxe-auth-backend` → `banxe-platform`** (resolving the MIG-M1.4
  `auth → emi-stack|platform` pipe to **platform**; auth is cross-cutting, consumed via the gRPC
  connector). Migrate behind the **`auth-connector` gRPC contract**.
- **Non-canonical `banxe-auth` (auth-api): RETIRE** after:
  1. confirming **no live service consumer** beyond the error-code namespace (audit shows none);
  2. **salvage only if needed** — if EMI requires a GraphQL auth gateway facet, fold the JWT/refresh
     resolver into the platform auth (thin adapter); otherwise **retire**;
  3. the **`auth-api` error-code namespace** migrates with the **platform error catalogue** (so error
     titles/statuses are preserved), independent of the service's retirement.
- **Correlation with MIG-M1.4 / MIG-M2.3:** this resolves the MIG-M1.4 open precondition (canonical
  auth = auth-backend → platform). identity (`banxe-identity`) stays its own SoT → `banxe-emi-stack`,
  consuming auth via the `auth-connector`; the KYC/KYB/AML carve-out (MIG-M1.4) is unaffected.

## 6. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Retiring auth-api drops a still-used JWT/refresh path | Audit shows ~no live service consumer; before retire (MIG-M2.3) re-run consumer grep fail-closed; salvage the JWT facet as a platform adapter only if a live consumer appears. |
| Breaking the `auth-connector` gRPC contract (8 consumers) | Migrate auth-backend behind the **same `auth-connector` gRPC contract**; contract tests pin the gRPC surface (SRP/session/token/api-key/login-history) before cutover. |
| SRP / session (Redis) / login-history semantics regression | Characterization tests for SRP handshake, session lifecycle (Redis), login-history; staged rollout. |
| Losing the `auth-api` error-code namespace | Migrate error codes/titles/statuses with the platform error catalogue (decoupled from service retirement). |
| Live auth traffic cutover | Operator-gated; M2 scaffolds advisory/read-only behind the connector; staged rollout with fallback to legacy auth-backend. |
| Mongo + Redis state migration | No state lift-and-shift; EMI re-models session/token stores; sessions are ephemeral (rebuild), login-history archived. |

## 7. Preconditions for MIG-M2.3 (identity/auth migration)

The auth-track is **prepared** when:
1. This audit (MIG-M1.4.1) accepted + IL recorded → **canonical auth = `banxe-auth-backend` →
   `banxe-platform`**.
2. **Consumer list captured:** 8 auth-backend consumers (via `auth-connector`) + the `auth-api`
   error-namespace consumers (for the error-catalogue migration).
3. **Feature list for re-home/adaptation:** SRP, Redis sessions, tokens (JWT/refresh), api-keys,
   login-history, scopes (→ platform); JWT/refresh GraphQL facet of auth-api → salvage-or-retire.
4. **Seam with identity:** identity (`banxe-emi-stack`, MIG-M1.4) consumes auth via the
   **`auth-connector` gRPC contract**; contract tests for both `auth-connector` + `identity-connector`.
5. **`auth-api` retirement plan** (post-cutover, fail-closed re-grep), error-namespace migrated.
6. MIG-M2.3 scaffolds platform auth (advisory/read-only first, behind `auth-connector`) — **no merge**,
   no live traffic cutover (operator-gated).

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0, advisory); legacy (read-only): `banxe-auth`
(`auth-api`), `banxe-fiat-backend/banxe-auth-backend` (`banxe-auth-backend`),
`banxe-common/lib/graphql-through-grpc-connectors/auth-connector` (targets `AUTH_BACKEND_SERVICE_NAME`),
`banxe-common`/`banxe-crypro-processing-api`/`banxe-shared-libs` error maps (`auth-api` namespace);
ADR-102, ADR-103, ADR-059-A; MIG-M1.4 (identity/auth boundary, merged — this resolves its auth
precondition); MIG-M1/M2 roadmap; precondition for MIG-M2.3.
