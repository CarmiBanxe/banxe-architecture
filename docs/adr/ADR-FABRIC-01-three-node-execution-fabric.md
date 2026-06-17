---
id: ADR-FABRIC-01
title: Three-Node Execution Fabric (evo1 control / evo2 heavy-inference / Legion execution) — hard architectural requirement
status: PROPOSED
date: 2026-06-17
accepted: null
supersedes: []
extends:
  - "INVARIANTS.md I-37 (Factory↔Project Layer Binding — two-layer infra, PROPOSED)"
  - "docs/runbooks/factory-routing-map.md (node→model→route mapping)"
related:
  - "ADR-040-ai-execution-policy.md (meta-plane vs inference-plane separation)"
  - "ADR-043-aider-routes.md (LiteLLM routes — the seam, no new route added)"
  - "ADR-046-decision-lineage-schema.md (correlation_id — reused as the fabric trace id)"
  - "ADR-047-ai-cost-governance-policy.md (per-request cost caps across nodes)"
  - "ADR-051-coding-execution-decision.md (which executor runs)"
  - "ADR-RUFLO-01-dual-role.md (Ruflo regulated-route checkpoint = policy-gate component, PROPOSED #486)"
  - "ADR-102-no-smart-refactor-without-duplication-verification.md (refactor discipline — fabric-default)"
  - ".claude/rules/agents.md AGENT_ROUTING_ENABLED gate; HITL bands BUG-007"
  - "bootstrap canon v3 §0.1 / §0.5 / §1.bis (distribution discipline)"
il_anchor: IL-255
numeric_alias: ADR-106 (reservable; ADR-104=ADR-RUFLO-01, ADR-105=ADR-FUSION-01 reserved)
scope: BANXE-only
concept_only: true
---

# ADR-FABRIC-01: Three-Node Execution Fabric (hard architectural requirement)

**Status:** PROPOSED / DRAFT — **NOT YET BINDING.** This ADR specifies a *hard architectural
requirement* but, like I-37, requires **explicit CEO/WG ratification** (CLAUDE.md §1.9/§1.11,
governance gate) before it flips to ACCEPTED/binding. All deployment/enablement steps are **GATED**
on Terminal-A infrastructure (CLAUDE.md NO-WAIT rule — infra build is Terminal A's domain).

## Context

evo2 must host a powerful reasoning model as the factory's **compute brain / reasoning node** —
but **not in isolation**. The requirement is that evo2 operate inside **one end-to-end process**
together with evo1 and Legion, as a single **three-node execution fabric**, not three loosely
coupled boxes.

Grounded in current infra canon (`docs/runbooks/factory-routing-map.md`,
INVARIANTS I-37 two-layer binding):

| Node | Plane (this ADR) | Current canonical surface |
|---|---|---|
| **evo1** | **Control / Orchestration plane** | Keycloak realm `banxe-emi` :8180; guardian-factory/guardian-project services :8195/8196; LiteLLM upstream; `factory-coder` (qwen3-coder-next) :11434. **Policy gate** owner. |
| **evo2** | **Heavy Inference / Planning plane** | `project-reason` / `reasoning-235b` = qwen3-235b-Q3_K_S on **:8082** — the **compute brain**; heavy reasoning, architecture/cross-repo planning. |
| **Legion** | **Execution / Ops / Tooling plane** | LiteLLM v2 router **:4000** (I-37 production entrypoint); `factory-fast` (qwen2.5-coder:14b) :11434; Aider; RTX 4070; tooling/exec. **Execution gate** owner. |

This ADR makes the *unified-process* property a requirement rather than an emergent accident.

## Decision — six mandatory invariants (I-FAB-1 … I-FAB-6, PROPOSED)

> Numbered in the `I-FAB-*` namespace to avoid collision with numeric invariants (main max = I-74).
> Flip to binding only on CEO/WG ratification.

**I-FAB-1 — Unified task lifecycle + correlation-id.** Every task carries ONE lifecycle
(`CREATED → PLANNED → POLICY_GATED → EXECUTING → DONE|FAILED|BLOCKED`) and ONE **`correlation_id`**
that is propagated across evo1 → evo2 → Legion and back. The id **reuses ADR-046's `correlation_id`**
(same family as `guardian_audit_events` + ClickHouse audit trail) — **no new trace schema**.

**I-FAB-2 — Shared task/event queue + heartbeat/health protocol.** The three nodes share ONE task
& event queue and a periodic **heartbeat/health** exchange (liveness, load, model-ready, queue depth).
No node accepts fabric work it cannot trace on the shared queue.

**I-FAB-3 — Explicit role separation + double gate.** evo2 **MUST NOT** perform critical production
actions directly. Any evo2-originated action that mutates client funds or production state passes:
**evo1 policy gate** (authorisation/invariant check — incl. Ruflo regulated-route checkpoint per
ADR-RUFLO-01, HITL bands BUG-007) **THEN** **Legion execution gate** (the actual tool/exec on :4000).
evo2 plans/reasons; it does not execute prod actions unilaterally.

**I-FAB-4 — Controlled shared memory/context.** Cross-node memory/context flows **only** through a
controlled **sync layer** with explicit versioned hand-offs. **No implicit state drift** — a node
may not silently read or assume another node's mutable state; all shared context is an explicit,
correlation-id-tagged sync event.

**I-FAB-5 — Failover (fail-closed).** If **evo2 is unavailable**: evo1 **degrades to lightweight
reasoning** (factory-mid/fast tier, reduced-confidence) and **Legion BLOCKS risky actions**
(funds/prod-state mutations) until evo2 (or an approved equivalent) is healthy. Degraded mode is
logged with `correlation_id`; it never silently upgrades back.

**I-FAB-6 — Fabric-by-default.** **All** agent / refactor / migration tasks in the factory are
computed as a **three-node process by default** (not single-node). Single-node execution is an
explicit, logged exception, never the default. The ADR-102 Duplication Audit and ADR-103 server-only
discipline run **within** the fabric, not beside it.

## Consequences

- The factory's heavy reasoning is centralised on evo2 but always policy-gated (evo1) and
  execution-gated (Legion) — no isolated "smart node" can touch production.
- Reuses existing seams: ADR-046 correlation_id, ADR-043 LiteLLM :4000 route, ADR-047 cost caps,
  ADR-RUFLO-01 Ruflo gate, I-37 two-layer binding. **No new agent, no new route, no new trace schema.**
- Failover is fail-closed: loss of the reasoning brain degrades capability, never safety.
- Once ratified, AGENTS.md / `.claude/rules/agents.md` carry the fabric requirement as binding
  (this PR stages those edits as PROPOSED, see the AGENTS.md update + runtime contract).

## Explicitly GATED / out of scope (NOT done by this ADR)

- **Deploying / wiring** the queue, heartbeat daemon, sync layer, or the evo2 reasoning model. **[GATED — Terminal-A infra]**
- **Enabling `AGENT_ROUTING_ENABLED`** — stays `false`; ARL conditions unmet. **[GATED]**
- **Creating `services/arl` or any LiteLLM route.** **[GATED — Terminal-A infra]**
- **Flipping I-FAB-1..6 / I-37 to binding** — requires CEO/WG ratification. **[GATED]**

## Duplication Audit (ADR-102)

| Target | Source of truth | Decision |
|---|---|---|
| Correlation/trace id | ADR-046 `correlation_id` | **keep/reuse** (no new schema) |
| Prod entrypoint route | ADR-043 LiteLLM :4000 (I-37) | **keep** (no new route) |
| Node→model mapping | `docs/runbooks/factory-routing-map.md` | **keep/extend** (planes layered on existing rows) |
| Policy gate | ADR-RUFLO-01 + HITL BUG-007 + guardian services | **keep** (fabric reuses as evo1 gate) |
| Cost governance | ADR-047 | **keep** (per-request cap spans nodes) |
| Two-layer binding | I-37 / §1.bis | **extend** (fabric refines, does not replace) |

No merge/delete; all matches resolve to **keep/extend**. No hidden consumer touched.

## References

- INVARIANTS I-37; bootstrap canon v3 §0.1/§0.5/§1.bis; `docs/runbooks/factory-routing-map.md`
- ADR-040 / ADR-043 / ADR-046 / ADR-047 / ADR-051 / ADR-RUFLO-01 / ADR-102 / ADR-103
- `.claude/rules/agents.md` (ARL pipeline, AGENT_ROUTING_ENABLED gate, HITL bands BUG-007)
- `docs/contracts/runtime-contract-evo1-evo2-legion.md` (this PR — the runtime contract)
