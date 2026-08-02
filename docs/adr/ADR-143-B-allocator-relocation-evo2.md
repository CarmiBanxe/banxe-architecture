# ADR-143-B: IL Allocator Relocation — primary to evo2 (amends ADR-143-A)

**Date:** 2026-08-02
**Status:** Proposed
**IL:** TBD (assigned by ledger-rebuild after merge)
**Author:** Moriel Carmi / Claude Code

refs:
  - ADR-143 / ADR-143-A (shared Redis IL allocator — THIS ADR amends 143-A)
  - ADR-102 (dedup — exactly one allocator)
  - ADR-105 (three-node fabric)
  - docs/runbooks/EVO1-ALLOCATOR-STABILITY-2026-08-02.md (incident evidence)
  - docs/runbooks/allocator-failover.md (migration + emergency procedures)

---

## Context

evo1 load-spike starvation caused **2 mint STOPs on 2026-08-02** (factory fail-closed,
correctly). The allocator Redis itself is healthy (restarts=0), but it is co-located
with the GPU workload (3 concurrent ollama residents + clickhouse), and at load
163–233 kernel-wide softirq starvation makes its network path time out. ADR-143-A
places the single allocator on evo1 (100.68.102.48:6379, key `banxe:il:counter`).

## Decision

Relocate the **SINGLE primary allocator** to **evo2 `100.99.208.21:6379`**, same key
`banxe:il:counter`. evo1 becomes **cold standby**. Amends ADR-143-A (host only —
key, semantics, fail-closed contract unchanged).

**(i) New primary:** evo2 100.99.208.21:6379, key `banxe:il:counter`.
**(ii) Migration (operator, quiet window):** pause mints → `SET` evo2 counter =
`GET` evo1 + safety margin → flip `BANXE_IL_ALLOCATOR_URL` → verify `INCR` returns
value strictly greater than any issued IL → resume mints.
**(iii) Standby promotion:** evo1 is promotable ONLY via the manual block-jump
runbook (counter floor = last-known-issued + 1000; gap accepted, duplicate never).
**(iv) RED LINE (verbatim, binding):** single writer at any instant;
uniqueness + strict monotonicity (gaps ok, duplicates = corruption); NO silent
local fallback (IL-827); failover = manual HITL runbook, **no automatic promotion**.

**Persistence:** evo2 Redis runs with **AOF `appendfsync everysec`** — the counter
must survive a reboot.

## Consequences

- The latency-critical singleton moves OFF the GPU node — load spikes on evo1 stop
  starving mints; fabric retry (T1, #1182) stays as transient cover.
- Anti-collision preserved: still exactly one writer at any instant (ADR-102).
- Failover is manual-only: an outage pauses mints until an operator acts — accepted
  cost; the alternative (auto-promotion) risks duplicates, which are corruption.
- Config: `BANXE_IL_ALLOCATOR_URL` (fabric-code follow-up PR) replaces scattered
  host/port defaults; until it lands, REDIS_HOST/REDIS_PORT env keeps working.

## Alternatives considered (REJECTED)

1. **Dual-active allocators** — guaranteed duplicates under concurrency; duplicates
   are corruption, not degradation. Rejected.
2. **Auto-promote async replica** — replication lag re-issues already-issued numbers
   on promotion; same corruption class. Rejected (manual block-jump only).
