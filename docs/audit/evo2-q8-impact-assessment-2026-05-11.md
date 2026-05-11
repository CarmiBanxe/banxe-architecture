# Impact Assessment: evo2 qwen3:235b-a22b Q4_K_M -> Q8_0
Document ID: IA-EVO2-Q8-001 | Status: DRAFT (execution DEFERRED per R-1)
ADR-035 Original Step 5

## 1. evo2 state
- Host: NucBox EVO-X2 (192.168.0.15 LAN / 100.99.208.21 Tailscale)
- RAM: 128 GB; ~80 GB available; ~50 GB buff/cache by llama-server Q3_K_S
- Disk: ~1.4 TB free on /var/lib/ollama
- GPU: AMD, CPU-only currently (G-INFRA-EVO2-GPU-STACK OPEN)

### Models on evo2
- qwen3:235b-a22b Q4_K_M 142.2 GB (shared blob 791d5d11)
- qwen3:235b-a22b-banxe Q4_K_M shared blob, Modelfile overlay

### Active processes
- llama-server :8082 qwen3-235b-Q3_K_S.gguf RSS ~50.9 GB
- ollama serve :11434 idle ~49 MB

### LiteLLM clients touching evo2 235b
- MetaClaw reasoning -> evo2:11434 qwen3:235b-a22b-banxe
- MetaClaw reasoning-235b -> evo2:8082 llama-server
- Legion main LiteLLM: not routed to 235b

## 2. Disk delta
Peak +240 GB during pull, +98 GB net after rm Q4_K_M. Headroom 1.16 TB. SAFE.

## 3. RAM delta (HIGHEST RISK)
- CPU-only both running: 121-171 GB needed vs 80 GB available -> HIGH
- GPU restored both: 70-90 GB vs 80 GB -> MEDIUM
- llama-server stopped, CPU Q8_0: 70-120 GB vs 80 GB -> MEDIUM-HIGH

## 4. Quality uplift (MoE A22B)
- ~1-2% MMLU-Pro gain
- ~5-10% hallucination reduction on compliance reasoning (estimated)

## 5. Throughput
- Q4_K_M CPU: ~5 tok/s
- Q8_0 CPU: ~2.8-3.5 tok/s (-40-50%)
- Q8_0 + GPU: ~8-15 tok/s

## 6. Risks
- R-1 HIGH: Q8_0 OOM CPU + llama-server. Mitigation: GPU stack first OR stop llama-server.
- R-2 HIGH: Q8_0 tag missing in Ollama lib. Mitigation: verify pre-window; build from GGUF.
- R-3 MED: banxe Modelfile lost. Mitigation: capture before swap.
- R-4 MED: llama-server crash from RAM contention.
- R-5 MED: Throughput regression unacceptable.
- R-6 LOW: Pull interrupted (resumes).
- R-7 MED: Q4_K_M deleted before verify. Mitigation: SHA snapshot.

## 7. Recommendation
Option A (RECOMMENDED): Restore GPU stack first, then Q8_0.
Option B: Q8_0 CPU-only, llama-server stopped during load. -40% throughput.
Option C: Stay at Q4_K_M. Zero risk.
Option D: Q6_K compromise.

## 8. Decision 2026-05-11
DEFER until G-INFRA-EVO2-GPU-STACK CLOSED. R-1 HIGH makes CPU-only unsafe.
