# MIG-M2.7 — RE-SCOPE: consume `@banxe/*` from banxe-shared-libs (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M2.7-RESCOPE-consume-from-shared-libs.md | Date: 2026-06-20 | Lane: BANXE.RAR → EMI cross-context migration track | advisory-only | No code, no scaffold, no merge. Resolves the MIG-M2.7 blocker (PR #612 / IL-370) per operator decision. -->

> **Resolves** the MIG-M2.7 blocker (target mismatch — `banxe-platform` is the frontend Web+Mobile UI
> monorepo, not a backend platform-core home; PR #612 / IL-370). **Operator/governance decision
> (2026-06-20)** recorded below. Advisory-only; no code, no scaffold, no merge.

## 1. Operator decisions

- **A — Backend platform-core home → RE-SCOPE: consume from `banxe-shared-libs`.**
  Do **not** scaffold a separate backend platform-core repo. EMI backend services consume the
  `@banxe/*` packages **as external packages** published from the canonical `banxe-shared-libs`
  monorepo (per MIG-M2.0). **MIG-M2.7 becomes a "pin/consume contracts" step, not a scaffold.**
- **B — Frontend roster (`banxe-platform` UI vs `banxe-ui`) → DEFER.**
  Do **not** fix the canonical frontend target now. A **dedicated read-only frontend audit**
  (`banxe-platform` Web+Mobile UI vs `banxe-ui`: overlap, purpose, canonical target) runs as its own
  MIG substep **before MIG-M2.8**.

## 2. Re-scoped MIG-M2.7 = contract-baseline pin (consume, not scaffold)

The canonical platform/shared-contracts source is **`banxe-shared-libs`** (MIG-M2.0). Re-scoped
MIG-M2.7 **pins the immutable consumption contract baseline** that downstream EMI backend substeps
import **unchanged** (as external `@banxe/*` packages) — no platform repo, no re-implementation:

| Contract | Package / artifact | Consumers note |
|---|---|---|
| GraphQL↔gRPC transport | `gql-transport.proto` (`@banxe/core`) | transport invariant — pin, never edit |
| Platform core base | `@banxe/core` (discovery / graphql / grpc / shared) | 88 importers |
| Connector mesh | `@banxe/common` (25 connectors) | **1429 importers** — highest blast radius |
| ABS contracts | `@abs/common` | ABS domain (emi-stack) consumes |
| Messaging | `@banxe/rabbit-mq` (RMQ patterns) | event/status consistency |
| Federation | apollo-gateway GraphQL federation schema | FE + gateway contract |

**No `banxe-platform` mutation; no scaffold; `@banxe/*` consumed from `banxe-shared-libs` as published
packages.** Each EMI backend substep (M2.1 payments / M2.2 accounts / M2.4 open-banking / M2.5 abs /
M2.6 sepa / M2.3 identity-auth) **declares a dependency on the pinned `@banxe/*` packages** and is
contract-tested against the baseline — rather than a one-off platform scaffold.

## 3. Mapping-v0 correction (supersedes the platform-core target rows)

| Item | Previous (incorrect) | Corrected |
|---|---|---|
| platform-core (`@banxe/core`/`@banxe/common`/`@abs/common`/`@banxe/rabbit-mq`) | `→ banxe-platform` (scaffold) | **consumed from `banxe-shared-libs`** (external packages; no platform-core repo) |
| `banxe-platform` | "backend platform-core" | **frontend Web+Mobile UI monorepo** (role pending the §1.B frontend audit) |
| `banxe-apollo-gateway` / `grpc-proxy-server` | `→ banxe-platform` | **TBD with §1.B / backend gateway home** — re-confirm in the frontend audit + M2 gateway substep |
| frontend (MIG-M1.7 shells) | `→ banxe-ui` | **deferred** — canonical target (`banxe-platform` vs `banxe-ui`) decided by the §1.B audit |

## 4. Impact on M2-sequencing

- **M2.7 (re-scoped)** = pin/consume `@banxe/*` contracts from `banxe-shared-libs` (this doc is the
  baseline record; per-service consumption wiring lands in each backend substep). No standalone
  platform scaffold step.
- **M2.2 → M2.1 → M2.6 → M2.4 → M2.5 → M2.3** (backend substeps) each **consume** the pinned `@banxe/*`
  contracts; order unchanged (accounts SoT before payments; rails after payments; etc.).
- **Frontend audit (pre-M2.8)** = new dedicated MIG substep (`banxe-platform` vs `banxe-ui`) before
  any frontend migration; M2.8 targets the audit's canonical frontend repo.
- **KYC/KYB/AML carve-out sign-off** remains the gate for M2.3 regulated slices (unchanged).

## 5. Status

- **MIG-M2.7 blocker (PR #612 / IL-370): RESOLVED** by operator decision → re-scoped to consume from
  `banxe-shared-libs`. No backend platform-core repo is created; no scaffold.
- **`banxe-platform` untouched** (no factory branch/scaffold); frontend role deferred to the §1.B audit.
- The pinned contract baseline (§2) is the canonical consumption contract for all M2 backend substeps.

## 6. Recommended next step

Either (operator's choice):
1. **Frontend roster audit** (`banxe-platform` Web+Mobile UI vs `banxe-ui`) — dedicated read-only MIG
   substep, precondition for M2.8; or
2. **MIG-M2.2** (accounts/balance SoT scaffold → `banxe-emi-stack`) — first backend M2 substep,
   consuming the pinned `@banxe/*` contracts (accounts SoT precedes payments per MIG-M1.3); advisory/
   read-only, paired backend-PR + arch IL-shard, no merge.

(Apply the §3 mapping-v0 correction alongside.)

## References
`docs/migration/MIG-M2.7-BLOCKER-platform-target-mismatch.md` (the blocker, IL-370, PR #612),
`MIG-M2.0-mapping-v0-update-and-shared-libs-dedup.md` (canonical = `banxe-shared-libs`), MIG-M1.6
(platform-core audit), MIG-M1.7 (frontends), MIG-M1.8 (acceptance); read-only `CarmiBanxe/banxe-platform`
(frontend), `banxe-ui`, `banxe-emi-stack`, `banxe-shared-libs`; ADR-102, ADR-103, ADR-059-A; MIG-M1/M2
roadmap.
