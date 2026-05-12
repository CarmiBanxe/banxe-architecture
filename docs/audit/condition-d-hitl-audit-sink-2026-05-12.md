# Condition D — HITL Audit Sink Schema and Escalation Wiring (Draft)

Document ID: COND-D-DRAFT-2026-05-12
Status: DRAFT — not executed on live infrastructure
Scope: Closes Condition D documentation gap per Sprint 4 audit (PR #219)
Track: Innovation Sandbox / Conditions A–D batch (Clause 16)
Date: 2026-05-12

---

## 1. Scope

Condition D requires three artifacts that were missing after Sprint 4:

1. Escalation rule wiring into the compliance-api decision path
2. Audit event sink contract (ClickHouse table name + schema)
3. "No silent bypass" enforcement contract

This document drafts all three. No DDL is executed against any live
ClickHouse cluster. Operator must approve the schema and assign
the wiring task before any execution occurs.

### Existing foundation (already merged)

| Artifact | Status | Reference |
|---|---|---|
| HITL L3 agent gate policy | DONE | `docs/policies/hitl-l3-agent-gate-2026-05-11.md` (PR #207) |
| HITL decision recording runbook | DONE | `docs/runbooks/hitl-decision-recording.md` (PR #207) |
| custom_code guardrail (8 regulated keywords) | DONE | Active in LiteLLM config (PR #200) |

---

## 2. ClickHouse Audit Sink Schema

### Target cluster

- Database: `banxe_audit`
- Table: `hitl_decisions`

### DDL (draft — NOT executed)

```sql
CREATE TABLE IF NOT EXISTS banxe_audit.hitl_decisions
(
    ts              DateTime64(3, 'UTC'),
    decision_id     UUID,
    level           Enum8(
                        'L0' = 0,
                        'L1' = 1,
                        'L2' = 2,
                        'L3' = 3
                    ),
    action          String,
    requested_by    String,
    requested_at    DateTime64(3, 'UTC'),
    prompt_hash     String,
    classifier_out  JSON,
    guardrail_hit   String,
    operator        String,
    outcome         Enum8(
                        'approve'  = 0,
                        'deny'     = 1,
                        'timeout'  = 2,
                        'escalate' = 3
                    ),
    decided_at      Nullable(DateTime64(3, 'UTC')),
    rollback_path   String,
    evidence_refs   Array(String)
)
ENGINE = ReplacingMergeTree(ts)
PARTITION BY toYYYYMM(ts)
ORDER BY (decision_id, ts)
TTL ts + INTERVAL 7 YEAR DELETE;
```

### Column semantics

| Column | Purpose |
|---|---|
| `ts` | Event timestamp (UTC, millisecond precision) |
| `decision_id` | Unique ID for this HITL decision |
| `level` | Escalation level (L0 = auto-allow, L3 = requires operator) |
| `action` | Requested action description |
| `requested_by` | Service or agent that triggered the decision |
| `requested_at` | When the request was made |
| `prompt_hash` | SHA-256 hash of the prompt (raw prompt NOT stored) |
| `classifier_out` | Classifier JSON output (class, confidence) — NULL if no classifier involved |
| `guardrail_hit` | Which guardrail keyword matched, if any (empty string if none) |
| `operator` | Human operator who reviewed (empty until decision made) |
| `outcome` | Decision result |
| `decided_at` | When the human decided (NULL until decided) |
| `rollback_path` | How to reverse this decision if needed |
| `evidence_refs` | Array of references (PR numbers, doc paths, ticket IDs) |

### Retention

- 7-year TTL aligns with FCA record-keeping requirements.
- Partitioned by month for efficient queries and expiration.

---

## 3. Escalation Rule Wiring

### Decision diagram

```
  Incoming request
        │
        ▼
  ┌─────────────────┐
  │ Guardrail check  │  (PR #200, 8 regulated keywords)
  │ keyword matched? │
  └────┬────────┬────┘
     YES       NO
       │        │
       ▼        ▼
  ┌─────────┐  ┌──────────────────┐
  │ BLOCK   │  │ Shadow classifier │  (pilot phase only)
  │ + row   │  │ Qwen2.5-0.5B     │
  │ deny    │  └────────┬─────────┘
  └─────────┘           │ record classification
                        ▼
                  ┌─────────────────┐
                  │ L3 review       │
                  │ required?       │
                  └────┬───────┬────┘
                     YES      NO
                       │       │
                       ▼       ▼
                  ┌─────────┐ ┌──────────┐
                  │ ASK     │ │ ALLOW    │
                  │ + row   │ │ + row    │
                  │ escalate│ │ approve  │
                  └─────────┘ └──────────┘
```

### Pseudocode

```python
def on_request(prompt: str, metadata: dict) -> Decision:
    # Step 1: guardrail check (already active, PR #200)
    guardrail_result = check_guardrail_keywords(prompt)
    if guardrail_result.hit:
        write_audit_row(
            level='L3',
            guardrail_hit=guardrail_result.keyword,
            outcome='deny',
            decided_at=now(),
        )
        return BLOCK

    # Step 2: classifier (shadow-mode only, pilot phase)
    if shadow_mode_enabled:
        classifier_result = classify_async(prompt_hash, prompt_excerpt)
        write_audit_row(
            level='L0',
            classifier_out=classifier_result,
            outcome='approve',  # shadow-mode: no production effect
            decided_at=now(),
        )

    # Step 3: L3 escalation check
    if requires_l3_review(prompt, metadata):
        row_id = write_audit_row(
            level='L3',
            outcome='escalate',
            decided_at=None,  # awaiting operator
        )
        operator_decision = await_operator_decision(row_id)
        update_audit_row(
            row_id,
            operator=operator_decision.who,
            outcome=operator_decision.result,
            decided_at=now(),
        )
        return operator_decision.result

    # Step 4: default allow
    write_audit_row(
        level='L0',
        outcome='approve',
        decided_at=now(),
    )
    return ALLOW
```

### Key rules

- `guardrail_hit != ''` → block immediately + write row with `outcome='deny'`
- `level == 'L3'` → ASK operator + write row with `outcome='escalate'`, wait for decision
- Shadow-mode classifier → write row for audit, no production effect
- Every decision path writes exactly one row before the action executes

---

## 4. No-Silent-Bypass Contract

### Invariants

1. **Every L3 decision produces an audit row BEFORE the action executes.**
   The audit write is synchronous; if it fails, the action is denied
   (fail-closed).

2. **NULL outcome is rejected at write time.** The `outcome` column uses
   Enum8 — only valid values are accepted. Escalated rows are written
   with `outcome='escalate'` and updated to the final decision.

3. **Audit completeness check:** For every ASK event in the system,
   a corresponding row must exist in `banxe_audit.hitl_decisions`
   within 5 seconds. Verified by the query in §5.

4. **No bypass path exists.** There is no code path that reaches an
   L3-classified action without passing through the escalation rule.
   This is enforced by middleware position in the request pipeline
   (before the router, after the guardrail).

---

## 5. Verification Queries (read-only)

These queries verify sink integrity. They do not modify data.

```sql
-- Count decisions by level and outcome (last 30 days)
SELECT
    level,
    outcome,
    count() AS cnt
FROM banxe_audit.hitl_decisions
WHERE ts >= now() - INTERVAL 30 DAY
GROUP BY level, outcome
ORDER BY level, outcome;

-- Find L3 decisions still awaiting operator (stale escalations)
SELECT *
FROM banxe_audit.hitl_decisions
WHERE level = 'L3'
  AND outcome = 'escalate'
  AND decided_at IS NULL
  AND ts < now() - INTERVAL 1 HOUR
ORDER BY ts DESC;

-- Completeness: ASKs without matching audit rows (should return 0)
-- Adapt system_asks to actual ASK event source
SELECT count(*)
FROM system_asks a
LEFT JOIN banxe_audit.hitl_decisions d
    ON a.ask_id = d.decision_id
WHERE d.decision_id IS NULL
  AND a.created_at < now() - INTERVAL 5 SECOND;

-- Daily decision volume (last 7 days)
SELECT
    toDate(ts) AS day,
    count() AS decisions
FROM banxe_audit.hitl_decisions
WHERE ts >= now() - INTERVAL 7 DAY
GROUP BY day
ORDER BY day;
```

---

## 6. Risks and Degradation

| Risk | Mitigation |
|---|---|
| ClickHouse unavailable | Degrade to local JSON log on the LiteLLM host. Resume sync to ClickHouse when available. Alert operator immediately. |
| Audit write latency > 100ms | Log warning, do not block user-facing response. Investigate ClickHouse cluster health. |
| Schema migration needed | Use ALTER TABLE (append-only columns). Never drop or rename existing columns. |
| Disk space exhaustion | Monitor partition sizes. 7-year TTL auto-expires old data. Alert at 80% capacity. |

---

## 7. Operator Actions Required

- [ ] Approve ClickHouse database and table name
- [ ] Approve column schema (especially JSON column for classifier_out)
- [ ] Approve 7-year TTL retention period
- [ ] Assign wiring task to connect escalation rule to compliance-api decision path
- [ ] Approve degradation strategy (local log fallback)

---

## 8. Decision

Condition D draft: COMPLETE.
Execution: NOT STARTED — requires operator approval of schema and
assignment of wiring task.

---

## 9. References

- PR #200 — custom_code guardrail
- PR #207 — HITL L3 agent gate policy
- PR #219 — Sprint 4 readiness audit
- PR #223 — Sprint 5 pilot plan
- POLICY-HITL-001, RB-HITL-001
