# Sprint 8: Full Factory Adoption

**Date:** 2026-05-14
**Status:** OPEN
**Depends on:** Sprint 7 (pilot complete with acceptable results)
**Blocks:** None (terminal sprint)

---

## Scope

Adopt the software factory model across all CarmiBanxe repositories. Resolve all findings from the Sprint 7 pilot. Transition from audit mode to enforcement mode for Canon Judge. Declare factory operational.

---

## Prerequisites

- [ ] Sprint 7 complete with retrospective
- [ ] All Sprint 7 gaps resolved or accepted as known limitations
- [ ] MLRO designated (or Operator confirms interim arrangement is permanent)
- [ ] CTIO designated (or Operator confirms interim arrangement is permanent)
- [ ] Canon amendments from Sprint 7 retrospective ratified (if any)

---

## Work Items

| ID | Item | Owner | Status |
|----|------|-------|--------|
| S8-01 | Resolve all Sprint 7 retrospective findings (bugs, gaps, performance) | Executor | PENDING |
| S8-02 | Apply canon amendments from Sprint 7 retrospective (if any) | Planner | PENDING |
| S8-03 | Transition Canon Judge from audit mode to enforcement mode (WARN/BLOCK verdicts block promotion) | Executor | PENDING |
| S8-04 | Enable factory loop for banxe-emi-stack repositories | Executor | PENDING |
| S8-05 | Enable factory loop for MetaClaw repository | Executor | PENDING |
| S8-06 | Update all repo CLAUDE.md files to reference factory canon | Executor | PENDING |
| S8-07 | Update COLLAB.md v3.0 to reference factory operating loop | Executor | PENDING |
| S8-08 | Create factory operational dashboard (ClickHouse queries: verdicts, approvals, deferrals, cycle time) | Executor | PENDING |
| S8-09 | Define ongoing canon review cadence (quarterly review cycle) | Planner | PENDING |
| S8-10 | Operator sign-off: factory is operational | Operator | PENDING |

---

## Deliverables

- [ ] All Sprint 7 findings resolved (or documented as accepted limitations)
- [ ] Canon Judge in enforcement mode across all repos
- [ ] Factory loop enabled for all CarmiBanxe repositories
- [ ] Updated CLAUDE.md and COLLAB.md references
- [ ] Factory operational dashboard (queries or script)
- [ ] Quarterly review schedule documented in canon
- [ ] Operator sign-off record

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Canon Judge enforcement mode causes excessive BLOCKs on legitimate work | MEDIUM | HIGH | Gradual rollout: enable enforcement on MetaClaw first (lower risk), then banxe-emi-stack |
| Cross-repo factory loop requires consistent tooling versions | MEDIUM | MEDIUM | Pin Guardian, Canon Judge, evaluation orchestrator versions in each repo |
| Performance degradation at scale (more repos = more evaluations) | LOW | MEDIUM | ClickHouse handles audit volume; evaluation runs per-repo not globally |
| Team resistance to mandatory factory loop | LOW | HIGH | Pilot results (Sprint 7) demonstrate value; Operator mandate |

---

## Blockers

- **S8-03:** Canon Judge mode transition requires Operator approval (risk of false BLOCKs).
- **S8-04:** banxe-emi-stack access and CLAUDE.md update authority required.

---

## Exit Criteria

1. All Sprint 7 findings resolved or documented as accepted limitations.
2. Canon Judge is in enforcement mode (audit mode disabled).
3. Factory loop is enabled and operational for all target repositories.
4. At least 3 work items completed through the full factory loop post-adoption (proving sustained operation).
5. Factory operational dashboard shows data from real work items.
6. Quarterly review schedule is documented in the canon.
7. Operator has signed off that the factory is operational.

---

## Rollback Assumptions

- Canon Judge can be reverted to audit mode at any time (config change, no code change).
- Factory loop can be disabled per-repo by removing the evaluation hook.
- CLAUDE.md and COLLAB.md changes are git-tracked and revertible.
- ClickHouse data persists regardless of factory mode — audit trail is not lost on rollback.
- Full rollback to pre-factory state: revert CLAUDE.md, COLLAB.md, disable evaluation hooks, set Canon Judge to audit mode. Estimated rollback time: <1 hour.

---

## Post-Adoption

After Sprint 8 exit criteria are met:

1. Factory model is the default operating mode for all CarmiBanxe work.
2. Canon is reviewed quarterly (canon Section 11).
3. New repos are onboarded with factory configuration as part of repo setup.
4. Factory metrics (cycle time, defer rate, BLOCK rate) are tracked in the operational dashboard.
5. Canon amendments follow the process defined in canon Section 11.
