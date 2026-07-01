---
il_ts: 2026-07-01T23:00:00Z
session_id: agent-factory-govAiCostPolicy-v1
source: factory
status: DONE
parent_il: IL-122-INTENT-FIRST-CANON-2026-06-07
---

### IL — AI Cost Policy governance artifact (ADR-045 §D7.2) — ACCEPTED

- **What:** Per-model/per-agent cost-governance artifact closing ADR-045 §D7 gap-2.
  Defines: (1) Model Tier Registry (T1 Haiku / T2 Sonnet / T3 Opus); (2) per-agent
  daily budget table (12 agents, estate daily cap USD 110.50); (3) monthly hard-cap
  ladder (INFO $500 / WARN $1 500 / ALERT $2 500 / HARD STOP $3 300); (4) per-day
  burn-rate alerting + per-call anomaly detection; (5) `CostAttributionRecord` schema
  (16 fields, Decimal cost_usd — I-01, correlation_id join to IL-785 decision-lineage);
  (6) ClickHouse primary store with TTL 5 YEAR (I-08) + PostgreSQL monthly-summary
  shadow; (7) hard-stop implementation contract (HardStopError → HITLProposal, MLRO
  SAR path exempt at T2, Redis state flag); (8) governance controls table;
  (9) 3 reserved future ADRs (ADR-050 implementation / ADR-051 multi-provider /
  ADR-052 dashboard).
- **ADR parent:** ADR-045 §D7.2 — this artifact CLOSES gap-2 of the §D7 backlog.
  Gap-1 (decision lineage) closed via IL-785. Gap-3 (S13-00 business process) remains PENDING.
- **Artifacts:** `governance/ai-cost-policy/README.md` (new, 10 sections);
  `INSTRUCTION-LEDGER.md` (this anchor, append-only).
- **Invariants enforced:** I-01 (Decimal cost_usd, never float); I-08 (ClickHouse TTL
  5 YEAR); I-24 (ai_cost_events append-only); I-27 (hard-stop → HITLProposal);
  I-28 (every LLM call emits CostAttributionRecord).
- **Implementation deferred:** DDL, ingestion, instrumentation → ADR-050 (factory sprint).
  Cost tracker → BANXE EMI Stack `services/arl/cost_tracker.py`. No code in this cycle.
- **Refs:** ADR-045 (parent); ADR-040 (ARL routing substrate); IL-785 (decision lineage,
  correlation_id join); `.claude/rules/agent-authority.md`;
  EU AI Act Art. 9 (risk management), Art. 13 (transparency).
