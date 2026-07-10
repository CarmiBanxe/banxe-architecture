# BEST-DECISION-LEARNING-LOOP — canon

> **Status:** PROPOSED · **Classification:** additive canon, **pointer-first** (ADR-102 — references, does not restate).
> **Scope:** the **BANK runtime decision-quality loop** — payment / compliance / KYC / AML (RED contour) and the
> information contour. This is the **feedback loop** over a bank-agent decision — it is **NOT** a new decider
> (that is **ADR-164** / `docs/design/BEST-DECISION-AGENT.md`), and it is **NOT** the factory self-healing loop
> (that is **ADR-141**, `scope: BANXE-factory-only`, RED zone **excluded** per PRECOND-06). This doc is the exact
> complement ADR-141 does not cover. Authored sync-before-write off current `origin/main` per **ADR-163 SYNC-CANON**.

## Purpose
One place defining how a bank-agent decision becomes a **measured, improvable event** — with **no autonomous
self-modification**. The loop: **decide → record → score/outcome → evaluate → propose config change → human/MLRO gate**.
It invents no decider and no threshold; it wires the **existing** pieces into a human-gated feedback cycle.

## Distinctness (ADR-102 — why this is net-new, not a rival source-of-truth)
- **ADR-164 / `docs/design/BEST-DECISION-AGENT.md`** — the per-agent advisory *method* (the decider unit). Pointer.
- **ADR-141** — the *factory* self-healing learning loop, `scope: BANXE-factory-only`, RED payment/KYC/AML/sanctions
  **excluded** (PRECOND-06). This doc is the **bank-runtime** loop over the RED/runtime contour ADR-141 does not
  reach. Pointer — **not redefined**.
- **`docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md` (sp38)** + **`docs/sources/consultant-response-best-decision-2026-07-07.md`** —
  the *ratification* of the decider design (incl. the deterministic admissibility gate before scoring). Pointer — this
  doc does not re-rule.
- **ADR-162 / `docs/canon/BEST-DECISION-BOUNDARY.md`** — best-decision principle + orchestrator‑vs‑runtime boundary. Pointer.

## The loop (each stage binds to an EXISTING artifact — nothing invented here)
1. **DECIDE.** The agent decides via the ADR-164 method. On payment/compliance/KYC/AML the ratified architecture
   (consultant-response Q1 / sp38) applies a **deterministic admissibility gate BEFORE scoring** — a versioned,
   human-authored rule-engine emitting `ADMISSIBLE | BLOCKED`, **never modified by the agent** — then MAUT scoring for
   `ADMISSIBLE` only. Pointer, not restated.
2. **RECORD.** Emit a `DecisionRecord` conforming to `schemas/agent_decision_record.schema.json`, written to the
   append-only decision sink via `clickhouse_writer` `decision_events` (append-only I-24; retention I-17). Pointer.
3. **SCORE / OUTCOME.** Emit an `OutcomeRecord` linked to the `DecisionRecord`; the decision-quality metrics
   (calibration Brier/ECE, regret, Pareto) are defined in the consultant loop spec
   `docs/sources/best-decision-self-learning-loop-2026-07-07.md` — **referenced, not restated here.**
4. **EVALUATE.** Replay against `tests/best-decision/` (`validator.py`) and the confidence bands of **BUG-007**
   (AUTO>90 / REVIEW 70–90 / BLOCK<70; `.claude/rules/agents.md`). Pointer — **no new threshold is defined here.**
5. **PROPOSE.** When metrics drift, emit an **`ImprovementProposal`** (adjusted weights/thresholds) — **status
   PROPOSED only, never applied by the loop.**
6. **HUMAN / MLRO GATE.** Adoption of any proposal lands in governance config
   (`governance/novelty-pipeline-config.yaml`) **only** through a **human-gated PR** (Config-over-Hardcoding,
   CLAUDE.md §10; I-27; on AML/KYC additionally **MLRO**). Then the loop returns to DECIDE.

## HARD RULE — Never-Autonomous (stop-barrier)
No runtime L2+ agent on the payment / compliance / KYC / AML contour, and no automated loop, may **self-modify its own
gates, weights, or thresholds.** Every change to the decision config is a **human-ratified PR** (fail-closed
precedence; I-27; CLAUDE.md §11; `BEST-DECISION-BOUNDARY`). **«Предлагает система — утверждает человек.»** On
ambiguity, timeout, or an unverifiable fact: **fail closed → block + human**, never an autonomous apply.

## Orchestrator role (pointer)
The orchestrator aggregates decision-quality per agent, schedules re-tests, queues `ImprovementProposal`s, and
escalates degradation via the escalation protocol (`docs/sources/consultant-escalation-protocol-2026-07-07.md`,
ADR-164). It **does not decide adoption** — adoption is the human/MLRO gate. It never modifies a runtime gate.

## Rollout (pointer)
Per the consultant loop spec phases: factory teachers/orchestrators first → fleet; **sandbox → information-contour →
compliance/payment last** (strictest; AUTO≥0.95 as a *proposal*; ratification always required). Referenced, not restated.

## SYNC-CANON compliance (ADR-163)
Authored sync-before-write off current `origin/main`; ledger-write serialized (main-serialize); branch ADR-060-valid.
This canon adds **no runtime, config, or schema change** — it only documents the loop over existing artifacts.

## Anchors (pointer-first — none restated)
ADR-164 / `docs/design/BEST-DECISION-AGENT.md` · **ADR-141** (factory loop, RED-excluded — distinct) ·
`docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md` + `docs/sources/consultant-response-best-decision-2026-07-07.md` ·
ADR-162 / `docs/canon/BEST-DECISION-BOUNDARY.md` · **ADR-163 SYNC-CANON** · ADR-161 (SSOT) ·
`schemas/agent_decision_record.schema.json` · `clickhouse_writer` `decision_events` · `.claude/rules/agents.md` (BUG-007) ·
`tests/best-decision/` · `governance/novelty-pipeline-config.yaml` ·
`docs/sources/best-decision-self-learning-loop-2026-07-07.md` · `docs/sources/best-decision-concept-2026-07-06-v2.md`.

> **All thresholds / weights referenced above are PROPOSALS that live in governance config (Config-over-Hardcoding
> §10) and reach production only via a human-gated PR — never canon-hardcoded here, never activated by this doc.**
