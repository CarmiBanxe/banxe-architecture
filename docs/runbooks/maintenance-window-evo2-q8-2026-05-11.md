# Maintenance Window Plan: evo2 qwen3:235b Q4_K_M -> Q8_0
Document ID: MW-EVO2-Q8-001 | Status: DRAFT DEFERRED

## Trigger
Activate only after G-INFRA-EVO2-GPU-STACK CLOSED and GPU offload verified for 24h.

## Window
- Duration: ~4 hours
- Off-peak: 02:00-06:00 CEST
- Owner: Sub-terminal A under HITL L3
- CTIO sign-off: HITL-ASK-2026-05-11-001

## Pre-flight
1. GPU stack verified (rocm-smi VRAM in use by ollama)
2. >=250 GB free in /var/lib/ollama
3. Capture SHA of current Q4_K_M blob
4. Capture banxe Modelfile -> /tmp/banxe-modelfile.bak
5. Verify Q8_0 tag in Ollama library
6. Freeze LiteLLM routes for evo2:11434 qwen3:235b
7. Notify MetaClaw operator
8. Post HITL ASK in docs/audit/hitl-decisions-2026-05-11.md
9. CTIO approve HITL-ASK-2026-05-11-001 recorded

## Execution
1. ssh evo2 ollama pull qwen3:235b-a22b-q8_0
2. ollama show qwen3:235b-a22b-q8_0
3. ollama run qwen3:235b-a22b-q8_0 "ping"
4. Recreate banxe overlay FROM Q8_0
5. Benchmark 10 prompts
6. Pass -> re-enable LiteLLM routes
7. Fail -> Rollback

## Acceptance
- ollama show q8_0 valid metadata
- Smoke prompt < 60s
- TTFT regression < 2x baseline
- No OOM in dmesg during 30 min sustained load

## Rollback
- ollama cp qwen3:235b-a22b-q4_K_M qwen3:235b-a22b
- Recreate banxe overlay FROM Q4_K_M
- Optional ollama rm qwen3:235b-a22b-q8_0
