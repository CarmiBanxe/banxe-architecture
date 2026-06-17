# Three-node fabric — bootstrap & current-state GAP (ADR-104 implementation plan)

<!-- Source: docs/runbooks/three-node-fabric-bootstrap.md | Date: 2026-06-17 | Version: 1.0 | Implements: ADR-104 | IL: pending-shard -->

## Status

PLAN (docs-only). Concrete implementation plan for the ADR-104 three-node execution
fabric and an honest current-state GAP. **It stands up no infrastructure and changes no
prod** — every stand-up step is an operator/infra-gated action (§4). The runtime
*interface* contract is `docs/runbooks/three-node-execution-fabric-contract.md`; this
runbook is the *deployment* plan that realizes it.

## 0. Scope & relationship to existing docs

| Doc | Role | This runbook |
|---|---|---|
| `ADR-104` | the decision (roles + 6 invariants) | implements |
| `three-node-execution-fabric-contract.md` | runtime **interface** contract (lifecycle, correlation_id, topics, gates, failover) | realizes — concrete deployment |
| `fa-02-litellm-canonical-aliases.md`, `factory-routing-map.md` | LiteLLM alias/route map | reuses (reasoning route) |
| `fa-evo2-gpu-stack.md` | evo2 ROCm/Vulkan GPU restore | pre-req for evo2 reasoning node |
| `redis-evo1-setup.md` | Redis 7 on evo1 | candidate queue/heartbeat backing store |
| `ADR-103` | server-only refactor host | evo1 stays the refactor host inside the fabric |

## 1. Target deployment (what runs where)

### evo1 — control / orchestration plane
- **Task-lifecycle service** — owns `created → planned → policy-gated → executing → done|failed|blocked`; mints one **`correlation_id`** (`fab-<utc-iso>-<6hex>`) per task at `created`.
- **Queue / event bus** — topics `task.*`, `plan.*`, `gate.*`, `exec.*`, `event.*`; every message `{correlation_id, node, ts, type, payload}`. Backing store: Redis 7 already on evo1 (`redis-evo1-setup.md`) for streams/heartbeat, or a dedicated broker (NATS/RabbitMQ) — chosen at build.
- **Heartbeat/health coordinator** — consumes `heartbeat.<node>`; marks a node down after K missed beats; exposes fabric health (`up|degraded|down`).
- **Policy gate** (`gate.policy`) — `allow | deny | needs-human` against invariants/ADRs + HITL thresholds (agents.md AUTO>90 / REVIEW 70–90 / BLOCK<70).
- **Refactor host (ADR-103)** — unchanged: the M-track workspace (`/srv/banxe-legacy/...`), vault, repo clones stay here.

### evo2 — heavy inference / planning plane
- **LiteLLM** endpoint + **reasoning model** (`project-reason` → qwen3-235b on evo2 :8082 per `factory-routing-map.md`). Pre-req: `fa-evo2-gpu-stack.md` GPU restore (today qwen3:235b is CPU-only ~5 tok/s).
- **health + heartbeat endpoint** — publishes `heartbeat.evo2 {node,ts,status,load}`; exposes `/health` (`up|degraded|down`).
- **Acts on nothing** — emits `plan` messages only (steps + intended actions); never calls a prod action directly.

### Legion — execution / ops / tooling plane
- **Execution gate** (`gate.exec`) — the **only** node that runs a prod action (shell/git/deploy/tooling); refuses any action lacking a live evo1 `allow` for the same `correlation_id`.
- **Heartbeat/health** — `heartbeat.legion`; on evo1-down → freeze (no gate → block all gated actions).

## 2. Cross-cutting contracts (realizing the interface contract)

- **correlation_id propagation** — minted by evo1 at `created`; carried in every queue message, log line, heartbeat, gate call, and artifact on all three nodes. No node starts work without one. Format `fab-<utc-iso>-<6hex>`.
- **heartbeat/health** — each node every N s publishes `heartbeat.<node> {node,ts,status,load}`; evo1 tracks liveness, K missed beats ⇒ down. Each node exposes a health endpoint.
- **no cross-node state drift** — shared context flows **only** through the controlled sync layer (`context.publish`/`context.subscribe`, versioned per key); last-writer read-then-write current version; divergence surfaced, never auto-merged. A node never silently reads/writes another node's FS/memory. The refactor state of record lives on evo1 (ADR-103), published via the sync layer.
- **gate chain** — reasoning(evo2) → `gate.policy`(evo1) → `gate.exec`(Legion) → action. Critical prod actions (payments, schema, secrets, deploys, merges) require **both** gates; fail-closed on either.
- **failover** — evo2 down (K missed beats): evo1 **degrades to lightweight reasoning** (smaller/local model, bounded scope) and **Legion blocks risky actions** (only low-risk/idempotent ops proceed). evo1 down: Legion freezes (no gate), evo2 holds plans. Legion down: evo1 holds execution/queues actions, evo2 keeps planning. No split-brain: a gated action needs a live evo1 `allow` + a live Legion executor.

## 3. Current-state GAP (pre-fabric debt — NOT ADR-104-compliant)

Audit finding: the M-track (M0–M1.2) ran on a single evo1 with direct commands, no fabric process. Concrete divergences:

| # | ADR-104 requirement | Current state | Debt |
|---|---|---|---|
| G1 | Three-node fabric as one process | **single-evo1**; fabric process not running | reasoning+control+execution collapsed onto evo1 |
| G2 | evo2 = live reasoning node | evo2 (`banxe-NucBox-EVO-X2-2`) **alive but idle**; not wired as reasoning node; **LiteLLM not up**; GPU stack unrestored (CPU-only) | no reasoning plane |
| G3 | Legion = sole execution gate | prod actions issued directly (no `gate.exec`); no execution-gate process | execution not gated through Legion |
| G4 | evo1 policy gate before action | no `gate.policy` process; decisions inline in the factory session | policy gate not enforced as a service |
| G5 | correlation_id on every task/log/artifact | not minted/propagated; M-track used ad-hoc task ids | no unified lifecycle id |
| G6 | queue + heartbeat/health | no bus/heartbeat service running (Redis present but not wired for this) | no liveness/failover signal |
| G7 | controlled sync layer (no drift) | single-box FS = implicit shared state | sync layer absent |

**Verdict:** current contour is **pre-fabric** — functional for M-track delivery under ADR-103 (server-only on evo1), but **not** the ADR-104 fabric. The above are tracked as pre-fabric debt; closing them = the operator stand-up (§4). This is acknowledged, not masked.

> The table above is the **original audit snapshot** (kept as the historical record). The
> **current** closure status is below.

### 3a. GAP closure status — UPDATED 2026-06-17 (record: ADR-105)

The fabric was built and verified server-side across **F1.1–F1.5 stage-3.1** (all merged).
Closure status per GAP (full record + evidence: `docs/adr/ADR-105-three-node-fabric-complete.md`):

| # | Status | Closed by |
|---|---|---|
| G1 | **CLOSED** | three live nodes — F1.1/F1.2/F1.3+3.1 (IL-257, IL-259, IL-260, IL-265, IL-266) |
| G2 | **CLOSED** | evo2 Vulkan reasoning + LiteLLM :4000 + health :9208 (IL-257) |
| G3 | **CLOSED for low-risk; risky = HITL-gated** | Legion `gate.exec` dry-run→activation→consumer (IL-260, IL-265, IL-266) |
| G4 | **CLOSED** | evo1 `gate.policy` :9110 deny-by-default (IL-260) |
| G5 | **CLOSED** | `correlation_id` end-to-end (IL-257, IL-259) |
| G6 | **CLOSED** | control-plane + Redis-streams bus + heartbeat (IL-259, IL-264) |
| G7 | **CLOSED** | Redis-streams controlled bus, no cross-node drift (IL-264) |

### 3b. Residual — operator/HITL-gated (NOT auto-closed)

1. **Persistent Legion `gate.exec` consumer** — built + unit-templated + server-side-tested,
   but the **real prod start on Legion is an OPERATOR ACTION** (`systemctl --user enable --now
   gate-exec.service` + Legion-side vault). G3 is closed *in capability*, not *running in prod*.
2. **Risky execution** — payment/withdraw/trade/transfer/custody/key-ops real execution is
   **NOT enabled**; requires a **separate operator authorization + HITL per action**
   (`.claude/rules/agents.md` AUTO>90 / REVIEW 70–90 / BLOCK<70). Stage-3 restricts real
   execution to the low-risk idempotent allow-list by design.

## Completion

The ADR-104 fabric is **IMPLEMENTED AND ACTIVE** for the low-risk path; risky execution and
the persistent Legion consumer start remain operator/HITL-gated (§3b). The authoritative
completion + GAP-closure record is **`docs/adr/ADR-105-three-node-fabric-complete.md`**
(ACCEPTED). This runbook remains the *deployment plan*; ADR-104 the *decision*; the contract
runbook the *interface*.

## 4. OPERATOR ACTIONS (human / infra-gated — the factory cannot self-provision these)

1. **evo2 GPU restore** — execute `fa-evo2-gpu-stack.md` (ROCm+Vulkan; G-INFRA-EVO2-GPU-STACK) so qwen3-235b runs GPU-offloaded, not CPU ~5 tok/s.
2. **LiteLLM up on evo1+evo2** — stand up the LiteLLM endpoint(s); confirm `project-reason`→evo2:8082 per `factory-routing-map.md`.
3. **Reasoning model on evo2** — load qwen3-235b (or the agreed model) behind LiteLLM; expose `/health` + `heartbeat.evo2`.
4. **Queue + heartbeat service** — choose Redis-streams (existing `redis-evo1-setup.md`) or NATS/RabbitMQ; stand up topics `task/plan/gate/exec/event.*` + heartbeat consumer on evo1.
5. **Gate services** — deploy `gate.policy` (evo1) and `gate.exec` (Legion) processes; wire the chain reasoning→policy→execution.
6. **Network / secrets** — Tailscale reachability evo1↔evo2↔Legion; secrets in server vault / GH Actions only (never in prompts, per ADR-040); no secret leaves the vault.
7. **Activation = a separate operator step** — the actual fabric go-live is HITL/operator-gated and **out of scope** of this spec.

## 5. Migration note — M-track (M0–M1.2) into the fabric, no loss

- **evo1 stays the refactor host** (ADR-103). M0–M1.2 artifacts (snapshot 50806, vault, `/srv/banxe-legacy/...`, the backend clone) remain on evo1 untouched — they are the control-plane's refactor workspace, already in the right place.
- **No re-do, no port.** Completed M-track work (e.g. M1.2 crypto-earn provider, merged) is unchanged; the fabric wraps *future* steps, it does not rewrite past ones.
- **New steps run the chain.** From fabric go-live, each new migration/refactor step is authored as: evo2 produces the plan → evo1 `gate.policy` allows → Legion `gate.exec` executes → one `correlation_id` throughout. Until go-live, the factory continues on evo1 under ADR-103 (the documented degraded/single-box mode, ADR-104 §5), with this GAP (§3) as the known debt.
- **Continuity:** the migration roadmap (`docs/roadmap/intent-first-migration-roadmap-2026-06-08.md`) and M-track ledger entries remain the source of record; no ledger rewrite.

## Duplication Audit (ADR-102)

**Coverage:** searched `docs/runbooks/`, `docs/roadmap/`, `docs/adr/` for an existing
fabric **bootstrap / implementation / deployment** plan and for LiteLLM/heartbeat/
queue/correlation_id docs. Matches: `three-node-execution-fabric-contract.md` (the
runtime **interface** contract), `fa-02-litellm-canonical-aliases.md` + `factory-routing-map.md`
(LiteLLM routes), `fa-evo2-gpu-stack.md` (evo2 GPU), `redis-evo1-setup.md` (Redis on evo1),
`maintenance-window-evo2-q8`, `legion-litellm-cache.md`.

| Match | Decision | Rationale |
|---|---|---|
| `three-node-execution-fabric-contract.md` | **keep — source-of-truth (interface)** | This runbook **realizes** it (deployment plan); no contract text duplicated. |
| LiteLLM alias/route runbooks | **keep / reference** | Reused for the reasoning route; not re-specified here. |
| `fa-evo2-gpu-stack.md` | **keep / reference** | Cited as evo2 pre-req (OPERATOR ACTION 1); not duplicated. |
| `redis-evo1-setup.md` | **keep / reference** | Cited as queue/heartbeat backing-store candidate; not duplicated. |

**Verdict:** **no duplicate bootstrap/implementation runbook exists.** This is a new artifact
that composes (references) the existing component runbooks and **extends** the interface
contract with a concrete deployment plan + current-state GAP. No merge/**delete** of any
existing doc; nothing removed. Source-of-truth boundaries preserved (ADR-104 = decision,
contract runbook = interface, this = deployment/GAP).

**Refs:** ADR-104, ADR-040 (planes/trust), ADR-103 (server-only refactor host),
ADR-060 (orchestration), ADR-102 (Duplication Audit);
`docs/runbooks/three-node-execution-fabric-contract.md`, `fa-evo2-gpu-stack.md`,
`fa-02-litellm-canonical-aliases.md`, `factory-routing-map.md`, `redis-evo1-setup.md`.
