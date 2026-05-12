# Condition B — banxe-compliance-api Integration Contract (Draft)

Document ID: COND-B-DRAFT-2026-05-12
Status: DRAFT — proposed contract, not implemented
Scope: Condition B draft per Sprint 4 audit (PR #219)
Track: Innovation Sandbox / Conditions A–D batch (Clause 16)
Date: 2026-05-12

---

## 1. Scope

Condition B requires four artifacts:
1. Exact call site in banxe-compliance-api
2. Request/response contract
3. Failure behavior specification
4. Rollback behavior specification

This document drafts all four as a proposed contract for review by
the banxe-emi-stack team. **Sub-A does NOT modify the banxe-emi-stack
or banxe-compliance-api repositories.** This is a proposal document only.

---

## 2. Proposed Call Site

| Property | Value |
|---|---|
| Service | banxe-compliance-api |
| Endpoint | `POST /v1/internal/classify-prompt` |
| Trigger | Internal LiteLLM tap (Legion) during shadow-mode pilot |
| Direction | LiteLLM (caller) -> compliance-api (callee) |
| Network | Internal Tailscale mesh only — not exposed externally |

### Why this endpoint belongs in compliance-api

The classifier determines whether a prompt relates to regulated
activity (fraud, compliance, KYC/AML). This is a compliance
classification decision and belongs in the compliance service's
domain, even when operating in shadow-mode.

---

## 3. Request Contract

```
POST /v1/internal/classify-prompt HTTP/1.1
Host: banxe-compliance-api.internal
Authorization: Bearer <internal-svc-token>
Content-Type: application/json
X-Request-Id: <uuid>

{
    "prompt_hash": "sha256:abc123...",
    "prompt_excerpt": "first 500 chars, PII-stripped",
    "metadata": {
        "source": "litellm_shadow_tap",
        "model": "classifier:qwen2.5-0.5b",
        "ts": "2026-05-12T10:30:00.000Z"
    }
}
```

### Field definitions

| Field | Type | Required | Description |
|---|---|---|---|
| `prompt_hash` | string | YES | SHA-256 hash of the full prompt. Raw prompt is NOT transmitted. |
| `prompt_excerpt` | string | YES | First 500 characters of prompt, PII-stripped at the caller. Used for classification context. |
| `metadata.source` | string | YES | Identifies the calling system. Always `litellm_shadow_tap` during pilot. |
| `metadata.model` | string | YES | Classifier model identifier. |
| `metadata.ts` | string (ISO 8601) | YES | Timestamp of the original request. |

### PII handling

- The caller (LiteLLM tap) is responsible for PII stripping before
  transmission.
- The compliance-api endpoint does NOT receive raw prompts.
- The `prompt_hash` allows correlation with audit records without
  exposing content.

---

## 4. Response Contract

### 200 OK — classification successful

```json
{
    "decision_id": "550e8400-e29b-41d4-a716-446655440000",
    "class": "compliance_query",
    "confidence": 0.92,
    "audit_written": true
}
```

| Field | Type | Description |
|---|---|---|
| `decision_id` | UUID | Unique ID, matches the row in `banxe_audit.hitl_decisions` |
| `class` | enum | One of: `fraud_signal`, `compliance_query`, `reasoning_task`, `developer_task` |
| `confidence` | float | 0.0-1.0 confidence score from the classifier |
| `audit_written` | boolean | Confirms an audit row was written to ClickHouse |

### 4xx — client error

```json
{
    "error": "invalid prompt_hash format",
    "request_id": "550e8400-e29b-41d4-a716-446655440001"
}
```

### 5xx — server error

```json
{
    "error": "classifier unavailable",
    "request_id": "550e8400-e29b-41d4-a716-446655440001"
}
```

---

## 5. Failure Behavior

The caller (LiteLLM shadow tap) must handle failures gracefully.
The classifier is advisory during shadow-mode and must NEVER block
user-facing responses.

| Failure mode | Caller behavior |
|---|---|
| Timeout > 100 ms | Log timeout event, proceed without classification. Record in audit as `outcome='timeout'`. |
| HTTP 4xx | Log error, proceed without classification. Do not retry (likely malformed request). |
| HTTP 5xx | Log error, proceed without classification. Record in audit as `outcome='timeout'`. |
| Network unreachable | Log error, proceed without classification. Alert operator if sustained > 5 minutes. |
| `audit_written: false` in response | Log warning. Classification exists but audit trail is broken — flag for investigation. |

**Critical invariant:** The LiteLLM tap NEVER blocks the user-facing
response. Classification runs asynchronously after the response is
returned to the caller.

---

## 6. Rollback Behavior

1. **Disable LiteLLM tap** — one-line config change, no code deployment.
   The LiteLLM proxy stops sending requests to `/v1/internal/classify-prompt`.
2. **Endpoint remains live** — the compliance-api endpoint stays deployed
   but receives no traffic. No code removal needed.
3. **No data integrity risk** — all classification was shadow-mode only.
   No production routing decisions were influenced by the classifier.
4. **Audit records preserved** — all rows written to `banxe_audit.hitl_decisions`
   during the pilot remain for post-mortem analysis.

Rollback time: under 2 minutes (LiteLLM config revert + proxy restart).

---

## 7. Authentication and Rate Limiting

| Property | Value |
|---|---|
| Auth method | Bearer token (internal service token) |
| Token rotation | Quarterly |
| Rate limit | 100 requests/second per source |
| Hard cap | 10,000 requests/hour to prevent runaway |
| Rate limit response | HTTP 429 with `Retry-After` header |

### Token management

- Token is stored in the LiteLLM environment (not in config files).
- Token is NOT the same as any user-facing API key.
- Token rotation does not require endpoint redeployment — token
  validation uses a shared secret store.

---

## 8. Operator Actions Required

- [ ] Approve proposed endpoint path (`/v1/internal/classify-prompt`)
- [ ] Authorize Sub-A to open a draft PR against banxe-emi-stack with
      this contract, OR assign the implementation task to the
      banxe-emi-stack team directly
- [ ] Approve PII handling strategy (caller-side stripping)
- [ ] Approve rate limit values
- [ ] Assign token provisioning to infrastructure team

---

## 9. Decision

Condition B draft: COMPLETE.
Execution: NOT STARTED — requires operator authorization for cross-repo
PR or direct team assignment.

---

## 10. References

- PR #219 — Sprint 4 readiness audit
- PR #223 — Sprint 5 pilot plan
- `docs/audit/condition-d-hitl-audit-sink-2026-05-12.md` (audit sink contract)
