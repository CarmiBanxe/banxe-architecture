# Sprint 7: Pilot Factory Pack

**Date:** 2026-05-14
**Status:** DONE
**Depends on:** Sprint 3 (routing enforcement), Sprint 4 (evaluation loop), Sprint 6 (evidence standard)
**Blocks:** Sprint 8

---

## Scope

Execute one complete factory loop end-to-end on a real work item, producing all five mandatory packs (P1-P5). This is the validation sprint — it proves the factory model works before full adoption.

---

## Prerequisites

- [ ] Sprint 3 complete (routing enforcement active)
- [ ] Sprint 4 complete (evaluation orchestrator mandatory)
- [ ] Sprint 6 complete (evidence pack generator and runbooks available)
- [ ] At least one backlog work item suitable for pilot (non-compliance-sensitive, MEDIUM complexity)
- [x] All Guardian rules (F1-F10, P1-P8) operational
- [x] Canon Judge MCP server operational

---

## Work Items

| ID | Item | Owner | Status |
|----|------|-------|--------|
| S7-01 | Select pilot work item from backlog (Operator approval) | Planner | DONE |
| S7-02 | **PLAN:** Create Instruction Pack (P1) for pilot item | Planner | DONE |
| S7-03 | **ROUTE:** Select model alias and validate against canon Section 5 | Planner | DONE |
| S7-04 | **EXECUTE:** Aider implements the work item, producing Execution Pack (P2) | Executor | DONE |
| S7-05 | **EVALUATE:** Run evaluation orchestrator, producing Evaluation Pack (P3) and Audit Pack (P4) | Reviewer | DONE |
| S7-06 | **REVIEW:** Claude Code reviews all verdicts and makes promote/defer decision | Reviewer | DONE |
| S7-07 | **APPROVE:** Run through approval gates (auto or Operator depending on risk) | Operator | DONE |
| S7-08 | **PROMOTE/DEFER:** Execute promote (merge PR) or defer (return to Plan with notes) | Executor | DONE |
| S7-09 | **EVIDENCE:** Generate Evidence Pack (P5) from P1-P4 + approval record | Executor | DONE |
| S7-10 | Retrospective: document what worked, what failed, what needs adjustment | Planner | DONE |

---

## Deliverables

- [ ] Complete P1-P5 pack set for the pilot work item
- [ ] All packs stored in `docs/audit/pilot/` or equivalent
- [ ] Retrospective document with findings and canon amendment proposals (if any)
- [ ] Timing data: latency for each loop phase

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Pilot exposes gaps in Sprint 3-6 implementations | HIGH | MEDIUM | This is expected — pilot is a validation sprint. Gaps are documented, not blockers |
| Pilot work item is too simple to exercise all gates | MEDIUM | MEDIUM | Select item that touches at least one compliance-adjacent path to exercise MLRO gate |
| Evaluation orchestrator fails on real diff (only tested on samples so far) | MEDIUM | MEDIUM | Run orchestrator manually first; debug before wiring into loop |
| Timing data shows unacceptable latency | MEDIUM | LOW | Document as finding; Sprint 8 addresses performance if needed |

---

## Blockers

- **S7-01:** Requires Operator to select and approve a pilot work item.

---

## Exit Criteria

1. One complete factory loop executed end-to-end.
2. All five packs (P1-P5) produced and stored.
3. At least 14 of 18 Guardian rules evaluated (F1-F10, P1-P8) — remaining rules may not apply to pilot item.
4. Canon Judge evaluation completed on pilot output.
5. Retrospective document produced with:
   - Phase timing data.
   - List of gaps or failures encountered.
   - Canon amendment proposals (if any).
6. Operator review of pilot results.

---

## Rollback Assumptions

- Pilot is a real work item — rollback of the work item itself follows standard git revert.
- Factory infrastructure (evaluation orchestrator, approval router, evidence generator) is not modified during pilot — Sprint 7 is execution-only.
- If pilot fails catastrophically, defer to Sprint 8 with findings; do not abandon the factory model.
