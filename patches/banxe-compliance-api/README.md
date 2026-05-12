# Condition B Step 4 — classify-prompt endpoint stub

Status: PREPARED / NOT APPLIED
Source contract: docs/audit/condition-b-compliance-api-integration-2026-05-12.md (PR #225)

## Files
- classify-prompt-stub-2026-05-12.py — FastAPI endpoint stub

## Notes
- The stub implements the request/response contract from PR #225.
- Auth: Bearer token from env BANXE_INTERNAL_SVC_TOKEN.
- Classifier backend: evo2 Ollama qwen2.5:0.5b (pre-staged in PR #234).
- Audit sink: writes via Condition D ClickHouse table
  (banxe_audit.hitl_decisions, DDL in PR #243).
- Timeout: 100 ms. On classifier failure -> cls="unknown",
  confidence=0.0, audit row still written.
- Never blocks caller. Never alters production routing.

## How banxe-emi-stack team applies this
1. Copy classify-prompt-stub-2026-05-12.py into the banxe-compliance-api
   service tree (path determined by emi-stack maintainers).
2. Wire into existing FastAPI app via include_router or app.mount.
3. Set env vars in service config:
   - BANXE_INTERNAL_SVC_TOKEN
   - CLASSIFIER_URL (default http://100.99.208.21:11434/api/generate)
   - CLASSIFIER_MODEL (default qwen2.5:0.5b)
   - CLICKHOUSE_HOST / CLICKHOUSE_PASSWORD
4. Add pytest smoke test (sample below) for the endpoint.
5. Open PR in banxe-emi-stack. Tag this artifact for review.

## Smoke test (sample)
```bash
curl -s -X POST http://localhost:8080/v1/internal/classify-prompt \
  -H "Authorization: Bearer $BANXE_INTERNAL_SVC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"prompt_hash":"abc","prompt_excerpt":"hello world",
       "metadata":{"source":"litellm_shadow_tap",
                   "model":"classifier:qwen2.5-0.5b",
                   "ts":"2026-05-12T11:00:00Z"}}' | jq .
```

## Hard rules
- Sub-A does NOT push or modify banxe-emi-stack.
- Stub is read-only artifact in banxe-architecture for emi-stack team.
- Stub MUST NOT be deployed without Condition D sink already live
  and Condition C reviewer named.
