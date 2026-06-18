# ADR-107: Blockchain Data Infrastructure for Crypto Accounting & Reconciliation
**Status:** PROPOSED
**Date:** 2026-06-18
**Deciders:** Operator, Central
**Trust Zone:** AMBER
**Change Class:** CLASS_B

## Context
BANXE EMI needs blockchain data infrastructure for crypto accounting & reconciliation at ~15,000 wallets scale, under EU EMI/CASP compliance (EBA GL/2019/02 outsourcing, MiCA Art. 70-76, DORA, GDPR Art. 28). Requirements: batch wallet support (~15K), real-time webhooks, double-entry accounting readiness, EU data residency, time-to-production.

## Decision Drivers
- 15K-wallet batch ingestion plus real-time updates
- EU EMI/CASP compliance (EBA GL/2019/02, MiCA, DORA, GDPR)
- Data sovereignty vs time-to-market trade-off
- TCO (CAPEX/OPEX) and DevOps overhead

## Considered Options
- A. Pure OSS self-hosted: Erigon/Reth archive + Ponder/SQD indexer + PostgreSQL/TimescaleDB + beancount/rotki + Metabase. Max data sovereignty; high DevOps; 8-16wk.
- B. Hybrid managed-RPC + OSS indexer: Alchemy/QuickNode + SQD/Ponder + PostgreSQL + custom accounting. Lower infra burden; RPC SLA dependency; ~3-6wk.
- C. Event-driven OSS: Reth ExEx + Substreams + Kafka/NATS + PostgreSQL/TimescaleDB. Real-time; highest ops complexity.
- D. Managed data warehouse: Ethereum-ETL to BigQuery + dbt + Metabase. Cheap/fast batch; not real-time.
- E. SaaS reconciliation: Cryptio / Breezing / Allium. Fastest time-to-market; outsourcing under EBA GL/2019/02 requires DPA, EU residency, SLA, DORA Register.

## Compliance Conditions (mandatory for managed/SaaS)
GDPR Art. 28 DPA; EU data residency (SCCs/adequacy); SLA >=99.9%, RPO <=4h, RTO <=8h; EBA GL/2019/02 outsourcing register & exit plan; DORA ICT incident reporting (72h) & Register of Information; data portability/export.

## Decision
PROPOSED - pending Operator selection of one option (A-E). No implementation/PoC authorized until ACCEPTED and an execution channel is confirmed (per ADR-106).

## Consequences
Positive/Negative placeholders - finalized on option selection.

## Related
- ADR-106 (execution channel gate) - implementation routes through approved Channel C.
- Market research base (15K wallets, EU EMI).
