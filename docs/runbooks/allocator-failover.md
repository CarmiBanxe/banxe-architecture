# Runbook: IL Allocator — Migration (evo1→evo2) + Emergency Failover

**Canon:** ADR-143-B (Proposed), ADR-143-A, ADR-102. **Executor:** OPERATOR ONLY (HITL).
**Red line:** single writer at any instant; gaps ok, duplicates = corruption; no silent
local fallback; **no automatic promotion** — every step below is a human act.

## 1. Planned migration evo1 → evo2 (quiet window)

1. **Pause mints:** announce factory-wide; confirm no add-il-shard/build_ledger runs
   in flight (check terminals; lock by convention).
2. **Read source counter:** `redis-cli -h 100.68.102.48 GET banxe:il:counter` → note N.
3. **Seed target with margin:** `redis-cli -h 100.99.208.21 SET banxe:il:counter <N+50>`
   (margin covers any in-flight mint missed in step 1; gap is acceptable).
4. **Persistence check (target):** `redis-cli -h 100.99.208.21 CONFIG GET appendonly` →
   `yes`; `CONFIG GET appendfsync` → `everysec`. If not — fix BEFORE the flip.
5. **Flip config:** point the fabric at evo2 (`BANXE_IL_ALLOCATOR_URL` once landed;
   until then: `REDIS_HOST=100.99.208.21` in the operator env/profile).
6. **Verify:** `redis-cli -h 100.99.208.21 INCR banxe:il:counter` → value strictly
   greater than every issued IL (compare with `git grep -o 'IL-[0-9]\+' | sort` max
   or IL-SEQUENCE.json). One test mint via `add-il-shard.sh` on a scratch slug.
7. **Resume mints.** Record the migration (date, N, seeded value) in the ledger.
8. **Demote evo1 to cold standby:** leave data in place (read-only reference);
   do NOT delete the key.

## 2. Emergency failover (block-jump; primary down, mints urgent)

1. Confirm primary truly down (retries exhausted, not a transient — see T1 backoff).
2. Determine `last-known-issued`: max of IL-SEQUENCE.json / merged shards / operator
   knowledge. When in doubt, take the HIGHEST candidate.
3. **Promote standby with a jump:**
   `redis-cli -h <standby> SET banxe:il:counter <last-known-issued + 1000>`
   — the 1000-gap guarantees no duplicate even if the dead primary had unrecorded
   issues. Gap accepted; duplicate never.
4. Flip config to the standby (as §1.5). Verify INCR (as §1.6). Resume.
5. **Record** the jump (old primary, floor used, evidence) in the ledger same-day.
6. When the old primary returns: it is now the cold standby. NEVER let it serve
   mints with its stale counter — its key is reference-only until a future planned
   migration seeds it again.

## 3. Verification checklist (both procedures)

- [ ] Exactly ONE host is being written to (grep fabric env; no second writer).
- [ ] `INCR` result > max issued IL (strict monotonicity).
- [ ] AOF everysec on the active host.
- [ ] Test mint succeeded and produced a fresh, unique shard.
- [ ] Ledger record of the event committed (shard).

## 4. Rollback

- Migration rollback (before resume only): flip config back to evo1 — its counter was
  never decremented, so it is still safe. After ANY mint on evo2, rollback = a new
  migration evo2→evo1 with margin (§1), never a plain flip (evo1 counter is behind).
- Emergency rollback: none — a block-jump is one-way by design; recovery of the old
  primary follows §2.6.
