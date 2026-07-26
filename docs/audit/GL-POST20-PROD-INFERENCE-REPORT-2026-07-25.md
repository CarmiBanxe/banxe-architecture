# GL-post-20 — Prod-Inference Wiring Report — 2026-07-25

**BANK CORE / GL-post-20 PROD-INFERENCE / STAGED / PROPOSES-ONLY / NO CODE-SECRETS / NO COMMIT**

## Status: **WIRED — proposes-only; live call [pending env key]** (:8200 preserved, :4000 bank gateway)

Banksy is now wired to inference via the **bank LiteLLM gateway :4000** (NOT Legion :8080), proposes-only
(I-27). No API key was set by the operator, so no live model call was made — status **[pending env key]**,
honestly (not a failure). The engine on :8200 stayed green throughout.

## ШАГ 0 — snapshot
- Backup: `banksy-engine.config.toml.pre-inference.bak`; pre `/status` saved.

## ШАГ 1 — inference client (0 secrets)
- Created `banksy/inference_client.py` (stdlib urllib): reads env `BANKSY_INFERENCE_URL` (default
  `http://127.0.0.1:4000/v1`), `BANKSY_MODEL`, `BANKSY_LLM_KEY` — **key env-only, 0 hardcoded**.
- Guard: default endpoint :4000; **never :8080** (Legion); `direct_legion_infer=False`.

## ШАГ 2 — proposes-only wiring (I-27 preserved)
- `main.py` surfaces inference into `/status`; `propose()` returns a **PROPOSAL, never an executed action**.
- `decision_framework_proposes_only=true` unchanged; inference generates proposals, human decides.

## ШАГ 3 — dry-test (measured)
- `BANKSY_LLM_KEY` **not set** by operator → `propose()` returned
  `{"proposes_only": true, "status": "pending-env-key", "note": "BANKSY_LLM_KEY not set; no live call made"}`.
- LiteLLM :4000 baseline = HTTP 401 (needs key — normal). **No live 200 claimed.** `[pending env key]`.

## ШАГ 4 — reload + LIVE-status verify (measured NOW)
- Controlled restart of ONLY the Banksy process; `:8200` `/health` green (32 modules).
- `/status`: `inference_wired=true`, `inference_endpoint=http://127.0.0.1:4000/v1`,
  `inference_proposes_only=true`, `inference_key_present=false`, `direct_legion_infer=false`,
  `decision_framework_proposes_only=true`. MCP `tools[]` (6) and `tools_endpoint_set=true` NOT regressed.

## Gates
| gate | result |
|---|---|
| Canon-Guardian — inference via :4000 bank gateway, NOT Legion :8080; `direct_legion_infer=false` | PASS |
| Factory-Watchdog — 0 hardcoded secrets (key env-only) | PASS |
| Factory-Watchdog — :8200 green after reload; MCP tools intact | PASS |
| I-27 — proposes-only preserved (inference proposes, human decides) | PASS |
| Live inference — **NOT claimed** (no env key → pending); honest | `[pending env key]` |

## Rollback
Controlled additive change. Rollback = restore `*.pre-inference.bak`, remove `inference_client.py` wiring, restart engine.

## Gated / open
- **Live inference** needs operator to set `BANKSY_LLM_KEY` (+ `BANKSY_MODEL`) in env → then a real 200 round-trip.
- **write-tools / ledger** remain `[counsel]` — inference proposes only; no autonomous write.
- Legion (:8080) untouched, external-only; `direct_legion_infer=false`.

---
**This does not replace legal advice.**
