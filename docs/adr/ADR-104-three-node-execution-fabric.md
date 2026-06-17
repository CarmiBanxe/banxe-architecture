---
id: ADR-104
title: Three-node execution fabric (evo1 control / evo2 reasoning / Legion execution)
status: ACCEPTED
date: 2026-06-17
accepted: 2026-06-17
supersedes: []
related:
  - "ADR-040-ai-execution-policy.md (meta- vs inference-plane + trust/deny-paths — source-of-truth; this ADR re-maps the node roles and adds the single-process fabric)"
  - "ADR-060-multi-actor-orchestration.md (terminal, branch, and merge orchestration — different axis)"
  - "ADR-103-server-only-refactoring-policy.md (server-only refactoring; fabric runs server-side)"
  - "ADR-102-no-smart-refactor-without-duplication-verification.md (Duplication Audit)"
il_anchor: IL-255
scope: BANXE-only
concept_only: false
---

# ADR-104: Three-node execution fabric

**Status:** ACCEPTED — 2026-06-17
**IL:** IL-255
**Applies to:** the factory (Claude Code / MetaClaw / every agent) and all
agent, refactor, and migration work. A hard architectural requirement.

## Context

`evo2` is to host a powerful AI model as the **compute brain / reasoning node** — but
**not in isolation**. ADR-040 established a two-plane model (meta-plane = Claude Code on
`legion`; inference-plane = `evo1`+`evo2` via LiteLLM) with its trust profiles, cloud
deny-paths, and "secrets never in prompts" rules — those remain in force. What was
missing is a single, end-to-end **execution fabric** spanning the three machines, with
one task lifecycle, explicit gates, and defined failover. Letting `evo2` reason in
isolation (or letting any node drift its own state) is the failure mode this ADR closes.

## Decision

Operate `evo1`, `evo2`, and `Legion` as **one three-node execution fabric** — a single
end-to-end process, not three independent boxes. Node roles (this re-maps ADR-040's
plane→node assignment):

| Node | Plane / role |
|---|---|
| **evo1** | **Control / orchestration plane** — task lifecycle owner, policy gate, queue/heartbeat coordinator, the server-only refactor workspace host (ADR-103). |
| **evo2** | **Heavy inference / planning plane** — the reasoning brain (large model): planning, analysis, multi-step reasoning. Produces plans/decisions; does **not** act directly. |
| **Legion** | **Execution / ops / tooling plane** — runs tools, shell, git, deploys; the execution gate; holds the dev tooling. |

ADR-040's trust boundaries (cloud deny-paths, secrets-never-in-prompts, inference-plane
never writes to disk directly) are preserved and inherited.

### Mandatory invariants (hard requirements)

1. **Unified task lifecycle + correlation-id.** Every task has one lifecycle
   (`created → planned → policy-gated → executing → done|failed|blocked`) and a single
   **`correlation_id`** propagated through all three nodes; every log, event, and artifact on
   any node carries it.
2. **Shared task/event queue + heartbeat/health.** A common queue/event bus carries
   tasks and events across the three nodes; each node emits a periodic **heartbeat** and
   exposes **health**; the control plane (evo1) tracks liveness.
3. **Explicit role separation (gates).** `evo2` **never** performs a critical production
   action directly. Any such action passes the **evo1 policy gate** (allowed? compliant?
   HITL?) **and** the **Legion execution gate** (the only node that runs the action).
   Reasoning (evo2) → policy (evo1) → execution (Legion) is the only path to a prod
   action.
4. **Controlled shared memory/context.** Shared context flows **only** through a
   controlled **sync layer** (explicit publish/subscribe with versioning) — **no implicit
   state drift**; a node never silently reads/writes another node's state.
5. **Failover.** If `evo2` is unavailable, `evo1` **degrades to lightweight reasoning**
   (smaller/local model, bounded scope) and **Legion blocks risky actions** (only
   low-risk/idempotent ops proceed); the fabric stays consistent, never split-brain.
6. **Three-node by default.** **All** factory agent / refactor / migration tasks are
   designed for this three-node process **by default** — not as a single-box assumption.

### Runtime contract

The concrete evo1↔evo2↔Legion runtime contract (correlation-id format, queue/topic
schema, heartbeat/health endpoints, the policy- and execution-gate request/response, the
sync-layer protocol, and the failover state machine) is specified in
`docs/runbooks/three-node-execution-fabric-contract.md`. The hard requirement is also
mirrored into `AGENTS.md`.

## Consequences

- **Positive:** `evo2`'s reasoning power is usable without isolation; one auditable task
  lifecycle; no node acts on prod without policy+execution gates; graceful degradation.
- **Cost:** a queue, heartbeat, and sync layer and the gate plumbing must be built (a follow-up
  infra sprint) — operator-gated; this ADR sets the contract, not the implementation.
- **Enforcement:** any factory task that assumes a single box, or lets `evo2` act
  directly on prod, or drifts shared state outside the sync layer, is a violation.

## Duplication Audit (ADR-102)

Coverage: searched `docs/adr/`, `.claude/rules/`, `AGENTS.md` for an existing three-node
/ execution-fabric / evo1-evo2-Legion-process policy. **No duplicate.** ADR-040 is the
**source-of-truth** for plane separation + trust/deny-paths (consumers: the inference
routing + the factory); ADR-104 **extends** it (re-maps node roles + adds the single
fabric, gates, sync layer, failover) — keep + extend, no supersede of ADR-040's trust
rules. ADR-060 (terminal/branch orchestration) and ADR-041/043/044/047 (AI pool/routing/
cost) govern different axes. Decision: **keep** (new requirement); risk none.

## OPERATOR DECISION REQUIRED

Standing up the actual fabric (the `evo2` model install, the queue, heartbeat, and sync layer,
the gate services) is a follow-up infra sprint — operator-gated. This ADR + the runtime
contract define the required design; they activate no infrastructure.

## References

- ADR-040 (execution planes), ADR-060 (orchestration), ADR-103 (server-only); IL-255;
  `docs/runbooks/three-node-execution-fabric-contract.md`; `AGENTS.md`.
