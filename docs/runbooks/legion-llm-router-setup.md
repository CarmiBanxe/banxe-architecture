# Runbook: Legion LLM Router (LiteLLM Proxy — Part 4 Canonical Config)
**Environment:** Legion WSL2
**Date:** 2026-05-11
**ADR:** ADR-035, Part 4 / Step 6
**Status:** ACTIVE — canonical endpoint `:8080` on `127.0.0.1`

---

## 1. Architecture

```
Claude Code / dev tools
       │
       ▼
LiteLLM Proxy (Legion :8080, 127.0.0.1 only)
  systemd: litellm.service
  config:  ~/litellm-config.yaml
       │
       ├── model: default ──────────────────► evo1 Ollama (100.68.102.48:11434)
       │   (Priority 1 — local, within EMI)    qwen3:30b-a3b
       │
       └── model: fallback-claude ──────────► Anthropic claude-sonnet-4-6
           (ONLY if evo1 unreachable AND       GUARDRAIL: block-regulated-paths
            guardrail passes)                  pre_call keyword blocking
                                               NEVER for: iban, kyc_id, national_id,
                                               aml_flag, transaction_id, /kyc/, /aml/, /compliance/
```

---

## 2. Canonical Config Sections Added (Part 4)

All changes are in `~/litellm-config.yaml` (managed by systemd `litellm.service`).
**Do NOT edit MetaClaw config** (`~/MetaClaw/litellm/litellm-config.v2.yaml`) — it is archived.

### 2.1 Models added

```yaml
# Priority 1 — evo1 Ollama via Tailscale
- model_name: "default"
  litellm_params:
    model: "ollama/qwen3:30b-a3b"
    api_base: "http://100.68.102.48:11434"
    timeout: 120

# Anthropic fallback — GUARDRAIL PROTECTED
- model_name: "fallback-claude"
  litellm_params:
    model: "claude-sonnet-4-6"
    api_key: "os.environ/ANTHROPIC_API_KEY"
```

### 2.2 Router settings added

```yaml
router_settings:
  routing_strategy: simple-shuffle
  default_fallbacks:
    - fallback-claude
  timeout: 30
  num_retries: 2
```

Note: `default_fallbacks` is the correct LiteLLM 1.82.0 key.
`fallback_models` (spec draft) is silently ignored by this version.

### 2.3 Guardrail added

```yaml
guardrails:
  - guardrail_name: "block-regulated-paths"
    litellm_params:
      guardrail: "custom_code"    # NOT "presidio" — Presidio not installed
      mode: "pre_call"
      default_on: true
      custom_code: |
        def apply_guardrail(inputs, request_data, input_type):
            regulated_keywords = [
                "/compliance/", "/kyc/", "/aml/",
                "kyc_id", "aml_flag", "transaction_id",
                "iban", "national_id",
            ]
            texts = inputs.get("texts") or []
            for text in texts:
                tl = lower(text)
                for kw in regulated_keywords:
                    if contains(tl, kw.lower()):
                        return block("Request blocked: regulated path/keyword '" + kw + "'")
            return allow()
```

**Why `custom_code` not `presidio`:** Microsoft Presidio is not installed in the LiteLLM
pipx venv (`presidio_analyzer` not importable). `custom_code` is LiteLLM-native, no deps.
The `allow()`, `block()`, `lower()`, `contains()` primitives are built into LiteLLM 1.82.0.

---

## 3. Service Management

```bash
# Restart after config change
systemctl --user restart litellm

# Status
systemctl --user status litellm --no-pager -l

# Logs (last 50 lines)
journalctl --user -u litellm -n 50 --no-pager

# Verify only one listener (127.0.0.1:8080, NOT 0.0.0.0:4000)
ss -tlnp | grep -E ':4000|:8080'
```

---

## 4. Environment Variables

Secrets are injected via systemd EnvironmentFile, NOT in the YAML config.

File: `~/.config/litellm/.env` (chmod 600, NOT in any git repo)

Required variables:
```
ANTHROPIC_API_KEY=<value>
REDIS_PASS=<value>
LITELLM_MASTER_KEY=<value>
```

The `litellm.service` unit file has `EnvironmentFile=%h/.config/litellm/.env`.
**Never add secrets to `~/litellm-config.yaml`** — it is not secret-protected.

---

## 5. Smoke Tests

Run after any config change or service restart:

### 5.1 Positive — non-regulated prompt → evo1 Ollama

```bash
MASTER_KEY=$(grep "^LITELLM_MASTER_KEY" ~/.config/litellm/.env | cut -d= -f2)

curl -s http://localhost:8080/v1/chat/completions \
  -H "Authorization: Bearer $MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"default","messages":[{"role":"user","content":"ping router test"}]}' \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('model:', d.get('model')); print('reply:', d['choices'][0]['message']['content'][:80])"
# Expected: model=default, reply from evo1 Ollama
```

### 5.2 Negative — regulated keyword → guardrail block (must NOT reach Anthropic)

```bash
MASTER_KEY=$(grep "^LITELLM_MASTER_KEY" ~/.config/litellm/.env | cut -d= -f2)

curl -s http://localhost:8080/v1/chat/completions \
  -H "Authorization: Bearer $MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"default","messages":[{"role":"user","content":"/kyc/ verify this iban DE89370400440532013000"}]}' \
  | python3 -m json.tool
# Expected: {"error": {"message": "Custom code guardrail execution failed: Request blocked..."}}
# The request must NOT appear in Anthropic API usage logs.
```

**Verified results (2026-05-11):**
- Positive: `model: default`, reply `pong` ✅
- Negative: guardrail block `regulated path/keyword '/kyc/'` ✅ (Anthropic NOT reached)

---

## 6. Guardrail Keyword Reference

| Keyword | Reason blocked |
|---|---|
| `/compliance/` | Compliance path prefix |
| `/kyc/` | KYC path prefix |
| `/aml/` | AML path prefix |
| `kyc_id` | KYC identifier field |
| `aml_flag` | AML flag field |
| `transaction_id` | Financial transaction identifier |
| `iban` | International Bank Account Number |
| `national_id` | Personal identification number |

Matching is **case-insensitive** (lowercased before check).
To add keywords: edit `custom_code` in `~/litellm-config.yaml`, restart service.
**Never remove keywords without MLRO/CTIO sign-off** — this is a compliance control (I-27).

---

## 7. Do-Not-Do

| Action | Why forbidden |
|---|---|
| Add evo2 (`192.168.0.15:*`) as backend | evo2 is production inference — Part 5 only |
| Bind to `0.0.0.0` | Exposes LiteLLM to all Legion interfaces — MetaClaw A-8 finding |
| Hardcode `ANTHROPIC_API_KEY` in YAML | Semgrep `banxe-hardcoded-secret` — always env var |
| Remove `block-regulated-paths` guardrail | Compliance control — I-27 HITL, UK GDPR Art.44 |
| Start second LiteLLM process manually | Causes A-8-class port collision and config split |
| Install Presidio without testing isolation | Presidio NER models may surface PII in logs |
| Point `fallback-claude` to regulated content | Anthropic is outside EMI perimeter for regulated data |

---

## 8. MetaClaw Reference

MetaClaw was a comprehensive local-model routing gateway (30+ routes, evo1+evo2+RPC).
It was stopped as part of A-8 resolution. Its config is archived (not deleted) at:
`/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml.bak-2026-05-11`

Model routes from MetaClaw that may be useful in future canonical config merges:
- `factory-*` aliases (qwen3-coder, llama3.3, qwen3:30b)
- `reasoning` / `reasoning-235b` (evo2 qwen3:235b + evo2 llama-server RPC)
- `glm-4.5-air` (evo1 llama-server :8081)

See `docs/audit/a8-metaclaw-resolution-2026-05-11.md` for full investigation.

---

## 9. evo2 Backend — Load Balancing (Part 6, 2026-05-11)

evo2 (`100.99.208.21:11434`) added as second backend for shared models.
LiteLLM `simple-shuffle` distributes requests across all entries with the same `model_name`.

### 9.1 Architecture (updated)

```
LiteLLM Proxy (Legion :8080, 127.0.0.1 only)
       │
       ├─ model: default ──── simple-shuffle ──► evo1 :11434  qwen3:30b-a3b
       │                                    └──► evo2 :11434  qwen3:30b-a3b
       │
       ├─ model: llama-3.3-70b ─────────────► evo1 :11434  llama3.3:70b
       │                                  └──► evo2 :11434  llama3.3:70b
       │
       ├─ model: banxe/operations ──────────► evo1 :11434  qwen3:30b-a3b
       │                                  └──► evo2 :11434  qwen3:30b-a3b
       │
       ├─ model: ollama/llama3.3-70b ───────► evo1 :11434  llama3.3:70b
       │                                  └──► evo2 :11434  llama3.3:70b
       │
       ├─ model: ollama/glm-flash ──────────► evo1 :11434  qwen3:30b-a3b
       │                                  └──► evo2 :11434  qwen3:30b-a3b
       │
       ├─ model: ollama/qwen3.5-35b ────────► evo1 :11434  qwen3.5:latest
       │                                  └──► evo2 :11434  qwen3.5:latest
       │
       └─ model: fallback-claude ───────────► Anthropic claude-sonnet-4-6
           (guardrail-gated — keyword block active)
```

### 9.2 Distribution verification

After restart, send 6 requests to `model=default`. Both nodes should load the model:

```bash
MASTER_KEY=$(grep "^LITELLM_MASTER_KEY" ~/.config/litellm/.env | cut -d= -f2)
for i in $(seq 1 6); do
  curl -s --max-time 30 http://127.0.0.1:8080/v1/chat/completions \
    -H "Authorization: Bearer $MASTER_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"default\",\"messages\":[{\"role\":\"user\",\"content\":\"/no_think ping$i\"}],\"max_tokens\":5}" \
    -o /dev/null -w "req$i: HTTP %{http_code}\n"
done

# Then check both nodes loaded the model:
curl -s http://100.68.102.48:11434/api/ps   # evo1
curl -s http://100.99.208.21:11434/api/ps   # evo2
```

Verified result (2026-05-11 14:29 CEST): both evo1 and evo2 showed `qwen3:30b-a3b` loaded
with expiry times 489ms apart — confirming simple-shuffle distribution ✅.

### 9.3 evo2-only models (NOT load-balanced)

`qwen3:235b-a22b` and `qwen3:235b-a22b-banxe` are evo2-only (142 GB each).
Add dedicated model_name entries pointing ONLY to evo2 when needed:

```yaml
- model_name: reasoning-235b
  litellm_params:
    model: ollama/qwen3:235b-a22b-banxe
    api_base: http://100.99.208.21:11434
    timeout: 600
```

### 9.4 Do-Not-Do (updated)

| ~~Old rule~~ | New status |
|---|---|
| ~~Add evo2 as backend~~ | **DONE in Part 6 — evo2 IS a backend now** |

Rule updated: evo2 is now the second canonical Ollama backend. Do not add a third
backend without a Part 7+ ROADMAP step.

