# BANXE EMI — Gap Register & Sprint Assignment

> **Status:** MANDATORY — enforced by GapTrackerAgent
> **Last Audit:** 2026-04-13
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
| GAP-005 | E-safeguard: Segregated client accounts daily recon | Sprint 12 | CEO+CTIO | **7 May 2026** | ❌ OPEN |
| GAP-006 | K-gabriel: FCA Gabriel/RegData returns | Sprint 13 | CEO | Q2 2026 | ❌ OPEN |
| GAP-007 | F-finrpt: FCA regulatory returns (FIN-RPT) | Sprint 13 | CEO | Q2 2026 | ❌ OPEN |
| GAP-008 | Activate PaymentRouterAgent — get Modulr API key (BT-001) | Sprint 12 | COO | Sprint 12 | ❌ BLOCKED |

---

## 🟡 P1 — Core Banking Must-Have

| ID | Gap | Sprint | Owner | Status |
|---|---|---|---|---|
| GAP-009 | Appoint CRO (SMF4) — Elena Vasilenko appointed 2026-04-13 | — | CEO | ✅ DONE |
| GAP-010 | D-recon: Reconciliation Engine (OVERDUE — was Sprint 9) | Sprint 12 | CTIO | ❌ OVERDUE |
| GAP-011 | A-kyc: KYC individual — get Sumsub API key (BT-004) | Sprint 12 | CTIO | ❌ BLOCKED |
| GAP-012 | A-idv: IDV pipeline (OCR + biometric) | Sprint 12 | CTIO | ❌ OPEN |
| GAP-013 | A-kyb: KYB business — get Companies House API key (BT-005) | Sprint 13 | CTIO | ❌ BLOCKED |
| GAP-014 | B-emi: EMI product definitions (e-money, cards, IBAN) | Sprint 12 | CEO | ❌ OPEN |
| GAP-015 | C-fps: UK Faster Payments FPS (needs Modulr) | Sprint 12 | CTIO | ❌ BLOCKED |
| GAP-016 | C-sepa: SEPA CT + SEPA Instant | Sprint 13 | CTIO | ❌ OPEN |
| GAP-017 | D-gl: General Ledger — complete GL reconciliation (5% done) | Sprint 12 | CTIO | ⚠️ IN PROGRESS |
| GAP-018 | D-fin: Financial Reporting (P&L, balance sheet) | Sprint 12 | CEO | ❌ OPEN |
| GAP-019 | D-fee: Fee Engine & billing | Sprint 12 | CTIO | ❌ OPEN |
| GAP-020 | E-capital: FCA ICARA capital adequacy | Sprint 16 | CEO | Q3 2026 | ❌ OPEN |
| GAP-021 | G-rt: Real-time fraud scoring (Jube ML model) | Sprint 13 | CTIO | ❌ OPEN |
| GAP-022 | G-device: Device fingerprinting, velocity checks | Sprint 13 | CTIO | ❌ OPEN |
| GAP-023 | I-api: API Gateway — developer-facing endpoints | Sprint 12 | CTIO | ❌ OPEN |
| GAP-024 | K-fscs: FSCS reporting | Sprint 16 | CEO | Q3 2026 | ❌ OPEN |
| GAP-025 | K-nca: NCA SARs automated filing | Sprint 13 | CTIO | ❌ OPEN |

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
| GAP-034 | B-pricing: Pricing rules, fee schedules | Sprint 13 | CEO | ❌ OPEN |
| GAP-035 | C-swift: SWIFT MT/MX | Sprint 14 | CTIO | ❌ OPEN |
| GAP-036 | E-treasury: Treasury / FX / ALM | Sprint 14 | CEO | ❌ OPEN |
| GAP-037 | F-fatca: FATCA/CRS tax reporting | Sprint 13 | CEO | ❌ OPEN |
| GAP-038 | H-crm: CRM + DSAR | Sprint 14 | CEO | ❌ OPEN |
| GAP-039 | H-support: Support ticketing + SLA | Sprint 14 | CEO | ❌ OPEN |
| GAP-040 | L-lake: ClickHouse Data Lake (30% done → 100%) | Sprint 12 | CTIO | ⚠️ IN PROGRESS |
| GAP-041 | M-gateway: Public REST API + OpenAPI spec | Sprint 14 | CTIO | ❌ OPEN |
| GAP-042 | M-sandbox: Sandbox + mock payment rails | Sprint 14 | CTIO | ❌ OPEN |

---

## ⚪ P3 — Backlog

| ID | Gap | Sprint | Owner | Status |
|---|---|---|---|---|
| GAP-043 | L-bi: BI/Dashboards (Superset/Metabase) | Sprint 15 | CTIO | ❌ OPEN |
| GAP-044 | M-sdk: Python + JS client SDK | Sprint 16 | CTIO | ❌ OPEN |
| GAP-045 | B-pricing tier 2 expansion | Sprint 15 | CEO | ❌ OPEN |

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
