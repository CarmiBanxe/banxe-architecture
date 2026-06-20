# MIG-M1.1 — open-banking duplication audit (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M1.1-open-banking-dup-audit.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | ADR-102 duplication audit | advisory-only, audit-only reads | No code, no merge. -->

> **Track:** cross-context migration (MIG-M1.x), distinct from the in-flight `banxe-trading-backend`
> advisory M1.x lane. **Mode:** advisory-only — produced from **read-only** audit of the legacy root
> `/tmp/bx-legacy/banxe-code/banxe`; no code, no branches in EMI repos, no merges. EMI target per
> mapping v0: **`banxe-emi-stack`** (`transfer_mode=dup-audit`).

## 1. Legacy scope

Two legacy services share the package name `banxe-open-banking` (both `v0.0.1`, NestJS/TypeScript) but
**diverge in role**:

### A. `banxe-open-banking` (top-level) — PSD2 provider surface + domain model
- **Entry points / modules:** `accounts` (incl. **`account-consents.controller`** + `accounts-consents.service` — AISP/PISP consent model), **`domestic`**, **`international`**, **`funds-confirmations`** (PSD2 payment-initiation + funds-confirmation surface, 11 controller/service files), `file`, `common`, `config`, `app.module.ts`, `main.ts` (`PORT` from config). GraphQL-oriented (graphql-js fork / schema-print per README).
- **Data types (top-level only):** **10 `@Entity` files** — the richer Open Banking domain model (consents, accounts, domestic/international payments, funds-confirmations).
- **Dependencies:** standalone NestJS app; no code-level imports from other legacy services observed.

### B. `banxe-fiat-backend/banxe-open-banking` (nested) — operational/TPP backend
- **Entry points / modules:** `accounts` (`account.controller` + `fiat-accounts`, thinner), **`api-keys`**, **`auth`**, **`transactions`**, `swagger` (REST docs), `shared`, `config`, `migrations`, `generate-ormconfig.ts`, `app.module.ts`, `main.ts` (`DEFAULT_APP_PORT=3000`).
- **Data types (nested):** **1 `@Entity` + 1 migration** (thin persistence) + `ormconfig.json`.
- **Dependencies:** lives under the `banxe-fiat-backend` container (**must NOT be lift-and-shifted as one unit** — bounded-context only).

## 2. Overlap & divergence

| Aspect | top-level `banxe-open-banking` | nested `banxe-fiat-backend/banxe-open-banking` |
|---|---|---|
| Role | PSD2 **provider API surface** + domain model | **operational/TPP** backend (auth, api-keys, tx) |
| PSD2 flows (domestic/international/funds-confirmations) | **present (canonical, 11 files)** | absent |
| Account consents (AISP/PISP) | **present** (`account-consents.controller`) | absent |
| `accounts` module | rich (consents, dtos, entities, enums, helpers, interfaces) | thin (`account.controller`, `fiat-accounts`) — **overlap (superseded)** |
| `api-keys` / `auth` (TPP onboarding) | absent | **present (unique)** |
| `transactions` | absent | **present (unique)** |
| Persistence | **10 entities** (rich) | 1 entity + 1 migration (thin) |
| API style | GraphQL-oriented | REST + swagger |

- **Overlap:** `accounts` + `config` exist in both; the top-level `accounts` (with consents + 10-entity model) **supersedes** the nested thin `accounts`.
- **Divergence / unique-to-nested:** `api-keys`, `auth` (TPP credential onboarding), `transactions` (history) — **not present** in the top-level. These are **cross-context slices** (auth/identity, payments/accounts), not open-banking-specific.
- **Unique-to-top-level:** the entire PSD2 provider surface (domestic/international/funds-confirmations + consents) and the rich entity model.

## 3. Consumers

Repo-wide read-only grep for `open-banking|openBanking|open_banking` across the legacy root (excluding
the two services themselves) → **5 external references, only 1 internal code/config consumer:**

| Reference | Type | Consumer? |
|---|---|---|
| `banxe-config/stable/fiat-config.json` | internal config | **Yes** — service URL / feature config for open-banking (re-point at MIG-M2.4). |
| `temenos_r19-apis/customerProfile-service-*-swagger.json` | vendor spec | No — Temenos core-banking reference spec (`customerOpenBankingConnections`), not a consumer of our code. |
| `temenos_r20/party-customerOpenBankingConnections-service-*-swagger.json` | vendor spec | No — vendor reference. |
| `temenos_r20/party-customers-service-*-swagger.json` | vendor spec | No — vendor reference. |
| `temenos_r19.12/party-customers-service-*-swagger.json` | vendor spec | No — vendor reference. |

**Finding:** no other legacy service imports/calls either open-banking service in code — open-banking is
a **relatively standalone bounded context** (consumed externally by TPPs via its API, wired via
`banxe-config`). The only internal wiring to re-point is `banxe-config/fiat-config.json`.

## 4. Decision (ADR-102 style)

- **Canonical source-of-truth = `banxe-open-banking` (top-level).**
  Rationale: it owns the full **PSD2 provider surface** (domestic + international payment initiation,
  funds-confirmations) **and** the **AISP/PISP account-consent** model, backed by the **richer
  10-entity domain model** — i.e. it is the genuine Open Banking bounded context. Data ownership +
  architectural completeness + regulatory-surface fidelity favour it. Migrate as the **single
  open-banking bounded context → `banxe-emi-stack`**.

- **Non-canonical = `banxe-fiat-backend/banxe-open-banking` (nested): MERGE-then-RETIRE (split unique slices first).**
  It is **not** a thin adapter (so "keep as adapter" is rejected) and **not** a pure duplicate (so
  blind "retire" would lose features). Decision:
  1. Its `accounts` overlap is **superseded** by the canonical → drop.
  2. Its **unique slices** are **cross-context, not open-banking**: `api-keys` + `auth` → evaluate
     against the **identity/auth** context (MIG-M1.4); `transactions` → evaluate against
     **payments/accounts** (MIG-M1.3). Re-home any genuinely-needed feature there.
  3. **Retire** the nested service after its unique slices are re-homed; **never** lift-and-shift it
     with `banxe-fiat-backend`.

## 5. Risks & mitigations

| Risk | Mitigation (MIG-M2.x / later) |
|---|---|
| Losing TPP `api-keys`/`auth` onboarding when retiring the nested service | Re-home to identity/auth context (MIG-M1.4 → MIG-M2.3) before retire; characterization tests for TPP credential flows. |
| Losing `transactions` history feature | Evaluate against payments/accounts (MIG-M1.3 → MIG-M2.1/M2.2); migrate or explicitly mark out-of-scope with operator sign-off. |
| Hidden consumer beyond the 5 refs | The single internal consumer is `banxe-config/fiat-config.json`; re-point at MIG-M2.4. Re-run repo-wide grep at M2.4 scaffold time (fail-closed: block retire if a new consumer appears). |
| GraphQL (top-level) vs REST/swagger (nested) API-style mismatch for EMI | MIG-M2.4 scaffolds the EMI open-banking surface advisory/read-only first; contract tests pin the PSD2 endpoint families before any live wiring. |
| Regulatory surface (PSD2 consents) regression | Port consent model + funds-confirmations under contract tests; no live payment initiation in M2 (operator-gated). |

## 6. EMI mapping confirmation

- **EMI target repo (mapping v0):** **`banxe-emi-stack`** — confirmed. `transfer_mode=dup-audit` resolved.
- open-banking migrates as a **single bounded context** into `banxe-emi-stack`, sourced from the
  **canonical top-level `banxe-open-banking`** — **NOT** via lift-and-shift of `banxe-fiat-backend`.
- Cross-context slices from the nested service (`api-keys`/`auth` → identity/auth; `transactions` →
  payments/accounts) are deferred to their owning contexts (MIG-M1.3 / MIG-M1.4), not folded into the
  open-banking migration.

## 7. Preconditions for MIG-M2.4 (open-banking migration)

1. This audit (MIG-M1.1) accepted + IL recorded.
2. Identity/auth boundary (MIG-M1.4) decides the home for nested `api-keys`/`auth`.
3. Payments/accounts boundary (MIG-M1.3) decides the home for nested `transactions`.
4. MIG-M2.4 scaffolds the EMI open-banking surface from the **canonical top-level** service (advisory/
   read-only first; PSD2 contract tests; `banxe-config/fiat-config.json` re-point) — **no merge**.

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0, advisory), CSV matrix v0 row
`banxe-open-banking` / `banxe-fiat-backend/banxe-open-banking` (`open-banking`, `banxe-emi-stack`,
`dup-audit`); legacy (read-only): `/tmp/bx-legacy/banxe-code/banxe/banxe-open-banking`,
`/tmp/bx-legacy/banxe-code/banxe/banxe-fiat-backend/banxe-open-banking`,
`banxe-config/stable/fiat-config.json`; ADR-102 (duplication audit), ADR-103 (server-only); MIG-M1/M2
roadmap.
