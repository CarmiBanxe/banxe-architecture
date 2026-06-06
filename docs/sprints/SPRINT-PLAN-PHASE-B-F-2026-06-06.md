# Sprint Plan — Phase B-F (Terminal B)
**Date:** 2026-06-06 CEST · **Base:** origin/main @ acfb13c (#325 CONSOLIDATED 270) · **Branch:** feat/docs-refactor-SPRINT-PLAN-and-TRANSFER-2026-06-06
**House rules:** 11 (best-solution) · 12 (sequential) · 10 (coordination-via-merge) · split-large-commands

## Context
- 29 legacy refactor SPEC/CONTRACT files now live on main via consolidated push (#325).
- 7 claims in UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md remain UNVERIFIED.
- Active blockers (CEO action): BT-001 Modulr, BT-005 Companies House, BT-010 FCA RegData.
- Coordination: avoid duplicating central terminal (best-solution). All docs-only, no production zones.

## Sprint 1 — Verification & Planning (this branch)
### IL-110 — Verify legacy discovery claims
- Resolve 7 UNVERIFIED claims in docs/project/UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md.
- Mark each VERIFIED / REJECTED with evidence (commit/file ref). No code changes.
### IL-111 — Sprint backlog
- docs/sprints/BACKLOG.md: open BT blockers + CEO actions + per-SPEC implementation order from PRIORITY-MAP (C1-C30).

## Sprint 2 — Phase B: Contract Layer
### IL-112 — Implement 6 CONTRACT SPECs (ports)
- Per file: kyc-provider-port, crm-port, exchange-port, notification-port, wallet-port, emi-banking-partnerport.
- Order from NEW-PROJECT-PRIORITY-MAP-2026-06-06.md. One port = one PR (split-large-commands).
- Each PR: CHANGELOG + RUNBOOK + ONBOARDING + API.md (I-29) + tests.

## Sprint 3 — Phase C: Design SPEC implementation
### IL-113 — 21 design SPECs by priority band
- Bands C1-C10 (Sprint 3a), C11-C20 (3b), C21-C30 (3c).
- Invariants enforced: I-01 Decimal GBP, I-02 hard-block sanctioned, I-24 append-only audit, I-27 HITL supervised.

## Sprint 4 — Phase D: Shared libs + remainder
### IL-114 — shared-libs, crypto-utils, tail/merge-remainder
- Consolidate shared-libs-SPEC, crypto-utils-libs-SPEC, crypto-api-keys-lib-SPEC.
- Sweep tail-remainder + merge-remainder SPECs.

## Sprint 5 — Phase E: Integration + ADR
### IL-115 — ADRs for new components + integration tests
- ADR per major port/component; update GAP-REGISTER + COMPLIANCE-MATRIX.

## Sprint 6 — Phase F: Doc-sync + closure
### IL-116 — doc-sync verification + finops review closure
- scripts/doc-sync.py --commit HEAD; finops-review-closure-SPEC sign-off.

## Exit conditions (all sprints)
- guardian-factory + guardian-project green in statusCheckRollup on main.
- 6534+ tests passing. IL entry after each step (I-28).
