# Fabric bus → redis-streams — F1.5 stage-2 (ADR-104 §2/§5)

<!-- Source: docs/runbooks/bus-redis-streams-2026-06-17.md | Date: 2026-06-17 | Implements: ADR-104 §2 (queue/heartbeat) + §5 (failover) | extends: redis-evo1-setup.md, evo1-control-plane-bringup, gate-services-dry-run | IL: pending-shard -->

## Status

**BUS/HEARTBEAT ON REDIS-STREAMS.** F1.5 **stage-2** moves the fabric event-bus and
heartbeat off the in-process/file backing onto the **existing hardened `banxe-redis`**
(`redis-evo1-setup.md`) via **Redis streams**. **The executor stays `execute_enabled=false`
(DRY-RUN) — no real execution.** Real execution = **stage-3** (separate operator go). Done
server-side over ssh, **no sudo**, **password only from a mode-600 vault (never on argv / in
logs / in this doc)**, **no disabled redis command used**.

## 1. Redis-streams client (stdlib RESP, no pip)

- `~/banxe-fabric/evo1/fabric_redis.py` — minimal RESP client over a socket. Commands used:
  **AUTH, PING, XADD, XREVRANGE, XLEN, DEL**. It does **NOT** implement the disabled admin
  commands (**CONFIG / FLUSHALL / FLUSHDB / DEBUG** are `rename-command ""` on the server).
- Password read **only** from the vault `~/banxe-fabric/.vault/redis.pass` (mode `600`,
  48 chars) inside the client — **never passed on argv, never logged**.
- **fail-closed:** any connect / AUTH / IO error raises `RedisUnavailable` → callers degrade
  per ADR-104 §5.
- Connection: **local on evo1** `127.0.0.1:6379`. (Cross-node evo2→evo1 would use the
  tailscale bind `100.68.102.48:6379` — see §5 / OPERATOR ACTION.)

## 2. Bus + heartbeat moved to streams

- `fabric_common.EventBus` extended: when a redis client is supplied it **XADD**-s every
  event to a per-topic stream `fabric:<type-with-colons>` (e.g. `heartbeat.evo1` →
  `fabric:heartbeat:evo1`, `gate.policy` → `fabric:gate:policy`). Each entry carries
  `{correlation_id, node, ts, type, payload}`.
- The **file log is retained as a tagged local audit** — every line records `_redis:
  ok|degraded|file-only`, so a redis outage is **never silent** (fail-closed degraded, not a
  quiet file fallback).
- `evo1_control.py` publishes `heartbeat.evo1` to the stream and **bridges** evo2: it reads
  evo2 `:9208` `/health` and XADD-s `heartbeat.evo2` to the stream. evo2 **liveness** is then
  derived from the stream's **freshness** (`XREVRANGE` latest; stale > `K·poll` ⇒ down).
- `gate_policy.py` publishes `gate.policy` decision events to the stream (decision-only).
- **The `correlation_id` is preserved** in every stream entry, end-to-end.

### Verified (live, on the real `fabric:*` streams)

- **XADD/XREVRANGE round-trip** with `correlation_id` — OK.
- **Both heartbeats in redis**: `fabric:heartbeat:evo1` and `fabric:heartbeat:evo2` each
  carry the **same per-cycle `correlation_id`** (evo1 self + evo1-bridged evo2). Control
  reports `evo2: up via=redis`, `bus: redis`.
- **`gate.policy` decisions** land in `fabric:gate:policy` (allow / requires_hitl /
  deny-by-default), `correlation_id` matching the chain.

## 3. Executor unchanged — still DRY-RUN

`fabric/legion/gate_exec.py` is **untouched**: `GATE_EXEC_ENABLED` defaults to **`false`**
(`WOULD EXECUTE` log, runs nothing); fail-closed without a valid verdict; refuses real
execution even if enabled. **No execution path activated in stage-2.**

## 4. Failover (ADR-104 §5) via redis — verified

- **evo2 publish absent/stale in the stream ⇒ evo2 `down`, fabric `degraded`,
  `reasoning_degraded=true`.** Verified on an **isolated throwaway** control (`:9118`,
  dedicated `fabric-fo` stream prefix, dead evo2 URL) — the real services, real evo2, and
  real `fabric:*` streams were **not** touched.
- **redis itself down ⇒ bus `degraded` ⇒ fabric `degraded`** (fail-closed; file log tagged
  `degraded`, not silent).

## 5. systemd — both units on redis (no sudo)

- `evo1-control.service` and `evo1-gate-policy.service` updated with redis env
  (`FABRIC_BUS=redis`, `REDIS_HOST=127.0.0.1`, `REDIS_PORT=6379`,
  `REDIS_PASS_FILE=~/banxe-fabric/.vault/redis.pass`, `FABRIC_STREAM_PREFIX=fabric`).
  **Only the vault path is in the unit — never the password.**
- `Restart=always`, **`Linger=yes`** (survives reboot) — both **active / enabled**.

## 6. Secret handling & minimal-privilege decision

- The requirepass lives **only** on evo1 (`~/banxe-fabric/.vault/redis.pass`, mode 600). It
  was **never** transferred through the factory, never printed, never written to repo /
  ledger / PR.
- **evo2 vault — OPERATOR ACTION (chosen minimal-privilege variant).** Rather than copy the
  secret to evo2 (which would route it through the factory), **evo1 bridges** evo2's
  heartbeat into the stream using evo1's local auth. A **direct** evo2→evo1 redis publish
  (evo2 writing with its own vault over tailscale `100.68.102.48:6379`) needs a vault on
  evo2 — the **operator** provisions `~/banxe-fabric/.vault/redis.pass` on evo2 the same
  server-side way. Until then the evo1-bridge is the source of `heartbeat.evo2`.

## 7. OPERATOR ACTIONS (HITL / sudo / secret — NOT done by the factory)

1. **evo2 vault + direct publish** — provision the evo2-side vault and switch evo2 to publish
   `heartbeat.evo2` directly to redis over tailscale (removes the evo1 bridge).
2. **Stage-3 executor activation** — `GATE_EXEC_ENABLED=true` + real executor on Legion,
   behind HITL (AUTH>90 / REVIEW 70–90 / BLOCK<70 per `.claude/rules/agents.md`). **Not here.**
3. **Consumer groups** — `XGROUP`/`XREADGROUP` for durable multi-consumer delivery + stream
   `MAXLEN` trimming policy (the RESP client extends to these on the same socket).
4. **Auth-harden :9108/:9110** before fabric exposure (token + Tailscale/LAN ACL).

## Duplication Audit (ADR-102)

**Coverage:** `redis-evo1-setup.md`, `fabric_common.py` (F1.2 bus), the F1.2/F1.3 runbooks,
and `docs/runbooks/` for redis/stream/bus implementations.

| Match | Decision | Rationale |
|---|---|---|
| `redis-evo1-setup.md` (`banxe-redis` 7, hardened) | **reuse / extend** | The existing container is the backing store — **not** re-provisioned. This runbook adds the **streams** usage + vault read; honours the disabled-command hardening. |
| `fabric_common.EventBus` (F1.2 in-process/file) | **extend, not duplicate** | Same class gains an optional redis sink + tagged audit log; the file bus remains as the fallback audit. No second bus implementation. |
| `evo1-control-plane-bringup` / `gate-services-dry-run` | **extend** | Same services re-pointed at redis; correlation_id / failover / dry-run contracts unchanged. |
| `fabric_redis.py` | **new (no duplicate)** | No prior redis client in the fabric; raw-socket RESP mirrors `redis-evo1-setup.md`'s verify snippet (stdlib, no pip). |

**Verdict:** **no duplicate** — extends the existing Redis + F1.2 bus with a streams backing;
reuses the hardened container and the correlation_id/failover contracts. **Keep all, no
merge/delete.**

## Confirmations

executor **DRY-RUN** (`GATE_EXEC_ENABLED=false`) — **no real execution** · password **only**
from mode-600 vault, **no-argv, not in logs/PR/ledger** · **no disabled redis command** used
(CONFIG/FLUSHALL/FLUSHDB/DEBUG) · **legacy secrets not touched** (no banxe-rar-extracted reads) ·
fail-closed degraded per §5 · reasoning(evo2)/policy(evo1) **act on nothing** · no cross-node
state drift (evo1 only **reads** evo2 health, bridges into its own stream) · evo1/evo2 services
**not stopped** · M0–M1.2 / `/srv/banxe-legacy` / prod / emi-stack untouched · server-side only,
no sudo.

**Refs:** ADR-104 (§2 queue/heartbeat, §5 failover), ADR-103 (server-only), ADR-102, ADR-059-A;
`redis-evo1-setup.md`, `three-node-execution-fabric-contract.md`,
`evo1-control-plane-bringup-2026-06-17.md`, `gate-services-dry-run-2026-06-17.md`,
`fabric/legion/gate_exec.py`, `.claude/rules/agents.md`.
