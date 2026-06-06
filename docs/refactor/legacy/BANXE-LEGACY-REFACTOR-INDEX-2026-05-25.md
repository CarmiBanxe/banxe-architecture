# BANXE Legacy Refactor INDEX — Phase A milestone (24/24 KEEP coverage)

Date: 2026-05-25
Status: SYNTHESIS INDEX (Phase A completion artefact; aggregates 7 SPECs into one Terminal B-facing entry point)
Scope: index + cross-reference + dependency graph for all 7 Phase A refactor SPECs covering 24/24 KEEP-rows of CLASS_KEEP.tsv
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/ on evo1 (read-only); 7 SPECs in docs/refactor/legacy/
Related: ADR-016 trading-ui; ADR-017 vendor-to-os; ADR-019 GraphQL migration; ADR-020 VABS-to-open-banking; ADR-021 five-new-ports; REFACTOR_MASTER_PLAN; CLASS_KEEP.tsv; House rules 10/11/12 + worktree-isolation pattern
Owner: Right terminal authored synthesis; Terminal B owns implementation (Phase B onwards)

## Purpose

Single entry point for Terminal B implementation. Aggregates the seven Phase A SPECs produced 2026-05-22 to 2026-05-25, captures cross-references and dependency order, and lists all five Hexagonal ports (ADR-021) plus the candidate sixth (NotificationPort) with their owning SPECs. Reading this index alone is enough to plan Phase B work.

## Summary table — 7 SPECs / 25 legacy projects / 24 KEEP rows / 5+1 ports

| # | SPEC file | Legacy projects | NEW components | Hexagonal port | Commit |
|---|---|---|---|---|---|
| 1 | crypto-api-keys-lib-SPEC-2026-05-22.md | crypto-api-keys-lib | banxe-crypto-utils | WalletPort | 2d44ca3 |
| 2 | crypto-utils-libs-SPEC-2026-05-22.md | bitcoinjs-lib + wallet-address-validator + coinselect | banxe-crypto-utils (deps of #1) | (supports WalletPort) | 8b5d345 |
| 3 | notification-port-SPEC-2026-05-23.md | telegram-bot + neuron-push-notifications + neuron-push-notifications-chat | banxe-notifications | NotificationPort (candidate 6th) | 0faf4c7 |
| 4 | trading-ui-group-SPEC-2026-05-23.md | neuron-bitshares-ui + fast-exchange + banxe-trade-view + banxe-trade-view-new | banxe-trading-ui + banxe-trading-backend | ExchangePort | 790af18 |
| 5 | emi-banking-services-SPEC-2026-05-23.md | cex/cex + cex/gql-cex + banxe-open-banking x2 + banxe-baas + sepa-service | banxe-open-banking + banxe-baas + banxe-sepa | PartnerPort | 446bca2 |
| 6 | fiat-backend-utils-SPEC-2026-05-23.md | banxe-referrers + files-api + banxe-circuit-breaker + banxe-tariff + node-clickhouse | banxe-crm + banxe-files + @banxe/circuit-breaker + banxe-tariff | CRMPort | 18a8f02 |
| 7 | crypto-ops-subgroup-SPEC-2026-05-25.md | crypto-api-rpc + crypto-api-portfolio + crypto-api-news | crypto-ops-monitor + banxe-portfolio (Python) + banxe-news | (consumer of WalletPort + ExchangePort) | 915fdda |

Totals: 25 legacy projects examined; 24 KEEP-rows of CLASS_KEEP.tsv covered; ~17 NEW components specified; 5 ADR-021 ports each have a primary SPEC; NotificationPort proposed as candidate 6th port.

## Recommended Phase B implementation order (dependency graph)

Build NEW components in this order so each step's preconditions are already met:

1. SPEC #2 (crypto-utils-libs scaffold decisions) - no runtime deps; pure architectural decisions for crypto primitives.
2. SPEC #1 (crypto-api-keys-lib -> banxe-crypto-utils + WalletPort) - depends on #2 verdicts; produces WalletPort.
3. SPEC #6 (@banxe/circuit-breaker library) - shared across all NEW services; build before any service that uses resilience patterns.
4. SPEC #5 (banxe-baas + banxe-open-banking + banxe-sepa + PartnerPort) - EMI core; depends on @banxe/circuit-breaker and on KYCProviderPort (inline).
5. SPEC #6 remainder (banxe-crm + banxe-files + banxe-tariff + CRMPort) - utilities consumed by EMI core.
6. SPEC #7 (crypto-ops-monitor + banxe-portfolio + banxe-news) - depends on WalletPort (#1) and on ExchangePort (#4).
7. SPEC #4 (banxe-trading-ui + banxe-trading-backend + ExchangePort) - depends on WalletPort (#1) for wallet UI components; SPEC #7 RPC layer.
8. SPEC #3 (NotificationPort + adapters) - cross-cutting; can run in parallel after step 4 since EMI core is consumer #1 of notifications.

Critical-path: #2 -> #1 -> #6-lib -> #5 -> #6-services -> #7 -> #4 -> #3.

## Cross-SPEC dependencies

- WalletPort (SPEC #1) consumed by: crypto-ops-monitor (#7), banxe-portfolio (#7), banxe-trading-ui (#4).
- ExchangePort (SPEC #4) consumed by: banxe-portfolio (#7).
- PartnerPort (SPEC #5) consumed by: banxe-baas, banxe-sepa (internal in #5).
- CRMPort (SPEC #6) consumed by: future loyalty / segmentation services (post-Phase A).
- NotificationPort (SPEC #3) consumed by: every NEW service that needs to alert users (EMI core, trading, compliance).
- @banxe/circuit-breaker (SPEC #6) consumed by: every NEW service with outbound calls.
- @clickhouse/client upstream (SPEC #6 drop of node-clickhouse fork) consumed by: any NEW service writing audit events.


## Hexagonal ports allocation (ADR-021)

| Port | Owning SPEC | Primary adapter | Status |
|---|---|---|---|
| WalletPort | SPEC #1 | banxe-crypto-utils (5-6 chain adapters) | contract drafted |
| ExchangePort | SPEC #4 | banxe-trading-backend (fast-exchange transform) | contract drafted |
| PartnerPort | SPEC #5 | banxe-baas + banxe-open-banking + banxe-sepa adapters | contract drafted |
| KYCProviderPort | SPEC #5 (inline) | SumSub via banxe-baas + banxe-open-banking | NOT yet broken out into own SPEC |
| CRMPort | SPEC #6 | ReferralCRMAdapter (banxe-crm from banxe-referrers) | contract drafted |
| NotificationPort (candidate 6th) | SPEC #3 | TelegramAdapter + MobilePushAdapter | contract drafted; requires ADR-021 amendment |

## Outside Phase A KEEP scope (not in this index, planned later)

- CLASS_TRANSFORM.tsv (99 rows) - Transform-first canonical migrations; needs its own Phase A inventory pass.
- CLASS_PORT.tsv (22), CLASS_MERGE.tsv (15), CLASS_REVIEW.tsv (69), CLASS_TAIL.tsv (39) - additional refactor categories.
- KYCProviderPort dedicated SPEC - SumSub currently inline in SPEC #5; standalone extraction is a future SPEC #8.
- ADR-021 amendment to formalise NotificationPort as 6th port - architecture-WG decision, not refactor SPEC scope.

## What right-terminal hands off to Terminal B

- 7 SPECs in docs/refactor/legacy/ (this index lists all).
- 7 backup copies in /home/mmber/tmp-banxe-audit/ (durability against worktree churn).
- 7 local feature branches feat/docs-refactor-* (pending push until R3 webhook live).
- Read-only inventory done on evo1 at /home/banxe/banxe-rar-extracted/ for every legacy project referenced.
- All Phases A-F outlined per SPEC (Phase A = inventory + decisions, complete; Phases B-F = implementation, Terminal B).

## References

- ADR-016 trading-ui; ADR-017 vendor-to-os; ADR-019 GraphQL migration; ADR-020 VABS-to-open-banking; ADR-021 five-new-ports; ADR-027 audit trail
- REFACTOR_MASTER_PLAN.md (Transform-first principles)
- CLASS_KEEP.tsv (24/24 rows now covered by 7 SPECs)
- TRADING_PHASE_A_INVENTORY.md + TRADING_REFACTOR_TASKS.md (precursor pattern for Phases A-F)
- RISK_REGISTER-2026-05-22.md (R-MIG-02, R-MIG-LICENSE-01, R-SEC-NEW-*, R-COMP-FCA-*, R-PRIV-*)
- ROADMAP_8Q-2026-05-22.md (8-quarter timeline)
- UNIVERSAL-CANON-2026-05-22.md + TOPOLOGY-CLARIFICATION-2026-05-22 + BEST-SOLUTION-AND-SEQUENTIAL-2026-05-25 (House rules 1-12 + worktree-isolation pattern)

=== END OF BANXE LEGACY REFACTOR INDEX (24/24 KEEP coverage; Phase A milestone) ===

## NEW capability mapping (per NEW-PROJECT-PRIORITY-MAP-2026-06-06)

Per the governing canon "NEW drives legacy reuse", each SPEC maps to authoritative NEW capabilities C1-C18:

| SPEC | NEW capabilities served | Decision class |
|---|---|---|
| #1 crypto-api-keys-lib | C1 (custody) | legacy-serves |
| #2 crypto-utils-libs | C1 + C2 (custody primitives + address validation) | legacy-serves |
| #3 notification-port | C9 (notifications) | legacy-serves |
| #4 trading-ui-group | C6 (trading) | legacy-serves |
| #5 emi-banking-services | C3 + C4 (fiat rails + BaaS) | legacy-serves |
| #6 fiat-backend-utils | C10 + C11 + C12 + C13 (CRM + tariff + files + resilience) | legacy-serves |
| #7 crypto-ops-subgroup | C7 + C8 + C18 (portfolio + RPC + news) | legacy-serves |
| #8 kyc-provider-port | C5 (KYC/AML) | legacy-serves |

Build-fresh NEW capabilities (NO legacy SPEC; built from scratch): C14 ledger (Midaz), C15 audit trail (Guardian/ClickHouse), C16 Travel Rule v2, C17 observability. These are NOT in the 8 refactor SPECs because no legacy source serves them — they are tracked separately in NEW-PROJECT-PRIORITY-MAP build-fresh gaps.

Coverage: 14 of 18 NEW capabilities served by refactored legacy (C1-C13 + C18); 4 build-fresh (C14-C17).

## Executable CONTRACT layer (6/6 ports, 2026-06-06)

Beyond the 8 design SPECs, each Hexagonal port has an executable CONTRACT (types + operations + idempotency + error model + audit + conformance suite). These are implementation-ready for Terminal B Phase C — no design ambiguity remains.

| Port | Capability | CONTRACT file | Conformance tests |
|---|---|---|---|
| WalletPort | C1 custody | wallet-port-CONTRACT-SPEC-2026-06-06.md | 10 (zero-mismatch) |
| PartnerPort | C3/C4 fiat | emi-banking-partnerport-CONTRACT-SPEC-2026-06-06.md | 11 |
| ExchangePort | C6 trading | exchange-port-CONTRACT-SPEC-2026-06-06.md (definitive; supersedes 8-line stub) | 11 |
| KYCProviderPort | C5 KYC/AML | kyc-provider-port-CONTRACT-SPEC-2026-06-06.md | 11 |
| NotificationPort | C9 notifications | notification-port-CONTRACT-SPEC-2026-06-06.md | 9 |
| CRMPort | C10 referral/CRM | crm-port-CONTRACT-SPEC-2026-06-06.md | 7 |

CONTRACT layer properties:
- All 4 regulatory-critical ports (Wallet/Partner/Exchange/KYC) have idempotency + 5y audit retention (CASS 15).
- All carry correlationId; all persist to guardian_audit_events.
- @banxe/circuit-breaker (SPEC #6) used for *Unavailable error classes across ports.
- ComplianceBlock / KYC-gate consistent across Exchange + Partner ports.
- NotificationPort is the cross-cutting MLRO escalation channel for all other ports.

## Governing canon reference

Per docs/refactor/legacy/NEW-PROJECT-PRIORITY-MAP-2026-06-06.md: NEW drives legacy reuse. Every SPEC + CONTRACT is anchored to a NEW capability C1-C18; legacy is reused only where it serves a NEW need. 4 build-fresh capabilities (C14-C17) have no refactor SPEC by design.
