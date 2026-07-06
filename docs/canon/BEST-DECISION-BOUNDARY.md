# BEST-DECISION-BOUNDARY

## Purpose

This canon defines where **best-decision** applies and where it must not apply.

## Orchestrator scope

Best-decision applies to the Orchestrating Terminal / Factory when choosing the best next step outside auto-run whitelists and outside stop-barriers.

The orchestrator continues without a counter-question unless a real stop-barrier is present: data loss risk, irreversible action, invariant breach, or governance / HITL risk.

This rule is anchored in the existing canon and is pointer-first, not restated here.

## Runtime-agent scope

Best-decision does **not** apply to runtime L2+ agents on payment, compliance, KYC, or AML contours.

These agents must fail-closed on ambiguity and escalate through the defined HITL path.

A runtime agent never best-decides to:
- clear a sanctions hit;
- release a payment;
- self-escalate a level;
- bypass a gate.

On the compliance / payment contour, fail-closed and HITL precedence override any orchestrator convenience.

## Where SOULs encode this

Runtime SOULs already encode the decision method through:
- Constraints;
- Escalation;
- HITL Workflow;
- Core Truths.

No dedicated decision-method section is added to `agents/souls/_TEMPLATE.md`.

## Precedence

Best-decision is additive only.

It never overrides:
- regulatory obligations;
- invariants;
- ADR boundaries;
- quality gates;
- HITL gates.

## Anchors

- `CLAUDE.md` §12
- `.claude/rules/approval-rules.md`
- `.claude/rules/agents.md`
- `AGENTS.md`
- `canon/rules/DIALOGUE.md`
- `I-27`
- `BUG-007`
