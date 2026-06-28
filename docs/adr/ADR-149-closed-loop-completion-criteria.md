---
id: ADR-149
title: Closed-loop completion-criteria for prepare-only factory tasks
status: PROPOSED
date: 2026-06-28
concept_only: false
relates:
  - "ADR-117 (factory↔project perimeter)"
  - "ADR-135 (held-out adoption gate — HITL on every mutation)"
  - "ADR-148 (Hands-On-AI adoption pack — self-reflective loop = quality heuristic, NOT a governance gate)"
  - "ADR-119 / ADR-143 / ADR-143-A (stable IL numbering + central single-writer allocator)"
  - "ADR-120 (per-session worktree isolation); parallel-session-isolation Rule 6/7"
il_anchor: IL-717
il_anchor_note: "Provisional per ADR-119 Rule 8 — minted by the central allocator (ADR-143/143-A) over current origin/main. Frozen at rebase-before-merge."
scope: BANXE-factory-governance
external_ref: "agent-looping patterns (research ref: @shannholmberg / Steinberger; loops.elorm.xyz) — referenced as PATTERNS, NOT a dependency / not imported / not a runtime"
---

# ADR-149 — Closed-loop completion-criteria for prepare-only factory tasks

> **DRAFT governance artifact. PREPARE-ONLY.** Codifies how a prepare-only factory task self-terminates.
> Promotion to ACCEPTED is operator (Software Factory Lead) action via ADR-135. No RED-zone content; no
> new runtime; authority stays factory-only.

## 1. Context
Agent-looping patterns (research ref: `@shannholmberg` / Steinberger; `loops.elorm.xyz`) describe
self-iterating agents. They are referenced here **as patterns only — NOT a dependency, NOT imported, NOT a
runtime.** The BANXE factory is **already a closed fleet-loop** (bounded agents + deterministic gates +
HITL). This ADR makes the loop's **stop-condition explicit** so prepare-only tasks terminate deterministically
instead of relying on manual nudging — the gap that produced the 4× wave-drift churn on #869/#872.

## 2. Decision
1. **Completion-criteria = first-class field** in the IL shard of a prepare-only task — a **declarative
   stop-condition**, e.g. `--check=0 AND behind-0 AND back-refs-resolved AND FROZEN-untouched`. The task is
   "done (prepare)" iff every clause holds.
2. **Closed looping only.** For regulated / EMI work, the loop MUST be bounded and gate-terminated.
   **Open-ended looping is FORBIDDEN** (token-burn + output-slop + uncontrolled egress / FCA exposure).
3. **Self-correcting loop in the PREPARE phase only** (discovery → draft → verify → fix, iterated until
   gates pass). **STOP at ANY mutation = HITL ADR-135** — merge, renumber, permission change, or
   push-to-main are never inside the autonomous loop; they are operator-gated exits.
4. **Egress only via the LiteLLM seam.** An external loop-service as runtime is **FORBIDDEN** (§0.5
   single-egress-seam; no external API in the loop).

## 3. Consequences
- Removes manual churn: an `auto-rebase-until-behind-0` closed loop (gate-terminated on `behind-0 AND
  --check=0`) would have absorbed the entire #869/#872 wave-drift sequence autonomously.
- HITL on every irreversible action is preserved — the loop self-corrects up to the gate, then **stops and
  hands off**. Determinism (allocator + serialize gate + `--check`) bounds the loop; it cannot run away.
- No new runtime, no external dependency, no RED-zone surface.

## Anchors
ADR-117 / ADR-135 (HITL) / ADR-148 (self-reflective ≠ gate) / ADR-119 / ADR-143 / ADR-143-A / ADR-120 ·
parallel-session-isolation Rule 6/7 · external pattern ref (not imported). PREPARE-ONLY; operator HITL via
ADR-135.
