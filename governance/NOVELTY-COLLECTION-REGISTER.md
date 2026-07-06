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
| agno-multimodal-agent-framework | banxe-oss-solutions | 2 | subproject | med | unique (Pythonic multi-modal agent framework; not in SRC-01 landscape of 10 frameworks) | evaluate | GAP-AGENT-ENGINE | NEW |
| smolagents-hf-micro-agent | banxe-oss-solutions | 2 | subproject | med | unique (Hugging Face micro-agent library; lightweight code-first agents, alt to CrewAI for small footprints) | evaluate | GAP-AGENT-ENGINE | NEW |
| goose-block-dev-loop-agent | banxe-oss-solutions | 2 | subproject | low | unique (Block/Square Goose dev-loop coding agent; local-only, developer-facing not customer-facing) | evaluate | NONE | NEW |
| mastra-typescript-agent-framework | banxe-oss-solutions | 2 | subproject | med | unique (TypeScript-first agent framework; possible fit for frontend intent-first surface alongside assistant-ui) | evaluate | GAP-080 (frontend intent-first) | NEW |
| langchain-js-agent-sdk | banxe-oss-solutions | 1 | feature | med | unique (JS/TS LangChain SDK for browser/edge agent surface; complements floor-1 intent-first) | evaluate | GAP-080 (frontend intent-first) | NEW |
| openmanus-rl-finetune-variant | banxe-oss-solutions | 2 | subproject | low | unique (RL-fine-tuned OpenManus variant; research-grade, not in SRC-01 OSS Descriptors) | reject | NONE | NEW |
| openhands-swe-general-agent | banxe-oss-solutions | 2 | subproject | med | unique (formerly OpenDevin; general-purpose SWE agent; possible factory-plane coding assist alt to Goose) | evaluate | NONE | NEW |
| cline-vscode-coding-agent | banxe-oss-solutions | 2 | subproject | low | unique (IDE-native VS Code coding agent; local dev tooling only, not banking runtime) | reject | NONE | NEW |
| fingpt-ai4finance-financial-llm | banxe-oss-solutions | 3 | feature | med | unique (AI4Finance FinGPT LLM fine-tuned on financial text; distinct from FinNLP/TradingAgents/Qlib entries in #1051; corpus only cites "FinGPT-style" reference) | evaluate | NONE | NEW |
| openkyc-agentic-verification | banxe-oss-solutions | 3 | subproject | med | unique (OSS KYC verification framework; alt/complement to commercial identity providers) | evaluate | GAP-KYC-ENGINE | NEW |
| verifiable-agent-kit-zk-proof | banxe-oss-solutions | 3 | compliance | high | unique (ZK-proof KYC / verifiable credentials; privacy-preserving identity attestation for GDPR-heavy flows) | evaluate | GAP-KYC-ENGINE | NEW |
| agentic-fraud-detection-pattern | banxe-oss-solutions | 3 | feature | med | unique (reference agentic fraud-detection pattern / OSS bundle; distinct from GNN family in #1051) | evaluate | GAP-FRAUD-ENGINE | NEW |
| mckinsey-agentic-reference-framework | banxe-oss-solutions | 4 | analytics | low | unique (industry reference framework; not adoptable code — benchmark for governance surface) | reject | NONE | NEW |
| cyclos-cooperative-banking-core | banxe-oss-solutions | 3 | subproject | low | unique (OSS cooperative-banking core; alt narrative for community-bank / mutual product line, not EMI-fit) | reject | NONE | NEW |
| ledgersmb-oss-accounting-core | banxe-oss-solutions | 3 | subproject | low | unique (OSS double-entry accounting; too small for EMI ledger substrate — Midaz/Blnk already primary) | reject | NONE | NEW |
| hyperledger-fabric-permissioned-ledger | banxe-oss-solutions | 3 | subproject | med | unique (Linux Foundation permissioned blockchain; alt/complement to FISCO-BCOS entry in #1051 with LF governance origin — regulator-preferred) | evaluate | NONE | NEW |
| llamaindex-rag-orchestration | banxe-oss-solutions | 2 | subproject | med | unique (RAG-orchestration framework; not in SRC-01/04; adjacent to Haystack for compliance-KB retrieval) | evaluate | GAP-COMPLIANCE-KB | NEW |
| weaviate-vector-db-alt | banxe-oss-solutions | 2 | subproject | low | unique (vector DB; ChromaDB already in use for compliance_kb, Qdrant PLANNED — Weaviate is a third alternative, no decisive fit) | reject | NONE | NEW |
| dify-llm-app-orchestration | banxe-oss-solutions | 2 | subproject | med | unique (LLM-app orchestration platform; alt to LangGraph/n8n for internal ops tooling) | evaluate | NONE | NEW |
| flowise-visual-llm-flow-builder | banxe-oss-solutions | 2 | subproject | low | unique (visual LangChain / LLM flow builder; ops tooling only) | reject | NONE | NEW |
| airflow-workflow-orchestrator | banxe-oss-solutions | 2 | subproject | med | unique (Apache Airflow; alt/complement to Temporal for data-pipeline schedules, not saga workflows) | evaluate | NONE | NEW |
| prefect-python-workflow-orchestrator | banxe-oss-solutions | 2 | subproject | low | unique (modern Python workflow orchestrator; Temporal covers saga requirement — Prefect duplicative) | reject | NONE | NEW |
| kestra-declarative-workflow | banxe-oss-solutions | 2 | subproject | low | unique (declarative workflow orchestrator; Temporal covers the requirement) | reject | NONE | NEW |
| bank-mcp-banking-server-family | banxe-oss-solutions | 3 | subproject | med | unique (banking-specific MCP server family; adjacent to banxe_mcp/server.py 34 tools but with external-bank connector focus) | evaluate | GAP-MCP-EXTERNAL-BANK | NEW |
| stripe-ai-sdk-payments-mcp | banxe-oss-solutions | 3 | feature | med | unique (Stripe AI SDK / MCP for payments-agent surface; alt to bespoke card-scheme tools) | evaluate | NONE | NEW |
| browser-use-python-web-agent | banxe-oss-solutions | 2 | feature | med | unique (Python browser automation for LLM agents; direct fit for OpenManus-like browser-agent surface) | evaluate | NONE | NEW |
| stagehand-browserbase-agentic-web | banxe-oss-solutions | 2 | subproject | low | unique (Browserbase Stagehand agentic web framework; SaaS-anchored, on-prem fit weak) | reject | NONE | NEW |
| skyvern-vision-web-automation | banxe-oss-solutions | 2 | feature | med | unique (vision-based web automation; possible fit for regulatory-portal automation, e.g. FCA Connect uploads) | evaluate | GAP-REG-PORTAL-AUTOMATION | NEW |
| playwright-microsoft-browser-automation | banxe-oss-solutions | 2 | infra | med | unique (Microsoft Playwright; browser automation lib for both agents and test surface) | evaluate | NONE | NEW |
| lm-studio-desktop-llm-manager | banxe-oss-solutions | 2 | infra | low | unique (desktop LLM manager; Ollama already covers on-prem serving — LM-Studio duplicative for our stack) | reject | NONE | NEW |
| open-webui-selfhosted-chat-ui | banxe-oss-solutions | 2 | feature | med | unique (self-hosted chat UI over Ollama; possible operator-side console alt to Telegram OpenClaw bot) | evaluate | NONE | NEW |
| guardrails-ai-validators | banxe-oss-solutions | 4 | compliance | high | unique (Guardrails.ai OSS validators / structured outputs; complements NeMo-Guardrails at LLM-input layer) | adopt | OD-LLM-SECURITY | NEW |
| arize-phoenix-llm-tracing | banxe-oss-solutions | 4 | infra | med | unique (Arize Phoenix OSS LLM tracing / evals; alt/complement to Langfuse for eval-side observability) | evaluate | GAP-LLM-OBSERVABILITY | NEW |
| langsmith-observability | banxe-oss-solutions | 4 | infra | low | unique (LangChain observability; SaaS-anchored, Langfuse already the adopt candidate) | reject | NONE | NEW |
| deepeval-llm-eval-framework | banxe-oss-solutions | 4 | infra | med | unique (Confident-AI OSS LLM eval framework; direct fit for ADR-141 self-healing eval harness) | evaluate | GAP-LLM-EVAL | NEW |
| ragas-rag-evaluation | banxe-oss-solutions | 4 | infra | med | unique (RAG-specific evaluation lib; fits compliance_kb RAG quality gate) | evaluate | GAP-COMPLIANCE-KB | NEW |
| mlflow-ml-lifecycle-tracking | banxe-oss-solutions | 4 | infra | med | unique (Databricks OSS ML/LLM lifecycle tracking; fits fraud/credit model registry and self-healing loop) | evaluate | GAP-FRAUD-ENGINE | NEW |
| styletts2-neural-tts | banxe-oss-solutions | 2 | feature | low | unique (alt TTS engine; ADR-112 already commits to XTTS/Kokoro — StyleTTS2 not decisive) | reject | NONE | NEW |
| lightgbm-fraud-credit-gbm | banxe-oss-solutions | 3 | feature | high | unique (Microsoft LightGBM; established gradient-boosting for fraud/credit scoring — production baseline before deep-learning) | adopt | GAP-FRAUD-ENGINE | NEW |
| xgboost-fraud-credit-gbm | banxe-oss-solutions | 3 | feature | high | unique (XGBoost; established gradient-boosting baseline for fraud/credit — LightGBM sibling) | evaluate | GAP-FRAUD-ENGINE | NEW |
| credit-scoring-oss-pipeline | banxe-oss-solutions | 3 | subproject | med | unique (OSS credit-scoring pipeline reference; direct fit for consumer-lending readiness) | evaluate | GAP-CREDIT-SCORING | NEW |
| spiderfoot-osint-adverse-media | banxe-concept-v7v9 | 3 | subproject | med | unique (open-source OSINT reconnaissance; complements adverse-media governor with automated web-source enumeration for MLRO / EDD packs) | evaluate | GAP-ADVERSE-MEDIA-OSINT | NEW |
| gdelt-global-events-knowledge-graph | banxe-concept-v7v9 | 3 | analytics | med | unique (GDELT Project; global events / tone / mentions dataset for real-time PEP / adverse-media signal enrichment) | evaluate | GAP-ADVERSE-MEDIA-OSINT | NEW |
| onionsearch-tor-index-scanner | banxe-concept-v7v9 | 3 | subproject | low | unique (Tor .onion search index enumerator; dark-web AML signal source — legally sensitive, sandboxed evaluation only) | evaluate | GAP-DARKWEB-OSINT | NEW |
| torbot-tor-crawler-osint | banxe-concept-v7v9 | 3 | subproject | low | unique (Tor .onion crawler / OSINT harvester; alt / complement to OnionSearch for dark-web AML feeds) | evaluate | GAP-DARKWEB-OSINT | NEW |
| reputell-onion-reputation-signal | banxe-concept-v7v9 | 3 | analytics | low | unique (Tor reputation signal aggregator; sanctions / fraud reputational context for VASP counterparties) | evaluate | GAP-DARKWEB-OSINT | NEW |
| paynetics-bin-sponsor-emi | banxe-concept-v7v9 | 3 | subproject | high | unique (Paynetics EEA/UK BIN sponsor + issuing partner; alt / complement to Paymentology for card issuance under EMI) | evaluate | GAP-074 (card issuing) | NEW |
| transact-pay-em-processing | banxe-concept-v7v9 | 3 | subproject | med | unique (Transact Pay UK EMI card processor; alt BIN sponsor / issuing partner for EMI-hosted card programme) | evaluate | GAP-074 (card issuing) | NEW |
| tribe-payments-emi-processor | banxe-concept-v7v9 | 3 | subproject | med | unique (Tribe Payments UK card issuing / acquiring stack; comparable BIN sponsor tier for card programme diversification) | evaluate | GAP-074 (card issuing) | NEW |
| fireblocks-mpc-custody-paybis-scope | banxe-concept-v7v9 | 3 | subproject | low | unique (Fireblocks MPC custody + Travel Rule; PAYBIS-scope only — Banxe crypto custody handled white-label by PAYBIS, ADR-138) | reject | NONE | NEW |
| jenesto-core-banking-alt | banxe-concept-v7v9 | 2 | subproject | low | unique (Jenesto API-first core banking; alt reference to Midaz/Fineract/Formance/Blnk stack — ADR-013 already selects Midaz PRIMARY / Fineract FALLBACK) | reject | NONE | NEW |
| sdk-finance-core-banking-alt | banxe-concept-v7v9 | 2 | subproject | low | unique (SDK.finance modular core banking; alt reference to Midaz/Fineract/Formance/Blnk stack — ADR-013 already selects Midaz PRIMARY / Fineract FALLBACK) | reject | NONE | NEW |
| tremor-react-dashboard-components | banxe-concept-v7v9 | 1 | feature | med | unique (Tremor React charts / KPI blocks; MIT; fit for internal ops / MLRO dashboards alongside GAP-080 intent-first surface) | evaluate | GAP-080 (frontend intent-first) | NEW |
| bmad-agentic-dev-method | banxe-concept-v7v9 | 1 | subproject | med | unique (BMAD-method agent-orchestrated dev workflow; complements factory-plane skills orchestration — not a runtime component) | evaluate | NONE | NEW |
| dutymark-consumer-duty-tracker | banxe-concept-v7v9 | 4 | compliance | med | unique (Consumer Duty outcome-tracking tool; complements ADR-054 analytics/reporting mask and Consumer Duty S9-06 line) | evaluate | GAP-CONSUMER-DUTY-TRACKING | NEW |
| omp-fca-obligations-mapping-tool | banxe-concept-v7v9 | 4 | compliance | med | unique (FCA obligations / rulebook mapping tool; complements COMPLIANCE-MATRIX 200+ req and regulatory horizon-scan) | evaluate | GAP-FCA-OBLIGATIONS-MAPPING | NEW |
| lending-2027-consumer-credit-roadmap | banxe-concept-v7v9 | 3 | subproject | low | unique (Lending 2027 roadmap item; consumer credit is OUT-OF-SCOPE for UK EMI licence — requires FCA CCA authorisation, not e-money) | reject | B-EMI-CREDIT-GATE-001 | NEW |
| sme-alternative-credit-scoring-2027 | banxe-concept-v7v9 | 3 | analytics | low | unique (SME alt credit-scoring model; OUT-OF-SCOPE for UK EMI — SME lending needs distinct authorisation; retain as post-EMI horizon only) | reject | B-EMI-CREDIT-GATE-001 | NEW |

---

## Append Instructions (Terminal B)

Add rows at the bottom of the Entries table. One row per finding. Do NOT edit existing rows.
Use `scripts/add-il-shard.sh specproj-<slug> "NOVELTY: <description>"` when committing additions.
