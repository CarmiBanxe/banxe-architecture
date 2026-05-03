# GLM-4.5-Air Distributed Inference — Benchmark Snapshot

**Date:** 2026-05-03
**Model:** GLM-4.5-Air-Q4_K_M (≈110.5B parameters, 73 GiB on disk in Q4_K_M GGUF)
**Source ADR:** `docs/adr/ADR-032-glm45-air-distributed.md`

## Results

| Metric | Value |
|--------|-------|
| Prompt evaluation | **32.52 tok/s** |
| Generation | **21.47 tok/s** |
| Workload | 50-token benchmark prompt, default sampling, RPC over USB4 |
| Path | LiteLLM v2 (`legion:4000`) → llama.cpp `glm-master` (evo1) ↔ RPC worker (evo2) |

## Topology

| Component | Host | Port | Role |
|-----------|------|------|------|
| llama.cpp `glm-master` | evo1 | 8081 | HTTP server, master process, holds KV cache |
| llama.cpp RPC worker | evo2 | 50052 | Tensor-parallel worker over USB4 RPC |
| LiteLLM v2 router | legion | 4000 | Exposes aliases `glm-air` and `glm-4.5-air-distributed` |
| Ollama (failover) | evo1 | 11434 | Fallback for the same reasoning slot when llama.cpp is down |

## Configuration

- Model file: `GLM-4.5-Air-Q4_K_M.gguf` (73 GiB)
- Master process: `evo1:8081` (llama.cpp HTTP server, systemd unit `llama-glm-master.service`)
- RPC worker: `evo2:50052` (llama.cpp RPC mode, USB4 physical link)
- Sampling: default (temperature 0.7, top-p 0.9)

## Regression threshold

GLM-Air distributed throughput MUST NOT regress below **~17 tok/s** end-to-end; lower values
trigger rollback to single-host inference per ADR-032 §Failover order.

Re-run this benchmark on every llama.cpp upgrade and store the result alongside this file
(naming convention: `glm-master-YYYY-MM-DD.md`).
