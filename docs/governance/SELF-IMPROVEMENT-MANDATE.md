# Self-Improvement Mandate — improve is mandatory; promote-to-canon stays gated

> **Status:** governance mandate. **Date:** 2026-07-02. **Owner-terminal: A (factory).**
> **Pointer-first and additive (ADR-102).** Reconciles an operator principle change with existing canon —
> **it edits no ADR, writes no project code, touches no perimeter, and invents no repo.** It references the
> canon it binds; it restates none of it.

## 0. Why this exists (correction of #968)
The **factory-fork-only exception** recorded in `FACTORY-PROJECT-PROJECTION-MODEL.md` Appendix A (#968/IL-814)
read `lesson-capture` (#951) and `skills → SKILL.md` (#953) as **`⛔ factory-fork-only`** — i.e. it fenced off
**self-improvement itself** from the project fork. That was **OVER-BROAD.** The canon it cited does **not**
forbid an agent improving itself; it forbids only **(a) authority-expansion *through* memory/skills** and
**(b) delegating *authority* to the project fork**:

- **ADR-136:** memory is *read-only w.r.t. authority* — it **describes, never authorizes**; a recalled fact
  "confers no merge/deploy/payment/AML/dispatch right." It gates **authority**, not **learning**.
- **ADR-130 / ADR-127:** **no authority expansion**; memory MUST NOT confer write/dispatch authority.
- **ADR-145:** its title is literally **"non-delegable authority + *delegable execution*"** — the **core
  invariant** is that *authority* (IL-mint, governance, merge, the ADR-135 gate) is non-delegable; the project
  fork is an **execution consumer**. Execution — including an agent improving its own execution — is
  **delegable**.
- **ADR-135:** autonomous skill-evolution is an **allowed L2/L3 action** under the ADR-128 ladder; what is
  forbidden is **authority expansion** ("no authority expansion, ever") — not the evolution itself.
- **ADR-128:** **L1 is auto** (read-only/operational, no gate); only state-changing / compliance-bearing
  actions are L2/L3-gated. Operating and improving *within a granted role* is not gated.

So the canon draws its line at **authority**, not at **self-improvement**. #968 drew it at self-improvement.
This mandate moves the line back to where the canon actually puts it.

## 1. Principle (operator, 2026-07-02)
**Agents MUST improve themselves.** This is a **mandate, not an option**:
- **factory agents** — self-improvement is **mandatory**;
- **project agents** — self-improvement is mandatory **at 100%** (every project agent, no carve-out).

Self-improvement means: **capturing lessons, optimising its own work, and improving on its own runs** —
i.e. **delegable execution** (ADR-145) plus the **permitted skill-evolution** (ADR-135, an L2/L3 action under
ADR-128). An agent that does not improve within its role is **non-conformant**, not "safe."

## 2. The split that reconciles mandate with canon
Two operations that #968 conflated are **separated** here; the mandate applies to the first, the gate to the
second:

| Operation | What it is | Rule | Canon |
|---|---|---|---|
| **IMPROVE** (learning / optimisation) | capture a lesson; tune its own prompts/skills on its own runs; optimise its own execution — **within its granted role** | **MANDATORY for BOTH forks** — the agent improves **freely** | ADR-145 (delegable execution); ADR-135 (permitted skill-evolution, L2/L3); ADR-128 (operate within role) |
| **PROMOTE-TO-CANON** (change shared rules / expand authority) | ratify a lesson/skill **into canon** — `CLAUDE.md` / an ADR / a rule; widen any right | **GATED + NON-DELEGABLE** — only via the **ADR-135 held-out adoption gate**, HITL, factory-only | ADR-145 core invariant (authority NON-DELEGABLE); ADR-136/130/127 (memory never authorizes); ADR-135 ("no authority expansion, ever") |

**In one line:** *improving is mandatory and free; changing the **canon** by your improvement is only via the
gate.* **No authority-expansion, ever** (ADR-135) — an improvement can never grant a right the agent was not
granted. The mandate **raises** the floor on IMPROVE; it **does not touch** the ceiling on PROMOTE-TO-CANON.

## 3. Reclassification of the two #968 rows (correcting the over-broad reading)
`lesson-capture` (#951) and `skills → SKILL.md` (#953) are **re-read**, not deleted from Appendix A:

- was: **`⛔ factory-fork-only`** (fenced off self-improvement entirely — over-broad);
- now: **IMPROVE mechanism = both-forks-mandatory (projectable to the project fork); AUTHORITY-promotion =
  factory-gated (ADR-135 HITL, non-delegable).**

Appendix A remains (it correctly isolates the **authority half** as non-delegable); this mandate
**corrects only their treatment of the *improve* half** — from "does not fork" to "**must** fork to both,
because improving is mandatory." The correction is recorded **additively** in
`FACTORY-PROJECT-PROJECTION-MODEL.md` **Appendix B** (Appendix A is **not** removed).

## 4. Project-fork locus (the one operator decision before project-side build)
Project-side self-improvement **requires an agent-harness project-fork locus** — a place where a project agent
persists lessons and evolves its own skills. **No such repo exists today** (all project repos are
product-runtime: `banxe-emi-stack`, `banxe-ui`, `banxe-fiat-backend`, `banxe-dashboard`, `banxe-payments`,
`banxe-identity`, `banxe-uikit`, …).

- **`[BLOCKING: operator / ADR-136-gated]`** — the concrete project-fork repo for the agent-harness locus is
  the **single operator decision** required before any project-side implementation. **It is NOT invented here**
  and **no repo is fabricated.** Until that decision, the mandate is **in force for the factory fork now**, and
  **specified-but-pending** for the project fork (awaiting the locus).
- Whatever the locus, it hosts **only the IMPROVE mechanism** (capture/optimise/evolve, execution-side, gated
  by ADR-135 for any promotion). The **PROMOTE-TO-CANON authority stays factory-only and non-delegable**
  regardless (ADR-145) — the locus projects *a mechanism*, never *authority*.

## 5. Relation to the self-improving-harness evaluation
The Hyperbrowser / self-correcting-harness evaluation (#949/IL-797) had **deferred** an external
self-improving harness and selected the **factory-native lesson-capture** (#951) as the safe substitute. This
mandate **upgrades that posture: a self-improving harness is now MANDATORY, not deferred** — but bounded by the
**authority gate** (ADR-135/136). It is therefore **consistent** with #949's safety rationale: the *value* of
self-correction is made obligatory, while the *risk* it flagged (unbounded self-modification, authority drift)
stays fenced by the non-delegable PROMOTE-TO-CANON gate. Improve — mandatory; promote — gated.

## Boundaries
- **No ADR edited** — this governance doc **references** ADR-136/145/135/130/128/127; it changes none of them.
  Any change to the *ceiling* (the gate, authority) would be an ADR revision, out of scope here.
- **No authority delegated, no authority expanded** — PROMOTE-TO-CANON stays factory-only, HITL, non-delegable
  (ADR-145 core invariant; ADR-135 "no authority expansion, ever").
- **No project code, no perimeter touch** — the project-side IMPROVE mechanism is built project-side under the
  operator gate, in a locus that **AWAITS-OPERATOR** (§4). No repo is created or invented.
- **RED-ZONE unchanged** — payment / KYC / AML (ADR-137) stays RED-ZONE-excluded by default; nothing here
  projects a RED-ZONE capability.

## Anchors
`docs/adr/ADR-136-agentmemory-shared-memory-substrate.md` (memory read-only w.r.t. authority — describes,
never authorizes) · `docs/adr/ADR-145-factory-project-fork-target-model.md` (non-delegable authority +
**delegable execution** — the improve/promote split's spine) · `docs/adr/ADR-135-agent-skill-evolution-gate.md`
(permitted skill-evolution L2/L3; "no authority expansion, ever"; held-out adoption gate) ·
`docs/adr/ADR-130-*` (SOUL — no authority expansion) · `docs/adr/ADR-128-banking-agents-hitl-matrix.md`
(L1 auto / L2/L3 gated ladder) · `docs/adr/ADR-127-*` (Tier-1 read-only / no-dispatch boundary) ·
`docs/governance/FACTORY-LESSON-CAPTURE.md` (#951 — the IMPROVE mechanism, factory side) ·
`.claude/skills/*/SKILL.md` (#953 — invokable skills) · `docs/governance/FACTORY-PROJECT-PROJECTION-MODEL.md`
(#967; Appendix A/#968 corrected here via Appendix B) · ADR-102 (Duplication Audit — restates none of the
above). Operator principle change 2026-07-02 (self-improvement mandatory for both forks; promote-to-canon stays
gated and non-delegable).
