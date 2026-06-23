---
il_ts: 2026-06-23T19:36:00Z
session_id: agent-factory-ops-s-fac-61-evo1-stabilize
source: CEO
status: PARTIAL
---
### S-FAC-61 (R1) evo1 stabilization — OPS RECORD of 4 runtime fixes (DoD PARTIAL: functional GREEN, 24h observation pending)
- **Date:** 2026-06-23 · **Type:** OPS record (ledger-only). **Fixes were applied at RUNTIME on the evo1 host (infra), NOT repo code.** This shard records the FACT; it changes no service/repo behavior.
- **Decision:** Record the four root-cause fixes that took evo1 `midaz-ledger`, `workflow-service`, `midaz-mongodb`, `ballerine-postgres` from RED (RESTARTING/unhealthy) to functional GREEN. DoD ("Up/healthy ≥24h") = **PARTIAL** — RECOVERED, under 24h observation.
- **Basis (audit):** live shell ops @ evo1 2026-06-23 ~19:32 UTC (not memory).
- **Root causes fixed (runtime, host-side):**
  1. **workflow-service P1001** — `ballerine-postgres` was Exited (restart=no); started it → `workflow-service` now Up, P1001 gone.
  2. **midaz redis REFUSED** — midaz expects Redis at host-gateway `172.22.0.1:6379`, but host redis (`jube-src` redis-stack) binds only `127.0.0.1:16379`. Fix: new **`midaz-redis-bridge`** container publishing redis on `172.22.0.1:6379` (jube redis untouched) → `midaz-ledger` redis OK.
  3. **midaz-mongodb unhealthy** — `--keyFile /etc/mongo/keyfile` "bad file": host keyfile owned `banxe:banxe` mode 400, unreadable by container uid 999. Fix: `chown 999:999` via throwaway root container (no sudo), mode 400 kept → mongo healthy; `mongo-init` ran `rs.initiate(rs0)` Exited(0).
  4. **midaz-ledger** — `depends_on` mongo `service_healthy`; came Up after (2)+(3).
- **Proof (post-warmup probe):** `midaz-mongodb` running(healthy) restarts=0; `ballerine-postgres` running(healthy) restarts=0; `midaz-redis-bridge` running restarts=0; `midaz-ledger` + `workflow-service` running, fresh logs CLEAN (no redis/mongo errors in last 60s). High `RestartCount` values are HISTORICAL (months-long pre-fix loop), not current.
- **Follow-up (flagged):** `midaz-redis-bridge` is a **stopgap** — fold midaz redis access into the midaz compose properly (dedicated redis service or correct host-gateway publish) so stabilization survives host restart without the bridge. Owner: later S-FAC-61/64 hardening. Also: persist these runtime fixes as declarative compose/config (currently host-only → reboot-fragile).
- **Canon compliance:** live-audit source of truth; OPS record only (no repo code/protection mutation); best-solution; minimal-diff; append-only ledger (ADR-119 frozen IL via IL-SEQUENCE.json, max+1); branch ADR-060-compliant (`agent/factory/ops/s-fac-61-evo1-stabilize`); no S320; hooks enabled (no `--no-verify`/`--admin`/bypass); STOP before merge for operator.
- **Coupling/append-only:** branch off origin/main@4c9904f; single new shard; no prior entry modified.
- **Proof (ledger):** `build_ledger.py --check` exit 0; guardian-ledger / ledger-append-only / guardian-ledger-shards / guardian-branch-naming green (local); squash PR to main (merge-queue); operator merges.
- **Refs:** `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §S-FAC-61 (R1); evo1 host-side `docker-compose.midaz.yml` (runtime artifact, not in this repo); `runtime/midaz-ledger/` (repo anchor); ADR-119; ADR-060.
