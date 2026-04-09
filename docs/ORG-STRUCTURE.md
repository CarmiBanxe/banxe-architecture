# ORG-STRUCTURE.md — Banxe AI Bank Organisational Structure
> IL-065 | Developer Plane | banxe-architecture
> Created: 2026-04-09 | Author: Claude Code
>
> **Purpose**: Canonical org structure — agent roles, human doubles, HITL gates, SM&CR mapping.
> Machine-readable version: `../HITL-MATRIX.yaml`
> Enforcement layer: `banxe-emi-stack/services/hitl/org_roles.py`

---

## 1. Organisational Chart

```
Board of Directors
└── CEO (SMF1, Moriel Carmi)
    ├── CRO — Chief Risk Officer (SMF4)
    │   ├── 1st Line: Operational Risk
    │   └── AI Risk Oversight (EU AI Act Art.22)
    ├── MLRO — Money Laundering Reporting Officer (SMF17)
    │   ├── AML Analyst (AI agent)
    │   ├── Sanctions Screening (AI agent)
    │   └── SAR Filing (MLRO-only, non-delegable)
    ├── Internal Audit (SMF5)
    ├── CFO — Chief Financial Officer (SMF2)
    │   ├── Controlling
    │   ├── FP&A
    │   ├── Treasury
    │   ├── Regulatory Reporting (FIN060, RegData)
    │   └── BI / Management Information
    ├── COO — Chief Operating Officer (SMF24)
    │   ├── Payments Operations
    │   ├── Safeguarding (FCA CASS 7)
    │   └── Customer Operations
    ├── CTO / AI Platform (SMF26)
    │   ├── Data & ML Engineering
    │   ├── Infrastructure / DevOps
    │   ├── Integrations (Modulr, Ballerine, Jube, Marble)
    │   └── Security / IAM (Keycloak)
    ├── Front Office
    │   ├── Sales
    │   ├── Marketing
    │   └── Customer Success
    └── HR / Legal / Compliance Admin
```

---

## 2. Functional Blocks

### 2.1 Board / CEO (SMF1)

| Attribute | Value |
|-----------|-------|
| **FCA Role** | SMF1 — CEO |
| **Incumbent** | Moriel Carmi (@bereg2022) |
| **Scope** | Ultimate accountability for FCA authorisation |
| **AI Agent** | None (Board/CEO = human-only tier) |
| **HITL Gate** | New product launch, FCA correspondence >material, SAR retraction, AML threshold changes, PEP approvals |
| **EU AI Act** | Art.22: overall responsible person for high-risk AI systems |
| **SM&CR Duty** | All SMF holders report to CEO; CEO chairs ALCO and Risk Committee |

**Decision authorities (non-delegable to AI):**
- Authorisation variations with FCA
- PEP onboarding sign-off (together with MLRO)
- SAR retraction (together with MLRO)
- AML/fraud threshold changes (together with CRO)
- Security incidents rated CRITICAL

---

### 2.2 CRO — Chief Risk Officer (SMF4)

| Attribute | Value |
|-----------|-------|
| **FCA Role** | SMF4 — Risk function |
| **Scope** | 1st-line operational risk + AI risk governance |
| **AI Agent** | `RiskOversightAgent` (PROPOSED) |
| **Human Double** | CRO (or delegated Risk Manager) |
| **Trust Zone** | 🔴 RED |
| **Autonomy** | L3 — CRO sign-off required |
| **EU AI Act** | Art.9: risk management system for high-risk AI; Art.14: meaningful human oversight |

**Responsibilities:**
- AI model risk assessment before production deployment
- Threshold approval for fraud/AML models (jointly with CEO)
- Consumer Duty PS22/9 fair outcomes monitoring
- 1st Line of Defence — escalates to Board on material risk

**Agent table:**
| Agent | Task | Autonomy | CRO gate? |
|-------|------|----------|-----------|
| `FraudScoringAgent` | Fraud risk score | L1 Auto | No (monitoring only) |
| `AMLPipelineAgent` | Transaction monitoring | L2 Review | On threshold change |
| `ConsumerDutyAgent` | PS22/9 outcomes | L2 Review | Quarterly review |
| `RiskOversightAgent` | Risk dashboard | L1 Auto | No |

---

### 2.3 MLRO — Money Laundering Reporting Officer (SMF17)

| Attribute | Value |
|-----------|-------|
| **FCA Role** | SMF17 — MLRO (FCA Approved Person) |
| **Legal Basis** | POCA 2002 s.330, MLR 2017, SAMLA 2018 |
| **SAR Channel** | NCA / UKFIU via FCA Connect (MLRO-only authority) |
| **AI Agents** | `AML-Analyst-v1`, `SanctionsScreeningAgent`, `ComplianceOfficerAgent` |
| **Human Double** | MLRO (non-delegable for SAR filing, PEP approval, SAR retraction) |
| **Trust Zone** | 🔴 RED |
| **Autonomy** | L3 MLRO — mandatory human gate |
| **SLA (SAR)** | 4 hours (POCA 2002 promptness requirement) |
| **SLA (EDD)** | 24 hours (MLR 2017 Reg.28) |

**Non-delegable duties (MLRO only — AI may assist but human must decide):**
1. SAR filing to NCA/UKFIU
2. SAR retraction (with CEO)
3. PEP enhanced due diligence sign-off
4. Sanctions BLOCK reversal (with CEO)
5. Customer BLOCK for AML reasons
6. Annual MLRO Report to Board

**Agent table:**
| Agent | Task | Autonomy | MLRO gate? |
|-------|------|----------|------------|
| `AML-Analyst-v1` | Transaction monitoring + risk scoring | L2 | Yes — on SAR_REQUIRED |
| `SanctionsScreeningAgent` | OFAC/HMT/UN watchlist | L1 Auto | Block auto; reversal → MLRO |
| `ComplianceOfficerAgent` | CDD/EDD decisions | L2 | Yes — EDD sign-off |
| `KYC-Specialist-v2` | Customer onboarding | L2 | On HIGH/PROHIBITED |

---

### 2.4 Internal Audit (SMF5)

| Attribute | Value |
|-----------|-------|
| **FCA Role** | SMF5 — Internal Audit function |
| **Scope** | Independent assurance — 3rd Line of Defence |
| **AI Agent** | `AuditTrailAgent` (read-only access to ClickHouse) |
| **Human Double** | Internal Auditor (or outsourced to Big-4) |
| **Trust Zone** | 🟢 GREEN (read-only) |
| **Autonomy** | L1 Auto (read-only); L4 Board for audit findings |

**Responsibilities:**
- Quarterly audit of HITL decision quality (approval rates, SLA breaches)
- Annual AI model governance audit (EU AI Act Art.17 logging)
- FCA SYSC 4 internal control review
- ClickHouse audit trail verification (I-21: 5-year TTL)

---

### 2.5 CFO — Chief Financial Officer (SMF2)

| Attribute | Value |
|-----------|-------|
| **FCA Role** | SMF2 — Finance function |
| **Scope** | Financial control, FCA regulatory returns, treasury, BI |
| **Trust Zone** | 🔴 RED (regulatory submissions) |
| **Autonomy** | L3 — CFO gate for FCA submissions |

#### 2.5.1 Controlling

| Agent | Task | Autonomy |
|-------|------|----------|
| `LedgerAgent` | Double-entry posting via MidazAdapter | L2 Review |
| `ReconciliationAgent` | Daily P&L recon | L2 Review |

CFO must approve any ledger adjustment >£10,000.

#### 2.5.2 FP&A

| Agent | Task | Autonomy |
|-------|------|----------|
| `FPAAgent` (PROPOSED) | Budget vs actuals reporting | L1 Auto |
| `ForecastAgent` (PROPOSED) | Liquidity forecasting | L2 Review |

#### 2.5.3 Treasury

| Agent | Task | Autonomy |
|-------|------|----------|
| `TreasuryAgent` (PROPOSED) | NOSTRO reconciliation, FX exposure | L2 Review |

Treasury decisions >£100k require CFO sign-off.

#### 2.5.4 Regulatory Reporting

| Agent | Task | Autonomy | Gate |
|-------|------|----------|------|
| `ReportingAgent` | FIN060 monthly safeguarding return | L3 | CFO must sign |
| `RegDataAgent` | FCA Gabriel/RegData submission | L3 | CFO must submit |
| `SARStatsAgent` | Annual SAR statistics | L3 | MLRO + CFO |

**FCA RegData submission is non-delegable to AI — CFO must click submit.**

#### 2.5.5 Business Intelligence

| Agent | Task | Autonomy |
|-------|------|----------|
| `BIAgent` (PROPOSED) | Dashboard generation, KPI alerts | L1 Auto |

---

### 2.6 COO — Chief Operating Officer (SMF24)

| Attribute | Value |
|-----------|-------|
| **FCA Role** | SMF24 — Operations |
| **Scope** | Payments rails, safeguarding, customer operations |
| **Trust Zone** | 🔴 RED (safeguarding) / 🟡 AMBER (ops) |

#### 2.6.1 Payments Operations

| Agent | Task | Autonomy | Gate |
|-------|------|----------|------|
| `PaymentRouterAgent` | FPS/SEPA/CHAPS routing | L1 Auto | — |
| `PaymentRouterAgent` | Payment >£50k | L2 Review | COO/CFO |
| `MassPaymentAgent` | Bulk payroll | L2 Review | CFO |
| `ChargebackAgent` (PROPOSED) | Dispute handling | L2 Review | COO |

**PSR 2017 Reg.71:** Strong auth required >£30 (automated, no HITL).

#### 2.6.2 Safeguarding (FCA CASS 7)

| Agent | Task | Autonomy | Gate |
|-------|------|----------|------|
| `SafeguardingAgent` | Daily recon (internal vs external bank) | L1 Auto | — |
| `BreachDetector` | Discrepancy streak >3 days | L3 | MLRO + CFO |
| `FIN060Generator` | Monthly FCA return | L3 | CFO signs |
| `ResolutionPackAgent` | CASS 10A 48h retrieval pack | L3 | CFO + MLRO |

**Safeguarding shortfall: automatic FCA alert — no AI authorised to suppress.**

#### 2.6.3 Customer Operations

| Agent | Task | Autonomy | Gate |
|-------|------|----------|------|
| `CustomerLifecycleAgent` | Onboarding → offboarding | L2 Review | COO on block |
| `CustomerSupportAgent` | Ticket routing, FAQ | L1 Auto | — |
| `ChurnPredictionAgent` (PROPOSED) | At-risk customer alerts | L1 Auto | — |

---

### 2.7 CTO / AI Platform (SMF26)

| Attribute | Value |
|-----------|-------|
| **FCA Role** | SMF26 — Technology function |
| **Scope** | AI platform, infra, integrations, security/IAM |
| **AI Agents** | All technical platform agents |
| **Trust Zone** | 🔴 RED (security) / 🟡 AMBER (platform) |

#### 2.7.1 Data & ML Engineering

| Agent | Task | Autonomy | Gate |
|-------|------|----------|------|
| `MLPipelineAgent` (PROPOSED) | Model retraining proposals | L3 | CRO + CTO |
| `FeedbackLoopAnalyser` | Threshold proposals (I-27) | L3 | CRO must approve |
| `DataQualityAgent` (PROPOSED) | Data drift detection | L1 Auto | — |

**I-27: No autonomous model updates. All changes require CRO sign-off.**

#### 2.7.2 Infrastructure / DevOps

| Agent | Task | Autonomy | Gate |
|-------|------|----------|------|
| `DeployAgent` (PROPOSED) | Staging deploys | L2 Review | CTO |
| `DeployAgent` (PROPOSED) | Production deploys | L3 | CTO must approve |
| `MonitoringAgent` | Health checks, alerting | L1 Auto | — |

#### 2.7.3 Integrations

| Vendor | Adapter | Status | Gate |
|--------|---------|--------|------|
| Modulr | `ModulrAdapter` | Pending API key (BT-001) | COO |
| Ballerine | `BallerineKYCAdapter` | Deployed | MLRO |
| Jube | `JubeAdapter` | Deployed (GMKtec :5001) | CRO |
| Marble | `MarbleAdapter` | Deployed (GMKtec :5002) | CRO |
| Sumsub | `SumsumAdapter` | Pending API key (BT-004) | MLRO |

#### 2.7.4 Security / IAM

| Agent | Task | Autonomy | Gate |
|-------|------|----------|------|
| `SecurityAgent` | Keycloak OIDC, device fingerprint | L3 | CTO + CEO |
| `IAMAgent` | Role provisioning (SM&CR aligned) | L2 Review | CTO |
| `IncidentResponseAgent` (PROPOSED) | Security incident triage | L2 | CTO + CEO (CRITICAL) |

**Security incident CRITICAL: CEO must be notified within 2h (FCA SYSC 8.1).**

---

### 2.8 Front Office

| Sub-block | Agent | Autonomy |
|-----------|-------|----------|
| Sales | `LeadScoringAgent` (PROPOSED) | L1 Auto |
| Marketing | `CampaignAgent` (PROPOSED) | L1 Auto |
| Customer Success | `CustomerSupportAgent` | L1 Auto |
| NPS | `NPSAgent` (PROPOSED) | L1 Auto |

No HITL gates required for Front Office (no regulatory obligations attach directly).
Consumer Duty PS22/9 outputs are monitored by CRO.

---

### 2.9 HR / Legal / Compliance Admin

| Sub-block | Agent | Autonomy | Gate |
|-----------|-------|----------|------|
| HR | `HRAgent` (PROPOSED) | L1 Auto | CEO (hiring SMF holders) |
| Legal | `ContractAgent` (PROPOSED) | L2 Review | Legal Counsel |
| Compliance Admin | `AgreementAgent` | L2 Review | MLRO (regulated docs) |

---

## 3. Three Lines of Defence

| Line | Function | Owner | AI Involvement |
|------|----------|-------|----------------|
| **1st Line** | Business risk management (operational controls) | COO + CTO + Front Office | L1-L2 agents, automated guardrails |
| **2nd Line** | Risk oversight, compliance monitoring, MLRO | CRO + MLRO | L2-L3 agents with human gates |
| **3rd Line** | Independent audit assurance | Internal Audit | Read-only agents; humans issue findings |

---

## 4. SM&CR — Senior Manager & Certification Regime

| SMF | Role | Holder | FCA Certification |
|-----|------|--------|------------------|
| SMF1 | CEO | Moriel Carmi | ✅ Required |
| SMF2 | CFO | TBC | ✅ Required |
| SMF4 | CRO | TBC | ✅ Required |
| SMF5 | Internal Audit | TBC (or outsourced) | ✅ Required |
| SMF17 | MLRO | TBC | ✅ Required |
| SMF24 | COO | TBC | ✅ Required |
| SMF26 | CTO | Oleg (@p314pm) (CTIO) | ✅ Required |

**FCA Conduct Rules apply to all Certified persons and SMF holders.**

---

## 5. EU AI Act Art.14 Compliance

High-risk AI systems (AML, KYC, fraud scoring, credit assessment) must allow:
1. **Understand** — all AI outputs are explainable (reasons, scores, thresholds)
2. **Interpret** — human operators can interrogate decision logic
3. **Override** — every AI HOLD/BLOCK decision can be overridden by authorised human
4. **Stop** — `DecisionOutcome.REJECT` + `CaseStatus.ESCALATED` paths always available

**High-risk AI systems in Banxe:**
- `FraudScoringAgent` (Jube) — HITL required on score ≥70
- `AML-Analyst-v1` — HITL required on SAR_REQUIRED, STRUCTURING, VELOCITY_DAILY
- `KYC-Specialist-v2` — HITL required on HIGH/PROHIBITED risk
- `SanctionsScreeningAgent` — AUTO BLOCK; reversal requires MLRO
- `CreditScoringAgent` (PROPOSED) — HITL required on all rejections

---

## 6. HITL Decision Gates — Summary

See full 17-row machine-readable matrix: `../HITL-MATRIX.yaml`

| Decision Type | Required Approver | SLA | AI may proceed without? |
|---------------|------------------|-----|------------------------|
| SAR filing | MLRO only | 4h | NO |
| EDD sign-off | Compliance Officer | 24h | NO |
| Sanctions BLOCK | Auto (MLRO notified) | Immediate | YES (BLOCK is automatic) |
| Sanctions reversal | MLRO + CEO | 2h | NO |
| Customer BLOCK (AML) | MLRO | 4h | NO |
| KYC rejection (HIGH risk) | Compliance Officer | 24h | NO |
| PEP onboarding | MLRO + CEO | 48h | NO |
| SAR retraction | MLRO + CEO | 4h | NO |
| Transaction HOLD (fraud) | Operator/MLRO | 24h | NO |
| FCA RegData submission | CFO | Before deadline | NO |
| Safeguarding shortfall | CFO + MLRO | 4h | NO |
| AML threshold change | CRO + CEO | Per change control | NO |
| Production deploy | CTO | Per release | NO |
| AI model update | CRO + CTO | Per release | NO |
| Security incident CRITICAL | CTO + CEO | 2h | NO |
| Transaction >£50k | COO or CFO | 1h | NO |
| New product launch | Board/CEO | Per governance | NO |

---

---

## 7. CBS & Finance AI Agents — Corrected OSS Stack
> IL-066 (created) | IL-067 (OSS stack corrected) | 2026-04-09
>
> Full authoritative OSS stack: `docs/FINANCE-BLOCK-OSS-STACK.md`
> Previous errors corrected: Camunda 7 CE → FINOS Fluxnova; JasperReports → WeasyPrint;
> ELK (SSPL) → OpenSearch; OpenBB excluded; My FCA portal = manual only (no API).

### 7.1 Five-Level CFO Block Structure

```
┌──────────────────────────────────────────────────────────────────┐
│              OFFICE OF CFO — FINANCE BLOCK                       │
├─────────────────────┬────────────────────────────────────────────┤
│ 1. Financial Control│ Odoo CE, ERPNext, Midaz, Formance,         │
│    (Controlling)    │ Beancount/Fava, OCA IFRS modules           │
├─────────────────────┼────────────────────────────────────────────┤
│ 2. FP&A             │ dbt Core, ClickHouse, Superset, Metabase,  │
│                     │ OSEM, H2O.ai, Airflow                      │
├─────────────────────┼────────────────────────────────────────────┤
│ 3. Treasury / ALM   │ Frankfurter, QuantLib, OSEM, Blnk Finance, │
│                     │ Prometheus + Grafana, ClickHouse MVs       │
├─────────────────────┼────────────────────────────────────────────┤
│ 4. Regulatory       │ Midaz Reporter, WeasyPrint, ReportLab,     │
│    Reporting        │ FINOS ORR/DRR, OpenMetadata, Great Expect.,│
│                     │ bankstatementparser, pgAudit, Debezium     │
├─────────────────────┼────────────────────────────────────────────┤
│ 5. Data Analytics BI│ ClickHouse, dbt, Superset, Metabase,       │
│                     │ Grafana, Airflow, Airbyte, OpenSearch ⭐   │
└─────────────────────┴────────────────────────────────────────────┘

 ┌───────────────────────────────────────────────────────────────┐
 │  MLRO FUNCTION (independent from CFO — reports to Board)     │
 │  AML + Fraud Detection + KYC/KYB + Sanctions Screening       │
 │  ── NOT part of CFO finance block ──                         │
 └───────────────────────────────────────────────────────────────┘

Workflow: FINOS Fluxnova ⭐ (Apache 2.0) — replaces Camunda 7 CE (EOL)
Workflow: Temporal (MIT) — durable orchestration
AI Agents: OpenClaw + MetaClaw + Ruflo (Claude Flow v3)
```

### 7.2 Corrected Integration Chain

```
Midaz / Formance Ledger
    │ event webhooks
    ▼
Odoo Community CE (GL/AP/AR) ←── OCA CAMT.053 reconcile ←── bankstatementparser
    │ OCA account-financial-tools (IFRS)
    │ dbt Core transformations
    ▼
ClickHouse (OLAP)
    ├──► Superset / Metabase     ──► CFO / ALCO dashboards
    ├──► dbt variance models     ──► FP&A variance reports
    ├──► Great Expectations      ──► Data quality gate
    ├──► Midaz Reporter / WeasyPrint ──► FIN060 / CASS 15 PDF (NOT JasperReports)
    │                                       │ manual upload (no API)
    │                                       ▼
    │                              My FCA portal (CFO/Head of Reg Reporting)
    ├──► Beancount + Fava        ──► External Auditor (read-only)
    ├──► OpenMetadata            ──► Data lineage (every FCA field)
    └──► OpenSearch ⭐           ──► Audit log search (NOT ELK/SSPL)

Blnk Finance + Prometheus/Grafana ──► Safeguarding pool + ALCO dashboard
Frankfurter (ECB FX) + QuantLib   ──► FX rates + derivative pricing
OSEM + H2O.ai                     ──► ALM models + AutoML forecasting
FINOS Fluxnova ──► Human approval BPMN (CFO close sign-off, FCA return approval)
```

### 7.3 AI Agents OSS Mapping (all 22 agents)

| AI Agent | Sub-block | OSS Stack | Human Double |
|----------|-----------|-----------|-------------|
| GL Close Agent | Controlling | Odoo CE, ERPNext, Midaz, ClickHouse, Beancount | Financial Controller |
| IFRS Agent | Controlling | Odoo + OCA IFRS, Midaz, Beancount | Chief Accountant |
| AP/AR Agent | Controlling | Odoo/ERPNext, OCA account-reconcile, CAMT.053, bankstatementparser | Controller / Head of Treasury |
| Expense Anomaly Agent | Controlling | Odoo CE, ClickHouse | Financial Controller |
| Consolidation Agent | Controlling | Odoo multicompany, ERPNext, Frankfurter | Financial Controller |
| Tax Compliance Agent | Controlling | Odoo/ERPNext | Tax Manager / Controller |
| Beancount Export Agent | Controlling | Odoo, Midaz, Beancount, Fava | Controller + Internal Audit |
| Budget Agent | FP&A | ClickHouse, dbt Core, Odoo CE, Frankfurter, OSEM, Superset | Head of FP&A |
| Forecast Agent | FP&A | ClickHouse, H2O.ai AutoML, dbt Core, Frankfurter, OSEM | Head of FP&A |
| Variance Analysis Agent | FP&A | ClickHouse, dbt, Superset/Metabase | Head of FP&A |
| Scenario Agent | FP&A | OSEM, ClickHouse, dbt, Python | Head of FP&A |
| Cash Position Agent | Treasury | Blnk Finance, ClickHouse MVs, CAMT.053, bankstatementparser, Midaz, Prometheus/Grafana | Head of Treasury |
| Liquidity Forecast Agent | Treasury | dbt, ClickHouse, OSEM, Prometheus/Grafana | Head of Treasury |
| FX Exposure Agent | Treasury | Frankfurter, QuantLib, ClickHouse, OSEM, Grafana | Head of Treasury |
| Covenant Monitor Agent | Treasury | ClickHouse, Blnk Finance, Prometheus/Grafana | Head of Treasury |
| FCA Data Extraction Agent | Reg Reporting | ClickHouse, Midaz, Odoo CE, bankstatementparser, OpenMetadata | Head of Reg Reporting |
| Reg Data Quality Agent | Reg Reporting | Great Expectations, ClickHouse | Head of Reg Reporting |
| FCA Return Generator Agent | Reg Reporting | dbt, WeasyPrint, ReportLab, OpenMetadata | Head of Reg Reporting (CFO submits) |
| Resolution Pack Agent | Reg Reporting | ClickHouse, Odoo CE, Beancount, WeasyPrint | Head of Reg Reporting + CFO |
| Finance BI Agent | Finance BI | ClickHouse, Superset, Metabase, Grafana, OpenSearch, dbt | Head of Finance Systems |
| Data Pipeline Agent | Finance BI | Airflow, dbt, Airbyte, ClickHouse | Head of Finance Systems / CTO |
| Data Quality Gate Agent | Finance BI | Great Expectations, dbt tests, ClickHouse | Head of Finance Systems |

### 7.4 Period-Close Swarm — Dependency Chain

```
Trigger: period-end
    │
    ▼
[GL Close Agent] ──────────────────────────────────────────────────────┐
    │                                                                   │
    ├──► [IFRS Agent] ─────────────────────────────┐                  │
    └──► [AP/AR Agent] ── parallel ──               │                  │
                                                    ▼                  ▼
                                       [Consolidation Agent]    [Tax Agent]
                                                    │
                                                    ▼
                                       [Beancount Export Agent]
                                                    │
                                                    ▼
                              CFO/Controller Agent → FINOS Fluxnova BPMN → Financial Controller ✋
```

Full swarm configs: `agents/swarms/accounting-swarm.yaml` (close cycle)
                    `agents/swarms/monthly-fca-return.yaml` (FCA reporting cycle)

---

*Document maintained by: Claude Code | IL-065, IL-066, IL-067 | 2026-04-09 | I-29 (Documentation Standard)*
