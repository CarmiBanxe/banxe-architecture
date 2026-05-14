# Runbook: Ruflo Checkpoint Rejection Handling
## Trigger
Ruflo checkpoint final_verdict = REJECTED.
## Steps
1. Read rejection reason from `gates_completed` array.
2. Identify which gate rejected: operator / mlro / ctio.
3. If operator: discuss with Moriel Carmi, address feedback.
4. If mlro: compliance concern — fix AML/KYC/CASS paths, re-evaluate.
5. If ctio: architecture concern — fix ADR/model/cluster paths, re-evaluate.
6. Re-submit through factory loop from Step 3 (Evaluate).
## Rollback
No code was merged (rejection happens pre-merge). No rollback needed.
Record rejection in ClickHouse ruflo_checkpoints table for audit trail.
