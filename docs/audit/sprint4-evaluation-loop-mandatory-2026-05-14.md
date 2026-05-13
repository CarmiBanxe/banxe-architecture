# Sprint 4: Evaluation Loop — Mandatory

**Date:** 2026-05-14
**Status:** OPEN
**Depends on:** Sprint 3 (routing enforcement)
**Blocks:** Sprint 5, Sprint 7

---

## Scope

Make the evaluation phase (canon Section 7.4) mandatory and automated. Every Aider execution must trigger the full evaluation pipeline: pytest, ruff, Guardian 16-rule check, and Canon Judge LLM evaluation. Introduce promptfoo for adversarial evaluation of agent outputs.

---

## Prerequisites

- [ ] Sprint 3 complete (routing enforcement wired)
- [x] pytest operational (`tests/`)
- [x] ruff configured (referenced in global CLAUDE.md quality gate)
- [x] Guardian auditor operational (`guardian/src/core/auditor.py`)
- [x] Canon Judge MCP server operational (`guardian/src/canon_judge/mcp/server.py`)
- [ ] promptfoo installed and configured [NOT YET IN REPO]

---

## Work Items

| ID | Item | Owner | Status |
|----|------|-------|--------|
| S4-01 | Create evaluation orchestrator script that chains: pytest -> ruff -> Guardian -> Canon Judge | Executor | PENDING |
| S4-02 | Integrate evaluation orchestrator as post-execution hook in Aider MCP flow | Executor | PENDING |
| S4-03 | Install and configure promptfoo for adversarial evaluation | Executor | PENDING |
| S4-04 | Create promptfoo test suite: canon compliance adversarial cases | Executor | PENDING |
| S4-05 | Create promptfoo test suite: security boundary adversarial cases (injection, secret leak, sanctioned tech) | Executor | PENDING |
| S4-06 | Wire promptfoo into evaluation orchestrator as optional stage | Executor | PENDING |
| S4-07 | Define evaluation verdict aggregation: how multiple tool verdicts combine into a single PASS/WARN/BLOCK | Planner | PENDING |
| S4-08 | Populate Evaluation Pack (P3) template automatically from orchestrator output | Executor | PENDING |
| S4-09 | Add tests for evaluation orchestrator | Executor | PENDING |
| S4-10 | Document evaluation pipeline in canon (update Section 7.4) | Planner | PENDING |

---

## Deliverables

- [ ] `scripts/evaluate.py` or `guardian/src/core/evaluator.py` — evaluation orchestrator
- [ ] `promptfoo/` directory with config and test suites (S4-04, S4-05)
- [ ] Evaluation Pack (P3) auto-generated template
- [ ] Canon Section 7.4 updated with pipeline specification
- [ ] Tests for the orchestrator

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| promptfoo is not yet in the repo — installation may introduce dependency conflicts | MEDIUM | MEDIUM | Install in isolated venv or as dev dependency only |
| Mandatory evaluation may slow down the factory loop significantly | MEDIUM | MEDIUM | Measure baseline latency; set SLA (e.g., <60s for full pipeline) |
| Canon Judge in audit mode does not block — gap between evaluation and enforcement | LOW | LOW | Sprint 5 addresses enforcement gating; Sprint 4 is audit-only |
| Verdict aggregation logic may be contested | MEDIUM | LOW | Define clear rules in S4-07; operator can override |

---

## Blockers

- **S4-03:** promptfoo not currently in the repo. Must be installed. [UNKNOWN: whether promptfoo supports local-only LLM evaluation via Ollama — verify before installation.]

---

## Exit Criteria

1. Evaluation orchestrator exists and chains all four tools (pytest, ruff, Guardian, Canon Judge).
2. Orchestrator runs successfully on a sample diff and produces a combined verdict.
3. promptfoo installed with at least 2 adversarial test suites (canon compliance, security boundary).
4. Evaluation Pack (P3) template is auto-generated.
5. Full test suite passes including new orchestrator tests.
6. Operator review of verdict aggregation rules.

---

## Rollback Assumptions

- Evaluation orchestrator is a new script — removal restores prior manual evaluation.
- promptfoo is a dev dependency — removal does not affect production code.
- Canon Judge remains in audit mode throughout this sprint (no blocking behaviour).
