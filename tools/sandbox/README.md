# Sandbox Pilot Smoke Harness

Document ID: TOOLS-SANDBOX-SMOKE-2026-05-12
Status: READY (read-only)

## Purpose
One-shot, read-only check of whether the sandbox pilot is safe to
activate (Step 6 in SANDBOX-ACTIVATION-ORDER-2026-05-12.md).

Reports PASS / FAIL / SKIP for each of 7 checks:
1. qwen2.5:0.5b present on evo2 (Step 1)
2. ClickHouse banxe_audit.hitl_decisions table exists (Condition D)
3. classify-prompt endpoint reachable + 200 (Condition B)
4. Evaluation protocol reviewer slot filled (Condition C)
5. Training dataset source named (Condition A)
6. LiteLLM canonical config present
7. Shadow-tap NOT yet wired (must remain absent until Step 6 apply)

## Usage
```bash
./tools/sandbox/smoke-pilot-readiness-2026-05-12.sh
```

Environment variables that unlock optional checks:
- CLICKHOUSE_HOST, CLICKHOUSE_PORT
- BANXE_COMPLIANCE_API_URL, BANXE_INTERNAL_SVC_TOKEN

Without those, checks SKIP rather than FAIL. SKIP is not a green
light — only PASS counts toward activation readiness.

## Hard rules
- Script is read-only. No writes, no DDL, no curl mutations.
- Script does not create the shadow tap. It only verifies state.
- Exit code 0 only when FAIL=0 (SKIPs allowed).
- Use this script as the pre-flight check before Step 6 apply
  (Clause 17 conflict check requires it).
