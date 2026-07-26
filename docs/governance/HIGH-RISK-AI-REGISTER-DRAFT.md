# HIGH-RISK AI REGISTER — DRAFT

**Status: DRAFT / NOT FOR MERGE / NO LEGAL STATUS.** Internal-classification заполняется/ратифицируется CRO+CTO; **legal-classification — исключительно counsel**; этот файл не меняет светофоры `OPEN-REGULATORY-QUESTIONS-REGISTER` и не является правовым документом. Источники: MASTER TABLE, Sprint 2 High-Risk Map, ai-oversight notes, room-канон.

| Agent | Room | Owner | Internal-classification | Legal-classification | Oversight-artefact | Register entries | Notes / open questions |
|---|---|---|---|---|---|---|---|
| FraudScoringAgent | F3/risk-room | Fraud Analyst→CRO | candidate YES (канон: RED zone) — CRO/CTO ратифицируют | [counsel] | `ai-oversight/FraudScoringAgent-notes.md` | #8; H-009/012/014 | Recital 58 exclusion? — counsel |
| CreditScoringAgent + lending_agent | F3/risk-room | CRO | candidate YES — CRO/CTO | [counsel] | `ai-oversight/CreditScoringAgent-notes.md` | #8 | Annex III creditworthiness — counsel; reject всегда human-reviewed (код) |
| SanctionsScreeningAgent (+Watchman) | F3/aml-room | MLRO | candidate YES — CRO/CTO | [counsel] | `ai-oversight/SanctionsScreeningAgent-notes.md` | #8, #3-cross | auto-block H-003; reversal только MLRO+CEO |
| AML-Analyst-v1 / AMLPipelineAgent | F3/aml-room | MLRO/CO | candidate YES — CRO/CTO | [counsel] | notes: TO CREATE | #8 | SAR-цепочка H-001 non-delegable |
| tx-scoring swarm-6 (base/behavior/geo_risk/product_limits/profile_history/sanctions) | F3/aml-room | MLRO/CO | candidate YES — CRO/CTO | [counsel] | notes: TO CREATE | #8 | placement ratification pending (room-kit) |
| KYC-Specialist-v2 / kyb_agent | F2/identity-room | Compliance Officer | candidate YES — CRO/CTO | [counsel] | notes: TO CREATE | #5-adjacent, #8 | I-27 carve-out обязателен |
| ato_agent / tracer_agent | F3/risk-room | Fraud Analyst | candidate YES — CRO/CTO | [counsel] | notes: TO CREATE | #8 | fraud-класс, H-009 |
| crypto_agent | F2/payments-room | COO+MLRO | candidate YES — CRO/CTO | [counsel] | notes: TO CREATE (после S1-memo) | #3 (RED), #8 | CASP-периметр — counsel; dormant |
| card_agent | F2/payments-room | COO | UNKNOWN до Scope Note | [counsel] | notes: после `sprint-1-card-functional-scope-note.md` | #2 (RED), #8 | функциональный scope не зафиксирован |
| MLPipelineAgent / FeedbackLoopAnalyser | F4/ai-platform (canon) | CTO+CRO | candidate YES (I-27-чувствительные) | [counsel] | notes: TO CREATE | #8; H-012/014 | propose-only по коду |
| HRAgent | F1/hr-legal (canon) | HR lead→CEO | UNKNOWN | [counsel] | notes: TO CREATE | #8 | Annex III employment-uses? — counsel |
| consent_agent | F2/identity-room | DPO (vacant)/interim | OPEN QUESTION (register #5: legal NO — confirm) | [counsel] | notes: TO CREATE | #5, #8 | internal-стандарт решает CRO/CTO |
| midaz_agent | F2/ledger-room | CTO | NO high-risk label; strict oversight regardless (register #6) | [counsel] | `ict/`-класс + write-path proof (S-A6) | #6, #8 | infra-классификация |
| webhook_agent | F4/ai-platform (canon) | CTO | infra; inherited gates | [counsel] | `ict/webhook-agent-control-model.md` | #7, #8 | regulated-execution вопрос — counsel |

**Правила файла:** строки добавляются append-only; «candidate YES» ≠ ратифицировано; переходы классификаций — только актом CRO/CTO (internal) или counsel-меморандумом (legal) с evidence-ссылкой; везде, где internal шире legal, — «INTERNAL HIGHER STANDARD by policy, not statutory minimum».
