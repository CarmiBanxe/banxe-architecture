# ADR-050: Crypto-Ops Subgroup Delivery Model

- Status: Proposed
- Date: 2026-06-07
- Deciders: Architecture WG, Terminal A (factory), Terminal B (impl)
- Context: spec-build architect rejected crypto-ops-subgroup-SPEC-2026-05-25 (NOT READY)

## Context

The crypto-ops-subgroup SPEC (#7) specifies 3 standalone repos on 2 runtimes:
- **crypto-ops-monitor** (NestJS) — multi-chain RPC ops gateway
- **banxe-portfolio** (Python FastAPI) — portfolio analytics
- **banxe-news** (NestJS) — news aggregator

The factory mapping is: `family=crypto-ops-subgroup`, `output=service-code`, `allowed_scope=src/crypto-ops/** + tests/crypto-ops/**` targeting a single repo (banxe-payment-core).

**Problem:** the SPEC demands 3 standalone repos across 2 language runtimes, but the factory pipeline only scaffolds into a single repo per family. Additionally, the SPEC carries 4 unresolved open questions and a 14-day shadow-mode requirement that cannot be expressed in the current spec-build contract.

## Decision

### Delivery model: Option B (per-capability SPECs)

Two options were considered:

| Option | Description | Pros | Cons |
|---|---|---|---|
| A | 3 standalone repos as SPEC demands | Matches SPEC intent; clean separation | Requires multi-repo scaffold extension in spec-build (Terminal A engine work); blocks on factory evolution |
| B | Split into per-capability families | Each passes existing single-repo pipeline immediately; no factory engine changes needed | 3 SPECs instead of 1; cross-SPEC coordination needed |

**Recommendation: Option B.**

Split crypto-ops-subgroup into three contract-scoped SPECs:
1. `crypto-ops-monitor-contract` — family targets crypto-ops-monitor repo, output=service-code, scope=src/crypto-ops-monitor/**
2. `portfolio-contract` — family targets banxe-portfolio repo, output=service-code, scope=src/portfolio/**
3. `news-contract` — family targets banxe-news repo, output=service-code, scope=src/news/**

Each SPEC can be built independently by the factory. The parent crypto-ops-subgroup-SPEC remains as a design document (reference architecture) but is NOT directly buildable.

Option A is deferred until Terminal A delivers multi-repo scaffold capability; at that point, Option A becomes viable as a future consolidation if the 3 repos prove tightly coupled in practice.

### Resolution of open questions

| # | Question | Proposed resolution | Owner | Status |
|---|---|---|---|---|
| 1 | banxe-portfolio Python deploy model | **Separate Python container** (dedicated Dockerfile, own systemd unit). Rationale: isolates Python dependency tree; enables independent scaling; avoids polluting NestJS host. Shared Python runtime deferred until ≥2 Python services exist. | SRE + Arch WG | PROPOSED |
| 2 | crypto-ops-monitor RpcPort: public Hexagonal port vs internal | **Internal** for now; expose as public RpcPort only if a second consumer beyond ExchangePort emerges. Avoids premature port proliferation per ADR-021 principle (ports = stable contracts with multiple consumers). | Arch WG | PROPOSED |
| 3 | banxe-news FCA financial-promotions moderation | **Required.** Any content surfaced to UK retail users must pass FCA financial promotions review. banxe-news MUST tag content with `promotionStatus` (approved/pending/rejected) and block display of unapproved content. Compliance team defines allowed-sources whitelist. | Compliance + Legal | PROPOSED |
| 4 | portfolio SQLAlchemy schema source | **Hand-rolled initially** (Alembic migrations, models co-located in banxe-portfolio). Migrate to shared Python template only when a second Python service (if any) proves schema-pattern convergence. Premature abstraction avoided per House rule 11. | Arch WG | PROPOSED |

### Consequences for factory mapping (spec-repo-map.tsv)

Terminal A must add 3 new rows to `config/spec-repo-map.tsv` (NOT done in this ADR):

```
# family                        | output        | repo                  | allowed_scope
crypto-ops-monitor-contract     | service-code  | crypto-ops-monitor    | src/crypto-ops-monitor/**
portfolio-contract              | service-code  | banxe-portfolio       | src/portfolio/**
news-contract                   | service-code  | banxe-news            | src/news/**
```

The existing `crypto-ops-subgroup` row should be marked `output=design-only` (no code generation; reference architecture document).

## Risks

| Risk ID | Description | Mitigation |
|---|---|---|
| R-MIG-LANG-01 | TS→Python technology boundary for banxe-portfolio; team may lack Python FastAPI expertise | Constrain portfolio to well-known patterns (FastAPI + SQLAlchemy + Alembic); provide cookiecutter template; code review by Python-experienced engineer |
| R-COMP-FCA-04 | Portfolio analytics surfaces financial data to users; must not constitute investment advice under FCA rules | Add disclaimer injection middleware; compliance review of all user-facing responses; audit trail per ADR-027 |
| R-OPS-SHADOW-01 | 14-day shadow-mode requirement in original SPEC has no factory primitive | Shadow-mode harness specified as a separate test-harness task (not part of service-code output); each per-capability SPEC includes shadow-mode as acceptance gate |

## References

- crypto-ops-subgroup-SPEC-2026-05-25.md (parent design SPEC #7)
- ADR-021 five-new-ports (port proliferation policy)
- ADR-017 vendor-to-OpenSource (ethers v5 → viem 2.x)
- ADR-019 GraphQL migration (Apollo → Hasura; portfolio decoupling)
- RISK_REGISTER-2026-05-22.md (R-MIG-02, R-OPS-02)
- wallet-port-CONTRACT-SPEC-2026-06-06.md (WalletPort consumed by crypto-ops-monitor)
- exchangeport-CONTRACT-SPEC-2026-06-06.md (ExchangePort consumer of RPC rates)
- UNIVERSAL-CANON House rules 11 (best-solution) + 12 (sequential)
