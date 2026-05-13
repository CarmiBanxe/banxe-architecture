# Sprint 5: Approval Model and Ruflo Gate

**Date:** 2026-05-14
**Status:** OPEN
**Depends on:** Sprint 2 (role passports), Sprint 4 (evaluation loop)
**Blocks:** Sprint 7

---

## Scope

Implement the approval model defined in canon Section 8. Wire evaluation verdicts into approval gates (Operator, MLRO, CTIO). Integrate or define the Ruflo regulated checkpoint as the single auditable approval surface.

---

## Prerequisites

- [ ] Sprint 2 complete (role passports with gate_authority fields)
- [ ] Sprint 4 complete (evaluation orchestrator producing combined verdicts)
- [x] Operator override pattern exists in `project_rules.py` (P1 rule)
- [x] HITL-MATRIX.yaml referenced by Guardian
- [ ] Ruflo tool/process specification [UNKNOWN — not in repo]

---

## Work Items

| ID | Item | Owner | Status |
|----|------|-------|--------|
| S5-01 | Define Ruflo checkpoint contract: inputs (evaluation verdict, pack references), outputs (approved/rejected, signer, timestamp) | Planner | PENDING |
| S5-02 | Implement approval router: maps evaluation verdict + touched paths to required gate (auto/Operator/MLRO/CTIO) | Executor | PENDING |
| S5-03 | Implement Operator gate: notification mechanism + approval capture | Executor | PENDING |
| S5-04 | Implement MLRO gate: compliance-sensitive path detection + sign-off capture | Executor | PENDING |
| S5-05 | Implement CTIO gate: architecture-change detection + sign-off capture | Executor | PENDING |
| S5-06 | Implement Ruflo checkpoint wrapper: aggregates all gate results into a single auditable record | Executor | PENDING |
| S5-07 | Persist Ruflo checkpoint records in ClickHouse (`ruflo_checkpoints` table) | Executor | PENDING |
| S5-08 | Wire approval router into the factory operating loop (between Review and Promote/Defer) | Executor | PENDING |
| S5-09 | Add tests for approval routing logic | Executor | PENDING |
| S5-10 | Update canon Section 8.5 with Ruflo implementation details | Planner | PENDING |

---

## Deliverables

- [ ] `guardian/src/core/approval_router.py` — approval routing engine
- [ ] `guardian/src/storage/ruflo_checkpoint.py` — ClickHouse persistence for Ruflo records
- [ ] ClickHouse migration: `ruflo_checkpoints` table schema
- [ ] Canon Section 8.5 updated (no longer UNKNOWN)
- [ ] Tests for approval routing

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Ruflo is not defined anywhere in the repo — entire integration is speculative | HIGH | HIGH | S5-01 defines the contract first; Operator must approve before implementation |
| MLRO not designated — MLRO gate cannot be tested end-to-end | HIGH | MEDIUM | Implement gate logic; test with mock signer; Operator acts as interim MLRO |
| CTIO not designated — same as MLRO | HIGH | MEDIUM | Same mitigation |
| Approval routing may create bottlenecks if human gates are slow | MEDIUM | MEDIUM | Define SLA for gate response (e.g., 24h); auto-escalate on timeout |
| ClickHouse schema migration may conflict with existing Guardian tables | LOW | MEDIUM | New table only; no ALTER on existing tables |

---

## Blockers

- **S5-01:** Ruflo specification is UNKNOWN. This work item must be completed first and approved by Operator before any implementation proceeds.
- **S5-04, S5-05:** MLRO and CTIO designations required for end-to-end testing.

---

## Exit Criteria

1. Ruflo checkpoint contract is defined and approved by Operator.
2. Approval router correctly maps evaluation verdicts to gates per canon Section 8.
3. All three human gates (Operator, MLRO, CTIO) have implementation with sign-off capture.
4. Ruflo checkpoint records are persisted in ClickHouse with 5-year TTL.
5. Full factory loop operates with approval gates (tested end-to-end on a sample work unit).
6. Canon Section 8.5 is no longer marked UNKNOWN.
7. Operator review and approval of the complete approval model implementation.

---

## Rollback Assumptions

- Approval router is a new component — removal restores the prior manual approval pattern.
- ClickHouse `ruflo_checkpoints` table is new — DROP TABLE is safe (no data loss from existing tables).
- Canon Judge remains in audit mode — removal of approval gates does not create an enforcement gap.
