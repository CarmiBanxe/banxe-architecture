# IL-COMP-01: Compliance Experiments Bootstrap

- Sprint: 42
- Status: PROPOSED
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: CarmiBanxe/banxe-emi-stack#3
- Created: 2026-04-27

## Context
The `compliance-experiments/` directory exists untracked in banxe-architecture since Sprint 41.
It contains a 4-state lifecycle registry (draft/active/finished/rejected) with `index.json`
tracking one draft experiment (transaction monitoring velocity checks). The directory was
explicitly excluded from Sprint 41 scope and deferred to a separate PR.

## Goal
Commit `compliance-experiments/` as a standalone PR in banxe-architecture, establishing the
compliance experiment registry as a first-class artefact under version control.

## Scope
- `compliance-experiments/index.json` — registry with 4-state lifecycle metadata
- `compliance-experiments/experiments/` — individual experiment files
- No changes to `.claude/*`, `CLAUDE.md`, `agents/*`, or any policy files
- No code logic, only documentation/registry artefacts

## Acceptance criteria
- [ ] `compliance-experiments/` fully committed and tracked in banxe-architecture main
- [ ] `index.json` validates: `total`, `by_status`, `experiments[]` with all required fields
- [ ] All experiment entries have: `id`, `title`, `scope`, `status`, `updated_at`, `has_pr`
- [ ] PR merged to main via GitHub UI (no direct push to main)
- [ ] No `.claude/*`, `CLAUDE.md`, or policy files modified

## Implementation notes
- Branch: `feat/compliance-experiments-bootstrap`
- Commit message: `feat(compliance): bootstrap compliance-experiments registry`
- The single existing draft experiment: `exp-2026-04-tran-improve-velocity-checks-for-st`
- Status transitions: draft → active (requires ADR + IL entry) → finished/rejected

## Risks and mitigations
- Risk: index.json schema drift over time → Mitigation: define JSON schema in `compliance-experiments/schema/`
- Risk: stale experiments never progressed → Mitigation: quarterly review gate in IL lifecycle

## Related
- Sprint 41 banxe-architecture PR #9 (deferred from there)
- `compliance-experiments/index.json` (existing file, untracked)
- IL-DOC-01 (ADR for Phase 56 artefacts)
