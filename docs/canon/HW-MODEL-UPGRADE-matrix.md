# HW-MODEL-UPGRADE Matrix

## qwen3:235b decision matrix (2026-05-05)

| Quant | Size | Fits 93 GiB RAM | Status |
|---|---|---|---|
| fp16 | 470 GB | ❌ no (≥470 GB needed) | DELETED 2026-05-05 (PA-4) |
| Q5_K_M | ~178 GB | ❌ no full-load (MoE active subset would need ~36 GB live + KV cache) | not pursued |
| Q4_K_M | ~158 GB | ⚠ borderline (no headroom) | not pursued |
| **Q3_K_S** | **142 GB** | **✅ yes (5.1 tok/s observed)** | **CANONICAL MAX (sanctioned by IL-CANON-OPERATOR-2026-05 principle #3)** |

Decision: keep Q3_K_S; delete fp16; defer any further quality upgrade
to G-MODEL-UPGRADE tracker triggered when evo2 RAM is upgraded
beyond 93 GiB or RPC/multi-host inference path is wired.

## Model placement matrix (2026-05-05, PA-3)

Canonical "primary serves" assignment per model. Duplicates retained on secondary until G-CLUSTER-03 operator-confirmed cleanup.

| Model | Size | Primary node | Secondary (dup) | Rationale |
|---|---|---|---|---|
| qwen3:4b | 2.5 GB | evo1 | evo2 | fast small for tools/autocomplete |
| qwen3.5:latest (9.7B) | 6.6 GB | evo1 | evo2 | embedding/quick reasoning |
| gpt-oss-derestricted:20b | 15 GB | evo1 | evo2 | text generation, no GPU need |
| qwen3:30b-a3b (MoE) | 18 GB | evo2 | evo1 | MoE benefits from GPU (gfx1151) |
| huihui_ai/glm-4.7-flash | 18 GB | evo2 | evo1 | canon-judge backend (ADR-031) |
| qwen3.5:35b | 23 GB | evo2 | evo1 | canon-judge primary (G-CANON-01, 13/13 PASS) |
| llama3.3:70b | 42 GB | evo2 | evo1 | large model, GPU/RAM benefit on evo2 |
| qwen3-coder-next:q4_K_M | 51 GB | evo2 | evo1 | code-focused, largest non-235b |
| qwen3:235b-a22b (Q3_K_S) | 142 GB | evo2 ONLY | — | canonical max (IL-CANON-OPERATOR-2026-05 #3) |
| qwen3:235b-a22b-banxe | 142 GB | evo2 ONLY | — | fine-tuned variant |

### Summary

- **evo1 primary** (3 models, ~24 GB): qwen3:4b, qwen3.5:latest, gpt-oss:20b.
- **evo2 primary** (6+ models, ~436 GB): all heavy + 235b exclusives.
- **Dedup target** (G-CLUSTER-03): remove ~134 GB from evo1 (30b-a3b 18 + glm-4.7 18 + qwen3.5:35b 23 + llama3.3:70b 42 + qwen3-coder-next 51 = 152 GB; or retain select for HA).
- **HA policy**: keep qwen3:4b + qwen3.5:latest on both (minimal, fast fallback). Remove heavy dups from evo1.

## Model placement matrix (PA-3, 2026-05-05)

Canonical "primary serves" placement for the dual-node cluster (evo1 30 GiB / evo2 93 GiB). evo2 = heavy inference primary (gfx1151 GPU + 93 GiB RAM); evo1 = small/utility models.

| Model | Size | Primary | Rationale |
|---|---|---|---|
| qwen3:4b | 2.5 GB | evo1 | fast small for tools; minimal footprint |
| qwen3.5:latest (9.7B) | 6.6 GB | evo1 | embedding / quick reasoning |
| gurubot/gpt-oss-derestricted:20b | 15 GB | evo1 | text generation, no GPU benefit |
| qwen3:30b-a3b | 18 GB | evo2 | MoE; benefits from GPU |
| huihui_ai/glm-4.7-flash-abliterated | 18 GB | evo2 | glm-air canon-judge backend (ADR-031) |
| qwen3.5:35b | 23 GB | evo2 | canon-judge primary (G-CANON-01 Week 2 13/13 PASS) |
| llama3.3:70b | 42 GB | evo2 | large; GPU benefit |
| qwen3-coder-next:q4_K_M | 51 GB | evo2 | code-focused, large |
| qwen3:235b-a22b | 142 GB | evo2 ONLY | canonical max (IL-CANON-OPERATOR-2026-05 #3) |
| qwen3:235b-a22b-banxe | 142 GB | evo2 ONLY | banxe-tuned canonical max |

**Dedup potential:** ~134 GB on evo1 (delete 30b-a3b, glm-4.7, qwen3.5:35b, llama3.3:70b, qwen3-coder-next).

**Execution:** deferred to **G-CLUSTER-03** — actual `ollama rm` invocations require per-model operator confirmation (§3.2 destructive ops), not blanket admin merge.

**HA / fallback:** if a primary-node model becomes critical for a workload that the other node serves, re-pull on the secondary as needed; no permanent dual-replication policy.
