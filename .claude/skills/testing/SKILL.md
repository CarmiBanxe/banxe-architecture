---
name: testing
description: Run the test/lint/security gate — pytest coverage, ruff, semgrep — at the canonical thresholds. Use before committing or when validating changes.
---

# Testing

## Tools
- `pytest` — tests.
- `ruff` — linting.
- `semgrep` — security analysis.

## Thresholds (canonical)
- Coverage: **≥ 80%**.
- Ruff errors: **0**.
- Semgrep findings: **0 critical**.

## Commands
```
pytest --cov --cov-report=term-missing
ruff check .
semgrep --config auto
```

## Auto-run rule
`pytest` / `ruff` / `semgrep` run **automatically without CEO confirmation** (they are on the auto-approved
whitelist — `.claude/rules/approval-rules.md`).

## Repo context
`banxe-architecture` is a **governance/docs repo with no pytest harness** — its gate is **`quality-gate.sh` +
semgrep** (plus `schemas/validate_schemas.py` for schema work). The `pytest` / coverage thresholds above
target the **code repos** (e.g. `banxe-emi-stack`). The thresholds are preserved; apply the gate appropriate
to the repo.

## Binding (factory canon)
This skill **is** the quality-gate discipline: no skill output, agent decision, or CEO instruction removes the
obligation to pass `quality-gate.sh` before a Product-Plane commit; if the gate fails, fix the root cause — do
not add skip flags (`.claude/rules/agents.md` — Skills Governance / Orchestration). Priority order: FCA >
invariants I-01..I-28 > ADRs > `quality-gate.sh` > IL > Skill.
