# Conditions A/B/C/D Activation Runbook

Document ID: RB-ABCD-ACTIVATE-2026-05-12
Status: PLANNED / NOT STARTED
Scope: Operational runbook for activating each pilot prerequisite
Track: Innovation Sandbox / Conditions A–D batch (Clause 16)
Date: 2026-05-12

---

## 1. Activation Order

Conditions must be activated in this order:

```
D (audit sink) -> C (evaluation protocol) -> B (compliance-api) -> A (dataset)
```

Rationale: technical foundation first.

- D must be live before C evaluation data is collected (audit trail
  must exist before any model predictions are recorded).
- B must be deployed before A is loaded (so labels can be sourced
  from production tap if operator chooses that data source).
- C reviewer must be named before any pilot benchmarking.

---

## 2. Condition D Activation — HITL Audit Sink

Reference: `docs/audit/condition-d-hitl-audit-sink-2026-05-12.md`

### Steps

1. **Operator runs ClickHouse DDL** from the Condition D draft document.
   - Execute the `CREATE TABLE` statement on the target ClickHouse cluster.
   - Verify table exists: `SELECT count() FROM banxe_audit.hitl_decisions`
     should return 0.

2. **Operator approves LiteLLM custom_code guardrail hook update.**
   - The existing guardrail (PR #200) must be extended to emit an audit
     row on every block event.
   - Operator reviews the proposed hook change before deployment.

3. **Sub-A under Clause 15** coordinates with central terminal, then
   updates the guardrail to emit an audit row on every block.
   - This is a config-level change to the LiteLLM custom_code hook.
   - Requires central-coordination ASK before execution.

4. **Smoke test:** send a regulated-keyword prompt through the LiteLLM
   proxy and verify a row appears in `banxe_audit.hitl_decisions`.
   - Expected: `outcome='deny'`, `guardrail_hit` populated, `level='L3'`.
   - If no row: investigate and do not proceed to Condition C.

### Exit criteria

- [ ] Table `banxe_audit.hitl_decisions` exists and accepts writes
- [ ] Guardrail hook emits audit row on every block
- [ ] Smoke test produces expected row
- [ ] Verification queries from Condition D document return valid results

---

## 3. Condition C Activation — Evaluation Protocol

Reference: `docs/audit/condition-c-evaluation-protocol-2026-05-12.md`

### Steps

1. **CTIO or MLRO names reviewer** in the Condition C document.
   - Fill the reviewer slot: "Reviewer: ________ (CTIO or MLRO)"
   - This is an operator/CTIO action.

2. **Reviewer approves metric thresholds.**
   - Reviewer reviews the proposed acceptance thresholds (accuracy >= 85%,
     F1 >= 0.80, p99 < 100 ms, false-block = 0%).
   - Reviewer may adjust thresholds with documented justification.
   - Adjusted thresholds are recorded in the same document.

3. **Sub-A reads off acceptance gates** from the approved Condition C
   document and prepares the evaluation pipeline configuration.
   - No execution until Conditions A and B are also active.

### Exit criteria

- [ ] Reviewer named and recorded in document
- [ ] Thresholds approved (or adjusted with justification)
- [ ] Evaluation procedure understood by all parties

---

## 4. Condition B Activation — banxe-compliance-api Integration

Reference: `docs/audit/condition-b-compliance-api-integration-2026-05-12.md`

### Steps

1. **banxe-emi-stack team opens PR** using the Condition B contract as
   specification.
   - The draft contract defines endpoint, request/response format,
     failure behavior, and rate limits.
   - This PR is opened and reviewed in banxe-emi-stack (outside Sub-A
     authority).

2. **PR review + merge in banxe-emi-stack.**
   - Standard banxe-emi-stack review process applies.
   - Sub-A has no role in this step.

3. **After endpoint deployed,** Sub-A under Clause 15 verifies
   reachability from Legion.
   - `curl -s -o /dev/null -w '%{http_code}' POST https://banxe-compliance-api.internal/v1/internal/classify-prompt`
   - Expected: 401 (unauthorized, since no valid token sent) or 400
     (bad request). Either confirms endpoint is live.
   - If unreachable: investigate Tailscale mesh and do not proceed.

### Exit criteria

- [ ] Endpoint deployed in banxe-compliance-api
- [ ] Endpoint reachable from Legion via Tailscale mesh
- [ ] Internal service token provisioned
- [ ] Rate limits configured as specified

---

## 5. Condition A Activation — Training Dataset

Reference: `docs/audit/condition-a-training-dataset-2026-05-12.md`

### Steps

1. **Operator names dataset source** per the Condition A template.
   - Operator decides which data source to use.
   - Operator approves storage location and handling path.

2. **Data team labels samples** per quality controls in the Condition A
   document.
   - Two independent labelers per sample.
   - Disagreements escalated to senior reviewer.
   - Minimum 4000 labeled samples (1000 per class).

3. **Sub-A receives storage location pointer** and verifies access.
   - Verify schema compliance: all required fields present.
   - Verify class distribution: approximately equal across 4 classes.
   - Verify split ratio: 80/10/10 train/val/test.
   - Sub-A does NOT modify the dataset.

### Exit criteria

- [ ] Data source named by operator
- [ ] Storage location approved
- [ ] Handling path approved
- [ ] 4000+ labeled samples available
- [ ] Schema validation passes
- [ ] Class distribution balanced
- [ ] Split ratio correct

---

## 6. Cross-Condition Checks

Before declaring all conditions DONE, verify these dependencies:

| Check | Verification |
|---|---|
| D live before C eval | Audit sink accepts writes before any evaluation run |
| B deployed before A loaded | compliance-api endpoint is reachable before dataset is used for shadow-mode tap |
| C reviewer named before benchmarking | Reviewer slot is filled before any pilot metrics are collected |
| Audit trail complete | Every condition activation step produced at least one row in `banxe_audit.hitl_decisions` |

### Activation readiness gate

All four conditions must show DONE before the pilot activation ASK
(Sprint 5, Day 0) can be submitted. The ASK itself is a separate
operator decision — completing conditions does not auto-start the pilot.

---

## 7. Rollback per Condition

### Condition D rollback

- Drop the ClickHouse table (operator decision, data loss).
- Or: keep the table but revert the guardrail hook to pre-activation
  state (no new rows written, existing data preserved).
- Degraded mode: switch to local JSON logging on LiteLLM host.

### Condition C rollback

- Revoke reviewer naming (operator decision).
- No technical rollback needed — the evaluation protocol is a document.

### Condition B rollback

- Remove or disable the `/v1/internal/classify-prompt` endpoint in
  banxe-compliance-api (banxe-emi-stack team decision).
- Disable LiteLLM shadow tap (one-line config revert).
- No data integrity risk — shadow-mode only.

### Condition A rollback

- Revoke dataset access (operator decision).
- Dataset remains on-prem storage; no deletion without operator
  approval.
- If dataset quality is insufficient, pause labeling and revise
  guidelines.

---

## 8. Do-Not-Do

- **No silent activation.** Every condition activation step must log
  to `banxe_audit.hitl_decisions` or produce a written record.
- **No skipping audit trail.** If the audit sink is down, do not
  proceed with any other condition activation.
- **No combining activations** into a single maintenance window without
  separate central-coordination ASKs for each condition.
- **No Sub-A autonomous activation.** Each step requires either operator
  approval or Clause 15 central coordination.
- **No cross-repo mutations by Sub-A.** banxe-compliance-api and
  banxe-emi-stack changes are owned by their respective teams.

---

## 9. References

- `docs/audit/condition-a-training-dataset-2026-05-12.md`
- `docs/audit/condition-b-compliance-api-integration-2026-05-12.md`
- `docs/audit/condition-c-evaluation-protocol-2026-05-12.md`
- `docs/audit/condition-d-hitl-audit-sink-2026-05-12.md`
- PR #219 — Sprint 4 readiness audit
- PR #223 — Sprint 5 pilot plan
- POLICY-HITL-001, RB-HITL-001
