# ADR-ADOPT3-UI-INTENT-FIRST — intent-first agent UI governance spec

**Status:** PROPOSED — NOT ACCEPTED. Design-only draft, no ADR number allocated, no code, no ledger mint.

## Context

#56 (GAP-080, intent-first agent UI) is the next unaddressed cluster-3 item now that SP41 consultant-verdicts are finalized and the 88-findings governance pass is applied; the quarantine PR #1133 established the precedent for how a PROPOSED-only, non-activated governance artifact set is packaged.

## Decision

Define the spec-level shape of an intent-first agent UI whose every user-visible action is backed by a real decision-lineage record and observability trace — this ADR decides governance wiring, not UI redesign or implementation.

## Scope

In scope: UI-to-lineage contract, UI-to-observability contract, XAI surfacing of confidence/reasoning at the point of user confirmation. Out of scope: any frontend code, component/library choice, visual design.

## Data / contract touchpoints

Every intent-driven UI action must be traceable to an ADR-046-shaped decision-lineage record (record_id, confidence_score, human_reviewed_by, correlation_id) and to a Langfuse/LiteLLM trace for the underlying model call — the UI is a consumer of both, not a new source of truth.

## Ties to existing governance

SP41 (consultant-driven governance posture), the 88-findings governance pass, ADR-046 (decision lineage), and ADR-168 (Langfuse/LiteLLM observability) define the compliance and quality baselines this UI must not violate; the UI reads from those records and traces rather than duplicating them.

## Open points / unknowns

Whether XAI surfacing (confidence/reasoning) is a new UI-side responsibility or purely a passthrough of ADR-046's reasoning_summary; whether cluster-3's UI work depends on the same Terminal-A orchestration-layer readiness flagged as a precondition elsewhere in the intent-layer work — both are UNKNOWN here and must be confirmed before any build.

## Consequences

This ADR alone does not create code, services, or ledger entries. If ratified, a follow-up factory task would turn this spec into a real build plan and companion ledger shard under an isolated worktree.

## References

Pointer-first only: SP41 adoption-finalization record, 88-findings governance doc, ADR-046, ADR-168, GAP-REGISTER entry for GAP-080, issue #56. None restated in full.
