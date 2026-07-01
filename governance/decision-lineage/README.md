# AI Agent Decision Lineage — Governance Specification

**Status:** ACCEPTED  
**Date:** 2026-07-01  
**IL-anchor:** IL-OPS-V2-DECISION-LINEAGE-SCHEMA-V1-2026-07-01  
**Source:** ADR-045 §D7 open governance gap (Decision Lineage Schema)  
**Pairs-with:** `docs/adr/ADR-045-intent-first-banking-architecture.md`, `docs/canon/INTENT-FIRST-CANON-2026-06-07.md`  
**Scope:** BANXE-only — governance artefact; CONCEPT + SCHEMA (no runtime code in this document)

---

## Purpose

Every consequential L2 agent decision in EMI BANXE AI BANK must leave a durable,
append-only record: who decided, on what intent, with what confidence, whether a human
confirmed it, and which prior decisions it depended on. This is the **Decision Lineage**
requirement.

This document closes ADR-045 §D7 gap 1 by specifying:

1. What qualifies as a *consequential L2 decision* (recording threshold).
2. The `AgentDecisionRecord` schema (append-only log entry).
3. Storage requirements and TTL (I-08, I-24).
4. Invariants and HITL gate rules.

Decision Lineage is part of the **L3 Governance & Compliance Layer** (INTENT-FIRST-CANON
Principle 2). No L2 agent action touching client funds, production state, or regulated
data may bypass L3, which includes this lineage requirement.

---

## 1. Recording Threshold — What Counts as Consequential

A Decision Lineage record MUST be created for every L2 agent action that meets **any**
of the following criteria:

| Criterion | Examples |
|-----------|----------|
| Touches client funds or balances | Payment initiation, refund, FX conversion |
| Mutates regulated or PII data | KYC status update, AML flag, DSAR action |
| Triggers a HITL gate | SAR candidate, EDD trigger, sanctions match |
| Executes a cross-agent instruction | Orchestrator → sub-agent task delegation |
| Modifies production configuration or policy | Threshold change, rule override |
| Any action with autonomy level L3 or L4 | Per `governance/agent-authority.md` |

Purely read-only queries (balance lookups, statement fetches with no state change) do
**not** require a Decision Lineage record unless they are themselves the trigger for a
consequential action.

---

## 2. `AgentDecisionRecord` Schema

Each record is one append-only row. Fields marked **REQUIRED** must be present; the
record is invalid without them.

```
AgentDecisionRecord {
  -- Identity
  record_id        UUID         REQUIRED  -- stable unique ID for this decision
  intent_id        UUID         REQUIRED  -- ID of the originating client intent
  agent_id         String       REQUIRED  -- canonical agent name (passport ID)
  autonomy_level   Enum(L1..L4) REQUIRED  -- per governance/agent-authority.md

  -- Timing
  decided_at       DateTime(UTC) REQUIRED -- when the agent made the decision
  recorded_at      DateTime(UTC) REQUIRED -- when the row was inserted (≥ decided_at)

  -- Decision content
  action_type      String       REQUIRED  -- verb_noun label (e.g. "payment_submit")
  action_payload   JSON         REQUIRED  -- sanitised inputs (no secrets, no card PANs)
  inputs_hash      SHA256       REQUIRED  -- hash of full input set for integrity
  confidence_score Decimal(5,4) NULLABLE  -- model confidence [0.0000–1.0000] if available

  -- Lineage
  parent_record_id UUID         NULLABLE  -- prior decision this depends on (chain root = NULL)
  correlation_id   UUID         REQUIRED  -- groups all records for one end-to-end flow
  session_id       String       NULLABLE  -- factory/terminal session if factory-originated

  -- HITL
  hitl_required    Boolean      REQUIRED  -- true if this action triggered a HITL gate
  hitl_outcome     Enum(         NULLABLE -- NULL if hitl_required = false
                     APPROVED,
                     REJECTED,
                     ESCALATED,
                     TIMEOUT)
  hitl_actor       String       NULLABLE  -- role/identity of human approver if applicable
  hitl_decided_at  DateTime(UTC) NULLABLE -- when human decision was recorded

  -- Outcome
  outcome          Enum(         REQUIRED
                     EXECUTED,
                     BLOCKED,
                     ESCALATED,
                     FAILED)
  outcome_detail   String       NULLABLE  -- free-text reason (rejection, error, etc.)

  -- Audit
  il_anchor        String       NULLABLE  -- IL entry that authorised this action class
  schema_version   String       REQUIRED  -- "v1" — bump on any breaking field addition
}
```

### Invariants

- **NEVER** UPDATE or DELETE a `AgentDecisionRecord`. The table is append-only (I-24).
- `recorded_at` is set by the storage layer at insert time and must be ≥ `decided_at`.
- `inputs_hash` must be computed over the canonical serialisation of `action_payload`
  before any field is redacted.
- `confidence_score` is stored as `Decimal(5,4)`, never `float` (I-01).

---

## 3. Storage

### Primary store — ClickHouse (I-08)

```sql
CREATE TABLE decision_lineage.agent_decision_records
(
    record_id        UUID,
    intent_id        UUID,
    agent_id         String,
    autonomy_level   LowCardinality(String),
    decided_at       DateTime64(3, 'UTC'),
    recorded_at      DateTime64(3, 'UTC'),
    action_type      String,
    action_payload   String,           -- JSON, sanitised
    inputs_hash      FixedString(64),  -- hex SHA-256
    confidence_score Nullable(Decimal(5, 4)),
    parent_record_id Nullable(UUID),
    correlation_id   UUID,
    session_id       Nullable(String),
    hitl_required    Bool,
    hitl_outcome     Nullable(LowCardinality(String)),
    hitl_actor       Nullable(String),
    hitl_decided_at  Nullable(DateTime64(3, 'UTC')),
    outcome          LowCardinality(String),
    outcome_detail   Nullable(String),
    il_anchor        Nullable(String),
    schema_version   LowCardinality(String)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(decided_at)
ORDER BY (decided_at, correlation_id, record_id)
TTL decided_at + INTERVAL 5 YEAR;  -- I-08: minimum 5-year retention
```

### Secondary index — PostgreSQL (operational queries)

A lightweight shadow table in PostgreSQL for real-time HITL gate queries and correlation
ID lookups. Contains only: `record_id`, `correlation_id`, `intent_id`, `agent_id`,
`hitl_required`, `hitl_outcome`, `outcome`, `decided_at`. The ClickHouse table is the
source of truth; the PostgreSQL shadow is a projection for latency-sensitive reads.

---

## 4. Query Patterns

### Lineage chain for one intent

```sql
WITH RECURSIVE chain AS (
    SELECT * FROM decision_lineage.agent_decision_records
    WHERE intent_id = 'UUID-HERE' AND parent_record_id IS NULL
    UNION ALL
    SELECT r.* FROM decision_lineage.agent_decision_records r
    JOIN chain c ON r.parent_record_id = c.record_id
)
SELECT * FROM chain ORDER BY decided_at;
```

### HITL pending > 2 hours

```sql
SELECT record_id, agent_id, action_type, decided_at
FROM decision_lineage.agent_decision_records
WHERE hitl_required = true
  AND hitl_outcome IS NULL
  AND decided_at < now() - INTERVAL 2 HOUR;
```

---

## 5. Implementation Sequence (future ADRs, NOT in this document)

The following are NAMED and RESERVED; this document does not design or implement them:

1. **ADR-Decision-Lineage-Runtime** — FastAPI writer service + ClickHouse adapter for
   inserting `AgentDecisionRecord` rows from agent code.
2. **ADR-Decision-Lineage-API** — REST + MCP tool (`get_decision_lineage`) for reading
   chains; authentication via Keycloak RBAC.
3. **ADR-Decision-Lineage-HITL-Integration** — wiring `hitl_service.py` to emit lineage
   records at gate open/close; MLRO dashboard panel.

These three items remain OPEN after this document. This document's obligation is to fix
the schema and storage contract so runtime implementation has an unambiguous target.

---

## 6. References

- `docs/adr/ADR-045-intent-first-banking-architecture.md` §D7 (originating gap)
- `docs/canon/INTENT-FIRST-CANON-2026-06-07.md` §Principle 2 (L3 Governance layer)
- `governance/agent-authority.md` (autonomy levels L1–L4, HITL gates)
- `services/hitl/hitl_service.py` (HITL gate implementation)
- `docs/adr/ADR-040-ai-execution-policy.md` (meta-plane vs inference-plane)
- `.claude/rules/agents.md` (HITL confidence thresholds; agent-chain × GSD matrix)
- `.semgrep/banxe-rules.yml` rules: `banxe-float-money` (I-01), `banxe-clickhouse-ttl-reduce` (I-08), `banxe-audit-delete` (I-24)
- `INSTRUCTION-LEDGER.md` → IL-OPS-V2-DECISION-LINEAGE-SCHEMA-V1-2026-07-01
