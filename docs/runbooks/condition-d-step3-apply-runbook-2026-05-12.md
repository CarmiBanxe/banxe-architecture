# Condition D Step 3 — Apply Runbook (2026-05-12)

Document ID: RB-CONDITION-D-STEP3-2026-05-12
Status: READY — operator + Sub-A apply in sequence
Owner: operator (DDL) + Sub-A (LiteLLM hook)

## Files in this package
- sql/create-banxe-audit-hitl-decisions-2026-05-12.sql
- patches/litellm-guardrail-audit-hook-2026-05-12.py
- patches/README.md
- docs/runbooks/condition-d-step3-apply-runbook-2026-05-12.md (this file)

## Apply order
1. Operator reviews SQL DDL.
2. Operator runs DDL on production ClickHouse (NOT Sub-A).
3. Verify: SHOW TABLES FROM banxe_audit; SHOW CREATE TABLE banxe_audit.hitl_decisions;
4. Operator sets CLICKHOUSE_HOST / CLICKHOUSE_PASSWORD in
   ~/.config/litellm/.env (chmod 600).
5. Operator installs Python dep on Legion if missing:
   pip install clickhouse-driver
6. Sub-A under Clause 17:
   - Pre-flight conflict check
   - Backup ~/litellm-config.yaml -> ~/litellm-config.yaml.bak-condition-d-pre
   - Replace existing block-regulated-paths custom_code block
     with content of patches/litellm-guardrail-audit-hook-2026-05-12.py
   - Validate YAML
   - systemctl --user restart litellm
   - Smoke test: regulated keyword prompt blocked + row appears in
     banxe_audit.hitl_decisions within 5s
   - Self-fix HITL-ASK-2026-05-12-002 with pre/post state

## Acceptance
- Smoke regulated prompt blocked at LiteLLM
- Row count in banxe_audit.hitl_decisions increases by 1 within 5s
- LiteLLM journal shows no errors
- Existing non-regulated routing unaffected

## Rollback (Sub-A self-fix under Clause 17)
- cp ~/litellm-config.yaml.bak-condition-d-pre ~/litellm-config.yaml
- systemctl --user restart litellm
- Write HITL-ASK rollback row with outcome=deny and reason

## Hard rules
- Sub-A never executes the ClickHouse DDL.
- No silent bypass: every guardrail decision MUST produce a row.
- If sink unreachable: fail-closed via Python exception (guardrail
  blocks the request), local fallback log in
  ~/banxe-dev/audit-staging/hitl-fallback.log
- Rollback never deletes rows from hitl_decisions (TTL handles that).
