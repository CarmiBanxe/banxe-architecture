# EVO1 Allocator Stability — tech-debt note + mitigation recommendation

**Date:** 2026-08-02 | **Type:** runbook / tech-debt record | **Status:** Recorded (actions operator-gated)
**Canon:** ADR-143-A (shared evo1 Redis allocator — UNCHANGED by this note), ADR-QUARANTINE-MIDAZ-EVO1, ADR-105 (three-node fabric).

## 1. Summary

The IL allocator is **canon-correct** per ADR-143-A: host `100.68.102.48:6379` (evo1),
key `banxe:il:counter` (namespaced, isolated from midaz). The intermittent
"allocator unreachable" misses observed 2026-08-01/02 are **evo1 LOAD-induced network
timeouts** — NOT a Redis failure, NOT a config error, NOT midaz coupling. Two factory
STOPs on 2026-08-01 were fail-closed reactions of the fabric to a transient condition
that recovered within ~10–20 s.

## 2. Evidence (audit 2026-08-02)

- evo1 load spikes hit **171–233** (load average) during the miss windows.
- Concurrent GPU residents at the time: **3 ollama models** (qwen3.5:35b +
  qwen3-banxe-v2 + qwen2.5-coder) plus **clickhouse at ~75% CPU**.
- `banxe-redis` (redis:7, host-net): **restarts = 0, up 4 days** — the allocator
  process itself never crashed.
- Key `banxe:il:counter` present; `PING` → `PONG`; `INCR` works.
- Fabric behavior: `scripts/add-il-shard.sh` does a **single 3 s TCP precheck** and
  then FAIL-CLOSED STOP (no retry). Both 2026-08-01 STOPs would have been avoided by
  a short retry window; the allocator was reachable again seconds later.

## 3. Tech-debt items (ranked; every action operator-gated)

- **T1 — fabric, LOW risk — RECOMMEND.** Add retry-with-backoff to the allocator
  precheck in `scripts/add-il-shard.sh`: e.g. 3 attempts at 5 s / 10 s / 15 s
  **before** the existing fail-closed STOP. Keeps ADR-143-A semantics intact
  (fail-closed stays; `local` mode stays forbidden) — it only widens the transient
  window the fabric tolerates. Gate: operator approves the script change as a
  separate code PR.
- **T2 — infra/evo1 — operator action.** Schedule/limit concurrent ollama models so
  GPU load does not starve the network stack: shorter keep-alive, fewer simultaneous
  ~25 GB residents, stagger heavy jobs vs. allocator-dependent factory windows.
- **T3 — infra, optional.** If T1+T2 prove insufficient: isolate the allocator Redis
  from GPU workload — dedicated small always-up container and/or cgroup/priority
  guarantees for its network path.

## 4. Explicit NON-actions

- Do NOT change the allocator host/port/key — ADR-143-A stands as ratified.
- Do NOT use `BANXE_IL_ALLOCATOR=local` — the local fallback remains forbidden
  (IL-827 duplicate precedent; fail-closed is the contract).
- Do NOT touch quarantined midaz-ledger/mongodb (ADR-QUARANTINE-MIDAZ-EVO1) —
  unrelated to the allocator and out of scope here.

## 5. Cross-refs

- ADR-143-A — shared evo1 Redis IL allocator (canon; unchanged).
- ADR-QUARANTINE-MIDAZ-EVO1 — midaz quarantine (unrelated, explicitly out of scope).
- ADR-105 — three-node fabric context (evo1 role).
- Incident context: factory STOPs 2026-08-01 (org-contour builder shard step;
  impact-org-overlay-impl Task 3) — both resolved on allocator recovery.
