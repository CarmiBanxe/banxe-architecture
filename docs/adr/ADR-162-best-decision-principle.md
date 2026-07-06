# ADR-162 — Best-decision principle as adoption-audit gate

**Date:** 2026-07-06
**Status:** PROPOSED
**Deciders:** Central (design owner), Terminal-B (Spec-Projects), Operator (accept + directive ratification)
**Replaces:** N/A
**Superseded by:** N/A
**References:** ADR-159 (§"Terminal-B Operating Algorithm"), ADR-161 (intake SSOT-persistence), ADR-102 (no restatement of canon), ADR-103 (server-only refactoring policy), ADR-119 (stable IL numbering), ADR-120 (per-session worktree), ADR-121 (destructive-action protection), ADR-153 (terminal topology), ADR-156 (sandbox / operator-gated sign-off), `.claude/rules/agents.md` §"HITL Confidence Thresholds" (BUG-007), `.claude/rules/approval-rules.md` §"Правило неоднозначности", CLAUDE.md §12 §71, `docs/canon/BEST-DECISION-BOUNDARY.md`, `docs/sources/best-decision-concept-2026-07-06.md`.

---

## Context

Two BANXE forces meet at the intake / adoption boundary:

1. **The best-decision canon** (`.claude/rules/approval-rules.md` §"Правило неоднозначности", CLAUDE.md §12) says: outside the whitelist and outside stop-barriers, Claude Code / the orchestrator picks the best option and proceeds — no counter-question. This gives the pipeline throughput.
2. **The fail-closed / HITL canon** (I-27, `.claude/rules/agents.md` §BUG-007, CLAUDE.md §71) says: L2+ runtime agents block below confidence AUTO thresholds; merges are operator-gated. This gives the pipeline safety.

Between these two, a **gap** exists that the pipeline has been navigating informally: **who evaluates whether an intake finding is worth adopting, and by what discipline?** Concretely:

- Semantic novelty (ADR-159 §D-3) tells us an item is *novel* — not that it is *worth adopting*.
- The register + queue tell us an item is *observed* — not that it is *strategic*.
- The best-decision canon tells us that when in doubt the orchestrator proceeds — but "proceeds" needs a target: what does "adoption" look like operationally?

The class-defect test (§ADR-161) that recovered the "Лучшее Решение" concept surfaced this gap: a rich academic input was consumed, novelty passed, but there was no canonical answer to "does BANXE adopt this? which method? with which criteria?" — the orchestrator had to invent one on the fly, which is precisely the shape of divergence the fail-closed canon is meant to prevent when it matters.

This ADR closes the gap **without** loosening fail-closed and **without** granting runtime autonomy.

---

## Decision

### D-1 — Introduce the best-decision adoption-audit gate

A **best-decision adoption-audit** gate is inserted into the ADR-159 hand-off chain, **between QUEUE picked-up (post semantic-scoring) and ROADMAP-MATRIX update** (see `docs/canon/BEST-DECISION-BOUNDARY.md` §2 for the diagram; ADR-102 pointer only). The gate is owned by **Central**, exercises the orchestrator best-decision canon, and produces one of three terminal outcomes:

- **ACCEPT** → ROADMAP-MATRIX append + sprint-task + QUEUE `planned → sprint#` → `processed`.
- **REJECT-AS-NOT-WORTH** → QUEUE `not-worth <criteria>` → `processed` (no PR).
- **DEFER** → QUEUE `defer <until-condition>` → revisited on trigger.

All three outcomes are **positive and auditable**; a `reject-as-not-worth` verdict is a proof that Central looked, not evidence of omission.

### D-2 — Multi-criteria evaluation set (references SSOT, no restatement)

The gate evaluates each item on the canonical criterion-set:

- **value / cost / risk / reversibility / strategic-fit (EMI-scope) / opportunity-cost.**

Method selection (EU / MAUT / AHP / TOPSIS / minimax-regret / satisficing / real-options / VoI) is per the item's regime (SSOT §16 step 2). Formal definitions of every method and criterion live in **`docs/sources/best-decision-concept-2026-07-06.md`** and are not restated in this ADR (ADR-102 §"no restatement of canon"). The operational surface — the six-criterion checklist — lives in `docs/canon/BEST-DECISION-BOUNDARY.md` §3.

### D-3 — Config-over-Hardcoding for thresholds

Any numeric threshold used by the gate (weights, satisficing floor, maxmin-alpha, secretary-rule window) lives in **config**, not in this ADR and not in code (CLAUDE.md §10 Config-over-Hardcoding). The Central-owned config file is `governance/novelty-pipeline-config.yaml` (see ADR-159 §D-4). Adding gate-specific keys is a follow-up config-PR, not part of this ADR.

### D-4 — Preconditions from ADR-161

The gate reads from the **persisted SSOT** established by ADR-161. Every item entering the gate MUST have a `docs/sources/<slug>-<date>.md` reference in its register row `rationale`. An item without a persisted SSOT is a canon violation (ADR-161 §D-2) and is **rejected at gate entry**, not evaluated — with an explicit `processed verdict=missing-ssot` in the QUEUE for operator triage.

### D-5 — Runtime posture is UNCHANGED

This ADR **does not** grant any autonomy to L2+ runtime agents. The fail-closed posture (I-27, `.claude/rules/agents.md` §BUG-007) stays as-is. The best-decision principle applies to **the orchestrator** in the intake / adoption / roadmap loop — Terminal-B, Central, factory — never to a runtime agent making an in-fabric call.

The **scope of best-decision inside the running fabric** is an OPEN governance question tracked as **DIRECTIVE B-BESTDEC-SCOPE-001** (see `docs/canon/BEST-DECISION-BOUNDARY.md` §7 and `governance/COORDINATION-NOTES.md`). Two variants (в-1 fail-closed-preserved / в-2 HITL-bounded runtime best-decide) are on the table; ratification is **operator-owned**. Until operator ratifies, the default is (в-1) — current fail-closed. **This ADR does not preempt that ratification.**

### D-6 — HITL merge preserved

All ACCEPT outcomes land as **draft PRs**; merge is operator-gated per CLAUDE.md §71 and ADR-156. Best-decision does not grant auto-merge. The gate produces an **audited proposal**, not a merged commit.

### D-7 — Tests

A canonical evidence-set lives in `tests/best-decision/`:

- **CASE-A** — `accept-high-value-low-cost`: item passes → `accept`.
- **CASE-B** — `reject-low-value-high-cost`: item fails → `reject-as-not-worth`.
- **CASE-C** — `credit-blocked`: item drifts to CREDIT (out-of-scope EMI, `B-EMI-CREDIT-GATE-001`) → `blocked-out-of-scope` (hard-fail).
- **CASE-D** — `uncertainty-eu`: ambiguity-heavy regime; expected `defer` or `accept` per pre-declared prior.

Validator: `python3 tests/best-decision/validator.py` prints per-case pass/fail; exit 0 = green.

---

## Consequences

**Positive**

- Central gains a canonical decision-shape for adoption; the orchestrator no longer invents evaluation criteria per item.
- `reject-as-not-worth` becomes a first-class terminal outcome — the pipeline can honestly refuse an item without silence.
- SSOT-persistence (ADR-161) is enforced at gate entry — audit-hole closed transitively.
- The fail-closed runtime discipline is preserved; no I-27 loosening.

**Negative / accepted trade-offs**

- The intake→roadmap latency grows by one gate step. The step is bounded and produces audit-trail.
- Central must publish a per-item adoption-audit note (short — criterion scores + method + verdict). This is a minor documentation obligation, offset by the value of auditability.

**Risks (mitigations noted)**

- **Ossification.** The gate becomes a rubber-stamp if criteria are not exercised. *Mitigation:* the test-suite (D-7) proves the gate can `reject` and `block`, not only `accept`.
- **Operator bottleneck at HITL merge.** *Mitigation:* unchanged — HITL is canon (CLAUDE.md §71). The gate does not add merge-approvals; it structures the pre-merge decision.
- **Runtime-scope creep.** Someone reads "best-decision" and applies it to a runtime agent. *Mitigation:* §D-5 and DIRECTIVE B-BESTDEC-SCOPE-001 explicitly hold the runtime scope OPEN and default to fail-closed.

---

## Open items

- **OI-1.** Operator ratification of DIRECTIVE B-BESTDEC-SCOPE-001 (в-1 or в-2). Until then, default is (в-1) — no runtime best-decision.
- **OI-2.** Config keys for the gate — weights, satisficing floors, method-selection defaults — added to `governance/novelty-pipeline-config.yaml` in a follow-up config-PR (out of scope here).
- **OI-3.** Optional machine hardening: a CI rule that a PR touching `NOVELTY-COLLECTION-REGISTER.md` must also touch `docs/sources/` (ADR-161 §D-5 advisory-first stance).

---

## Anchors (authoritative, pointer only — ADR-102)

- **`docs/canon/BEST-DECISION-BOUNDARY.md`** — normative operational canon this ADR formalises.
- **`docs/sources/best-decision-concept-2026-07-06.md`** — SSOT for the academic body of methods and criteria (VNM/EU, Bellman-MDP, MAUT, AHP, TOPSIS, NSGA-II, Pareto, satisficing, minimax-regret, prospect theory, real options, VoI, secretary rule).
- **`docs/adr/ADR-161-intake-ssot-persistence.md`** — the SSOT-persistence rule that D-4 depends on.
- **`docs/adr/ADR-159-ba-novelty-auto-handoff-pipeline.md`** — the hand-off pipeline into which this gate is inserted (between QUEUE and ROADMAP).
- **`.claude/rules/agents.md`** §"HITL Confidence Thresholds" (BUG-007) — the fail-closed runtime posture preserved by §D-5.
- **`.claude/rules/approval-rules.md`** §"Правило неоднозначности" — the orchestrator best-decision canon this ADR specialises for the adoption-audit gate.
- **CLAUDE.md §12** — the best-decision canon.
- **CLAUDE.md §71** and **`docs/adr/ADR-156-sandbox-mode-signoff-gates-removed.md`** — HITL merge gate (preserved by §D-6).
- **`governance/COORDINATION-NOTES.md`** — where DIRECTIVE B-BESTDEC-SCOPE-001 is tracked.
- **`tests/best-decision/`** — canonical evidence-set (CASE-A..CASE-D).
