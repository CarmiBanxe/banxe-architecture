# ADR-170: Cross-Terminal Registration Sync — writer-lock, stale-main gate, working-file durability

## Status
Proposed

> R-SYNC. Closes the **narrow** cross-terminal "registration" gaps that caused two recurring
> incidents — **stale-main** (a sprint cut from a behind base) and **lost-untracked** (working files
> destroyed by worktree/branch hygiene, recovered in **PR #1123**). Additive to, and **not** a
> restatement of, ADR-120/121/134/153 (ADR-102 pointer-first).

## Context
The existing terminal-sync canon covers isolation, protection, attribution, and topology:
- **ADR-120** — per-session worktree isolation (one session = one worktree off `origin/main`).
- **ADR-121** — parallel-session destructive-action protection.
- **ADR-134** — cross-terminal status-report attribution (don't mis-blame a foreign terminal).
- **ADR-153** — terminal-topology canon (A=left/factory, Central, B=right).

None of them provide: (a) a **preflight HARD gate** on a stale base, (b) a **cross-terminal
writer-lock** to surface concurrent ledger writers, or (c) an **anti-untracked durability rule**.
Concretely: `factory-preflight.sh` treated base-drift as WARN-only, so a sprint could be cut from a
behind base and only discover it at merge; `fabric_redis.py` had `incr/get/set` but no atomic lock
primitive; and important working files were left untracked and swept away.

## Decision
Three narrow deltas:

1. **(A) Preflight HARD stale-main gate.** `tools/factory/factory-preflight.sh` base-drift check:
   `behind>0` now calls `fail()` (was `warn()`), with message *"stale main: behind=$BEHIND — run
   git pull --ff-only origin main before starting a sprint"*. `behind=0` still passes. No other
   check changed. (This `.sh` file is infra-exempt from the shard rule, but B/D/E below are not.)

2. **(B) Atomic advisory lock in `fabric/common/fabric_redis.py`.**
   - `set_nx_ex(key, value, ttl_seconds) -> bool` — one atomic `SET key value NX EX ttl`; returns
     True iff acquired, False if already held; TTL bounds a crashed holder. Fail-closed
     (RedisUnavailable) on connect/AUTH/IO failure — never a silent "acquired".
   - `release_if_owner(key, expected_value) -> bool` — `GET`; if it equals our token, `DEL`. Documented
     **non-atomic caveat** (GET+DEL two round-trips; a Lua CAS is the atomic ideal — see Follow-ups).
   `incr/get/set/connect` are unchanged.

3. **(C) Advisory writer-lock read in preflight.** A new read-only `ledger-writer-lock` check: if the
   branch is ledger-touching and Redis is reachable, `GET banxe:ledger:writer`; if another terminal id
   holds it, **WARN** (never fail — the lock is acquired at push time, not preflight) naming the holder.
   Surfaces cross-terminal contention early.

4. **(D) Working-file durability rule.** `docs/governance/WORKING-FILE-DURABILITY.md`: important
   working artifacts MUST be committed on a named branch, never left untracked (untracked files are
   destroyed by worktree/branch hygiene — PR #1123). Cross-refs ADR-120.

## Non-Goals
- **No new topology** and no change to ADR-153.
- **No replacement of ADR-134** attribution — this adds a lock signal, not a new attribution model.
- **No full distributed lock manager** — the Redis `SET NX EX` lock is **advisory** only; the real
  guard remains push-time base-drift + guardian-ledger + the single-writer merge queue. The preflight
  read is a heads-up, not an enforcement point.
- **No auto-acquire/auto-release in preflight** — preflight stays read-only.

## Duplication Audit (ADR-102)
| Existing | Provides | Delta here |
|---|---|---|
| ADR-120 | session-worktree isolation | (D) records the *durability* consequence (commit, don't leave untracked); does not restate isolation |
| ADR-121 | destructive-action protection | unrelated (this ADR adds no destructive op) |
| ADR-134 | cross-terminal attribution | (C) adds a *lock-holder* signal, not an attribution rule; complementary |
| ADR-153 | terminal topology | unchanged; no new terminal/role |
| `fabric_redis.py` incr/get/set | fail-closed Redis primitives | (B) adds `set_nx_ex`/`release_if_owner` in the same fail-closed style; existing methods untouched |
| `factory-preflight.sh` base-drift WARN | advisory drift note | (A) promotes to HARD fail; (C) adds an advisory lock read |

**Conclusion:** no overlap — each delta fills a gap none of ADR-120/121/134/153 covers. ADD the ADR,
the durability doc, and the two Redis methods; KEEP all referenced canon unchanged.

## Follow-ups (separate sprints)
- **Atomic release via Lua CAS** — replace `release_if_owner`'s GET+DEL with a single `EVAL "if
  redis.call('get',KEYS[1])==ARGV[1] then return redis.call('del',KEYS[1]) end"` for a truly atomic
  compare-and-delete.
- **Writer-lock heartbeat registry** — periodic refresh + a `banxe:ledger:writers` set for a live view
  of which terminal holds/queues the ledger writer slot.
- **Wire acquire/release at push time** — a push wrapper that `set_nx_ex` before a ledger push and
  `release_if_owner` after (out of scope here — preflight stays read-only).

## References
- `tools/factory/factory-preflight.sh` (A, C), `fabric/common/fabric_redis.py` (B),
  `docs/governance/WORKING-FILE-DURABILITY.md` (D).
- ADR-120, ADR-121, ADR-134, ADR-153 (KEEP; cross-ref). ADR-056/060 (guardian-ledger coupling),
  ADR-143 (Redis allocator), ADR-104 §5 (fail-closed degrade), ADR-102 (pointer-first). PR #1123
  (lost-untracked recovery). I-24 (append-only).
