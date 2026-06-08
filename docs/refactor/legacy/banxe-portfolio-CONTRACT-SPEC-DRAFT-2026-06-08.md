# banxe-portfolio CONTRACT SPEC — DRAFT

- Family: portfolio-contract
- Target: CarmiBanxe/banxe-portfolio
- Scope: src/**
- Status: DRAFT (not buildable; repo does NOT exist yet — 404 as of 2026-06-08)

Date: 2026-06-08
Source: crypto-ops-subgroup-SPEC-2026-05-25.md (parent SPEC #7); ADR-050 Option B
NEW capability: C7 portfolio analytics
Related: ADR-050 (delivery model + Q1/Q4 resolutions); ADR-019 (GraphQL drop); ADR-054 (C7 analytics mask)
Verified repo: CarmiBanxe/banxe-portfolio DOES NOT EXIST (404, 2026-06-08)

## Purpose

Define the contract for banxe-portfolio as a standalone Python FastAPI portfolio analytics service. Rewrites legacy crypto-api-portfolio (TypeScript NestJS + TypeORM + GraphQL) into Python with numeric-native tooling (Decimal, pandas, SQLAlchemy). Split from crypto-ops-subgroup per ADR-050 Option B.

## Domain boundary

- IN scope: portfolio value calculation, time-series history (1h/1d/7d/30d windows), holdings aggregation, rate conversion (Decimal-only, never float), audit trail per value snapshot.
- OUT of scope: RPC blockchain operations (crypto-ops-monitor), news (banxe-news), order execution (ExchangePort), wallet key management (WalletPort).

## Contract ports

### Provided (this service exposes)

- **PortfolioAPI** (REST, pydantic models — no GraphQL per ADR-019):
  - `GET /portfolio/{userId}/value` → current portfolio value (Decimal)
  - `GET /portfolio/{userId}/history?window={1h|1d|7d|30d}` → time-series snapshots
  - `GET /portfolio/{userId}/holdings` → per-asset breakdown

### Consumed (this service depends on)

- ExchangePort.getRate() — current asset rates for value calculation.
- WalletPort — holdings data (balances per chain/address).
- guardian_audit_events — every value snapshot persisted (R-COMP-FCA-04).

## Key constraints

- Python 3.12+ / FastAPI / SQLAlchemy + Alembic.
- Decimal ONLY for all monetary values (I-01, never float).
- Drop GraphQL coupling (ADR-019); REST with pydantic models.
- Separate Python container deployment (ADR-050 Q1 resolution).
- Hand-rolled SQLAlchemy schema initially (ADR-050 Q4 resolution).
- Audit: every value snapshot → guardian_audit_events with correlationId (R-COMP-FCA-04).

## Conformance requirements

1. Portfolio value calculation matches legacy crypto-api-portfolio on deterministic test vectors (zero-mismatch on 1h/1d/7d/30d windows).
2. All monetary values use Decimal; zero float usage in codebase.
3. Every API response includes correlationId.
4. Every value snapshot emits one audit event.
5. Parity tests vs legacy pass before Phase E cut-over.

## Blockers

- **Repo does not exist.** CarmiBanxe/banxe-portfolio returns 404 as of 2026-06-08. Repo creation is a prerequisite for promotion from DRAFT to PROPOSED. Path/SHA NOT fabricated (I-28).

## References

- crypto-ops-subgroup-SPEC-2026-05-25.md (parent SPEC #7)
- ADR-050 (delivery model Option B, Q1 + Q4 resolutions)
- ADR-019 (GraphQL → REST migration)
- ADR-054 (C7 analytics/reporting client-facing mask)
- RISK_REGISTER R-MIG-LANG-01 (TS→Python), R-COMP-FCA-04 (portfolio audit)
