# ADR-164 — Best-decision "agent" = advisory reusable method, per-agent embedded (not a central decider)

**Date:** 2026-07-07
**Status:** PROPOSED
**Deciders:** Central (design owner), Terminal-B (Spec-Projects), Operator (ratification pending)
**Replaces:** N/A
**Superseded by:** N/A
**References:** ADR-162 (best-decision adoption-audit gate — orchestrator scope), ADR-159 (B→A hand-off pipeline), ADR-161 (intake SSOT-persistence), ADR-131 (SOUL format standard — amended by #1077 for §Decision Method), ADR-102 (no restatement of canon), ADR-060 (branch actor namespace), ADR-119/ADR-133 (stable IL numbering, mint-at-merge), ADR-120 (per-session worktree isolation), ADR-163 (SYNC-CANON), `docs/canon/BEST-DECISION-BOUNDARY.md`, `docs/canon/BEST-DECISION-RETROFIT-PLAN.md`, `docs/canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md`, `docs/sources/best-decision-concept-2026-07-06-v2.md`, `docs/factory/FACTORY-CANON.md` §1.11, `agents/souls/_TEMPLATE.md` §Decision Method (added #1077), `.claude/rules/agents.md` §"HITL Confidence Thresholds" (BUG-007), `.claude/rules/approval-rules.md` §"Правило неоднозначности", CLAUDE.md §1, §10, §11, §12, §71.

---

## Context

The best-decision canon now exists in BANXE at three complementary layers:

1. **Adoption-audit gate (orchestrator scope)** — ADR-162 + `docs/canon/BEST-DECISION-BOUNDARY.md`
   §2..§4. Owned by Central, sits between QUEUE and ROADMAP, exercises orchestrator best-decide
   with a HITL merge; **does not** grant runtime autonomy.
2. **Runtime execution algorithm (per-agent scope)** — `docs/canon/BEST-DECISION-BOUNDARY.md` §7
   variant-2 ratified 2026-07-06, with the operator-directed meaning-correction: best-decision is
   the algorithm by which an agent **executes** the operator's decision and is trained by it, not
   the agent's right to decide adoption. Applies uniformly to all agents inside a bounded HITL
   envelope with I-27 preserved.
3. **SOUL wiring (per-agent, format-level)** — `agents/souls/_TEMPLATE.md` §Decision Method added
   in #1077; `docs/canon/BEST-DECISION-RETROFIT-PLAN.md` schedules the R1..R7 retrofit across 58
   existing SOULs; ADR-131 amended 2026-07-07 for the 12th mandatory section.

**Gap.** The three layers agree that the runtime best-decision is a **method** applied uniformly
across agents. What is missing is the **formal statement of the shape** of that method — is it a
central "best-decision-agent" service that L2+ agents call, or a per-agent embedded procedure
invoked from within each agent's own runtime? The wording "agent" in `BEST-DECISION-AGENT` is
ambiguous and, read incorrectly, would re-introduce the very runtime-autonomy shape that
variant-2 ratification explicitly rejects (a central decider would need cross-agent authority to
be useful, and cross-agent authority is autonomy).

The FACTORY-CANON §1.11 training bar (added 2026-07-07 in #1077) and the RETROFIT-PLAN both
describe embedding the method inside each SOUL — not a shared service — but this is inferred
from wiring, not stated as a decision. In the absence of a formal decision, an incoming
implementation could plausibly build the central-service shape and violate the ratification
without leaving a rejection-trail.

This ADR closes that gap by stating the shape explicitly, in the shortest possible form, with
all technical content deferred (via ADR-102) to the four existing sources-of-truth.

---

## Decision

### D-1 — "BEST-DECISION-AGENT" is an advisory reusable method, not a central agent

The runtime best-decision procedure ratified in `docs/canon/BEST-DECISION-BOUNDARY.md` §7
variant-2 is realised as **an advisory reusable method embedded into every agent** — a
library-style callable invoked from inside each agent's own SOUL runtime — **not** as a separate
central decider agent, service, container, port, or passport.

The design of the callable — contract, integration, escalation wiring — is in
`docs/design/BEST-DECISION-AGENT.md` (this PR). This ADR states the shape and the negative
boundary; the design document specifies the contract; the SSOT chain owns the technical content
(ADR-102 pointer-only).

### D-2 — No central decider (hard prohibition)

The following are **prohibited** as instantiations of the best-decision principle at runtime:

- a standalone `best-decision-agent` service, container, port, systemd unit, or passport;
- a cross-agent RPC or MoA-style gateway whose sole purpose is to compute the best step for
  another agent;
- any component that receives another agent's candidate steps and returns a chosen step **with
  execution authority** (advisory helpers that only return ranked candidates back to the caller
  agent are permitted, provided the caller agent — inside its own HITL envelope — retains the
  execute-or-escalate decision and the caller's passport constraints and I-27 discipline are
  applied by the caller).

Rationale: cross-agent execution authority is a runtime-autonomy shape. Variant-2 ratification
(BOUNDARY §7) — with the operator-directed meaning-correction — grants **no runtime autonomy**.
Any component that could execute a step on behalf of another agent restores the shape variant-1
was chosen to prevent, and the operator-directed correction was authored to prevent.

### D-3 — Per-agent embedding via SOUL `## Decision Method`

Each of the 58 existing SOULs is retrofitted per `docs/canon/BEST-DECISION-RETROFIT-PLAN.md`
(R1..R7 batches) with a `## Decision Method` section that invokes the same method with per-role
parameters. The **algorithm is identical across agents**; the **envelope is per-role** and lives
in config (Config-over-Hardcoding, CLAUDE.md §10 — `governance/novelty-pipeline-config.yaml` or a
sibling per-role config). This ADR does not restate the retrofit schedule (ADR-102).

### D-4 — I-27 fail-closed preserved absolute (hard invariant)

On payment / compliance / KYC / AML contours the method runs **inside** the agent's fail-closed
HITL envelope per `.claude/rules/agents.md` §"HITL Confidence Thresholds" (BUG-007) and the I-27
invariant. Confidence below the AUTO / compliance floor ⇒ **BLOCK + escalate**, regardless of
computed score. The method **cannot** self-clear a runtime L2+ decision on a fail-closed
contour. The escalation rule is normative and specified in `docs/design/BEST-DECISION-AGENT.md`
§5.3.

Any implementation that permits the method to override, bypass, or "best-decide past" a
fail-closed contour is a canon violation and MUST be rejected at review. This is the same
discipline BOUNDARY §7 constraint (v) ("fail-closed I-27 discipline is preserved — the agent
chooses the best step INSIDE HITL, never overrides HITL") formalises; this ADR names it
absolute.

### D-5 — Stop-barriers are hard constraints (drop, never trade off)

Irreversibility of an operator decision, invariant-breach, data-loss risk, open operator
directives, and CODEOWNERS boundary crossings are **hard constraints**, not scored criteria. A
candidate step touching any of them is **removed** from the feasibility set before scoring — it
is **never** "traded off" against a high value / low-cost profile. This mirrors and does not
restate `.claude/rules/safety-rules.md`, CLAUDE.md §1, §11, §12, and BOUNDARY §7 constraint (ii)
("irreversibility, invariant-breach, and any I-27 stop-barrier remain absolute stop-barriers —
never 'best-decided' past").

### D-6 — Adoption remains operator-owned (no scope creep)

The method never decides whether BANXE **adopts** a novelty, component, library, standard, or
vendor. Adoption remains the **operator's prerogative** via the ADR-162 adoption-audit gate at
intake — the meaning-correction in BOUNDARY §7 states this in normative form and this ADR names
it as the second hard boundary of D-1. A method that widens its scope from "execute the
operator's decision" to "decide the operator's decision" is a canon violation.

### D-7 — Config-over-Hardcoding for all numeric parameters

All numeric parameters used by the method — criterion weights, satisficing floors, per-role
AUTO / REVIEW / BLOCK thresholds, irreversibility floors, method-family selection defaults —
live in `governance/novelty-pipeline-config.yaml` (or a sibling per-role config), never in this
ADR and never in code (CLAUDE.md §10, ADR-162 §D-3). Adding gate-specific keys is a follow-up
config-PR, not part of this ADR.

### D-8 — Auditability floor

Every invocation logs `{correlation_id, agent_role, method_family, confidence, chosen_step,
escalate_flag, escalate_reason, rationale, per_criterion_scores, dropped_candidates}` to
ClickHouse per BOUNDARY §7 constraint (iii). Dropped candidates are logged with their
`drop_reason` — the audit trail must record why steps were infeasible, not only which was
chosen. This closes the ossification-risk noted in ADR-162 §"Consequences → Risks".

### D-9 — DESIGN-phase only (no implementation in this PR)

This PR is **prepare-only**. It introduces:

- `docs/design/BEST-DECISION-AGENT.md` — the design specification with typed contract.
- `docs/adr/ADR-164-best-decision-agent-method.md` — this ADR (PROPOSED).

It does **not** ship a runtime implementation, does not add code to any agent, does not touch
`_TEMPLATE.md` (already updated in #1077), does not touch any of the 58 SOULs (retrofit is a
separate serial effort per BEST-DECISION-RETROFIT-PLAN R1..R7), and does not add config keys
(follow-up config-PR per D-7). Ratification of D-1..D-8 by the operator is required before any
implementation PR opens (best-decision canon: this is a decision-shape gate, not a whitelist
auto-run).

---

## Consequences

**Positive**

- The runtime best-decision principle has a formal shape statement (advisory reusable method,
  not central agent), closing the ambiguity that a naive read of "BEST-DECISION-AGENT" could
  have introduced.
- Central-decider anti-patterns are named and prohibited in a merged ADR, giving reviewers a
  bright-line to reject implementations that regress toward runtime autonomy.
- Retrofit editors (RETROFIT-PLAN R1..R7) have a single authoritative contract to wire against;
  the `## Decision Method` sections in 58 SOULs can be edited consistently.
- I-27 preservation, adoption-scope boundary, and stop-barrier discipline are re-affirmed in the
  ADR chain (not only in BOUNDARY prose), reinforcing their invariant status.
- Auditability floor is stated: dropped candidates + escalate reasons are first-class, not
  optional.

**Negative / accepted trade-offs**

- The method must be embedded per-agent (58 retrofits scheduled). This is a serialised effort,
  not a single-PR change — the RETROFIT-PLAN explicitly accepts this trade-off in exchange for
  per-passport grounding.
- Config surface grows (per-role thresholds, weights, floors). Accepted per Config-over-
  Hardcoding (CLAUDE.md §10); the sprawl is bounded by the per-role structure and is auditable.
- A central-decider shape is sometimes ergonomically attractive (one place to tune). Explicitly
  rejected here (D-2) because ergonomic centralisation ⇒ runtime autonomy, which the operator
  has ratified against (variant-1 REJECTED in BOUNDARY §7).

**Risks (mitigations noted)**

- **Drift toward a central decider.** A well-meaning implementation offers an "advisory service"
  that grows execute-on-behalf-of authority. *Mitigation:* D-2 names this shape as prohibited in
  merged canon; reviewers can reject on ADR-164 alone.
- **Drift toward adoption authority.** An implementation gradually extends the method from
  "execute the operator's step" to "choose whether to execute". *Mitigation:* D-6 names this as
  a hard boundary; BOUNDARY §7 meaning-correction is upstream normative.
- **Drift toward fail-closed bypass.** A high-score step on a compliance contour is granted
  execution because its confidence is above AUTO. *Mitigation:* D-4 makes fail-closed absolute
  precedence over confidence; §5.3 rule 4 in the design specifies the escalation rule.
- **Config sprawl / silent tuning.** Per-role thresholds diverge without governance. *Mitigation:*
  BOUNDARY §5 preservation clause + Config-over-Hardcoding CLAUDE.md §10 — config lives in the
  repo under CODEOWNERS.
- **Under-audit escalations.** Escalations fire without structured reason, humans triage blind.
  *Mitigation:* D-8 makes `escalate_reason` and `dropped_candidates` first-class in the log
  contract.

---

## Open items

- **OI-1.** Operator ratification of D-1..D-8. Until then, PROPOSED; no implementation opens.
- **OI-2.** Follow-up config-PR to add per-role keys to `governance/novelty-pipeline-config.yaml`
  (weights, satisficing floors, per-role AUTO / REVIEW / BLOCK / compliance floors, irreversibility
  floors, method-family selection defaults). Out of scope for this ADR (per D-7).
- **OI-3.** Retrofit implementation PRs (R1..R7 per BEST-DECISION-RETROFIT-PLAN) each edit one
  batch of SOULs' `## Decision Method` sections to wire the callable at the SOUL level. Serial,
  one PR per batch, out of scope for this ADR.
- **OI-4.** Optional CI guard: a rule that new SOULs (post-retrofit) MUST include a
  `## Decision Method` section (ADR-131 already amended for the 12-section standard; a
  guardian-souls-format check can enforce it). Out of scope here.
- **OI-5.** Retrofit-time verification: each retrofit PR's `## Decision Method` must reference
  this ADR + BOUNDARY §7 (variant-2 + meaning-correction) — advisory review criterion, not a
  gate change.

---

## Anchors (authoritative, pointer only — ADR-102)

- **`docs/design/BEST-DECISION-AGENT.md`** — the design specification this ADR formalises.
- **`docs/canon/BEST-DECISION-BOUNDARY.md`** §7 — variant-2 ratification + meaning-correction +
  uniform-application clause (the normative source of the shape decided here).
- **`docs/adr/ADR-162-best-decision-principle.md`** — the adoption-audit gate (orchestrator
  scope) — complements this ADR at the intake boundary.
- **`docs/canon/BEST-DECISION-RETROFIT-PLAN.md`** — the R1..R7 retrofit schedule that lands the
  wiring across 58 SOULs.
- **`docs/canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md`** — synthesis referenced by
  FACTORY-CANON §1.11.
- **`docs/sources/best-decision-concept-2026-07-06-v2.md`** — SSOT for theory / method families
  (EU/VNM, MDP/Bellman, MAUT/AHP/TOPSIS, secretary, minimax-regret, prospect awareness, Nash).
- **`agents/souls/_TEMPLATE.md`** §Decision Method — the SOUL wiring template (added #1077).
- **`docs/factory/FACTORY-CANON.md`** §1.11 — the training bar for factory work.
- **`docs/adr/ADR-131-souls-format-standard.md`** — 12-section SOUL standard (amended 2026-07-07).
- **`.claude/rules/agents.md`** §"HITL Confidence Thresholds" (BUG-007) — the fail-closed runtime
  posture preserved by D-4.
- **`.claude/rules/approval-rules.md`** §"Правило неоднозначности" and **CLAUDE.md §12** —
  orchestrator best-decision canon (adoption gate side).
- **`.claude/rules/safety-rules.md`**, **CLAUDE.md §1, §11** — stop-barriers (D-5).
- **CLAUDE.md §10** — Config-over-Hardcoding (D-7).
- **CLAUDE.md §71** and **`docs/adr/ADR-156-sandbox-mode-signoff-gates-removed.md`** — HITL merge
  gate (unchanged by this ADR).
- **`docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md`** — pointer-first
  discipline this ADR enforces.
- **`docs/adr/ADR-060-...`** — branch actor namespace (`agent/specproj/sp32/…`).
- **`docs/adr/ADR-119-...`** + **`docs/adr/ADR-133-...`** — stable IL numbering / mint-at-merge.
- **`docs/adr/ADR-120-...`** — per-session worktree isolation.
- **`docs/adr/ADR-163-...`** + **`docs/canon/SYNC-CANON.md`** — SYNC-CANON compliance for this
  PR.
