# Sprint 3 — CANCELLED
Document ID: SPR3-CANCEL-001
ADR-036 Closure Plan / Sprint 3 (Model Deduplication)

## Original goal
Remove duplicate Ollama models across evo1 and evo2 (~165 GB savings).

## Inventory snapshot (2026-05-11)
Shared models (same digest on both nodes):
| Model | Size |
|---|---|
| qwen3:4b | 2 GB |
| qwen3.5:latest | 6 GB |
| gurubot/gpt-oss-derestricted:20b | 14 GB |
| qwen3:30b-a3b | 17 GB |
| huihui_ai/glm-4.7-flash-abliterated:latest | 17 GB |
| qwen3.5:35b | 22 GB |
| llama3.3:70b | 39 GB |
| qwen3-coder-next:q4_K_M | 48 GB |
| Total duplicates | ~165 GB |

Node-only:
- evo1: qwen2.5-coder:7b (4 GB)
- evo2: qwen3:235b-a22b + banxe (~142 GB shared blob)

## Disk pressure (current)
- evo1 `/data`: 265 GB used, 1.5 TB free (15% used)
- evo2 `/`:      429 GB used, 1.4 TB free (25% used)
No disk pressure exists on either node.

## Why cancelled
1. The duplicates are intentional. PR #205 (Sprint 6 — Part 6 of
   ADR-035) added evo2 entries to LiteLLM model_list to enable load
   balancing between evo1 and evo2 for shared models via the
   simple-shuffle strategy. Removing one copy would silently disable
   load balancing for that model.
2. Dedup saves ~10% of one disk while removing one redundancy layer
   (HA for inference per model). The tradeoff is unfavourable.
3. CTIO/MLRO sign-off was the stated precondition. Cost/benefit does
   not justify even asking for it.
4. Sprint 3 was the last open item of ADR-036. With Sprint 1 closed
   and Sprint 2 cancelled, Sprint 3 cancellation finalizes ADR-036.

## Decision
Sprint 3 CANCELLED. No `ollama rm` actions on either node.
ADR-036 Closure Plan complete.

## Future trigger
If either node passes 70% disk usage, revisit Sprint 3 with a
single-model dedup scope (e.g. only `llama3.3:70b` or
`qwen3-coder-next:q4_K_M`, the two largest shared models) instead
of full dedup. HITL ASK to CTIO/MLRO at that point with concrete
disk-pressure metric.
