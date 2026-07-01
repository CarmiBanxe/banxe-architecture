---
il_ts: 2026-07-01T22:00:00Z
session_id: agent-factory-govDecisionLineage-v1
source: factory
status: DONE
parent_il: IL-122-INTENT-FIRST-CANON-2026-06-07
---

### IL — AI Agent Decision Lineage — schema governance v1 (2026-07-01)

**ID:** IL-OPS-V2-DECISION-LINEAGE-SCHEMA-V1-2026-07-01
**Date:** 2026-07-01
**Parent:** IL-122-INTENT-FIRST-CANON-2026-06-07 / ADR-045 §D7 open gap
**Scope:** governance artefact only — CONCEPT + SCHEMA. No runtime code.

#### What this closes

ADR-045 §D7 named three open governance gaps. This entry closes **gap 1**:

> "Decision Lineage Schema / `AgentDecisionRecord` — a durable schema capturing,
> for every consequential L2 agent decision, the intent, the agent, the inputs,
> the confidence, the HITL outcome, and the lineage to prior decisions."

#### Changes

- **Created** `governance/decision-lineage/README.md` — binding specification of:
  - Recording threshold (what constitutes a consequential L2 decision).
  - `AgentDecisionRecord` schema: 22 fields covering identity, timing, decision
    content, lineage chain (`parent_record_id`), HITL outcome, and result.
  - ClickHouse primary store (TTL 5yr, I-08) + PostgreSQL shadow for HITL queries.
  - Two query patterns: full lineage chain per intent; HITL pending > 2h.
  - Three future implementation ADRs named and reserved (runtime writer,
    REST/MCP API, HITL integration) — explicitly NOT implemented here.

#### Invariants upheld

- I-01: `confidence_score` stored as `Decimal(5,4)`, never `float`.
- I-08: ClickHouse TTL 5 years minimum.
- I-24: Append-only — no UPDATE/DELETE on `agent_decision_records`.
- I-27: HITL gate outcome recorded per record; agents PROPOSE, humans DECIDE at L3+.
- EU AI Act Art.14: human oversight preserved via `hitl_required` / `hitl_outcome` fields.

#### ADR-045 §D7 gap status after this entry

| Gap | Status |
|-----|--------|
| 1 — Decision Lineage Schema | ✅ CLOSED by this entry |
| 2 — AI cost governance policy | OPEN (future ADR) |
| 3 — S13-00 Business Process Repository | OPEN (future ADR) |

Gaps 2 and 3 remain OPEN and are out of scope for this cycle.
