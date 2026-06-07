# ADR-052 — Canon Enforcement Runtime

**Status:** Proposed (awaiting operator sanction)
**Date:** 2026-06-07
**Authors:** Perplexity Factory Terminal
**Invariants:** I-27, I-71, I-74, I-75, I-76, I-77, I-78
**Amendments:** TBD

## Context

The canon now defines enforcement governance — Canon Enforcer (I-76/I-77) and Enforcement Supervisor (I-78) — and a dual-PASS gate before merges (ADR-051, IL-129). However, these agents exist only as governance text: there is no defined runtime that instantiates and executes them. Without a runtime, enforcement is non-binding and drift can recur (the exact failure mode found in the 2026-06-07 audit: spec-build bypassing LiteLLM, idle local stack).

This ADR defines HOW the enforcement agents run, so that governance becomes mechanically binding rather than advisory.

## Decision

Enforcement agents run as **operator-invoked, audited runtime units**, not as always-on daemons (to preserve cost governance per ADR-047 and HITL control per I-27):

1. **Canon Enforcer (I-76/I-77)** — runs as a CI gate + on-demand CLI. On every PR into `main`, it validates the change against canonical invariants and ADRs, emitting `PASS` / `FAIL` with a machine-readable reason.
2. **Enforcement Supervisor (I-78)** — independent second reviewer. A merge requires **dual PASS** (Enforcer + Supervisor). Disagreement escalates to HITL (I-27), never auto-resolves.
3. **Audit fallback (mandatory):** if either agent is unavailable or errors, the gate is **fail-closed** — merge is blocked and the event is logged to the Instruction Ledger. No silent bypass.
4. **Provenance:** every enforcement run records inputs, decision, and SHA to the append-only ledger (IL-NNN), satisfying I-75 (compute audit) and I-74 (traceability).

## Runtime Topology

- **Trigger:** PR opened/updated against `main`, or operator on-demand invocation.
- **Execution layer:** factory-managed (zone Terminal A) — wired into the same guardian checks (`guardian-factory`, `guardian-project`) already gating PRs.
- **Override path:** HITL-only (I-27); overrides are themselves ledgered.
- **No bypass of branch protections.**

## Consequences

Upon operator sanction, the factory (zone Terminal A) wires Enforcer + Supervisor into the guardian check pipeline, and ADR-044/§19 are amended to reference this runtime. Until sanction, status remains "Proposed"; current manual dual-PASS discipline continues. This ADR does not itself modify the factory engine — it specifies the contract the engine must implement.

## References

ADR-044, ADR-047, ADR-051, §19 (Canon Enforcement Agents), I-27, I-74, I-75, I-76, I-77, I-78, IL-129.
