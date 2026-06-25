---
id: ADR-128
title: Banking-agent HITL authority matrix (L1/L2/L3 — MLRO/CRO/CTO gates), read-only AI by default
status: PROPOSED
date: 2026-06-25
accepted: 
supersedes: []
relates:
  - "ADR-126 (Hermes Tier-1 — confirms Hermes is NOT an L2+ decision agent; this ADR records the full HITL ladder it sits outside of)"
  - "ADR-019 (AI guardian two-family)"
  - ".claude/rules/agents.md (HITL thresholds BUG-007; ARL/Ruflo pipeline BUG-005; perimeter zones)"
  - "ADR-016 (AI plane PII/AML routing)"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
  - "COMPLIANCE-ARCH.md / SANCTIONS-POLICY.md (root canon)"
il_anchor: IL-548
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
scope: BANXE-factory-only
concept_only: true
research_ref: "Hermes-Agent-Razbor-i-primenenie-v-EMI-BANXE-AI-Bank-i-Software-Factory.md (attached research artifact — referenced, NOT duplicated)"
---

# ADR-128 — Banking-agent HITL authority matrix (L1/L2/L3)

## Context

The attached research artifact (referenced, **not duplicated**) proposes an org-structure of banking agents (AML analyst, transaction monitor, sanctions screening, fraud scoring, KYC specialist, risk oversight, customer support, ML-pipeline, deploy) each with a human-in-the-loop level. This ADR records the **authority ladder as canon** so any future agent adoption inherits a pre-bounded HITL gate, consistent with EU AI Act Art. 14 and existing guardian thresholds (BUG-007). It introduces **no runtime code** and provisions **no agent**.

## Decision

**All banking-domain AI is read-only by default. Every state-changing or compliance-bearing action is classified L1/L2/L3 and gated accordingly. No AI agent — Hermes included — may self-escalate across a level.**

### HITL levels
- **L1 (auto, read-only/observe):** health checks, metric/log monitoring, velocity counters, advisory read paths. AI may act; output is observational/alerting only.
- **L2 (human review — MLRO/CRO):** anomaly/threshold breaches, fraud-score review, KYC HIGH/PROHIBITED, AML triage. AI proposes; a named human disposes.
- **L3 (human-only — MLRO/CEO/CRO/CTO):** SAR filing, PEP approvals, AML-threshold changes, sanctions decisions, production deploy. **No AI authority whatsoever**; GPG-signed human action only.

### Authority matrix (canon summary)
- AML triage / SAR → **L2 review, L3 file** (MLRO).
- Transaction-monitor velocity → **L1 auto, L2 on threshold**.
- Sanctions screening → **L1 auto-flag; BLOCK + L3 decision**.
- Fraud scoring → **L2 review** above threshold.
- KYC → **L2 (MLRO) on HIGH/PROHIBITED**.
- Risk oversight → **L1 read-only monitor** (advisory; no auto-execute).
- Customer support → **L1 auto; L2 on escalation**.
- ML-pipeline → **L3 (CRO/CTO) sign-off**.
- Production deploy → **L3 (CTO), GPG-signed**.

## HITL / read-only / security boundaries
- **Hermes placement:** explicitly **outside** the L2/L3 decision path (per ADR-126). It may surface L1 signals that *inform* a higher-level human action, never take it.
- **RED zone (compliance swarm) is AI-FORBIDDEN to Tier-1** (BUG-005). The matrix never grants an AI agent write authority over customer funds, sanctions, or SAR.
- **Fail-closed.** Ambiguous level → treat as the higher level and escalate to a human.

## Duplication Audit (ADR-102)
1. **Repo-wide search** for an existing consolidated HITL authority matrix — thresholds exist piecemeal in `.claude/rules/agents.md` (BUG-007) and root compliance canon, but no single ADR consolidates the L1/L2/L3 ladder. No agent passport encodes it.
2. **Source-of-truth.** Guardian thresholds = `.claude/rules/agents.md`; this ADR-128 is the **consolidating canon pointer**, subordinate to root COMPLIANCE-ARCH.md / SANCTIONS-POLICY.md — it does **not** restate their content, only the level mapping. Research artifact **referenced, not duplicated**.
3. **No hidden dependencies.** No code keys off this matrix as a file; it is governance canon.
4. **Decision per match:** `.claude/rules/agents.md` → KEEP (source of thresholds); root compliance canon → KEEP (pointer only). **No delete, no merge, no parallel duplicate.**
5. **No doubt / fail-closed:** no ambiguity; nothing to escalate; no runtime code added.

## Consequences
- Any future banking-agent adoption inherits a pre-classified HITL gate; AI is read-only-by-default with explicit MLRO/CRO/CTO human gates for L2/L3.
- Reinforces ADR-126: Hermes (and Tier-1 generally) is structurally barred from compliance decision authority.
- **No runtime change.** No agent provisioned; activation remains a future, separately-gated work item.

## Anchors
- ADR-126 (Hermes Tier-1 exclusion), ADR-019 (AI guardian two-family), ADR-016 (AI plane PII/AML routing).
- `.claude/rules/agents.md` (BUG-007 HITL, BUG-005 pipeline), COMPLIANCE-ARCH.md, SANCTIONS-POLICY.md.
- ADR-102 (Duplication Audit), ADR-119 (IL numbering), EU AI Act Art. 14.
- Research artifact Hermes-Agent-Razbor-i-primenenie-v-EMI-BANXE-AI-Bank-i-Software-Factory.md (attached; referenced, not duplicated).
