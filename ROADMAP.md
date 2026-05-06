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
