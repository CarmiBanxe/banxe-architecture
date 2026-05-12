# Sandbox Activation Order — 2026-05-12

Document ID: SANDBOX-ACTIVATION-ORDER-2026-05-12
Status: BINDING for shadow-tap rollout
Owner: Sub-terminal A (autonomous per Clause 17)
Captured by: operator at 2026-05-12 ~11:30 CEST

## Order
1. Confirm evo2 model presence: qwen2.5:0.5b pre-staged
   (DONE — HITL-ASK-2026-05-12-001 / PR #234)
2. Condition C — assign named reviewer (CTIO or MLRO)
3. Condition D — prepare ClickHouse DDL + guardrail hook update
4. Condition B — open banxe-compliance-api endpoint PR in banxe-emi-stack
5. Condition A — request/confirm dataset from data team
6. After A+B+C+D explicitly satisfied, apply LiteLLM shadow-tap patch
   (PR #238 — RUNBOOK-LITELLM-SHADOW-TAP-2026-05-12)

## Operator owners per step
- Step 1: SUB-A (done)
- Step 2: operator (assigns reviewer)
- Step 3: operator (ClickHouse DDL exec) + SUB-A (guardrail hook config)
- Step 4: banxe-emi-stack team (cross-repo PR)
- Step 5: data team + operator
- Step 6: SUB-A under Clause 17 conflict check + new HITL-ASK

## Cross-references
- Drafts: PR #225 (Conditions A/B/C/D)
- Pilot plan: PR #223 (Sprint 5)
- Readiness audit: PR #219 (Sprint 4)
- Candidate matrix: PR #217 (Sprint 3)
- Sandbox roadmap: PR #215 (Sprint 1+2 plus ML-track gating)
- Model pre-stage: PR #234 (HITL-ASK-2026-05-12-001)
- Activation patch: PR #238 (shadow-tap, not applied)

## Hard rules
- No step skipping. Step N requires Step N-1 explicit completion.
- Every step closure produces a HITL-ASK entry in
  docs/audit/hitl-decisions-<date>.md.
- Step 6 (apply patch) is a Clause 17 L3 self-fixed action: pre-check,
  apply, post-check, audit row.
- Rollback path of Step 6 stays per PR #238 §Rollback.
