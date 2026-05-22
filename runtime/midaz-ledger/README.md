# midaz-ledger runtime

## Purpose
Unified ledger component (`lerianstudio/midaz-ledger:latest`). Hot-fix runtime on Legion.
HTTP API on 127.0.0.1:8095. Consumes RabbitMQ events.

## Root cause (R1 blocker, resolved 2026-05-22)
RABBITMQ_HEALTH_CHECK_URL must be BASE URL only, not full path.
- Correct:   RABBITMQ_HEALTH_CHECK_URL=http://midaz-rabbitmq:15672
- Incorrect: RABBITMQ_HEALTH_CHECK_URL=http://midaz-rabbitmq:15672/api/health/checks/alarms
midaz appends /api/health/checks/alarms internally. Full path = malformed URL = 3ms FATAL.

## Boot command
docker run -d --name midaz-ledger --network midaz-network --restart unless-stopped \
  -p 127.0.0.1:8095:3002 --env-file runtime/midaz-ledger/env.live \
  lerianstudio/midaz-ledger:latest

env.live is gitignored. Build from env.example by filling REPLACE_ME values.

## Health verification
docker ps --filter name=midaz-ledger --format '{{.Names}} {{.Status}}'
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8095/health
Expected: Up X minutes; HTTP 200.

## Known operational warnings (non-blocking)
Consumer logs: 404 NOT_FOUND - no previously declared queue (exponential backoff).
Expected until queues are declared. Tracked separately.

## Dependencies (all in midaz-network)
- banxe-redis 172.20.0.3
- midaz-postgres 172.20.0.5
- midaz-mongodb 172.20.0.2
- midaz-rabbitmq 172.20.0.4 (RabbitMQ 4.1.3 + management plugin)

## See also
- docs/runbooks/R1-MIDAZ-LEDGER-BOOTSTRAP-2026-05-22.md
- INSTRUCTION-LEDGER.md (IL-OPS-R1-MIDAZ-LEDGER-BLOCKER-RESOLVED-2026-05-22)
- docs/canon/UNIVERSAL-CANON-2026-05-22.md section 13 item R1
