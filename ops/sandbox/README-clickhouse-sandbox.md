# SANDBOX ClickHouse — runbook (STEP5, ENGREF01)

> ⚠ SANDBOX / TRAINING — NOT FOR PRODUCTION. BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false.

## Purpose
Isolated sandbox ClickHouse carrying `banxe_audit.hitl_decisions` with the engine-ref schema
(14 canonical + 8 lineage columns) for the STEP4 sandbox contour (compliance-gate, agent decision lineage).

## Isolation guarantees
- Dedicated named volume **banxe_clickhouse_sandbox_data** — never reuses `docker_clickhouse_data`
  (foreign volume of a prior project; do not touch), never shares state with `banxe-clickhouse` /
  `fu2-clickhouse-*` containers (left untouched, Exited).
- Ports bound to **127.0.0.1 only** (8123 HTTP, 9000 native) — not exposed externally.
- Credentials live in `ops/sandbox/.ch-sandbox.env` (gitignored). User: `banxe_sandbox`.

## Operate
```bash
# up / wait healthy
docker compose -f ops/sandbox/clickhouse-sandbox.compose.yml up -d
docker inspect -f '{{.State.Health.Status}}' banxe-clickhouse-sandbox

# apply schema (from repo root; reads password from env file)
set -a; . ops/sandbox/.ch-sandbox.env; set +a
docker exec -i banxe-clickhouse-sandbox clickhouse-client --user banxe_sandbox --password "$CLICKHOUSE_PASSWORD" --multiquery < ops/sandbox/create-hitl-decisions-sandbox-ch24.8.sql  # sandbox-adapted TTL (see file footer)
docker exec -i banxe-clickhouse-sandbox clickhouse-client --user banxe_sandbox --password "$CLICKHOUSE_PASSWORD" --multiquery < sql/alter-banxe-audit-hitl-decisions-engine-ref-2026-07-26.sql

# verify
docker exec banxe-clickhouse-sandbox clickhouse-client --user banxe_sandbox --password "$CLICKHOUSE_PASSWORD" -q "DESCRIBE TABLE banxe_audit.hitl_decisions"

# down (data persists in the named volume)
docker compose -f ops/sandbox/clickhouse-sandbox.compose.yml down
```

## PROD contract
This instance never graduates to prod. Prod schema application = separate operator-gated change-set on the
prod cluster per ADR-171 §PROD-CUTOVER CONTRACT (purge TRAINING first; TRAINING rows blocked from prod).
