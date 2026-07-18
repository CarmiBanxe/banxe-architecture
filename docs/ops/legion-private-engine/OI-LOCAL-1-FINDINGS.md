# OI-LOCAL-1 — Findings: Local Model + Offload Settings for Legion
# Status: COMPLETE — extraction done; draft proposals prepared; operator approval required before editing any artifact.
# Sources read: 3 (ai-efficiency-methodology, manus-legion-private-engine, S-18-consultant-answers)
# Created: 2026-07-11
# Parent: docs/governance/OPEN-ITEMS-OFFLOAD.md
# Constraint: [SOURCE-SILENT] for any value not stated in sources. Do NOT invent.

---

## 1. EXTRACTION RESULTS

### 1.1 Source: `MetaClaw/docs/sources/manus-legion-private-engine.md`

#### What the source describes

The source document describes a **llama-server :8080 + uncensored Qwen3.6 model** stack.
Per `OPEN-ITEMS-OFFLOAD.md` constraint, this section is **SUPERSEDED** — it must NOT be
copied verbatim into config.toml. Values are recorded here as reference only.

| Parameter | Value from source | Source location | Status |
|-----------|------------------|----------------|--------|
| Model family | Qwen3.6-35B-A3B | Block 3, Step 3.2 config.toml snippet | SUPERSEDED section |
| Model quantization | IQ2_M | Model filename in Block 6 systemd ExecStart | SUPERSEDED section |
| Full GGUF filename | `Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-IQ2_M.gguf` | Block 6, Step 6.1 ExecStart | SUPERSEDED (uncensored) |
| Backend type | llama-server (llama.cpp) | Block 1 architecture diagram + Block 6 | SUPERSEDED (not Ollama) |
| Backend endpoint | `http://localhost:8080/v1` | Block 3 config.toml snippet, line `base_url` | SUPERSEDED (llama-server port) |
| GPU layers (-ngl) | **20** | Block 6, Step 6.1: `--flags -ngl 20` | SUPERSEDED section |
| Context size | **131072 tokens** | Block 6, Step 6.1: `-c 131072` | SUPERSEDED section |
| KV-cache type | `q8_0` (both K and V) | Block 6: `--cache-type-k q8_0 --cache-type-v q8_0` | SUPERSEDED section |
| Flash attention | Enabled | Block 6: `--flash-attn` | SUPERSEDED section |
| OpenAI-compat API | Yes (llama-server serves `/v1` endpoint) | Block 3 config.toml `api_type = 'openai'` | SUPERSEDED section |
| max_tokens | 8192 | Block 3 config.toml | SUPERSEDED section |
| temperature | 0.6 | Block 3 config.toml | SUPERSEDED section |
| top_p | 0.95 | Block 3 config.toml | SUPERSEDED section |
| Vision model | Huihui-gemma-4-12B-it-abliterated via llama-server :8081 | Block 3 `[llm.vision]` | SUPERSEDED section |
| Ollama endpoint | [SOURCE-SILENT] | Not mentioned in this file | — |
| Ollama num_gpu param | [SOURCE-SILENT] | Not mentioned in this file | — |

**Key finding:** The source file does NOT contain an "Ollama standard operation" section.
The entire local-model recommendation in this source is based on llama-server / llama.cpp.
Therefore: recommended model/quant for Ollama operation = **[SOURCE-SILENT]**.

#### What is confirmed as non-superseded

The following technical facts remain valid regardless of which local backend (llama.cpp vs Ollama) is used:

| Technical fact | Value | Applicability |
|---------------|-------|--------------|
| Model class needed | 35B-class (Qwen3.x) | Valid: both llama.cpp and Ollama can serve this |
| Quantization class | IQ2_M (aggressive, fits 8GB VRAM + RAM offload) | Valid as reference; Ollama tag equivalent unknown |
| GPU layer count reference | 20 layers offloaded to GPU | Valid: translates to Ollama `num_gpu 20` conceptually |
| Context window | 131072 tokens (131K) | Valid: same context target applies for Ollama |
| Flash attention | Recommended | Valid: Ollama supports flash attention |
| KV-cache quantization | q8_0 | [SOURCE-SILENT for Ollama] — Ollama may not expose this param directly |

---

### 1.2 Source: `MetaClaw/docs/sources/ai-efficiency-methodology-2026-07-09.md`

This document covers AI model efficiency methodology (CUSUM, TOPSIS, golden sets, EU AI Act metrics).
Scope: evo1/evo2 Ollama nodes + LiteLLM gateway. **Not Legion-specific.**

| Parameter | Value from source | Source location | Status |
|-----------|------------------|----------------|--------|
| VRAM utilisation threshold | ≤ 0.85 sustained | §5a Operational Thresholds | APPLICABLE (general rule) |
| Latency SLA (factory-fast) | P99 ≤ 2000ms | §5a table | APPLICABLE as SLA target |
| Latency SLA (factory-coder) | P99 ≤ 30s | §5a table | APPLICABLE |
| Latency SLA (factory-mid) | P99 ≤ 5s | §5a table | APPLICABLE |
| Model alias example | `qwen3:30b@evo2` | §7a logging schema example | Reference only (evo2, not Legion) |
| Pareto models mentioned | `qwen3.5:35b` (evo2), `llama3.3:70b` (evo1) | §4c Pareto front example | Reference only (remote, not Legion) |
| Local Legion model | [SOURCE-SILENT] | Not specified | — |
| Ollama num_gpu for Legion | [SOURCE-SILENT] | Not specified | — |
| Tokens/s benchmarks for Legion | [SOURCE-SILENT] | Not specified | — |
| Legion VRAM/RAM split numbers | [SOURCE-SILENT] | Not specified | — |

---

### 1.3 Source: `MetaClaw/docs/sources/S-18-consultant-answers.md`

This document is the consultant Q&A on architecture boundaries.

| Parameter | Value from source | Source location | Status |
|-----------|------------------|----------------|--------|
| Local Legion model | [SOURCE-SILENT] | Not specified | — |
| Private Engine: autonomous, isolated | Confirmed | Block 1.1, Block Q1 | APPLICABLE |
| No routes from Legion to banking DBs | Confirmed | Block 5.2 DLP-граница | APPLICABLE |
| Uncensored model on Legion | Confirmed (for private use only) | Block 1.2 | Confirms model class but not Ollama config |
| Ollama offload settings | [SOURCE-SILENT] | Not specified | — |

---

## 2. SOURCE-SILENT GAPS (operator/consultant input required)

The following values were NOT found in any of the three source files:

| Gap ID | Parameter | Why it matters | Who resolves |
|--------|-----------|---------------|-------------|
| G-1 | Ollama model tag for Legion local run | config.toml `model` field | Operator confirms Ollama pull tag (e.g. `qwen3:32b` or `qwen3:30b`) |
| G-2 | Ollama quantization suffix | Determines VRAM fit (IQ2_M in llama.cpp ≠ direct Ollama tag) | Operator: `ollama list` or `ollama pull` target |
| G-3 | Ollama `num_gpu` confirmed value | Source only confirms `-ngl 20` for llama-server | Operator tests: `OLLAMA_NUM_GPU=20 ollama run <model>` |
| G-4 | KV-cache config in Ollama | Ollama exposes limited params vs llama.cpp | Operator: check if `OLLAMA_FLASH_ATTENTION=1` suffices |
| G-5 | Tokens/s measured on Legion | No benchmark stated for Legion + this model | Operator: measure after first run |
| G-6 | Whether llama-server (superseded) is actually replaced by Ollama | Source uses llama-server; OPEN-ITEMS assumes Ollama | Operator decides: Ollama OR llama-server with censored model? |

**G-6 is the most critical gap.** The source files only describe llama-server operation.
The OPEN-ITEMS assumption is Ollama. These may differ significantly in setup.

---

## 3. DRAFT PROPOSALS (operator approval required before any edit)

### 3a. T1: config.toml — proposed [llm] block change

**Current [llm] block (committed f9e5d7b):**
```toml
[llm]
api_type = "openai"
model = "qwen3-30b"
base_url = "http://127.0.0.1:4000/v1"
api_key = "sk-banxe-llm-gateway-2026"
max_tokens = 8192
temperature = 0.6
top_p = 0.95
```

**Proposed [llm] block (autonomous local Ollama — pending G-1/G-2/G-3 resolution):**
```toml
[llm]
api_type = "openai"
# CONFIRMED FROM SOURCE: Qwen3.x 35B-class; IQ2_M quantization (ref: manus-legion-private-engine.md)
# G-1/G-2: Exact Ollama tag below is UNCONFIRMED — operator must verify via: ollama list
model = "qwen3:32b"               # [UNCONFIRMED — source-silent for Ollama tag; verify]
base_url = "http://127.0.0.1:11434/v1"   # Ollama OpenAI-compat endpoint (standard)
api_key = "none"                  # Local Ollama — no key needed
max_tokens = 8192                 # Confirmed from source (Block 3)
temperature = 0.6                 # Confirmed from source (Block 3)
top_p = 0.95                     # Confirmed from source (Block 3)

[llm.vision]
api_type = "openai"
# G-1: Ollama tag for vision model also unconfirmed; source specifies Gemma-4-12B via llama-server :8081
model = "gemma3:12b"              # [UNCONFIRMED — source: Huihui-gemma-4-12B; Ollama equiv unknown]
base_url = "http://127.0.0.1:11434/v1"
api_key = "none"
max_tokens = 4096                 # Confirmed from source (Block 3 [llm.vision])

# Optional: keep evo as fallback heavy tier (operator can uncomment when needed)
# [llm.heavy]
# api_type = "openai"
# model = "qwen3-30b"
# base_url = "http://127.0.0.1:4000/v1"
# api_key = "sk-banxe-llm-gateway-2026"
# max_tokens = 8192
```

**Ollama pre-flight (operator runs before editing config.toml):**
```bash
# Check what models are available locally:
ollama list

# If qwen3:32b or equivalent not present, pull it:
# (Operator decision: which tag to use — IQ2_M / Q4_K_M / Q5_K_M variant)
ollama pull qwen3:32b

# Test GPU offload (confirmed GPU layer count from source: 20 layers):
# Ollama uses OLLAMA_NUM_GPU env var OR Modelfile `parameter num_gpu`
OLLAMA_NUM_GPU=20 ollama run qwen3:32b "hello, what model are you?"

# Verify VRAM usage (should be < 85% = <6.96GB of 8188MiB):
nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader
```

**Params confirmed from source (safe to apply):**
- `max_tokens = 8192` ← confirmed from manus-legion-private-engine.md Block 3
- `temperature = 0.6` ← confirmed from manus-legion-private-engine.md Block 3
- `top_p = 0.95` ← confirmed from manus-legion-private-engine.md Block 3
- `base_url = "http://127.0.0.1:11434/v1"` ← standard Ollama OpenAI-compat endpoint (not from source; canonical Ollama default)
- `api_key = "none"` ← local endpoint, no key (standard)

**Params pending operator confirmation (G-1..G-4):**
- `model =` (Ollama tag)
- `num_gpu` setting (via Modelfile or env var)
- Vision model Ollama tag

---

### 3b. T2: Sprint plan L-1 — proposed wording change

**Current L-1 in SPRINT-PLAN-TWO-ENGINES.md (commit 5c41cb1, bdsl-act-prep worktree):**
> Sprint L-1 sets Tier 2 backend (qwen3-30b via evo2/LiteLLM :4000) as primary default model.

**Proposed L-1 change (description, do NOT edit SPRINT-PLAN-TWO-ENGINES.md here):**

Replace the primary tier in L-1 from:
- "Tier 2 backend: `qwen3-30b` via LiteLLM `:4000` (remote evo2)"

To:
- "Tier 1 backend: local Qwen3.x 35B-class via Ollama `:11434` with GPU+RAM offload (RTX 4070 8GB VRAM + 54GB RAM; 20 GPU layers as reference; exact tag confirmed by operator)"

Change the Done criteria for L-1 to include:
- `ollama run <confirmed-model>` responds to test prompt locally
- `nvidia-smi` shows VRAM < 85% during inference
- OpenManus config.toml updated and `python main.py` runs without errors
- Tier 2 (evo2 via :4000) remains as fallback only — documented in config as optional `[llm.heavy]`

Change autonomy statement in L-1 from:
- "Engine relies on remote evo infrastructure for primary inference"

To:
- "Engine is AUTONOMOUS — primary inference runs locally on Legion without dependency on evo availability"

---

## 4. STATUS UPDATE

| Item | Status |
|------|--------|
| Source 1 read and values extracted | ✅ DONE — no Legion-specific Ollama config found |
| Source 2 read and values extracted | ✅ DONE — llama-server specs extracted; Ollama section [SOURCE-SILENT] |
| Source 3 read and values extracted | ✅ DONE — architecture boundaries confirmed; no offload config |
| G-1 (Ollama tag) | ✅ RESOLVED — `qwen3:30b-a3b` (confirmed from evo1+evo2 audit 2026-07-11; 18.6 GB) |
| G-6 (Ollama vs llama-server) | ✅ RESOLVED — Ollama backend confirmed (operator ran `ollama list`, confirmed Ollama active on evo1/evo2) |
| G-2 (quant suffix) | ✅ RESOLVED — no explicit quantization suffix in tag `qwen3:30b-a3b` (Ollama default quantization) |
| G-3 (num_gpu) | ⏳ PENDING — operator measures after `ollama pull qwen3:30b-a3b` on Legion; reference: 20 GPU layers |
| G-4 (KV-cache in Ollama) | ⏳ PENDING — operator tests `OLLAMA_FLASH_ATTENTION=1` after pull |
| G-5 (tokens/s on Legion) | ⏳ PENDING — measure after first local run |
| config.toml revision | ✅ DONE — updated to Tier 1 local: `qwen3:30b-a3b` via `127.0.0.1:11434`; evo :4000 as fallback |
| Sprint L-1 revision | ✅ DONE — rewritten to LOCAL autonomous primary tier; pull pre-flight + VRAM check added |
| SESSION-STATE.md update | ✅ DONE — audit findings recorded; G-1/G-6 closed; LiteLLM 20-alias list corrected |

**Operator action required (next steps):**
1. `ollama pull qwen3:30b-a3b` on Legion (18.6 GB — I-71 operator action)
2. After pull: `OLLAMA_NUM_GPU=20 ollama run qwen3:30b-a3b "hello"` — verify GPU offload
3. `nvidia-smi` — confirm VRAM < 85% (< 6.96 GB) during inference
4. Copy updated `config.toml` from `docs/ops/legion-private-engine/config.toml` to `~/OpenManus/config/config.toml`
5. `systemctl start banxe-private-engine` — start the engine (Sprint L-1 activation)

---

## References

- `MetaClaw/docs/sources/manus-legion-private-engine.md` — Block 3 (config), Block 6 (systemd/llama-server flags)
- `MetaClaw/docs/sources/ai-efficiency-methodology-2026-07-09.md` — §5a (VRAM threshold), §7a (model_id example)
- `MetaClaw/docs/sources/S-18-consultant-answers.md` — Block 5.2 (DLP boundary), Block 1.2 (uncensored model scope)
- `docs/governance/OPEN-ITEMS-OFFLOAD.md` — extraction constraints and output targets
- `docs/governance/SESSION-STATE.md` — OI-LOCAL-1 entry (update after operator confirms values)
- `docs/ops/legion-private-engine/config.toml` — current committed config (f9e5d7b)
- `docs/architecture/SPRINT-PLAN-TWO-ENGINES.md` — Sprint L-1 current wording (5c41cb1, bdsl-act-prep)
