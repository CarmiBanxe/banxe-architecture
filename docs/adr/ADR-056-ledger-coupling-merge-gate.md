# ADR-056 — Ledger-Coupling Merge Gate

- Status: Proposed
- Date: 2026-06-08
- Deciders: Operator (CEO/CTIO), Central (Executor), Spec-First Auditor v2
- Related: ADR-045 (Intent-First), ADR-046 (Decision Lineage / AgentDecisionRecord), ADR-047 (AI Cost Governance), Invariant I-28 (INSTRUCTION-LEDGER append-only)
- Supersedes: none

## Context

The factory records every CEO/CTIO instruction as an append-only block in `INSTRUCTION-LEDGER.md` (Invariant I-28). Today this invariant is enforced only by convention plus human/CodeRabbit review. The existing CI gates `guardian-factory` and `guardian-project` (`.github/workflows/guardian.yml`) check filesystem invariants only and do NOT inspect the ledger.

Real failure (IL-145 / PR #367): during parallel sessions a ledger change was lost in conflict resolution, allowing product artifacts (SPEC files) to reach the repository without a corresponding ledger entry. IL-145 retroactively closed the gap, but nothing prevents a recurrence.

## Decision

Introduce a third required CI job `guardian-ledger` in `guardian.yml` that couples substantive changes to a ledger append:

1. If a pull request changes any tracked product/governance path (code, `*spec*`, `docs/adr/ADR-*`, `agents/`), then the same PR MUST add at least one new `### IL-NNN` block to `INSTRUCTION-LEDGER.md`.
2. The job MUST verify the change to `INSTRUCTION-LEDGER.md` is append-only: zero deleted/modified existing lines (additions only).
3. Docs-only ledger PRs (ledger is the only changed file) are exempt from rule 1 but still subject to rule 2.
4. `guardian-ledger` is added to branch protection on `main` as a required status check.

## Consequences

- Positive: the IL-145/PR-367 class of failure (silent ledger loss) becomes machine-blocked; append-only (I-28) is enforced by CI, not convention.
- Positive: aligns with ADR-046 decision-lineage by guaranteeing every substantive action is ledgered.
- Negative: contributors must always co-author a ledger block; emergency docs-only bypass remains via the documented `--no-verify` rule (docs-only commits only, bypass fact recorded in commit message).

## Verification

- `guardian-ledger` job present in `.github/workflows/guardian.yml` and green on this PR.
- Required status check enabled in branch protection for `main` (operator action).
- Recorded as append-only entry IL-149 in `INSTRUCTION-LEDGER.md`.
