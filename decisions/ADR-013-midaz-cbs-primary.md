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

## Consequences

- LedgerPort ABC (`ports/ledger_port.py`) enables future CBS swap without compliance code changes
- Next: reconciliation engine (Block D-recon, Sprint 9)
- P0: Safeguarding accounts must be configured in Midaz (Block J, deadline 7 May 2026)

## Invariants Affected

- I-10: No fake integrations — Midaz is real, receiving live API calls
- I-18: Port isolation — :8095 reserved for Midaz
