---
title: "ADOPTION-AUDIT — 88 NEW findings (ratified Q4 two-stage triage) — PROPOSED"
status: PROPOSED
classification: derived decision artefact (pointer-first per ADR-102)
central_finalization_required: true
intake_date: 2026-07-07
author: Terminal-B (Central-assist, specproj sp41)
inputs:
  - "governance/NOVELTY-COLLECTION-REGISTER.md (88 NEW findings, lines 43–130)"
  - "docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md (Q4 ratified two-stage triage)"
  - "governance/DIRECTIVE-BESTDEC-RATIFY-001.md (Q1–Q5 APPROVED by operator + Central)"
invariants: I-27 preserved; EMI scope preserved; numbers = governed-config *proposal*
adoption_note: NOT auto — each ADOPT requires its own sprint/IL and Central sign-off
---

# ADOPTION-AUDIT — 88 NEW findings — PROPOSED (Central finalizes)

> **Status: PROPOSED.** This is a *derived decision artefact* (ADR-102: pointer-first, no source
> restate). It applies the **ratified Q4 two-stage triage** from
> `docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md` §Q4 (see also
> `governance/DIRECTIVE-BESTDEC-RATIFY-001.md` — Q1–Q5 APPROVED by operator + Central) to the
> **88 NEW findings** in `governance/NOVELTY-COLLECTION-REGISTER.md` (lines 43–130,
> `status: NEW`).
>
> **Nothing here activates a decision.** All numeric parameters (HGC / FCR / AC / CGR weights,
> ADOPT/DEFER/REJECT bands, FCR ≥ 0.80 override) are **governed-config *proposals*** per
> CLAUDE.md §10. Central + operator finalize verdicts. Each ADOPT that survives finalization
> lands as its **own sprint/IL** — this audit does not adopt anything itself. **I-27 preserved**
> end-to-end; the NOVELTY register is unchanged (append-only, no row edits).

## Method — ratified Q4 two-stage triage (verbatim reference, no restate)

The exact triage steps, thresholds, and lexicographic override are canonical in
`docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md` §Q4:

- **Stage 1 — Hard-gate** (deterministic, first): EMI-scope / sanctions / I-27 admissibility.
  - Credit / lending / investment / trading **outside TOMPAY-EMI licence** (credit / lending /
    TradingAgents / Qlib / FinRL and similar) → **DEFER-to-licence** under handoff anchor
    `B-EMI-CREDIT-GATE-001`. No score computed.
  - Sanctions surface / I-27 incompatible (e.g. PRC-state-affiliated fintech references not
    adoptable under UK/EEA regulator posture) → **REJECT-hard**. No score computed.
- **Stage 2 — Dedup-by-need**: collapse duplicates that reduce to the same operational
  capability-need → keep-best; the rest recorded as `dup-of:<item>`.
- **Stage 3 — Score-triage** on the remaining survivors, using metric family
  **HGC / FCR / AC / CGR** as *governed-config proposal*, weighted:

  ```
  S = 0.35·FCR + 0.15·CGR − 0.30·HGC − 0.20·AC     (normalised 0..1 via +0.50 shift)
  ADOPT   S ≥ 0.60
  DEFER   0.30 ≤ S < 0.60
  REJECT  S < 0.30
  Lexicographic override: FCR ≥ 0.80 → ESCALATE-IMMEDIATE (single-dimension safety dominance)
  ```

Metric family (operational definitions used in this audit, still governed-config proposal):

- **HGC** — Human-Governance-Cost (higher = more human oversight required).
- **FCR** — Financial/Compliance-Risk-reduction fit (higher = stronger risk-reduction /
  regulator-facing hardening).
- **AC**  — Adoption-Cost (higher = costlier integration / infra).
- **CGR** — Capability-Growth-Return (higher = more capability added to the fleet).

All four are on `[0, 1]`.

## Summary (proposed counts)

| Bucket | Count | Notes |
|--------|------:|-------|
| TOTAL NEW findings audited                                    | **88** | rows 43–130 of `NOVELTY-COLLECTION-REGISTER.md` |
| Stage-1 REJECT-hard (sanctions / I-27 incompatible)            | **2**  | PRC state-affiliated fintech references (rows 48, 59) |
| Stage-1 DEFER-to-licence (credit / lending / investment / trading OOS TOMPAY-EMI) | **8** | credit / lending / trading-agents / Qlib / FinRL / FinRobot / FinGPT / SME-credit families |
| Stage-2 DUP (dedup-by-need)                                   | **8**  | card-issuing 3-overlap, FATE 3-overlap, fraud-GNN pair, LLM-observability pair, GBM pair, Tor OSINT pair |
| Stage-3 ADOPT (S ≥ 0.60)                                       | **9**  | of which **3** are FCR ≥ 0.80 → **ESCALATE-IMMEDIATE** |
| Stage-3 DEFER (0.30 ≤ S < 0.60)                                | **44** | Central review band — manual finalization required |
| Stage-3 REJECT (S < 0.30)                                      | **17** | score-driven, atop 2 Stage-1 hard-rejects (grand-total REJECT = 19) |
| **Grand-total REJECT (Stage-1 hard + Stage-3 score)**          | **19** | for the one-line status field |

> **Verdicts = PROPOSED.** Adoption is **NOT** auto. Central + operator finalize;
> each surviving ADOPT lands as **its own sprint / IL** with Duplication Audit (ADR-102).
> Credit / lending / trading DEFERs remain gated behind `B-EMI-CREDIT-GATE-001` and await a
> licence-scope extension. **Numbers = governed-config proposal**; they only reach production
> via a human-gated PR against `governance/novelty-pipeline-config.yaml` (or equivalent).

## Full triage table

Column key: `stage1` = pass / credit-DEFER / reject-hard; `dedup` = keep / `dup-of:<item>`.
Scored items show HGC / FCR / AC / CGR / S (all `[0,1]`, proposals). Non-scored items
(REJECT-hard, DEFER-credit, DUP) leave the metric columns as `—`. `verdict-proposed` is the
Stage-1/2/3 outcome; `reason` is the audit rationale.

| # | item | stage1 | dedup | HGC | FCR | AC | CGR | S | proposed-verdict | reason |
|---|------|--------|-------|-----|-----|----|-----|---|------------------|--------|
| 43 | deerflow-banking-orchestrator | pass | keep | 0.55 | 0.40 | 0.65 | 0.50 | 0.42 | DEFER | banking-specialised agent orchestrator; medium fit, non-trivial integration |
| 44 | agenticseek-privacy-first-agent | pass | keep | 0.35 | 0.55 | 0.40 | 0.35 | 0.56 | DEFER | privacy-first local agent; useful for on-prem MLRO tooling but low value |
| 45 | suna-self-hosted-manus-clone | pass | keep | 0.50 | 0.30 | 0.55 | 0.30 | 0.39 | DEFER | self-hosted general agent; competes with existing OWL/CAMEL choice |
| 46 | nuformer-tx-embedding-model | pass | keep | 0.45 | 0.75 | 0.50 | 0.65 | 0.625 | **ADOPT** | tx-embedding fraud discriminator; strong FCR fit for fraud engine |
| 47 | transactiongpt-payments-llm | pass | keep | 0.55 | 0.65 | 0.60 | 0.60 | 0.53 | DEFER | payments-domain LLM; high value but LLM-safety overhead moderate |
| 48 | wechatpay-gpt-payments-llm | **reject-hard** | — | — | — | — | — | — | **REJECT-hard** | PRC state-affiliated (Tencent WeChatPay); non-adoptable under UK/EEA regulator posture — sanctions / regulator-friction bucket |
| 49 | hgnn-heterogeneous-gnn-fraud | pass | **keep** (fraud-GNN capability) | 0.50 | 0.75 | 0.55 | 0.65 | 0.60 | **ADOPT** | heterogeneous GNN over multi-entity tx graph; best-fit fraud GNN |
| 50 | fraudgnn-rl-adaptive | pass | dup-of:hgnn-heterogeneous-gnn-fraud (49) | — | — | — | — | — | DUP | overlaps 49 on capability-need (fraud-GNN); RL adaptive dimension can revisit in follow-on |
| 51 | asa-gnn-adversarial-safe | pass | keep (distinct adversarial-safe capability) | 0.50 | 0.70 | 0.55 | 0.55 | 0.57 | DEFER | adversarial-safe GNN; distinct capability but net score borderline |
| 52 | fate-federated-learning-webank | pass | **keep** (FATE capability) | 0.65 | 0.60 | 0.75 | 0.65 | 0.46 | DEFER | cross-bank AML consortium substrate; medium-high governance overhead (WeBank origin) |
| 53 | fedkt-federated-knowledge-transfer | pass | dup-of:fate-federated-learning-webank (52) | — | — | — | — | — | DUP | alt FL variant to FATE; same capability-need (cross-bank AML) |
| 54 | vaultgemma-dp-private-llm | pass | keep | 0.55 | 0.75 | 0.60 | 0.60 | 0.57 | DEFER | DP LLM under GDPR / customer-data constraints; borderline ADOPT |
| 55 | finrl-deepseek-rl-treasury | **credit-DEFER** | — | — | — | — | — | — | **DEFER-to-licence** | RL treasury / FX policy learning — investment/trading-adjacent, OOS TOMPAY-EMI → `B-EMI-CREDIT-GATE-001` |
| 56 | assistant-ui-agent-frontend | pass | keep | 0.30 | 0.50 | 0.35 | 0.65 | 0.61 | **ADOPT** | direct fit for GAP-080 floor-1 intent-first UI; low HGC / AC |
| 57 | fisco-bcos-permissioned-ledger | pass | keep | 0.65 | 0.35 | 0.75 | 0.40 | 0.34 | DEFER | WeBank permissioned blockchain; high AC / HGC — regulator-preferred alt exists (Hyperledger) |
| 58 | strands-sdk-aws-agent-framework | pass | keep | 0.55 | 0.40 | 0.55 | 0.45 | 0.43 | DEFER | AWS-opinionated agent SDK; cloud-native lean vs on-prem posture |
| 59 | sofastack-financial-cloud-antgroup | **reject-hard** | — | — | — | — | — | — | **REJECT-hard** | Ant Group PRC-origin full fin-cloud; not EU/UK-adoptable — sanctions / regulator-friction |
| 60 | finrobot-fintech-multi-agent | **credit-DEFER** | — | — | — | — | — | — | **DEFER-to-licence** | multi-agent framework adjacent to trading / treasury desks → OOS TOMPAY-EMI |
| 61 | finnlp-domain-nlp-toolkit | pass | keep | 0.40 | 0.50 | 0.45 | 0.50 | 0.54 | DEFER | financial NLP; potential AML-adjacent uses (sentiment / entity extraction from filings) |
| 62 | tradingagents-llm-multi-agent | **credit-DEFER** | — | — | — | — | — | — | **DEFER-to-licence** | explicit LLM trading system → OOS TOMPAY-EMI |
| 63 | qlib-quant-research-platform | **credit-DEFER** | — | — | — | — | — | — | **DEFER-to-licence** | Microsoft Qlib quant platform → OOS TOMPAY-EMI |
| 64 | owasp-llm-top10-supply-chain | pass | keep | 0.20 | **0.85** | 0.20 | 0.60 | 0.79 | **ADOPT + ESCALATE-IMMEDIATE** | OWASP LLM Top-10 checklist; FCR ≥ 0.80 override — integrate into `ai-cost-policy` + OSS supply-chain review |
| 65 | nemo-guardrails-runtime-safety | pass | keep | 0.35 | **0.80** | 0.40 | 0.60 | 0.685 | **ADOPT + ESCALATE-IMMEDIATE** | NVIDIA NeMo Guardrails runtime; FCR ≥ 0.80 override — runtime complement to prompt canon |
| 66 | lime-shap-hitl-explainability | pass | keep | 0.35 | 0.65 | 0.35 | 0.50 | 0.63 | **ADOPT** | LIME / SHAP for ADR-046 decision-lineage; sharper MLRO / HITL rationale |
| 67 | github-agentic-workflows-ci | pass | keep | 0.35 | 0.40 | 0.30 | 0.40 | 0.535 | DEFER | agentic PR CI; alt / complement to Hermes tier-1 watchdog |
| 68 | langfuse-llm-observability | pass | **keep** (LLM observability capability) | 0.35 | 0.70 | 0.40 | 0.65 | 0.66 | **ADOPT** | prompt / trace / cost observability across LiteLLM :4000 fleet |
| 69 | memory-first-agent-architecture | pass | keep | 0.45 | 0.40 | 0.50 | 0.55 | 0.49 | DEFER | Mem0 / Zep memory-first architecture; medium fit, no compelling need vs current stack |
| 70 | fate-cross-bank-aml-consortium | pass | dup-of:fate-federated-learning-webank (52) | — | — | — | — | — | DUP | roadmap concept over the same FATE substrate as 52 |
| 71 | quantum-gnn-fraud-research | pass | keep | 0.60 | 0.20 | 0.75 | 0.20 | 0.27 | **REJECT** | TRL ≈ 2 research horizon; track but do not fund |
| 72 | temporal-knowledge-distillation-fraud | pass | keep | 0.45 | 0.65 | 0.50 | 0.55 | 0.575 | DEFER | KD for streaming fraud model refresh; useful but complementary to primary GNN |
| 73 | agno-multimodal-agent-framework | pass | keep | 0.45 | 0.40 | 0.50 | 0.45 | 0.47 | DEFER | Pythonic multi-modal agent framework; overlaps existing choices |
| 74 | smolagents-hf-micro-agent | pass | keep | 0.30 | 0.40 | 0.30 | 0.40 | 0.55 | DEFER | HF micro-agent; lightweight small-footprint alt |
| 75 | goose-block-dev-loop-agent | pass | keep | 0.30 | 0.25 | 0.30 | 0.30 | 0.48 | DEFER | dev-loop coding agent; developer-facing, not customer-facing |
| 76 | mastra-typescript-agent-framework | pass | keep | 0.40 | 0.40 | 0.45 | 0.45 | 0.50 | DEFER | TS agent framework; possible fit alongside assistant-ui (56) |
| 77 | langchain-js-agent-sdk | pass | keep | 0.30 | 0.40 | 0.35 | 0.45 | 0.55 | DEFER | JS/TS SDK for browser / edge agent surface |
| 78 | openmanus-rl-finetune-variant | pass | keep | 0.65 | 0.15 | 0.65 | 0.20 | 0.26 | **REJECT** | research-grade RL fine-tuned OpenManus variant; not in SRC-01 |
| 79 | openhands-swe-general-agent | pass | keep | 0.45 | 0.35 | 0.50 | 0.45 | 0.46 | DEFER | formerly OpenDevin; general-purpose SWE agent, factory-plane assist |
| 80 | cline-vscode-coding-agent | pass | keep | 0.55 | 0.10 | 0.50 | 0.15 | 0.29 | **REJECT** | IDE-native VS Code coding agent; not banking runtime |
| 81 | fingpt-ai4finance-financial-llm | **credit-DEFER** | — | — | — | — | — | — | **DEFER-to-licence** | AI4Finance FinGPT LLM; trading / portfolio adjacencies → OOS TOMPAY-EMI |
| 82 | openkyc-agentic-verification | pass | keep | 0.45 | 0.65 | 0.55 | 0.55 | 0.565 | DEFER | OSS KYC framework; borderline — need pilot vs commercial provider baseline |
| 83 | verifiable-agent-kit-zk-proof | pass | keep | 0.55 | 0.75 | 0.65 | 0.65 | 0.565 | DEFER | ZK-proof KYC / verifiable credentials; strong FCR but heavy AC |
| 84 | agentic-fraud-detection-pattern | pass | keep | 0.45 | 0.55 | 0.50 | 0.45 | 0.525 | DEFER | agentic fraud pattern bundle; complements GNN family but not decisive |
| 85 | mckinsey-agentic-reference-framework | pass | keep | 0.60 | 0.10 | 0.60 | 0.15 | 0.26 | **REJECT** | industry reference framework; not adoptable code |
| 86 | cyclos-cooperative-banking-core | pass | keep | 0.65 | 0.15 | 0.75 | 0.20 | 0.24 | **REJECT** | community-bank / mutual product line; not EMI-fit |
| 87 | ledgersmb-oss-accounting-core | pass | keep | 0.65 | 0.15 | 0.70 | 0.20 | 0.25 | **REJECT** | OSS double-entry accounting; too small for EMI ledger substrate (Midaz/Blnk PRIMARY per ADR-013) |
| 88 | hyperledger-fabric-permissioned-ledger | pass | keep | 0.65 | 0.45 | 0.75 | 0.50 | 0.39 | DEFER | LF permissioned blockchain; better regulator posture than FISCO-BCOS but heavy AC |
| 89 | llamaindex-rag-orchestration | pass | keep | 0.40 | 0.55 | 0.45 | 0.50 | 0.56 | DEFER | RAG orchestration; adjacent to Haystack for compliance-KB retrieval |
| 90 | weaviate-vector-db-alt | pass | keep | 0.55 | 0.15 | 0.60 | 0.15 | 0.29 | **REJECT** | vector DB; ChromaDB in use + Qdrant PLANNED — third alt not decisive |
| 91 | dify-llm-app-orchestration | pass | keep | 0.45 | 0.40 | 0.50 | 0.45 | 0.47 | DEFER | LLM-app orchestration; alt to LangGraph / n8n for internal ops |
| 92 | flowise-visual-llm-flow-builder | pass | keep | 0.60 | 0.10 | 0.55 | 0.15 | 0.27 | **REJECT** | visual LangChain / LLM flow builder; ops tooling only |
| 93 | airflow-workflow-orchestrator | pass | keep | 0.45 | 0.40 | 0.55 | 0.45 | 0.46 | DEFER | Apache Airflow; alt for data-pipeline schedules (Temporal covers sagas) |
| 94 | prefect-python-workflow-orchestrator | pass | keep | 0.60 | 0.15 | 0.60 | 0.20 | 0.28 | **REJECT** | modern Python workflow; Temporal already covers saga requirement |
| 95 | kestra-declarative-workflow | pass | keep | 0.60 | 0.15 | 0.60 | 0.20 | 0.28 | **REJECT** | declarative workflow; Temporal already covers the requirement |
| 96 | bank-mcp-banking-server-family | pass | keep | 0.45 | 0.55 | 0.50 | 0.55 | 0.54 | DEFER | banking-specific MCP servers; external-bank connector focus |
| 97 | stripe-ai-sdk-payments-mcp | pass | keep | 0.45 | 0.45 | 0.40 | 0.50 | 0.52 | DEFER | Stripe AI SDK / MCP; alt to bespoke card-scheme tools |
| 98 | browser-use-python-web-agent | pass | keep | 0.45 | 0.40 | 0.40 | 0.45 | 0.49 | DEFER | Python browser automation for LLM agents |
| 99 | stagehand-browserbase-agentic-web | pass | keep | 0.65 | 0.15 | 0.65 | 0.20 | 0.26 | **REJECT** | SaaS-anchored agentic web framework; weak on-prem fit |
| 100 | skyvern-vision-web-automation | pass | keep | 0.50 | 0.60 | 0.55 | 0.55 | 0.5325 | DEFER | vision-based web automation; possible reg-portal automation fit |
| 101 | playwright-microsoft-browser-automation | pass | keep | 0.30 | 0.40 | 0.30 | 0.45 | 0.5575 | DEFER | Microsoft Playwright; browser automation lib for agents + test surface |
| 102 | lm-studio-desktop-llm-manager | pass | keep | 0.60 | 0.10 | 0.55 | 0.15 | 0.27 | **REJECT** | desktop LLM manager; Ollama already covers on-prem serving |
| 103 | open-webui-selfhosted-chat-ui | pass | keep | 0.35 | 0.35 | 0.35 | 0.45 | 0.515 | DEFER | self-hosted chat UI over Ollama; alt operator console |
| 104 | guardrails-ai-validators | pass | keep | 0.35 | **0.80** | 0.35 | 0.60 | 0.695 | **ADOPT + ESCALATE-IMMEDIATE** | Guardrails.ai OSS validators; FCR ≥ 0.80 override — complements NeMo-Guardrails at LLM-input layer |
| 105 | arize-phoenix-llm-tracing | pass | dup-of:langfuse-llm-observability (68) | — | — | — | — | — | DUP | overlaps 68 on LLM-observability capability (Langfuse chosen keep-best) |
| 106 | langsmith-observability | pass | keep | 0.65 | 0.15 | 0.60 | 0.20 | 0.27 | **REJECT** | LangChain observability; SaaS-anchored, Langfuse is adopt candidate |
| 107 | deepeval-llm-eval-framework | pass | keep | 0.35 | 0.55 | 0.40 | 0.55 | 0.59 | DEFER | Confident-AI OSS LLM eval; direct fit for ADR-141 self-healing harness |
| 108 | ragas-rag-evaluation | pass | keep | 0.35 | 0.55 | 0.40 | 0.50 | 0.5825 | DEFER | RAG-specific evaluation; fits compliance_kb RAG quality gate |
| 109 | mlflow-ml-lifecycle-tracking | pass | keep | 0.45 | 0.55 | 0.50 | 0.55 | 0.54 | DEFER | Databricks OSS ML/LLM lifecycle; fits fraud/credit model registry |
| 110 | styletts2-neural-tts | pass | keep | 0.60 | 0.10 | 0.55 | 0.15 | 0.27 | **REJECT** | alt TTS; ADR-112 already commits to XTTS / Kokoro |
| 111 | lightgbm-fraud-credit-gbm | pass | **keep** (GBM capability, EMI-scope fraud use) | 0.35 | 0.75 | 0.30 | 0.65 | 0.695 | **ADOPT** | LightGBM baseline for **fraud** (EMI-scope); credit-use gated behind `B-EMI-CREDIT-GATE-001` |
| 112 | xgboost-fraud-credit-gbm | pass | dup-of:lightgbm-fraud-credit-gbm (111) | — | — | — | — | — | DUP | XGBoost sibling; same capability-need (GBM baseline) |
| 113 | credit-scoring-oss-pipeline | **credit-DEFER** | — | — | — | — | — | — | **DEFER-to-licence** | OSS credit-scoring pipeline → OOS TOMPAY-EMI, `B-EMI-CREDIT-GATE-001` |
| 114 | spiderfoot-osint-adverse-media | pass | keep | 0.50 | 0.60 | 0.45 | 0.55 | 0.5525 | DEFER | OSS OSINT; complements adverse-media governor for MLRO / EDD |
| 115 | gdelt-global-events-knowledge-graph | pass | keep | 0.40 | 0.55 | 0.35 | 0.55 | 0.585 | DEFER | global events / tone dataset for PEP / adverse-media enrichment |
| 116 | onionsearch-tor-index-scanner | pass | **keep** (Tor OSINT capability) | 0.75 | 0.35 | 0.60 | 0.40 | 0.3375 | DEFER | Tor index enumerator; legally sensitive — sandboxed evaluation only |
| 117 | torbot-tor-crawler-osint | pass | dup-of:onionsearch-tor-index-scanner (116) | — | — | — | — | — | DUP | Tor crawler; overlaps 116 on capability-need (dark-web AML feed) |
| 118 | reputell-onion-reputation-signal | pass | keep | 0.70 | 0.35 | 0.55 | 0.35 | 0.355 | DEFER | Tor reputation signal; adjacent but distinct capability, sandboxed eval only |
| 119 | paynetics-bin-sponsor-emi | pass | **keep** (card-issuing 3-overlap) | 0.55 | 0.70 | 0.65 | 0.75 | 0.5625 | DEFER | Paynetics EEA/UK BIN sponsor + issuing; best-fit of the three; borderline ADOPT |
| 120 | transact-pay-em-processing | pass | dup-of:paynetics-bin-sponsor-emi (119) | — | — | — | — | — | DUP | UK EMI card processor; same capability-need |
| 121 | tribe-payments-emi-processor | pass | dup-of:paynetics-bin-sponsor-emi (119) | — | — | — | — | — | DUP | UK card issuing / acquiring; same capability-need |
| 122 | fireblocks-mpc-custody-paybis-scope | pass | keep | 0.60 | 0.15 | 0.60 | 0.15 | 0.275 | **REJECT** | Banxe crypto custody delegated to PAYBIS (ADR-138); out-of-scope |
| 123 | jenesto-core-banking-alt | pass | keep | 0.65 | 0.15 | 0.70 | 0.15 | 0.24 | **REJECT** | alt core banking; ADR-013 already selects Midaz PRIMARY / Fineract FALLBACK |
| 124 | sdk-finance-core-banking-alt | pass | keep | 0.65 | 0.15 | 0.70 | 0.15 | 0.24 | **REJECT** | alt core banking; ADR-013 already selects Midaz / Fineract |
| 125 | tremor-react-dashboard-components | pass | keep | 0.30 | 0.40 | 0.30 | 0.55 | 0.5725 | DEFER | Tremor React charts / KPI blocks; fit for internal ops / MLRO dashboards |
| 126 | bmad-agentic-dev-method | pass | keep | 0.35 | 0.30 | 0.35 | 0.40 | 0.49 | DEFER | BMAD-method agent-orchestrated dev workflow; factory-plane complement |
| 127 | dutymark-consumer-duty-tracker | pass | keep | 0.45 | 0.65 | 0.45 | 0.55 | 0.585 | DEFER | Consumer Duty outcome-tracker; complements ADR-054 + S9-06 line |
| 128 | omp-fca-obligations-mapping-tool | pass | keep | 0.45 | 0.65 | 0.45 | 0.60 | 0.5925 | DEFER | FCA obligations / rulebook mapping; complements COMPLIANCE-MATRIX 200+ req |
| 129 | lending-2027-consumer-credit-roadmap | **credit-DEFER** | — | — | — | — | — | — | **DEFER-to-licence** | consumer credit OOS UK EMI — CCA authorisation required, `B-EMI-CREDIT-GATE-001` |
| 130 | sme-alternative-credit-scoring-2027 | **credit-DEFER** | — | — | — | — | — | — | **DEFER-to-licence** | SME lending OOS UK EMI — distinct authorisation, `B-EMI-CREDIT-GATE-001` |

## Central review band (DEFER / borderline — manual finalization required)

The **44 DEFER items** all fall in the `0.30 ≤ S < 0.60` band and require Central + operator
finalization. Grouped by capability-family for review efficiency (not for automated grouping —
each item is finalized on its own merit):

- **Agent frameworks / orchestration (11):** 43 deerflow-banking-orchestrator,
  44 agenticseek-privacy-first-agent, 45 suna-self-hosted-manus-clone,
  58 strands-sdk-aws-agent-framework, 69 memory-first-agent-architecture,
  73 agno-multimodal-agent-framework, 74 smolagents-hf-micro-agent,
  75 goose-block-dev-loop-agent, 76 mastra-typescript-agent-framework,
  77 langchain-js-agent-sdk, 79 openhands-swe-general-agent, 91 dify-llm-app-orchestration,
  126 bmad-agentic-dev-method.
- **Fraud detection (2):** 47 transactiongpt-payments-llm, 51 asa-gnn-adversarial-safe,
  72 temporal-knowledge-distillation-fraud, 84 agentic-fraud-detection-pattern.
- **AML / cross-bank privacy / DP LLM (2):** 52 fate-federated-learning-webank,
  54 vaultgemma-dp-private-llm.
- **KYC / identity (2):** 82 openkyc-agentic-verification, 83 verifiable-agent-kit-zk-proof.
- **NLP / RAG / eval (5):** 61 finnlp-domain-nlp-toolkit, 89 llamaindex-rag-orchestration,
  107 deepeval-llm-eval-framework, 108 ragas-rag-evaluation, 109 mlflow-ml-lifecycle-tracking.
- **Web / browser automation (4):** 98 browser-use-python-web-agent, 100 skyvern-vision-web-automation,
  101 playwright-microsoft-browser-automation, 103 open-webui-selfhosted-chat-ui.
- **OSINT / adverse-media / Tor (4):** 114 spiderfoot-osint-adverse-media,
  115 gdelt-global-events-knowledge-graph, 116 onionsearch-tor-index-scanner (sandboxed),
  118 reputell-onion-reputation-signal (sandboxed).
- **Ledger / blockchain (2):** 57 fisco-bcos-permissioned-ledger, 88 hyperledger-fabric-permissioned-ledger.
- **Payments / MCP / card issuing (3):** 96 bank-mcp-banking-server-family,
  97 stripe-ai-sdk-payments-mcp, 119 paynetics-bin-sponsor-emi (**borderline: 0.5625, close to ADOPT**).
- **CI / dev tooling (1):** 67 github-agentic-workflows-ci.
- **Compliance / regulator surface (3):** 125 tremor-react-dashboard-components,
  127 dutymark-consumer-duty-tracker, 128 omp-fca-obligations-mapping-tool.

**Special call-outs for Central review:**

- **119 paynetics-bin-sponsor-emi** at S = 0.5625 is the closest DEFER to ADOPT; the 3-overlap
  dedup (120 transact-pay, 121 tribe) means finalization of 119 also resolves the card-issuing
  BIN-sponsor family — worth prioritising.
- **116 onionsearch-tor-index-scanner** and **118 reputell-onion-reputation-signal** carry a
  legal-sensitivity HGC (0.75 / 0.70); if pursued, they must be **sandboxed-eval-only** with
  a distinct governance wrapper — do not fold into general adverse-media flow without a
  bespoke ADR.
- **52 fate-federated-learning-webank** carries a WeBank-origin HGC (0.65) even though not
  Stage-1 sanctions-rejected; Central should weigh the FL cross-bank AML consortium roadmap
  against alt substrates before adoption.
- **83 verifiable-agent-kit-zk-proof** at S = 0.565 with FCR = 0.75 is the strongest
  privacy-preserving KYC candidate; heavy AC (0.65) is the drag. Central may promote if a
  ZK-proof KYC pilot is on the roadmap.

## ADOPT items (proposed — each becomes its own sprint / IL)

Each ADOPT entry below requires a **dedicated sprint / IL** (with its own Duplication Audit per
ADR-102 and Server-Only Refactoring gate per ADR-103 where applicable). This audit does **not**
adopt them itself.

1. **46 nuformer-tx-embedding-model** (S = 0.625) — fraud engine (tx embedding).
2. **49 hgnn-heterogeneous-gnn-fraud** (S = 0.60) — fraud engine (heterogeneous GNN).
3. **56 assistant-ui-agent-frontend** (S = 0.6125) — GAP-080 floor-1 intent-first UI.
4. **64 owasp-llm-top10-supply-chain** (S = 0.7875, **FCR = 0.85 → ESCALATE-IMMEDIATE**) —
   integrate into `ai-cost-policy` + OSS supply-chain review.
5. **65 nemo-guardrails-runtime-safety** (S = 0.685, **FCR = 0.80 → ESCALATE-IMMEDIATE**) —
   runtime guardrails complement to prompt canon.
6. **66 lime-shap-hitl-explainability** (S = 0.6275) — ADR-046 decision-lineage XAI fields.
7. **68 langfuse-llm-observability** (S = 0.6575) — LLM prompt/trace/cost observability across
   LiteLLM :4000 fleet.
8. **104 guardrails-ai-validators** (S = 0.695, **FCR = 0.80 → ESCALATE-IMMEDIATE**) —
   LLM-input validators; NeMo-Guardrails complement.
9. **111 lightgbm-fraud-credit-gbm** (S = 0.695) — GBM baseline for **fraud** (EMI-scope);
   credit-use gated behind `B-EMI-CREDIT-GATE-001`.

**ESCALATE-IMMEDIATE (3):** 64, 65, 104 — the three LLM-safety-perimeter items. FCR ≥ 0.80
lexicographic override applies; Central + operator should sequence adoption ahead of the
score-only ADOPT items.

## REJECT-hard (Stage-1)

- **48 wechatpay-gpt-payments-llm** — PRC state-affiliated (Tencent) payments LLM; non-adoptable
  under UK/EEA regulator posture. Track as reference-only.
- **59 sofastack-financial-cloud-antgroup** — Ant Group PRC-origin full fin-cloud; not
  EU/UK-adoptable. Track as reference-only.

## DEFER-to-licence (Stage-1, `B-EMI-CREDIT-GATE-001`)

All 8 items below are **outside TOMPAY-EMI licence scope** (credit / lending / investment /
trading agents) and await a licence-scope extension (FCA CCA authorisation for consumer credit,
distinct authorisation for SME lending / investment / trading). They are **not adopted, not
rejected** — parked behind the licence gate.

- **55 finrl-deepseek-rl-treasury** — RL treasury / FX policy.
- **60 finrobot-fintech-multi-agent** — trading / treasury multi-agent adjacencies.
- **62 tradingagents-llm-multi-agent** — explicit LLM trading system.
- **63 qlib-quant-research-platform** — Microsoft Qlib quant.
- **81 fingpt-ai4finance-financial-llm** — AI4Finance financial LLM (trading family).
- **113 credit-scoring-oss-pipeline** — OSS credit-scoring pipeline.
- **129 lending-2027-consumer-credit-roadmap** — consumer credit roadmap.
- **130 sme-alternative-credit-scoring-2027** — SME alt credit-scoring.

## Score-based REJECT (Stage-3, S < 0.30)

17 items with score below the REJECT threshold; low FCR / CGR combined with high HGC / AC.
Listed for completeness — Central may still reclassify if operational context changes.

71 quantum-gnn-fraud-research (0.27); 78 openmanus-rl-finetune-variant (0.26);
80 cline-vscode-coding-agent (0.29); 85 mckinsey-agentic-reference-framework (0.26);
86 cyclos-cooperative-banking-core (0.24); 87 ledgersmb-oss-accounting-core (0.25);
90 weaviate-vector-db-alt (0.29); 92 flowise-visual-llm-flow-builder (0.27);
94 prefect-python-workflow-orchestrator (0.28); 95 kestra-declarative-workflow (0.28);
99 stagehand-browserbase-agentic-web (0.26); 102 lm-studio-desktop-llm-manager (0.27);
106 langsmith-observability (0.27); 110 styletts2-neural-tts (0.27);
122 fireblocks-mpc-custody-paybis-scope (0.275); 123 jenesto-core-banking-alt (0.24);
124 sdk-finance-core-banking-alt (0.24).

## Invariants, boundaries, and Central-finalization pathway

- **NOVELTY-COLLECTION-REGISTER.md unchanged.** No row edits, no verdict-status mutation in the
  register (append-only per its own instructions and I-24). Finalization is recorded here and
  in Central's follow-on artefacts — the register itself only changes via **new appended
  rows**, if at all.
- **I-27 preserved.** No autonomous production-state mutation. This audit is advisory-only
  until Central + operator ratify.
- **EMI scope preserved.** Credit / lending / investment / trading items are **DEFER-to-licence**,
  not adopted — the TOMPAY-EMI scope boundary is respected.
- **Numbers = governed-config proposal.** HGC / FCR / AC / CGR values, the weights
  `(0.35, 0.15, 0.30, 0.20)`, the thresholds `(0.60 / 0.30)`, and the FCR ≥ 0.80 override are
  all **proposals**. Live activation requires a human-gated PR against
  `governance/novelty-pipeline-config.yaml` (per CLAUDE.md §10 Config-over-Hardcoding).
- **ADR-102 (Duplication Audit).** Each ADOPT that survives finalization lands as its own
  sprint / IL with a fresh repo-wide Duplication Audit — not folded into this audit.
- **Central-finalization pathway.**
  1. Central + operator review this file, validate the 9 ADOPT / 3 ESCALATE-IMMEDIATE / 44 DEFER
     / 19 REJECT / 8 credit-DEFER / 8 DUP counts, and record final verdicts.
  2. Each surviving ADOPT gets its own IL sprint (with own DA and, if applicable, ADR).
  3. Follow-on activation of the numeric proposals (weights, thresholds) via a human-gated
     PR against `governance/novelty-pipeline-config.yaml`.
  4. If any Stage-1 hard-gate or dedup decision needs revisiting, that surfaces as a
     `governance/NOVELTY-COVERAGE-LOG.md` follow-on entry — not a mutation of this file.

## Cross-references

- `governance/NOVELTY-COLLECTION-REGISTER.md` — the SSOT register of 88 NEW findings (rows 43–130
  audited here; **not mutated**).
- `docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md` — Q4 ratified two-stage triage
  (**method canon**, referenced not restated per ADR-102).
- `governance/DIRECTIVE-BESTDEC-RATIFY-001.md` — Q1–Q5 APPROVED by operator + Central.
- `governance/novelty-pipeline-config.yaml` — activation pathway for numeric proposals
  (governed-config).
- `.claude/rules/agents.md` (HITL confidence tiers) — same > 90 / 70–90 / < 70 thresholding
  spirit as ADOPT / DEFER / REJECT.
- ADR-102 (no-restate / pointer-first duplication canon) — this file adheres.
- ADR-103 (server-only refactoring) — each downstream ADOPT sprint must gate through this.
- ADR-162 / ADR-163 / ADR-164 — Best-Decision canon and Sync-Canon.
- Handoff anchor: `B-EMI-CREDIT-GATE-001` — the licence-scope holding pen for credit /
  lending / investment / trading DEFERs.
