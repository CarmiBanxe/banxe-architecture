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
| **lesson-capture** | `FACTORY-LESSON-CAPTURE` (#951) — factory-native register | — | `[НЕИЗВЕСТНО — forked?]` | **❌ NOT projected** — candidate; no project projection defined (do not invent) |
| **skills → SKILL.md** | `.claude/skills/{github-navigation,spec-writing,testing}/SKILL.md` (#953) — factory harness | — | `[НЕИЗВЕСТНО]` | **❌ NOT projected** — candidate; no project projection defined (do not invent) |

Honest read: **three features are projected** (server-2, UI/UX, fleet-control — each has a project-side
build-prompt); **two are factory-side only** (lesson-capture, skills) and have **no project projection** yet.

## 4. Gap-list (features without a project projection)
Per §3, the following are **un-projected** and each is a **separate future build-prompt on operator signal —
NOT authored here**:
- **lesson-capture (#951)** — factory-native today; whether it forks to a project projection (and to which
  repo) is **`[НЕИЗВЕСТНО]` / AWAITS-OPERATOR**. (A project projection is plausible — e.g. a project-side
  lessons feed — but is not defined; not invented.)
- **skills → SKILL.md (#953)** — factory harness today; a project projection (project-side invokable skills)
  is **`[НЕИЗВЕСТНО]` / AWAITS-OPERATOR**.

Each gap, when you signal it, becomes its own prepare-only build-prompt (the §2 lifecycle) targeting the repo
**you** name — no project repo is fabricated here for an un-projected feature.

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

## Anchors
`docs/adr/ADR-145-factory-project-fork-target-model.md` (fork model — factory authority, project consumer) ·
`docs/adr/ADR-135-agent-skill-evolution-gate.md` (held-out adoption gate — factory-only promotion between
forks) · `docs/adr/ADR-117-factory-project-perimeter-and-fullcycle-org.md` (perimeter) ·
`docs/adr/ADR-137-*` (RED-ZONE exclusion by default) · `docs/governance/TERMINAL-OWNERSHIP.md` (shared ledger,
cross-repo code zone) · `docs/governance/CONFLICT-LEDGER.md` (cross-fork deconfliction) · the six
projections consolidated here — `UIUX-RUNTIME-CONTRACT` (#920) · `UIUX-EVIDENCE-EMISSION-SPEC` (#928) ·
`SERVER-2-ENFORCER-BUILD-PROMPT` (#939) · `BANXE-UI-EMITTER-BUILD-PROMPT` (#942) · `UIUX-RUNNERS-BUILD-PROMPTS`
(#944) · `FLEET-MONITOR-BUILD-PROMPT` (#963) · ADR-102 (Duplication Audit — this restates none of the above).
Operator directive 2026-07-02 (every feature forks to the project; consolidate the projection model).
