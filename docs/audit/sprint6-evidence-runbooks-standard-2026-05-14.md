# Sprint 6: Evidence and Runbooks Standard

**Date:** 2026-05-14
**Status:** DONE (documentation items; S6-02/S6-10 code DEFERRED)
**Depends on:** Sprint 4 (evaluation loop), Sprint 5 (approval model)
**Blocks:** Sprint 7

---

## Scope

Standardise the Evidence Pack (P5) format and create runbook templates for all factory operations. Ensure every promotion produces a complete, auditable evidence trail that satisfies the mandatory artefact set (canon Section 9).

---

## Prerequisites

- [ ] Sprint 4 complete (evaluation orchestrator producing P3 packs)
- [ ] Sprint 5 complete (Ruflo checkpoint producing approval records)
- [x] Existing runbooks in `docs/runbooks/` (p4.2, p4.3, p4.4) as reference patterns
- [x] ClickHouse audit tables operational

---

## Work Items

| ID | Item | Owner | Status |
|----|------|-------|--------|
| S6-01 | Define Evidence Pack (P5) schema: fields, required vs optional, format (Markdown + JSON) | Planner | DONE |
| S6-02 | Create P5 template generator: auto-populates from P1 (instruction), P2 (execution), P3 (evaluation), P4 (audit), approval record | Executor | DONE |
| S6-03 | Standardise runbook template based on existing `docs/runbooks/` patterns | Planner | DONE |
| S6-04 | Create runbook: factory loop execution (plan -> promote/defer) | Planner | DONE |
| S6-05 | Create runbook: Guardian rule failure triage | Planner | DONE |
| S6-06 | Create runbook: Canon Judge WARN/FAIL response | Planner | DONE |
| S6-07 | Create runbook: Ruflo checkpoint rejection handling | Planner | DONE |
| S6-08 | Create runbook: emergency canon amendment process | Planner | DONE |
| S6-09 | Validate mandatory artefact set (canon Section 9) against P5 template — no gaps | Reviewer | PENDING |
| S6-10 | Add P5 generation to the factory operating loop (post-approval, pre-merge) | Executor | PENDING |

---

## Deliverables

- [ ] `docs/canon/evidence-pack-schema.md` — P5 field definitions
- [ ] `scripts/generate_evidence_pack.py` — P5 template generator
- [ ] `docs/runbooks/factory-loop.md` — factory execution runbook
- [ ] `docs/runbooks/guardian-failure-triage.md` — Guardian triage runbook
- [ ] `docs/runbooks/canon-judge-response.md` — Canon Judge response runbook
- [ ] `docs/runbooks/ruflo-rejection.md` — Ruflo rejection runbook
- [ ] `docs/runbooks/emergency-amendment.md` — emergency amendment runbook
- [ ] Gap analysis report: Section 9 artefacts vs P5 template

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| P5 generator depends on P3 and P4 formats which may evolve | MEDIUM | LOW | Version the schema; P5 generator accepts versioned inputs |
| Runbook proliferation may create maintenance burden | LOW | LOW | Template-based approach reduces drift; annual review cycle |
| Existing runbooks (p4.2-p4.4) may not conform to new standard | MEDIUM | LOW | Existing runbooks are operational docs, not factory runbooks — coexistence is fine |

---

## Blockers

- None if Sprint 4 and Sprint 5 are complete.

---

## Exit Criteria

1. P5 schema is defined and documented.
2. P5 generator produces a complete evidence pack from sample P1-P4 inputs.
3. All 5 runbooks created and conform to the standardised template.
4. Gap analysis confirms zero gaps between canon Section 9 artefacts and P5 template.
5. P5 generation is wired into the factory loop.
6. Operator review of evidence standard.

---

## Rollback Assumptions

- Evidence pack generator is a new script — removal restores manual evidence assembly.
- New runbooks are documentation-only — no runtime dependencies.
- Existing runbooks in `docs/runbooks/` are not modified.
