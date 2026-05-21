# Unverified Claims — Legacy Discovery Scope

Date: 2026-05-22
Status: DISCOVERY-REQUIRED (no claim enters binding roadmap until verified)
Source: docs/project/DELTA-ANALYSIS-LEGACY-REFACTOR-vs-CURRENT-ROADMAP.md §3
Owner sprint: R0-DISCOVERY (pre-S16, operator-led with Central documentation support)

## Claims requiring evidence

| # | Claim | Verification method | Status |
|---|-------|---------------------|--------|
| 1 | "8.6 GB BANXE.RAR unpacked" | Operator provides archive; Central runs du -sh + find | UNVERIFIED |
| 2 | "12 projects in archive" | ls -d */ in unpacked root; count + identify each | UNVERIFIED |
| 3 | "7 Binance-related files" | grep -r Binance in unpacked archive; list paths | UNVERIFIED |
| 4 | "neuron-bitshares-ui = trading frontend" | Identify neuron-bitshares-ui dir; read package.json/README | UNVERIFIED |
| 5 | "HollaEx/CCXT recommended target" | Research feasibility; requires ADR after claim 4 verified | UNVERIFIED |
| 6 | "Paymentology 11 remote API endpoints complete" | Audit actual Paymentology integration code vs spec | UNVERIFIED |
| 7 | "<500ms payment path SLA" | Not in existing invariants; create I-NEW if confirmed | UNVERIFIED |

## Process

1. Operator provides access to BANXE.RAR archive (or confirms it is already extracted on Legion/evo1).
2. Central runs read-only inventory: file tree, SHA256, dependency extraction, README/package.json scan.
3. Each claim moves to VERIFIED or REJECTED with evidence path.
4. VERIFIED claims get sprint assignment per DELTA-ANALYSIS §4 mapping.
5. REJECTED claims get IL notation "CLAIM-X REJECTED: <reason>".

## Exit criteria for R0-DISCOVERY

- All 7 claims have VERIFIED or REJECTED status with evidence.
- If trading legacy confirmed: ADR draft for ExchangePort + HollaEx/CCXT evaluation.
- If trading legacy not confirmed: close trading track permanently.
- MIGRATION_DASHBOARD.md draft with domain coverage percentages.
- Strangler Fig ADR draft with bounded context diagram.

## Anchors

IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11 (line 7728); DELTA-ANALYSIS §3; SPRINT-EXTENSION §R0-DISCOVERY.
