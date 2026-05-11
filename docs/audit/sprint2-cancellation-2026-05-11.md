# Sprint 2 — CANCELLED
Document ID: SPR2-CANCEL-001
ADR-036 Closure Plan / Sprint 2 (Original Part 5)

## Original goal
Requantize qwen3:235b-a22b from Q4_K_M to Q8_0 in Ollama on evo2.

## Why cancelled
1. Sprint 1 evaluation showed Ollama Vulkan backend cannot load 132 GB
   Q4_K_M blob on this hardware. Q8_0 (~240 GB) is even less feasible.
2. The intended use case (better-quality 235B reasoning for compliance
   workloads) is already served by llama-server :8082 with Q3_K_S, which
   loads reliably and is wired into MetaClaw `reasoning-235b`.
3. No business pain point currently maps to "Q8 in Ollama specifically".
4. Sprint 1 freed Original Part 5 from the "blocked by GPU" framing —
   GPU works fine. The blocker is hardware-level RAM/UMA capacity,
   which is not solvable without adding more physical memory.

## Decision
Sprint 2 CANCELLED. HITL-ASK-2026-05-11-001 set to RESOLVED-CANCELLED.

## Future alternative (parked, not committed)
If Q8 235B becomes a real requirement later, two viable paths exist:
- Path A: distribute 235B Q8 across both evo1 and evo2 via llama.cpp
  RPC (would require GPU stack on both nodes and RPC plumbing).
- Path B: download a Q8 GGUF directly and serve it via a second
  llama-server instance on evo2 alongside the existing Q3_K_S one,
  if RAM allows (it does NOT today: Q8 GGUF is ~240 GB, evo2 has 128 GB
  RAM total).

Neither path is justified by current Banxe workload.
