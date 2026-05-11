# ADR-036 Closure Plan — Final Summary
Date: 2026-05-11
Parent ADR: ADR-035 (AI Pool Roadmap)

## Spring outcomes

| Sprint | Title | Outcome | PR |
|---|---|---|---|
| 1 | GPU stack on evo2 | COMPLETE (Vulkan sufficient) | #213 |
| 2 | qwen3:235b Q4 -> Q8 (Original Part 5) | CANCELLED (240 GB blob > 128 GB RAM; llama-server Q3_K_S covers use case) | #213 |
| 3 | Model deduplication | CANCELLED (conflicts with load balancing from Sprint 6; no disk pressure) | this PR |

## ADR-036 ledger
- Sprints completed productively: 1 of 3
- Sprints cancelled with reasoned justification: 2 of 3
- Sprints deferred/blocked: 0 of 3

Cancellations are NOT failures: each was cancelled because evidence
collected during the closure plan invalidated the original premise.
This is the canon's "best decision" rule (Clause 5) applied at
sprint level.

## Architectural state after ADR-036 closure
Unchanged from ADR-035 final state (PR #210). No production mutations.

## Lessons captured
- Vulkan backend on AMD iGPU is production-grade for models <= 70 GB.
- Vulkan backend cannot load 132 GB+ models reliably; route those
  through llama-server with explicit GPU layer count instead.
- Load balancing via duplicate Ollama tags across nodes is cheaper
  than deduplication when disk is abundant.

## Closure
ADR-036 CLOSED 2026-05-11. No follow-on tracks.
