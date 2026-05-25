# Refactor SPEC — crypto-ops sub-group consolidation (final)

Date: 2026-05-25
Status: SPEC (design baseline; impl owned by Terminal B per House rule 10)
Scope: crypto-api-rpc + crypto-api-portfolio + crypto-api-news -> crypto-ops-monitor + banxe-portfolio (FastAPI) + banxe-news
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/ on evo1
Related: ADR-019 GraphQL migration; ADR-017 vendor-to-os; CLASS_KEEP.tsv KEEP-EXTRACT rows; SPEC #1 crypto-api-keys-lib (WalletPort dep for RPC chain coverage)
Owner: Central authors SPEC; Terminal B owns impl

## Purpose

Specify smart refactor of the final three KEEP-EXTRACT legacy crypto services into three NEW components: a multi-chain RPC ops gateway (crypto-ops-monitor), a Python FastAPI portfolio analytics service (banxe-portfolio), and a standalone news aggregator (banxe-news). This is SPEC #7 of 7; it completes 24/24 KEEP-row coverage from CLASS_KEEP.tsv and closes Phase A inventory for the full BANXE.RAR refactor under the Transform-first canon.

## Legacy inventory (read-only audit 2026-05-25)

### 1. crypto-api/crypto-api-rpc (multi-chain RPC gateway)

- Path: crypto-api/crypto-api-rpc
- Lang: TypeScript NestJS
- Size: 1.8 MB
- Pkg: rpc-api v0.7.3, MIT license (more mature version than v0.0.1 of others)
- Has Dockerfile + docker-compose + ecosystem.config.js (PM2 process manager)
- Per-chain READMEs: README.BCH.md, README.BITCOIN.md, README.BSV.md (multi-chain documentation)
- Git history active: erc20 filtering improvements; ethers IP node check; pending tx filtering
- Role: blockchain RPC abstraction layer (multi-chain pool, error handling, health monitoring)
- Reuse target: TRANSFORM into crypto-ops-monitor (NEW operational gateway)

### 2. crypto-api/crypto-api-portfolio (portfolio analytics)

- Path: crypto-api/crypto-api-portfolio
- Lang: TypeScript NestJS + TypeORM (ormconfig.js)
- Size: 1.1 MB
- Pkg: crypto-api-portfolio v0.0.1
- Has schema.graphql (GraphQL coupling) + portfolio.txt (likely sample data)
- Has ecosystem.config.js (PM2)
- Git history: 15-minute graph step seconds; first-point graph fix; bignumber rate convert
- Role: portfolio value/history calculation (time-series math, big numbers)
- Reuse target: TRANSFORM-REWRITE into Python FastAPI banxe-portfolio (numeric-heavy domain better in Python)

### 3. crypto-api/crypto-api-news (news aggregator)

- Path: crypto-api/crypto-api-news
- Lang: TypeScript NestJS
- Size: 868 KB (smallest)
- Pkg: name typo "files-api" v0.0.1 (copy-paste bug from boilerplate)
- Has ecosystem.config.js (PM2)
- Git history: settings fixes; eslint formatting alignment; template fitting
- Role: news aggregator / feed
- Reuse target: TRANSFORM into standalone banxe-news; fix package name typo

## Decision per service

### crypto-api-rpc: TRANSFORM-INTO-crypto-ops-monitor
- Base for NEW crypto-ops-monitor (operational gateway for blockchain RPC pool).
- Keep multi-chain abstraction; modernise to NestJS 10 + Node 18+.
- Replace ethers v5 (legacy) with viem 2.x (aligned with SPEC #1 EVM dep choice).
- Drop ecosystem.config.js (PM2) for systemd unit (production parity).
- Wire to NEW WalletPort chain coverage (5-6 chains from SPEC #1) — RPC pool only serves chains that WalletPort supports.
- Expose health endpoints + Prometheus metrics for R3 observability foundation.

### crypto-api-portfolio: TRANSFORM-REWRITE-PYTHON
- Rewrite from NestJS TypeScript to Python FastAPI (per CLASS_KEEP.tsv guidance).
- Reasons: portfolio analytics is numeric-heavy (Decimal, time-series, bignumber math); Python with pandas + numpy + decimal handles this natively.
- Drop GraphQL coupling per ADR-019; expose REST with pydantic models.
- Keep TypeORM schema as reference; migrate to SQLAlchemy + Alembic in NEW.
- Output: banxe-portfolio (FastAPI on Python 3.12+).
- Wire to ExchangePort (SPEC #4) for current rates and to WalletPort (SPEC #1) for holdings.

### crypto-api-news: TRANSFORM
- Base for NEW standalone banxe-news (NestJS 10 + Node 18+).
- Fix package.json name typo "files-api" -> "banxe-news".
- Keep aggregator logic; minimise vendor coupling.
- Drop ecosystem.config.js (PM2) for systemd unit.

## Legacy to NEW mapping

| Legacy | NEW location | Verdict |
|---|---|---|
| crypto-api-rpc | crypto-ops-monitor standalone NEW repo | TRANSFORM |
| crypto-api-portfolio | banxe-portfolio (Python FastAPI) | TRANSFORM-REWRITE |
| crypto-api-news | banxe-news standalone NEW repo | TRANSFORM |

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + decisions (this SPEC).
- Phase B (Terminal B): scaffold 3 NEW repos (crypto-ops-monitor NestJS, banxe-portfolio Python FastAPI, banxe-news NestJS).
- Phase C (Terminal B): implement crypto-ops-monitor multi-chain RPC pool; rewrite portfolio analytics in Python FastAPI; port news aggregator.
- Phase D (Terminal B): shadow-mode rate quotes (RPC pool) and portfolio history vs legacy for 14 days; zero-mismatch on deterministic ops.
- Phase E (Terminal B): cut legacy callers across NEW services; remove old endpoints.
- Phase F (Terminal B): tag 3 legacy services ARCHIVE; record decommission in IL; complete 24/24 KEEP coverage milestone.

## Risk register tie-in

- R-MIG-02 (legacy on evo1 only): mirror three legacy dirs to off-evo1 backup per R4 PREP.
- R-MIG-LANG-01 (TypeScript-to-Python rewrite for portfolio): introduces a language boundary in NEW; ensure Python observability + container runtime align with the rest of NEW stack.
- R-OPS-02 (Prometheus dead 2+ weeks): crypto-ops-monitor must expose Prometheus metrics from day 1 to unblock R3 Observability foundation tie-in.
- R-COMP-FCA-04 (portfolio audit trail): banxe-portfolio every value-snapshot persisted to guardian_audit_events with correlationId for MLRO + Section 4 evidence.

## Acceptance criteria

- 3 NEW repos scaffolded: crypto-ops-monitor (NestJS), banxe-portfolio (Python FastAPI), banxe-news (NestJS).
- crypto-ops-monitor: multi-chain RPC pool covers 5-6 WalletPort chains; Prometheus metrics exposed; health endpoints green.
- banxe-portfolio: parity tests vs legacy crypto-api-portfolio on time-series queries (1h, 1d, 7d, 30d windows); zero-mismatch on deterministic queries.
- banxe-news: news aggregator parity tests vs legacy crypto-api-news.
- ethers v5 replaced by viem 2.x consistently across NEW.
- 3 legacy services tagged ARCHIVE; decommission in IL; 24/24 KEEP coverage milestone closed.

## Open questions

- Where does banxe-portfolio Python service deploy: same systemd host as NestJS services, separate Python container, or shared Python runtime with other future Python services? Owner: SRE + Architecture WG.
- Should crypto-ops-monitor expose its multi-chain RPC abstraction as a public Hexagonal port (RpcPort), or remain internal to operations? Owner: Architecture WG.
- Does banxe-news need its own moderation/compliance review for content (FCA financial promotions rules)? Owner: Compliance + Legal.
- Does portfolio analytics rewrite re-use the SQLAlchemy schema from a future Python services template, or hand-rolled? Owner: Architecture WG.

## References

- ADR-021 five-new-ports (WalletPort + ExchangePort dependencies)
- ADR-019 GraphQL migration (Apollo to Hasura; drops GraphQL coupling in portfolio)
- ADR-017 vendor-to-OpenSource policy (ethers v5 -> viem 2.x)
- REFACTOR_MASTER_PLAN.md
- CLASS_KEEP.tsv (3 KEEP-EXTRACT rows: rpc, portfolio, news)
- RISK_REGISTER-2026-05-22.md (R-MIG-02, R-OPS-02)
- SPEC #1 crypto-api-keys-lib (WalletPort chain coverage)
- SPEC #4 Trading UI group (ExchangePort consumer of rpc)
- UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md (House rule 10)
- UNIVERSAL-CANON-BEST-SOLUTION-AND-SEQUENTIAL-2026-05-23.md (House rules 11 + 12)

=== END OF crypto-ops sub-group SPEC (snapshot 4ca0eef) ===
=== 24/24 KEEP coverage milestone achieved with this SPEC ===
