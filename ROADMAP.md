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
- [x] ORG-STRUCTURE.md — Organizational structure
- [x] DEPARTMENT-MAP.md — 10 departments with AI agents
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
- [x] JOB-DESCRIPTIONS.md — AI agents & human doubles, 32 roles (IL-080)
- [x] FEATURE-REGISTRY.md — 30 features with purpose, value & KPIs (IL-081)
- [x] RELATIONSHIP-TREE.md — Org relationships, agent interactions, escalation (IL-082)
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
| ORG-STRUCTURE.md | Complete | Initial |
| DEPARTMENT-MAP.md | Complete | Updated 10 depts |
| COMPLIANCE-FRAMEWORK.md | Complete | Initial |
| CRYPTO-BLOCK.md | Complete | IL-070 |
| JOB-DESCRIPTIONS.md | Complete | IL-080 |
| FEATURE-REGISTRY.md | Complete | IL-081 |
| RELATIONSHIP-TREE.md | Complete | IL-082 |
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
