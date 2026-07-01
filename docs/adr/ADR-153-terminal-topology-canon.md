# ADR-153: Terminal topology canon — A (factory) / Central / B (TRADING-001)

**Status:** PROPOSED — operator governance decision; **operator merge = enactment** (CLAUDE.md §1/§9)
**Date:** 2026-06-30
**Type:** Governance / org-topology canon — single authoritative source-of-truth for the terminal entities
**Supersedes (for topology naming):** the scattered/contradictory terminal definitions in `INSTRUCTION-LEDGER.md` (IL-7322/7323, IL-7840-7842), `PROMPT-CANON-PROJECT.md`, `OPERATOR-PLAYBOOK.md`, `ROADMAP.md`
**Reconciles (does NOT override):** AGENTS.md / `.claude/rules/agents.md` "Right Terminal" Best-Single-Artifact **behavioural** canon (see §Reconciliation)
**Anchors (mechanism, unchanged):** ADR-120 (worktree isolation), ADR-121 (destructive-action protection), `.claude/rules/parallel-session-isolation.md` (Rules 1–7), ADR-060 (branch namespace), §71 single-writer
**Plane:** banxe-architecture = decision/canon only. No runtime code. Additive (ADR-119 append-only).

> **Why this ADR.** A duplicate-check (ADR-102) found the terminal entities defined **three incompatible ways** on `main`, with "right", "left", and "Central" each meaning different things across sources, plus a `Sub-terminal A/B` naming layer. This ADR fixes ONE authoritative topology and reconciles the legacy terms. It is a **governance decision**: the factory prepares the record (§9); the **operator merge enacts it**.

## Decision — canonical 3-terminal topology

| Terminal | Position | Role |
|---|---|---|
| **Terminal A** | **LEFT** | **The Software Factory = orchestrator.** Builds and runs all project code through factory tasks; self-orchestrates; is the executor-of-record. ("Left = the AI agents / Software Factory.") |
| **Central** | — | **Production-line dispatcher / arbiter + operator-facing governance line.** Integrates factory results into the canonical pipeline; holds the Best-Single-Artifact output discipline; merge authority is operator-reserved. |
| **Terminal B** | **RIGHT** | **Special-mandate executor.** Current mandate = **TRADING-001** (the trading block: `banxe-trading-backend` / `banxe-trading-frontend`). Autonomous, non-overlapping work packages; isolation per the mechanism anchors. |

**Sub-terminal A/B** are **NOT** topology peers — they are **bounded-context execution-isolation UNITS** (a worktree + branch under whichever terminal spawns them), per ADR-120/121 + parallel-session Rules. Authority: **read + own-worktree + local-commit only**; push/PR via the orchestrating terminal; **merge operator-reserved**. The name "Sub-terminal" denotes an isolation unit, not a fourth terminal.

## Reconciliation (legacy → canon) — ADR-102 mapping, not duplication

| Legacy source | Legacy statement | Reconciled to |
|---|---|---|
| **AGENTS.md / `.claude/rules/agents.md`** | "**Right Terminal** = operator terminal = orchestrator; **Left** = AI agents" (Best-Single-Artifact) | The name "**Right Terminal**" there denotes the **orchestration / output-discipline ROLE**, **not** topological Terminal B. That discipline attaches to the orchestrating line (Central + Factory A). **Behavioural rules unchanged**; an additive naming pointer is added to those files (this PR) so readers are not confused by the "right" overload. A fuller rename to "Orchestrating Terminal" is an **optional follow-up** (operator-gated, NOT in this PR). |
| **IL-7840-7842** (BINDING) | Central=Perplexity (dispatcher); A(left)=innovation sandbox; B(right)=parallel executor | **MATCHES** the 3-terminal structure. Refinements: A's canonical role is the **Software Factory/orchestrator** (it may still prototype, but "innovation sandbox" was too narrow); B is narrowed from "general parallel executor" to "**special-mandate** executor (TRADING-001 current)". |
| **global `~/.claude/CLAUDE.md`** (not in-repo) | "Central = **Right Terminal**"; "Terminal A builds the factory" | "Central" carries the orchestration output-discipline (the "Right Terminal" *name*); topological position is not "B". **Out-of-band follow-up:** operator aligns the global file's wording (it is local, not git-tracked, so not editable here). |
| IL-7322/7323 | "Left=Comet/Perplexity; Right=Claude Code factory worker" (both CLOSED 2026-05-11) | **Historical/closed** — superseded; recorded for provenance only. |

**Key disambiguation:** "Right" was overloaded across two axes — a **behavioural** role-name ("Right Terminal" = orchestration discipline) and a **topological** position ("Terminal B (right)"). This ADR fixes the **topological** axis (table above); the behavioural "Right Terminal" name is reconciled by pointer, not redefined.

## Orchestration & isolation mechanism (unchanged)

Best-Single-Artifact output discipline, **§71 single-writer** (serialized writes), parallel-session **Rules 1–7** (Rule 6 HALT on foreign session, Rule 7 no destructive ops on shared/foreign state), **ADR-120** (per-session worktree), **ADR-121** (destructive-action protection), **ADR-060** (branch namespace) remain the orchestration/isolation mechanism for all three terminals and their sub-terminal units. This ADR changes naming/topology only, not the mechanism.

## Out of scope (fail-closed)

No edit to the behavioural rules of AGENTS.md/`.claude/rules/agents.md` (only an additive naming pointer); no edit to the global `~/.claude/CLAUDE.md` (operator out-of-band); no edit to foreign/active session branches (Rule 6/7); no runtime code; no ledger-history rewrite (legacy IL lines stay, reconciled by reference per I-28).

## Consequences

- **Positive:** one authoritative topology SoT; the "right/left/Central" and "Sub-terminal" confusion is resolved by an explicit mapping; smart orchestration into the single EMI BANXE AI BANK product is unambiguous.
- **Follow-ups (operator-gated, separate):** (1) optional rename of the AGENTS.md "Right Terminal" behavioural canon to "Orchestrating Terminal"; (2) operator aligns the global `~/.claude/CLAUDE.md` wording; (3) optional consolidation pointer from `AGENT-ORG-STRUCTURE.md` to this ADR.

## Related

AGENTS.md / `.claude/rules/agents.md` (Best-Single-Artifact, reconciled); IL-7840-7842 / IL-7322-7323 (superseded for topology); `PROMPT-CANON-PROJECT.md`, `OPERATOR-PLAYBOOK.md`, `ROADMAP.md`, `ADR-044` (Sub-terminal naming, reconciled); ADR-120/121/060, parallel-session-isolation Rules 1–7, §71; BANXE-TRADING-001 (Terminal B mandate). ADR-102 (this is a reconcile-mapping, not a duplicate).

- Complementary ownership axis — `docs/governance/TERMINAL-OWNERSHIP.md` + `docs/governance/TERMINAL-OWNERSHIP-AND-ANTIDRIFT.md` (registry series #903/#905/#913, 7/7 FINAL). Topology answers WHAT the terminals are (this ADR); the registry answers WHO owns which write-zone. The two reconcile bidirectionally (ADR-102 mapping, not duplication).

> **Governance:** PROPOSED. The factory prepared this record (§9 — LLM prepares materials, human decides). It declares the operator's stated topology as the SoT and reconciles the legacy terms; it does **not** silently override the behavioural "Right Terminal" canon (only an additive pointer). **Operator merge = enactment** (§1/§9). Prepared as a **DRAFT PR — DO NOT MERGE** without operator sign-off.
