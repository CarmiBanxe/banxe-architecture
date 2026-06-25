---
id: ADR-127
title: Hermes Tier-1 delegation contract in the Software Factory pipeline (OpenClaw / Ruflo / NanoClaw orchestration boundary, read-only/alerting, HITL-safe)
status: PROPOSED
date: 2026-06-25
accepted: 
supersedes: []
relates:
  - "ADR-126 (Hermes Tier-1 role — this ADR details the delegation/handoff contract within those exact bounds)"
  - "ADR-117 §Hermes (future factory work item; perimeter — factory node only)"
  - "ADR-025 (agent-interaction canon — handoff/contract shape)"
  - "ADR-103 (server-only; operator hosts/configures any Hermes server)"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
  - ".claude/rules/agents.md (ARL/Ruflo pipeline BUG-005; HITL thresholds BUG-007)"
il_anchor: IL-547
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
scope: BANXE-factory-only
concept_only: true
research_ref: "Hermes-Agent-Razbor-i-primenenie-v-EMI-BANXE-AI-Bank-i-Software-Factory.md (attached research artifact — referenced, NOT duplicated)"
---

# ADR-127 — Hermes Tier-1 delegation contract in the Software Factory pipeline

## Context

ADR-126 fixed Hermes as a **Tier-1, read-only / alerting-first, HITL-safe** companion that sits **below** the Tier-0 orchestration layer (Claude Code / OpenClaw-MoA) and never substitutes for it. The attached research artifact (referenced, **not duplicated**) maps a Factory pipeline in which an orchestration layer decomposes work and specialist agents execute it.

This ADR records the **delegation/handoff contract** for that future Tier-1 role: precisely how Hermes may hand observations to, and receive read-only signals from, the orchestration/swarm agents (OpenClaw orchestration, Ruflo swarm dispatch, NanoClaw test generation) **without acquiring any write, merge, deploy, or compliance authority**. It introduces **no runtime code** and adds **no agent passport, soul, or config stub**.

## Decision

**Hermes participates in the Factory pipeline only as a read-only observer and alert producer. All task decomposition, code generation, spec authoring, test generation, and merge/deploy remain with the Tier-0 orchestration layer and its gated flow. Hermes never originates or approves a state-changing action.**

### IN SCOPE (Tier-1 delegation, read-only / alerting-first)
1. **Observe orchestration state** — read pipeline/spec/lock status (Lock 0 to 1 to 2 progression) and surface stalls, failed gates, or coverage regressions as **alerts** to a human.
2. **Receive read-only signals** from swarm/test agents (e.g. benchmark deltas, failing spec-to-code tasks) and forward them as operator notifications. No re-dispatch, no auto-retry that changes state.
3. **Research-fetch assist** — browser/SSH/cron gateways feeding **human** decisions only.

### OUT OF SCOPE (hard boundary — never, without a new ADR + operator HITL)
- **Task dispatch / orchestration** — Hermes does **not** issue ruflo run, assign Lock-0 specs, trigger NanoClaw, or drive OpenClaw coding. It does not replace Tier-0.
- **Merge / deploy authority** — unchanged from ADR-126: none.
- **Payment-core / AML / SAR** — unchanged from ADR-126: AI-FORBIDDEN to Hermes (RED zone; BUG-005 pipeline excludes it).
- **Credential-bearing actions** — no Hermes-held repo write tokens, scoped or otherwise; secrets stay operator-side (ADR-103).

## HITL / read-only / security boundaries
- **Hermes proposes; a human (or the gated Tier-0 flow) disposes.** Every handoff out of Hermes is an alert/notification, never an executed privileged action.
- **Fail-closed.** If a delegation path is ambiguous, the action is denied and escalated to a human; Hermes does not self-expand into Tier-0.
- **Perimeter (ADR-117).** Factory infra-monitoring plane only; never the PROJECT RED zone, never banking/domain models.

## Duplication Audit (ADR-102)
1. **Repo-wide search** for an existing delegation/handoff doc for Hermes — none exists; ADR-126 defines the role but not the pipeline handoff contract. No passport, soul, swarm, or config stub references Hermes.
2. **Source-of-truth.** Role bounds = ADR-126 (parent); interaction shape = ADR-025. This ADR-127 is the source-of-truth for the **delegation contract**, subordinate to and consistent with both. The research artifact is **referenced via research_ref, not duplicated**.
3. **No hidden dependencies.** No code/CI keys off a Hermes delegation path — nothing to wire.
4. **Decision per match:** ADR-126 to KEEP (parent, pointer only); ADR-025 to KEEP. **No delete, no merge, no parallel duplicate.**
5. **No doubt / fail-closed:** no ambiguity; nothing to escalate; no runtime code added.

## Consequences
- Any future "wire Hermes into the pipeline" work starts pre-bounded: read-only observer + alert producer, with Tier-0 orchestration and merge/deploy/compliance authority explicitly withheld.
- No parallel Hermes doc is created (ADR-102 satisfied); the research artifact stays the single external evidence base.
- **No runtime change.** Activation remains a future, separately-gated work item (passport under I-27, operator HITL, server-only host).

## Anchors
- ADR-126 (Tier-1 role, refined here into a delegation contract), ADR-117 §Hermes (perimeter), ADR-025 (agent-interaction canon).
- ADR-102 (Duplication Audit), ADR-103 (server-only), ADR-119 (IL numbering).
- .claude/rules/agents.md — ARL/Ruflo pipeline (BUG-005), HITL thresholds (BUG-007).
- Research artifact Hermes-Agent-Razbor-i-primenenie-v-EMI-BANXE-AI-Bank-i-Software-Factory.md (attached; referenced, not duplicated).
