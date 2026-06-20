# MIG-M2.0 — mapping-v0 update + banxe-shared-libs dedup-audit (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M2.0-mapping-v0-update-and-shared-libs-dedup.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | ADR-102 | advisory-only, audit-only reads | No code, no merge. Precondition for MIG-M2.7. -->

> **Track:** cross-context migration — **M2 precondition** (gates MIG-M2.7). **Mode:** advisory-only,
> **read-only** audit; no code, no EMI-repo branches, no merges. Resolves the two open M1.8
> preconditions: (a) the `banxe-shared-libs` vs `banxe-core`/`banxe-common` **dedup-audit** (two
> platform-core risk), and (b) the **mapping-v0 update** with the 11 audit-discovered services.

## 1. Scope — why this gates M2.7

MIG-M1.6 flagged a **two-platform-core risk**: `banxe-shared-libs` appeared to mirror `@banxe/core`
(`banxe-core`) + `@banxe/common` (`banxe-common`). Scaffolding platform-core (MIG-M2.7) before
resolving which is canonical would risk **two competing platform foundations** — catastrophic for the
connector mesh (`@banxe/common` has **1429 importers**; `@banxe/core` 88). This audit picks the single
canonical platform/shared-contracts home and records the mapping-v0 update so M2.7 starts unambiguous.

## 2. ADR-102 dedup — `banxe-shared-libs` vs `banxe-core`/`banxe-common`

- **`banxe-shared-libs`** = a **consolidated shared-contracts monorepo**, `packages/`:
  | package | name | identical standalone? |
  |---|---|---|
  | `core` | `@banxe/core` | **identical** to `banxe-core` (same lib tree + `gql-transport.proto`, **v0.0.50**) |
  | `common` | `@banxe/common` | **identical** to `banxe-common` (25 connectors, **v0.0.461**) |
  | `abs-common` | `@abs/common` | **identical** to `banxe-fiat-backend/abs-common` (**v0.1.112**, the MIG-M1.2 lib) |
  | `bank-common` | `@banxe/bank-common` | (monorepo-only) |
  | `graphql` | `graphql` | (monorepo-only) |
  | `rabbit-mq` | `@banxe/rabbit-mq` | (monorepo-only) |
- **Source-of-truth signal:** consumers import by **package name** (`@banxe/core`, `@banxe/common`,
  `@abs/common`) — **0 references** to `banxe-shared-libs` as a path. Standalone `banxe-core` /
  `banxe-common` / `banxe-fiat-backend/abs-common` are **single-package mirror checkouts** (same
  name + version, same mtime batch) of the monorepo packages.
- **Degree of duplication:** **100% (identical artifacts)** — same package names + versions, not a
  divergent fork. This is **not a true divergent duplicate**; it is one source published two ways
  (monorepo + extracted single-package dirs).
- **Consumers:** `@banxe/common` = **1429 importers**, `@banxe/core` = **88**, `@abs/common` per
  MIG-M1.2 (111 ABS refs) — all by package name, agnostic to the source dir.

## 3. Decision (ADR-102)

- **Canonical platform / shared-contracts home = `banxe-shared-libs` (the monorepo).**
  Rationale: it is the **structured single source** publishing all platform/shared packages
  (`@banxe/core`, `@banxe/common`, `@abs/common`, `@banxe/bank-common`, `@banxe/rabbit-mq`, `graphql`);
  the standalone dirs are extracted mirrors of identical version. Migrate the **monorepo** as the
  platform shared-contracts package source → **`banxe-platform`**.
- **Standalone `banxe-core` / `banxe-common` / `banxe-fiat-backend/abs-common` → RETIRE** (mirror
  checkouts; identical name+version). No reconciliation needed (no divergence). Consumers import by
  `@banxe/*` package name → repoint to the shared-libs-published packages in `banxe-platform`; the
  source-dir change is transparent to importers.
- **Two-platform-core risk = RESOLVED:** there is **one** platform source (`banxe-shared-libs`); M2.7
  scaffolds from it, not from the standalone mirrors.
- **Cross-references resolved:** MIG-M1.2 `@abs/common` and MIG-M1.6 platform-core are both **the
  shared-libs monorepo** — `@abs/common` migrates with `banxe-shared-libs` → `banxe-platform` (ABS
  domain in `banxe-emi-stack` *consumes* the `@abs/common` contract from platform).

## 4. Risks & mitigations

| Risk | Mitigation (MIG-M2.7) |
|---|---|
| Two platform-cores scaffolded (monorepo + mirror) | **Resolved**: canonical = `banxe-shared-libs`; standalone dirs retired; M2.7 sources from the monorepo only. |
| Breaking `@banxe/common` connector contract (**1429 importers**) | Migrate behind the **same** `@banxe/common` package API + `gql-transport.proto`; comprehensive connector contract tests **before** any consumer migration. |
| `gql-transport.proto` transport regression | Pin the proto as a contract-test baseline; identical proto in both sources → no divergence to merge. |
| `@abs/common` treated as a separate lib (MIG-M1.2) vs monorepo package | Clarified: it is `banxe-shared-libs/packages/abs-common` → migrates with the platform monorepo; ABS domain consumes the contract. |
| Version drift if mirrors edited post-cutover | Retire mirrors at M2.7; single publish source (monorepo) thereafter. |

## 5. Mapping-v0 update (11 audit-discovered services)

| Legacy service | Domain | Canonical EMI repo | transfer_mode | Note |
|---|---|---|---|---|
| `banxe-fiat-backend/banxe-auth-backend` | auth (canonical) | **banxe-platform** | adapt | MIG-M1.4.1 canonical auth (SRP/session/token/api-key) |
| `banxe_auth` (underscore) | frontend-auth | **banxe-ui** | adapt | React FE (not a backend) |
| `banxe-identity-config-manager` | config | **infra** (banxe-platform) | adapt | config service |
| `banxe-shared-libs` | platform-core (shared-contracts monorepo) | **banxe-platform** | adapt | **CANONICAL platform home**; supersedes standalone `banxe-core`/`banxe-common`/`abs-common` (retire) |
| `@abs/common` (`banxe-fiat-backend/abs-common`) | abs-contracts | **banxe-platform** | adapt (retire standalone) | = `banxe-shared-libs/packages/abs-common`; ABS domain (emi-stack) consumes it |
| `banxe-apollo-gateway` | platform-core (GraphQL federation) | **banxe-platform** | adapt | gateway |
| `grpc-proxy-server` | platform-core | **banxe-platform** | adapt | gRPC proxy |
| `banxe-manual-payments` | frontend-admin | **banxe-ui** | adapt | React FE (back-office) |
| `tompayment-web` (`banxe-tompayment`) | frontend-product | **banxe-ui** | adapt | React FE (product) |
| `transfer_accounts` | payments-transfer | **banxe-payment-core** | adapt | Express transfer micro-service |
| `banxe-admin-panel-new` (`banxe-admin-panel`) | frontend-admin (canonical) | **banxe-ui** | adapt | canonical admin shell (React18+Vite) |

> **Recommendation:** apply these 11 rows to the canonical `migration-mapping-v0` CSV; mark standalone
> `banxe-core` / `banxe-common` / `banxe-fiat-backend/abs-common` as **retire (mirror of
> `banxe-shared-libs`)**.

## 6. Preconditions for MIG-M2.7 (now satisfiable)

1. **Canonical platform home chosen** ✅ — `banxe-shared-libs` (monorepo) → `banxe-platform`;
   standalone mirrors retire. **Two-platform-core risk resolved.**
2. **Contract-test baseline to capture before scaffold:** `gql-transport.proto`; the 25
   `@banxe/common` connectors (1429 importers); `@banxe/core` discovery/graphql/grpc API (88
   importers); `@abs/common`; `@banxe/rabbit-mq`; apollo-gateway federation schema.
3. **M2.7 scaffolds** the platform shared-contracts (`@banxe/*` packages) from `banxe-shared-libs` →
   `banxe-platform` (advisory/read-only first, behind the identical package APIs + proto) — **no merge,
   no live mutation** (operator-gated).
4. mapping-v0 updated (§5) so downstream M2 substeps reference single canonical targets.

## 7. Acceptance

The `banxe-shared-libs` dedup is **resolved** (canonical = monorepo; standalone = identical mirrors →
retire; **no divergence**), and the 11 discovered services have proposed mapping-v0 rows. The two open
MIG-M1.8 preconditions tied to the platform layer are now closed; **MIG-M2.7 may proceed** once its
contract-test baseline (§6.2) is captured. Advisory-only, no code, no mutation.

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0); legacy (read-only): `banxe-shared-libs`
(`packages/core`/`common`/`abs-common`/`bank-common`/`graphql`/`rabbit-mq`), `banxe-core` (`@banxe/core`
v0.0.50), `banxe-common` (`@banxe/common` v0.0.461), `banxe-fiat-backend/abs-common` (`@abs/common`
v0.1.112), `banxe-apollo-gateway`, `grpc-proxy-server`; ADR-102 (duplication audit), ADR-103
(server-only); MIG-M1.6 (platform-core), MIG-M1.2 (`@abs/common`), MIG-M1.8 (acceptance); MIG-M2.7
(next).
