# SP18 — BANXE OSS Solutions intake (2nd Terminal-B intake)

**Date (UTC):** 2026-07-06T00:15:17Z
**Corpus SHA:** 891cefd (origin/main)
**Source doc:** "Open Source Free AI Agent Solutions for Next-Generation Banking BANXE AI Bank" (~120 OSS solutions)
**Passes:** 3 (multi-pass read; sections 1–15 covered).
**Prior intake dedup base:** PR #1051 (30 NEW EMI-stack findings) + corpus (`governance/`, `docs/adr/`, `docs/agent-engine-dossier/`, `docs/canon/`, `CLAUDE.md`, `.claude/rules/`).
**Rule:** dedup = duplicate ONLY if genuinely covered (ADR / operational service / status DONE / already in register). Simple mention does NOT count as covered. Labels: `NEW`, `DUP-1051`, `DUP-corpus`.

---

## Coverage checklist (15 sections)

| # | Section | Covered |
|---|---------|---------|
| 1 | Agent frameworks | ✅ |
| 2 | Manus-like autonomous agents | ✅ |
| 3 | Financial-domain AI | ✅ |
| 4 | KYC / AML agentic | ✅ |
| 5 | Core banking OSS | ✅ |
| 6 | RAG / vector / memory | ✅ |
| 7 | Workflow orchestration | ✅ |
| 8 | MCP (Model Context Protocol) stack | ✅ |
| 9 | Web / browser automation | ✅ |
| 10 | LLM privacy-first / local-serving | ✅ |
| 11 | Guardrails / LLM safety | ✅ |
| 12 | LLM observability / evaluation | ✅ |
| 13 | Speech (ASR / TTS / realtime) | ✅ |
| 14 | Streaming / data pipeline | ✅ |
| 15 | Fraud / credit-scoring ML | ✅ |

---

## Per-candidate table (verdicts by section)

Legend — `NEW`: appended to register. `DUP-1051`: covered by PR #1051 finding (name in parentheses). `DUP-corpus`: covered by existing ADR / service / canon (anchor in parentheses).

### §1 Agent frameworks
| Candidate | Verdict | Evidence |
|---|---|---|
| LangGraph | DUP-corpus | SRC-01 §BANXE-STATUS = DEPLOYED (S7-06/C-27); SRC-04 §1 |
| CrewAI | DUP-corpus | SRC-04 §1 (4-Partner Swarm role-based fit) |
| AutoGen | DUP-corpus | SRC-01 §BANXE-STATUS = DEPLOYED (S7-08/C-29) |
| Strands | DUP-1051 | strands-sdk-aws-agent-framework |
| Agno | NEW | Not in SRC-01 landscape (10 frameworks); Pythonic multi-modal agent framework |
| CAMEL | DUP-corpus | SRC-01 §Landscape "OWL/CAMEL" (GAIA SOTA) |
| MetaGPT | DUP-corpus | SRC-04 §1 (code-generation factory) |
| DeerFlow | DUP-1051 | deerflow-banking-orchestrator |
| Smolagents | NEW | Not in SRC-01/04; Hugging Face micro-agent library |
| Goose | NEW | Not in SRC-01/04; Block/Square dev-loop agent |
| Mastra | NEW | Not in SRC-01/04; TypeScript-first agent framework |
| LangChain.js | NEW | Not in SRC-01/04; JS/TS agent SDK (frontend-side agent surface) |

### §2 Manus-like autonomous agents
| Candidate | Verdict | Evidence |
|---|---|---|
| OpenManus | DUP-corpus | SRC-01 §Landscape + OSS Descriptors |
| OpenManus-RL | NEW | RL fine-tuned variant not in SRC-01 |
| AgenticSeek | DUP-1051 | agenticseek-privacy-first-agent |
| Suna | DUP-1051 | suna-self-hosted-manus-clone |
| OpenHands | NEW | Not in corpus; general-purpose SWE agent (ex-OpenDevin) |
| Cline | NEW | Not in corpus; IDE-native coding agent |
| AutoGPT | DUP-corpus | SRC-01 §BANXE-STATUS (persistent memory pattern reference) |

### §3 Financial-domain AI
| Candidate | Verdict | Evidence |
|---|---|---|
| FinRobot | DUP-1051 | finrobot-fintech-multi-agent |
| FinGPT | NEW | AI4Finance FinGPT LLM — distinct from FinNLP/TradingAgents/Qlib in #1051; corpus only cites "FinGPT-style" reference |
| AI4Finance | DUP-1051 | Umbrella covered via finrobot/finnlp/tradingagents/qlib entries |

### §4 KYC / AML agentic
| Candidate | Verdict | Evidence |
|---|---|---|
| OpenKYC | NEW | Not in corpus/#1051 |
| Verifiable-Agent-Kit (ZK-proof) | NEW | Not in corpus; ZK-proof identity verification framework |
| agentic-fraud-detection | NEW | Not in corpus; reference agentic fraud-detection pattern |
| McKinsey-agentic | NEW | Not in corpus; industry reference framework |

### §5 Core banking OSS
| Candidate | Verdict | Evidence |
|---|---|---|
| Formance | DUP-corpus | banxe-emi-stack (services; MASTER dossier) |
| Blnk | DUP-corpus | MASTER dossier: Reconciliation Daily OPERATIONAL |
| Cyclos | NEW | Not in corpus; cooperative-banking OSS core |
| LedgerSMB | NEW | Not in corpus; OSS double-entry accounting stack |
| Hyperledger-Fabric | NEW | Not in corpus (FISCO-BCOS is a DUP-1051 sibling but distinct governance origin) |

### §6 RAG / vector / memory
| Candidate | Verdict | Evidence |
|---|---|---|
| LlamaIndex | NEW | Not in SRC-01/04; RAG-orchestration framework (adjacent to Haystack) |
| Weaviate | NEW | Not in corpus; vector DB (ChromaDB currently in use; Qdrant PLANNED — Weaviate is a third alternative) |
| Qdrant | DUP-corpus | SRC-01 §BANXE-STATUS = PLANNED |
| Mem0 | DUP-corpus + DUP-1051 | SRC-01 §BANXE-STATUS = EVAL; memory-first-agent-architecture umbrella |
| Zep | DUP-1051 | memory-first-agent-architecture umbrella |

### §7 Workflow orchestration
| Candidate | Verdict | Evidence |
|---|---|---|
| n8n | DUP-corpus | CLAUDE.md P0 (safeguarding shortfall alert) |
| Dify | NEW | Not in corpus; LLM-app orchestration platform |
| Flowise | NEW | Not in corpus; visual LangChain / LLM flow builder |
| Airflow | NEW | Not in corpus; Apache workflow orchestrator |
| Temporal | DUP-corpus | SRC-04 §4.1 combo architecture (infra scope) |
| Prefect | NEW | Not in corpus; modern Python workflow |
| Kestra | NEW | Not in corpus; declarative workflow orchestrator |

### §8 MCP stack
| Candidate | Verdict | Evidence |
|---|---|---|
| MCP-protocol | DUP-corpus | banxe_mcp/server.py (34 tools) + compliance_kb (6 tools) OPERATIONAL |
| Bank-MCP | NEW | Not in corpus; banking-specific MCP server family |
| Open-Banking-Gateway (Adorsys) | DUP-corpus | CLAUDE.md IL-010 + MASTER dossier (banxe-emi-stack recon OPERATIONAL) |
| Stripe-AI-SDK | NEW | Not in corpus; Stripe MCP/AI SDK for payments agents |

### §9 Web / browser automation
| Candidate | Verdict | Evidence |
|---|---|---|
| Browser-Use | NEW | Not in corpus; Python browser automation for LLM agents |
| Stagehand | NEW | Not in corpus; Browserbase agentic web framework |
| Skyvern | NEW | Not in corpus; vision-based web automation |
| Playwright | NEW | Not in corpus; Microsoft browser automation lib (agent + test surface) |

### §10 LLM privacy-first / local serving
| Candidate | Verdict | Evidence |
|---|---|---|
| Ollama | DUP-corpus | MASTER dossier: :11434 OPERATIONAL evo1/evo2 |
| LM-Studio | NEW | Not in corpus; desktop LLM manager (Ollama alternative) |
| llama.cpp | DUP-corpus | ADR-041 GLM-Air llama-server evo1:8081 / evo2:8082 |
| Open-WebUI | NEW | Not in corpus; self-hosted chat UI over Ollama |

### §11 Guardrails / LLM safety
| Candidate | Verdict | Evidence |
|---|---|---|
| NeMo-Guardrails | DUP-1051 | nemo-guardrails-runtime-safety |
| Guardrails-AI | NEW | Not in corpus (only concept "guardrails" appears); OSS validators / structured outputs |
| OWASP-LLM | DUP-1051 | owasp-llm-top10-supply-chain |

### §12 LLM observability / evaluation
| Candidate | Verdict | Evidence |
|---|---|---|
| Langfuse | DUP-1051 | langfuse-llm-observability |
| Arize-Phoenix | NEW | Not in corpus; OSS LLM tracing / evals |
| LangSmith | NEW | Not in corpus; LangChain observability |
| DeepEval | NEW | Not in corpus; Confident-AI OSS LLM eval framework |
| Ragas | NEW | Not in corpus; RAG-specific evaluation library |
| MLflow | NEW | Not in corpus; Databricks OSS ML/LLM tracking |
| Promptfoo | DUP-corpus | ADR-141 uses `promptfoo-eval` in self-healing loop |

### §13 Speech (ASR / TTS / realtime)
| Candidate | Verdict | Evidence |
|---|---|---|
| Whisper | DUP-corpus | ADR-112 Faster-Whisper ASR |
| Kokoro | DUP-corpus | ADR-112 TTS XTTS/Kokoro |
| StyleTTS2 | NEW | Not in corpus (ADR-112 lists XTTS/Kokoro only) |
| LiveKit | DUP-corpus | ADR-112 realtime + SIP telephony |

### §14 Streaming / data pipeline
| Candidate | Verdict | Evidence |
|---|---|---|
| Kafka | DUP-corpus | `.claude/rules/infrastructure.md` Event streaming (FA-15) + agents.md P1 |
| dbt | DUP-corpus | CLAUDE.md P0 (production run against ClickHouse) |

### §15 Fraud / credit-scoring ML
| Candidate | Verdict | Evidence |
|---|---|---|
| LightGBM | NEW | Not in corpus; Microsoft gradient boosting library for fraud/credit |
| XGBoost | NEW | Not in corpus; established gradient boosting library |
| credit-scoring | NEW | Not in corpus; OSS credit-scoring pipeline reference |

---

## Summary counters

- Candidates enumerated across 15 sections: 74
- `NEW` (appended to `NOVELTY-COLLECTION-REGISTER.md`): 41
- `DUP-1051` (covered by 30 findings of PR #1051): 12
- `DUP-corpus` (covered by ADR / operational service / canon / rules): 22 (`Mem0` counted once in DUP-corpus but also flagged DUP-1051)

## Outcome

**Outcome-1 findings** → 41 rows appended to `governance/NOVELTY-COLLECTION-REGISTER.md` (append-only, status=NEW).

Merge — HITL operator (canon `CLAUDE.md §71`). Draft PR only; no auto-merge armed.

## Anchors

- ADR-159 §Terminal-B-Operating-Algorithm (multi-pass + Outcome-1 / Outcome-2)
- `docs/canon/TERMINAL-B-OPERATING-CANON.md` (full-coverage mandate)
- `governance/NOVELTY-COLLECTION-REGISTER.md` (append target)
- PR #1051 (base of dedup vs prior 30 findings)
- ADR-119, ADR-133, ADR-143 (ledger discipline: shard + IL-SEQUENCE.json + INSTRUCTION-LEDGER.md together)
