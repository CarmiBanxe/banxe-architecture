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
| litellm_4000_single_listener_guard | banxe-architecture | 2 | infra | high | unique (systemd drop-in ExecStartPre kill-stale + Restart=on-failure предотвращает orphan co-bind :4000 через SO_REUSEPORT, устраняя мерцающий routing) | adopt | closes GAP "systemd single-listener guard"; apply=operator-Legion | OPEN |
| deerflow-banking-orchestrator | emi-banxe-stack-review | 2 | subproject | med | unique (ByteDance DeerFlow multi-agent orchestrator; not in SRC-01 landscape of 10 frameworks) | evaluate | GAP-AGENT-ENGINE (compare vs LangGraph/OWL) | NEW |
| agenticseek-privacy-first-agent | emi-banxe-stack-review | 2 | subproject | low | unique (fully-local autonomous agent framework; privacy-first alt for on-prem MLRO tooling) | evaluate | NONE | NEW |
| suna-self-hosted-manus-clone | emi-banxe-stack-review | 2 | subproject | low | unique (Kortix Suna self-hosted general agent; competes with existing OWL/CAMEL choice) | evaluate | NONE | NEW |
| nuformer-tx-embedding-model | emi-banxe-stack-review | 3 | feature | high | unique (transformer pre-trained on merchant tx sequences; embedding-based fraud discriminator) | evaluate | GAP-FRAUD-ENGINE | NEW |
| transactiongpt-payments-llm | emi-banxe-stack-review | 3 | feature | high | unique (payments-domain LLM for tx annotation / anomaly explanation) | evaluate | GAP-FRAUD-ENGINE | NEW |
| wechatpay-gpt-payments-llm | emi-banxe-stack-review | 3 | analytics | low | unique (Tencent WeChatPay-GPT reference; PRC-only, non-adoptable but benchmark for payments-LLM class) | reject | NONE | NEW |
| hgnn-heterogeneous-gnn-fraud | emi-banxe-stack-review | 3 | feature | high | unique (heterogeneous GNN over multi-entity tx graph; better cross-type fraud detection than homogeneous GNN) | evaluate | GAP-FRAUD-ENGINE | NEW |
| fraudgnn-rl-adaptive | emi-banxe-stack-review | 3 | feature | high | unique (GNN + RL for online-adaptive fraud thresholds; auto-tunes decision policy against adversarial drift) | evaluate | GAP-FRAUD-ENGINE | NEW |
| asa-gnn-adversarial-safe | emi-banxe-stack-review | 3 | compliance | med | unique (adversarial-safe GNN; hardens fraud model against poisoning attacks — regulator-relevant) | evaluate | GAP-FRAUD-ENGINE | NEW |
| fate-federated-learning-webank | emi-banxe-stack-review | 4 | subproject | high | unique (WeBank FATE federated learning framework; enables cross-bank AML consortium without raw-data sharing) | evaluate | GAP-AML-CROSS-BANK | NEW |
| fedkt-federated-knowledge-transfer | emi-banxe-stack-review | 4 | feature | med | unique (teacher-student FL variant; alt to FATE for private cross-bank model transfer with tighter DP guarantees) | evaluate | GAP-AML-CROSS-BANK | NEW |
| vaultgemma-dp-private-llm | emi-banxe-stack-review | 4 | feature | high | unique (Google differentially-private Gemma; production-safe LLM under strong GDPR / customer-data constraints) | evaluate | GAP-LLM-PRIVACY | NEW |
| finrl-deepseek-rl-treasury | emi-banxe-stack-review | 3 | feature | med | unique (FinRL + DeepSeek reasoning for treasury / FX policy learning; RL agent for hedging decisions) | evaluate | NONE | NEW |
| assistant-ui-agent-frontend | emi-banxe-stack-review | 1 | feature | high | unique (assistant-ui React library; direct fit for GAP-080 intent-first floor-1 UI missing 6 card variants) | evaluate | GAP-080 (frontend intent-first) | NEW |
| fisco-bcos-permissioned-ledger | emi-banxe-stack-review | 3 | subproject | med | unique (WeBank FISCO-BCOS permissioned blockchain; alt for interbank recon / settlement consortium substrate) | evaluate | NONE | NEW |
| strands-sdk-aws-agent-framework | emi-banxe-stack-review | 2 | subproject | med | unique (AWS Strands agent SDK; opinionated agent-native runtime, alt to LangGraph for cloud-native flows) | evaluate | NONE | NEW |
| sofastack-financial-cloud-antgroup | emi-banxe-stack-review | 3 | subproject | low | unique (Ant Group SOFAStack full-stack fin-cloud; PRC-origin, not EU/UK-adoptable — reference only) | reject | NONE | NEW |
| finrobot-fintech-multi-agent | emi-banxe-stack-review | 2 | subproject | med | unique (AI4Finance FinRobot LLM-powered financial multi-agent framework; adjacent to trading / treasury agents) | evaluate | NONE | NEW |
| finnlp-domain-nlp-toolkit | emi-banxe-stack-review | 3 | feature | med | unique (AI4Finance FinNLP toolkit for financial NLP; sentiment / relation extraction from filings / news) | evaluate | NONE | NEW |
| tradingagents-llm-multi-agent | emi-banxe-stack-review | 3 | subproject | med | unique (AI4Finance TradingAgents multi-agent LLM trading system; reference for treasury-desk agent design) | evaluate | NONE | NEW |
| qlib-quant-research-platform | emi-banxe-stack-review | 3 | subproject | med | unique (Microsoft Qlib quant AI platform; reference for FX / treasury back-testing pipeline) | evaluate | NONE | NEW |
| owasp-llm-top10-supply-chain | emi-banxe-stack-review | 4 | compliance | high | unique (OWASP LLM Top-10 checklist; MUST integrate into ai-cost-policy and OSS-supply-chain review) | adopt | OD-LLM-SECURITY | NEW |
| nemo-guardrails-runtime-safety | emi-banxe-stack-review | 4 | compliance | high | unique (NVIDIA NeMo Guardrails runtime for LLM input/output policy enforcement; runtime complement to prompt canon) | adopt | OD-LLM-SECURITY | NEW |
| lime-shap-hitl-explainability | emi-banxe-stack-review | 4 | compliance | med | unique (LIME / SHAP for ADR-046 decision-lineage explainability fields; sharper MLRO / HITL rationale) | evaluate | GAP-DECISION-LINEAGE-XAI | NEW |
| github-agentic-workflows-ci | emi-banxe-stack-review | 4 | infra | med | unique (GitHub agentic workflows for agent-authored PR CI; alt / complement to Hermes tier-1 watchdog) | evaluate | NONE | NEW |
| langfuse-llm-observability | emi-banxe-stack-review | 4 | infra | high | unique (Langfuse prompt / trace / cost observability across the LiteLLM :4000 fleet; complements decision-lineage) | adopt | GAP-LLM-OBSERVABILITY | NEW |
| memory-first-agent-architecture | emi-banxe-stack-review | 2 | subproject | med | unique (memory-first agent architecture — Mem0 / Zep persistent memory as the primary reasoning substrate) | evaluate | NONE | NEW |
| fate-cross-bank-aml-consortium | emi-banxe-stack-review | 4 | subproject | high | unique (FATE-based cross-bank AML consortium concept; multi-EMI federated fraud detection roadmap) | evaluate | GAP-AML-CROSS-BANK | NEW |
| quantum-gnn-fraud-research | emi-banxe-stack-review | 3 | analytics | low | unique (quantum-annealed GNN for fraud; TRL ≈ 2, research-only horizon — track but do not fund) | reject | NONE | NEW |
| temporal-knowledge-distillation-fraud | emi-banxe-stack-review | 3 | feature | med | unique (temporal knowledge distillation for streaming fraud model refresh without catastrophic forgetting) | evaluate | GAP-FRAUD-ENGINE | NEW |

---

## Append Instructions (Terminal B)

Add rows at the bottom of the Entries table. One row per finding. Do NOT edit existing rows.
Use `scripts/add-il-shard.sh specproj-<slug> "NOVELTY: <description>"` when committing additions.
