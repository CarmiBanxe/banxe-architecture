# Runtime Contract — evo1 / evo2 / Legion Three-Node Execution Fabric

> **Status: PROPOSED / DRAFT — NOT BINDING.** Companion to **ADR-FABRIC-01**. Becomes binding only
> on CEO/WG ratification. All deployment is **GATED on Terminal-A infra**. This document is the
> machine-and-human contract that the three nodes MUST honour once the fabric is enabled.

## 0. Planes & ownership

| Plane | Node | Owns | Does NOT do |
|---|---|---|---|
| Control / Orchestration | **evo1** | task lifecycle authority, **policy gate**, Keycloak :8180, guardian-factory/project :8195/8196, sync-layer coordinator | heavy reasoning; direct tool execution |
| Heavy Inference / Planning | **evo2** | reasoning brain (qwen3-235b :8082), planning, judge/synth (ADR-FUSION-01) | **direct production actions** (must route through gates) |
| Execution / Ops / Tooling | **Legion** | LiteLLM v2 router :4000, **execution gate**, tooling, Aider, factory-fast | policy decisions; unilateral risky actions |

## 1. Task lifecycle (I-FAB-1)

```
CREATED ─▶ PLANNED ─▶ POLICY_GATED ─▶ EXECUTING ─▶ DONE
                │            │             │      └▶ FAILED
                │            │             └────────▶ BLOCKED
   (evo1 mints) (evo2 plans) (evo1 gate)  (Legion exec gate)
```

- **One `correlation_id` per task**, minted by evo1, propagated to evo2 and Legion and onto every
  log/audit/lineage record. **Reuses ADR-046 `correlation_id`** (same family as `guardian_audit_events`
  + ClickHouse trail). No second trace id is permitted.
- Every state transition is an event on the shared queue (§2), tagged with `correlation_id`,
  `node`, `task_id`, `ts`.

## 2. Shared queue + heartbeat (I-FAB-2)

- **Task/event queue:** single logical queue shared by all three nodes. A node MUST NOT act on
  fabric work that is not represented on the queue (no side-channel tasks).
- **Heartbeat/health protocol:** each node emits a periodic heartbeat with
  `{node, healthy, model_ready, queue_depth, load, ts, correlation_window}`. Missing heartbeat
  beyond the configured threshold = node-down → triggers §5 failover.
- Thresholds/intervals are **config-as-data** (repo config, not hardcoded — CLAUDE.md §10).

## 3. Double gate for evo2-originated prod actions (I-FAB-3)

```
evo2 (plan / reasoning output that would mutate funds or prod state)
   └─▶ evo1 POLICY GATE  : authz + invariants (I-01..I-07), Ruflo regulated-route
   │                       checkpoint (ADR-RUFLO-01), HITL bands (BUG-007:
   │                       >90 AUTO / 70-90 REVIEW / <70 BLOCK)
   └─▶ Legion EXECUTION GATE : the actual tool/exec call on :4000 (I-37)
        └─▶ response (+ audit metadata, same correlation_id)
```

- evo2 **never** calls a critical production action directly. Bypassing either gate = canon
  violation (CLAUDE.md §1.11 production-state mutation gate).
- For `payment` / `compliance` / `kyc` task types, Ruflo is **mandatory** in the policy gate
  (`.claude/rules/agents.md`).

## 4. Controlled context sync (I-FAB-4)

- Cross-node memory/context flows **only** through the sync layer as explicit, versioned,
  `correlation_id`-tagged sync events.
- **No implicit state drift:** a node may not read or assume another node's mutable in-memory state.
  Shared context = an emitted sync event with a version, consumed deterministically.
- Conflicting sync versions fail-closed and escalate to evo1 (human-in-the-loop if unresolved).

## 5. Failover (I-FAB-5 — fail-closed)

| Condition | evo1 | evo2 | Legion |
|---|---|---|---|
| evo2 **healthy** | full orchestration | heavy reasoning/planning | full execution |
| evo2 **down** (heartbeat lost) | **degrade to lightweight reasoning** (factory-mid/fast, reduced confidence; tasks needing heavy reasoning → BLOCKED, not silently downgraded) | — | **BLOCK risky actions** (funds/prod-state mutations); read-only/low-risk ops may continue |
| evo1 **down** | — | reasoning continues but **no policy gate ⇒ Legion blocks all prod actions** | execution gate fail-closed |
| Legion **down** | orchestration continues; no execution | planning continues | — |

- Degraded mode is logged with `correlation_id`; recovery to full mode is an explicit, logged
  transition (never a silent upgrade).

## 6. Fabric-by-default (I-FAB-6)

- All agent / refactor / migration tasks are **three-node by default**. Single-node execution is an
  explicit, logged exception with a recorded reason.
- ADR-102 Duplication Audit and ADR-103 server-only refactoring run **inside** the fabric
  (evo2 plans the audit, evo1 gates, Legion executes server-side).

## 7. GATED enablement (NOT active)

`AGENT_ROUTING_ENABLED=false`; queue/heartbeat/sync-layer/evo2-model deployment all **GATED on
Terminal-A infra**. This contract is dormant until ADR-FABRIC-01 is ratified and the infra is stood
up and verified.

## Anchors

ADR-FABRIC-01; ADR-046 (correlation_id); ADR-043/I-37 (:4000 route); ADR-RUFLO-01 (policy gate);
BUG-007 (HITL); `docs/runbooks/factory-routing-map.md`; bootstrap canon §0.1/§0.5/§1.bis;
CLAUDE.md §1.11 (prod-state mutation gate), §10 (config-as-data).
