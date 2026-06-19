# ADR-111: Crypto-AML Graph-Analytics Layer (Collective Crystal)

**Status:** PROPOSED
**Date:** 2026-06-19

## Context
Structured crypto-AML screening is mature (Marble case-mgmt, Jube TM/ML, Watchman OFAC, Yente PEP, sanctions). MISSING: entity-clustering + graph analytics + ML laundering detection (GraphSense=1, Neo4j=1, entity-clustering=0, peel-chain=0). OPEN GAPs 021 (real-time fraud ML), 022 (device/velocity), 025 (NCA SARs) need this layer.

## Decision
- Add crypto-AML graph-analytics as EXTENSION on existing AML foundation (reuse Marble/Jube/Watchman/Yente, do not rebuild).
- Entity clustering: GraphSense (MIT) + CIOH heuristic (BTC) + Neo4j Community for graph queries.
- ML laundering detection: GraphSAGE on Elliptic++ dataset; peel-chain Random Forest. Fulfils GAP-021.
- Real-time blacklist feeds: 0xB10C OFAC crypto list + USDT blacklist (usdtbanlist) + Scorechain/MistTrack freemium ensemble.
- Integration: pre-crediting screen API for incoming crypto; scoring matrix LOW/MED/HIGH/CRITICAL -> CRITICAL=block+SAR; Marble case feed; ClickHouse audit (append-only).

## Compliance
- MiCA VASP monitoring; FATF Travel Rule (ADR-036 gate). Data sovereignty: in-Banxe infra (no client data to 3rd party beyond Paybis distribution scope).
- MLRO HITL on HIGH/CRITICAL + SAR; AI may score, never auto-clear adverse.

## Consequences
- Positive: closes GAP-021/022/025 graph dimension; investigative depth ~80-90% of Crystal/Chainalysis at OSS cost.
- Negative/residual: GraphSense needs Cassandra backend; GNN model training/ops (separate impl effort); ensemble feed API costs (freemium tiers).

## Related
- GAP-021/022/025, GAP-068 (new), ADR-036 (Travel Rule), ADR-109 (crypto-ops-monitor Python), SP-OS1 (adverse-media). Marble/Jube/Watchman/Yente (foundation).
