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
- **Scope-2 — Runtime-agent best-decide.** Applies to L2+ agents inside the running fabric
  (mlro_agent, aml_check_agent, sanctions_check_agent, and any future runtime agent). Currently
  **inverted** relative to Scope-1: runtime agents operate under **fail-closed I-27 discipline**,
  NOT best-decision (see §7 Governance question DIRECTIVE B-BESTDEC-SCOPE-001). Runtime autonomy is
  **NOT introduced by this canon**; it is an OPEN governance question awaiting operator
  ratification.

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
invariant: below the AUTO threshold, decisions are paused / blocked, not "best-decided" by the
agent. This canon does **not** change that posture. See §7 for the OPEN governance directive.

## 7. Governance question — DIRECTIVE B-BESTDEC-SCOPE-001

**Status:** OPEN. **Ack-required:** operator. **Do not resolve inside this ADR/canon.**

The scope of best-decision INSIDE the running fabric is an open governance question. Two
formulations are on the table; **selection is deferred to the operator**, and until ratification the
default remains fail-closed (I-27):

- **Variant 1 (в-1) — current inversion, operator-preserved.** Best-decision is exercised **only by
  the orchestrator** (Terminal-B / Central / factory) at the intake / adoption / roadmap loop. Every
  runtime agent stays **fail-closed** (I-27 unchanged): below the confidence AUTO threshold, block
  or escalate; no runtime "best-decide" is authorised. **This is the current canonical posture.**
- **Variant 2 (в-2) — HITL-bounded runtime best-decide.** A runtime agent MAY, **inside a bounded
  HITL envelope** (enumerate options → score → satisfice → escalate on failure), execute a
  best-decision, provided that (i) the envelope is pre-declared per-agent-role, (ii) irreversibility
  and invariant-touching remain stop-barriers (never "best-decided" past), (iii) all decisions log
  correlation_id + confidence + method + rationale, and (iv) escalation still fires below a
  configurable satisficing threshold. **No runtime autonomy is granted** — the agent still operates
  under HITL.

**Ratification path:** operator selects (в-1) or (в-2). If (в-2), a follow-up ADR defines the
per-role HITL envelope and the config schema. Until then, this directive stays OPEN and the runtime
posture is (в-1) by default. **This canon does NOT introduce runtime autonomy under any variant.**

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
