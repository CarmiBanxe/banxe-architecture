# evo1 / evo2 Model Inventory — 2026-05-11
# ADR-035 ROADMAP Part 6 / Step 4 — Add evo2 as second LiteLLM backend
# Collected: 2026-05-11 via HTTP GET /api/tags (read-only)

## Collection Method

```
curl -sf http://100.68.102.48:11434/api/tags   # evo1 via Tailscale
curl -sf http://100.99.208.21:11434/api/tags   # evo2 via Tailscale
```

No mutations to evo1 or evo2 performed.

---

## Models Present on BOTH (load-balanceable)

| Model | Size | LiteLLM model_names using it |
|-------|------|------------------------------|
| `qwen3:30b-a3b` | 18.6 GB | `default`, `banxe/operations`, `ollama/glm-flash` |
| `llama3.3:70b` | 42.5 GB | `llama-3.3-70b`, `ollama/llama3.3-70b` |
| `qwen3.5:latest` | 6.6 GB | `ollama/qwen3.5-35b` |
| `qwen3.5:35b` | 23.9 GB | (not yet mapped in LiteLLM config) |
| `qwen3-coder-next:q4_K_M` | 51.7 GB | (not yet mapped in LiteLLM config) |
| `huihui_ai/glm-4.7-flash-abliterated:latest` | 18.8 GB | (not yet mapped in LiteLLM config) |
| `gurubot/gpt-oss-derestricted:20b` | 15.8 GB | (not yet mapped in LiteLLM config) |
| `qwen3:4b` | 2.5 GB | (not yet mapped in LiteLLM config) |

**Total shared storage:** ~180.9 GB duplicated across evo1+evo2

---

## evo1 Only

| Model | Size | Notes |
|-------|------|-------|
| `qwen2.5-coder:7b-instruct-q4_K_M` | 4.7 GB | Older coder; not on evo2 |

---

## evo2 Only

| Model | Size | Notes |
|-------|------|-------|
| `qwen3:235b-a22b` | 142.2 GB | Large reasoning model — requires evo2 RAM |
| `qwen3:235b-a22b-banxe` | 142.2 GB | Banxe-tuned variant of 235b |

evo2-only models require evo2 exclusively due to ~120+ GB RAM requirement.
These are NOT load-balanced (only one backend available).

---

## Full Inventory

### evo1 (100.68.102.48 — banxe-nucbox-evo-x2)

| Model | Size |
|-------|------|
| gurubot/gpt-oss-derestricted:20b | 15.8 GB |
| huihui_ai/glm-4.7-flash-abliterated:latest | 18.8 GB |
| llama3.3:70b | 42.5 GB |
| qwen2.5-coder:7b-instruct-q4_K_M | 4.7 GB |
| qwen3-coder-next:q4_K_M | 51.7 GB |
| qwen3.5:35b | 23.9 GB |
| qwen3.5:latest | 6.6 GB |
| qwen3:30b-a3b | 18.6 GB |
| qwen3:4b | 2.5 GB |
| **Total** | **185.1 GB** |

### evo2 (100.99.208.21 — banxe-nucbox-evo-x2-2)

| Model | Size |
|-------|------|
| gurubot/gpt-oss-derestricted:20b | 15.8 GB |
| huihui_ai/glm-4.7-flash-abliterated:latest | 18.8 GB |
| llama3.3:70b | 42.5 GB |
| qwen3-coder-next:q4_K_M | 51.7 GB |
| qwen3.5:35b | 23.9 GB |
| qwen3.5:latest | 6.6 GB |
| qwen3:235b-a22b | 142.2 GB |
| qwen3:235b-a22b-banxe | 142.2 GB |
| qwen3:30b-a3b | 18.6 GB |
| qwen3:4b | 2.5 GB |
| **Total** | **463.3 GB** |

---

## LiteLLM model_list Changes Applied (Part 6)

Added 6 evo2 entries (one per existing evo1 model_name with shared model):

| model_name | model | evo2 api_base |
|-----------|-------|--------------|
| `default` | `ollama/qwen3:30b-a3b` | `http://100.99.208.21:11434` |
| `banxe/operations` | `ollama/qwen3:30b-a3b` | `http://100.99.208.21:11434` |
| `ollama/glm-flash` | `ollama/qwen3:30b-a3b` | `http://100.99.208.21:11434` |
| `llama-3.3-70b` | `ollama/llama3.3:70b` | `http://100.99.208.21:11434` |
| `ollama/llama3.3-70b` | `ollama/llama3.3:70b` | `http://100.99.208.21:11434` |
| `ollama/qwen3.5-35b` | `ollama/qwen3.5:latest` | `http://100.99.208.21:11434` |

Router strategy: `simple-shuffle` (already configured in Part 4).
LiteLLM distributes requests round-robin across all entries with the same `model_name`.

---

## Distribution Verification (2026-05-11 14:29 CEST)

6 requests sent to `model=default`. Result from Ollama `/api/ps`:

| Node | Model loaded | Expires |
|------|-------------|---------|
| evo1 (100.68.102.48) | qwen3:30b-a3b | 14:39:17.215 |
| evo2 (100.99.208.21) | qwen3:30b-a3b | 14:39:17.704 |

Both nodes loaded the model within 489ms of each other — confirms requests
were distributed by LiteLLM simple-shuffle across both backends.

---

## Deduplication Opportunity (Step 3)

~180.9 GB duplicated across nodes. Candidate for Step 3 (model dedup):

| Model | Recommended canonical node | Rationale |
|-------|--------------------------|-----------|
| `qwen3:235b-a22b*` | evo2 only | Needs 120+ GB RAM; evo1 RAM constrained by services |
| `qwen3-coder-next:q4_K_M` | evo1 (primary) | Coding workload primary on evo1 |
| `llama3.3:70b` | Both (keep as LB pair) | High demand general model |
| `qwen3:30b-a3b` | Both (keep as LB pair) | Default model, LB is the point |

Step 3 (dedup analysis) can now proceed using this inventory as the source of truth.

---

*Collected read-only by Sub-terminal A under SESSION-CANON 2026-05-11*
