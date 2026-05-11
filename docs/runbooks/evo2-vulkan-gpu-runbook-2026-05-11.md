# Runbook: evo2 Vulkan GPU stack (operational reference)

## What runs where on evo2
- Ollama (systemd, port 11434, Vulkan backend): serves models up to
  ~50 GB VRAM footprint. Used by MetaClaw `reasoning` (qwen3:30b-a3b),
  Legion LiteLLM `default` route for evo2 backend.
- llama-server (port 8082, --n-gpu-layers 40): serves qwen3-235b-Q3_K_S.
  Used by MetaClaw `reasoning-235b`. Started independently of Ollama.

## Environment (in /etc/systemd/system/ollama.service.d/override.conf)
- OLLAMA_VULKAN=1
- OLLAMA_LLM_LIBRARY=vulkan
- HSA_OVERRIDE_GFX_VERSION=11.5.1
- OLLAMA_FLASH_ATTENTION=1
- OLLAMA_CONTEXT_LENGTH=131072
- OLLAMA_NUM_PARALLEL=1
- OLLAMA_KEEP_ALIVE=10m
- OLLAMA_MODELS=/data/ollama-models

## Verified throughput (2026-05-11)
- qwen3:4b: 67 tok/s
- qwen3:30b-a3b: 69 tok/s
- qwen3:235b: do NOT load into Ollama; use llama-server :8082

## Do-not-do
- Do NOT issue /api/generate against qwen3:235b-* through Ollama on
  evo2. It crashes the daemon. Route 235B via llama-server :8082.
- Do NOT install ROCm runtime without an ADR. Current Vulkan setup is
  stable for production workloads under 50 GB.
- Do NOT change OLLAMA_VULKAN, HSA_OVERRIDE_GFX_VERSION, or
  OLLAMA_LLM_LIBRARY in override.conf without a maintenance window
  and rollback plan.
