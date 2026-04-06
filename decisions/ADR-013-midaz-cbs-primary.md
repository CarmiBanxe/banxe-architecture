# ADR-013 — Midaz CBS: PRIMARY Core Banking System

**Status:** ACCEPTED  
**Date:** 2026-04-06  
**Deciders:** CEO (Moriel Carmi), CTIO  
**Sprint:** 8 BLOCK-A

## Context

BANXE required a GL-capable Core Banking System for FCA authorisation. Evaluated:
- Midaz v3.5.3 (LerianStudio) — Apache 2.0, unified ledger (onboarding + transaction)
- Apache Fineract — Java, heavier, 5+ containers

## Decision

**Midaz v3.5.3** is PRIMARY CBS. Fineract remains FALLBACK (not deployed).

Architecture: Variant 2 (lightweight) — reuses existing PostgreSQL 17 and Redis, adds 3 containers (MongoDB, RabbitMQ, Midaz Ledger).

## Deployment (GMKtec 2026-04-06)

| Service | Port | Status |
|---------|------|--------|
| midaz-ledger | 8095 | ✅ healthy |
| midaz-mongodb | 5703 | ✅ healthy |
| midaz-rabbitmq | 3003/3004 | ✅ healthy |

First organization created: BANXE LTD (`019d6301-32d7-70a1-bc77-0a05379ee510`)

## Safeguarding Accounts (Block J — FCA CASS 7, EMR 2011 Reg.19)

Created 2026-04-06. **Deadline: 7 May 2026**.

| Entity | ID |
|--------|-----|
| Organization | `019d6301-32d7-70a1-bc77-0a05379ee510` (BANXE LTD) |
| Safeguarding Ledger | `019d632f-519e-7865-8a30-3c33991bba9c` |
| Asset | GBP `019d632f-7c06-75e0-9a49-8249da13f609` |
| client_funds account | `019d6332-da7f-752f-b9fd-fa1c6fc777ec` (liability, CASS 7.13) |
| operational account | `019d6332-f274-709a-b3a7-983bc8745886` (asset, CASS 7.14) |

Pending (Sprint 9): reconciliation engine linking these accounts to external bank statements.

## DEF-002 Resolution — Healthcheck

`lerianstudio/midaz-ledger:latest` uses `distroless/static-debian12` — no shell, no curl.  
`healthcheck: disable: true` + external cron (`/usr/local/bin/midaz-healthcheck.sh`, every 2min).  
API verified: `curl http://127.0.0.1:8095/health → "healthy"`.

## Consequences

- LedgerPort ABC (`ports/ledger_port.py`) enables future CBS swap without compliance code changes
- Next: reconciliation engine (Block D-recon, Sprint 9)
- Block J Phase 1 COMPLETE: safeguarding ledger + GBP asset + 2 accounts created

## Invariants Affected

- I-10: No fake integrations — Midaz is real, receiving live API calls
- I-18: Port isolation — :8095 reserved for Midaz
