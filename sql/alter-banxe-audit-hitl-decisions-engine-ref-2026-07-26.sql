-- ClickHouse DELTA ALTER for banxe_audit.hitl_decisions (engine-reference block E)
-- ENGREF01 | 2026-07-26 | STATUS: PROPOSED — operator to review and execute on production ClickHouse.
-- Sub-A authority: cannot run this DDL on live cluster (same contract as create-banxe-audit-hitl-decisions-2026-05-12.sql).
--
-- Design decision (ADR-171 §4): EXTEND the canonical table — NO new table (no second audit trail, ADR-102).
-- Canonical engine/partitioning/TTL are preserved by ALTER semantics:
--   ENGINE ReplacingMergeTree(ts) | PARTITION BY toYYYYMM(ts) | ORDER BY (decision_id, ts) | TTL ts + 7 YEAR DELETE
--
-- +8 columns for AI-agent decision lineage (EU AI Act auditability):

ALTER TABLE banxe_audit.hitl_decisions
    ADD COLUMN IF NOT EXISTS agent_name    String COMMENT 'L5 agent emitting the decision (registry name)',
    ADD COLUMN IF NOT EXISTS user_id       String COMMENT 'pseudonymized client reference (GDPR: no raw PII)',
    ADD COLUMN IF NOT EXISTS input_context String COMMENT 'sanitized input context (PII-redacted before write)',
    ADD COLUMN IF NOT EXISTS confidence    Float32 COMMENT 'agent confidence score [0,1]',
    ADD COLUMN IF NOT EXISTS model_version String COMMENT 'LiteLLM alias + resolved model version',
    ADD COLUMN IF NOT EXISTS explanation   String COMMENT 'client-facing/audit explanation (explainability by design)',
    ADD COLUMN IF NOT EXISTS decision_type Enum8('transfer' = 1, 'credit' = 2, 'fraud_flag' = 3, 'recommendation' = 4) DEFAULT 'recommendation',
    ADD COLUMN IF NOT EXISTS tools_called  Array(String) COMMENT 'composite tools invoked for this decision';

-- Verification (read-only, after operator applies):
--   DESCRIBE TABLE banxe_audit.hitl_decisions;
--   SELECT engine_full, partition_key, sorting_key FROM system.tables
--     WHERE database = 'banxe_audit' AND name = 'hitl_decisions';
-- Expected: original 14 columns intact + 8 new; engine/partition/order/TTL unchanged.
