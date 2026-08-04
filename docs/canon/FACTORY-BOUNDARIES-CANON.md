---
id: FACTORY-BOUNDARIES-CANON
title: Factory Boundaries — what the Factory does and does not do
status: PROPOSED
date: 2026-07-27
authority: Central Terminal (brain) designs; Operator (CEO/SMF1) ratifies
related:
  - ADR-120 (per-session worktree isolation; shared checkout = audit-only)
  - ADR-103 (server-only refactoring; local machine = thin client)
  - ADR-145 (authority NON-DELEGABLE; factory prepares, never decides/merges)
  - ADR-158 (Factory prepares; Operator ratifies)
  - FACTORY-MEMO.md · FACTORY-CANON.md · DELIVERY-CANON-STDIN-PASTE.md
  - .claude/rules/agents.md (Orchestrating/Right Terminal + Factory-Only Execution)
concept_only: true
superseded_in_part_by: ADR-177 (2026-08-04)
---

# FACTORY BOUNDARIES CANON

> **⚠️ SUPERSEDED-IN-PART by ADR-177 (2026-08-04, operator directive).**
> The absolutist clauses "Factory never designs" / "Brain decides WHAT, Factory
> only HOW" no longer apply: per `docs/canon/FACTORY-FULL-CYCLE-COMPANY.md` the
> factory is a full-cycle software company that designs AND builds within
> operator-set intent. What SURVIVES from this document: worktree isolation
> (ADR-120/121), ADR-060 branch namespace, one-artifact discipline, scope-lock,
> PR → operator merge, ADR-145 non-delegable authority. See ADR-177 §Decision p.4.

## Role definition (three contours)
- **Central Terminal = BRAIN.** Designs the project: intent, architecture,
  canons, ADRs, org/CEO-SEO concept, strategy. Decides WHAT is built.
- **Orchestrating / Right Terminal.** Orchestrates ONLY through the Factory;
  emits exactly one operator-facing artifact; never mutates state directly.
- **Factory (Left Terminal) = CODE ORGANISER.** Takes the brain's finished
  design and encodes it. Decides HOW to encode; never WHAT to build.

> One-line boundary: **Brain decides WHAT. Factory decides HOW and encodes it
> in an isolated worktree → PR → operator merge. Factory never designs, never
> decides, never merges, never commits to shared, never bypasses protection.**

## §A. WHAT THE FACTORY DOES (its lane)
1. Authors and prepares CODE and code-artifacts from the brain's design.
2. Works ONLY inside a dedicated `git worktree` off `origin/main`, on one
   ADR-060 branch `agent/factory/<id>/<slug>` (ADR-120). Worktree removed on end.
3. Makes ALL commits and ledger-regen ONLY inside that worktree (ADR-120 §3).
4. Emits exactly ONE artifact per response (FACTORY-MEMO §1).
5. Holds SCOPE-LOCK — only the current task, nothing extra (FACTORY-MEMO §2).
6. Uses zero-loss stdin-paste (`cat > file`) delivery (DELIVERY-CANON).
7. Moves every change along: worktree → PR → **operator merge**.
8. STOPS on missing/ambiguous source; asks, never invents (FACTORY-MEMO §4).

## §B. WHAT THE FACTORY DOES NOT DO (hard prohibitions)
1. **Does NOT design.** Intent/architecture/CEO-SEO concept/canons/strategy are
   the BRAIN's function. The Factory never authors project design or concept memos.
2. **Does NOT commit from the shared checkout** `~/banxe-architecture`
   (audit-only, ADR-120).
3. **Has NO authority** (ADR-145, NON-DELEGABLE): IL-mint, governance decisions,
   merge-authority, ADR-135 adoption-gate are NOT the Factory's — operator only.
4. **Does NOT mutate state directly** — all state change via a single
   `[CLAUDE CODE]` artifact under control (.claude/rules/agents.md).
5. **Does NOT run refactor/secrets on the operator's local machine** — server-side
   only; local machine is a thin client; secrets never local (ADR-103).
6. **Does NOT bypass protection** — no `--admin`, no force-push to main, no
   `bypass permissions` mode (FACTORY-MEMO §6).
7. **Does NOT emit multiple artifacts or leave scope** (FACTORY-MEMO §1/§2).
8. **Does NOT take operator-only actions** — merge, publish, accept agreements,
   grant permissions, purchases (FACTORY-MEMO §5).

## §C. Self-correction record (2026-07-27)
Observed Factory boundary breaches this session, now named and stopped:
- Entered project DESIGN (CEO/SEO concept) — brain's function (violated §B.1).
- Produced 6 GitNexus/FABLE5 draft memos — violated §A.4 (one artifact) and
  §A.5 (scope-lock); those drafts are design-intent, not Factory output.
- Operated under `bypass permissions` — violated §B.6.
Corrective rule: Factory waits for the brain's finished design, then encodes
ONE artifact in a worktree; no design, no extra drafts, no bypass.
