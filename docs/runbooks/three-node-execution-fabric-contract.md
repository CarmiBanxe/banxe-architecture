# Three-node execution fabric — runtime contract (ADR-104)

<!-- Source: docs/runbooks/three-node-execution-fabric-contract.md | Date: 2026-06-17 | Version: 1.0 | Implements: ADR-104 | IL: IL-255 -->

## Status

CONTRACT (design). Specifies the runtime contract between **evo1** (control), **evo2**
(reasoning), and **Legion** (execution) per ADR-104. It stands up no infrastructure —
the queue, heartbeat, sync, and gate services are a follow-up operator-gated infra sprint.

## Nodes & planes

| Node | Plane | Owns |
|---|---|---|
| evo1 | control / orchestration | task lifecycle, policy gate, queue+heartbeat coordinator, server-only refactor workspace (ADR-103) |
| evo2 | heavy inference / planning | the reasoning brain — plans/decisions; **acts on nothing directly** |
| Legion | execution / ops / tooling | shell, git, and tooling, the execution gate (only node that runs actions) |

## 1. Task lifecycle + correlation-id (invariant 1)

States: `created → planned → policy-gated → executing → done | failed | blocked`.
One **`correlation_id`** per task — format `fab-<utc-iso>-<6hex>` — minted by evo1 at
`created`, propagated in every queue message, log line, heartbeat, gate call, and
artifact on all three nodes. No node may start work without a correlation_id.

## 2. Queue / event bus + heartbeat/health (invariant 2)

- **Bus:** a shared queue/event bus (e.g. RabbitMQ/NATS — chosen at build time) with
  topics `task.*`, `plan.*`, `gate.*`, `exec.*`, `event.*`. Every message carries
  `{correlation_id, node, ts, type, payload}`.
- **Heartbeat:** each node publishes `heartbeat.<node>` every N seconds with
  `{node, ts, status, load}`; evo1 tracks liveness and marks a node down after K missed
  beats.
- **Health:** each node exposes a health endpoint (`up | degraded | down`).

## 3. Gates — the only path to a prod action (invariant 3)

```
evo2 (reason → PLAN)  →  evo1 POLICY GATE  →  Legion EXECUTION GATE  →  action
```

- **evo2** emits a `plan` (steps + intended actions). It NEVER calls a prod action.
- **evo1 policy gate** (`gate.policy`): evaluates allowed? compliant (invariants/ADRs)?
  HITL required? → `allow | deny | needs-human`. Deny/needs-human stops the chain.
- **Legion execution gate** (`gate.exec`): the **only** node that runs the action; it
  refuses any action lacking a valid evo1 `allow` for the same correlation_id.
- Critical prod actions (payments, schema, secrets, deploys, merges) require both gates;
  fail-closed on either.

## 4. Controlled sync layer — no implicit drift (invariant 4)

- Shared context flows **only** through the sync layer: explicit `context.publish` /
  `context.subscribe` with a **version** per context key. A node never silently
  reads/writes another node's filesystem/memory.
- Conflicts resolve by version (last-writer must read-then-write the current version);
  divergence is surfaced, not auto-merged. The refactor/legacy state of record lives on
  evo1 (ADR-103), published to the others via the sync layer.

## 5. Failover (invariant 5)

| Condition | evo1 (control) | Legion (execution) | evo2 |
|---|---|---|---|
| evo2 down (K missed beats) | **degrade to lightweight reasoning** (smaller/local model, bounded scope) | **block risky actions** — only low-risk/idempotent ops proceed | — |
| evo1 down | — | freeze (no gate) → block all gated actions | hold plans |
| Legion down | hold execution; queue actions | — | continue planning |

No split-brain: a gated action requires a live evo1 `allow` + a live Legion executor;
absent either, it does not run.

## 6. Three-node by default (invariant 6)

Every factory agent, refactor, and migration task is authored for this fabric: reasoning on
evo2, policy on evo1, execution on Legion, one correlation_id throughout — never a
single-box assumption. Single-node fallbacks are the degraded mode (§5), not the design.

## Out of scope (operator-gated build)

The `evo2` model install, the queue, heartbeat, sync, and gate services, and their wiring are a
follow-up infra sprint. This contract defines the interfaces; it activates nothing.

**Refs:** ADR-104, ADR-040 (planes), ADR-103 (server-only), ADR-060 (orchestration); IL-255.
