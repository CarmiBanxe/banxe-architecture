-- Condition D Step 2: ClickHouse DDL for HITL audit sink
-- Status: PREPARED, NOT APPLIED
CREATE TABLE IF NOT EXISTS banxe_audit.hitl_decisions
(
    event_id UUID,
    occurred_at DateTime64(3, 'UTC'),
    source LowCardinality(String),
    decision_type LowCardinality(String),
    request_class LowCardinality(String),
    model_name String,
    confidence Float32,
    path String,
    payload_hash String,
    reviewer Nullable(String),
    outcome LowCardinality(String),
    notes String
)
ENGINE = MergeTree
ORDER BY (occurred_at, decision_type, event_id);
