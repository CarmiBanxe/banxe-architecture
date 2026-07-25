# Phase-2 Master Code Migration Roadmap — Execution Phases and Verification Gates

**PHASE-2 EXECUTION / MASTER CODE-MIGRATION OVERVIEW / NO AUTO-DEPLOY / NO LEGAL STATUS**

## Purpose & scope

- This document is the master execution roadmap for code migration within the already-approved Phase-1 governance boundaries (Sprints 3–9, S-GATE-REPAIR, the S-A5/S-A6/S-A7 spine and their install-audits).
- It serves factory execution and consultant/operator orientation: it says in what order code may move and which gates must pass first.
- It does not authorize deploys and does not change legal/compliance positions; all such matters remain [counsel]/auditor. Phase-2 is an execution layer, not a new governance phase.

## Migration principles

- No silent code move — every move is recorded and traceable.
- Audit-first — no migration into a lane before that lane has an install-audit.
- Verification before migration — a constraint is proven before code depending on it moves.
- HITL on high-risk lanes — identity, ledger, gateway, payments require human sign-off.
- Rollback/cutover planning required before any high-risk move.
- No bypass of existing gates — LedgerPort, LedgerAgent, and the unified gateway/auth perimeter remain mandatory.

## Execution phases

**Phase A — Inventory and code-lift mapping**
- Purpose: enumerate basement/sidecar/draft code and map each family to a governed lane (Sprint-6 / S-A8 perimeter).
- Allowed: read-only inventory, classification, routing-sheet creation.
- Blocked: any code move, any deploy, any lane activation.
- Exit gate: inventory complete, every family assigned a candidate lane and owner.

**Phase B — Technical verification of constraints**
- Purpose: prove the stated constraints (no second ledger / no direct MCP→ledger writes, gateway coverage, identity/consent gating).
- Allowed: verification sprints (e.g. S-A6-VERIF), evidence collection, findings classification.
- Blocked: code move, remediation, deploy.
- Exit gate: each in-scope constraint classified Confirmed or Confirmed-with-caveats; Not proven / Broken routed to repair.

**Phase C — Low-risk / internal code lift within approved perimeters**
- Purpose: move low-risk, non-value-bearing code into governed lanes.
- Allowed: code lift for low-risk lane items with tests; evidence binding.
- Blocked: high-risk-lane moves; anything touching ledger/gateway/identity value paths.
- Exit gate: low-risk items lifted, green, and bound to their lane's audit.

**Phase D — Controlled migration of high-risk paths behind gates**
- Purpose: migrate identity/ledger/payments/gateway code behind the existing gates.
- Allowed: gated moves with HITL sign-off, rollback plan, and decision-trace, one route group at a time.
- Blocked: any move where the relevant gate (below) is not passed; any bypass of LedgerPort/LedgerAgent/gateway perimeter.
- Exit gate: each high-risk move passes its verification gate + rollback-readiness gate under HITL.

**Phase E — Post-migration audit and evidence consolidation**
- Purpose: prove the migrated state matches the target and bind evidence.
- Allowed: install-audit re-runs, evidence consolidation, Finding-ID binding.
- Blocked: new migrations before consolidation of the prior wave.
- Exit gate: post-migration audits green; evidence consolidated and referenced in the master roadmap.

## Lane-by-lane mapping

| Lane | Migration readiness | Required verification gate | HITL intensity | Rollback sensitivity | Likely first move type |
|---|---|---|---|---|---|
| S-A5 identity | audits done; ready for gated moves | Identity/consent gate | High | High (rights/consent) | Low-risk supporting code, then gated identity paths |
| S-A6 ledger/EMI | audit shell + S-A6-VERIF pending | Ledger no-direct-write gate | High | Very high (value-bearing) | Verification first; no move until confirmed |
| S-A7 gateway/web | audit shell; feeds S-GATE-REPAIR | Gateway perimeter gate | High | High (edge exposure) | Coverage expansion behind unified perimeter |
| S-GATE-REPAIR overlay | ready-for-execution (design) | Gateway perimeter + audit-evidence gates | High | High | External-gate proof, then route-group coverage |

## Verification gates

- **Identity/consent gate** — Prove: identity/KYC/KYB and consent checks guard the relevant paths (Sprint 8, S-A5). Evidence: A-IDV/A-KYC/A-KYB audit references, consent logging/decision-trace. If not passed: identity/consent-dependent moves blocked.
- **Ledger no-direct-write gate** — Prove: no second ledger; no direct MCP→ledger writes; all writes via LedgerPort+LedgerAgent under HITL (S-A6-VERIF). Evidence: architecture/config/code/operational evidence per the verification sprint. If not passed: ledger-path moves blocked; finding to repair backlog.
- **Gateway perimeter gate** — Prove: payments/ledger routes sit behind one unified gateway/auth/rate-limit perimeter (S-GATE-REPAIR). Evidence: traffic-path map, external-gate verdict, coverage plan. If not passed: gateway/payment moves blocked.
- **Audit-evidence gate** — Prove: the target lane's install-audit exists and its relevant checks are exercised. Evidence: install-audit with populated findings by Finding ID. If not passed: no move into that lane.
- **Rollback readiness gate** — Prove: a rollback/cutover plan exists and is exercised for the move. Evidence: rollback design + dry-run record. If not passed: high-risk move blocked.

## Blockers and freeze conditions

The Phase-2 roadmap remains partially blocked where:

- verification findings are Not proven or Broken;
- required install-audit evidence is missing;
- gateway perimeter proof is incomplete;
- rollback/cutover design is absent.

Such blockers do not reopen the Phase-1 roadmap. They feed either repair execution (S-GATE-REPAIR / S-A6) or project-brain design decisions. The frozen Phase-1 governance set stays frozen.

## Factory execution lanes

- **Factory may do autonomously (within existing controls):** inventory / code-lift mapping (Phase A), verification (Phase B), install-audit expansion, evidence consolidation (Phase E).
- **Design-only, under the project brain:** new migration domains, changes to risk lanes, new repair-plan classes, and any deploy/cutover authorization.

## What this roadmap does not do

- Does not reopen Phase-1 governance.
- Does not authorize migration by itself.
- Does not replace execution plans or install-audits.
- Does not assert compliance or readiness — all such matters remain [counsel]/auditor.


---
> **SUPERSEDED (2026-07-23):** consolidated into the single **GENERAL-LINE** roadmap → `../roadmap/GENERAL-LINE-ROADMAP-2026-07-23.md` (see its §4 mapping / §5 register). This file is retained for history; the GENERAL-LINE is the source of truth. IL-ledger unaffected.
