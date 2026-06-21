# BANXE EMI — Gap Register & Sprint Assignment
> **Scope:** Operational EMI sprint GAPs (GAP-NNN format) tracking FCA Authorisation Blockers, Sprint Assignment, GapTrackerAgent enforcement.
> **Counterpart:** Repository root `GAP-REGISTER.md` tracks **architecture-level canon** GAPs (G-FACTORY-*, G-PROJECT-*, G-SECURITY-*, etc).
> **Per Sprint S5 F4 reconciliation 2026-05-09:** Two GAP-REGISTER.md files coexist with distinct purposes. Не duplicate. See IL-OPS-SPRINT-S5-F4-DOCUMENTATION-RECONCILIATION-2026-05-09.

> **Status:** MANDATORY — enforced by GapTrackerAgent
> **Last Audit:** 2026-06-18 (SP-10: +GAP-056..059)
> **Enforcer:** `agents/passports/gap_tracker_agent.yaml`
> **Rule:** Every session MUST begin by running `python3 scripts/gap-tracker.py --status`
>           Even if work diverges, return to this list before closing session.

---

## 🔴 P0 — FCA Authorisation Blockers (Hard Deadlines)

| ID | Gap | Sprint | Owner | Deadline | Status |
|---|---|---|---|---|---|
| GAP-001 | Appoint MLRO (SMF17) — Sarah Mitchell appointed 2026-04-13 | — | CEO | **NOW** | ✅ DONE |
| GAP-002 | Appoint CFO (SMF2) — David Goldstein appointed 2026-04-13 | — | CEO | **NOW** | ✅ DONE |
| GAP-003 | J-engine: Safeguarding Engine CASS 15 (zero implementation) | Sprint 12 | CTIO | **7 May 2026** | ✅ DONE |
| GAP-004 | J-audit: ClickHouse safeguarding audit trail | Sprint 12 | CTIO | **7 May 2026** | ✅ DONE |
| GAP-005 | E-safeguard: Segregated client accounts daily recon | Sprint 12 | CEO+CTIO | **7 May 2026** | 🟡 IN PROGRESS |
| GAP-006 | K-gabriel: FCA Gabriel/RegData returns | Sprint 13 | CEO | Q2 2026 | 🟡 IN PROGRESS |
| GAP-007 | F-finrpt: FCA regulatory returns (FIN-RPT) — IN PROGRESS 2026-06-21 — code services/regulatory_reporting (7 .py, ~7 tests); residual: FIN-RPT live submission needs FCA RegData key (BT-010) | Sprint 13 | CEO | Q2 2026 | 🔄 IN PROGRESS |
| GAP-008 | Activate PaymentRouterAgent — get Modulr API key (BT-001) | Sprint 12 | COO | Sprint 12 | ❌ BLOCKED |

---

## 🟡 P1 — Core Banking Must-Have

| ID | Gap | Sprint | Owner | Status |
|---|---|---|---|---|
| GAP-009 | Appoint CRO (SMF4) — Elena Vasilenko appointed 2026-04-13 | — | CEO | ✅ DONE |
| GAP-010 | D-recon: Reconciliation Engine (OVERDUE — was Sprint 9) | Sprint 12 | CTIO | ✅ DONE |
| GAP-011 | A-kyc: KYC individual — get Sumsub API key (BT-004) | Sprint 12 | CTIO | ❌ BLOCKED |
| GAP-012 | A-idv: IDV pipeline (OCR + biometric) — IN PROGRESS 2026-06-21 — code services/kyc (6 .py, ~41 tests); residual: live IDV OCR/biometric needs Sumsub key (BT-004) | Sprint 12 | CTIO | 🔄 IN PROGRESS |
| GAP-013 | A-kyb: KYB business — get Companies House API key (BT-005) | Sprint 13 | CTIO | ❌ BLOCKED |
| GAP-014 | B-emi: EMI product definitions (e-money, cards, IBAN) | Sprint 12 | CEO | ✅ DONE |
| GAP-015 | C-fps: UK Faster Payments FPS (needs Modulr) | Sprint 12 | CTIO | ❌ BLOCKED |
| GAP-016 | C-sepa: SEPA CT + SEPA Instant (code CT+Instant DONE in banxe-emi-stack; residual: Channel C orchestration governance) | Sprint 13 | CTIO | 🔄 IN PROGRESS |
| GAP-017 | D-gl: General Ledger — complete GL reconciliation (5% done) | Sprint 12 | CTIO | ✅ DONE |
| GAP-018 | D-fin: Financial Reporting (P&L, balance sheet) — IN PROGRESS 2026-06-21 — code services/reporting_analytics (10 .py, ~12 tests); P&L/BS report code present | Sprint 12 | CEO | 🔄 IN PROGRESS |
| GAP-019 | D-fee: Fee Engine & billing | Sprint 12 | CTIO | ✅ DONE |
| GAP-020 | E-capital: FCA ICARA capital adequacy — IN PROGRESS 2026-06-21 — code services/risk_management (8 .py); ICARA capital logic present | Sprint 16 | CEO | Q3 2026 | 🔄 IN PROGRESS |
| GAP-021 | G-rt: Real-time fraud scoring (Jube ML model) — IN PROGRESS 2026-06-21 — code services/fraud (6 .py, ~13 tests) + services/crypto_aml_graph (IMPL-2); residual: Jube live needs admin pw | Sprint 13 | CTIO | 🔄 IN PROGRESS |
| GAP-022 | G-device: Device fingerprinting, velocity checks — IN PROGRESS 2026-06-21 — code services/device_fingerprint (7 .py); device/velocity code present | Sprint 13 | CTIO | 🔄 IN PROGRESS |
| GAP-023 | I-api: API Gateway — developer-facing endpoints | Sprint 12 | CTIO | ✅ DONE |
| GAP-024 | K-fscs: FSCS reporting — SP-THIN 2026-06-21 → L2: services/resolution/fscs_scv.py (FSCS Single Customer View, PRA SS18/15; £85k cap + eligibility) + tests/test_fscs_scv.py (emi-stack PR #205); residual: live FSCS SCV submission deferred to production | Sprint 16 | CEO | Q3 2026 | 🔄 IN PROGRESS |
| GAP-025 | K-nca: NCA SARs automated filing — IN PROGRESS 2026-06-21 — code services/sanctions_screening (8 .py, ~13 tests); NCA SARs filing code; live needs NCA channel | Sprint 13 | CTIO | 🔄 IN PROGRESS |
| GAP-056 | DPO appointment + DPIA framework (UK GDPR Art.37-39, DSAR) — IN PROGRESS 2026-06-21 — code services/consent_management (7 .py, ~16 tests); DPO/DPIA/DSAR consent code present | Sprint 13 | CEO | 🔄 IN PROGRESS |
| GAP-057 | Wind-Down Planning (FCA Approach Doc 2026; run-off scenarios) — SP-THIN 2026-06-21 → L2: services/resolution/wind_down_plan.py (FCA WDPG triggers + runway + steps) + tests/test_wind_down_plan.py (emi-stack PR #205); residual: ICARA-calibrated thresholds at production | Sprint 14 | CFO+Board | 🔄 IN PROGRESS |
| GAP-058 | Annual Safeguarding Audit (PS25/12; relevant funds >£100k) — SP-THIN 2026-06-21 → L2: src/safeguarding/annual_audit.py (Annual Safeguarding Audit, EMR 2011 reg.21; opinion from daily recon) + tests/test_annual_safeguarding_audit.py (emi-stack PR #205) | Sprint 13 | Internal Audit | 🔄 IN PROGRESS |
| GAP-059 | Operational Resilience / DORA (DR/BCP, incident response) — SP-THIN 2026-06-21 → L2: services/incident_response/dora_continuity.py (DORA DR/BCP RTO/RPO + major-incident classification) + tests/test_dora_continuity.py (emi-stack PR #205); residual: live DORA reporting channel deferred | Sprint 14 | CTIO+COO | 🔄 IN PROGRESS |
| GAP-064 | A-edd: Adverse-media screening (MLR 2017 Reg.28 EDD; negative-news entity match into Ballerine/Marble EDD flow) | Sprint 13 | MLRO+CTIO | Q2 2026 | 🟡 IN PROGRESS |
| GAP-065 | crypto-ops-monitor Python platform (ADR-109 supersedes stale NestJS spec; SP-CO2 hardening in repo) | Sprint 14 | CTIO | Q3 2026 | 🟡 IN PROGRESS |
| GAP-066 | braslina merchant-onboarding service registration (ADR-110; standalone repo, partial KYB GAP-013; port note n8n 5680) | Sprint 14 | CTIO+MLRO | Q3 2026 | 🟡 IN PROGRESS |
| GAP-067 | OSS supply-chain & license governance (SBOM+SCA+license-audit+third-party register; AGPL/SSPL/BSL/Fair-code tiers) | Sprint 15 | CTIO+Compliance | Q3 2026 | 🟡 IN PROGRESS |
| GAP-068 | Crypto-AML graph-analytics (ADR-111; GraphSense+Neo4j clustering, GraphSAGE/Elliptic ML, blacklist feeds; extends GAP-021/022/025) | Sprint 15 | CTIO+MLRO | Q3 2026 | 🟡 IN PROGRESS |
| GAP-069 | Voice AI support channel (ADR-112; LiveKit/Pipecat/Whisper/TTS, reuse Presidio+Chatwoot; compliance-heavy: recording/retention/audio-PII) | Sprint 16 | COO+Compliance | Q3 2026 | 🟡 IN PROGRESS |
| GAP-070 | Quant pricing/risk advisory engine (ADR-113; Heston/SABR/Bates + Avellaneda MM + Greeks/VaR; advisory-seam, no live exec; reuses QuantLib+DSE+ADR-079) | Sprint 16 | CTIO+CRO | Q4 2026 | 🟡 IN PROGRESS |
| GAP-071 | Payment distribution model — Tompay+Paybis, Neuronext superseded (ADR-108 **ACCEPTED 2026-06-20**; open-items resolved: settlement=Paybis via Tompay GBP IBAN + Papaya EUR-SEPA, custody=NON-CUSTODIAL; residual: Paybis go-live, CASP T&C by 2026-07-01, Travel Rule) | Sprint 14 | CEO+CTIO | Q3 2026 | 🟡 IN PROGRESS |
| GAP-072 | Travel Rule responsibility (ADR-114; Paybis CASP = TR-provider option-a + BANXE MLRO oversight option-b; resolves ADR-036 gate) | Sprint 14 | MLRO+CTIO | Q3 2026 | 🟡 IN PROGRESS |
| GAP-073 | Execution channel ACCEPTED — Channel C = Ruflo factory (ADR-106; launch start-ruflo.sh, scope arch-stack-002); Claude-Code-via-factory UNBLOCKED | Sprint 14 | CEO+CTIO | NOW | ✅ DONE |
| GAP-074 | Acquiring/issuing registration — banxe-payment-core (Hyperswitch :8096-8098 + Paymentology issuer + Midaz :8095 + IPM settlement) per ADR-015; code DONE + 297 tests green, registered in SAD §3.7; go-live BLOCKED on Modulr key BT-001 + Paymentology sandbox key | Sprint 14 | CTIO | Q3 2026 | ❌ BLOCKED |
| GAP-075 | Feature-installation audit — 3-level model (L1/L2/L3) + roadmap AU-1..AU-7 for GAP-064..074; **verdicts recorded 2026-06-20**: code-installed L2/L3=4, governance-only=3, implementation-delta=4; read-only, no code changes | Sprint 14 | CTIO | Q3 2026 | ✅ DONE |
| GAP-076 | Implementation roadmap L1→L3 for the 4 ADR-without-code features (IMPL-1 adverse-media/GAP-064, IMPL-2 crypto-AML-graph/GAP-068, IMPL-3 voice-AI/GAP-069, IMPL-4 quant/GAP-070); regulatory priority IMPL-1 first (MLR Reg.28 EDD); code lands in banxe-emi-stack; roadmap doc only (impls not executed here) | Sprint 14 | CTIO | Q3 2026 | 📋 PLANNED — **reconcile 2026-06-21:** IMPL-1..4 complete at L2; full-project audit (FULL-PROJECT-INSTALLATION-AUDIT-2026-06-21) finds ~76% L2, all 13 OPEN GAPs have code (stale statuses); remaining = SP-RECON/SP-THIN/SP-L3DOC, not large code gaps |
| GAP-077 | Canonical Org Freeze (Sprint-1) — mandatory department-head + independent-line agents NOT yet built (PROPOSED passports deferred to Sprint 2): ceo_orchestration_agent, board_reporting_agent, internal_audit_agent, risk_oversight_agent, compliance-monitoring head, cfo_orchestration_agent, coo_operations_agent, cto_platform_agent, front_office_agent, legal_corporate_agent. Org structure FROZEN in governance/CANONICAL-ORG-CHART-v2.md; MLRO de-duplicated as independent line; owners fixed for DPO/Wind-Down/Safeguarding-Audit/DORA — **Sprint-2 DONE 2026-06-21:** governance/STAFF-MATRIX-v1.md normative; 10 PROPOSED dept-head passport stubs created; head→L3/L4→human_double→service mapped. Service-impl → GAP-078 (Sprint 3) | Sprint 2 | CEO | Q3 2026 | ✅ DONE |
| GAP-078 | Sprint-3 — implement service code + activation for the 10 PROPOSED department-head agents (governance/STAFF-MATRIX-v1.md): code, org_roles.py wiring, HITL gates, PROPOSED→active. No service code built in Sprint 2 | Sprint 3 | CEO | Q3 2026 | PLANNED |

---

## 🟠 P1 — HR Roles (functional, non-SMF)

| ID | Gap | Sprint | Owner | Status |
|---|---|---|---|---|
| GAP-026 | Hire Financial Controller — Rachel Cohen appointed 2026-04-13 | Sprint 13 | CEO | ✅ DONE |
| GAP-027 | Hire Head of FP&A — Nikolai Petrov appointed 2026-04-13 | Sprint 14 | CEO | ✅ DONE |
| GAP-028 | Hire Head of Treasury — Marcus Webb appointed 2026-04-13 | Sprint 14 | CEO | ✅ DONE |
| GAP-029 | Hire Head of Reg Reporting — Priya Sharma appointed 2026-04-13 | Sprint 13 | CEO | ✅ DONE |
| GAP-030 | Hire Compliance Officer (EDD sign-off) — Aisha Okonkwo appointed 2026-04-13 | Sprint 12 | CEO | ✅ DONE |
| GAP-031 | Hire Head of Customer Support — Tom Nakamura appointed 2026-04-13 | Sprint 14 | CEO | ✅ DONE |
| GAP-032 | Assign Legal Counsel — Laura Bennett appointed 2026-04-13 | Sprint 13 | CEO | ✅ DONE |
| GAP-033 | Engage External Auditor (CASS 10A) — Grant Thornton UK appointed 2026-04-13 | Sprint 13 | CEO | ✅ DONE |

---

## 🔵 P2 — Operational

| ID | Gap | Sprint | Owner | Status |
|---|---|---|---|---|
| GAP-034 | B-pricing: Pricing rules, fee schedules (code DONE in banxe-emi-stack services/fee_management + router + tests, GAP-019; residual: pricing governance) | Sprint 13 | CEO | 🔄 IN PROGRESS |
| GAP-035 | C-swift: SWIFT MT/MX (code DONE in banxe-emi-stack services/swift_correspondent, ADR-013; residual: Channel C orchestration governance) | Sprint 14 | CTIO | 🔄 IN PROGRESS |
| GAP-036 | E-treasury: Treasury / FX / ALM — services/treasury+fx implemented (code repo, IL-097/099); residual here = ALM orchestration + PROPOSED passport (OSEM/QuantLib, covenant monitor) | Sprint 14 | CEO | ⚠️ IN PROGRESS |
| GAP-037 | F-fatca: FATCA/CRS tax reporting (code DONE in banxe-emi-stack services/fatca_crs: self_cert_engine, hmrc_models, fatca_agent; residual: reporting governance) | Sprint 13 | CEO | 🔄 IN PROGRESS |
| GAP-038 | H-crm: CRM + DSAR (CRM code in banxe-emi-stack services/crm; residual: DSAR/consent/retention governance) | Sprint 14 | CEO | 🔄 IN PROGRESS |
| GAP-039 | H-support: Support ticketing + SLA | Sprint 14 | CEO | 🔄 IN PROGRESS |
| GAP-040 | L-lake: ClickHouse Data Lake — schema/audit layer DONE; residual = ELT/streaming/lineage (FA-03 dbt, FA-19 Airbyte, FA-10/15 Debezium+Kafka, FA-18 OpenMetadata, FA-20 Airflow) | Sprint 12 | CTIO | ⚠️ IN PROGRESS |
| GAP-041 | M-gateway: Public REST API + OpenAPI spec (gateway infra DONE in banxe-emi-stack services/api_gateway, GAP-023; residual: unified Public-API governance) | Sprint 14 | CTIO | 🔄 IN PROGRESS |
| GAP-042 | M-sandbox: Sandbox + mock payment rails | Sprint 14 | CTIO | 🔄 IN PROGRESS |

---

## ⚪ P3 — Backlog

| ID | Gap | Sprint | Owner | Status |
|---|---|---|---|---|
| GAP-043 | L-bi: BI/Dashboards (Superset/Metabase) | Sprint 15 | CTIO | 🔄 IN PROGRESS |
| GAP-044 | M-sdk: Python + JS client SDK | Sprint 16 | CTIO | 🔄 IN PROGRESS |
| GAP-045 | B-pricing tier 2 expansion — IN PROGRESS 2026-06-21 — code services/fee_management (8 .py, ~25 tests); pricing tier-2 code present | Sprint 15 | CEO | 🔄 IN PROGRESS |

---

## AI Agents — PROPOSED (not yet active)

| ID | Agent | Blocker | Sprint |
|---|---|---|---|
| GAP-046 | PaymentRouterAgent | BT-001 (Modulr key) | Sprint 12 |
| GAP-047 | CustomerLifecycleAgent | S17-01/S17-09 | Sprint 13 |
| GAP-048 | AgreementAgent | S17-02 | Sprint 13 |
| GAP-049 | ReportingAgent | BT-010 (RegData key) | Sprint 13 |
| GAP-050 | RiskOversightAgent | CRO not appointed | Sprint 13 |
| GAP-051 | SafeguardingAgent (complete) | J-engine | Sprint 12 |
| GAP-052 | FPAAgent + ForecastAgent | — | Sprint 14 |
| GAP-053 | TreasuryAgent | — | Sprint 14 |
| GAP-054 | DeployAgent | — | Sprint 14 |
| GAP-055 | MLPipelineAgent | CRO gate | Sprint 15 |

---

## Sprint Assignment Summary

| Sprint | P0 Items | P1 Items | Focus |
|---|---|---|---|
| **Sprint 12** (NOW) | GAP-003,004,005,008 | GAP-010,011,014,015,017,019,023,051 | Safeguarding + Payments |
| **Sprint 13** | GAP-006,007 | GAP-013,016,021,022,025,026,029,030,032,033 | FCA Returns + Fraud + Hiring |
| **Sprint 14** | — | GAP-020,024 | Treasury + CRM + SDK |
| **Sprint 15+** | — | — | BI + SDK + Backlog |

> **Invariant:** GAP-001 (MLRO) and GAP-002 (CFO) must be resolved BEFORE Sprint 13 closes.
> Without SMF17 + SMF2, FCA authorisation cannot proceed.

---

*Enforced by: GapTrackerAgent | Last updated: 2026-04-13 | IL-GAP-001*
