# evo1 control-plane bring-up — status (F1.2, ADR-104)

<!-- Source: docs/runbooks/evo1-control-plane-bringup-2026-06-17.md | Date: 2026-06-17 | Implements: ADR-104 + three-node-execution-fabric-contract.md + three-node-fabric-bootstrap.md | IL: pending-shard -->

## Status

**CONTROL PLANE UP (observe-only, ADR-104 §5 degraded-mode legal).** evo1
(`banxe-NucBox-EVO-X1`, user `banxe`) is brought up as the fabric **control /
orchestration plane** per ADR-104 / `three-node-fabric-bootstrap.md`: a heartbeat
coordinator, a lightweight queue/event-bus, a unified `correlation_id`, and an
aggregated control health endpoint on **:9108**. It **coordinates and observes only** —
it activates **no execution path and no gates** (`gate.policy` / `gate.exec` = F1.3). It
**reads** evo2 `:9208` health; it never writes evo2 state (no cross-node drift). Done
server-side over ssh, **no sudo executed for code**, no secrets handled.

Closes pre-fabric debt **GAP-G5** (no correlation_id) and **GAP-G6** (no queue/heartbeat
service) from `three-node-fabric-bootstrap.md` §3.

## 1. What runs on evo1 (factory-built, no sudo, stdlib-only)

Artifacts under `~/banxe-fabric/evo1/` (mirrors the evo2 `~/banxe-fabric/evo2/` layout):

| File | Role |
|---|---|
| `fabric_common.py` | `correlation_id` mint/echo helper, `EventBus` (in-process queue + append-only log), `NodeRegistry` (liveness + K-missed-beats) |
| `evo1_control.py` | the control-plane service: coordinator thread + HTTP status endpoint on `:9108` |
| `fabric-events.log` | append-only event log (`{correlation_id, node, ts, type, payload}`) |

- **Python 3.12.3, stdlib-only** (no pip deps) — `http.server`, `threading`, `urllib`.
- **No secrets**: the control-plane reads only evo2's keyless `:9208` health endpoint.

### Heartbeat coordinator
Every `FABRIC_POLL_INTERVAL_S` (default 15 s): emits `heartbeat.evo1`, reads evo2 `:9208`
`/health`, updates the liveness registry, and emits `heartbeat.evo2` (observed). A node is
marked **down** after `FABRIC_DOWN_AFTER_MISSED` (default 3) missed beats — per the
runtime contract §2.

### Queue / event-bus
Topics `task.*` / `plan.*` / `gate.*` / `event.*`; every message carries
`{correlation_id, node, ts, type, payload}`. **Backing store today = in-process deque +
append-only file log.** Redis-streams backing is an **OPERATOR ACTION** (see §4) — it
needs the `requirepass` secret (`REDIS_PASS`), which the factory does not handle. This
mirrors evo2's local `heartbeat.log` until the shared bus exists.

### correlation_id (unified lifecycle id)
Format **`fab-<utc-iso>-<6hex>`** — identical to evo2's `evo2_health.py`. evo1 mints at
task `created`; inbound `X-Correlation-Id` is echoed verbatim, else a fresh id is minted.
**End-to-end verified:** one minted id appears on both the evo1 self-beat **and** the
evo2 health-read in the same cycle (evo2 echoes the inbound id), e.g.
`fab-2026-06-17T10:27:41Z-a27fbc` on both `heartbeat.evo1` and `heartbeat.evo2`.

### Control health/status endpoint :9108
- `GET /health` (also `/`) → aggregated fabric state
  `{node:"evo1", role:"control", status: up|degraded|down, ts, correlation_id,
  acts_on:"nothing (control/observe-only)", nodes:{evo1, evo2}, failover, bus}`.
  Echoes `X-Correlation-Id`.
- `GET /status` → the above plus `recent_events`.
- `GET /nodes` → the liveness registry (evo1 self + evo2 up/down, last-seen, missed-beats).
- `POST /task` → mints a lifecycle `correlation_id`, emits `task.created` (observe-only;
  **executes nothing** — gates are F1.3), returns `{correlation_id, state:"created"}`.

### Failover hook (ADR-104 §5) — indication only
If evo2 is unreachable for K missed beats → evo2 marked `down`, fabric → `degraded`,
`failover.reasoning_degraded = true` (control continues; risky execution would be blocked
at the Legion gate — F1.3). **Verified** on an isolated throwaway instance (`:9109`,
dead endpoint) — the real evo2 was **not** touched. The hook only **indicates**; it
performs no action.

## 2. Persistence — systemd user-unit (no sudo)

- Unit `~/.config/systemd/user/evo1-control.service` — `Restart=always`, `RestartSec=3`,
  `WantedBy=default.target`, env (`EVO1_CONTROL_PORT=9108`, poll/down thresholds,
  `EVO2_HEALTH_URLS`).
- `systemctl --user enable --now evo1-control.service` → **active (running)**, **enabled**.
- `loginctl enable-linger banxe` succeeded **without sudo** → **`Linger=yes`** (the unit
  survives logout **and reboot**). Parity with evo2's `evo2-health.service`.

## 3. Reuse / no-duplication of infrastructure

- **Redis on evo1** (`banxe-redis`, up 9 days, `redis-evo1-setup.md`) is **reused as the
  designated bus backing-store** — but wiring it requires `REDIS_PASS` (a secret) →
  deferred to OPERATOR ACTION (§4). Not re-provisioned.
- **LiteLLM aliases / routes** unchanged — control-plane does no inference.
- evo2 reasoning node (`:4000` / `:9208`) reused as the health source — read-only,
  **not modified, not restarted**.

## 4. OPERATOR ACTIONS (HITL / sudo / secret — NOT executed by the factory)

1. **Bus backing-store → Redis streams.** Point the `EventBus` at `banxe-redis` (streams
   `task/plan/gate/exec/event.*` + `heartbeat.<node>`). Needs `REDIS_PASS` from the
   server vault (`~/banxe-dev/redis-evo1.env`, never in repo). Until then the bus is the
   in-process + file log.
2. **Cross-node heartbeat publish.** Once the bus is shared, evo2/Legion publish
   `heartbeat.<node>` to it instead of local logs (the F1.3+ infra step).
3. **Auth-harden :9108 before fabric exposure.** Currently bound `0.0.0.0`, no auth
   (parity with evo2 `:9208`). Add a token + Tailscale/LAN ACL before any non-local use.
4. **Gate services (F1.3).** Deploy `gate.policy` (evo1) and `gate.exec` (Legion) and wire
   the chain reasoning(evo2) → policy(evo1) → execution(Legion). **Out of scope here.**
5. **Sync layer (F1.x).** Controlled `context.publish`/`context.subscribe` with versioning
   (contract §4) — not stood up in F1.2.

## Duplication Audit (ADR-102)

**Coverage:** searched `docs/runbooks/`, `docs/adr/`, `.claude/rules/`, and the evo1/evo2
fabric artifacts for an existing control-plane / queue / heartbeat-coordinator /
correlation_id implementation. Matches reviewed:

| Match | Decision | Rationale |
|---|---|---|
| `three-node-execution-fabric-contract.md` | **keep — source-of-truth (interface)** | This bring-up **implements** the contract (lifecycle id, heartbeat, health, failover §5); no contract text duplicated. |
| `three-node-fabric-bootstrap.md` §1 (evo1 plane plan) | **keep — realizes** | This is the concrete F1.2 realization of the evo1 control-plane section; closes its G5/G6 debt. No re-spec. |
| `evo2-reasoning-node-bringup-2026-06-17.md` / `evo2_health.py` | **keep / reuse pattern** | `correlation_id` format + `/health` shape reused verbatim (consistency across nodes); evo1 reads evo2, does not re-implement evo2's emitter. |
| `redis-evo1-setup.md` (`banxe-redis`) | **keep / reuse as backing-store** | Designated bus store; wiring deferred (needs secret). Not duplicated, not re-provisioned. |
| `fa-02-litellm-canonical-aliases.md` / `factory-routing-map.md` | **keep / reference** | Control-plane does no inference; routes untouched. |

**Verdict:** **no duplicate** — F1.2 implements the contract and realizes the bootstrap
plan's evo1 section, reusing evo2's correlation_id/health conventions and the existing
Redis. **Keep all, no merge/delete.** Source-of-truth boundaries preserved (ADR-104 =
decision, contract = interface, bootstrap = deployment plan, this = evo1 realization).

## Confirmations

no sudo executed for code (`loginctl enable-linger` is a per-user, non-sudo op) · no
secrets handled (Redis `requirepass` deferred to operator; control-plane reads only the
keyless evo2 `:9208`) · **no execution path / no gates activated** (`gate.policy` /
`gate.exec` = F1.3) · control-plane **acts on nothing**, reads evo2 health only (no
cross-node state write) · evo2 services **not stopped** · M0–M1.2 / `/srv/banxe-legacy` /
prod / emi-stack untouched.

**Refs:** ADR-104, ADR-040, ADR-103, ADR-102; `docs/runbooks/three-node-execution-fabric-contract.md`,
`three-node-fabric-bootstrap.md`, `evo2-reasoning-node-bringup-2026-06-17.md`,
`redis-evo1-setup.md`, `fa-02-litellm-canonical-aliases.md`.
