---
id: ADR-143
title: Central IL allocator via Redis INCR — atomic cross-process anti-collision (replaces local max+1)
status: accepted
accepted: 2026-07-09
date: 2026-06-27
amends: ADR-119
relates:
  - "ADR-119 (provisional/frozen IL numbering — Rule 8; this changes only the SOURCE of the number, not its provisional semantics)"
  - "ADR-133 / ADR-142 (IL uniqueness gate + the IL-159/172 dedup migration — this fixes the ROOT cause those记录)"
  - "ADR-057 / ADR-059-A (append-only ledger; existing keys keep their frozen number)"
  - "ADR-104 §5 (graceful degrade / fail-closed — Redis-unavailable fallback)"
  - "LEDGER-MERGE-QUEUE.md (native GitHub merge queue is UNAVAILABLE — repo is user-owned, org-only feature; this allocator provides the serialization instead)"
il_anchor: IL-613
il_anchor_note: "Provisional per ADR-119 Rule 8 — NOT hardcoded; minted by the new allocator (Redis INCR, or local max+1 fallback) over current origin/main. Frozen at rebase-before-merge."
scope: BANXE-ledger-tooling
concept_only: false
---

# ADR-143 — Central IL allocator via Redis INCR

## Context

`ledger/build_ledger.py:assign()` minted new IL numbers as `max(IL-SEQUENCE.json values) + 1`.
`IL-SEQUENCE.json` is a **local** persisted map; two terminals on **different worktrees** run
`build_ledger.py` independently, both read the same `max`, and both emit `max+1` → a **duplicate**
(the **IL-172 class**: a shard minted 519 collided with a parallel body-reference 172). The native
**GitHub merge queue** that would serialize this is **unavailable** — the repo is **user-owned**, and
merge queue is an **organization-only** feature. So serialization must come from a **central ID
allocator**, not from GitHub.

## Decision

Replace the inter-process-unsafe `max+1` with an **atomic central counter** — **Redis `INCR`** on key
`banxe:il:counter` — used **only at live-mint time**. Determinism of `--check` is preserved.

### Three modes (strict separation)
1. **MINT (live write only — `build_ledger.py` without `--check`):** each NEW shard number comes from
   `RedisStreams.incr("banxe:il:counter")`. **Atomic** across processes/worktrees → two terminals can
   never receive the same number.
2. **FALLBACK (Redis unavailable):** degrade to local `max+1` and print
   `WARN: Redis allocator unavailable … RACE POSSIBLE …` — **never crash** (ADR-104 §5 graceful
   degrade). Single-terminal use stays correct; only concurrent mints lose the atomic guarantee, and
   the warning makes that explicit. `BANXE_IL_ALLOCATOR=local` forces this path deliberately.
3. **`--check` / REBUILD:** **never contacts Redis.** `main()` calls
   `assign(records, use_allocator=False)`, so the gate is **fully offline + deterministic** — it only
   reproduces numbers already **frozen** in `IL-SEQUENCE.json`. CI runners need no Redis.

### Monotonicity guarantee
The counter is always `>= max(IL-SEQUENCE.json)`: a fresh/behind counter is bumped (repeat `INCR`)
until it **exceeds** the current frozen max, so no number at/below an already-assigned one is ever
handed out. Existing keys **keep their frozen number** (the existing `assign()` branch is unchanged) —
append-only (ADR-057/059-A) holds.

### Config
- Host/port: `TL_REDIS_HOST` / `TL_REDIS_PORT` (default **127.0.0.1:6379**).
- Password: vault file `REDIS_PASS_FILE` (default `~/banxe-fabric/.vault/redis.pass`, mode-600), exactly
  as `RedisStreams` is used in `fabric/legion/gate_exec_consumer.py`. Never on argv, never logged.

## Why this preserves canon
- **ADR-119 Rule 8 (provisional IL):** the IL stays **provisional** — only the *source* of the number
  changes (central counter vs local `max+1`); it is still frozen at rebase-before-merge, never hardcoded.
- **ADR-057 / 059-A (append-only):** existing keys are untouched; only NEW keys are allocated;
  `IL-SEQUENCE.json` diff is **add-only**.
- **ADR-133 / ADR-142:** this removes the **root cause** of the duplicate class those records had to
  clean up after the fact.
- **ADR-104 §5 (fail-closed/degrade):** Redis down ⇒ warn + fallback, never a hard failure;
  `--check`/CI never depend on Redis.

## Consequences
- Concurrent terminals minting against a **live Redis** can no longer collide (atomic `INCR`).
- With Redis down, behaviour is the old `max+1` **plus a loud RACE warning** — no regression, just a
  visible caveat.
- `fabric/common/fabric_redis.py` gains a small `incr(key)` method (RESP `INCR`, fail-closed).
- A future hardening (Redis persistence/HA, or a Lua `CAS` seed) is optional and out of scope here.

## Anchors
- `ledger/build_ledger.py` (`_alloc_next` / `_redis_allocate` / `assign(use_allocator=...)`),
  `fabric/common/fabric_redis.py` (`incr`), `tests/test_redis_il_allocator.py`.
  ADR-119/133/142, ADR-057/059-A, ADR-104 §5, `LEDGER-MERGE-QUEUE.md` (queue unavailable → allocator).

## Amendment 2026-07-09 — Ratified (PROPOSED → accepted)

> Append-only (I-24): the body above is unchanged; this records the ratification.

Ratified per orchestration escalation #1084. The allocator has been operating in production
and is confirmed live; this amendment flips the status to `accepted` and records the evidence.

- **Allocator verified LIVE.** `banxe:il:counter` observed at **1054+** on the shared **evo1**
  Redis (`100.68.102.48:6379`), incremented by atomic `INCR`.
- **Fail-loud guard already implemented — NO code change (ADR-102).** `build_ledger._alloc_next`
  already refuses a silent local `max+1` fallback; on Redis-unreachable / missing auth it raises
  a loud RuntimeError. Offline local counter only via explicit `BANXE_IL_ALLOCATOR=local`;
  `--check`/rebuild stay offline-deterministic. No hardening required; touching working code
  would violate ADR-102.
- **The "1046/1048" observation was NOT a collision** — monotonic Redis allocation (1046 reserved
  by an unmerged branch; 1047/1048 later in order). Append-only, no renumber, no silent fallback.

Effective: 2026-07-09. Enforcement: CI (`guardian-ledger`) + strict branch protection +
the live `_alloc_next` guard.
