# BEST-DECISION-AGENT — advisory reusable method (per-agent, not central)

> **Status:** DESIGN (prepare-only, DESIGN-phase). Prescribes contract + integration for a reusable
> advisory best-decision **method** embedded into every BANXE agent via its SOUL `## Decision Method`
> section — **NOT** a separate central decider agent.
>
> **Restatement rule (ADR-102, hard).** This design **references** SSOT; it does **not** restate
> academic formulas, criterion definitions, HITL thresholds, ratification, retrofit schedule,
> or ADR-162 gate mechanics. All those live in the anchors below and are the source-of-truth.
> Any drift toward a second source is a canon violation.

## 1. Purpose

Every BANXE agent (factory-side and project-side) needs a **single, uniform, auditable procedure**
for choosing the best **executing step** for an operator-directed task, inside its per-role HITL
envelope. This design specifies that procedure as a **reusable advisory method** — a library-style
callable — embedded into each agent through its SOUL `## Decision Method` block (retrofit per
`docs/canon/BEST-DECISION-RETROFIT-PLAN.md`).

The method:

- Ranks candidate **execution steps** (already-in-scope actions to carry out the operator's
  decision) — it does **not** decide whether to adopt novelty, whether to change policy, or whether
  to cross a governance gate.
- Emits a **chosen step + confidence + rationale + escalate flag** — the agent then either executes
  (when the flag is clear and the agent's HITL envelope permits) or **escalates** (when confidence
  falls below the agent's satisficing threshold or a stop-barrier is proximate).
- Is invoked **from inside the agent's own runtime** (per-agent embedding) — there is no central
  "decider" service that L2+ agents call across the fabric.

## 2. Non-goals (what this method does NOT do — HARD BOUNDARIES)

A dedicated non-goals list is required by the meaning-correction in
`docs/canon/BEST-DECISION-BOUNDARY.md` §7. Violations here revert the ratified variant-2 into a
disallowed autonomy shape.

- **Not a central agent.** No standalone `best-decision-agent` service, container, port, or
  passport. The method is a **per-agent embedded procedure**; instantiating a central decider
  restores the runtime-autonomy shape that variant-2 ratification (BOUNDARY §7) explicitly rejects.
- **Not an adoption decision.** The method never decides whether BANXE adopts a novelty, component,
  library, standard, or vendor. Adoption remains the **operator's** prerogative via the ADR-162
  adoption-audit gate at intake (BOUNDARY §2–§4). Any drift here is a canon violation
  (BOUNDARY §7 meaning-correction).
- **Not a governance override.** The method never elects to bypass a passport constraint, an
  invariant (I-01..I-28), an FCA regulation, a CODEOWNERS boundary, or an ADR — regardless of
  computed "utility". Constraints are pre-filters that eliminate infeasible steps **before**
  scoring; violated constraint ⇒ step is dropped, not "traded off".
- **Not autonomy on payment/AML/KYC/compliance.** On these contours the method runs **INSIDE** the
  agent's fail-closed HITL envelope (I-27, `.claude/rules/agents.md` §BUG-007). Confidence below
  the AUTO threshold ⇒ **BLOCK + escalate**, always — the method **cannot** self-clear a runtime
  L2+ decision on a compliance/payment contour. Fail-closed takes precedence over throughput.
- **Not a stop-barrier bypass.** Irreversibility, invariant-breach, data-loss risk, or an OPEN
  operator directive are absolute stop-barriers per `.claude/rules/safety-rules.md` and CLAUDE.md
  §1, §11. The method treats them as hard constraints (drop the step); it never "best-decides" past
  them.
- **Not a second source-of-truth.** This document does not restate SSOT v2 formulas, the ADR-162
  gate, HITL thresholds (BUG-007), the retrofit schedule, or FACTORY-CANON §1.11 (ADR-102). It
  wires them together into the callable contract only.

## 3. Reference architecture (used-by-all)

```
                             ┌────────────────────────────────────────────┐
                             │           SSOT (pointer only, ADR-102)     │
                             │  docs/sources/best-decision-concept-       │
                             │       2026-07-06-v2.md                     │
                             │  docs/canon/BEST-DECISION-BOUNDARY.md      │
                             │  docs/adr/ADR-162-best-decision-           │
                             │       principle.md                         │
                             │  docs/canon/BEST-DECISION-RETROFIT-PLAN.md │
                             │  agents/souls/_TEMPLATE.md §Decision       │
                             │       Method  (#1077)                      │
                             │  .claude/rules/agents.md §BUG-007          │
                             │       (HITL thresholds)                    │
                             └───────────────┬────────────────────────────┘
                                             │ referenced by
                                             ▼
    ┌─────────────────────────┐   embeds  ┌──────────────────────────────────────┐
    │  agent (any of 58 + n)  │◀──────────│  BestDecisionMethod (advisory        │
    │  ─── SOUL: passport +   │           │  reusable procedure — library-shape) │
    │  §Decision Method       │──────────▶│                                      │
    │  (per-role envelope,    │  invokes  │  enumerate → score → satisfice →     │
    │  fail-closed on         │           │  choose best-step → confidence →     │
    │  compliance/payment)    │           │  escalate_flag                       │
    └───────────┬─────────────┘           └──────────────────────────────────────┘
                │
                │ result: {ranked_steps[], chosen_step, confidence, escalate_flag, method, rationale}
                ▼
    ┌──────────────────────────────────────────────────────────────────────────┐
    │  agent runtime — HITL envelope (per-role, config-as-data)                │
    │                                                                          │
    │  escalate_flag == true   →  BLOCK + escalate (to named role: MLRO/CRO/…) │
    │  escalate_flag == false                                                  │
    │      ∧ confidence ≥ AUTO threshold (BUG-007)  →  execute chosen_step     │
    │      ∧ confidence in REVIEW band              →  propose + human review  │
    │      ∧ confidence < REVIEW floor              →  BLOCK + escalate        │
    │                                                                          │
    │  compliance/payment contour: BUG-007 thresholds ALWAYS binding           │
    │  (I-27 fail-closed — method cannot self-clear)                           │
    └──────────────────────────────────────────────────────────────────────────┘
```

**One SSOT, N embeddings, zero central decider.** The method's *logic* is a single canonical
specification; each agent's *invocation site* is inside its own SOUL. Cross-agent uniformity comes
from the ratification (BOUNDARY §7 uniform-application clause) and the retrofit
(BEST-DECISION-RETROFIT-PLAN §"Retrofit discipline") — not from a shared runtime service.

## 4. Algorithm shape (pointer to SSOT, not restatement)

The four-step procedure `enumerate → score → satisfice → pick-best-step` is defined by the SSOT
chain, not by this document:

- **Definition of steps**: `docs/sources/best-decision-concept-2026-07-06-v2.md` — theory /
  method families (EU/VNM, MDP/Bellman, MAUT/AHP/TOPSIS, secretary, minimax-regret,
  prospect-theory awareness, Nash — pointer only).
- **Canonical criterion-set** (value / cost / risk / reversibility / strategic-fit (EMI-scope) /
  opportunity-cost): `docs/canon/BEST-DECISION-BOUNDARY.md` §3 — operational surface only.
- **Method-selection rule** (which family per problem-class): BOUNDARY §3 method-selection rule +
  SSOT v2 §11 mapping.
- **Runtime envelope + fail-closed posture** (I-27, thresholds): `.claude/rules/agents.md`
  §"HITL Confidence Thresholds" (BUG-007).
- **Per-agent embedding**: `agents/souls/_TEMPLATE.md` §Decision Method (added in #1077, retrofit
  scheduled per BEST-DECISION-RETROFIT-PLAN R1..R7).
- **Adoption gate boundary** (separate scope — NOT this method): ADR-162, BOUNDARY §2–§4.

This design **wires** them into a callable contract; it does not re-derive them.

## 5. Contract (interface — typed contract, no implementation)

The method is a **pure advisory function** — no side-effects, no external state mutation, no
network I/O beyond the caller-provided context. The agent (caller) owns the runtime effects.

### 5.1 Input

```python
# Type sketch — normative shape, not an implementation.
# The runtime binding (Python / other) is out of scope for this DESIGN.

@dataclass(frozen=True)
class CandidateStep:
    step_id: str                         # stable id within the invocation
    description: str                     # human-readable action label
    kind: Literal["read_only", "state_changing"]
    reversibility: Literal["reversible", "partially_reversible", "irreversible"]
    contour: Literal[                    # governance contour affecting the step
        "compliance_payment_aml_kyc",    # ⇒ fail-closed HITL binding (I-27, BUG-007)
        "governance",                    # ⇒ operator-gated (ADR-162 adoption / directives)
        "operational",                   # ⇒ standard HITL envelope
    ]
    invariants_touched: list[str]        # I-01..I-28 keys this step interacts with
    expected_effect: dict[str, Any]      # per-criterion expected outcomes, opaque here

@dataclass(frozen=True)
class Constraints:
    # Constraints are pre-filters. A step violating any of these is REMOVED
    # from D before scoring — never "traded off" (BOUNDARY §5 preservation).
    invariants_forbidden: set[str]       # from passport + I-01..I-28
    stop_barriers: set[Literal[
        "irreversibility_on_operator_decision",
        "invariant_breach",
        "data_loss_risk",
        "open_operator_directive",
        "codeowners_boundary_cross",
    ]]
    fail_closed_contours: set[str]       # compliance/payment/AML/KYC (I-27)

@dataclass(frozen=True)
class CriteriaWeights:
    # Weights over the canonical criterion-set (BOUNDARY §3 — pointer only).
    # Config-as-data (CLAUDE.md §10): weights live in
    # governance/novelty-pipeline-config.yaml (or a sibling per-role config),
    # NEVER in code and NEVER in this document (ADR-102).
    value: float
    cost: float
    risk: float
    reversibility: float
    strategic_fit_emi_scope: float
    opportunity_cost: float

@dataclass(frozen=True)
class MethodContext:
    agent_role: str                      # e.g. "mlro-report-agent", "payment-router-agent"
    envelope_thresholds: dict[str, float]  # BUG-007 per-role AUTO / REVIEW / BLOCK — from config
    problem_class: Literal[              # informs method-family selection (SSOT v2 §11)
        "risk_eu", "sequential_mdp", "multi_criteria_maut",
        "irreversible_one_shot", "deep_uncertainty_minimax_regret",
        "multi_agent_nash",
    ]
    correlation_id: str                  # audit chain — always present
    operator_directive_id: str | None    # the directive this step executes (if any)

@dataclass(frozen=True)
class MethodInput:
    candidate_steps: list[CandidateStep]
    context: MethodContext
    constraints: Constraints
    criteria_weights: CriteriaWeights
```

### 5.2 Output

```python
@dataclass(frozen=True)
class RankedStep:
    step_id: str
    score: float                         # composite per criteria_weights
    per_criterion_scores: dict[str, float]
    dropped: bool                        # true if constraint pre-filter removed it
    drop_reason: str | None              # populated when dropped == true

@dataclass(frozen=True)
class MethodOutput:
    ranked_steps: list[RankedStep]       # incl. dropped, for auditability
    chosen_step: str | None              # None when no feasible step exists
    confidence: float                    # [0.0, 1.0]
    method_family: Literal[              # which family was actually applied (SSOT v2 §11)
        "eu_vnm", "mdp_bellman", "maut_ahp_topsis",
        "secretary_37", "minimax_regret", "prospect_aware",
        "nash",
    ]
    rationale: str                       # short, audit-grade — appended to ClickHouse log
    escalate_flag: bool                  # TRUE ⇒ agent MUST NOT execute; escalate + BLOCK
    escalate_reason: str | None          # populated when escalate_flag == true
```

### 5.3 Escalation rule (normative — wired to HITL thresholds)

The `escalate_flag` is set to **TRUE** when **any** of the following holds (short-circuit OR —
evaluate in order, stop at first hit; short-circuit means later conditions are not evaluated
once a hit fires — this is auditability-preserving, not silence):

1. `chosen_step is None` (no feasible step survived the constraint pre-filter).
2. `confidence < envelope_thresholds["auto_threshold"]` (BUG-007: `<90%` on runtime L2+ agents;
   per-role floors live in config).
3. `context.problem_class == "irreversible_one_shot"` **AND** `confidence <
   envelope_thresholds["irreversible_floor"]` (higher hurdle for irreversible actions —
   BOUNDARY §3 C4 reversibility criterion).
4. `chosen_step` touches a **fail-closed contour** (`context.constraints.fail_closed_contours`)
   **AND** `confidence < envelope_thresholds["compliance_floor"]` (I-27 fail-closed, always
   binding on payment/AML/KYC/compliance — the method cannot self-clear here regardless of
   score).
5. Any **stop-barrier** in `constraints.stop_barriers` would be crossed by executing the step
   (irreversibility of an operator decision, invariant-breach, data-loss risk, open operator
   directive, CODEOWNERS boundary cross).

On escalation the agent MUST log `{correlation_id, agent_role, confidence, method_family,
escalate_reason, rationale}` to ClickHouse per BOUNDARY §7 constraint (iii) before proposing to
the named human role in its Escalation section.

**Precedence recap.** `fail_closed_contours` and `stop_barriers` take precedence over
`confidence`. High confidence does not clear a stop-barrier. Score does not vote against I-27.

## 6. Embedding — how each agent invokes the method

The method is invoked from **inside the agent's own SOUL runtime**, per the retrofit schedule in
`docs/canon/BEST-DECISION-RETROFIT-PLAN.md`. There is **no** cross-agent RPC to a "decider".

### 6.1 Wiring template (normative shape — for the retrofit editors)

Each retrofitted SOUL's `## Decision Method` section, when translated into the agent runtime,
invokes the method as:

```python
# Illustrative wiring — inside the agent's own action loop.
# NOT an implementation directive; DESIGN phase only.

def act_on(directive: OperatorDirective) -> ActionResult:
    candidates = enumerate_execution_steps(directive, self.passport)
    context = MethodContext(
        agent_role=self.role,
        envelope_thresholds=self.config.hitl_thresholds,   # config-as-data
        problem_class=classify(directive, self.passport),  # SSOT v2 §11 method-selection
        correlation_id=directive.correlation_id,
        operator_directive_id=directive.id,
    )
    constraints = Constraints(
        invariants_forbidden=self.passport.invariants_forbidden,
        stop_barriers=self.stop_barriers,                  # includes I-27 on compliance
        fail_closed_contours=self.passport.fail_closed_contours,
    )
    weights = self.config.criteria_weights                 # per-role, config-as-data

    result = best_decision_method(MethodInput(
        candidate_steps=candidates,
        context=context,
        constraints=constraints,
        criteria_weights=weights,
    ))

    audit_log(result, correlation_id=directive.correlation_id)  # ClickHouse — BOUNDARY §7 (iii)

    if result.escalate_flag:
        return escalate(result, to=self.escalation_target)     # SOUL §Escalation
    return execute(result.chosen_step)                          # inside HITL envelope
```

### 6.2 Uniform-application clause (BOUNDARY §7)

Every retrofitted agent (58 SOULs enumerated in RETROFIT-PLAN R1..R7) calls the **same** method
with **role-specific** `envelope_thresholds`, `criteria_weights`, and `stop_barriers` sourced from
config. The **algorithm is identical**; the envelope is per-role.

Config location (Config-over-Hardcoding, CLAUDE.md §10):
`governance/novelty-pipeline-config.yaml` for orchestrator-side keys (per ADR-162 §D-3),
per-role runtime keys per BOUNDARY §7 constraint (i) — pre-declared per-agent-role in
`governance/novelty-pipeline-config.yaml` or a sibling config. **No numeric threshold, weight,
floor, or method-selection default belongs in this document** (ADR-102).

### 6.3 Retrofit sequence (pointer only)

Batches R1..R7 in `docs/canon/BEST-DECISION-RETROFIT-PLAN.md` — one PR per batch, grounded
per-passport, prepare-only. This design does **not** duplicate that schedule.

## 7. Auditability

- **Every invocation** logs `{correlation_id, agent_role, method_family, confidence, chosen_step,
  escalate_flag, rationale}` to ClickHouse per BOUNDARY §7 constraint (iii).
- **Dropped candidates** are returned in `ranked_steps` with `dropped=true` + `drop_reason` — the
  audit trail records **why** a step was infeasible, not only what was chosen. This closes the
  "silent constraint" audit-hole flagged in ADR-162 §"Consequences → Risks → Ossification".
- **Escalations** always carry `escalate_reason` — the human at the escalation target receives a
  structured, replayable frame, not a bare "confidence low".

## 8. I-27 preservation — explicit re-affirmation

The runtime posture defined in `.claude/rules/agents.md` §"HITL Confidence Thresholds" (BUG-007) is
**preserved unchanged**:

| Confidence | Action | Applies to |
|---|---|---|
| `>90%` (per-role) | `AUTO` — execute inside envelope | non-compliance contours only when contour is not fail-closed |
| `70–90%` (per-role) | `REVIEW` — propose + named human review | all L2+ agents |
| `<70%` (per-role) | `BLOCK` — human confirmation mandatory | all L2+ agents; SAR path if amount ≥£10k with AML signal |

On compliance/payment/AML/KYC contours (I-27 fail-closed), the method **cannot** self-clear —
`escalate_flag` fires whenever `confidence < compliance_floor`, regardless of score, per §5.3
rule 4. This is the same discipline that variant-2 ratification (BOUNDARY §7) explicitly preserves;
this design merely wires it into the callable.

## 9. Anchors (authoritative, pointer only — ADR-102)

- **SSOT / theory:** `docs/sources/best-decision-concept-2026-07-06-v2.md`
- **Boundary (operational canon):** `docs/canon/BEST-DECISION-BOUNDARY.md` §1..§9 (esp. §7
  variant-2 ratification + meaning-correction + uniform-application clause)
- **Formal principle (adoption-audit gate):** `docs/adr/ADR-162-best-decision-principle.md`
- **Retrofit schedule (58 SOULs):** `docs/canon/BEST-DECISION-RETROFIT-PLAN.md`
- **Synthesis:** `docs/canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md`
- **SOUL template `## Decision Method` (added #1077):** `agents/souls/_TEMPLATE.md`
- **FACTORY-CANON §1.11 (Best-Decision training):** `docs/factory/FACTORY-CANON.md`
- **HITL thresholds (fail-closed runtime):** `.claude/rules/agents.md` §"HITL Confidence
  Thresholds" (BUG-007)
- **Orchestrator best-decision canon:** `.claude/rules/approval-rules.md` §"Правило
  неоднозначности" and CLAUDE.md §12
- **Stop-barriers:** `.claude/rules/safety-rules.md`, CLAUDE.md §1, §11
- **Config-over-Hardcoding:** CLAUDE.md §10
- **ADR-131 (SOUL format, 12 sections — amended by #1077):**
  `docs/adr/ADR-131-souls-format-standard.md`
- **This design's formal decision:**
  `docs/adr/ADR-164-best-decision-agent-method.md` (PROPOSED, this PR)
- **No restatement discipline:** `docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md`
