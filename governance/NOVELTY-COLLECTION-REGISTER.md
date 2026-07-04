# NOVELTY-COLLECTION-REGISTER — Terminal B Spec-Projects Lane

**Status:** ACTIVE  
**Owner:** Terminal B (Spec-Projects)  
**Consumer:** Terminal A (Factory) — reads only, never edits  
**Append-only (I-24).** No row edits. New rows appended at bottom.  
**ADR:** decisions/ADR-TERMINAL-B-SPEC-LANE.md  
**Updated:** 2026-07-02  

---

## Register Schema

| Column | Values | Notes |
|--------|--------|-------|
| `item` | short name | unique slug per finding |
| `source-repo` | repo name | where found |
| `floor` | 1-4 | 4-floor model (MASTER-ORG-CODE-RUNTIME-DOSSIER) |
| `type` | feature / subproject / analytics / compliance | finding type |
| `value` | high / med / low | estimated adoption value |
| `dedup` | unique / duplicate-of:\<X\> | is this genuinely new? |
| `verdict` | adopt / evaluate / reject | B's recommendation |
| `handoff` | GAP-NN / OD-NN / NONE | routing for operator or A |
| `status` | OPEN / IN-PROGRESS / RESOLVED | lifecycle |

---

## Entries

| item | source-repo | floor | type | value | dedup | verdict | handoff | status |
|------|-------------|-------|------|-------|-------|---------|---------|--------|
| tx_monitor_i01_float_fix | vibe-coding | 3 | compliance | high | duplicate-candidate (EMI tx_monitor uses Decimal) | adopt | OD-2 (vibe I-01 fix) | OPEN |
| tx_monitor_crypto_flag | vibe-coding | 3 | feature | med | unique (not in EMI tx_monitor) | evaluate | GAP-TM-CRYPTO | OPEN |
| legion_14b_unfit_8gb_vram | banxe-architecture | 2 | analytics | high | unique (measured 2026-07-03: 9GB>8GB VRAM, 7.6 tok/s CPU-fallback, GPU idle 3%) | adopt | NONE (docs-only correction landed §5.7-D) | RESOLVED |
| legion_7b_viable_factory_fast | banxe-architecture | 2 | analytics | high | unique (measured 2026-07-03: fits 8GB VRAM, ~52 tok/s) | adopt | NONE (routing-map + factory-fast card retargeted) | RESOLVED |
| reasoning_235b_truth_apikey_asyncslot | banxe-architecture | 2 | analytics | high | unique (llama-server evo2:8082 Q3_K_S --n-gpu-layers=40, api-key gated /v1/chat, /v1/models≠liveness, 2.13 tok/s async-only) | adopt | NONE (lesson landed §5.7-A + §5.7-C) | RESOLVED |
| glm_air_distributed_second_reason_lane | banxe-architecture | 2 | feature | med | unique (evo1:8081 llama-server master + evo2:50052 rpc-server Vulkan worker; alias glm-air) | evaluate | GAP-COMPUTE-GLM-AIR-REG (register `glm-air` in `:4000` canonical alias table — Terminal-A / ADR-103) | OPEN |
| lesson_v1models_not_generation_proof | banxe-architecture | 4 | compliance | high | unique (audit-methodology lesson: 200 on /v1/models does not prove weights loaded / auth OK / throughput; only /v1/chat with correct bearer + bounded response) | adopt | NONE (recorded §5.7-C) | RESOLVED |
| litellm_4000_orphan_reuseport | banxe-architecture | 2 | analytics | high | unique (2 процесса-зомби co-bound :4000 через SO_REUSEPORT -> round-robin «мерцающий» routing: project-reason то :8081, то :8082) | adopt | GAP: systemd single-listener guard | OPEN |
| litellm_4000_noauth_redis_cache_stall | banxe-architecture | 2 | compliance | high | unique (cache:true + evo1-redis requirepass (NOAUTH) + отсутствие password -> ~20s столл на всех completions) | adopt | RESOLVED (cache:false, MetaClaw 7288cf8) | RESOLVED |
| project_reason_glm_air_live_applied | banxe-architecture | 2 | feature | high | unique (project-reason 235b->glm-air применён и замерен 2.54s vs 28.8s (~11x), MetaClaw 7288cf8) | adopt | advances GAP-COMPUTE-GLM-AIR-REG | RESOLVED |

---

## Append Instructions (Terminal B)

Add rows at the bottom of the Entries table. One row per finding. Do NOT edit existing rows.
Use `scripts/add-il-shard.sh specproj-<slug> "NOVELTY: <description>"` when committing additions.
