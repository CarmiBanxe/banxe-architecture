# banxe-news CONTRACT SPEC — DRAFT

- Family: news-contract
- Target: CarmiBanxe/banxe-news
- Scope: src/**
- Status: DRAFT (not buildable; repo does NOT exist yet — 404 as of 2026-06-08)

Date: 2026-06-08
Source: crypto-ops-subgroup-SPEC-2026-05-25.md (parent SPEC #7); ADR-050 Option B
NEW capability: content aggregation (supporting C6 trading UX)
Related: ADR-050 (delivery model + Q3 resolution); ADR-017 (vendor-to-OSS)
Verified repo: CarmiBanxe/banxe-news DOES NOT EXIST (404, 2026-06-08)

## Purpose

Define the contract for banxe-news as a standalone news aggregator service. Transforms legacy crypto-api-news (TypeScript NestJS, misnamed "files-api") into a clean standalone service with FCA financial-promotions compliance. Split from crypto-ops-subgroup per ADR-050 Option B.

## Domain boundary

- IN scope: news feed aggregation, source management, content tagging (promotionStatus), FCA financial-promotions compliance gate, content caching.
- OUT of scope: portfolio analytics (banxe-portfolio), RPC operations (crypto-ops-monitor), trading execution (ExchangePort), any user-generated content.

## Contract ports

### Provided (this service exposes)

- **NewsAPI** (REST):
  - `GET /news/feed?category={crypto|market|regulatory}&limit=N` → news items
  - `GET /news/{id}` → single item with full content + promotionStatus
  - Each news item carries: `promotionStatus` (approved | pending | rejected), `source`, `publishedAt`, `categories[]`

### Consumed (this service depends on)

- External news sources (RSS/API feeds — configured via allowed-sources whitelist).
- Compliance-approved sources whitelist (managed by Compliance team, ADR-050 Q3 resolution).

## Key constraints

- NestJS 10+ / Node 18+.
- Fix package.json name from "files-api" to "banxe-news".
- Drop PM2 (ecosystem.config.js) for systemd unit.
- FCA financial-promotions compliance REQUIRED (ADR-050 Q3 resolution):
  - All content tagged with `promotionStatus`.
  - Unapproved content (pending/rejected) MUST NOT be displayed to UK retail users.
  - Sources whitelist maintained by Compliance + Legal.
- Minimise vendor coupling in aggregator logic.

## Conformance requirements

1. All news items carry a valid promotionStatus field.
2. GET /news/feed with default params returns only promotionStatus=approved items.
3. Unapproved content never appears in user-facing responses (filter enforced server-side).
4. Sources whitelist is config-driven (not hard-coded).
5. Parity tests vs legacy crypto-api-news aggregation logic pass before Phase E cut-over.

## Blockers

- **Repo does not exist.** CarmiBanxe/banxe-news returns 404 as of 2026-06-08. Repo creation is a prerequisite for promotion from DRAFT to PROPOSED. Path/SHA NOT fabricated (I-28).

## References

- crypto-ops-subgroup-SPEC-2026-05-25.md (parent SPEC #7)
- ADR-050 (delivery model Option B, Q3 resolution — FCA financial-promotions)
- ADR-017 (vendor-to-OSS policy)
- RISK_REGISTER R-MIG-02 (legacy on evo1)
