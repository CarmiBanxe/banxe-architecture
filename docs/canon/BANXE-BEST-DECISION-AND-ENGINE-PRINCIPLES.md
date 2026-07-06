# BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES

> Additive canon, **pointer-first** (ADR-102). It links the best-decision concept to BANXE architecture and the
> 24/7 agent runtime. It **references** the theory and the adoption gate; it does **not** restate them, and it
> changes no SOUL, no passport, and not `agents/souls/_TEMPLATE.md`. Prepare-only; never overrides a stop-barrier
> or a HITL gate. **Source note:** the mathematics is preserved verbatim in
> `docs/sources/best-decision-concept-2026-07-06.md` (source #1); the engine content is repo-resident as the
> **agent-engine dossier** (`docs/agent-engine-dossier/SRC-01…03` + `ENGINE-ROADMAP.md` — the structured ingestion
> of source #2 "EMI BANXE AI BANK — Идеальный Open Source Движок", "Corpus Part 1–3"), referenced pointer-first.
> The raw original of source #2 is not a single repo file; verbatim archival of it (as done for source #1) is a
> separate step, not required by this doc.

## 1. Purpose

State, in one place, how BANXE's **best-decision** mathematics becomes **operational rules**, and how the engine
runs AI agents **24/7** safely. The theory and the adoption gate already exist (§7); this doc is the bridge.

## 2. Best Decision as a mathematical concept

Definitions live in `docs/sources/best-decision-concept-2026-07-06.md` and are not restated here. The applicable
method families: **expected utility (VNM)**, **Bellman-MDP** dynamics, **MCDA** (MAUT / AHP / TOPSIS / PROMETHEE /
ELECTRE), **multi-objective Pareto / NSGA-II**, **decision-under-uncertainty** rules (maximin / minimax-regret /
Hurwicz), **satisficing** (Simon), **optimal stopping** (secretary rule), **prospect theory** + **ambiguity
aversion** (Ellsberg), **reversibility / real options**, and **value-of-information**. Core reframe:
**"improvement ≠ necessarily the best decision"** — adoption is justified only when net-utility(adopt) exceeds
status-quo *including* cost, risk, and opportunity-cost.

## 3. Best Decision in BANXE operations

BANXE is a **continuous bank-agent runtime** — not a batch system, not a single-request assistant. Therefore
"best decision" is a **sequential best-next-decision under constraints** (an MDP / optimal-stopping policy over a
running state), never a one-shot optimum. Central's **adoption-audit gate** (ADR-162) applies this to every
intake: **ACCEPT / REJECT-AS-NOT-WORTH / DEFER**, scored on value / cost / risk / reversibility / strategic-fit
(EMI-scope) / opportunity-cost. Math → rule mapping: EU / MAUT → the weighted six-criterion verdict; MDP /
secretary → timing and DEFER; minimax-regret / prospect → risk posture; Pareto / NSGA-II → trade-off framing.

## 4. Runtime agent boundary: fail-closed over best-decide

Per `docs/canon/BEST-DECISION-BOUNDARY.md` (pointer, not restated): the **orchestrator / Factory** best-decides on
non-production, non-stop-barrier work; **runtime L2+ agents** on payment / compliance / KYC / AML **fail-closed and
escalate** — never best-decide to clear a sanctions hit, release a payment, self-escalate a level, or bypass a
gate. On the compliance / payment contour, **fail-closed takes precedence** (I-27, BUG-007). Best-decision is
throughput; fail-closed is safety; the adoption gate (ADR-162) sits between them. The engine-side statement of
this split is `docs/agent-engine-dossier/SRC-03-implementation-state.md` §3 (Governance vs Runtime Divergence),
pointer only.

## 5. Engine principles that make this safe

For a 24/7 agent bank, correctness is a **runtime** property, not a one-time check. Mandatory:

- **resume after failure** — durable state; no in-flight decision is lost;
- **idempotent execution** — no double-spend / duplicate side-effect on retry;
- **timeout / retry discipline** — bounded, typed; escalate on exhaustion, never loop silently;
- **append-only audit lineage** — every decision + gate outcome is traceable (I-08 / I-24);
- **no silent autonomous financial action** — customer funds are always human-gated (I-27);
- **human escalation on ambiguity, invariant breach, or confidence drop** (BUG-007: AUTO >90 / REVIEW 70–90 / BLOCK <70).

## 6. Architectural implications for Factory / LangGraph / HITL / Ledger / Audit

- **Factory** — authors and prepares; every state change flows worktree → PR → operator merge (FACTORY-CANON); it
  best-decides its own next step and **never activates**.
- **LangGraph (stateful orchestration)** — the agent graph carries running state, so best-next-decision is
  sequential; nodes are typed, resumable, and gate-aware.
- **HITL** — the fail-closed gate materialises as a human-review node; a confidence drop routes to REVIEW / BLOCK
  (BUG-007), and no level self-escalates.
- **Ledger** — append-only IL (ADR-059 / ADR-119); adoption verdicts (ACCEPT / REJECT-AS-NOT-WORTH / DEFER) are
  **recorded, not discarded** — a `reject-as-not-worth` is proof Central looked.
- **Audit** — immutable lineage (`clickhouse_writer`, I-24; DORA retention I-17).
- **24/7 agent operations** — BANXE runs continuously on: **Temporal** durable workflows (resume-after-failure),
  **Kafka** event streaming (decoupled, replayable), **LangGraph** stateful orchestration (sequential
  best-next-decision), **Kubernetes** runtime (self-healing), **observability / audit** (append-only lineage),
  and **fail-closed HITL escalation** (no silent financial action). *Operational expectation:* the Factory
  prepares and proposes; the runtime acts only through **durable, idempotent, audited, human-gated** steps — a
  failure **resumes**, never silently drops or double-acts, and ambiguity **escalates**, never self-clears.

### Factory–Central–Right synchronization

Synchronization of the three contours (Factory / Terminal A / LEFT, Central, Right terminal) is **MANDATORY for
technological works** touching orchestration, agent runtime, service-code, passports / SOUL / HITL, or shared
schemas / audit / ledger / routing — no contour silently diverges from the others on working state. The full
discipline (sync-before-shared-change · sync-after-audit-confirmed-change · no-silent-divergence ·
visibility-through-Central · execution-boundaries-remain) is **canon in ADR-163 / `docs/canon/SYNC-CANON.md`**
(pointer only, not restated — ADR-102). It is a **consistency rule, not contour-capture** — Rule 6 / ADR-153
execution boundaries stay in force. (The 24/7 runtime above is a live instance of why: parallel actors on divergent
`origin/main` baselines is precisely what SYNC-CANON prevents.)

## 7. Anchors

- `docs/sources/best-decision-concept-2026-07-06.md` — academic basis (source #1; ~40 references)
- `docs/adr/ADR-162-best-decision-principle.md` — best-decision adoption-audit gate; `tests/best-decision/`
- `docs/canon/BEST-DECISION-BOUNDARY.md` — orchestrator best-decide vs runtime fail-closed
- `.claude/rules/agents.md` — BUG-007 HITL thresholds; ARL / Ruflo pre-gate; Temporal / Kafka (FinDev matrix)
- `docs/factory/FACTORY-CANON.md` · `CLAUDE.md` §12 · I-08 / I-17 / I-24 / I-27 · ADR-059 / ADR-102 / ADR-120
- ADR-153 (terminal topology) · **ADR-163 / `docs/canon/SYNC-CANON.md`** (mandatory sync discipline) · `.claude/rules/parallel-session-isolation.md` Rule 6 · `governance/COORDINATION-NOTES.md` (cross-terminal sync)
- `docs/agent-engine-dossier/` — engine SSOT (source #2, "Corpus Part 1–3"): `SRC-01-engine-landscape.md` (architecture / OSS landscape), `SRC-02-theory-principles.md` (formal notation), `SRC-03-implementation-state.md` (§3 governance vs runtime), `ENGINE-ROADMAP.md` (L1→L2→L3 adoption gate)
