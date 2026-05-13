# Sprint 3: Routing Canon Enforcement

**Date:** 2026-05-14
**Status:** OPEN
**Depends on:** Sprint 1 (canon ratified), Sprint 2 (role passports)
**Blocks:** Sprint 4, Sprint 7

---

## Scope

Wire role passports into the Guardian rule engine so that factory routing decisions (who executes, which model, which approval gate) are enforced at runtime. Extend factory rules to validate route binding against canon Section 5.

---

## Prerequisites

- [ ] Sprint 1 complete (canon ratified)
- [ ] Sprint 2 complete (role passports in `docs/canon/passports/`)
- [x] Guardian `evaluate_all()` method operational
- [x] LiteLLM config with canonical aliases deployed
- [x] Factory rule F1 (prompt canon compliance) operational

---

## Work Items

| ID | Item | Owner | Status |
|----|------|-------|--------|
| S3-01 | New factory rule F9: Route alias validation — every LLM call must use a canonical alias from canon Section 5 | Executor | PENDING |
| S3-02 | New factory rule F10: Role-action validation — Executor (Aider) cannot perform Reviewer actions and vice versa | Executor | PENDING |
| S3-03 | Extend `memory_loader.py` to load role passports as a memory artefact (per ADR-020 pattern) | Executor | PENDING |
| S3-04 | Update Guardian auditor to include passport-based routing checks in `evaluate_all()` | Executor | PENDING |
| S3-05 | Add tests for F9 and F10 rules | Executor | PENDING |
| S3-06 | Validate that LiteLLM config aliases match canon Section 5 exactly (no drift) | Reviewer | PENDING |
| S3-07 | Document routing enforcement in canon Appendix A (new evidence row) | Planner | PENDING |

---

## Deliverables

- [ ] `guardian/src/rules/factory_rules.py` updated with F9, F10
- [ ] `guardian/src/memory_loader.py` updated to load passports
- [ ] `guardian/tests/test_routing_enforcement.py` — new test suite
- [ ] LiteLLM alias drift check (manual or scripted)
- [ ] Canon Appendix A updated

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Adding F9/F10 may break existing Guardian evaluate_all() contract | MEDIUM | HIGH | Tests first; run full Guardian test suite before merge |
| LiteLLM config has backup proliferation (20+ .bak files) — drift risk | MEDIUM | MEDIUM | S3-06 validates canonical config only; .bak files are not authoritative |
| Passport loading adds latency to Guardian pre-flight | LOW | LOW | Passport files are small YAML; cache TTL (60s) applies |

---

## Blockers

- None anticipated if Sprint 1 and Sprint 2 are complete.

---

## Exit Criteria

1. Factory rules F9 and F10 exist and pass their dedicated tests.
2. Guardian `evaluate_all()` includes routing validation without regression.
3. LiteLLM canonical aliases verified against canon Section 5 — zero drift.
4. Full Guardian test suite passes (existing F1-F8 + new F9-F10).
5. Operator review of new rules.

---

## Rollback Assumptions

- F9 and F10 are additive rules — removal restores prior behaviour.
- Rollback = revert factory_rules.py and memory_loader.py to pre-sprint state.
- Guardian cache (60s TTL) means rollback takes effect within one minute.
