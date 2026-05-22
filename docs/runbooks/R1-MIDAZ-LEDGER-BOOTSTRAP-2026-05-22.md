# R1 — midaz-ledger bootstrap recovery (2026-05-22)

## Status
RESOLVED. Container Up; HTTP /health returns 200.

## Symptom
midaz-ledger in restart loop. FATAL on rabbitmq.go:63 "RabbitMQ.HealthCheck: can't connect rabbitmq".

## Diagnostic chain (factual)
1. Postgres connect OK (no new migrations).
2. MongoDB connect OK; 4 indexes ensured (operation, transaction, operation_route, transaction_route).
3. Redis OK after switch to banxe-redis:6379 (STANDALONE mode).
4. midaz-rabbitmq container Up 10h; ports 5672 + 15672 exposed (host 3004 + 3003).
5. midaz-network contains banxe-redis, midaz-postgres, midaz-mongodb, midaz-rabbitmq.
6. rabbitmq-diagnostics status OK; management plugin enabled.
7. User midaz has [administrator] tag.
8. vhost / exists; user permissions: configure=.* write=.* read=.*.
9. curl -u midaz:midaz_rmq_2026 http://127.0.0.1:3003/api/health/checks/alarms -> 200.
10. midaz-ledger env (docker inspect) contains all RABBITMQ_* vars correctly.
11. RABBITMQ_URI=amqp (bare) is correct - midaz uses it as scheme prefix.
12. Full URL in RABBITMQ_URI broke primary connect (no such host: midaz-rabbitmq:5672).
13. curl from peer container in midaz-network to http://midaz-rabbitmq:15672/api/health/checks/alarms -> 200.
14. strings on /app binary revealed env tag env:"RABBITMQ_HEALTH_CHECK_URL".
15. No env flag to disable health check exists.
16. Hypothesis: midaz appends /api/health/checks/alarms internally.
17. Fix: RABBITMQ_HEALTH_CHECK_URL=http://midaz-rabbitmq:15672 (base URL only).
18. Container Up 10+ minutes after fix; no restart loop.
19. curl http://127.0.0.1:8095/health -> 200 in 1.2ms.

## Root cause
midaz Go client appends /api/health/checks/alarms to RABBITMQ_HEALTH_CHECK_URL.
A full-path URL becomes /api/health/checks/alarms/api/health/checks/alarms -> malformed -> 3ms FATAL.

## Fix
runtime/midaz-ledger/env.live: RABBITMQ_HEALTH_CHECK_URL=http://midaz-rabbitmq:15672

## Verification
- docker ps: midaz-ledger Up
- curl http://127.0.0.1:8095/health -> 200 (1.2ms)

## Next-tracked
Declare missing RabbitMQ queues (RABBITMQ_BALANCE_CREATE_QUEUE, RABBITMQ_TRANSACTION_BALANCE_OPERATION_QUEUEE, RABBITMQ_AUDIT_EXCHANGE).
Not blocking; consumer retries with exponential backoff.

## Refs
- runtime/midaz-ledger/env.example
- runtime/midaz-ledger/env.live (gitignored)
- runtime/midaz-ledger/README.md
- INSTRUCTION-LEDGER.md (IL-OPS-R1-MIDAZ-LEDGER-BLOCKER-RESOLVED-2026-05-22)
