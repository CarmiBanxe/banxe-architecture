---
il_ts: 2026-07-11T00:03:00Z
session_id: agent-factory-t1c-llamaserver-hauhaucs
source: factory
status: DONE (config.toml T1c applied — operator GGUF download + commit pending)
---
### T1c: llama-server replaces Ollama — HauhauCS-Aggressive-IQ2_M + Gemma-4-12B abliterated

- **Decision:** Operator confirmed HauhauCS-Aggressive-IQ2_M as primary model. HauhauCS-Aggressive is NOT
  available in Ollama registry — only as GGUF. Therefore Ollama :11434 (T1) is SUPERSEDED by
  llama-server :8080 (T1c). Factory applied config.toml update.
- **Math confirmed:**
  - IQ2_M: 11.7 GB GGUF, 40 layers, ~292 MB/layer
  - 8GB VRAM → -ngl 20 → ~5.8 GB GPU; remainder ~5.8 GB RAM
  - KV-cache q8_0 ctx=131072 → ~5-8 GB RAM; total ~13 GB of 64 GB RAM ✅
  - Gemma IQ4_XS: 6.8 GB → fits fully in VRAM (-ngl 99); sequential use only
  - CONFLICT: Ollama (qwen2.5-coder:7b = 4.7 GB VRAM) must be stopped before llama-server
- **Artifacts revised (NOT committed — operator action required):**
  - `docs/ops/legion-private-engine/config.toml` T1c:
    - [llm]: base_url=http://127.0.0.1:8080/v1 (llama-server), model="qwen3.6-35b-hauhaucs"
    - [llm.vision]: base_url=http://127.0.0.1:8081/v1 (llama-server), model="gemma-4-12b-abliterated"
    - PRE-FLIGHT launch commands embedded as comments
    - CONFLICT WARNING (Ollama) documented in header
  - `docs/governance/SESSION-STATE.md` — T1 track, ARTIFACT STATUS, TRACK BOARD updated
- **Model sources (operator downloads):**
  - https://huggingface.co/HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive
    → IQ2_M.gguf (11.7 GB) + mmproj-f16.gguf (899 MB)
  - https://huggingface.co/mradermacher/Huihui-gemma-4-12B-it-abliterated-GGUF
    → IQ4_XS.gguf (6.8 GB)
- **Operator action required (I-71):**
  1. pip install huggingface_hub
  2. huggingface-cli download HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive IQ2_M.gguf mmproj-f16.gguf --local-dir ~/models/qwen36-35b-aggressive
  3. huggingface-cli download mradermacher/Huihui-gemma-4-12B-it-abliterated-GGUF IQ4_XS.gguf --local-dir ~/models/gemma4-12b-abliterated
  4. Install llama.cpp CUDA build (see RUNBOOK.md)
  5. systemctl stop ollama
  6. llama-server … --port 8080 (see config.toml comments for full command)
  7. Copy config.toml to ~/OpenManus/config/config.toml
  8. git add + commit + push (both worktrees)
- **Superseded:** T1 (Ollama :11434, qwen3:30b-a3b) — NOT the right backend for HauhauCS GGUF files.
- **Append-only (ADR-059-A):** il_ts 2026-07-11T00:03:00Z strictly > 2026-07-11T00:02:00Z.
- **Refs:** config.toml T1c, SESSION-STATE.md, HauhauCS HF repo, mradermacher HF repo.
