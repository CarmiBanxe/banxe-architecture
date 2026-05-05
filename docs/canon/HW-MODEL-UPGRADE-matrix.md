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
