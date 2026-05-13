# Sprint 2: Role Passports

**Date:** 2026-05-14
**Status:** OPEN
**Depends on:** Sprint 1 (canon ratified)
**Blocks:** Sprint 3, Sprint 5

---

## Scope

Create a machine-readable role passport for each factory profession defined in canon Section 4. Passports codify who/what can do what, under which conditions, and with which tools. They are the authoritative source for HITL routing and Guardian gate evaluation.

---

## Prerequisites

- [ ] Sprint 1 complete (canon ratified)
- [x] HITL-MATRIX.yaml exists in banxe-architecture (referenced by `guardian/src/memory_loader.py`)
- [x] Guardian rule engines operational (F1-F8, P1-P8)
- [ ] MLRO and CTIO designations confirmed by Operator

---

## Work Items

| ID | Item | Owner | Status |
|----|------|-------|--------|
| S2-01 | Define passport schema (YAML) with fields: role_id, actor, permissions, tool_allowlist, gate_authority, risk_ceiling | Planner | PENDING |
| S2-02 | Create passport: Planner (Claude Code) | Planner | PENDING |
| S2-03 | Create passport: Executor (Aider) | Planner | PENDING |
| S2-04 | Create passport: Reviewer (Claude Code) | Planner | PENDING |
| S2-05 | Create passport: Factory Guardian | Planner | PENDING |
| S2-06 | Create passport: Project Guardian | Planner | PENDING |
| S2-07 | Create passport: Canon Judge | Planner | PENDING |
| S2-08 | Create passport: Operator (human) | Planner | PENDING |
| S2-09 | Create passport: MLRO (human) | Planner | PENDING |
| S2-10 | Create passport: CTIO (human) | Planner | PENDING |
| S2-11 | Validate passports against HITL-MATRIX.yaml consistency | Reviewer | PENDING |
| S2-12 | Store passports in `docs/canon/passports/` | Executor | PENDING |

---

## Deliverables

- [ ] `docs/canon/passports/schema.yaml` — passport field definitions
- [ ] `docs/canon/passports/*.yaml` — one passport per role (9 total)
- [ ] Consistency report: passports vs HITL-MATRIX.yaml vs canon Section 4

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| MLRO/CTIO not designated — passports will have placeholder actors | HIGH | MEDIUM | Create passports with actor=UNDESIGNATED; fill when confirmed |
| Passport schema may need iteration after Sprint 3 routing integration | MEDIUM | LOW | Schema versioning (v1); Sprint 3 may produce v1.1 |
| HITL-MATRIX.yaml may be stale relative to canon | MEDIUM | MEDIUM | S2-11 validates consistency; discrepancies escalated to Operator |

---

## Blockers

- **S2-09, S2-10:** MLRO and CTIO designations unknown. Passports created with placeholder actors.

---

## Exit Criteria

1. Passport schema defined and documented.
2. All 9 role passports created in `docs/canon/passports/`.
3. Consistency check between passports, HITL-MATRIX.yaml, and canon Section 4 passes with no BLOCK-level discrepancies.
4. Operator review of human role passports (S2-08, S2-09, S2-10).

---

## Rollback Assumptions

- Passports are documentation-only — no runtime behaviour depends on them until Sprint 3.
- Rollback = delete `docs/canon/passports/` directory.
