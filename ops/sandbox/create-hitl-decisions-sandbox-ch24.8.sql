-- ClickHouse DDL for HITL audit sink (Condition D, Step 3)
-- Source: Condition D draft (PR #225)
-- Operator action: review and execute on production ClickHouse
-- Sub-A authority: cannot run this DDL on live cluster

CREATE DATABASE IF NOT EXISTS banxe_audit;

CREATE TABLE IF NOT EXISTS banxe_audit.hitl_decisions
(
    ts             DateTime64(3, 'UTC'),
    decision_id    UUID,
    level          Enum8('L0' = 0, 'L1' = 1, 'L2' = 2, 'L3' = 3),
    action         String,
    requested_by   String,
    requested_at   DateTime64(3, 'UTC'),
    prompt_hash    String,
    classifier_out String,
    guardrail_hit  String,
    operator       String,
    outcome        Enum8('approve' = 0, 'deny' = 1, 'timeout' = 2, 'escalate' = 3),
    decided_at     Nullable(DateTime64(3, 'UTC')),
    rollback_path  String,
    evidence_refs  Array(String)
)
ENGINE = ReplacingMergeTree(ts)
PARTITION BY toYYYYMM(ts)
ORDER BY (decision_id, ts)
TTL toDateTime(ts) + INTERVAL 7 YEAR DELETE;

-- ── SANDBOX ADAPTATION (STEP5, 2026-07-26) ──────────────────────────────────
-- Deviation from canonical sql/create-banxe-audit-hitl-decisions-2026-05-12.sql:
--   TTL expression wrapped: ts (DateTime64) -> toDateTime(ts).
-- Reason: ClickHouse 24.8 rejects DateTime64 in TTL (BAD_TTL_EXPRESSION, Code 450).
-- Semantics unchanged: 7-year delete. Canonical file NOT modified (canon).
-- OPEN POINT for operator: canonical DDL will hit the same error on any CH with
-- this restriction — review before PROD application (ADR-171 §PROD contract).
