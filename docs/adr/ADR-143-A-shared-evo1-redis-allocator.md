---
id: ADR-143-A
title: Central IL allocator targets the SHARED evo1 Redis (amends ADR-143 — fixes the local-127.0.0.1 config gap)
status: ACCEPTED
accepted: 2026-07-12
date: 2026-06-27
amends: ADR-143
relates:
  - "ADR-143 (central IL allocator via Redis INCR — this fixes its config so the counter is actually shared)"
  - "ADR-104 §5 (graceful degrade — fallback retained, WARN strengthened to name the target host)"
  - "ADR-119 Rule 8 (provisional IL — unchanged); ADR-057/059-A (append-only — unchanged)"
  - "fabric/legion/gate_exec_consumer.py (canonical REDIS_HOST/REDIS_PORT/REDIS_PASS_FILE the allocator now matches)"
il_anchor: IL-615
il_anchor_note: "Provisional per ADR-119 Rule 8 — minted by the allocator (shared evo1 Redis, or local max+1 fallback) over current origin/main. Frozen at rebase-before-merge."
scope: BANXE-ledger-tooling
concept_only: false
---

# ADR-143-A — Central IL allocator targets the SHARED evo1 Redis

## Context — the config gap in ADR-143

ADR-143 introduced the central allocator but pointed `_redis_allocate` at **`TL_REDIS_HOST`/
`TL_REDIS_PORT` (default `127.0.0.1:6379`)** — the **traffic-light local monitoring** Redis. That is
**per-host**: each terminal (evo1 / evo2 / Legion) would hit its **own** local counter, and on Legion no
local Redis is even running (PING unanswered) → the allocator fell back to local `max+1` (IL-613 was
minted that way). **Net: the counter was not shared, so the anti-collision was illusory** — exactly the
IL-172 duplicate class ADR-143 set out to kill.

## Decision

Point the allocator at the **one shared fabric Redis** the factory already uses — **evo1 over
tailscale, `100.68.102.48:6379`** — via the **same env vars and defaults as
`fabric/legion/gate_exec_consumer.py`**:

| Setting | Value |
|---|---|
| host | `REDIS_HOST` (default **`100.68.102.48`**) — explicit env overrides the evo1 default |
| port | `REDIS_PORT` (default `6379`) |
| password | vault file `REDIS_PASS_FILE` (default `~/banxe-fabric/.vault/redis.pass`, mode-600) — **path only, never the secret** |

**`TL_REDIS_*` is no longer used** by the allocator (it is local traffic-light monitoring, not the
fabric counter).

### Counter seed (monotonic floor)
On first contact the allocator seeds the counter floor: `GET banxe:il:counter`; if it is below the
frozen `max(IL-SEQUENCE.json)`, `SET` it to that max (only when below). A fresh evo1 counter therefore
never hands out a number below an already-assigned one, and the `INCR`-until-`> max` loop remains the
**atomic** safety net (covers any seed race between terminals). `RedisStreams` gains small `get`/`set`
helpers for this.

### Fallback (retained, strengthened)
Redis-unavailable still degrades to local `max+1` (ADR-104 §5 — never crash), but the WARN now **names
the target host/port** so a miss on the **shared** counter is visible:
`WARN: shared fabric Redis 100.68.102.48:6379 unreachable (…); fallback to local max+1 — anti-collision
DEGRADED, RACE POSSIBLE across terminals`.

### `--check` unchanged
`main()` still calls `assign(use_allocator=not args.check)` — `--check`/rebuild stay **offline +
deterministic**, never contacting Redis. CI without Redis passes.

## Operational requirement

For the anti-collision to hold, **every terminal that mints IL numbers (evo1 / evo2 / Legion) MUST point
at the one evo1 counter** — i.e. `REDIS_HOST=100.68.102.48` (the default) reachable over tailscale, with
the Legion-side vault password provisioned. If evo1 Redis is unreachable, the build still succeeds
(fallback) but prints the DEGRADED warning; concurrent mints during an outage can collide and must be
reconciled via the ADR-142 append-only corrective pattern. Documented in `fabric/legion/README.md`.

## Canon
- **ADR-119 Rule 8:** IL stays provisional; only the counter *location* changes (shared vs local).
- **ADR-057/059-A:** existing keys keep frozen numbers; `IL-SEQUENCE.json` diff add-only.
- **ADR-104 §5:** graceful degrade retained; CI/`--check` never depend on Redis.
- No secrets in code — only the vault **path**, exactly as `gate_exec_consumer.py`.

## Anchors
- `ledger/build_ledger.py` (`_redis_config` / `_redis_allocate` seed / `_alloc_next` WARN),
  `fabric/common/fabric_redis.py` (`get`/`set`), `tests/test_redis_il_allocator.py` (host-config + WARN
  tests), `fabric/legion/README.md` (operational requirement). Amends ADR-143; ADR-119/057/059-A/104 §5.

## Ratified 2026-07-12 (PROPOSED → ACCEPTED)

> Append-only (I-24): the decision text above is unchanged; this records ratification only.

Ratified 2026-07-12. The shared allocator is confirmed **LIVE**: a `PING` to the canonical
target **evo1 `100.68.102.48:6379`** returned **`PONG`** today, authenticated via the vault-file
credential (`REDIS_PASS_FILE`, path-only — never the secret in code, exactly as
`fabric/legion/gate_exec_consumer.py`). The `build_ledger._alloc_next` path mints IL numbers against
this shared counter and **fails loud** (RuntimeError) when the allocator is unreachable — no silent
local `max+1` fallback (offline mint requires the explicit `BANXE_IL_ALLOCATOR=local` opt-in).

- **Config verified:** `REDIS_HOST=100.68.102.48`, `REDIS_PORT=6379`, `REDIS_PASS_FILE` vault path
  (matches `gate_exec_consumer.py` canon).
- **No allocator code change** — this amendment is doc/governance only; the technical decision and
  implementation described above are unchanged.
- **Enforcement:** the fail-loud `_alloc_next` guard + `guardian-ledger` CI coupling remain in force.
