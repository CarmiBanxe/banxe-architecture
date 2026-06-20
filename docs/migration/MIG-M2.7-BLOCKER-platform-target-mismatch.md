# MIG-M2.7 — BLOCKER: platform-core target mismatch (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M2.7-BLOCKER-platform-target-mismatch.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | BLOCKER REPORT | advisory-only, read-only preflight | No code, no scaffold, no merge. -->

> **STATUS: BLOCKED.** MIG-M2.7 (platform-core/gateway scaffold) **did NOT proceed.** The read-only
> preflight found the target repo `banxe-platform` is **not** a backend platform-core home — it is the
> **frontend Web+Mobile UI monorepo**. No scaffold was created; no backend PR opened. This report +
> IL-shard record the blocker and the decision required from the operator/governance.

## 1. Preflight outcome (read-only)

`banxe-platform` **exists, is accessible, initialized** (default `main`, ~213KB, public) — but its
**purpose contradicts the MIG-M2.7 target assumption**:

- **README:** *"banxe-platform — BANXE AI Bank — **Web + Mobile UI Platform**. TypeScript monorepo
  (pnpm + Turbo) for BANXE customer-facing applications. Includes React web app and React Native
  mobile app with shared types and utilities."*
- **ROADMAP:** *"banxe-platform is the **frontend monorepo** for BANXE AI Bank."*
- **Layout:** `packages/web` (Next.js 15 App Router), `packages/mobile` (React Native/Expo),
  `packages/shared` (TS types / design tokens / Zustand stores). pnpm workspaces.
- **Backend platform-core artifacts present: NONE** — no `.proto`, no NestJS/gRPC, no
  `@banxe/core`/`@banxe/common`/`gql-transport`/apollo-federation/connector code.

## 2. The mismatch

MIG-M2.7 (and the platform-core target in mapping-v0 / MIG-M1.6 / MIG-M2.0) assumed
**`banxe-platform` = the backend platform-core home** for `@banxe/core` (GraphQL↔gRPC transport,
`gql-transport.proto`, discovery), `@banxe/common` (25 gRPC connectors, 1429 importers), `@abs/common`,
`@banxe/rabbit-mq`, and the apollo-gateway federation.

**Reality:** `banxe-platform` is the **frontend (Web+Mobile UI) monorepo**. Scaffolding a Node/NestJS
backend platform-core (gRPC/proto + connector mesh) into a Next.js/React-Native frontend monorepo
would:
- **contradict the repo's established purpose** (README/ROADMAP/CANON) — I did not create this repo and
  its content contradicts how the target was described in the mapping → surface, do not overwrite;
- introduce an **architectural canon violation** (backend gRPC transport inside a customer-facing UI
  monorepo);
- break the clean frontend/backend separation the EMI repo roster implies.

Per the MIG-M2.7 instruction (*"если репо … заблокировано, НЕ scaffold'ить ничего, а оформить это как
blocker-report + arch IL-shard/PR и остановиться"*) and standing canon (do not overwrite a
different-purpose repo) — **STOP, no scaffold.**

## 3. EMI repo roster facts (read-only)

| Repo | size | Nature (observed) |
|---|---|---|
| `banxe-platform` | ~213KB | **Frontend Web+Mobile UI monorepo** (Next.js 15 + React Native + shared TS) |
| `banxe-ui` | ~6702KB | Frontend (separate, larger) — exists |
| `banxe-emi-stack` | ~5526KB | EMI **backend** stack (candidate backend platform-core home) |
| `banxe-payment-core` | ~315KB | Payment backend |
| `banxe-architecture` | — | Docs/ADR/sharded-ledger (this repo) |

→ There are **two frontend repos** (`banxe-platform` UI + `banxe-ui`) and the **backend platform-core
has no clearly-designated home** in the current roster.

## 4. Impact on the migration plan

- **MIG-M2.7 cannot run** against `banxe-platform` as a backend platform-core target.
- **mapping-v0 / MIG-M1.6 / MIG-M2.0** platform-core target rows (`platform-core → banxe-platform`) are
  **incorrect** given the real repo; they must be corrected.
- **MIG-M1.7 frontend rows** (`frontend → banxe-ui`) may also need reconciliation: the actual frontend
  monorepo is **`banxe-platform`** (Web+Mobile UI) — so the frontend-admin/customer targets may belong
  to `banxe-platform`, and `banxe-ui` 's role must be clarified vs `banxe-platform`.
- **Downstream M2 sequencing** (M2.7 first) is paused until the backend platform-core home is fixed.

## 5. Decision required (operator / governance)

**A. Backend platform-core home** — choose one (do not silently re-target):
1. **`banxe-emi-stack`** — host the backend platform-core (`@banxe/*` from `banxe-shared-libs`) as a
   module/package inside the EMI backend stack (it is the backend monorepo, ~5.5MB).
2. **New dedicated repo** — e.g. `banxe-platform-core` / `banxe-core-backend` for the shared-contracts
   backend foundation (cleanest separation; requires repo init).
3. **Re-scope** — keep `@banxe/*` published from `banxe-shared-libs` and have EMI services consume them
   as external packages (no new platform repo); MIG-M2.7 becomes a "consume contracts" step, not a
   scaffold.

**B. Frontend roster reconciliation** — clarify **`banxe-platform` (UI) vs `banxe-ui`**: which is the
canonical frontend target for the MIG-M1.7 admin/customer/product shells (so M2.8 targets the right
repo).

## 6. What was and was NOT done

- **Done (read-only):** preflight of `banxe-platform` (README/ROADMAP/CANON/tree), roster check of
  `banxe-ui`/`banxe-emi-stack`/`banxe-payment-core`; this blocker doc + IL-shard in
  `banxe-architecture` (isolated worktree, Rule 1/6).
- **NOT done:** **no scaffold** in any repo; **no backend PR**; **no code/proto/package skeleton**
  created; `banxe-platform` **untouched**; no merge.

## 7. Recommended next step (pending operator decision)

Operator/governance resolves §5.A (backend platform-core home) + §5.B (frontend roster). Then either:
- re-issue **MIG-M2.7** against the confirmed backend home (with the same contract baseline:
  `gql-transport.proto` + 25 `@banxe/common` connectors + `@banxe/core` + `@abs/common` +
  `@banxe/rabbit-mq` + apollo federation), or
- if §5.A.3 chosen, re-scope MIG-M2.7 to a "consume `@banxe/*` from `banxe-shared-libs`" step.
- Correct mapping-v0 platform/frontend target rows accordingly (sibling to MIG-M2.0).

## References
`/tmp/banxe-migration-mapping-v0.claude.txt` (mapping v0); read-only: `CarmiBanxe/banxe-platform`
(README/ROADMAP/CANON — frontend Web+Mobile UI), `CarmiBanxe/banxe-ui`, `CarmiBanxe/banxe-emi-stack`,
`CarmiBanxe/banxe-payment-core`; `banxe-shared-libs` (canonical platform shared-contracts source, per
MIG-M2.0); ADR-102, ADR-103 (server-only + promotion gate), ADR-059-A; MIG-M1.6 (platform-core audit),
MIG-M2.0 (shared-libs dedup), MIG-M1.8 (acceptance); MIG-M1/M2 roadmap.
