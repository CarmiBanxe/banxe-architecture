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

## IL-110 Verification Result — 2026-06-06 CEST (Terminal B)

Method: read-only inventory on Legion (BANXE-only scope; non-BANXE/legal resources excluded per operator).

| # | Claim | Verdict | Evidence |
|---|-------|---------|----------|
| 1 | 8.6 GB unpacked | BLOCKED | banxe.rar = RAR5 encrypted headers (unrar exit 11); no full unpack on disk (only 116K stub /home/mmber/banxe-legacy-unpack). Requires operator password OR fresh unpack. |
| 2 | 12 projects | BLOCKED | archive contents inaccessible (encrypted). |
| 3 | 7 Binance files (in archive) | UNVERIFIABLE-IN-ARCHIVE | cannot inspect archive; Binance code exists only in current repos (banxe-emi-stack legacy_binancekyc_adapter.py; crypto-ops-monitor mock_binance.py). |
| 4 | neuron-bitshares-ui = trading frontend | NOT-FOUND | marker absent anywhere on machine (find -iname). |
| 5 | HollaEx/CCXT recommended | BLOCKED | depends on claim 4 (unavailable). |
| 6 | Paymentology 11 endpoints complete | REJECTED | actual: 3 RPC ops (handle_deduct/handle_balance/handle_deduct_reversal) + 2 REST (/paymentology/webhook, /health) in banxe-payment-core/src/paymentology. Not 11. |
| 7 | <500ms payment SLA | NOT-AN-INVARIANT | absent from canon; only mention is this same unverified list (UNIVERSAL-CANON-2026-05-22.md:292). Operator decision required to create I-NEW. |

Operator action required: provide banxe.rar password (RAR5 encrypted headers) to unblock claims 1,2,5; claim 3 re-scope to "current repos" not archive; claim 4 evidence absent; claim 6 corrected to 3 RPC ops; claim 7 not an invariant.
