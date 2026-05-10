# ROADMAP.md
## Banxe AI Bank — Architecture Repository Roadmap
### banxe-architecture repo progress tracker

---

## Phase 1: Foundation (COMPLETED)
- [x] Repository structure created
- [x] Initial README.md
- [x] docs/ folder structure
- [x] diagrams/ folder
- [x] master-document/ folder
- [x] reviews/ folder

## Phase 2: Core Architecture Documents (COMPLETED)
- [x] docs/ORG-STRUCTURE.md — Organizational structure
- [x] docs/DEPARTMENT-MAP.md — 10 departments with AI agents
- [x] COMPLIANCE-FRAMEWORK.md — FCA compliance framework
- [x] BANXE-CLAUDE-PROMPT.md — Master Claude prompt
- [x] BANXE-HEADER-SYSTEM.md — Header system documentation
- [x] BANXE-SCREEN-MAP.md — Screen mapping
- [x] BANXE-UI-ARCHITECTURE.md — UI architecture
- [x] BANXE-UI-UX-DESIGN-SYSTEM.md — Design system
- [x] BANXE-UI-UX-SPEC.md — UI/UX specifications
- [x] BLOCKED-TASKS.md — Blocked tasks tracker
- [x] COLLAB.md — Collaboration guide

## Phase 3: Extended Documentation (COMPLETED)
- [x] CRYPTO-BLOCK.md — Crypto operations: Neuronext + TomPay (IL-070)
- [x] docs/JOB-DESCRIPTIONS.md — AI agents & human doubles, 32 roles (IL-080)
- [x] FEATURE-REGISTRY.md — 30 features with purpose, value & KPIs (IL-081)
- [x] docs/RELATIONSHIP-TREE.md — Org relationships, agent interactions, escalation (IL-082)
- [x] ROADMAP.md — Architecture repo phases & inventory (IL-083)

## Phase 3.5: Developer Documentation Pipeline (COMPLETED)
- [x] mkdocs.yml — MkDocs Material config with full nav (IL-084)
- [x] DEV-DOCUMENTATION-GUIDE.md — 4-layer auto-documentation guide (IL-085)
- [x] .github/workflows/docs.yml — GitHub Pages CI/CD deploy (IL-086)
- [x] CHANGELOG-POLICY.md — Conventional commits + SemVer (IL-087)
- [x] prompts/18-auto-documentation-pipeline.md — Legion prompt (IL-088)

- [ ] ## Phase 4: Code Implementation (IN PROGRESS)

### Implemented Services (banxe-emi-stack)
- [x] services/compliance_kb — Compliance Knowledge Service: RAG, ChromaDB, 88 tests (IL-CKS-01)
- [x] services/agent_routing — AI Agent routing and orchestration
- [x] services/recon — Reconciliation engine
- [x] services/reasoning_bank — AI reasoning storage
- [x] services/design_pipeline — Design-to-code pipeline
- [x] services/swarm — Multi-agent swarm orchestration
- [x] services/aml — Anti-Money Laundering service
- [x] services/kyc — Know Your Customer verification
- [x] services/payment — Payment processing (SEPA/SWIFT/FPS)
- [x] services/ledger — Financial ledger (double-entry)
- [x] services/fraud — Fraud detection
- [x] services/auth — Authentication
- [x] services/iam — Identity & Access Management
- [x] services/customer — Customer management
- [x] services/notifications — Multi-channel notifications
- [x] services/reporting — Regulatory reporting
- [x] services/case_management — Case management
- [x] services/complaints — Complaint handling
- [x] services/consumer_duty — FCA Consumer Duty
- [x] services/agreement — Agreement management
- [x] services/statements — Account statements
- [x] services/resolution — Dispute resolution
- [x] services/webhooks — Webhook management
- [x] services/events — Event bus
- [x] services/hitl — Human-in-the-loop escalation
- [x] services/config — Configuration management
- [x] services/providers — External provider integrations

### Implementation Prompts
- [x] prompts/03 through prompts/17 — Core feature prompts
- [x] prompts/18-auto-documentation-pipeline.md (IL-088)
- [ ] prompts/19-customer-support-block.md — Customer Support AI
- [ ] prompts/20-marketing-block.md — Marketing & CRO AI
- [ ] prompts/21-crypto-onboarding-flow.md — Crypto wallet onboarding
- [ ] prompts/22-crypto-compliance-flow.md — Crypto AML/Travel Rule
- [ ] prompts/23-agent-communication-bus.md — Inter-agent messaging

### Architecture Docs (ARCHITECTURE-*.md in banxe-emi-stack/docs/)
- [x] ARCHITECTURE-AGENT-ROUTING.md
- [x] ARCHITECTURE-RECON.md
- [x] ARCHITECTURE-DESIGN-TO-CODE.md
- [x] ARCHITECTURE-AI-DESIGN-SYSTEM.md
- [x] ARCHITECTURE-16-AI-DESIGN-SYSTEM.md
- [x] ARCHITECTURE-17-COMPLIANCE-AI-COPILOT.md
- [ ] ARCHITECTURE-18-COMPLIANCE-KB.md (next)

## Phase 4.5 — Compliance & IAM Cutover (COMPLETED 2026-05-04)

- [x] FCA CASS 15 Safeguarding Engine — IL-001..011 (banxe-emi-stack Phase 1)
- [x] AI Plane (LiteLLM v2 + 4 aliases) — ADR-016, INVARIANTS I-32/I-33
- [x] Keycloak IAM cutover via STRATEGY-B (Legion host) — ADR-017, tag `cass15-iam-cutover-2026-05-07`, banxe-emi-stack PR #50
- [x] Production Postgres backend validation (staging :8181) — G-IAM-09 closed, banxe-emi-stack PR #55
- [x] Phase 57 IAM cutover ROADMAP entry — banxe-emi-stack PR #53

## Phase 4.6 — Guardian conversation-level enforcement (COMPLETED 2026-05-05)

- [x] Guardian factory + project deployed — ADR-019 + ADR-022, evo1 :8195 / :8196
- [x] Bash shim (Strategy-S1 native PreToolUse hook) — ADR-024, banxe-emi-stack PR #48
- [x] claude.bash scope rules CB1..CB4 — ADR-026, MetaClaw d122a61
- [x] ENFORCE mode rolled out for banxe-emi-stack + banxe-architecture — G-GUARD-02 DONE
- [x] Cron pull-deploy MetaClaw guardian/ → evo1 — G-DEPLOY-01 DONE
- [x] Agent Interaction Canon (4-layer canon: auto-run / stop-barrier / best-decision / session-canon) — ADR-025
- [x] §3/§4/§15 expansion: whitelist taxonomy, BDP, Claude-Code-First — IL-CANON-04, IL-CANON-05

## Phase 4.7 — V-violations canon formalisation (COMPLETED 2026-05-05)

13/13 violations from HANDOFF-2026-05-04 addressed in canonical GAP-REGISTER.md:

| V-XX | Severity | Resolution |
|------|----------|------------|
| V-01 | CRITICAL | Guardian-shim enforce — G-GUARD-01..04 |
| V-02 | HIGH | KC realm session-timeout hardening — **DONE 2026-05-06** (G-IAM-10, IL-PHASE-G-01) |
| V-03 | HIGH | G-KYC-01/02 — KYC re-verification triggers |
| V-04 | HIGH | G-IAM-06 verified DONE |
| V-05 | HIGH | G-IAM-08 reconciled |
| V-06 | HIGH | G-CASS-01/02 — audit-trail durability |
| V-07 | MEDIUM | G-OPS-01/02 — Postgres backup rotation |
| V-08 | MEDIUM | G-CI-01/02 — end-to-end smoke gate |
| V-09 | MEDIUM | G-SEC-01/02 — secrets rotation (Vault placeholder) |
| V-10 | MEDIUM | G-OBS-01/02 — KC alert routing reframed |
| V-11 | MEDIUM | G-KYC-03/04 — SumSub webhook retry/DLQ |
| V-12 | LOW | G-API-01/02 — auth rate limits |
| V-13 | LOW | docs/ops STRATEGY-B archive |

Pending implementation phase: ADR-027..034 + code/tests + deploy. See GAP-REGISTER.md.

## Pending operator gates (live-ops)

- ~~**Phase F**: live switch dev-file → Postgres backend on production KC.~~ **APPLIED 2026-05-06** — G-IAM-09 DONE, see IL-PHASE-F-01 + `docs/ops/phase-f-execution-2026-05-06.md`. Downtime: 2 min 44 sec. Smoke: 4/4 PASS.
- ~~**Phase G**: live-apply session-timeout hardening per V-02.~~ **APPLIED 2026-05-06** — V-02 DONE, see G-IAM-10 + IL-PHASE-G-01 + `docs/ops/phase-g-execution-2026-05-06.md`.

## Phase 5: Advanced Features (PLANNED)
- [ ] Multi-agent communication protocol
- [ ] Real-time dashboard (ClickHouse + Superset)
- [ ] Telegram Bot operational interface
- [ ] FCA Section 4 automated reporting
- [ ] Management Information (MI) report generator

## Phase 6: Crypto Block Implementation (PLANNED)
- [ ] Neuronext API integration layer
- [ ] Crypto wallet management system
- [ ] Fiat-to-crypto bridge (buy/sell)
- [ ] Travel Rule compliance engine
- [ ] Crypto-specific AML monitoring
- [ ] Cross-entity reconciliation (TomPay ↔ Neuronext)

## Phase 7: Testing & QA (PLANNED)
- [ ] End-to-end onboarding flow tests
- [ ] Payment processing regression suite
- [ ] Compliance scenario testing
- [ ] AI agent accuracy benchmarks
- [ ] Performance load testing

## Phase 8: Production Readiness (PLANNED)
- [ ] Infrastructure hardening
- [ ] Disaster recovery procedures
- [ ] Monitoring & alerting setup
- [ ] Documentation audit
- [ ] Go-live checklist

---

## Document Inventory (banxe-architecture/docs/)

| Document | Status | Commit |
|----------|--------|--------|
| docs/ORG-STRUCTURE.md | Complete | Initial |
| docs/DEPARTMENT-MAP.md | Complete | Updated 10 depts |
| COMPLIANCE-FRAMEWORK.md | Complete | Initial |
| CRYPTO-BLOCK.md | Complete | IL-070 |
| docs/JOB-DESCRIPTIONS.md | Complete | IL-080 |
| FEATURE-REGISTRY.md | Complete | IL-081 |
| docs/RELATIONSHIP-TREE.md | Complete | IL-082 |
| DEV-DOCUMENTATION-GUIDE.md | Complete | IL-085 |
| CHANGELOG-POLICY.md | Complete | IL-087 |
| BANXE-CLAUDE-PROMPT.md | Complete | Initial |
| BANXE-HEADER-SYSTEM.md | Complete | Initial |
| BANXE-SCREEN-MAP.md | Complete | Initial |
| BANXE-UI-ARCHITECTURE.md | Complete | Initial |
| BANXE-UI-UX-DESIGN-SYSTEM.md | Complete | Initial |
| BANXE-UI-UX-SPEC.md | Complete | Initial |
| BLOCKED-TASKS.md | Active | Ongoing |
| COLLAB.md | Complete | Initial |

## Service Inventory (banxe-emi-stack/services/ — 27 services)

| Service | Domain | Last Updated |
|---------|--------|-------------|
| compliance_kb | Compliance RAG | IL-CKS-01 |
| agent_routing | AI Orchestration | 5h ago |
| recon | Finance | 8h ago |
| reasoning_bank | AI | 5h ago |
| design_pipeline | DevOps | 4h ago |
| swarm | AI Orchestration | 5h ago |
| aml | Compliance | 2d ago |
| kyc | Compliance | 3d ago |
| payment | Operations | 3d ago |
| ledger | Finance | 3d ago |
| fraud | Security | 3d ago |
| auth | Security | 3d ago |
| iam | Security | 3d ago |
| customer | Operations | 3d ago |
| notifications | Communications | 3d ago |
| reporting | Compliance | 3d ago |
| case_management | Operations | 3d ago |
| complaints | Customer Support | 3d ago |
| consumer_duty | Compliance | 3d ago |
| agreement | Legal | 3d ago |
| statements | Finance | 3d ago |
| resolution | Customer Support | 3d ago |
| webhooks | Infrastructure | 3d ago |
| events | Infrastructure | 3d ago |
| hitl | AI/Human | 3d ago |
| config | Infrastructure | 3d ago |
| providers | Integrations | 3d ago |

---

> Last Updated: 2026-05-06 | Maintained by: CarmiBanxe
> Cross-repo state: banxe-emi-stack: main HEAD post-merge, all V-violations canonized; MetaClaw: guardian deployed pull-mode, claude.bash rules active

---

## Snapshot 2026-05-06 — Progress Checkpoint

Состояние на 2026-05-06 10:00 CEST. ADR-027 (audit-trail durability) Accepted и закрыт.
ADR-028 (KYC re-verification triggers) в работе: Step 1 (PR #69) и Step 2 (PR #70) открыты.
Следующий шаг: ADR-028 Step 3 (cron/CI smoke), затем Step 4 (flip Accepted + G-KYC-01/02 close).
Базовый тег: `checkpoint-2026-05-06-adr027-accepted`. Новый тег после merge: `checkpoint-2026-05-06-progress-snapshot`.

→ Подробности: [docs/sessions/SNAPSHOT-2026-05-06-progress-checkpoint.md](docs/sessions/SNAPSHOT-2026-05-06-progress-checkpoint.md)


---

## Checkpoint registry

Реестр опорных точек прогресса EMI BANXE AI BANK. Каждая запись — аннотированный git-tag в `banxe-architecture` + ссылка на соответствующий handoff/snapshot. Реестр append-only: предыдущие записи не редактируются.

| Дата (CEST) | Тег | Коммит | Тип | Документ |
|---|---|---|---|---|
| 2026-05-06 | `checkpoint-2026-05-06-adr027-accepted` | 1fa9ddf | HANDOFF | docs/sessions/HANDOFF-2026-05-06-adr027-accepted.md |
| 2026-05-06 | `checkpoint-2026-05-06-progress-snapshot` | 24ad91a | SNAPSHOT | docs/sessions/SNAPSHOT-2026-05-06-progress-checkpoint.md |
| 2026-05-06 | `checkpoint-2026-05-06-sber-oss-emi-block` | будет проставлен оператором после merge PR | ROADMAP BLOCK | docs/sessions/SNAPSHOT-2026-05-06-sber-oss-emi-block.md |
| 2026-05-06 | `checkpoint-2026-05-06-claude-finance-agents-block` | _будет проставлен оператором после merge PR_ | ROADMAP BLOCK | docs/sessions/SNAPSHOT-2026-05-06-claude-finance-agents-block.md |
| 2026-05-06 | `checkpoint-2026-05-06-defi-stack-binance-replacement-block` | _будет проставлен оператором после merge PR_ | ROADMAP BLOCK | docs/sessions/SNAPSHOT-2026-05-06-defi-stack-binance-replacement-block.md |
| 2026-05-06 | `checkpoint-2026-05-06-dac8-tax-reporting-block` | _будет проставлен оператором после merge PR_ | ROADMAP BLOCK | docs/sessions/SNAPSHOT-2026-05-06-dac8-tax-reporting-block.md |
| 2026-05-06 | `checkpoint-2026-05-06-oss-sumsub-replacement-block` | _будет проставлен оператором после merge PR_ | ROADMAP BLOCK | docs/sessions/SNAPSHOT-2026-05-06-oss-sumsub-replacement-block.md |
| 2026-05-06 | `checkpoint-2026-05-06-owner-control-agent-block` | _будет проставлен оператором после merge PR_ | ROADMAP BLOCK | docs/sessions/SNAPSHOT-2026-05-06-owner-control-agent-block.md |
| 2026-05-07 | `checkpoint-2026-05-07-canon-extended` | ed66ab2 | CHECKPOINT (parallel session) | docs/sessions/ (canon-extended branch) |
| 2026-05-07 | `checkpoint-2026-05-07-r1-r2-r3-complete` | 6d56ff5 | CHECKPOINT (parallel session) | docs/sessions/ (R1-R2-R3 fixes roadmap) |
| 2026-05-07 | `checkpoint-2026-05-07-customer-privacy-right-v2-base` | 00822b5 | ROADMAP BLOCK | docs/privacy/customer-privacy-right-v2.md |
| 2026-05-07 | `checkpoint-2026-05-07-ghost-mode-spec` | 97fc7c6 | FEATURE SPEC | docs/privacy/ghost-mode-spec.md |
| 2026-05-08 | `checkpoint-2026-05-08-incident-monitor-state-transition` | d087169 | INCIDENT STATE TRANSITION | docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md |
| 2026-05-09 | `checkpoint-2026-05-09-canon-section-0-fixation` | 633bb6a | CANON BLOCK | docs/canon/factory-project-stack-2026-05.md (Sprint S1 — F0..F7 roadmap) |

Протокол наращивания (append-only):
1. Каждый новый блок прогресса = отдельный PR в `banxe-architecture`, отдельная ветка, один коммит.
2. Блок добавляется новым подразделом ниже (или новой строкой в реестр), без правки уже существующих разделов.
3. После merge — оператор ставит новый аннотированный тег `checkpoint-YYYY-MM-DD-<slug>` на коммит этого PR и пушит его в `origin`.
4. Базовая точка resume для будущих сессий — последний тег из реестра.


---

## Roadmap Block 2026-05-06 — Sber OSS for EMI BANXE

Инвентаризация и план интеграции Open Source-экосистемы Сбера (GigaChain + Sberbank AI Lab) в EMI BANXE AI BANK в EMI-периметре (без кредитования; AML/fraud/KYC/SAR/MiCA-фокус; GDPR-ограничение для GigaChat API).

Применения: AML transaction monitoring, fraud detection, KYC onboarding, customer support, SAR autogeneration, crypto/MiCA monitoring, drop-in OpenAI → GigaChat через gpt2giga.

Регуляторное правило: персональные данные EU/EEA-клиентов BANXE не отправляются в публичный GigaChat API.

Базовая опора: `checkpoint-2026-05-06-progress-snapshot`.

Тег после merge: `checkpoint-2026-05-06-sber-oss-emi-block`.

→ Подробности: [docs/sessions/SNAPSHOT-2026-05-06-sber-oss-emi-block.md](docs/sessions/SNAPSHOT-2026-05-06-sber-oss-emi-block.md)

---

## Roadmap Block 2026-05-06 — Anthropic Claude Finance Agents (EMI applicability)

Оценка готовых Anthropic Claude agent templates для финансовых команд (pitch book, valuation review, month-end close, credit memo, KYC, reconciliation, fund accounting) с точки зрения применимости в EMI BANXE AI BANK — строго в EMI-периметре.

**In-scope (текущий EMI):** KYC agent, Reconciliation agent, Month-end close (partial — только собственный P&L и FIN060).

**Out-of-scope (кредитование / инвестиционные услуги / M&A):** credit memo, pitch book, valuation review, fund accounting — резерв при расширении лицензии.

Регуляторное правило: все вызовы к Claude Finance Agents только через approved AI-plane (LiteLLM v2 / Bedrock-EU с DPA); прямая отправка EU/EEA PII в Anthropic API запрещена. Pending invariant: I-38.

Резерв ADR: ADR-041..044.

Базовая опора: `checkpoint-2026-05-06-sber-oss-emi-block`.

Тег после merge: `checkpoint-2026-05-06-claude-finance-agents-block`.

→ Подробности: [docs/sessions/SNAPSHOT-2026-05-06-claude-finance-agents-block.md](docs/sessions/SNAPSHOT-2026-05-06-claude-finance-agents-block.md)

---

## Roadmap Block 2026-05-06 — Composable DeFi Stack vs Binance Dealer Program (BANXE perimeter assessment)

Оценка Composable DeFi Stack (LI.FI / 0x / Rubic / dYdX v4 / Injective / GMX v2 / StakeKit / Hummingbot / Enso / OpenDAX / HollaEx) как структурной альтернативы программе Binance Dealer/white-label для EMI BANXE AI BANK — строго в EMI-периметре.

**In-scope (текущий EMI):** non-custodial swap UI (LI.FI / 0x / Rubic + AML pre-trade screening), EMT-stablecoins under MiCA Title III, Travel Rule execution (Sumsub / Notabene), internal Hummingbot analytics (liquidity intelligence, no autonomous execution), OpenDAX/HollaEx white-label (partial — UI shell only, custody remains external).

**Out-of-scope (CASP / инвестиционные услуги / кредитование):** dYdX v4 / Injective / GMX v2 (margin/leverage/perps — MiFID II/MiCA CASP required), StakeKit / yield protocols (guaranteed/staking yield — investment product), custodial DeFi, safeguarding pool funds in DeFi smart contracts.

Регуляторное правило: BANXE выступает исключительно как non-custodial routing UI; клиент подписывает транзакции собственным кошельком; BANXE проводит AML pre-trade screening существующим `services/aml` pipeline. Прямая отправка EU/EEA PII через DeFi-шлюзы без approved AI-plane запрещена. Pending invariant: I-39.

Резерв ADR: ADR-045..050.

Базовая опора: `checkpoint-2026-05-06-claude-finance-agents-block`.

Тег после merge: `checkpoint-2026-05-06-defi-stack-binance-replacement-block`.

→ Подробности: [docs/sessions/SNAPSHOT-2026-05-06-defi-stack-binance-replacement-block.md](docs/sessions/SNAPSHOT-2026-05-06-defi-stack-binance-replacement-block.md)

---

## Roadmap Block 2026-05-06 — DAC8 EMI Compliance (Tax Reporting + Customer Notification + 60-day Kill Switch)

Канонизация обязательств BANXE по Council Directive (EU) 2023/2226 (DAC8) с 1 января 2026: ежегодная XML CARF отчётность в национальный налоговый орган страны регистрации, GDPR-обязательное уведомление клиентов о передаче данных, 60-дневная процедура self-certification → блокировка reportable transactions (Annex VI, Section V(A)(2)).

**Ownership matrix:**
- RFI Owner: Tax Reporting & Regulatory Reporting Function (Compliance & Reporting, под MLRO / Head of Compliance) — владеет XML CARF выгрузкой и отправкой; артефакты: `services/reporting/*`, FIN060 pipeline, ADR-027.
- Data Ingestion Co-owner: Customer Operations (KYC/Onboarding/CS) — self-certification, GDPR-уведомление, 60-day reminders; артефакты: `services/kyc/*`, `services/customer_lifecycle/*`, `services/notifications/*`.
- Поддержка: Legal & Privacy (DPO) — GDPR Privacy Policy + lawful basis; MLRO/AML — AMLR Art. 33 пересечение; Engineering — Tax-Reporting Service + FSM (future ADR-045..049).

Pending invariants: I-40 (RFI ownership + customer notification), I-41 (60-day kill-switch mandatory). Резерв ADR: ADR-045..049.

Базовая опора: `checkpoint-2026-05-06-defi-stack-binance-replacement-block`.

Тег после merge: `checkpoint-2026-05-06-dac8-tax-reporting-block`.

→ Подробности: [docs/sessions/SNAPSHOT-2026-05-06-dac8-tax-reporting-block.md](docs/sessions/SNAPSHOT-2026-05-06-dac8-tax-reporting-block.md)

---

## Roadmap Block 2026-05-06 — Open-Source Sumsub Replacement Stack (KYC/KYB/AML/Travel-Rule)

Инвентаризация open-source-инструментов как замены / дополнения Sumsub по 10 функциональным слоям (KYC/KYB orchestration, OCR/document verification, biometrics/liveness/NFC, AML screening, transaction monitoring, fraud detection, KYB, identity/SCA/PSD2, bank account verification, Travel Rule VASP) с фильтром EMI BANXE и каноническим ownership.

**In-scope (YES):** Ballerine (MIT), EasyOCR/Tesseract/Doubango (Apache), DeepFace/NFCPassportReader (MIT), Yente/OpenSanctions/Moov Watchman (MIT/Apache), Marble (Apache), Ory Kratos/Hydra (Apache), KYB + public registries.

**PARTIAL/AGPL-flag:** Jube (AGPL-3.0, изолированный сервис + legal-review-required), FaceOnLive/Faceplugin (commercial SDK, DPA + Art. 9 DPIA).

**INTERNAL-ONLY:** kyc-analyst (adverse media, compliance officer tool).

**RESERVE:** TRP + Walt.id + opencred (Travel Rule / VC, CASP/MiCA perimeter, ADR-061).

Canonical ownership: KYC/AML Operations (MLRO) — process owner; Customer Operations — data ingestion; Engineering — деплой OSS-стека. Pending invariants: I-42 (EU residency self-hosted), I-43 (Jube AGPL isolation), I-44 (biometrics DPIA Art. 9). Резерв ADR: ADR-056..062.

Базовая опора: `checkpoint-2026-05-06-dac8-tax-reporting-block`.

Тег после merge: `checkpoint-2026-05-06-oss-sumsub-replacement-block`.

→ Подробности: [docs/sessions/SNAPSHOT-2026-05-06-oss-sumsub-replacement-block.md](docs/sessions/SNAPSHOT-2026-05-06-oss-sumsub-replacement-block.md)

## Roadmap Block 2026-05-06 — Owner Control Agent 1.0 (KPI/Compliance Pulse for BANXE.COM Holding)

Канонизация плана Owner Control Agent 1.0 — внешнего наблюдательного KPI/compliance pulse-агента для собственника BANXE.COM (холдинг) над TOMPAY LTD (FCA EMI) и NEURONEXT (CASP/VASP под MiCA). Агент не является каналом FCA-reporting и не замещает решения MLRO. Observer-only: нет write-доступа к клиентским системам.

**Источники данных (7 Google Sheets + Apps Script):** TompayDailyFiat (11 столбцов, A..K), SafeguardingRecon (14 столбцов, A..N), FCAReportingCalendar (7 столбцов, A..G), FraudAndAML (10 столбцов, A..J), ComplaintsSupport (10 столбцов, A..J), OpRiskIncidents (8 столбцов, A..H), NeuronextDailyCrypto (10 столбцов, A..J). Apps Script `collectDataForClaude()` — триггер 06:00–07:00 UTC, агрегирует последние 7 дней + MTD, записывает в лист ClaudeInput (ячейка A1).

**Non-PII контракт ClaudeInput:** только агрегированные KPI, счётчики, итоги, severity-флаги; запрещены имена/IBAN/адреса/паспорта/MRZ/биометрия/транзакционные PII/SAR-нарративы.

**Одобренный AI-plane:** Claude.ai с DPA или EU-managed Claude / Bedrock-EU. Личные аккаунты без DPA для продакшн-данных запрещены.

**KPI-пороги (11 KPI):** Safeguarding Shortfall — нулевая толерантность (красный > £0); Transaction Failure Rate — зелёный < 2%, жёлтый 2–5%, красный > 5%; Fraud Rate — зелёный < 0.1%, жёлтый 0.1–0.5%, красный > 0.5%; SAR Pipeline — жёлтый > 0 незакрытых > 48ч, красный > 0 просроченных > 5 дней; FCA Calendar — красный: просроченный дедлайн; Complaints Response Rate — зелёный ≥ 95%, жёлтый 85–95%, красный < 85%; Op Risk P1 Incidents — зелёный = 0 открытых, жёлтый 1–2, красный ≥ 3; Crypto PnL Variance — жёлтый > 5% от прогноза; VASP Travel Rule Compliance — зелёный = 100%; Liquidity Buffer — зелёный ≥ 110% target, красный < 100%; Regulatory Capital — зелёный ≥ 120% trigger.

**Ownership matrix:** Данные-owner — MLRO (SafeguardingRecon, FraudAndAML), CFO (TompayDailyFiat, NeuronextDailyCrypto), CCO (FCAReportingCalendar, ComplaintsSupport, OpRiskIncidents); Агент-owner — CEO/Собственник (потребитель), Engineering (деплой Apps Script + Claude Project).

Canonical ownership: CEO/Собственник — agent consumer; MLRO — compliance data owner; CFO — financial data owner; Engineering — Apps Script + Claude Project. Pending invariants: I-45 (non-PII контракт ClaudeInput), I-46 (одобренный AI-plane), I-47 (observer-only граница). Резерв ADR: ADR-063..069.

Базовая опора: `checkpoint-2026-05-06-oss-sumsub-replacement-block`.

Тег после merge: `checkpoint-2026-05-06-owner-control-agent-block`.

→ Подробности: [docs/sessions/SNAPSHOT-2026-05-06-owner-control-agent-block.md](docs/sessions/SNAPSHOT-2026-05-06-owner-control-agent-block.md)

## Incident State Transition 2026-05-08 — MONITOR (P0 → P1)

Incident `INCIDENT-2026-05-07-EVO1-XMRIG` transitioned from P0 to MONITOR state on 2026-05-08 22:05 CEST after all 7 technical phases complete + AML/KYC integrity verified + containment stable 30+ hours. Roadmap unfreeze under `I-59` active. Standard OCAT/CCF roadmap-block accumulation procedure restored.

- Incident document: `docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md`
- State: MONITOR (P1, downgraded from P0)
- Observation window: 2026-05-08 22:05 CEST .. 2026-05-09/10 22:05 CEST
- Pending external: MLRO/DPO/CCO/Legal formal sign-off (parallel-safe)
- Pending operator-side: Phase 6 credentials rotation (parallel-safe)
- Roadmap restrictions remaining: no destructive ops on evo1; containment iptables stay; Bundle B preservation continues

Tag after merge: `checkpoint-2026-05-08-incident-monitor-state-transition`.

## Roadmap Block 2026-05-09 — Factory Restoration F0–F7 + §0 Section Fixation

> Block opened under I-59 (roadmap-block procedure restored under MONITOR state).
> Procedure: one branch → one commit → one PR → annotated checkpoint tag after merge.
> Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, bootstrap canon v3 §0..§30, I-37 (PROPOSED).

### Section §0 fixation (immutable canon)
- §0.1 Two-layer AI infrastructure: factory=Legion, project=evo1+evo2 unified
- §0.2 Five-tier hierarchy: operators / low management / heads+duplicates / CEO human-only / MLRO independent
- §0.3 Sandbox→Production gate: real customer data BLOCKED until 100% sandbox completion
- §0.4 Factory overseer agent: continuous §0 compliance monitoring (Phase F2.4)
- §0.5 Distribution discipline: cross-layer ONLY via LiteLLM gateway + Ruflo for regulated

### Phase F0 — Canon §0 fixation + project audit (CURRENT)
- [x] §0 accepted as immutable canon (this commit)
- [x] Factory layer baseline audit (machines + AI models + LiteLLM routes)
- [x] Post-evo2-update verification (kernel 6.17.0-23, llama-server :8082 healthy)
- [x] G-PROJECT-SECTION-0-COMPLIANCE-AUDIT-PENDING (P0) created
- [ ] Sprint S2 — existing project §0.2 audit + per-deviation GAPs

### Phase F1 — P0 regulatory unblock (Sprint S3)
- [ ] Deploy Ruflo on Legion factory infrastructure
- [ ] Wire LiteLLM project-mid / project-heavy / project-reason via Ruflo proxy chain
- [ ] Verify regulated request flow: client → LiteLLM → ARL → Ruflo → llama-server → response
- [ ] Closes G-FACTORY-RUFLO-NOT-DEPLOYED

### Phase F2 — P1 operational restoration (Sprint S3)
- [x] F2.1 evo2 SSH access restored (operator update 2026-05-09)
- [x] F2.2 llama-server qwen3-235b on evo2:8082 verified healthy
- [ ] F2.3 Deploy 4 canonical Claude subagents to ~/.claude/agents/ (controller, inspector-agent, openclo-moa, safeguarding-agent)
- [ ] F2.4 Deploy factory overseer agent for §0 compliance monitoring + 100% completion KPI
- [ ] F2.5 Update Perplexity supervisor canon with §0 awareness

### Phase F3 — P2 hardening (Sprint S4)
- [ ] F3.1 Create /etc/systemd/system/litellm-v2.service unit
- [ ] F3.2 Reconcile 20 LiteLLM routes vs 7 canonical (14 extra route decisions + project-heavy register-or-remove)
- [ ] F3.3 Relocate or canon-update Spec-First Auditor v2 path

### Phase F4 — P3 documentation (Sprint S5)
- [ ] F4.1 Sync canon §1/§1.bis with factual state; document distributed inference (glm-master + llama-rpc-worker)
- [ ] F4.2 ROADMAP.md trackable F0–F7 milestones (this block opens F0)
- [ ] F4.3 Sweep canon-file duplicates (root vs docs/ GAP-REGISTER.md)

### Phase F5 — §0.2 hierarchy implementation (Sprints S6–S10)
- [ ] F5.1 Level 1 AI agents (operators)
- [ ] F5.2 Level 2 AI agents (team leads)
- [ ] F5.3 Level 3 Heads + human duplicate framework
- [ ] F5.4 Level 4 CEO governance interface
- [ ] F5.5 Level 5 AI MLRO independent agent (NOT subordinate to CEO; Ruflo MANDATORY)

### Phase F6 — Sandbox 100% completion (Sprint S11)
- [ ] FCA sandbox audit pass / GDPR Art.32 / AMLR-AMLD6 readiness review

### Phase F7 — Production transition (Sprint S12)
- [ ] Multi-party sign-off (Operator + MLRO + Legal + Compliance) → real customer data migration → live operations

### Pending tags (post-merge per canon §21)
- checkpoint-2026-05-09-canon-section-0-fixation (after this PR merge)
- checkpoint-2026-05-XX-factory-restoration-F1-complete (after Sprint S3)
- checkpoint-2026-05-XX-factory-100-percent-restored (after Sprint S5)
- checkpoint-2026-05-XX-section-0-implementation-complete (after Sprint S10)
- checkpoint-2026-05-XX-sandbox-100-percent-complete (after Sprint S11)
- checkpoint-2026-05-XX-production-transition-ready (after Sprint S12)

## Roadmap Block 2026-05-09 — Sprint S2 Project §0.2 Compliance Audit

> Block opened under I-59 (roadmap-block procedure restored under MONITOR state).
> Procedure: one branch → one commit → one PR → annotated tag NOT applied (process audit, not milestone per canon §21).
> Anchors: IL-OPS-PROJECT-SECTION-0-COMPLIANCE-AUDIT-2026-05-09, bootstrap canon v3 §0.2 + §10 Phase F0/F5 + §11 Sprint S2..S10, I-37 (PROPOSED).

### Sprint S2 closure (Phase F0 final)
- [x] Existing project (54 AI agents + 84 services + SM&CR framework) audited vs §0.2 Levels 1..5
- [x] Existing autonomy framework (L1/L2/L3/L4 + GREEN/AMBER/RED + 17 HITL gates) catalogued
- [x] Per-Level mapping established (Level 4 ALIGNED, Levels 1+2+3+5 PARTIAL/CONFLICT)
- [x] G-PROJECT-SECTION-0-COMPLIANCE-AUDIT-PENDING (P0 from Sprint S1) → CLOSED
- [x] 5 per-deviation GAPs opened (1 P0 Level 5 + 3 P1 Levels 1+2+3 + 1 P3 services drift)

### Phase F5 readiness (post-S2)
- [ ] F5.1 (Sprint S6) Level 1 operators — governance choice required: Option A reformulate §0.2 Level 1 OR Option B remove human doubles OR Hybrid (operator decides) — G-PROJECT-SECTION-0-LEVEL-1-NO-DUPLICATE-VIOLATION
- [ ] F5.2 (Sprint S7) Level 2 team leads — same governance choice — G-PROJECT-SECTION-0-LEVEL-2-NO-DUPLICATE-VIOLATION
- [ ] F5.3 (Sprint S8) Level 3 SMF Heads + sub-Heads — deploy AI duplicates for SMF C-suite + formalise sub-Heads AI partner pattern — G-PROJECT-SECTION-0-LEVEL-3-SMF-HEADS-AI-DUPLICATE-MISSING
- [ ] F5.4 (Sprint S9) Level 4 CEO governance dashboard
- [ ] F5.5 (Sprint S10) Level 5 autonomous AI MLRO agent + Ruflo MANDATORY routing + HITL Gates §6 update for AML decisions — G-PROJECT-SECTION-0-LEVEL-5-AI-MLRO-AUTONOMOUS-MISSING

### Critical governance decision points (operator-only)
1. Levels 1+2 fundamental conflict: §0.2 declares "100% AI без duplicate" but ALL existing L1/L2 agents have human doubles per Agent Summary Registry. Three resolution paths in GAP descriptions.
2. Level 5 AI MLRO co-sign with CEO: HITL Gates §6 require "MLRO + CEO" for SAR retraction / Sanctions reversal / PEP onboarding. §0.2 says AI MLRO NOT subordinate to CEO. Resolution requires HITL Gates §6 amendment + legal review.

### Sandbox→Production gate (§0.3)
- All §0.2 Levels deployed in sandbox: BLOCKED (Levels 1+2 governance + Level 5 AI MLRO + Level 3 SMF AI duplicates all pending Sprint S6..S10).
- Real customer data migration: BLOCKED until Sprint S11 (sandbox 100% verification per Phase F6).

### Pending tags (canon §21 — process audit, NO tag applied for S2)
- Sprint S2 = process audit, not milestone per §21; no checkpoint tag applied.
- Next milestone tag: checkpoint-2026-05-XX-factory-restoration-F1-complete (after Sprint S3).

## Incident RESOLVED 2026-05-09 — INCIDENT-2026-05-07-EVO1-XMRIG

P0 → MONITOR → RESOLVED. 24h observation PASS. Containment static 43+h. Zero reinfection. AML/KYC integrity preserved. ~58 hours total incident duration.

Tag after merge: `checkpoint-2026-05-09-incident-resolved`.

→ Full incident document: [docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md](docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md)

## Roadmap Block 2026-05-09 — Sprint S3 F2 Progress (Phase F1 BLOCKED + F2 partial)

> Block opened under I-59. Procedure: one branch → one commit → one PR → NO tag (sprint progress, not milestone per §21).
> Anchors: IL-OPS-SPRINT-S3-F2-3-CLAUDE-SUBAGENTS-PARTIAL-DEPLOYMENT-2026-05-09, IL-OPS-SPRINT-S3-F2-5-PERPLEXITY-SUPERVISOR-CANON-SECTION-0-AWARENESS-2026-05-09, IL-OPS-SPRINT-S3-PROGRESS-NOTE-2026-05-09.

### Sprint S3 sub-phase status
- [ ] F1 (Ruflo deployment) — **BLOCKED** on operator decision: FA-3 reclassification (PR #83 ops/phase-f-applied-2026-05-06) reclassifies Ruflo as "internal review agent" CONFLICTS bootstrap canon v3 §0.5 + §1.bis "Ruflo MANDATORY for regulated routes". Resolution: adopt FA-3 / reject FA-3 / hybrid.
- [x] F2.1 (evo2 SSH access) — DONE 2026-05-09 00:47 (verified post-operator-update; G-FACTORY-EVO2-SSH-ACCESS-LOST CLOSED in Sprint S1 audit IL).
- [x] F2.2 (llama-server qwen3-235b on evo2:8082) — DONE 2026-05-09 00:47 (verified healthy in Sprint S1 audit IL).
- [/] F2.3 (4 canonical subagents) — PARTIAL 75% (3/4 deployed: controller + inspector-agent + safeguarding-agent in ~/.claude/agents/; openclo-moa MISSING, sub-GAP G-FACTORY-CLAUDE-SUBAGENT-OPENCLO-MOA-MISSING P2 opened).
- [ ] F2.4 (factory overseer agent §0.4) — **BLOCKED** on operator design spec (canon §0.4 high-level only; need agent definition + KPI dashboard mechanism + alert routing + §0.1+§0.2+§0.3 monitoring rules).
- [x] F2.5 (Perplexity supervisor canon §0 awareness) — DONE this commit (IL-OPS-SPRINT-S3-F2-5-PERPLEXITY-SUPERVISOR-CANON-SECTION-0-AWARENESS-2026-05-09 fixates Perplexity supervisor session canon awareness binding for §0 immutable).

### Operator decision queue (3 blocking items)
1. **FA-3 vs §0.5 Ruflo reconciliation** — choose adopt / reject / hybrid path before F1 deploy proceeds.
2. **openclo-moa subagent design spec** — author from scratch / adapt similar pattern (controller+inspector-agent hybrid?) / defer to later sprint.
3. **Factory overseer agent design spec (§0.4)** — operator authors high-level design before F2.4 implementation.

### Sprint S3 partial closure (post-this-commit)
- 3 of 5 sub-phases DONE (F2.1 + F2.2 + F2.5).
- 1 of 5 sub-phases PARTIAL (F2.3 = 75%).
- 2 of 5 sub-phases BLOCKED on operator (F1 + F2.4).
- Sprint S3 cannot fully close (G-FACTORY-CLAUDE-SUBAGENTS-MISSING remains PARTIAL until openclo-moa authored; G-FACTORY-RUFLO-NOT-DEPLOYED P0 remains OPEN until FA-3 reconciliation).

### Pending tags (canon §21 — sprint progress, NO tag applied)
- Sprint S3 = progress consolidation, not milestone per §21; no checkpoint tag applied for partial state.
- Next milestone tag: checkpoint-2026-05-XX-factory-restoration-F1-complete (after F1 unblocks + deploys; gates Sprint S3 closure).

## Roadmap Block 2026-05-09 — Sprint S4 F3.2 LiteLLM Routes Reconciliation Diagnostic

> Block opened under I-59. Procedure: one branch → one commit → one PR → NO tag (sprint progress per §21).
> Anchors: IL-OPS-SPRINT-S4-F3-2-LITELLM-ROUTES-RECONCILIATION-DIAGNOSTIC-2026-05-09.

### Sprint S4 F3.2 phase 1 (diagnostic) — DONE
- [x] All 20 LiteLLM routes enumerated from gateway + config (litellm-config.v2.yaml inspected)
- [x] 14 extras classified (9 DUPLICATE / 1 UNIQUE-PROMOTE / 2 UNIQUE-DECISION / 2 CROSS-LAYER-VIOLATION)
- [x] project-heavy resolution candidate identified (route `large` glm-4.5-air distributed inference)
- [x] Cross-layer concerns documented (factory-mid/heavy/coder backed on evo1+evo2 ollama = project-layer nodes per §1.bis)

### Sprint S4 F3.2 phase 2 (operator decisions) — PENDING
- [ ] 9 DUPLICATE-ALIASES removal — operator pre-approve bulk REMOVE (low risk; callers can switch to canonical names)
- [ ] `large` → `project-heavy` promotion strategy — rename / alias / new entry
- [ ] `fast` (glm-4.7-flash-abliterated) — promote as canonical / remove
- [ ] `gpt-oss-20b` (gurubot/gpt-oss-derestricted:20b) — keep with documentation / remove
- [ ] `ai-heavy` + `reasoning` cross-layer — REMOVE per §1.bis strict OR §1.bis amendment to allow cross-layer
- [ ] Cross-layer concern (factory-mid/heavy/coder on evo1+evo2 ollama) — §1.bis canon update OR Legion model expansion strategy

### Sprint S4 F3.2 phase 3 (implementation) — BLOCKED on phase 2
- [ ] LiteLLM config sweep per operator decisions (edit /home/mmber/MetaClaw/litellm/litellm-config.v2.yaml)
- [ ] Restart LiteLLM v2 process (graceful pipx-managed restart)
- [ ] Verification round-trip (curl all canonical 7 routes post-cleanup)
- [ ] G-FACTORY-LITELLM-ROUTES-VS-CANON-DRIFT closure
- [ ] G-FACTORY-LITELLM-PROJECT-HEAVY-ROUTE-MISSING closure

### Sprint S4 remaining sub-phases
- [ ] F3.1 (LiteLLM systemd unit) — operator design spec required (User/WorkingDirectory/ExecStart per current bare pipx invocation)
- [ ] F3.3 (Spec-First Auditor relocation) — operator decision: relocate to canon path ~/developer/spec-first/audit/ OR canon update §5 to factual path

### Pending tags (canon §21 — sprint progress, NO tag applied)
- Sprint S4 = progress consolidation, not milestone per §21; no checkpoint tag applied.
- Next milestone tag: checkpoint-2026-05-XX-factory-restoration-F1-complete (after Phase F1 unblocks + deploys).

## Roadmap Block 2026-05-09 — Sprint S5 F4 Documentation Reconciliation (autonomous)

> Block opened under I-59. Procedure: one branch → one commit → one PR → NO tag (sprint progress per §21).
> Anchors: IL-OPS-SPRINT-S5-F4-DOCUMENTATION-RECONCILIATION-2026-05-09.

### Sprint S5 F4 autonomous closures
- [x] **G-FACTORY-DOCUMENTATION-PATH-DRIFT** (P3) → CLOSED — 8 path references fixed in ROADMAP.md (docs/ prefix added)
- [x] **G-FACTORY-CANON-FILES-DUPLICATION** (P3) → CLOSED-RECLASSIFIED — namespace clarification headers added to both GAP-REGISTER.md files; distinct purposes documented (architecture canon vs operational EMI)
- [x] **G-FACTORY-DISTRIBUTED-INFERENCE-NOT-IN-CANON** (P2) → CLOSED — distributed inference topology documented in docs/LOCAL-CLOUD-ROUTING.md

### Sprint S5 F4 deferred (operator-blocked)
- [ ] **G-PROJECT-SERVICES-COUNT-DRIFT-VS-ROADMAP** (P3): per-service classification for 84 services — operator decision required per service
- [ ] **F3.1 LiteLLM systemd unit**: operator design spec required (User/WorkingDirectory/ExecStart)
- [ ] **F3.3 Spec-First Auditor relocation**: operator decision required (relocate to canon path OR canon update §5)
- [ ] **F4.1 bootstrap canon v3 §1/§1.bis update**: bootstrap is operator-supplied immutable artifact, cannot be edited from repo

### Sprint S5 status
- 3 GAPs autonomously closed (1 P2 + 2 P3).
- 4 sub-tasks deferred (operator-blocked).
- Sprint S5 = partial closure — autonomous documentation hygiene complete, operator-blocked tasks remain for dedicated future sprints.

### Pending tags (canon §21 — sprint progress, NO tag applied)
- Sprint S5 = progress consolidation, not milestone per §21; no checkpoint tag applied.
- Next milestone tag: checkpoint-2026-05-XX-factory-restoration-F1-complete (after Phase F1 unblocks + deploys).

## Roadmap Block 2026-05-09 — Sprint S4 F3.2 Phase 2 Proposal (operator decision matrix)

> Block opened under I-59. Procedure: one branch → one commit → one PR → NO tag (sprint progress per §21).
> Anchors: IL-OPS-SPRINT-S4-F3-2-PHASE2-PROPOSAL-2026-05-09.

### Phase 2 proposal authored — operator decision matrix
- [ ] **PROPOSAL A**: bulk REMOVE 9 DUPLICATE-ALIASES (12 model_list entries) — recommend pre-approval, low risk, all aliases have canonical equivalents
- [ ] **PROPOSAL B**: `large` → `project-heavy` promotion — recommend B2 (alias) for staged migration
- [ ] **PROPOSAL C**: cross-layer reconciliation factory-mid/heavy/coder — operator chooses C1 (canon §1.bis amendment) / C2 (Legion model expansion) / C3 (hybrid)
- [ ] **DECISION D1** `fast` route — recommend D1b REMOVE
- [ ] **DECISION D2** `gpt-oss-20b` — recommend D2b REMOVE
- [ ] **DECISION D3** `ai-heavy` — recommend D3a REMOVE per §1.bis strict
- [ ] **DECISION D4** `reasoning` — recommend D4a REMOVE per §1.bis strict + composite antipattern

### Phase 3 implementation — BLOCKED on Phase 2 operator approval matrix
- [ ] Edit litellm-config.v2.yaml per approved decisions (single atomic edit)
- [ ] Reload LiteLLM v2 process (graceful pipx restart)
- [ ] Verification round-trip (curl all canonical 7 routes — 200 OK; removed routes — 404)
- [ ] G-FACTORY-LITELLM-ROUTES-VS-CANON-DRIFT closure
- [ ] G-FACTORY-LITELLM-PROJECT-HEAVY-ROUTE-MISSING closure

### Pending tags
- Sprint S4 = sprint progress, not milestone per §21; no tag.

## Roadmap Block 2026-05-09 — Sprint S4 F3.2 Phase 3 Prep (caller migration inventory)

> Block opened under I-59. Procedure: one branch → one commit → one PR → NO tag (sprint progress per §21).
> Anchors: IL-OPS-SPRINT-S4-F3-2-PHASE3-PREP-CALLER-MIGRATION-INVENTORY-2026-05-09.

### Phase 3 prep — caller migration inventory complete
- [x] All 9 DUPLICATE-ALIASES caller-inventoried across banxe-emi-stack + MetaClaw + banxe-architecture
- [x] False-positive analysis applied (coding + ai aliases — no actual model_name callers)
- [x] Risk classification refined: 4 zero-caller + 2 low-risk + 3 medium-risk (all in dev tooling, NONE в EMI production)
- [x] Migration script template authored (yq config edits + sed caller migration + LiteLLM restart + verification round-trip)

### Phase 3 implementation — BLOCKED on operator approval matrix from Phase 2
- [ ] Operator approval: Proposals A/B/C + Decisions D1/D2/D3/D4
- [ ] Execute migration script (LiteLLM config edit + dev tooling migration + LiteLLM restart)
- [ ] Verification round-trip (curl 7 canonical → 200; curl 9 removed → 404)
- [ ] G-FACTORY-LITELLM-ROUTES-VS-CANON-DRIFT closure
- [ ] G-FACTORY-LITELLM-PROJECT-HEAVY-ROUTE-MISSING closure (если Proposal B executed)

### Pending tags
- Sprint S4 = sprint progress, NO tag.

## Roadmap Block 2026-05-09 — Sprint S4 + S5 Autonomous Closure

> Block opened under I-59. Procedure: one branch → one commit → one PR → NO tag (sprint closure note, not milestone per §21).
> Anchors: IL-OPS-SPRINT-S4-AND-S5-AUTONOMOUS-CLOSURE-2026-05-09.

### Sprint S5 — CLOSED-AUTONOMOUS
- [x] F4.1 canon §1/§1.bis sync — DONE (repo-internal canon docs)
- [x] F4.2 ROADMAP F0–F7 trackable milestones — DONE
- [x] F4.3 G-FACTORY-* GAPs reconciliation — DONE (5 GAPs closed/updated через S3+S4+S5)

### Sprint S4 — CLOSED-AUTONOMOUS-PORTION
- [x] F3.2 phase 1 (routes diagnostic) — DONE (PR #159)
- [x] F3.2 phase 2 (operator decision proposal) — DONE (PR #162)
- [x] F3.2 phase 3 prep (caller migration inventory) — DONE (PR #164)
- [ ] F3.2 phase 3 execute — DEFERRED (operator approval matrix required)
- [ ] F3.1 LiteLLM systemd unit — DEFERRED (operator design spec)
- [ ] F3.3 Spec-First Auditor relocation — DEFERRED (operator decision)

### Cumulative session state
- 9 PRs merged on origin/main (633bb6a + 13d9d4d + 5279009 + 85d8582 + 5d495ae + fefcdd8 + 513229d + 20f6bcf + e9a10ed)
- 1 milestone tag applied (checkpoint-2026-05-09-canon-section-0-fixation)
- 5 GAPs autonomously closed + 5 status updates applied
- Atomic single-block race-mitigation pattern validated 7×

### Genuine autonomous progression terminus reached
All canon authoring + diagnostic + caller inventory + script template + proposal preparation work merged on main. Phase 3 execute ready, awaits operator. Sprints S6-S12 require operator design specs.

### Operator decision queue (11 items consolidated)
1. FA-3 vs §0.5 Ruflo (blocks F1)
2. openclo-moa subagent design spec
3. Factory overseer §0.4 design spec (blocks F2.4)
4. F3.1 LiteLLM systemd unit design spec
5. F3.2 phase 3 execute approval matrix (Proposals A/B/C + Decisions D1-D4)
6. F3.3 Spec-First Auditor relocation OR canon update
7. 84 services per-service classification
8. §0.2 Levels 1+2 governance (Sprints S6+S7)
9. §0.2 Level 3 SMF Heads AI duplicates design (Sprint S8)
10. §0.2 Level 4 CEO governance dashboard design (Sprint S9)
11. §0.2 Level 5 AI MLRO + HITL Gates §6 amendment + legal review (Sprint S10)

### Pending tags
- Sprint S4 + S5 = closure notes, not milestones per §21; no tag.
- Next milestone tag: checkpoint-2026-05-XX-factory-restoration-F1-complete (after operator unblocks F1 + F1 deploys).

## Roadmap Block 2026-05-09 — Session Terminal Consolidation (S1-S5 autonomous progression complete)

> Block opened under I-59. Procedure: one branch → one commit → one PR → NO tag (session record per §21).
> Anchors: IL-OPS-SESSION-TERMINAL-2026-05-09-S1-S5-CONSOLIDATION.

### Cumulative session 2026-05-09 (final)
- 10 PRs merged on origin/main (633bb6a + 13d9d4d + 5279009 + 85d8582 + 5d495ae + fefcdd8 + 513229d + 20f6bcf + e9a10ed + e72ef51)
- 1 milestone tag (checkpoint-2026-05-09-canon-section-0-fixation)
- 6 GAPs autonomously closed + 4 status updates (5 + Sub-pattern C closure this IL)
- Atomic single-block race-mitigation pattern validated 8× (binding empirical evidence)
- Cherry-pick abort+redo recovery: 2×
- Independent verify+restore: 10 instances 100% success
- Branch protection restored: 10 instances no exposure
- 13 worktrees created with zero MEMORY.md leakage (Sub-pattern C empirical closure)

### Pattern updates recommended (Phase F4.1 reconciliation pending operator)
- Canon §13: append empirical learnings (atomic pattern PRIMARY, DIRTY abort, race-detect-2, independent restore SEPARATE, CodeRabbit PENDING handling, race-conflict limit 2)
- Canon §27: PROMOTE atomic single-block from "partially superseded" to "PRIMARY for high-activity canon work"

### 11 operator decisions queue (binding terminus)
[same as IL listing]

### Pending tags
- Session terminal record = NO tag per §21 (not milestone).
- Next milestone tag: checkpoint-2026-05-XX-factory-restoration-F1-complete (after operator unblocks F1 + deploys).

### Genuine absolute autonomous progression terminus
All pathways exhausted per канон §6+§7 ENHANCED v3. Resume requires operator inputs.

## Roadmap Block 2026-05-10 — Perplexity Management Improvement Plan ACCEPTED + Phase 5 kickoff

> Block opened under I-59. One branch / one commit / one PR / annotated tag `checkpoint-2026-05-10-perplexity-management-plan-accepted` after merge.
> Anchors: IL-OPS-PERPLEXITY-MANAGEMENT-IMPROVEMENT-PLAN-ACCEPTED-2026-05-10, PR #168 (be2ab59), tag checkpoint-2026-05-10-canon-unified-accepted.

### Layer 0
- [x] PR #168 ACCEPTED (be2ab59 + tag) — DONE 2026-05-09T23:38:46Z
- [x] Plan IL acceptance — DONE this commit
- [ ] Local-only repos rescue (banxe + banxe-ai-infrastructure) — operator-led P0
- [ ] Mirror backfill 8 PRs Sprint 6-10

### Layer 1 — amendment-30.O
- [ ] T2 Canon Synthesis Drafter / T3 Cross-Repo Coordinator / T4 Compliance Advisor / T5 Decision Triage / T6 Privileged Operator (gated)

### Phase 5 — Autonomous
- [ ] 5.1 Track A close
- [ ] 5.2 Track G close
- [ ] 5.3 Mirror backfill (#94, #96, #97, #98, #100, #101, #105, #157)
- [ ] 5.4 Local-only repos rescue (operator-led)

### Phase 6 — Operator-blocked
- [ ] Track B / D / E / F / H / I + §0.2 Levels 1+2 + L3+L4+L5 designs + FA-3 Ruflo + openclo-moa + Factory overseer + MLRO appointment + Safeguarding engine

### Phase 7 — Crypto Block
- [ ] ADR-036 FATF Travel Rule + CryptoCompliancePort + Wave E process extraction + Neuronext + TomPay + Crypto AML

### Phase 8 — Multi-agent Comms
- [ ] Multi-agent comms + Real-time dashboard + Telegram bot + FCA Section 4 + MI report

### Phase 9 — QA + Production Ready
- [ ] E2E + payment regression + compliance playbooks + AI benchmarks + load testing + Track I cutover + DR/failover + monitoring + docs audit + go-live checklist

### Phase 10 — FCA Submission + Go-Live
- [ ] SMF + Internal Audit + Board + RegData FIN-RPT + safeguarding evidence + MLRO report + AML policy + business plan + multi-party sign-off + customer data migration + live operations

### Pending tags (canon §21)
- checkpoint-2026-05-10-perplexity-management-plan-accepted (after this PR merge)
- checkpoint-2026-05-XX-phase5-step3-mirror-backfill-complete
- checkpoint-2026-05-XX-amendment-30-O-accepted
- checkpoint-2026-05-XX-track-A-G-closed
- checkpoint-2026-05-XX-mlro-appointed
- checkpoint-2026-05-XX-safeguarding-engine-complete
- checkpoint-2026-05-XX-phase6-complete
- checkpoint-2026-05-XX-phase7-crypto-complete
- checkpoint-2026-05-XX-phase8-comms-complete
- checkpoint-2026-05-XX-phase9-production-ready
- checkpoint-2026-05-XX-fca-emi-submitted
- checkpoint-2026-05-XX-go-live (FINAL)

### CORE PRINCIPLE (per PR #168 binding)
NEW EMI stack главный, BANXE.RAR = только источник процессов (НЕ кода). Sprint 10 dobor confirmed.

### Two-loop sync (binding)
emi-stack IL → architecture IL mirror. Pre-commit hook on both repos enforce.

### Working as factory under unified canon
amendment-B.11.N+2: Claude Code executor + Mark pool owner + Perplexity coordinator. ADR-025 Session Rules 1..7. Race-mitigation pattern validated 10×.

## Roadmap Block 2026-05-10 — Phase 5 Step 5.3 Mirror Backfill (partial — 4 of 8)

> Block opened under I-59. Procedure: one branch / one commit / one PR / NO tag (sprint progress per §21).
> Anchors: IL-OPS-PHASE5-STEP53-TWO-LOOP-MIRROR-BACKFILL-2026-05-10.

### Phase 5 Step 5.3 — partial backfill DONE (4 of 8 originally-listed)
- [x] PR #94 mirror — TwilioOtpAdapter + SendGridOtpAdapter (Wave B OTP) — IL-MIRROR-EMI-PR-94
- [x] PR #96 mirror — SumsubHttpAdapter (Wave C/D KYC) — IL-MIRROR-EMI-PR-96
- [x] PR #97 mirror — ModulrSepaAdapter (Wave C SEPA) — IL-MIRROR-EMI-PR-97
- [x] PR #100 mirror — ADR-035 smoke gate matrix mock tier — IL-MIRROR-EMI-PR-100

### Deferred (NOT merged in emi-stack OR wrong-repo)
- [ ] PR #98 mirror (Wave E Midaz crypto adapter — NOT merged)
- [ ] PR #101 mirror (ADR-035 Step 2 mock workflow — NOT merged)
- [ ] PR #105 mirror (ADR-035 Step 5 audit signal — NOT merged)
- [N/A] PR #157 mirror (lives в banxe-architecture, не emi-stack; already on main as Sprint 10 dobor)

### Two-loop sync rule (binding going forward)
Каждый emi-stack production PR merge → architecture INSTRUCTION-LEDGER.md mirror IL appended within 24h. Pre-commit hook to enforce — TBD Phase 6.

### Phase 5 status post-this-commit
- [x] Step 5.3 partial (4 mirrors done, 3 deferred pending merges)
- [ ] Step 5.1 Track A close (per MASTER-PLAN-2026-05-05) — next
- [ ] Step 5.2 Track G close — next
- [ ] Step 5.4 Local-only repos rescue (operator-led)

### Pending tags
- checkpoint-2026-05-XX-phase5-step53-mirror-backfill-complete (after deferred 3 PRs merged + their mirrors appended)

## Roadmap Block 2026-05-10 — Phase 5 Step 5.2 Track G Partial Closure

> Block opened under I-59. Procedure: one branch / one commit / one PR / NO tag (sprint progress per §21).
> Anchors: IL-OPS-PHASE5-STEP52-TRACK-G-PARTIAL-CLOSURE-2026-05-10.

### Track G — Ops/CI Hardening status (4/7 DONE + 1 PARTIAL + 2 NEW)
- [x] G-OPS-01 Postgres backup rotation — DONE 2026-05-10 (ADR-029 PR #167 + tag)
- [x] G-OPS-02 Backup-restore CI smoke — DONE 2026-05-10 (ADR-029)
- [x] G-API-01 Auth rate-limit — DONE 2026-05-10 (ADR-030 PR #172 + tag)
- [x] G-API-02 Rate-limit tests (17 tests) — DONE 2026-05-10 (ADR-030)
- [/] G-INFRA-01 evo2 stub registered (SERVICE-MAP + infrastructure.md), full registration TBD — PARTIAL
- [ ] G-CI-01 End-to-end smoke gate workflow — NEW operator-blocked (DevOps lead)
- [ ] G-CI-02 Required-check enforcement — NEW operator-blocked (depends on G-CI-01)

### Phase 5 status post-this-commit
- [x] Step 5.3 mirror backfill (PR #174)
- [x] Step 5.2 Track G partial closure (this commit)
- [ ] Step 5.1 Track A close — operator-blocked (G-GUARD-03/04 + G-CANON-AUTONOMY/15)
- [ ] Step 5.4 Local-only repos rescue — operator-led

### Phase 5 autonomous track substantially complete
2 of 4 steps DONE (5.2 + 5.3). Steps 5.1 + 5.4 await operator action.

### Pending tags
- checkpoint-2026-05-XX-track-G-fully-closed (after G-CI-01 + G-CI-02 + G-INFRA-01 full)

## Roadmap Block 2026-05-10 — Step 1 Item 5 Track A Drafts

> Block opened under I-59. One branch / one commit / one PR / NO tag (sprint progress per §21).
> Anchors: IL-OPS-STEP1-ITEM5-TRACK-A-GUARDIAN-ENFORCEMENT-DRAFTS-2026-05-10.

### Track A drafts — autonomous canon-edit complete
- [/] G-GUARD-03 REFRAMED — verification-pending-operator (5y TTL already prescribed per ADR-019, не extension)
- [/] G-GUARD-04 ROLLOUT-PLAN-DRAFTED — 4 repos shim install pending operator (banxe-architecture / banxe-platform / banxe-payment-core / banxe-infra)
- [/] G-CANON-AUTONOMY — V-14..V-17 test specs drafted, MetaClaw implementation pending
- [/] G-CANON-15 — §15 conversation-judge prompt spec drafted, MetaClaw implementation pending

### Track A deployment standby (per sandbox status)
- [ ] evo1 ClickHouse verify (G-GUARD-03 closure)
- [ ] Shim rollout 4 repos (G-GUARD-04 closure)
- [ ] MetaClaw test_canon_judge.py V-14..V-17 implementation (G-CANON-AUTONOMY closure)
- [ ] MetaClaw judge prompt §15 update (G-CANON-15 closure)

### Sequence post-this-commit
Step 2 (Item 6 Track G remaining drafts) → next.

## Roadmap Block 2026-05-10 — Step 2 Item 6 Track G Remaining Drafts

> Block opened under I-59. One branch / one commit / one PR / NO tag (sprint progress per §21).
> Anchors: IL-OPS-STEP2-ITEM6-TRACK-G-REMAINING-DRAFTS-2026-05-10.

### Track G remaining drafts — autonomous canon-edit complete
- [/] G-CI-01 — smoke-gate.yml workflow spec drafted (5-7 endpoints + ephemeral docker-compose + ≤ 7 min budget)
- [/] G-CI-02 — branch-protection migration spec drafted (smoke-gate required + enforce_admins true post-stabilization)
- [/] G-INFRA-01 — evo2 full registration map drafted (DNS, ports, monitoring, ROCm regression rollback, backup, Tailscale ACL)

### Track G deployment standby (per sandbox status)
- [ ] DevOps implement smoke-gate.yml workflow (G-CI-01 closure)
- [ ] Operator GitHub branch-protection migration (G-CI-02 closure)
- [ ] Operator evo2 full deploy + Tailscale ACL alignment (G-INFRA-01 closure)
- [ ] G-INFRA-02 ROCm/amdgpu kernel 6.17 regression resolution (P1)

### Sequence post-this-commit
Step 3 (Item 8 §0.2 Levels 3-5 + FA-3 + openclo-moa + Factory overseer drafts) → next.
