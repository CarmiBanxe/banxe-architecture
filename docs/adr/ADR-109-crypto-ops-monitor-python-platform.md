# ADR-109: crypto-ops-monitor = Python Crypto-Accounting Platform (supersedes NestJS CONTRACT-SPEC)

**Status:** PROPOSED
**Date:** 2026-06-19
**Supersedes:** crypto-ops-monitor-CONTRACT-SPEC-DRAFT-2026-06-08 (NestJS RPC-gateway, never built)
**Updates:** ADR-050 domain boundary

## Context
CONTRACT-SPEC-DRAFT (2026-06-08) defined crypto-ops-monitor as NestJS multi-chain RPC gateway. Runtime audit (2026-06-19) of ~/crypto-ops-monitor shows it is a PYTHON project (pyproject.toml, no package.json): FastAPI/SQLAlchemy/Alembic/Celery Crypto Assets Monitoring Foundation (18 entities, ~40 endpoints, BTC/ETH/Polygon/BSC connectors, Kraken/Binance, fiat/Xero, classification, frozen reports, travel rule, RBAC, dual control, append-only). The spec is STALE vs reality.

## Decision
- crypto-ops-monitor IS a Python/FastAPI crypto-accounting + reconciliation platform (code = source of truth).
- The NestJS RPC-gateway CONTRACT-SPEC-DRAFT is marked SUPERSEDED (not buildable, never reflected reality).
- ADR-050 domain boundary updated: RPC-gateway getRate() for ExchangePort is a SEPARATE concern (open-item: keep standalone service OR fold into banxe-trading-backend per ADR-021), NOT part of crypto-ops-monitor.
- crypto-ops-monitor scope: wallet registry, ingestion, canonical tx, balance snapshots, reconciliation, fiat valuation, Xero postings, travel-rule records.

## Compliance
- Travel Rule (ADR-036): TravelRuleRecord entity present; crypto go-live gated per ADR-036 (provider or MLRO manual).
- Append-only + RBAC + dual control + ClickHouse audit consistent with I-24 audit invariants.

## Consequences
- Positive: documentation aligned to real production-near code (52 tests, RBAC); no destructive rewrite.
- Negative/residual: production-readiness gaps remain (SP-CO2, separate repo): live RPC wiring, DB bootstrap (cryptonetworks table), ruff/mypy/pytest green, CI gate, smoke run.

## Related
- ADR-050 (delivery model, boundary updated), ADR-021 (ExchangePort), ADR-036 (Travel Rule). CONTRACT-SPEC-DRAFT-2026-06-08 (SUPERSEDED). GAP-065 (new).
