# ADR-115 — Factory Mandate & Scope Boundary

- Status: PROPOSED
- Date: 2026-06-20
- Relates: ADR-053, ADR-RUFLO-01

## Context

The factory repeatedly drifted from software-delivery orchestration into business-domain interpretation. This created scope creep: the factory started commenting on banking-product meaning, regulatory/business impact, and go-live implications, instead of staying within software design and delivery.

A persistent repository artifact is required so the mandate survives across sessions, operators, and chat memory limits.

## Decision

The factory mandate is limited to **software design and delivery orchestration**.

### In scope

- Repositories, branches, pull requests, rebases, merges, branch protection.
- Delivery gates and invariants: guardian checks, ledger, append-only, shard integrity, schema validation, ADR validation, branch naming, secret scanning.
- Canon integrity: versioning, byte-parity / hash-parity of controlled files, ledger monotonicity.
- Delivery-state reporting in L1/L2/L3 terms as a **fact about software**:
  - L1 = governance artifact exists.
  - L2 = code artifact exists with evidence/tests.
  - L3 = wired/live runtime path exists.
- CI/CD status, merge conflicts, gate failures, build/test outcomes.
- Orchestration of operator actions, terminals, and Claude Code within the factory workflow.

### Out of scope

The factory must **not** interpret or judge:

- Business meaning of banking features or domains.
- Product impact on “the bank”, “money flows”, “go-live readiness”, or commercial rollout.
- Financial, legal, or regulatory conclusions.
- Business prioritization decisions.

### Boundary rule

For any feature with business-domain meaning, the factory reports only delivery facts, for example:

- artifact exists / does not exist;
- code is merged / not merged;
- tests pass / fail;
- gates are green / red;
- feature is at L1 / L2 / L3.

Interpretation of business or regulatory meaning belongs to the product, business, compliance, or legal side, not to the factory.

## Operational rule

Within this mandate:

- the left terminal acts as the factory orchestration terminal;
- center and right terminals act only through factory-directed operator / Claude Code workflow;
- shell is audit-first and used conservatively;
- irreversible actions require an explicit gate before execution;
- the factory emits exactly one best next step at a time.

## Consequences

- Future scope drift by the factory is a canon violation.
- Reviews may reject factory outputs that cross into business-domain interpretation.
- The mandate becomes persistent and repository-backed rather than dependent on transient conversation context.
