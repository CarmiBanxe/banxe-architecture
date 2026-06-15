---
id: ADR-081
title: CTO DeployPort + DeployAgent (prepare-vs-execute, prod-requires-CTO-approval) for EMI BANXE AI BANK
status: ACCEPTED
date: 2026-06-11
accepted: 2026-06-11
supersedes: []
related:
  - "ADR-049-intent-layer-client-facing-agent-masks.md (the §D2 gate-chain + step-up the agent enforces)"
  - "ADR-046-decision-lineage-schema.md (one AgentDecisionRecord per masked action)"
  - "ADR-047-ai-cost-governance-policy.md (cost_cap + AUTO/REVIEW/BLOCK bands)"
  - "ADR-078-cfo-treasury-forecast-ports.md (the £100k→CFO step-up pattern reused here as prod→CTO step-up)"
  - "ADR-080-cto-data-quality-port.md (sibling CTO port-first, sprint-48)"
  - "ADR-056-ledger-coupling-gate.md (this ADR ships with an IL block)"
binding_artifact: null
il_anchor: IL-175-CTO-DEPLOY-PORT-2026-06-11
scope: BANXE-only
concept_only: false
---

# ADR-081: CTO DeployPort + DeployAgent (prepare-vs-execute; prod requires CTO approval)

**Status:** ACCEPTED — 2026-06-11
**Sprint:** 49 / IL-175 (companion: instruction-ledger/sprint-49/IL-DEPLOY-01-deploy.md)

## Context

ORG-STRUCTURE §2.7.2 (CTO / AI Platform, SMF26 — Infrastructure / DevOps) defines `DeployAgent`
at two autonomy levels: **Staging deploys — L2 Review, gate = CTO**; **Production deploys — L3,
gate = CTO must approve** (mandatory human gate). This is the most safety-critical agent in the
fleet so far: it is the first whose masked action has a **state-changing side effect** (a
deployment), not just a read. The ADR-049 §D2 mask needs an injectable port that makes
**execution gated on an explicit human-approval token** structurally impossible to bypass —
none exists, so this ADR adds one, port-first.

This sprint builds **only** DeployAgent. `MonitoringAgent` (§2.7.2, L1) and `MLPipelineAgent`
(§2.7.1, L3/I-27) are explicitly deferred.

## Decision

### D1 — DeployPort: prepare-vs-execute separation (read-only CONTRACT for prepare; token-gated execute)

A new port `services/deploy/deploy_port.py` (abc.ABC + InMemory impl + `DeployPortError`):
- `prepare_deployment(target_env) -> DeploymentPlan` — read/validate/propose only, no side effect.
- `request_approval(plan) -> ApprovalRequest` — raises the action to the human (CTO) gate.
- `execute_deployment(plan, approval_token) -> DeployResult` — the only state-changing method;
  it **MUST raise `DeployPortError` when `approval_token` is absent or invalid**. There is **no
  parameterless / autonomous execute path** on the port: every execute requires a token argument
  the port validates. No real CI/CD integration ships (I-10) — InMemory test impl only.

### D2 — DeployAgent: the §D2 step-up IS the CTO approval token

`services/agents/deploy_agent.py` enforces the full ADR-049 §D2 gate-chain, where the **step-up
position is the CTO deployment-approval token** (the exact analogue of ADR-078's £100k→CFO
step-up). Actions:
- **prepare** — read/validate, AUTO-eligible (no token, no side effect).
- **deploy_staging (L2)** — `force_review=True`; requires a CTO review token (carried as
  `human_reviewed_by`). No token → HOLD_FOR_REVIEW (proceed=False, `execute_deployment` **not
  called**, escalate→CTO); with token → execute.
- **deploy_production (L3)** — `force_review=True` **always** (step-up regardless of confidence),
  `requires_step_up=True`. No/empty token → HALT (HOLD_FOR_REVIEW / step-up to CTO),
  `execute_deployment` **never called**; with a token → execute (the port re-validates and raises
  on an invalid token — defense in depth; recorded then re-raised).

Each action emits one ADR-046 `AgentDecisionRecord`; port + recorder injected.

### D3 — Safety invariant (enforced in code + test)

**The agent MUST NEVER autonomously execute a production deployment.** Prod execute is reachable
only when a non-empty approval token is supplied AND the gate-chain proceeds; `force_review`
always pulls prod to REVIEW, and REVIEW with no token halts before the port call. No scope op
bypasses approval. **R-SEC:** the approval token is credential-like and MUST NOT appear in any
`AgentDecisionRecord` field — lineage carries only opaque handles (plan_id, target_env) and a
non-secret reviewer identity, never the raw token.

## Boundaries (explicit)

prepare/request = read/validate/propose. execute = token-gated, human-approved only. The agent
never deploys to production on its own initiative, never embeds a bypass, never logs the approval
token. Consequential execution authority stays with the human CTO (EU AI Act Art.14 oversight).

## Consequences

**Positive:** the first state-changing agent lands with a structurally un-bypassable human-approval
gate; prepare/execute separation keeps validation cheap and execution guarded; consistent with the
ADR-078 step-up pattern. **Negative / costs:** one more contract; the real CI/CD adapter remains
unbuilt (InMemory only); the DEPLOY_SAFETY overlay + CTO role + token scheme are config-as-data and
must stay aligned with §2.7.2.

## Alternatives considered

- **Single `execute()` with an internal autonomy flag** — rejected: an in-agent boolean is a
  bypass waiting to happen; the token must be a required port argument the port itself validates.
- **Let the agent auto-approve staging** — rejected: §2.7.2 makes staging L2 (CTO gate) and prod L3
  (CTO must approve); both require a human token.
- **Defer until a real CI/CD adapter exists** — rejected: port-first lands the governed,
  approval-gated agent now (I-10-safe), with the live adapter as a later swap behind the same
  token-gated contract.
