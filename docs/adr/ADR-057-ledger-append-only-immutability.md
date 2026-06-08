# ADR-057 — Ledger Append-Only Immutability Check

- Status: Proposed
- Date: 2026-06-08
- Deciders: Operator (CEO/CTIO), Central (Executor), Spec-First Auditor v2
- Related: ADR-056 (Ledger-Coupling Merge Gate), Invariant I-28 (INSTRUCTION-LEDGER append-only)
- Builds on: ADR-056

## Context

ADR-056 introduced `guardian-ledger`, which (a) requires a new `### IL-NNN` block when a PR changes tracked paths, and (b) rejects deletions in `INSTRUCTION-LEDGER.md` within the pull_request diff. Two residual gaps remain:

1. `guardian-ledger` runs only on `pull_request`. A direct `push` to `main` (or an admin bypass) is not checked for ledger immutability.
2. The deletion check protects against removed lines, but the canonical risk from IL-145 / PR #367 is the silent rewrite of an EXISTING IL block during conflict resolution — i.e. previously committed ledger history being mutated, not merely lines removed.

Invariant I-28 states the ledger is append-only: existing entries are immutable; only new entries may be added at the tail.

## Decision

Add a second, independent CI job `ledger-append-only` to `guardian.yml`:

1. Triggers on BOTH `pull_request` and `push` to `main` (defence in depth, independent of ADR-056).
2. Computes the diff of `INSTRUCTION-LEDGER.md` (base..head for PRs; before..after for pushes) and FAILS if any line is removed or modified — i.e. any `-` hunk line other than the diff header is present. Only pure additions are allowed.
3. Is independent of `guardian-ledger`: ADR-056 enforces the coupling (code => ledger entry); ADR-057 enforces immutability of prior ledger history. Either may fail independently.

## Consequences

- Positive: prior ledger entries become tamper-evident on every code path (PR and direct push); the IL-145 silent-rewrite class is closed even outside the PR flow.
- Positive: redundant with ADR-056 by design — two independent gates means a single misconfiguration cannot silently disable append-only enforcement.
- Negative: legitimate corrections to a historical IL block must be done by appending a new correcting IL entry (never by editing the old one), consistent with I-28.

## Verification

- `ledger-append-only` job present in `.github/workflows/guardian.yml` and green on this PR.
- Recorded as append-only entry IL-150.
- Operator action: add `ledger-append-only` to required status checks on `main` (alongside `guardian-ledger`).
