# Runbook — PA-1 midaz-ledger Postgres provisioning + bind fix

| Field | Value |
|---|---|
| Sprint | IL-PROJECT-AUDIT-01 (PR #58) |
| Scope | Provision midaz_onboarding + midaz_transaction databases on host postgres@16-main; reconfigure listen_addresses + pg_hba.conf for docker bridge access; correct DB_PORT in midaz compose (5432→5433) |
| Target node | evo1 (banxe-NucBox-EVO-X2) |
| Risk | MEDIUM — touches host postgres@16-main config (used also by banxe_compliance / banxe_db); requires `systemctl reload postgresql@16-main`; also touches midaz-ledger compose env. |
| Reversibility | HIGH (config changes are idempotent + revertible; created DBs/role can be dropped). |
| Approval required | YES — production-state mutation per CLAUDE.md §11; explicit operator `go` per phase below. |

## Root cause (per PA-1a..PA-1e discovery)

`midaz-ledger` distroless container (`lerianstudio/midaz-ledger:latest`, entrypoint `/app`) is in restart loop (RestartCount=6051; runtime ~5.3 sec each; ExitCode=1; OOMKilled=false; logs only show `VERSION: NO-VERSION / Skipping .env file, using env local` then silent exit).

Container expects:
- DB_ONBOARDING_HOST = `172.22.0.1` (docker bridge gateway, host-side)
- DB_ONBOARDING_PORT = `5432`
- DB_TRANSACTION_HOST = `172.22.0.1`, DB_TRANSACTION_PORT = `5432`
- midaz_onboarding + midaz_transaction databases reachable via user `midaz_app` with password `${DB_PASSWORD}` (length 13, lower+digit+symbol; stored only in `/data/banxe/midaz/.env`).

Reality on evo1:
- PostgreSQL 16 cluster `16-main` running, owner=postgres, listening on `127.0.0.1:5433` (NOT `:5432` as midaz expects).
- `listen_addresses` excludes docker bridge `172.22.0.1` — only localhost.
- Database `midaz_onboarding` does NOT exist; `midaz_transaction` does NOT exist; role `midaz_app` does NOT exist. Only `banxe`, `banxe_app_role`, `postgres` roles; only `postgres`, `banxe_compliance`, `banxe_db` user databases.
- midaz-mongodb and midaz-rabbitmq are healthy (not the cause).

Conclusion: midaz-ledger needs three coordinated changes — (1) DBs + role provisioning on host postgres, (2) postgres bind/auth config to allow docker bridge access, (3) midaz compose DB_PORT fix from 5432 to 5433.

**Note (post-discovery):** Actual PA-1 fix was `docker start redis` — redis container had been stopped (SIGTERM 4 days ago). This runbook documents the Postgres provisioning path (Variant A) which was fully analysed but superseded by the redis fix. Retained as reference in case a fresh evo1 deployment or DR scenario requires Postgres re-provisioning.

## Provisioning steps (each gated on operator `go`)

### Phase A — Backup current postgres state (read-only-equivalent)

```bash
ssh evo1 'sudo -u postgres pg_dumpall -p 5433 -f /data/banxe/midaz/backup-pre-pa-01-$(date +%Y%m%d-%H%M%S).sql && ls -lh /data/banxe/midaz/backup-pre-pa-01-*.sql | tail -1'
```

Acceptance: backup file created, size > 0.

### Phase B — Create role + databases (operator `go` required)

```bash
ssh evo1 'sudo -u postgres psql -p 5433 -v ON_ERROR_STOP=1 <<SQL
CREATE ROLE midaz_app WITH LOGIN PASSWORD '"'"'<DB_PASSWORD from .env>'"'"';
CREATE DATABASE midaz_onboarding OWNER midaz_app;
CREATE DATABASE midaz_transaction OWNER midaz_app;
GRANT ALL PRIVILEGES ON DATABASE midaz_onboarding TO midaz_app;
GRANT ALL PRIVILEGES ON DATABASE midaz_transaction TO midaz_app;
SQL'
```

Note: substitute `<DB_PASSWORD from .env>` by reading `/data/banxe/midaz/.env` manually; never echo the value to shell history.

Acceptance:
```bash
ssh evo1 "sudo -u postgres psql -p 5433 -lqt | grep -E 'midaz_(onboarding|transaction)'"
ssh evo1 "sudo -u postgres psql -p 5433 -c '\du midaz_app'"
```
Both should return non-empty rows.

### Phase C — Configure postgres listen_addresses + pg_hba (operator `go` required)

Edit `/etc/postgresql/16/main/postgresql.conf` — backup first, then change `listen_addresses`:
```bash
ssh evo1 "sudo cp /etc/postgresql/16/main/postgresql.conf /etc/postgresql/16/main/postgresql.conf.bak-$(date +%Y%m%d-%H%M%S)"
ssh evo1 "sudo cp /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.bak-$(date +%Y%m%d-%H%M%S)"
```

Set `listen_addresses = 'localhost,172.22.0.1'` in postgresql.conf.

Add to pg_hba.conf (BEFORE the IPv4 catch-all line):
```
# midaz docker bridge (PA-1 IL-PROJECT-AUDIT-01)
host    midaz_onboarding   midaz_app   172.22.0.0/16   scram-sha-256
host    midaz_transaction  midaz_app   172.22.0.0/16   scram-sha-256
```

Reload:
```bash
ssh evo1 'sudo systemctl reload postgresql@16-main'
```

Acceptance:
```bash
ssh evo1 'ss -tln | grep 5433'
```
Must show both `127.0.0.1:5433` AND `172.22.0.1:5433` in LISTEN state.

### Phase D — Update midaz compose DB_PORT (operator `go` required)

Edit `/data/banxe/midaz/docker-compose.midaz.yml` — change ledger service env values:
```yaml
DB_ONBOARDING_PORT: "5433"
DB_TRANSACTION_PORT: "5433"
```
(replace existing `"5432"` for both fields; compose values override .env so must be edited in compose directly).

### Phase E — Restart midaz-ledger (operator `go` required)

```bash
ssh evo1 'cd /data/banxe/midaz && sudo docker compose -f docker-compose.midaz.yml up -d --force-recreate midaz-ledger'
```

Wait 60 seconds then verify:
```bash
ssh evo1 'docker logs midaz-ledger --tail 50 2>&1'
ssh evo1 'docker inspect midaz-ledger --format "{{.State.Status}} restarts={{.RestartCount}}"'
ssh evo1 'curl -fsS http://127.0.0.1:8095/health 2>&1 | head -3'
```

Acceptance: Status="running"; RestartCount stable for 60+ sec; /health returns 200; logs show successful DB connect.

### Phase F — Smoke test LedgerPort invariant I-28 (operator `go` required)

```bash
curl -fsS http://127.0.0.1:8095/v1/organizations 2>&1 | head -5
```

Should return 200 (empty list — DBs are freshly provisioned). If 500 with `relation "organizations" does not exist` → midaz migrations needed. Run migration command per midaz docs or `docker exec midaz-ledger /app --migrate` (check entrypoint). If unclear, STOP and open follow-up gap.

## Rollback plan

Restore Phase B (drop midaz role + DBs):
```bash
ssh evo1 'sudo -u postgres psql -p 5433 -c "DROP DATABASE IF EXISTS midaz_onboarding;"'
ssh evo1 'sudo -u postgres psql -p 5433 -c "DROP DATABASE IF EXISTS midaz_transaction;"'
ssh evo1 'sudo -u postgres psql -p 5433 -c "DROP ROLE IF EXISTS midaz_app;"'
```

Restore Phase C config:
```bash
ssh evo1 'sudo cp /etc/postgresql/16/main/postgresql.conf.bak-<timestamp> /etc/postgresql/16/main/postgresql.conf'
ssh evo1 'sudo cp /etc/postgresql/16/main/pg_hba.conf.bak-<timestamp> /etc/postgresql/16/main/pg_hba.conf'
ssh evo1 'sudo systemctl reload postgresql@16-main'
```

Revert Phase D compose edit via git in /data/banxe/midaz/ if tracked, else manual revert.

Stop midaz-ledger if needed:
```bash
ssh evo1 'cd /data/banxe/midaz && docker compose -f docker-compose.midaz.yml stop midaz-ledger'
```

Restore from Phase A backup if required:
```bash
ssh evo1 'sudo -u postgres psql -p 5433 -f /data/banxe/midaz/backup-pre-pa-01-<timestamp>.sql'
```

## Anchors

- IL-PROJECT-AUDIT-01 (PR #58) — sprint kickoff
- PA-1a..PA-1e discovery (2026-05-05 21:41-21:52 UTC)
- ADR-013 — Midaz primary CBS, I-28 LedgerPort invariant
- IL-001..IL-007 — historical Midaz integration work (IL-002 safeguarding, IL-003 LedgerPort)
- docs/canon/operator-canon-2026-05.md — Principle 1 (Hardware-first), Principle 2 (evo1 as-is)
- safety-rules.md — destructive operation gate
- CLAUDE.md §11 — production-state mutation gate
- IL-PA-01-CLOSE — actual PA-1 fix (docker start redis; this runbook = Variant A, not executed)

## Architectural alternative (Variant B, not chosen for PA-1)

Containerized midaz-postgres in midaz-network instead of using host postgres@16-main. Benefits: isolation, easier backup/restore. Costs: ~50-100 MB extra RAM, new compose service, separate volume management. Deferred to future ADR if isolation becomes a compliance requirement.

## Status

| Date | Status | Note |
|---|---|---|
| 2026-05-05 | DRAFT (superseded) | Runbook drafted post PA-1e discovery; actual fix = `docker start redis` (IL-PA-01-CLOSE). Variant A retained as DR / fresh-deploy reference. |
