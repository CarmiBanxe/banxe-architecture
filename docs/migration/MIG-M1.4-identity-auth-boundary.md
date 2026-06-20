# MIG-M1.4 — identity + auth domain boundary (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M1.4-identity-auth-boundary.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | advisory-only, audit-only reads | No code, no merge. Scope: FULL RECONCILE (operator-approved 2026-06-20) — documents CSV-v0 + audit-discovered services; nothing regulated scoped-in without operator OK. -->

> **Track:** cross-context migration (MIG-M1.x). **Mode:** advisory-only — from **read-only** audit of
> `/tmp/bx-legacy/banxe-code/banxe`; no code, no EMI-repo branches, no merges. **CSV v0 rows in
> scope:** `banxe-fiat-backend/banxe-identity → identity → banxe-emi-stack (adapt)`; `banxe-auth →
> auth → banxe-emi-stack|banxe-platform (adapt)`. This audit found **services beyond CSV v0** — they
> are **documented + flagged**, not silently scoped-in (full-reconcile per operator decision).

## 1. Legacy scope

### A. `banxe-fiat-backend/banxe-identity` (CSV v0 — identity) — package `banxe-identity`
- **Identity core (migratable):** `users`, `companies` / `companies-docs` / `companies-questionnaires`,
  `user-identity-docs`, `dictionary-client` / `dictionary-connector`, `files`, `messanger`, `crm-connector`,
  `migrations`, `version`.
- **⚠️ Regulated / operator-gated slices (KYC/KYB/AML-adjacent — NOT casual adapt):** `bkyc`, `kyb`,
  `scoring-risk-level`, `sumsub-connector`, `blocking`. Per canon (KYC/AML deferred, never bypassed)
  these require a **carve-out + operator gate**, separate from the identity-core migration.
- Persistence-owning (ormconfig + migrations); under `banxe-fiat-backend` — **bounded-context only, no
  lift-and-shift**.

### B. `banxe-auth` (CSV v0 — auth) — package **`auth-api`**
- Focused auth backend: `auth`, `code` (verification codes), `user`, `_shared`, `config`. Thinner
  surface; the CSV-named auth service.

### C. Services discovered by audit — **NOT in CSV v0** (flagged, not scoped-in)
| Service | package | Nature | Disposition (flag) |
|---|---|---|---|
| `banxe-fiat-backend/banxe-auth-backend` | `banxe-auth-backend` | **Full auth backend** — `api-key`, **`srp`**, `session`, `token`, `login-history`, `scope`, `redis`, `migrations`, `project`, `plugins`, `middleware` | **Auth duplication-audit candidate vs `banxe-auth`** (open-banking/abs-style pair). Likely the richer/operational auth source — confirm in a dedicated dup-audit before MIG-M2.3. |
| `banxe_auth` (underscore) | `banxe-auth` | **Frontend** (React/Feature-Sliced: `pages`/`widgets`/`processes`/`features`/`serviceWorker`) | **NOT an auth backend → frontend track `banxe-ui`** (re-home to MIG frontend, not identity/auth). |
| `banxe-identity-config-manager` | `banxe-identity-config-manager` | tiny config service (`app.module`/`config`/`main`) | **config/infra** → MIG-M1.6 config track, not identity domain. |

## 2. Overlap & divergence

- **Two auth backends** (`banxe-auth`=`auth-api` vs `banxe-fiat-backend/banxe-auth-backend`) — partial
  overlap (both do authentication) but **diverge**: `auth-backend` is far richer (SRP, sessions,
  tokens, api-keys, login-history, scopes, redis) while `auth-api` is thin (auth/code/user). This is a
  genuine **duplication-audit pair** (analogous to open-banking MIG-M1.1 / abs MIG-M1.2) — **not yet
  resolved here** (needs its own dup-audit).
- **identity vs auth seam:** `banxe-identity` owns *who the user is* (KYC/KYB/companies/profile);
  auth backends own *authentication* (sessions/tokens/codes/SRP). Clean conceptual boundary; users
  data is identity-owned, credentials/sessions are auth-owned.
- **`banxe_auth` is a frontend**, not a backend duplicate — belongs to the UI track.

## 3. Consumers

Read-only repo-wide grep (`banxe-identity|banxe-auth`, excl `node_modules`/lock/vendor/the services
themselves) → **30 external files**; the canonical access pattern is the **`banxe-common`
graphql-through-grpc connector layer**:

- **`banxe-common` connectors (the integration seam):** `auth-connector`, `identity-connector` (+ 20
  others: `accounts`/`cards`/`payments`/`sumsub`/`companies`/`2fa`/`addresses`/`acl`/`rates`/`tariff`/
  `notifications`/…). **Any auth/identity migration MUST preserve these gRPC contract boundaries.**
- Other references: `banxe-fiat-backend/banxe-sumsub`, `banxe-fiat-backend/banxe-banners`,
  `banxe-manual-payments`, `banxe-bootstrap`, `banxe-config` (`rabbitmq-config.json`,
  `gateway-config.json`), `banxe-docs`, `banxe-identity-config-manager`.

**Finding:** auth/identity are **widely consumed via `banxe-common` gRPC connectors** (unlike the
standalone open-banking) — the migration's hard constraint is **contract preservation of
`auth-connector` + `identity-connector`**, not just code relocation.

## 4. Decision (ADR-102 style) — boundaries + carve-outs + flags

- **identity-core (canonical) → `banxe-emi-stack`** (CSV v0 confirmed): migrate `users` / `companies*`
  / `user-identity-docs` / `dictionary` / `files` / `crm-connector` as the **identity bounded
  context**, behind the `identity-connector` gRPC contract. Bounded-context only — no
  `banxe-fiat-backend` lift-and-shift.
- **identity regulated slices (`bkyc`/`kyb`/`scoring-risk-level`/`sumsub-connector`/`blocking`) →
  CARVE-OUT, operator-gated.** **NOT scoped into MIG-M2.3** without explicit operator/governance sign-off
  (canon: KYC/AML deferred, never bypassed). Documented here; decision deferred to a dedicated
  KYC/KYB governance step.
- **auth (canonical) → resolve to `banxe-platform`** (CSV `emi-stack|platform` → **platform**):
  authentication/session/token/SRP is a **cross-cutting platform concern** consumed by many contexts
  via `auth-connector` — platform layer is the right home. **BUT** the canonical auth *source* is
  **pending an auth duplication-audit** (`banxe-auth` vs `banxe-auth-backend`); `banxe-auth-backend`
  is the **likely canonical** (richer SRP/session/token/api-key), with `banxe-auth` (`auth-api`)
  thin → merge-then-retire — **to be confirmed in that dup-audit, not finalized here.**
- **`banxe_auth` (frontend) → `banxe-ui`** track (not identity/auth domain).
- **`banxe-identity-config-manager` → config/infra** (MIG-M1.6), not identity domain.

## 5. Risks & mitigations

| Risk | Mitigation (MIG-M2.x / dedicated steps) |
|---|---|
| Auth duplication unresolved (`banxe-auth` vs `banxe-auth-backend`) → wrong canonical migrated | **Dedicated auth dup-audit** (open-banking/abs-style) before MIG-M2.3; pick canonical by SRP/session/token ownership + consumer contracts. |
| Breaking the `banxe-common` `auth-connector`/`identity-connector` gRPC contracts | MIG-M2.3 scaffolds EMI identity/auth **behind the same connector contracts**; contract tests pin the gRPC surface before any cutover. |
| Casual migration of regulated KYC/KYB/AML (`bkyc`/`kyb`/`scoring-risk-level`/`sumsub`) | **Operator-gated carve-out**; excluded from MIG-M2.3 default scope; separate governance + compliance review. |
| `banxe_auth` frontend mis-filed into auth backend track | Explicitly routed to `banxe-ui`; not part of identity/auth backend migration. |
| CSV v0 incompleteness (3 discovered services) misleads later waves | This doc + IL record the discrepancy; recommend updating mapping v0 to add `banxe-auth-backend` (auth dup pair), `banxe_auth` (frontend), `banxe-identity-config-manager` (config). |

## 6. EMI mapping confirmation

- **identity-core → `banxe-emi-stack`** (CSV v0 confirmed); regulated KYC/KYB slices **carved out,
  operator-gated**.
- **auth → `banxe-platform`** (CSV `emi-stack|platform` resolved to **platform** — cross-cutting),
  canonical source **pending auth dup-audit**.
- Migrated **per bounded context behind `banxe-common` connector contracts** — **NOT** via
  `banxe-fiat-backend` lift-and-shift.
- **CSV-v0 discrepancy recorded:** `banxe-auth-backend` (auth dup pair), `banxe_auth` (→ banxe-ui),
  `banxe-identity-config-manager` (→ config) are audit-discovered; recommend mapping-v0 update.

## 7. Preconditions for MIG-M2.3 (identity/auth migration)

1. This boundary audit (MIG-M1.4) accepted + IL recorded.
2. **Auth duplication-audit** (`banxe-auth` vs `banxe-auth-backend`) completed → single canonical auth.
3. **Operator/governance sign-off** on the KYC/KYB/AML carve-out scope (in or out of MIG-M2.3).
4. `banxe-common` `auth-connector` + `identity-connector` gRPC contracts captured as contract tests.
5. MIG-M2.3 scaffolds identity-core → `banxe-emi-stack` and auth → `banxe-platform` (advisory/read-only
   first, behind connector contracts) — **no merge**.

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0, advisory); CSV rows `banxe-fiat-backend/
banxe-identity` (identity, banxe-emi-stack) + `banxe-auth` (auth, banxe-emi-stack|banxe-platform);
legacy (read-only): `banxe-fiat-backend/banxe-identity`, `banxe-auth`, `banxe-fiat-backend/
banxe-auth-backend` (discovered), `banxe_auth` (discovered frontend), `banxe-identity-config-manager`
(discovered config), `banxe-common/lib/graphql-through-grpc-connectors/{auth,identity}-connector`;
ADR-102 (duplication audit), ADR-103 (server-only); MIG-M1/M2 roadmap; sibling MIG-M1.1 (open-banking
dup-audit pattern).
