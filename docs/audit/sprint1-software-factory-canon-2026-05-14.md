# Sprint 1: Software Factory Canon Ratification

**Date:** 2026-05-14
**Status:** OPEN
**Depends on:** None (root sprint)
**Blocks:** Sprint 2, Sprint 3, Sprint 4, Sprint 5, Sprint 6, Sprint 7, Sprint 8

---

## Scope

Ratify `docs/canon/software-factory-canon-v1.md` as the binding operating document for the role-based software factory. Establish the canon as the single source of truth for factory governance.

---

## Prerequisites

- [x] Guardian two-family architecture deployed (`guardian/src/rules/`)
- [x] Canon Judge MCP server operational (`guardian/src/canon_judge/mcp/server.py`)
- [x] COLLAB.md v3.0 in place (`docs/COLLAB.md`)
- [x] LiteLLM gateway configured (`litellm/litellm-config.v2.yaml`)
- [x] Aider MCP integration active (`.aider.conf.yml`, Qoder stdio)
- [ ] Operator review of canon v1.0 draft

---

## Work Items

| ID | Item | Owner | Status |
|----|------|-------|--------|
| S1-01 | Draft software-factory-canon-v1.md | Planner (Claude Code) | DONE |
| S1-02 | Cross-reference all invariants against existing ADRs | Planner | DONE |
| S1-03 | Identify unevidenced capabilities and mark as UNKNOWN | Planner | DONE |
| S1-04 | Operator review and sign-off | Operator | PENDING |
| S1-05 | Merge canon to main branch | Executor (Aider) | BLOCKED on S1-04 |
| S1-06 | Add canon reference to `docs/roadmap/INDEX.md` | Executor | BLOCKED on S1-05 |

---

## Deliverables

- [x] `docs/canon/software-factory-canon-v1.md` — complete, all sections populated
- [ ] Operator sign-off record (PR approval or commit message)
- [ ] Roadmap index updated with canon pointer

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Canon references capabilities not yet implemented (Ruflo, promptfoo) | HIGH | MEDIUM | Marked as UNKNOWN with placeholders; Sprint 4/5 will fill gaps |
| MLRO/CTIO roles not yet designated | HIGH | LOW for Sprint 1 | Operator acts as interim until designation; does not block ratification |
| Canon may conflict with existing ADRs | LOW | HIGH | Cross-referenced in S1-02; ADR takes precedence until canon amendment |

---

## Blockers

- **S1-04:** Requires operator availability for review.

---

## Exit Criteria

1. Canon document exists at `docs/canon/software-factory-canon-v1.md`.
2. All 11 sections are populated (Sections 1-11 + Appendices A-B).
3. All unevidenced items are explicitly marked as UNKNOWN.
4. Operator has reviewed and approved (PR approval or equivalent).
5. Canon is referenced in `docs/roadmap/INDEX.md`.

---

## Rollback Assumptions

- Canon ratification is additive — it does not modify existing code or configuration.
- Rollback = revert the merge commit and remove the roadmap index entry.
- No Guardian rules or Canon Judge behaviour changes until Sprint 3+.
