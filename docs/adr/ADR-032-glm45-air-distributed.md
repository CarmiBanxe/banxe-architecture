---
id: ADR-032
title: GLM-4.5-Air Distributed Inference (USB4 RPC)
status: ACCEPTED
date: 2026-05-03
supersedes: []
related:
  - ADR-031 (AI Execution Policy)
  - ADR-033 (ufw Perimeter Posture)
  - ADR-034 (Aider/Continue Routes)
binding_artifact: banxe-infra/ai-routing/policy.yaml
---

# ADR-032: GLM-4.5-Air Distributed Inference (USB4 RPC)

## Status
ACCEPTED — 2026-05-03 (CEO: Moriel Carmi)

## Context

Banxe needs an on-prem `large` reasoning model to back the `reasoning`-class routes
defined in ADR-034 and to satisfy the meta-plane policy in ADR-031 that high-sensitivity
prompts stay inside the GMKtec cluster. Models in the 70B-class (Llama 3.3 70B,
Qwen 2.5 72B) fit on a single evo node but plateau on multi-step financial reasoning;
models in the 200B-class (Qwen3 235B) fit only with severe quantisation and have cold
loads measured in minutes.

GLM-4.5-Air-Q4_K_M (≈110.5B parameters, 73 GiB on disk in `Q4_K_M` GGUF) sits in the
gap and is the first model where the USB4-tethered evo1↔evo2 link delivers acceptable
distributed inference: the master process holds the KV cache and the bulk of weights on
evo1, and a llama.cpp RPC worker on evo2 holds the remaining tensor shards.

A 50-token benchmark on 2026-05-03 produced **prompt 32.52 tok/s, generation 21.47 tok/s**
end-to-end through LiteLLM v2 — fast enough to be the default `large` reasoning
endpoint without falling back to Ollama for every long-context call.

## Decision

### Topology

| Component | Host | Port | Role |
|-----------|------|------|------|
| llama.cpp `glm-master` | evo1 | 8081 | HTTP server, master process, holds KV cache |
| llama.cpp RPC worker | evo2 | 50052 | Tensor-parallel worker over USB4 RPC |
| LiteLLM v2 router | legion | 4000 | Exposes aliases `glm-air` and `glm-4.5-air-distributed` |
| Ollama (failover) | evo1 | 11434 | Fallback for the same reasoning slot when llama.cpp is down |

### Aliases (LiteLLM v2)

- `glm-air` — friendly short alias used by Aider/Continue routes (ADR-034).
- `glm-4.5-air-distributed` — explicit alias used by deterministic agents and benchmarks.

Both resolve to the same backend; the duplication is intentional so callers can be
audited by alias regardless of which surface they came from.

### Failover order

1. `legion:4000` LiteLLM v2 → `evo1:8081` (llama.cpp `glm-master`, distributed)
2. → `evo1:8081` direct (single-node degraded mode if RPC worker is unreachable)
3. → `evo1:11434` (Ollama, smaller `large` substitute — see `policy.yaml` for the
   substitute model id)

Failover is silent up to step 3. A drop to step 3 emits a warning event (`ai_route_degraded`)
that the meta-plane is expected to surface to the operator on next interaction.

### Authentication

The llama.cpp `glm-master` API key is generated and stored only in the systemd unit on
evo1 (`/etc/systemd/system/llama-glm-master.service` environment file). It MUST NOT be
checked into any repo, including this one and `banxe-infra`. LiteLLM v2 reads it from
its own environment file on legion. Rotation is manual and logged in the IL.

### Benchmark snapshot (2026-05-03)

- Prompt evaluation: **32.52 tok/s**
- Generation: **21.47 tok/s**
- Workload: 50-token benchmark prompt, default sampling, RPC over USB4
- Run via: LiteLLM v2 (`legion:4000`) → llama.cpp `glm-master` (evo1) ↔ RPC (evo2)

This snapshot is the baseline for regression detection. A drop below ~17 tok/s
generation on the same workload triggers an investigation IL.

## Consequences

Positive:
- First on-prem model with sub-2s first-token on long-context Banxe prompts.
- USB4 RPC validates the cluster topology for future >100B models without buying
  multi-GPU rigs.
- API key never in repo → no secret-rotation event when contributors come and go.

Negative:
- evo1 outage takes the whole `large` reasoning slot down to Ollama-only.
- llama.cpp RPC is sensitive to USB4 cable state; `dmesg` checks are now part of the
  pre-shift cluster health routine.
- 73 GiB GGUF weight is large enough that re-deployment to a fresh node is a
  multi-minute operation; document in runbook before any node rebuild.

## Verification

- `policy.yaml` MUST define `glm-air` and `glm-4.5-air-distributed` with the failover
  order above.
- `evo1:8081` health endpoint MUST be polled by the cluster monitor; a stale poll
  flips LiteLLM to step 2 within one health window.
- Benchmark above is the baseline; re-run on every llama.cpp upgrade and store result
  alongside this ADR.
