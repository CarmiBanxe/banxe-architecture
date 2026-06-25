---
id: ADR-129
title: Factory project isolation for any Tier-1 agent (AGENTS.md per repo, scoped tokens, read-only DB users) — Tier 7-8 hardening
status: PROPOSED
date: 2026-06-25
accepted: 
supersedes: []
relates:
  - "ADR-126 (Hermes Tier-1 — this ADR records the isolation/least-privilege hardening any Tier-1 agent must satisfy before adoption)"
  - "ADR-117 §Hermes (factory-node perimeter)"
  - "ADR-103 (server-only; operator hosts/configures; secrets operator-side)"
  - "ADR-001 / PRIVILEGE-MODEL.md (privilege model)"
  - "ADR-032 (secret-rotation policy)"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
il_anchor: IL-549
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
scope: BANXE-factory-only
concept_only: true
research_ref: "Hermes-Agent-Razbor-i-primenenie-v-EMI-BANXE-AI-Bank-i-Software-Factory.md (attached research artifact — referenced, NOT duplicated)"
---

# ADR-129 — Factory project isolation for any Tier-1 agent (Tier 7-8 hardening)

## Context

The attached research artifact (referenced, **not duplicated**) describes project-isolation practices for a high-privilege autonomous agent (per-repo AGENTS.md, current-working-directory isolation, scoped fine-grained credentials, read-only database users, scoped channels, approval-gated risky actions). This ADR records those as the **mandatory isolation baseline** any Tier-1 agent (e.g. the future Hermes of ADR-126) must satisfy **before** adoption, aligned with the existing privilege model and secret-rotation canon. It introduces **no runtime code** and provisions **no agent or credential**.

## Decision

**No Tier-1 agent may be adopted without least-privilege project isolation: per-repo scoping, CWD isolation, scoped read-only credentials, operator-held secrets, and approval gates on any risky action. Isolation is a precondition, not a post-hoc control.**

### Required isolation baseline (Tier 7-8)
1. **Per-repo AGENTS.md scope** — an agent operates only within repos that carry an explicit AGENTS.md grant; no implicit cross-repo reach.
2. **CWD isolation** — agent activity confined to a project current-working-directory; no traversal outside its grant.
3. **Scoped credentials** — GitHub fine-grained tokens limited to declared repos and **read** scopes; database access via **read-only** users only. No broad PATs, no write/admin scopes.
4. **Operator-held secrets (ADR-103).** Secrets are provisioned and rotated operator-side (ADR-032); the agent never stores or self-provisions credentials.
5. **Scoped channels** — messaging/alerting limited to declared operator channels and allowed-user lists.
6. **Approval-gated risky actions** — any action beyond read/observe requires explicit operator HITL; production-critical banking stack is out of reach by default.

## HITL / read-only / security boundaries
- **Least-privilege by default; deny-by-default for un-granted scopes.** An agent without an explicit grant has no access.
- **No write/admin credentials for Tier-1.** Consistent with ADR-126 (no merge/deploy/payment-core write) and ADR-128 (no L2/L3 authority).
- **Fail-closed.** Missing or ambiguous scope → access denied, escalate to operator.
- **Perimeter (ADR-117).** Factory infra plane only; PROJECT RED zone and banking/domain models are never in an agent's grant.

## Duplication Audit (ADR-102)
1. **Repo-wide search** for an existing agent-isolation baseline doc — privilege rules exist in PRIVILEGE-MODEL.md / ADR-001 and secret rules in ADR-032, but no single ADR consolidates the Tier-1 **isolation precondition** (AGENTS.md + CWD + scoped tokens + read-only DB). No agent passport encodes it.
2. **Source-of-truth.** Privilege model = PRIVILEGE-MODEL.md / ADR-001; secret rotation = ADR-032; server-only = ADR-103. This ADR-129 is the **consolidating precondition pointer** for Tier-1 adoption, restating none of their content — only the isolation requirement set. Research artifact **referenced, not duplicated**.
3. **No hidden dependencies.** No code keys off this baseline as a file; it is governance canon.
4. **Decision per match:** PRIVILEGE-MODEL.md / ADR-001 → KEEP (pointer); ADR-032 → KEEP (pointer); ADR-103 → KEEP (pointer). **No delete, no merge, no parallel duplicate.**
5. **No doubt / fail-closed:** no ambiguity; nothing to escalate; no runtime code added.

## Consequences
- Any future Tier-1 agent adoption (Hermes included) is gated behind a least-privilege isolation precondition; no agent can be wired in with broad or write credentials.
- Reinforces ADR-126 / ADR-128: the isolation baseline structurally prevents scope creep into merge/deploy/compliance authority.
- **No runtime change.** No agent, token, or DB user provisioned; activation remains a future, separately-gated work item (operator HITL, server-only host).

## Anchors
- ADR-126 (Tier-1 role), ADR-128 (HITL matrix), ADR-117 §Hermes (perimeter), ADR-103 (server-only).
- PRIVILEGE-MODEL.md / ADR-001 (privilege model), ADR-032 (secret rotation).
- ADR-102 (Duplication Audit), ADR-119 (IL numbering).
- Research artifact Hermes-Agent-Razbor-i-primenenie-v-EMI-BANXE-AI-Bank-i-Software-Factory.md (attached; referenced, not duplicated).
