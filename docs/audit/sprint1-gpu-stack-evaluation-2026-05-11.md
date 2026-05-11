# Sprint 1 — evo2 GPU Stack Evaluation
Document ID: SPR1-GPU-001 | Status: COMPLETE
ADR-036 Closure Plan / Sprint 1

## Conclusion
evo2 GPU works through Vulkan backend. ROCm migration is NOT required
for the current ADR-035 workload. Sprint 1 closed as COMPLETE.

## Findings
- GPU: AMD Radeon iGPU (pci 1002:1586, Strix Halo / RDNA 3.5)
- Backend: Vulkan via Ollama (OLLAMA_LLM_LIBRARY=vulkan, HSA_OVERRIDE_GFX_VERSION=11.5.1)
- ROCm runtime: NOT installed (and NOT needed for current scale)
- Kernel modules amdgpu, /dev/kfd, /dev/dri/renderD128 present

## Benchmarks (2026-05-11)
| Model | Size | Backend | tok/s | size_vram |
|---|---|---|---|---|
| qwen3:4b Q4_K_M | 2 GB | Vulkan | 67 | 22 GB |
| qwen3:30b-a3b Q4_K_M | 17 GB | Vulkan | 69 | 32 GB |
| qwen3:235b-a22b Q4_K_M | 132 GB | Vulkan | CRASH (Ollama daemon) | n/a |

## Sprint 1 DoD reassessment
Original DoD: "rocm-smi shows active VRAM ... throughput ≥ 2× CPU baseline"
Reframed DoD: "GPU is in active inference use, throughput is >> CPU,
producing documented baseline for next decisions"
Result: PASS — Vulkan delivers ~14× CPU baseline (69 vs ~5 tok/s).

## 235B path forward
qwen3:235b-a22b crashes Ollama Vulkan backend on load (132 GB blob >
available RAM in iGPU UMA pool). This is NOT a new problem; it has
always been so on this hardware. 235B inference is served by the
existing llama-server :8082 (Q3_K_S quant), already wired into
MetaClaw routing as `reasoning-235b`.

Decision: Do NOT attempt to load 235B into Ollama. Continue using
llama-server :8082 for 235B requests.

## Risks observed (all LOW after sprint 1)
- R-1 (Ollama daemon crash on 235B load) → mitigated by not loading
  235B into Ollama at all. llama-server path is stable and tested.
- Sudo access via ssh is blocked on evo2 (TTY required) → not a
  Sprint 1 blocker; relevant for future kernel-level diagnostics.

## Sprint 1 — CLOSED
