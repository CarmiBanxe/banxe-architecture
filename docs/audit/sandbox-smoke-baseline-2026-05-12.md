# Sandbox Pilot Smoke Baseline — 2026-05-12 10:30 UTC

Document ID: SANDBOX-SMOKE-BASELINE-2026-05-12
Status: BASELINE RUN
Owner: Sub-terminal A (autonomous per Clause 17)
Source: tools/sandbox/smoke-pilot-readiness-2026-05-12.sh (PR #248)

## Run output (verbatim, 2026-05-12T10:30:00Z)
- PASS Step 1 qwen2.5:0.5b on evo2
- SKIP Condition D ClickHouse (no local clickhouse-client)
- SKIP Condition B endpoint (env vars unset)
- FAIL Condition C reviewer not named
- FAIL Condition A dataset source not named
- PASS LiteLLM canonical config present
- PASS Shadow-tap not wired (expected gating state)
Summary: PASS=3 FAIL=2 SKIP=2, exit=1

## Interpretation
FAIL is expected at this stage. exit=0 will be the gate signal for Step 6 (apply shadow-tap).
SKIP is not green; only PASS counts toward readiness.

## Decision
PR #248 smoke harness confirmed functioning against current main.
Re-run after each operator/team activation to track progress toward Step 6.

## Hard rules
- Read-only baseline; no mutations triggered.
- Do NOT apply shadow-tap while any FAIL remains.
- Apply Step 6 (PR #238) only when exit=0.

Refs: PR #215, #223, #225, #234, #238, #240, #243, #247, #248
