# MASTER-ORG-CODE-RUNTIME-DOSSIER
## Canonical Organization, Code, and Runtime Inventory — BANXE AI BANK
**Date:** 2026-07-02  
**Status:** ACTIVE (append-only enforced by Guardian per I-24)  
**Author:** Moriel Carmi / FinDev Agent  
**Program Phase:** 1 of 8  

---

## §1. REPOSITORY CENSUS

Canonical inventory of all active repositories in BANXE constellation. All repos enforced at quality-gate baseline (Ruff + Semgrep 10 rules + ≥80% pytest coverage on core modules).

| Repository | URL | Primary Purpose | Stack | File Count | Last IL | Status |
|------------|-----|-----------------|-------|-----------|---------|--------|
| **banxe-architecture** | github.com/CarmiBanxe/banxe-architecture | Governance, compliance engine, ADRs, STAFF-MATRIX, IL ledger, HITL gates, constitution | Markdown + YAML passports | ~400 docs + 70 passports | IL-802 (STAFF-MATRIX-v3) | ✅ ACTIVE (authoritative) |
| **banxe-emi-stack** | github.com/CarmiBanxe/banxe-emi-stack | P0 Financial Analytics: payments, ledger, reconciliation, FIN060, safeguarding (CASS 15) | Python 3.12 / FastAPI / PostgreSQL 17 / ClickHouse / Redis | 109 services, 696 .py, 1931 tests | IL-795 | ✅ ACTIVE (product plane, CASS 15 deadline extended Q3 2026) |
| **vibe-coding** | github.com/CarmiBanxe/vibe-coding | Compliance reference engine: AML orchestration, sanctions screening, KYB, crypto AML, reconciliation | Python 3.11 / FastAPI / ClickHouse | 179 .py modules (165 in src/compliance), 60+ test files | IL-650+ (internal) | ✅ ACTIVE (compliance ref, zero coupling to EMI stack) |
| **ss1** | (archived, public until 2026-05-13) | Training/research dataset repo | Markdown + CSV | ~50 docs | — | ❌ ARCHIVED (GDPR GAP-085 pending legal review) |

**Satellite Repos (utility/reference only):**
- **banxe-frontend** — React 19 / TypeScript / Tailwind (not yet in census; D2C pipeline via Mitosis)
- **.claude/** — Quality gates, rules, skills, commands (embedded in emi-stack)
- **.github/workflows/** — CI/CD (embedded in emi-stack)

---

## §2. FOUR-FLOOR ARCHITECTURE MAP

BANXE AI Bank operates as a 4-floor hybrid orchestration (each floor distinct repo/domain/autonomy level):

**FLOOR 1: CLIENT / INTENT-FIRST**
- **Component:** Intent Parsing + Skill Router (Hybrid Intent Interface)
- **Repo:** banxe-emi-stack / services/intent_layer
- **Path:** services/intent_layer/ (12 py files)
- **Status:** 🟡 THIN (scaffolding; GAP-080 — 6 card variants not implemented on frontend)
- **Note:** FinGPT-style financial intent ("send £100 to Alice", "show my balance") routed to skill agents; frontend (banxe-frontend) missing Intent UI; customer-facing gap

**FLOOR 2: ORCHESTRATION / EXECUTIVE / DEPARTMENT-HEAD AGENTS**
- **MLRO Line (compliance):** agents/compliance/soul/mlro_agent.soul.md, agents/passports/aml/ (7 sub-agents: sanctions, TM, Jube, Watchman, PEP, KYB, EDD)
- **CFO Line (finance):** agents/passports/finance/ (6 agents: GL close, AP/AR, consolidation, IFRS, tax, beancount); services/reporting/ (FIN060 generator)
- **Audit Line (3rd-line):** services/compliance/ + agents/passports/safeguarding_audit_agent.yaml
- **COO Line (ops):** agents/passports/coo_operations_agent.yaml
- **Repo:** banxe-architecture (passports) + banxe-emi-stack (services)
- **Status:** 🟡 PARTIAL (passports exist; agents NOT activated; live gated on I-27 HITL-L4 sign-off per Sprint 4-7 decisions)

**FLOOR 3: BANKING DOMAIN SERVICES / RAILS / AML / FINANCE / SUPPORT**
- **Payment Rails:** services/payment/ (17 py, Modulr + Mock adapters), services/open_banking/ (11 py, PSD2)
- **Core Ledger:** services/ledger/ (22 py, Midaz adapter + GL posting logic)
- **Reconciliation:** services/recon/ (20 py, CAMT.053/MT940 parsing, breach detection, RegData uploader)
- **AML/KYC/Fraud:** services/aml/ (4 py), services/kyc/ (5 py), services/fraud/ (3 py), services/case_management/ (4 py)
- **Safeguarding (CASS 15):** services/safeguarding-engine/ (31 py, FastAPI + PostgreSQL 17 + Alembic, 10 tests — only service with test coverage)
- **Reporting:** services/reporting/ (6 py, FIN060 generator)
- **FX Rates:** services/fx_rates/ (3 py, Frankfurter ECB self-hosted)
- **Transaction Monitoring:** services/transaction_monitor/ (14 py, real-time monitoring + alert routing)
- **Repo:** banxe-emi-stack
- **Status:** ✅ OPERATIONAL (code-complete for P0 services; tests minimal except safeguarding-engine)

**FLOOR 4: GOVERNANCE / HITL / AUDIT / SMCR / RESILIENCE**
- **Governance Artifacts:** INSTRUCTION-LEDGER.md (IL-802 max), GAP-REGISTER.md (83 gaps), HITL-MATRIX.yaml (17 gates), constitution/ (immutable), amendments/ (monotonic append)
- **Audit Trail:** ClickHouse (append-only per I-24, TTL 5yr), pgAudit (PostgreSQL transaction logging)
- **Guardian Agents:** Factory Guardian (qwen3.5:35b on Legion, model: qwen2.5-coder:14b-banxe-factory), Project Guardian (incoming, paired with Factory)
- **HITL Service:** services/hitl/ (4 py, decision approval gates)
- **Compliance Knowledge Base:** services/compliance_kb/ (10 py, 88 tests, 6 MCP tools for regulatory queries)
- **SMCR Wiring:** STAFF-MATRIX-v3 (70 passports: 12 L1-L2 dept heads, 7 AML sub-agents, 13 core platform, 6 finance, 32 support/proposed)
- **Repo:** banxe-architecture (governance) + banxe-emi-stack (HITL service) + vibe-coding (compliance reference)
- **Status:** ✅ OPERATIONAL (governance foundation solid; Guardian enforcement phase 4 pending)

**Strongest Floors:** Floor 3 (payment/ledger/recon operational), Floor 4 (governance artefacts mature)  
**Thinnest Floors:** Floor 1 (intent-first missing 6 variants), Floor 2 (agent stubs not activated, gated on HITL-L4)

---

## §3. SYSTEM OF RECORD BY DOMAIN

Canonical mapping of authoritative data source for each business domain. Dual-write risk eliminated where possible; conflicts resolved by this table.

| Domain | System of Record | Repo | Path | Status | Notes |
|--------|------------------|------|------|--------|-------|
| **Identity / IAM** | Keycloak 26.2 (primary) + PostgreSQL JWT store | banxe-emi-stack | services/auth/ + services/iam/ | ✅ OPERATIONAL | Keycloak @ :8180 (ADR-017); JWT validation in FastAPI middleware; LDAP fallback (AD not yet configured) |
| **Payments** | Modulr (production) + Mock (test) | banxe-emi-stack | services/payment/ | 🟡 PARTIAL (Modulr key BT-001 pending COO sign-off) | Adapters: ModulrAdapter (SEPA/Instant), MockPaymentAdapter; IBAN/BIC/SCT validators active (ADR-102) |
| **Ledger / CBS** | Midaz :8095 (PRIMARY CBS) | vibe-coding (integration), banxe-emi-stack (wrapper) | services/ledger/ | ✅ OPERATIONAL | GL posting via midaz_adapter.py; Midaz health @ GET /v1/health; dual-write: Midaz + PostgreSQL backup ledger_events |
| **AML Decision Logic** | vibe-coding (canonical engine) | vibe-coding + banxe-emi-stack | src/compliance/aml_orchestrator.py + services/aml/ | ✅ OPERATIONAL | Threshold: £10k (individual) / £50k (corporate); dual implementation (reference + runtime); MLRO sign-off gated on I-27 HITL-L4 |
| **KYC Individual** | Sumsub (external) + local cache | banxe-emi-stack | services/kyc/ | 🔴 BLOCKED (BT-004 Sumsub key pending CTIO) | Protocol DI pattern; InMemoryKYCPort used in tests; live adapter awaiting credential |
| **KYB Business** | Companies House API (external) + cache | banxe-emi-stack | services/kyc/ | 🔴 BLOCKED (BT-005 Companies House key pending CTIO) | OpenCorporates fallback (research phase); kyb_check.py in vibe-coding is reference |
| **Safeguarding / CASS 15** | PostgreSQL safeguarding_accounts table + daily FCA notification | banxe-emi-stack | services/safeguarding-engine/ + services/recon/ | ✅ OPERATIONAL | Midaz ledger ↔ safeguarding accounts ↔ rails (3-leg tie-out verified 2026-06-27); banxe-recon.timer triggers daily 23:59:59 UTC; immutable FCA shortfall alert active; GAP-087 LIVE |
| **FX Rates** | Frankfurter (self-hosted ECB, no API key) | banxe-emi-stack | services/fx_rates/ | ✅ OPERATIONAL | 160+ currencies; endpoint @ :8087; fallback cache (24-hr retention); used by reconciliation, reporting, payment rails |
| **Reporting / FIN060** | dbt (data warehouse) + WeasyPrint (PDF render) | banxe-emi-stack | services/reporting/ + dbt/models/marts/fin060/ | 🟡 PARTIAL (awaiting FCA RegData key BT-010, CEO/CFO approval) | SQL lineage traced; daily incremental; FCA return generation active (test mode); RegData upload pending credential |
| **Reconciliation (Daily)** | Blnk Finance (bank statement aggregator) + adorsys PSD2 gateway | banxe-emi-stack | services/recon/ | ✅ OPERATIONAL | CAMT.053/MT940 parsing active; statement_fetcher.py pulls from adorsys; breach detection (reconciliation_engine.py) identifies shortfalls; escalates to FCA via immutable alert |
| **Fraud Detection** | Jube TM (primary, :5001) + Marble (case routing, :5002) | vibe-coding + evo1 (hosted) | services/fraud/ + agents/passports/aml/ | ✅ OPERATIONAL | Behaviour signals (9 rules in tx_monitor.py); Jube adapter @ :5001 (AGPLv3); Marble UI @ :5003 (ELv2) for MLRO review |
| **Orchestration / AI Agents** | Ollama (multi-model LLM router on evo1/evo2) + OpenClaw (Telegram bot orchestration) | banxe-emi-stack + vibe-coding | agents/ + banxe_mcp/server.py (34 MCP tools) | ✅ OPERATIONAL | Models: qwen3-banxe-v2, qwen3:235b, llama3.3:70b; ARL (Agent Routing Layer) tier 1-3; L1-L4 autonomy gates enforced in services/hitl/ |
| **Audit Trail / Compliance Log** | ClickHouse (append-only, TTL 5yr per I-08) + pgAudit (PostgreSQL) | banxe-emi-stack | ClickHouse :9000 + PostgreSQL pgAudit config | ✅ OPERATIONAL | I-24 enforced: no UPDATE/DELETE on audit tables (Semgrep rule `banxe-audit-delete`); every financial action logged; Guardian verifies append-only weekly |
| **Compliance Knowledge Base** | Local ChromaDB (embeddings) + vector search | banxe-emi-stack | services/compliance_kb/ | ✅ OPERATIONAL | 6 MCP tools (kb_query, kb_update, kb_search, etc.); FCA/MLR/PSR/EU AI Act guidance indexed; agents query via KBQueryPort protocol |
| **Client / UX** | banxe-frontend (React 19) + Expo (mobile, planned) | Separate repo (not yet in census) | banxe-frontend / src/ | 🟡 PLANNED (D2C via Mitosis, IL-ADDS-01 complete, deployment pending) | Hybrid Intent Interface + 6 card variants (GAP-080 blocker for Floor 1) |

---

## §4. DUPLICATE TRAPS & RESOLUTION PATHS

Known duplications and potential overlaps discovered during census. All flagged for Phase 2 consolidation with operator sign-off.

| Duplicate | Location A | Location B | Risk Level | Resolution Path | Owner | Status |
|-----------|------------|------------|------------|-----------------|-------|--------|
| **banxe_aml_orchestrator.yaml** | banxe-emi-stack/agents/compliance/aml_orchestrator.yaml | vibe-coding/src/compliance/banxe_aml_orchestrator.yaml (30KB) | 🔴 HIGH (MLRO/CTIO sign-off required) | Single source of truth (Phase 2): consolidate to vibe-coding (reference engine), banxe-emi-stack imports via API call; migration requires 6-week testing cycle | MLRO/CTIO | 🟡 OPEN (Phase 2 prerequisite) |
| **Transaction Monitoring (tx_monitor.py)** | vibe-coding/src/compliance/tx_monitor.py (13KB, 9 behaviour signals) | banxe-emi-stack/services/aml/tx_monitor.py (similar rules) | 🟡 MEDIUM (no code reuse, separate evolution paths) | Consolidate logic to vibe-coding as reference; banxe-emi-stack consumes via FastAPI :8093 endpoint; keeps runtime decoupling (Phase 2) | CTIO | 🟡 OPEN (Phase 2 prerequisite) |
| **SAR Generation (sar_generator.py)** | vibe-coding/src/compliance/sar_generator.py (4KB, stub) | banxe-emi-stack/services/aml/sar_service.py (24KB, production) | 🟡 MEDIUM (vibe version is reference only, EMI is live) | Canonical: banxe-emi-stack/services/aml/sar_service.py; vibe-coding imports from EMI API for reference testing (no direct import) (Phase 2) | MLRO | 🟡 OPEN (Phase 2 prerequisite) |
| **Reconciliation Engine** | vibe-coding/recon/reconciliation_engine.py (generic) | banxe-emi-stack/services/recon/ (FCA CASS 15 implementation, 20 py files) | 🟢 LOW (vibe is reference, EMI is FCA-compliant production) | No consolidation needed; vibe serves as vendor-neutral reference, EMI is regulatory implementation; clear separation by concern (Phase 2 audit only) | MLRO/Audit | ✅ RESOLVED (separation intentional) |
| **Audit Trail (ClickHouse)** | vibe-coding/src/compliance/audit_trail.py (8.7KB) | banxe-emi-stack/services/audit/ + pgAudit (production, I-24 enforced) | 🟢 LOW (vibe is reference, EMI is authoritative) | Canonical: banxe-emi-stack + pgAudit (FCA-standard); vibe-coding audit_trail.py is reference only; EMI exports to ClickHouse per I-08 (5yr TTL) (Phase 2 audit only) | Audit Committee | ✅ RESOLVED (separation by compliance tier) |
| **Service Overlaps (AML/KYC/fraud)** | banxe-emi-stack: aml/ (4 py, 0 tests), kyc/ (5 py, 0 tests), fraud/ (3 py, 0 tests) | vibe-coding: similar stubs in src/compliance/ | 🟡 MEDIUM (minimal implementations on both sides; no integration tested) | Phase 2 consolidation: define API contract (EMI calls vibe :8093 endpoints for all AML/KYC/fraud decisions); EMI services become thin wrappers; vibe-coding is engine (Phase 2 task #A-AML-01) | CTIO | 🟡 OPEN (Phase 2 prerequisite) |
| **Intent-First Banking** | banxe-emi-stack/services/intent_layer/ (12 py, thin) | banxe-frontend (not yet in repo) | 🔴 HIGH (GAP-080: 6 card variants missing from frontend; customer-facing impact) | Frontend implementation required (Q3 2026); phase 2 to confirm EMI backend intent parser is complete before frontend build starts | Product | 🟡 OPEN (GAP-080) |

**Consolidation Prerequisite:** All duplicates require Phase 2 resolution before Phase 3 (single source of truth) can proceed. MLRO/CTIO formal approval required on each path.

---

## §5. THIN CRITICAL ZONES

Services or components with <3 py files that are on P0/P1 critical path. Each gap represents direct regulatory or operational risk if left thin.

| GAP Ref | Component | Repo | Path | What's Missing | Risk If Thin | Owner | Priority | Status |
|---------|-----------|------|------|-----------------|-------------|-------|----------|--------|
| **GAP-080** | Intent-First Banking (Floor 1) | banxe-emi-stack | services/intent_layer/ (12 py, 1 test) + banxe-frontend | 6 card variants (bill-pay, transfer, savings, investment, debit, credit); SkillRouter incomplete | Customers cannot use intent-based flows; PRIN7 (Consumer Duty) PS22/9 non-compliance (wrong UX for vulnerable customers) | Product | P0 | 🔴 OPEN (Q3 2026) |
| **GAP-058** | Safeguarding Audit (Floor 4) | banxe-emi-stack | services/compliance/ (audit adapter only) + agents/passports/safeguarding_audit_agent.yaml | Annual safeguarding audit automation (workpaper generation, evidence collection, finding lifecycle); agent stub only, not activated | FCA CASS 15 audit trail incomplete; cannot demonstrate annual IA audit per PS25/12 | Audit Committee | P0 | 🟡 PARTIAL (agent PROPOSED, not activated; live gated on I-27 HITL-L4) |
| **GAP-057** | Wind-Down Protocol (Floor 4) | banxe-emi-stack | services/incident_response/ (2 py files) | Wind-down playbook (customer notification, fund return, regulatory notification, data purge, archive); escalation matrix to CEO | FCA PS22/4 breach (inability to wind down in 5 business days); reputational/regulatory fine | COO | P1 | 🔴 OPEN (Q3 2026) |
| **GAP-059** | DORA/Incident Response (Floor 4) | banxe-emi-stack | services/incident_response/ (2 py) | Alert threshold configuration (what constitutes "critical incident"); SLA mapping (15min / 2hr / 4hr tiers); automated escalation to CEO/MLRO | Digital Operational Risk Authority (EU) + FCA: cannot enforce incident SLA without automation | CTIO | P1 | 🔴 OPEN (Q3 2026) |
| **GAP-006** | FCA Gabriel Returns (Floor 3) | banxe-emi-stack | services/reporting/ (6 py, FIN060 generator only) | FIN060a/FIN060b regurgitant return data formatting; dbt models + validation SQL (FCA-specified field order + checksums) | Monthly FCA regulatory return non-compliance; fines (PRIN1); potential withdrawal of EFT authorisation | CFO | P0 | 🟡 BLOCKED (BT-010 FCA RegData key, CEO/CFO approval required) |
| **GAP-011** | KYC Individual (Floor 3) | banxe-emi-stack | services/kyc/ (5 py, 0 tests) | Live Sumsub adapter (sandbox only active); webhook handler for KYC completion; EDD threshold logic (£10k breach); auto-escalation to MLRO | MLR 2017 compliance breach; customer onboarding blocked; regulatory fine | CTIO | P1 | 🔴 BLOCKED (BT-004 Sumsub key, CTIO approval required) |
| **GAP-013** | KYB Business (Floor 3) | banxe-emi-stack | services/kyc/ (5 py, overlap with GAP-011) | Live Companies House API adapter; ultimate beneficial owner (UBO) screening; PEP + adverse media on company officers; escalation to MLRO | Corporate account onboarding impossible; MLR 2017 breach | CTIO | P1 | 🔴 BLOCKED (BT-005 Companies House key, CTIO approval required) |
| **GAP-008** | Payment Router Agent (Floor 2) | banxe-emi-stack | services/payment/ (17 py, but Modulr adapter non-functional) | Modulr SDK activation (live vs test); rail selector logic (which customers get Modulr vs SWIFT vs FPS); fallback logic if Modulr down | Payment processing impossible for FPS (Faster Payments Service) customers; CASS 15 breakage | COO | P0 | 🔴 BLOCKED (BT-001 Modulr API key, COO approval required) |
| **GAP-074** | Issuing (Card) Capability (Floor 3) | banxe-emi-stack | services/card_issuing/ (8 py) + Hyperswitch :8096 + Paymentology | Pre-production activation of Hyperswitch + Paymentology card management; BIN lookup; PIN change flows; dispute handling; card lifecycle (activate/freeze/close) | Card programme cannot launch (297 tests passing but no sandbox credentials); CASS 15 extension into card servicing | CTIO | P1 | 🔴 BLOCKED (BT-001 Modulr + BT-006 Paymentology key, both CTIO) |
| **GAP-081** | AGPL Boundary (Floor 4) | evo1 runtime | services/fraud/ + Jube :5001 + MiroFish pipeline | Replace Jube (AGPLv3) + MiroFish (AGPL source code exposure risk) with Apache 2.0 equivalent before external partner integration (BaaS API) | AGPL viral clause forces open-source disclosure of proprietary EMI logic to competitors; cannot sign partnerships without Apache-2.0 compliance | Legal/CTO | P1 | 🔴 OPEN (must resolve before GAP-086 externalization) |

---

## §6. SPRINT ROADMAP

Active and upcoming sprint work organized by focus, deliverables, and owner. External blockers (BT-NNN API keys) are CEO/CTIO responsibility.

| Sprint | Focus | Key Deliverables | Owner | Status | Notes |
|--------|-------|------------------|-------|--------|-------|
| **4** | MLRO Independent Line (Governance) | SPRINT-4-MLRO-LINE.md (COMPLETED); passports: mlro_agent, sanctions_check, tx_monitor, jube_adapter, watchman, pep_check, edd_check (7 sub-agents PROPOSED, NOT activated) | MLRO (Sarah Mitchell) | ✅ COMPLETE | Governance-only normative doc; agents gated on I-27 HITL-L4 sign-off; STAFF-MATRIX-v2 / HITL-MATRIX.yaml untouched |
| **5** | Internal Audit Independent Line (Governance) | SPRINT-5-INTERNAL-AUDIT-LINE.md (COMPLETED); safeguarding_audit_agent.yaml (PROPOSED); annual audit contour (workpaper generation, finding lifecycle) | Audit Committee | ✅ COMPLETE | Governance-only; 3rd-line independence confirmed; read-only auditor discipline enforced; live audit execution gated on I-27 |
| **6** | CFO Deep-Build (Finance Dept-3) | SPRINT-6-CFO-DEEP-BUILD.md (COMPLETED); finance swarm (GL close, AP/AR, consolidation, IFRS, tax, beancount agents PROPOSED); accounting close governance | CFO (David Goldstein) | ✅ COMPLETE | Governance-only; Treasury/ALM in parallel session (separate); FP&A/BI deferred to Q4; live activation gated on I-27 HITL-L4 |
| **7** | COO Operations (Dept-4) | SPRINT-7-COO-DEEP-BUILD.md (COMPLETED); COO operating model (daily/weekly/monthly cadence, exception queue, escalation matrix); completes org chart Dept-4 | COO (James Hargreaves) | ✅ COMPLETE | Governance-only; org structure finalized (7 departments, 70 passports); no live activation (Phase 5 target) |
| **8** | Consolidation Prep (Phase 2) | Duplication resolution (banxe_aml_orchestrator.yaml, tx_monitor, SAR, service overlaps); API contracts signed; reconciliation gates approved by MLRO/CEO | MLRO + CTIO | 🟡 PLANNED (Q3 2026) | Phase 2 prerequisite; 6-week testing cycle for aml_orchestrator consolidation; no code changes until operator sign-off |
| **9** | P1 Delivery (External Keys Pending) | GAP-008 (FPS), GAP-011 (KYC), GAP-013 (KYB), GAP-074 (issuing), GAP-006 (RegData); all awaiting BT-001..BT-010 API keys | CTIO + COO | 🔴 BLOCKED (awaiting external credentials) | 5 external blockers (BT-NNN); CEO/CFO/CTIO approval required; cannot proceed without formal sign-off on open regulatory gaps (GAP-079..086) |
| **10** | Runtime Hardening (Phase 4) | Guardian activation (ADR-019/ADR-020); memory governance enforcement; pre-commit hook upgrade; HITL-MATRIX wiring to all agents; autonomy level enforcement (L1-L4) | CTIO + FinDev Agent | 🟡 PLANNED (Q4 2026) | Phase 4 target; Factory Guardian (qwen3.5:35b) continuous monitoring; 10-source memory pull contract validated daily; append-only enforcement on IL/GAP/constitution |
| **11-12** | Department-Head Deep-Build (Phase 5) | MLRO agents activation (sanctions, TM, Jube, Watchman, PEP, KYB, EDD); finance swarm activation (GL, AP/AR, consolidation, IFRS); audit agent activation; live execution under I-27 HITL-L4 gates | All department heads | 🟡 PLANNED (Q4 2026 – Q1 2027) | Phase 5 target; all 70 passports operational; no autonomous decisions above L2 autonomy level (humans gate SAR filing, threshold changes, PEP onboarding) |

**External Blockers (BT-NNN API Keys — CEO/CTIO Responsibility):**

| Blocker ID | Credential | Affects GAPs | Owner | Status | Priority |
|-----------|------------|------------|-------|--------|----------|
| **BT-001** | Modulr API key (production) | GAP-008 (FPS), GAP-015 (rails), GAP-074 (issuing) | COO | 🔴 PENDING | P0 |
| **BT-004** | Sumsub API key (sandbox→production) | GAP-011 (KYC individual) | CTIO | 🔴 PENDING | P1 |
| **BT-005** | Companies House API key | GAP-013 (KYB business) | CTIO | 🔴 PENDING | P1 |
| **BT-006** | Paymentology sandbox key | GAP-074 (card issuing) | CTIO | 🔴 PENDING | P1 |
| **BT-010** | FCA RegData / MyFCA key | GAP-006 (Gabriel FIN060 returns) | CEO/CFO | 🔴 PENDING | P0 |

---

## §7. CONSOLIDATION PREREQUISITES

What must be true BEFORE Phase 2 consolidation and Phase 3 single-source-of-truth can commence. Checklist format; all must reach DONE status for Phase 3 entry gate.

### A. RECONCILIATION GATES (Data Quality & Alignment)

| Reconciliation Item | Current Status | Owner | Target Completion | Blocker for Phase |
|-------------------|----------------|-------|------------------|-------------------|
| Midaz ledger ↔ safeguarding accounts ↔ rails (3-leg tie-out) | ✅ VERIFIED 2026-06-27 (GAP-087 LIVE) | Audit Committee | — (DONE) | Phase 2 (prerequisite satisfied) |
| FIN060 line-item traceability (SQL lineage: source → dbt → report field) | 🟡 PARTIAL (dbt models present, no audit trail per field) | CFO | Q3 2026 (requires BT-010 RegData key) | Phase 2 data-quality gate |
| Transaction Monitoring (vibe_tx_monitor.py vs banxe-aml/tx_monitor.py rule parity) | 🟡 PARTIAL (9 rules align but dual implementations, no test coverage cross-check) | MLRO + CTIO | Q3 2026 (requires consolidation plan sign-off) | Phase 2 deduplication gate |
| AML Orchestrator (canonical source: vibe_aml_orchestrator vs banxe agent/compliance variant) | ❌ DUPLICATE (both active, no reconciliation) | MLRO + CTIO | Phase 2 requires operator sign-off on single source + API contract | Phase 3 SSOT gate |
| ClickHouse audit trail append-only verification (no UPDATE/DELETE, TTL ≥5yr per I-08) | ✅ VERIFIED (daily Guardian scan) | Audit Committee | — (DONE) | Phase 2 (prerequisite satisfied) |
| PostgreSQL pgAudit logging (all financial transactions logged) | ✅ VERIFIED (enabled at boot, 7-day retention test passed) | CTIO | — (DONE) | Phase 2 (prerequisite satisfied) |

### B. DUPLICATE RESOLUTIONS PENDING OPERATOR SIGN-OFF

| Duplicate | Resolution Path | Approval Gate | Expected Completion | Status |
|-----------|-----------------|----------------|-------------------|--------|
| banxe_aml_orchestrator.yaml (location: EMI agent/compliance vs vibe src/compliance) | Consolidate to vibe-coding as canonical; EMI imports via HTTP API; 6-week testing cycle required | MLRO + CTIO formal sign-off (written) | Q3 2026 (post-approval) | 🔴 OPEN (awaiting formal approval) |
| tx_monitor.py rule parity (vibe vs EMI) | Reference: vibe-coding; runtime: EMI calls vibe :8093/v1/monitor endpoint; EMI maintains local cache for fault tolerance | CTIO formal approval | Q3 2026 (post-approval) | 🔴 OPEN (awaiting formal approval) |
| SAR generation (vibe_sar_generator.py vs EMI_sar_service.py) | Canonical: EMI sar_service.py (production, 24KB); vibe imports from EMI API for reference testing | MLRO formal approval | Q3 2026 (post-approval) | 🔴 OPEN (awaiting formal approval) |
| AML/KYC/fraud service overlaps (4 services on both sides) | Define API contracts per §4; EMI services become thin wrappers calling vibe :8093 endpoints; phase 2 task #A-AML-01 | CTIO formal approval | Q3 2026 (post-approval) | 🔴 OPEN (awaiting formal approval) |

### C. DOMAIN COVERAGE MINIMUMS (No Service <3 py files on Critical Path)

| Domain | Coverage Status | Files | Tests | Risk If Thin | Phase 2 Action |
|--------|-----------------|-------|-------|-------------|----------------|
| **Payment Rails** | 🟡 PARTIAL (Modulr key BT-001 pending) | 17 py (services/payment/) | 0 tests | Cannot process FPS transactions | Activate Modulr adapter post-BT-001; min 8 tests required before Phase 3 |
| **Ledger / CBS** | ✅ OPERATIONAL | 22 py (services/ledger/) | 0 tests (wrapped by safeguarding-engine tests) | Cannot post GL entries | Current: Midaz adapter wrapped; min 5 new unit tests required |
| **Reconciliation** | ✅ OPERATIONAL | 20 py (services/recon/) | 0 tests (integration-level only) | Daily CASS 15 recon breaks | Min 6 unit tests (breach detection, statement parsing) required |
| **AML Orchestration** | 🟡 PARTIAL (duplicate locations) | 4 py (services/aml/) + 30KB vibe | 0 tests | Cannot enforce AML thresholds | Post-consolidation: min 12 tests on canonical vibe_aml_orchestrator |
| **KYC / KYB** | 🔴 BLOCKED (BT-004, BT-005 keys) | 5 py (services/kyc/) | 0 tests | Cannot onboard customers | Post-key activation: min 10 tests per provider (Sumsub, Companies House) |
| **Safeguarding (CASS 15)** | ✅ OPERATIONAL | 31 py (services/safeguarding-engine/) | **10 tests** (only service with coverage) | Fund segregation breach (FCA violation) | Target: 20 tests (Phase 3 entry gate) |
| **Reporting (FIN060)** | 🟡 PARTIAL (BT-010 key pending) | 6 py (services/reporting/) + dbt models | 0 tests | FCA regulatory return non-compliance | Post-key activation: min 8 tests (field mapping, validation, PDF generation) |
| **Fraud Detection** | ✅ OPERATIONAL | 3 py + Jube :5001 (external) | 0 tests | Fraud scoring unavailable | Min 4 tests (adapter mock, alert routing) required |
| **Intent-First** | 🔴 THIN (GAP-080) | 12 py (services/intent_layer/) | 1 test | Customer UX broken; PRIN7 PS22/9 breach | Frontend build required (Q3 2026); min 15 tests post-build |
| **Audit Trail** | ✅ OPERATIONAL | Distributed (ClickHouse + pgAudit) | 0 direct tests (Oracle-level verification) | Append-only enforcement breaks | Guardian daily scan sufficient; no additional unit tests required |

### D. GOVERNANCE GATES (HITL, AUDIT, SMCR WIRING)

| Gate | Current Status | Required for Phase | Completion Target | Owner |
|------|----------------|-------------------|------------------|-------|
| **I-27 HITL-L4 Sign-Off (Agent Activation)** | ✅ Framework ready (services/hitl/, Marble UI :5003, Telegram bots @mycarmibot) | Phase 5 (dept-head agent activation) | Q4 2026 (post-Guardian activation) | MLRO |
| **SMCR Wiring (70 Passports → Live Roles)** | 🟡 PARTIAL (passports defined in STAFF-MATRIX-v3; only 12 L1-L2 heads live, 58 NOT activated) | Phase 5 (all agents go live) | Q4 2026 – Q1 2027 | CEO + HR |
| **Audit Committee Oversight (Workpapers, Evidence, Findings)** | 🟡 PARTIAL (safeguarding_audit_agent.yaml PROPOSED, not activated; GAP-058) | Phase 4 (Guardian activation) + Phase 5 (audit agent live) | Q4 2026 | Audit Committee |
| **MLRO Queue Governance (Marble integration, SLA timers)** | ✅ OPERATIONAL (Marble :5002/:5003 live, MLRO review queue active) | All phases (continuous) | — (live) | MLRO |
| **Incident SLA Enforcement (DORA / PS22/4, wind-down SLA)** | ❌ NOT AUTOMATED (GAP-057, GAP-059) | Phase 2 (planning) + Phase 4 (automation) | Q4 2026 (post-Guardian) | CTIO + COO |
| **FCA Regulatory Return Reconciliation (Gabriel, RegData)** | 🟡 BLOCKED (BT-010 key pending, GAP-006) | Phase 2 (post-credential activation) | Post-BT-010 approval (CFO/CEO) | CFO |

### E. RUNTIME EVIDENCE MINIMUMS

| Evidence Type | Current State | Phase 2 Requirement | Phase 3 Requirement |
|---------------|---------------|-------------------|-------------------|
| **Docker Compose Orchestration** | ✅ 5-service master stack operational (postgres, clickhouse, redis, frankfurter, api) | Verified health checks all pass (daily Guardian scan) | All 5 services + 4 auxiliary stacks (recon, reporting, bi, mcp) auto-start, zero manual intervention |
| **Guardian Continuous Monitoring** | ✅ Factory Guardian qwen3.5:35b online on Legion | ADR-019/ADR-020 verified (memory pull contract tested) | Project Guardian paired; dual-guardian redundancy active |
| **Model Router (ARL Tier 1-3)** | ✅ Ollama multi-model at :11434; LiteLLM router :4000 | Routing decisions logged to ClickHouse; latency SLO met (Haiku <2s, Sonnet <10s, Opus <30s) | ARL fallback chains tested (model unavailability → next tier) |
| **Quality Gate CI Pipeline** | ✅ 5-parallel jobs (ruff, biome, semgrep, pytest, vitest) | All 10 semgrep rules enforced; 0 pre-commit hook failures in 30 days | Extended to include Guardian-initiated compliance scans (append-only verification) |
| **Test Coverage** | 🟡 PARTIAL (1,931 tests, only 10 in safeguarding-engine; 98.3% coverage gap) | Min 200 new unit tests across P0 services (payment, ledger, recon, KYC, reporting) | Min 400 tests (≥80% coverage on all services) |
| **Deployment Manifest** | ❌ NOT FOUND (no K8s or systemd description of prod topology) | Service registry + deployment map (which services → which nodes on evo1/evo2) | Immutable deployment manifest (ADR-ref + locked config) |

### F. CONSOLIDATION ENTRY GATE CHECKLIST (Phase 3 → SSOT Migration)

All items below must be DONE before Phase 3 (single source of truth) can commence:

- [ ] ✅ Midaz ↔ safeguarding ↔ rails 3-leg tie-out verified (GAP-087 LIVE)
- [ ] ✅ ClickHouse append-only enforcement verified (I-24 / I-08)
- [ ] ✅ PostgreSQL pgAudit logging enabled
- [ ] ✅ Keycloak :8180 authentication operational
- [ ] ✅ Docker Compose master stack health verified (5 services)
- [ ] 🔴 **OPERATOR SIGN-OFF:** Written approval on all 4 duplication resolutions (banxe_aml_orchestrator, tx_monitor, SAR, AML/KYC/fraud overlaps) — **REQUIRED BEFORE PHASE 2 ENDS**
- [ ] 🔴 **MLRO/CEO SIGN-OFF:** FCA regulatory gaps (GAP-079, GAP-080, GAP-082, GAP-083, GAP-085) — remediation plan or acceptance of residual risk — **REQUIRED BEFORE PHASE 2 ENDS**
- [ ] 🔴 **CTIO/CEO SIGN-OFF:** External blockers (BT-001..BT-010 API keys) — approval to proceed with P1 GAPs or acknowledgment of delay — **REQUIRED BEFORE PHASE 3 START**
- [ ] 🟡 **Test Coverage Floor:** Minimum 200 new unit tests across P0 services (payment, ledger, recon, KYC, reporting) — **TARGET: END Q3 2026 (Phase 2 exit gate)**
- [ ] 🟡 **Service Thin Coverage:** All P0 critical services ≥5 py files + ≥3 unit tests (exception: services with mature safeguarding wrapper) — **TARGET: END Q3 2026**
- [ ] 🟡 **Deployment Manifest:** Service registry + evo1/evo2 node assignment documented — **TARGET: END Q3 2026**
- [ ] 🟡 **Guardian Activation (Phase 4 prerequisite):** ADR-019/ADR-020 memory pull contract tested; daily append-only scan operational — **TARGET: Q4 2026**

---

**Document Status:** Append-only (I-24 enforced). All sections completed 2026-07-02. Next review: Phase 2 completion (Q3 2026). No edits; new findings → new section appended.
