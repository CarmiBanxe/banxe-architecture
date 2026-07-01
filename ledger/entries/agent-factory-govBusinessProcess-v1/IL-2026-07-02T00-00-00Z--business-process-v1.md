---
il_ts: 2026-07-02T00:00:00Z
session_id: agent-factory-govBusinessProcess-v1
source: factory
status: DONE
parent_il: IL-122-INTENT-FIRST-CANON-2026-06-07
---

### IL — Business Process Repository governance artifact (ADR-045 §D7.3 / S13-00) — ACCEPTED

- **What:** Process catalog schema and policy artifact closing ADR-045 §D7 gap-3 (S13-00).
  Defines: (1) Process ID scheme (`BPR-{DOMAIN}-{NNNN}`, 10 domain codes); (2) 37-field
  process catalog schema spanning identity, ownership, trigger, inputs/outputs, systems,
  SLA, upstream/downstream dependencies, and risk/compliance tags; (3) change-control and
  deprecation policy; (4) PostgreSQL source-of-truth DDL (`process_catalog`,
  `process_changelog`, `process_io`) with append-only constraint (I-24); (5) ClickHouse
  audit event store with TTL 5 YEAR (I-08) and `correlation_id` join to AgentDecisionRecord
  (IL-785) and CostAttributionRecord (IL-789); (6) DAG dependency model with cycle-detection
  rule; (7) SLA class table (REALTIME/NEAR_REALTIME/OPERATIONAL/BATCH/PERIODIC) and breach
  action vocabulary; (8) AI agent integration constraints (autonomy ceiling, cost attribution,
  decision lineage, HITL gate — I-27); (9) 3 reserved future ADRs (ADR-053 runtime /
  ADR-054 integration / ADR-055 dashboard).
- **ADR parent:** ADR-045 §D7.3 — this artifact CLOSES gap-3 (S13-00), the final §D7 gap.
  Gap-1 (decision lineage) closed via IL-785. Gap-2 (AI cost policy) closed via IL-789.
  ADR-045 §D7 backlog is now complete.
- **Artifacts:** `governance/business-process/README.md` (new, 11 sections);
  `INSTRUCTION-LEDGER.md` (this anchor, append-only).
- **Invariants enforced:** I-08 (ClickHouse TTL 5 YEAR); I-24 (process_catalog
  append-only); I-27 (AI-executed processes return HITLProposal, never auto-apply);
  I-28 (AI execution trace emitted per step); EU AI Act Art.14 (human oversight at L3+).
- **Implementation deferred:** DDL migration, FastAPI registration service, DAG validator,
  compliance dashboard → ADR-053 / ADR-054 / ADR-055 (factory sprints). No code in this cycle.
- **Refs:** ADR-045 (parent); IL-785 (decision lineage, correlation_id join);
  IL-789 (AI cost policy, CostAttributionRecord join); `.claude/rules/agent-authority.md`;
  EU AI Act Art.14 (human oversight), Art. 9 (risk management).
