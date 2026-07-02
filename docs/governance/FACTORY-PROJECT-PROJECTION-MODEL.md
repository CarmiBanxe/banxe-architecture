# Factory → Project Projection — operating model

> **Status:** governance operating model (consolidation). **Date:** 2026-07-02. **Owner-terminal: A
> (factory).** **Pointer-first and additive (ADR-102).**
>
> Consolidates the **already-defined** factory→project feature-projection pattern into one operating model.
> **It introduces NO new mechanism** — ADR-145 (fork model), ADR-135 (adoption gate), and ADR-117 (perimeter)
> remain the source; this document only names, sequences, and indexes them. **It delegates NO authority to
> the project fork, writes no project code, and touches no perimeter or machine.** It restates none of the
> canon it binds — it references it.

## 1. Principle
> Operator requirement (2026-07-02): *"every feature must have a fork onto the project and be used by both the
> factory and the project."*

Every feature is **two-sided**:
- a **factory / governance side** — the rules, spec, and config authored **here** (`banxe-architecture`);
- a **project projection** — the executable part built in a project repo (`banxe-emi-stack` / `banxe-ui` /
  `banxe-monitoring`), against the **same governance contract**.

**Both forks — factory and project — consume the one governance contract.** A feature is **not** factory-side
only; the governance side is the shared source of truth, and the project projection is its executable
consumer. Authoring the governance side without a project projection leaves the feature *un-projected* (§3/§4).

## 2. Projection lifecycle (consolidated from existing canon — not rewritten)
1. **Factory authors** the governance spec / build-prompt in `banxe-architecture`. **Merge-authority and the
   ADR-135 adoption gate are non-delegable** — they stay in the factory fork (ADR-145; PRECOND-07: *the
   project fork is an execution consumer, never an authority*).
2. **Project / infra builds** the executable part against that contract, in the project repo
   (`banxe-emi-stack` / `banxe-ui` / `banxe-monitoring`), **under the operator gate, beyond the ADR-117
   perimeter** (project hardware/repos are operator-owned).
3. **Validated result is promoted back through the ADR-135 held-out adoption gate** — **factory-only**; the
   project fork never self-promotes into canon.
4. **Shared layer:** `ledger/` is **shared, append-only** (each terminal appends only its own session shard —
   TERMINAL-OWNERSHIP / ADR-059); **both forks read the one contract**. Cross-fork contention is deconflicted
   via CONFLICT-LEDGER + TERMINAL-OWNERSHIP.

This is the established build-prompt handoff pattern (governance-side spec → project-side build under the
gate → factory-only promotion), stated once as canon-consolidation.

## 3. Coverage matrix (facts of this programme)
| Feature | Factory / governance artefact (on `main`) | Project projection (build-prompt / contract) | Project repo target | Projected? |
|---|---|---|---|---|
| **server-2 compute** | policy `SERVER-2-BORROWABLE-COMPUTE-ORCHESTRATION` (#932) + `config/compute/server-2-borrow-policy.yaml` (#933/#936) + `SERVER-2-RUNTIME-ENFORCER-SPEC` (#934) | `SERVER-2-ENFORCER-BUILD-PROMPT` (#939) | `banxe-emi-stack` / infra *(`[BLOCKING: operator]` exact repo)* | **✅ projected** (build-prompt exists) |
| **UI/UX audit** | spec `UIUX-AUDIT-BLOCK-SPEC` (#916) + schema/gate-policy (#918) + `UIUX-RUNTIME-CONTRACT` (#920) + `UIUX-EVIDENCE-EMISSION-SPEC` (#928) | `BANXE-UI-EMITTER-BUILD-PROMPT` (#942) + `UIUX-RUNNERS-BUILD-PROMPTS` (#944) | `banxe-ui` | **✅ projected** (build-prompts exist) |
| **fleet-control** | policy `SERVER-CONTROL-ORCHESTRATION` (#959) + placement/ratified `config/fleet/*` (#964) | `FLEET-MONITOR-BUILD-PROMPT` (#963) | `banxe-monitoring` (+ #939 enforcer project-side) | **✅ projected** (build-prompt exists) |
| **lesson-capture** | `FACTORY-LESSON-CAPTURE` (#951) — factory-native register | — (**not projectable by default**) | none — agent-harness class | **⛔ factory-fork-only (correct-by-canon)** — ADR-136 PRECOND-05 (see Appendix A) |
| **skills → SKILL.md** | `.claude/skills/{github-navigation,spec-writing,testing}/SKILL.md` (#953) — factory harness | — (**not projectable by default**) | none — agent-harness class | **⛔ factory-fork-only (correct-by-canon)** — ADR-136 PRECOND-05 (see Appendix A) |

Honest read: **three features are projected** (server-2, UI/UX, fleet-control — each has a project-side
build-prompt); **two are agent-harness / self-improvement features that are factory-fork-only by canon**
(lesson-capture, skills) — **not a pending gap**, see Appendix A. **Net: 3 projected + 2 factory-fork-only
(correct-by-canon) = 0 pending gap.**

## 4. Gap-list — resolved: 0 pending gap
Per §3 and **Appendix A**, the two features that lack a project projection (lesson-capture #951, skills #953)
are **agent-harness / self-improvement** features that are **factory-fork-only by canon (ADR-136 PRECOND-05)**
— **not un-projected gaps.** There is **no `[НЕИЗВЕСТНО]` pending build-prompt** for them; projecting them
would *violate* ADR-136 by default, not satisfy the projection principle. **Net: 3 projected + 2
factory-fork-only (correct-by-canon) = 0 pending gap.** The only way either becomes projectable is an explicit
ADR-136-gated operator decision to create an **agent-harness project fork** (Appendix A) — a governance call,
not a routine build-prompt; **no such repo is fabricated here.**

## 5. Boundaries
- **No new mechanism** — ADR-145 (fork model), ADR-135 (adoption gate), ADR-117 (perimeter) remain the
  source; this doc consolidates and indexes them only. No new gate, invariant, or authority.
- **No authority delegated to the project fork** — the project fork stays an **execution consumer, never an
  authority** (ADR-145 / PRECOND-07); merge-authority + the ADR-135 gate stay factory-only.
- **No project code written** — this authors governance-side consolidation only; project projections are
  built project-side under the operator gate.
- **RED-ZONE excluded by default** — payment / KYC / AML (ADR-137) is **RED-ZONE-excluded from the project
  fork by default**; projecting any RED-ZONE feature is an explicit, separately-gated operator decision, not
  covered by this default model.

## Appendix A — Factory-fork-only exception (ADR-136 PRECOND-05)
> Additive appendix (audit-resolved 2026-07-02). The §1–§5 body is unchanged in substance; this appendix
> reclassifies the two matrix rows that appeared as gaps and records the canonical exception to the
> "every feature forks to the project" principle. It **invents no repo** and **creates none**.

- **The projection principle (§1) applies to features of *projectable* nature** — runtime / UI / ops:
  server-2 → `banxe-emi-stack`/infra, UI/UX → `banxe-ui`, fleet-control → `banxe-monitoring` (**3/3
  projected**).
- **EXCEPTION — agent-harness / self-improvement features are factory-fork-only by default (ADR-136
  PRECOND-05).** `lesson-capture` (#951) and `skills → SKILL.md` (#953) are the agent's own
  self-modification / prompts / capabilities. The agent **does not delegate its self-improvement to the
  project fork** — authority is non-delegable (ADR-145 / PRECOND-07), and the agentmemory/self-improvement
  substrate is **factory-fork-only by default** (ADR-136 / PRECOND-05). There is **no agent-harness project
  repo** — **all project repos are product-runtime** (`banxe-emi-stack`, `banxe-ui`, `banxe-fiat-backend`,
  `banxe-dashboard`, `banxe-payments`, `banxe-identity`, `banxe-uikit`, … — none is an agent-harness/prompts
  repo).
- **Reclassification:** the two `❌ NOT projected` matrix rows are now `⛔ factory-fork-only
  (correct-by-canon)` — **not a pending gap.** The matrix reads **3 projected + 2 factory-fork-only = 0
  pending gap.**
- **Open option (NOT decided here):** projecting an agent-harness feature is possible **only** via an explicit
  **ADR-136-gated operator decision to create an agent-harness project-fork repo** — a governance call, not a
  routine build-prompt, and not covered by the default model. **AWAITS-OPERATOR; no repo fabricated.**
- **Data-quality correction:** the `SERVER-2-ENFORCER-BUILD-PROMPT` (#939) targets **`banxe-emi-stack` /
  infra**, **not** `banxe-ui` (a `banxe-ui` mention in that doc is the ADR-117 *exclusion* — "not banxe-ui";
  a grep artefact). The §3 matrix target for server-2 is `banxe-emi-stack`/infra.

## Appendix B — Self-improvement is mandatory; only promote-to-canon is factory-gated (corrects A's over-broad read)
> Additive appendix (operator principle change 2026-07-02). **Appendix A (#968) is NOT removed** — its
> **authority-half** fence (promote-to-canon is non-delegable) is correct and stays. Appendix B **corrects only
> A's treatment of the *improve* half**: A read `⛔ factory-fork-only` over the whole feature, which fenced off
> self-improvement itself. Canon (ADR-136/145/135/130/128/127) gates **authority-promotion**, **not** learning.
> B is **self-contained** — it states the full authority/improve split below (it depends on no other appendix).
> It **supersedes the earlier draft that read the improve half as "factory-fork-only by default"** (that draft's
> only correct idea — the two-half split — is carried in full here). Full statement:
> `docs/governance/SELF-IMPROVEMENT-MANDATE.md`. No ADR edited, no matrix count changed, no repo invented.

- **Operator principle (2026-07-02):** **self-improvement is MANDATORY** — for factory agents obligatorily,
  for **project agents at 100%.** An agent improving itself (capture lessons, optimise its own runs, evolve its
  own skills within its role) is **delegable execution** (ADR-145) + **permitted skill-evolution** (ADR-135,
  L2/L3 under ADR-128) — **not** an authority act, so **not** fenced to the factory.
- **The improve / promote split** (see mandate §2): **IMPROVE** (learning/optimisation) = **mandatory for BOTH
  forks**, agent improves freely; **PROMOTE-TO-CANON** (change shared rules / expand authority) = **GATED +
  NON-DELEGABLE**, only via the ADR-135 held-out gate (HITL, factory-only). No authority-expansion, ever
  (ADR-135).
- **Re-read of the two `⛔` rows (A NOT deleted):** `lesson-capture` (#951) and `skills → SKILL.md` (#953):
  - **was** (A): `⛔ factory-fork-only` — over-broad, fenced self-improvement itself;
  - **now** (B): **`self-improve: both-forks-mandatory` (the IMPROVE mechanism projects to the project fork) ·
    `promote-to-canon: factory-gated` (authority stays factory-only, non-delegable).**
  The **authority half** Appendix A isolates is unchanged and correct; only the **improve half** is corrected
  from "does not fork" to "**must** fork to both."
- **Project-fork locus = AWAITS-OPERATOR (no repo fabricated):** project-side IMPROVE requires an agent-harness
  project-fork locus; **no such repo exists** (all project repos are product-runtime). Its concrete repo is a
  **`[BLOCKING: operator / ADR-136-gated]`** decision — the single operator call before any project-side
  build. **Not invented here.** The mandate is **in force for the factory fork now**, specified-but-pending for
  the project fork. The locus would host **only the IMPROVE mechanism**; PROMOTE-TO-CANON authority never
  delegates (ADR-145).
- **Matrix unchanged in count:** the §3 coverage matrix is **not** re-tallied here; Appendix B corrects the
  *interpretation* of the two `⛔` rows (see the mandate for the authoritative statement), and adds no
  projected/gap count.

## Anchors
`docs/adr/ADR-136-agentmemory-shared-memory-substrate.md` (PRECOND-05 — agent-harness/self-improvement
factory-fork-only by default; the exception's source) ·
`docs/adr/ADR-145-factory-project-fork-target-model.md` (fork model — factory authority, project consumer) ·
`docs/adr/ADR-135-agent-skill-evolution-gate.md` (held-out adoption gate — factory-only promotion between
forks) · `docs/adr/ADR-117-factory-project-perimeter-and-fullcycle-org.md` (perimeter) ·
`docs/adr/ADR-137-*` (RED-ZONE exclusion by default) · `docs/governance/TERMINAL-OWNERSHIP.md` (shared ledger,
cross-repo code zone) · `docs/governance/CONFLICT-LEDGER.md` (cross-fork deconfliction) · the six
projections consolidated here — `UIUX-RUNTIME-CONTRACT` (#920) · `UIUX-EVIDENCE-EMISSION-SPEC` (#928) ·
`SERVER-2-ENFORCER-BUILD-PROMPT` (#939) · `BANXE-UI-EMITTER-BUILD-PROMPT` (#942) · `UIUX-RUNNERS-BUILD-PROMPTS`
(#944) · `FLEET-MONITOR-BUILD-PROMPT` (#963) · ADR-102 (Duplication Audit — this restates none of the above).
Operator directive 2026-07-02 (every feature forks to the project; consolidate the projection model).
