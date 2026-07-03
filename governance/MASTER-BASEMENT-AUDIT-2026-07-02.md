# MASTER-BASEMENT AUDIT — EMI BANXE AI BANK
**Дата:** 2026-07-02  
**Статус:** ПРИНЯТ — канонический артефакт governance  
**Тип:** Read-only аудит | System of Record  
**Автор:** Factory sub-agent (по поручению оператора)  
**Append-only (I-24). Обновления только через новые секции.**  

---

## 1. EXECUTIVE VERDICT

### 1.1 Что реально существует (Доказательства на код)

#### Floor 3 — Banking Domain Services (OPERATIONAL)

| Сервис | Файлы | Тесты | Статус | Доказательство |
|--------|-------|-------|--------|---|
| **services/payment/** | 17 py | 0 (unit) | Code-ready | ModulrAdapter (SEPA), MockPaymentAdapter, IBAN/BIC validators в ADR-102 |
| **services/ledger/** | 22 py | 0 (unit) | Operational | Midaz :8095 adapter; GL posting logic в ledger_service.py |
| **services/safeguarding-engine/** | 31 py | 10 | LIVE | CASS 15 реконсиляция, daily timer, PostgreSQL safeguarding_accounts table (GAP-087 LIVE) |
| **services/recon/** | 20 py | 0 | Operational | CAMT.053/MT940 parsing, reconciliation_engine.py, daily execution |
| **services/reporting/** | 6 py | 0 | Code-ready | FIN060 generator, dbt/models/marts/fin060/ (awaiting BT-010 FCA RegData key) |
| **services/fx_rates/** | 3 py | 0 | Live | Frankfurter ECB self-hosted, 160+ валют, fallback cache 24h |
| **services/aml/** | 4 py | 0 | Code-ready | Threshold logic (£10k/£50k), dual impl с vibe-coding (OD-1) |
| **services/kyc/** | 5 py | 0 | Blocked | Sumsub (BT-004) + Companies House (BT-005) adapters; EDD threshold logic |
| **services/fraud/** | 3 py | 0 | Operational | Jube :5001 adapter; Marble :5002 case routing (9 behaviour signals) |
| **services/intent_layer/** | 12 py | 1 | Staged | Intent parsing (INTENT_LAYER_ENABLED=false), SkillRouter incomplete (GAP-080) |
| **services/hitl/** | 4 py | — | Ready | HITL gates (L1-L4), Marble UI :5003 wired для approvals |
| **services/arl/** | — | — | Live | Agent Routing Layer (tier 1-3); Ollama multi-model на evo1/evo2 |
| **banxe_mcp/server.py** | 1 file | — | Live | 34 MCP tools (kb_query, monitor_*, route_*, experiment_*) |

**Итого Floor 3:** 95 сервисов всего, P0 core = 12 выше, остальные = L2

#### Floor 4 — Governance / HITL / Audit (FOUNDATION SOLID)

| Артефакт | Статус | Локация | Доказательство |
|----------|--------|---------|---|
| **INSTRUCTION-LEDGER.md** | ✅ Live | banxe-architecture/ | IL-829 (append-only, Guardian enforced per ADR-019/020) |
| **GAP-REGISTER.md** | ✅ Live | docs/ | 92 gaps total; 73% code-complete; 18 OPEN |
| **37 ADRs** | ✅ Canon | decisions/ | ADR-001..045; ADR-018 (LiteLLM 5-layer), ADR-019/020 (Guardian), ADR-045 (Intent-First), ADR-049 (L1 spec), ADR-102 (SEPA), ADR-153 (topology) |
| **STAFF-MATRIX-v3** | ✅ Live | docs/ | 70 passports (12 L1-L2 dept heads, 58 PROPOSED agents) |
| **HITL-MATRIX.yaml** | ✅ Live | docs/ | 17 gates (L1-L4 autonomy levels defined) |
| **CONSOLIDATION-PLAN.md** | ✅ Live | governance/ | Phase 2 IN PROGRESS; 4 dup resolutions, 5 API blockers |
| **GLOBAL-PROGRAM-PLAN.md** | ✅ Live | governance/ | 8 phases (1=DONE, 2=IN_PROGRESS, 3-8=PLANNED) |
| **pgAudit** | ✅ Active | PostgreSQL :5432 | Enabled at boot; 7-day retention verified (I-24) |
| **ClickHouse audit** | ✅ Live | :9000 | Append-only per I-24; TTL 5 years enforced (I-08) |
| **Factory Guardian** | ✅ Active | evo1 (Legion) | qwen3.5:35b-banxe-factory; daily IL/GAP append-only scan |

### 1.2 Что отсутствует (MISSING)

#### Customer-facing interfaces
| Gap | Почему критично | Target Floor |
|-----|-----------------|---|
| **Consumer banking UI** | No web/mobile app для обычных пользователей; только trading channel exists | Floor 1 |
| **6 Intent-First card variants** | bill-pay, transfer, savings, investment, debit, credit = 0/6 реализовано (GAP-080) | Floor 1 |
| **Mobile app (consumer)** | Expo exists only для trading; consumer mobile ABSENT | Floor 1 |

#### Agent activation & wiring
| What's missing | Impact | Gate |
|---|---|---|
| **58 PROPOSED agents** | Written в passports, не activated; I-27 L4 HITL sign-off required | Floor 2 → Phase 5 |
| **HITL Marble wiring** | Service ready (services/hitl/), но не connected к agentов decisions | Floor 2 → Phase 4 |

#### Deployment & infrastructure
| What's missing | Impact |
|---|---|
| **Service registry / deployment manifest** | No DEPLOYMENT-MANIFEST.md; no node assignments (evo1 vs evo2); no healthcheck strategy | Phase 3 blocker |
| **External API keys (BT-001..BT-010)** | 5 critical: Modulr, Sumsub, Companies House, Paymentology, FCA RegData | Phase 1 completion blocker |

#### Test coverage floor
| Domain | Tests | Gap | Priority |
|--------|-------|-----|----------|
| **services/payment/** | 0 | Need ≥8 | P0 |
| **services/ledger/** | 0 | Need ≥5 | P0 |
| **services/recon/** | 0 | Need ≥6 | P0 |
| **services/reporting/** | 0 | Need ≥8 | P0 |
| **services/aml/** | 0 | Need ≥12 | P1 |
| **services/kyc/** | 0 | Need ≥10 | P1 |
| **services/fraud/** | 0 | Need ≥4 | P1 |

### 1.3 Что fragmented (DUPLICATIONS)

| # | Дублирование | Location A | Location B | Status | Owner |
|---|-------------|-----------|-----------|--------|-------|
| **OD-1** | AML Orchestrator | vibe-coding/src/compliance/aml_orchestrator.py (718L, runtime) | banxe-emi-stack/agents/compliance/swarm.yaml (YAML, config) | CANDIDATE_COEXIST (Phase 2 sign-off pending) | MLRO/CTIO |
| **OD-2** | Payment Core | banxe-payment-core/src/ (297 tests, ADR-015, not deployed) | services/payment/ (17 py, runtime) | CANDIDATE_RECONCILE (Phase 2 investigation) | CTIO |
| **OD-3** | Intent Layer | banxe-ai-infrastructure/intent_dispatcher (Floor 1, 6 modules) | services/intent_layer/ (Floor 3 seam, 12 py) | CANDIDATE_COEXIST (no contract yet, GAP-091) | Product/CTIO |
| **OD-4** | TX Monitor | vibe-coding/src/compliance/tx_monitor.py (I-01 float violation) | services/aml/tx_monitor.py (Decimal, I-01 compliant) | CANDIDATE_ARCHIVE vibe (после port CRYPTO_FLAG) | CTIO |
| **OD-5** | SAR Generation | vibe-coding/src/compliance/sar_generator.py (4KB, stub) | services/aml/sar_service.py (24KB, prod, MLRO L4 gate) | CANDIDATE_ARCHIVE vibe | MLRO |
| **OD-6** | Audit Trail | vibe-coding pattern | ClickHouse + pgAudit (banxe-emi-stack, canonical) | CANDIDATE_ARCHIVE vibe (dev vs prod separation) | Audit Committee |
| **OD-7** | Recon Engine | vibe-coding/recon/ (reference) | services/recon/ (FCA CASS 15 prod) | CANDIDATE_ARCHIVE vibe (intentional separation) | MLRO |
| **OD-8** | Local clones | ~/banxe-* (62 checkouts) | git worktrees (3-4 active) | CANDIDATE_ARCHIVE (stale > 30 days) | Operator |
| **OD-9** | Service overlaps | banxe-emi-stack: aml/kyc/fraud (4+5+3 py, 0 tests each) | vibe-coding: similar stubs | CANDIDATE_COEXIST (API contract pending) | CTIO |

### 1.4 Что hidden / обнаружено в ходе аудита

#### vibe-coding (Compliance Reference Engine)
- **Статус:** ACTIVE, zero coupling к EMI stack (deliberate separation per DOSSIER §4)
- **Содержание:** 179 py modules; AML orchestrator (718L), TX monitor (13KB), SAR generator (4KB, stub), reconciliation engine
- **Риск:** I-01 нарушение в tx_monitor.py (float используется для денежных сумм); CRYPTO_FLAG rule не портирована в EMI
- **Resolution:** Phase 2: fix I-01 + port CRYPTO_FLAG, затем archive vibe или COEXIST с EMI под API contract

#### banxe-payment-core (Payment Orchestration)
- **Статус:** 297 tests (97% coverage), ADR-015 ACCEPTED, но **НЕ DEPLOYED**
- **Содержание:** Mastercard IPM settlement, BIN lookup, card lifecycle
- **Риск:** Duplicate с services/payment/; no API contract between репо
- **Resolution:** Phase 2: verify if deployed or reference-only; Phase 3 path decision (merge / integrate as lib / archive)

#### banxe-ai-infrastructure (Floor 1 Intent-Dispatcher)
- **Статус:** ACTIVE, 6 modules, separate repo, **0 integration test** с Floor 3
- **Содержание:** Intent parsing, skill router, hybrid interface
- **Риск:** No API contract к services/intent_layer/; GAP-091 (Path A/B/C decision pending)
- **Resolution:** Phase 2: formalize contract; Phase 3: enable INTENT_LAYER_ENABLED=true

#### Orphan repositories
- **Inactive > 30 days:** banxe-archive-2026-04-18, gpt-archive-toolkit, banxe-monitoring, crypto-ops-monitor (22 total)
- **Risk:** Divergence if WIP branches not cleaned up
- **Resolution:** Phase 2: inventory + cleanup plan

### 1.5 Критические blockers для единого банка

| Blocker | Impact | Owner | Target |
|---------|--------|-------|--------|
| **1. Phase 2 Consolidation** | 9 duplications = distributed logic; cannot converge to SSOT without formal resolution | MLRO/CTIO/CEO | Sprint 1 (Q3 2026) |
| **2. External API Keys (BT-001..BT-010)** | 5 gates: Modulr (payment), Sumsub (KYC), Companies House (KYB), Paymentology (card), FCA RegData (reporting) | CEO/CTIO | Phase 1 completion |
| **3. Test Coverage Floor** | P0 services = 0 unit tests (except safeguarding-engine: 10); cannot enter Phase 3 without ≥80% coverage gate | Factory | Sprint 2 (Q3 2026) |
| **4. Agent Activation & HITL Wiring** | 58 agents PROPOSED, not activated; I-27 L4 gates = manual process (not automated) | MLRO/CTIO | Phase 5 (Q4 2026) |
| **5. Deployment Manifest** | No service registry, no node assignment strategy, no health-check automation | CTIO | Phase 3 (Q3 2026) |

---

## 2. REPOSITORIES & ARTIFACTS (FULL INVENTORY)

### Репозитории (34 total)

**Активные (< 30d):** banxe-architecture, banxe-emi-stack, vibe-coding, banxe-trading-backend, banxe-trading-frontend, banxe-ai-infrastructure, MetaClaw, developer-core, banxe-ui (9 repos)

**Неактивные (30-90d):** banxe-platform, banxe-infra, banxe-business-processes, banxe-monitoring, и др. (7 repos)

**Archived (> 90d):** banxe-archive-2026-04-18, gpt-archive-toolkit, crypto-ops-monitor, legal-*, braslina (15 repos)

**Excluded (security):** 1 EXCLUDED per GUIYON rule

### Governance artifacts (Floor 4)
- INSTRUCTION-LEDGER.md (IL-829, append-only)
- GAP-REGISTER.md (92 gaps, 73% code-complete)
- 37 ADRs (decisions/)
- 70 passports (STAFF-MATRIX-v3)
- HITL-MATRIX.yaml (17 gates)
- CONSOLIDATION-PLAN.md
- MASTER-DOSSIER.md
- GLOBAL-PROGRAM-PLAN.md

### Domain services (Floor 3)
- 95 services total
- P0 core: payment, ledger, safeguarding, recon, reporting, fx, aml, kyc, fraud, intent_layer, hitl, arl
- L2 support: 83 services (agreement, audit, auth, billing, card, compliance, customer, etc.)
- 1,931 tests total (mostly integration); 10 in safeguarding-engine only

### Client interfaces (Floor 1)
- banxe-trading-frontend (React 19, Expo) — trading only, ✅ Live
- Consumer banking UI — 🔴 ABSENT
- intent_dispatcher (banxe-ai-infrastructure) — 🟡 Staged, 0 integration tests
- services/intent_layer — 🟡 Staged, INTENT_LAYER_ENABLED=false
- 6 card variants — 🔴 ABSENT (0/6), GAP-080
- banxe-ui prototype — 🟡 Proto, may become consumer home

### Orchestration / agents (Floor 2)
- 70 passports (12 L1-L2, 58 PROPOSED)
- swarm.yaml defined, not activated
- ARL live (Ollama Tier 1-3)
- HITL service ready, gates defined, not wired
- Guardian active (qwen3.5:35b evo1)

### Runtime / infra
- PostgreSQL :5432 ✅
- Redis :6379 ✅
- ClickHouse :9000 ✅ (append-only, TTL 5yr)
- Keycloak :8180 ✅
- Jube :5001 ✅
- Marble :5003 ✅
- Frankfurter :8087 ✅
- Midaz :8095 ✅
- n8n :5678 🟡 Configured
- Ollama evo1/evo2 ✅

---

## 3. FOUR-FLOOR MAPPING

| Floor | Status | Owner | Key components |
|-------|--------|-------|---|
| **1 (Client)** | 🔴 THIN | Product | Trading ✅, Consumer UI ❌, Intent THIN, 6 variants ❌ |
| **2 (Orchestration)** | 🟡 PROPOSED | MLRO/CTIO | Passports ✅, swarm YAML ✅, ARL ✅, HITL ready ✅, agents not wired ❌ |
| **3 (Banking)** | ✅ OPERATIONAL | Factory | 12 P0 services + 83 L2; 1,931 tests; unit test coverage thin ❌ |
| **4 (Governance)** | ✅ SOLID | Audit/Guardian | IL ✅, GAP-REGISTER ✅, ADRs ✅, pgAudit ✅, ClickHouse ✅ |

---

## 4. DUPLICATION MATRIX (OD-1..OD-9)

All 9 duplications require Phase 2 operator resolution before Phase 3 (SSOT) can proceed.

| OD | Issue | Path A | Path B | CANDIDATE | Phase 2 Gate |
|----|-------|--------|--------|-----------|---|
| OD-1 | AML orch (vibe 718L vs banxe YAML) | vibe runtime engine | banxe config layer | COEXIST (6-week test) | MLRO/CTIO sign-off |
| OD-2 | Payment-core (not deployed vs services/payment runtime) | Reference only | Primary runtime | RECONCILE (path decision) | CTIO sign-off |
| OD-3 | Intent-Dispatcher (Floor 1) vs intent_layer (Floor 3) | Floor 1 canonical | Floor 3 seam | COEXIST (contract needed) | Product/CTIO sign-off |
| OD-4 | TX Monitor (vibe I-01 violation vs EMI Decimal) | Fix I-01 + port CRYPTO_FLAG | Keep both | ARCHIVE vibe | CTIO sign-off |
| OD-5 | SAR Generator (vibe stub vs EMI prod) | Reference only | Production | ARCHIVE vibe | MLRO sign-off |
| OD-6 | Audit Trail (vibe pattern vs ClickHouse+pgAudit prod) | Dev reference | Production | ARCHIVE vibe | Audit sign-off |
| OD-7 | Recon Engine (vibe generic vs services/recon CASS 15) | Reference | Regulatory | ARCHIVE vibe | MLRO sign-off |
| OD-8 | Local clones (62 checkouts, 30+ stale worktrees) | Manual cleanup | Worktrees only | CLEANUP (inventory + remove stale) | Operator sign-off |
| OD-9 | Service overlaps (aml/kyc/fraud) | API contract to vibe | EMI wrappers | COEXIST (contract pending) | CTIO sign-off |

---

## 5. CRITICAL PATH (Phases 1–8)

**PHASE 1 (✅ DONE):** Master Dossier + Master Basement Audit
- Governance foundation locked
- 9 duplications catalogued
- 5 blockers identified

**PHASE 2 (🟡 IN PROGRESS):** Consolidation Prep — Q3 2026, 6-8 weeks
- CONSOLIDATION-PLAN-PHASE-2.md (formal execution contract)
- 9 duplication resolutions (operator sign-offs)
- API contracts spec (5 specs)
- I-01 fix (vibe tx_monitor)
- 200+ unit tests on P0 services
- Phase 3 entry gate

**PHASE 3 (PLANNED):** Single Source of Truth — Q3 2026
- Unified domain map (2-repo stable)
- Deployment manifest (service registry)
- Intent Layer activation
- Floor1↔Floor3 API contract implemented

**PHASE 4 (PLANNED):** Runtime Hardening — Q4 2026
- Guardian activation (ADR-019/020)
- HITL wiring (Marble → agents)
- Compliance swarm activation (I-27 manual)

**PHASE 5 (PLANNED):** Department-Head Deep-Build — Q4 2026–Q1 2027
- MLRO line (7 AML agents)
- Finance line (6 agents)
- Audit line activation
- COO line activation

**PHASE 6 (PLANNED):** Externalize & Partner — Q1 2027
- Consumer banking UI (Floor 1 build)
- BaaS API contract
- AGPL boundary fix (GAP-081)

**PHASE 7 (PLANNED):** Compliance Certification — Q2 2027
- FCA pre-authorisation audit

**PHASE 8 (PLANNED):** Production Handoff — Q2 2027
- Customer cutover
- Operator → SMCR transition

---

## 6. NEXT SINGLE BEST ARTIFACT

### governance/CONSOLIDATION-PLAN-PHASE-2.md

**Why:** Formal execution contract. Fixes all Phase 1 decisions into operator sign-off matrix:
- 9 duplication resolutions (OD-1..OD-9)
- 5 API contract specs
- Test coverage floor strategy (200+ tests)
- Operator sign-off checklist (MLRO / CTIO / CEO)
- Phase 3 entry criteria (all duplications resolved with evidence)

**Without it:** 9 decision points = no forward motion; Phase 3 SSOT blocked indefinitely.

**With it:** Sprint 1–7 parallelizable execution; measurable milestones.

---

*Append-only (I-24). Обновления только через новые секции с датой.*  
*Все CANDIDATE_* метки предварительные. Финальные решения только после Phase 2 operator sign-off.*  
*Factory sub-agent: Audit complete. Ready for governance execution.*
