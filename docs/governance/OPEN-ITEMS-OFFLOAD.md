# OPEN ITEMS — Local Model Offload Settings for Legion
# Status: TODO — factory must extract from source files before config revision.
# Created: 2026-07-11
# Parent: SESSION-STATE.md OI-LOCAL-1

---

## Context

Private Legion Engine is AUTONOMOUS. It must run its primary model locally on Legion,
not defer to evo2 by default. The current config.toml uses `qwen3-30b` via LiteLLM :4000
(remote). This must be revised once the correct local model + offload config is confirmed.

Legion hardware supports GPU+RAM offload:
- VRAM: 8GB (RTX 4070 Laptop)
- RAM: ~54GB usable
- CPU: i7-14700HX 20 threads
- Disk: 769G free (sufficient for large weight files)

30B-class models are feasible locally with llama.cpp / Ollama `num_gpu` layer splitting.
235B-class still requires evo2.

---

## TODO: Extract from Source Files

### Source 1
**File:** `MetaClaw/docs/sources/ai-efficiency-methodology-2026-07-09.md`
**Path (local):** `/home/mmber/MetaClaw/docs/sources/ai-efficiency-methodology-2026-07-09.md`

Extract:
- [ ] Recommended local model name and variant for Legion (30B-class or similar)
- [ ] Recommended quantization format (e.g., Q4_K_M, IQ2_M, Q5_K_M)
- [ ] Recommended `num_gpu` / offload layer count for RTX 4070 8GB + 54GB RAM
- [ ] Any noted latency / throughput benchmarks for Legion hardware
- [ ] Any noted context window constraints under offload

### Source 2
**File:** `MetaClaw/docs/sources/manus-legion-private-engine.md`
**Path (local):** `/home/mmber/MetaClaw/docs/sources/manus-legion-private-engine.md`

Extract:
- [ ] Model specified for local Legion run (the blueprint section, NOT the superseded llama-server config)
- [ ] Quantization specified
- [ ] Ollama or llama.cpp invocation pattern for Legion
- [ ] `num_gpu` or equivalent offload parameter specified
- [ ] Any VRAM / RAM split noted

---

## Output Target

When extracted, populate into:
1. `docs/governance/SESSION-STATE.md` — section "KEY FACT — RAM Offload", add confirmed values.
2. `docs/ops/legion-private-engine/config.toml` — revise `[llm]` block:
   - Change `api_type` from `"openai"` to appropriate local backend type
   - Change `model` to confirmed local model name
   - Change `base_url` from `http://127.0.0.1:4000/v1` to local Ollama endpoint
   - Remove `api_key` or set to `"none"` (local endpoint)
3. `docs/architecture/SPRINT-PLAN-TWO-ENGINES.md` — revise Sprint L-1:
   - Default tier becomes the confirmed local model (not evo Tier 2)
   - Document offload params in Done criteria

---

## Constraints (do NOT invent)

- Do NOT populate model name or quantization values from training memory.
- Values MUST come from the two source files above.
- If source files do not specify a value, record it as `[NOT FOUND IN SOURCE]`.
- Do NOT copy the superseded llama-server :8080 / uncensored-model config from
  `manus-legion-private-engine.md` blueprint — that section is SUPERSEDED.
  Only extract the recommended model/quant for standard local Ollama operation.

---

## Status

- [ ] Source 1 read and values extracted
- [ ] Source 2 read and values extracted
- [ ] SESSION-STATE.md updated with confirmed values
- [ ] config.toml revised (factory task, after operator approval)
- [ ] Sprint L-1 revised (factory task, after operator approval)
