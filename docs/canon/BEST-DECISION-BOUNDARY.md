# BEST-DECISION-BOUNDARY — orchestrator best-decide vs runtime fail-closed

> **Canon.** Best-decision as a **governance gate** for BANXE. Additive to — never supersedes —
> `.claude/rules/approval-rules.md` §"Правило неоднозначности", CLAUDE.md §12, ADR-159 (B→A pipeline),
> ADR-161 (intake SSOT-persistence), `.claude/rules/safety-rules.md`, and the I-01..I-28 invariants.
>
> **Restatement rule (ADR-102):** the academic body of the best-decision concept
> (VNM/EU, Bellman-MDP, MAUT, AHP, TOPSIS, NSGA-II, Pareto, satisficing, minimax-regret, prospect
> theory, real options, VoI, secretary problem, ambiguity/robust) lives in
> **`docs/sources/best-decision-concept-2026-07-06.md`** — this canon **references** it, never
> restates it. Use that SSOT for definitions and formulas.

## 1. Purpose (what this canon is FOR)

The best-decision principle exists in BANXE for **two separate scopes** that this canon **holds
apart** so they do not collide:

- **Scope-1 — Orchestrator best-decide.** Applies to Terminal-B (Spec-Projects), Central, and the
  Software Factory in the intake / adoption / roadmap loop. Best-decision is exercised **by the
  orchestrator** with an operator HITL gate at merge. Novelty is **NEVER auto-adopted**; Central runs
  a **multi-criteria adoption-audit** (§3) that MAY reject an item as "not-worth" — a valid, positive
  outcome, not an omission.
- **Scope-2 — Runtime-agent best-decide (RATIFIED 2026-07-06 — variant-2).** Applies to L2+ agents
  inside the running fabric (mlro_agent, aml_check_agent, sanctions_check_agent, and any future
  runtime agent). The operator has **RATIFIED variant-2** of directive B-BESTDEC-SCOPE-001 (see §7):
  runtime agents apply the best-decision algorithm as an **execution method** —
  `enumerate options → score → satisfice → pick the best executing step` — strictly **inside a
  bounded HITL envelope** and **under fail-closed I-27 discipline**. No runtime autonomy is granted:
  the agent cannot override, waive, or bypass an operator decision, cannot cross a stop-barrier
  (irreversibility / invariant-breach / data-loss), and escalates on satisficing failure.
  Meaning-correction (operator-directed, 2026-07-06): "best-decision" is the algorithm by which
  the agent **executes** the operator's decision (and is trained by it), **not** the agent's right
  to decide adoption of novelty — that decision remains the **operator's**. This principle applies
  uniformly to **all agents** (factory-side and project-side) as the method of choosing the best
  **executing step**. See ADR-162 for the formal statement (pointer only, no restatement — ADR-102).

## 2. Where the gate sits (pipeline placement)

The best-decision gate is placed **between QUEUE and ROADMAP** in the ADR-159 §"Terminal-B Operating
Algorithm" hand-off chain — additive, no restatement (ADR-102 §"pointer only"):

```
NEW  →  QUEUE picked
             ↓
       [ semantic-scoring ≥ threshold ]
             ↓
       [ Central best-decision ADOPTION-AUDIT  ]   ← this gate (§3)
             │        ↓                 ↓
             │      ACCEPT           REJECT-AS-NOT-WORTH
             ↓                            ↓
        ROADMAP-MATRIX update      QUEUE ack: not-worth <criteria>
             ↓                            ↓
        sprint-task queued          processed (terminal, no PR)
```

Anchors (pointer only, no restatement — ADR-102): **ADR-159 §D-3** (two-stage novelty check),
**ADR-159 §"Terminal-B Operating Algorithm"** (hand-off chain), **ADR-161** (intake SSOT-persistence
— every input to the gate is a persisted `docs/sources/*` file).

## 3. Criteria (adoption-audit multi-criteria checklist)

Central's adoption-audit runs a **multi-criteria** evaluation over each queued finding using the
canonical BANXE criterion-set (formal definitions and the underlying methods — MAUT / AHP / TOPSIS /
minimax-regret / satisficing / real-options / VoI — are in the SSOT
`docs/sources/best-decision-concept-2026-07-06.md`; this canon lists the OPERATIONAL surface only):

| # | Criterion | Operational question |
|---|-----------|----------------------|
| C1 | **value** | What EMI-scope outcome does adoption improve? (compliance, resilience, unit-economics, latency.) |
| C2 | **cost** | Delivery cost — engineering effort, ops overhead, ongoing licence / maintenance. |
| C3 | **risk** | Regulatory / operational / integration risk introduced (and its residual after mitigation). |
| C4 | **reversibility** | Can we back this out cheaply if wrong? Low reversibility ⇒ higher hurdle. |
| C5 | **strategic-fit (EMI-scope)** | Does it lie inside BANXE's EMI perimeter, or does it drift into out-of-scope territory (e.g., credit)? |
| C6 | **opportunity-cost** | What other queued items would this displace? Is a strictly better item queued or expected? |

Method-selection rule (SSOT §16 workflow):

- Well-defined critera and probabilities → **MAUT / EU**.
- Regulatory / ambiguity-heavy → **maxmin / minimax-regret** (Gilboa–Schmeidler; Savage).
- Time-boxed streaming intake → **satisficing** with pre-declared threshold, optionally paired with
  the **secretary rule** (1/e) as a lower-bound heuristic.
- Multi-objective incommensurable → **Pareto** dominance, escalate the frontier.

No single method is mandated by this canon — Central selects per the regime (SSOT §16 step 2) and
records the choice in the adoption-audit note.

## 4. Terminal outcomes of the adoption-audit

Three valid terminal outcomes — all positive, all auditable:

1. **ACCEPT.** Item passes the multi-criteria audit → append `ROADMAP-MATRIX.md`, open sprint-task,
   QUEUE ack `planned → sprint#`, then `processed` (per ADR-159 chain).
2. **REJECT-AS-NOT-WORTH.** Item fails a criterion (typically low `value / cost`, out-of-scope
   `strategic-fit`, high `opportunity-cost`) → QUEUE ack `not-worth <criteria>` with a brief
   rationale, then `processed`. **This is not an omission.** It is a positive proof that Central
   evaluated the item and chose to spend the compute elsewhere.
3. **DEFER (real-option value).** Item is neither accepted nor rejected — deferred pending
   information (VoI > 0) or environmental change. QUEUE ack `defer <until-condition>`, revisited
   when the condition triggers.

## 5. Boundaries (what this canon does NOT change)

- **HITL merge.** All ACCEPT outcomes still land as **draft PRs** merged by the operator (CLAUDE.md
  §71, ADR-156 sandbox). Best-decision does **not** grant auto-merge.
- **I-27 preservation.** Runtime agents keep the fail-closed discipline (§6). Any change to that
  posture is a separate ADR + operator sign-off.
- **CODEOWNERS.** Existing ownership boundaries are unchanged.
- **Intake persistence.** ADR-161 §D-2 mandates SSOT-persist before extraction; the best-decision
  gate reads from persisted SSOT, never from a transient paste.
- **Config-over-Hardcoding.** Any numeric threshold, weight, or scoring cut-off used by the gate
  belongs in `governance/novelty-pipeline-config.yaml` (or a sibling config), not in this canon or
  in code (CLAUDE.md §10).

## 6. Relation to runtime fail-closed (I-27)

Runtime L2+ agents (mlro_agent, aml_check_agent, sanctions_check_agent) operate under **fail-closed
discipline** per `.claude/rules/agents.md` §"HITL Confidence Thresholds" (BUG-007) and the I-27
invariant: below the AUTO threshold, decisions are paused / blocked. Under the §7 variant-2
ratification (2026-07-06), the agent may apply the best-decision algorithm to pick the best
**executing step INSIDE** the HITL envelope, but MUST NOT "best-decide" past a stop-barrier
(irreversibility / invariant-breach / data-loss) and MUST NOT bypass or override an operator
decision. I-27 is preserved unchanged — the ratification adds an in-envelope execution method, not
runtime autonomy.

## 7. Governance question — DIRECTIVE B-BESTDEC-SCOPE-001

**Status:** RATIFIED (2026-07-06) — **variant-2 selected by operator.** **Ack-required:** —
(operator ratification recorded). **Meaning correction attached (2026-07-06).**

The scope of best-decision INSIDE the running fabric was an open governance question. Two
formulations were on the table; the operator has now selected **variant-2**:

- **Variant 1 (в-1) — REJECTED.** Best-decision exercised **only by the orchestrator** (Terminal-B
  / Central / factory) at the intake / adoption / roadmap loop, runtime agents strictly fail-closed
  with no in-envelope algorithmic choice. Retained here for historical record only.
- **Variant 2 (в-2) — RATIFIED (2026-07-06).** Every agent (factory-side and project-side, including
  runtime L2+ agents — mlro_agent, aml_check_agent, sanctions_check_agent) applies the best-decision
  algorithm as an **execution method inside a bounded HITL envelope**:
  `enumerate options → score → satisfice → pick the best executing step`. Constraints (unchanged
  from the original formulation, re-affirmed by this ratification):
  (i) the envelope is pre-declared per-agent-role in `governance/novelty-pipeline-config.yaml` (or a
  sibling config); (ii) irreversibility, invariant-breach, and any I-27 stop-barrier remain
  **absolute stop-barriers** — never "best-decided" past; (iii) every decision logs
  correlation_id + confidence + method + rationale to ClickHouse; (iv) escalation fires below the
  configured satisficing threshold; (v) fail-closed I-27 discipline is preserved — the agent chooses
  the best step **inside** HITL, never overrides HITL. **No runtime autonomy is granted.**

**Meaning correction (operator-directed, 2026-07-06).** "Best-decision" (лучшее решение) in BANXE
is the **execution algorithm** by which an agent carries out the operator's decision, and is the
**learning signal** by which the agent is trained. It is **not** the agent's right to decide
whether to adopt a novelty, a component, or a policy — **adoption remains the operator's
prerogative** (Scope-1 orchestrator best-decide still lands as **draft PRs** merged by the operator
per §5 "HITL merge"; Scope-2 runtime best-decide still operates strictly inside HITL per §6 and this
§7 variant-2). Any drift toward interpreting best-decision as an adoption right is a canon
violation and MUST be rejected at review.

**Uniform-application clause.** This principle applies **to all agents** — factory-side (RSB, ACG,
CAE, EHS, STG, ARP, DO, PS, CMS, OpenClaw gateway-*) and project-side (mlro_agent, aml_check_agent,
sanctions_check_agent, TreasuryAgent, and any future L2+ runtime agent) — as the canonical method
of choosing the best **executing step**. Per-role envelopes differ (config-as-data), the algorithm
does not.

**Anchors (pointer only — ADR-102):** ADR-162 (formal principle statement), ADR-161 (intake
SSOT-persistence), ADR-159 (B→A hand-off pipeline), `.claude/rules/agents.md` §"HITL Confidence
Thresholds" (BUG-007), `.claude/rules/approval-rules.md` §"Правило неоднозначности", CLAUDE.md
§12. Follow-up ADR (per-role HITL envelope + config schema) — to be authored by Central per
BACKLOG item B8.

## 8. Tests (evidence of the gate)

The gate has a small canonical evidence-set in `tests/best-decision/` — YAML cases + a
Python validator that prints pass/fail:

- **CASE-A `accept-high-value-low-cost`.** Item passes → verdict `accept`.
- **CASE-B `reject-low-value-high-cost`.** Item fails value/cost → verdict `reject-as-not-worth`.
- **CASE-C `credit-blocked`.** Item drifts to CREDIT (out-of-scope EMI, `B-EMI-CREDIT-GATE-001`) →
  verdict `blocked-out-of-scope`, hard-fail regardless of other criteria.
- **CASE-D `uncertainty-eu`.** Item under regulatory ambiguity → verdict `defer` on VoI grounds, or
  `accept` under maxmin-EU with the operator-supplied prior — whichever the case declares.

Run: `python3 tests/best-decision/validator.py` — exit 0 = all pass.

## 9. Anchors (authoritative, pointer only — ADR-102)

- **`docs/sources/best-decision-concept-2026-07-06.md`** — SSOT for the academic content this canon
  operationalises (VNM/EU, Bellman-MDP, MAUT, AHP, TOPSIS, NSGA-II, Pareto, satisficing,
  minimax-regret, prospect theory, real options, VoI, secretary rule, ambiguity/robust).
- **`docs/adr/ADR-159-ba-novelty-auto-handoff-pipeline.md`** — the hand-off pipeline this gate sits
  inside (between QUEUE and ROADMAP).
- **`docs/adr/ADR-161-intake-ssot-persistence.md`** — the SSOT-persistence precondition (gate reads
  from persisted SSOT, never from transient paste).
- **`docs/adr/ADR-162-best-decision-principle.md`** — the formal ADR for this canon (PROPOSED).
- **`docs/canon/TERMINAL-B-OPERATING-CANON.md`** §9 — step-0 SSOT-persist amendment.
- **`.claude/rules/agents.md`** §"HITL Confidence Thresholds" (BUG-007) — the fail-closed runtime
  posture referenced by §6 and §7.
- **`.claude/rules/approval-rules.md`** §"Правило неоднозначности" and **CLAUDE.md §12** — the
  orchestrator best-decision canon; this file specialises it for the intake / adoption gate.
- **CLAUDE.md §71** and **`docs/adr/ADR-156-sandbox-mode-signoff-gates-removed.md`** — HITL merge
  gate (unchanged by this canon).
- **`governance/COORDINATION-NOTES.md`** — optional home for the OPEN directive
  B-BESTDEC-SCOPE-001 status; the operator MAY track ratification there.
