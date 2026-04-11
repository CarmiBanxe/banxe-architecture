# JOB-DESCRIPTIONS.md — Banxe AI Bank Job Descriptions

> IL-071 | Developer Plane | banxe-architecture
> Created: 2026-04-12 | Author: Perplexity Computer + Claude Code
>
> **Purpose**: Canonical job descriptions for every AI agent and human double
> in the Banxe AI Bank organisational structure. Each entry defines:
> duties, authorities, KPIs, interaction map, and HITL boundaries.
> Foundation document for RELATIONSHIP-TREE.md.

---

## 1. Senior Management (SMF Holders) — Human Only

### 1.1 CEO (SMF1) — Moriel Carmi

| Field | Value |
|-------|-------|
| **Title** | Chief Executive Officer |
| **SMF** | SMF1 |
| **Reports to** | Board of Directors |
| **Entity** | Banxe LTD / TomPay LTD |
| **AI Agent** | None (human-only tier) |
| **Trust Zone** | Board (L4) |

**Core Duties:**
- Ultimate accountability for FCA authorisation and regulatory compliance
- Chairs ALCO and Risk Committee
- Approves PEP onboarding (with MLRO), SAR retraction, AML threshold changes
- Approves security incidents rated CRITICAL (with CTO)
- Signs off new product launches
- EU AI Act Art.22: overall responsible person for high-risk AI systems

**KPIs:**
- FCA compliance score: 100% (zero enforcement actions)
- Customer growth rate: quarterly targets
- Platform uptime: >99.9%
- Regulatory incident response: <2h for CRITICAL

---

### 1.2 MLRO (SMF17) — TBC

| Field | Value |
|-------|-------|
| **Title** | Money Laundering Reporting Officer |
| **SMF** | SMF17 (FCA Approved Person) |
| **Reports to** | CEO + Board (independent reporting line) |
| **Entity** | TomPay LTD |
| **AI Agents supervised** | AML-Analyst-v1, SanctionsScreeningAgent, ComplianceOfficerAgent, KYC-Specialist-v2 |
| **Trust Zone** | RED (L3) |

**Core Duties (non-delegable to AI):**
- SAR filing to NCA/UKFIU (POCA 2002 s.330)
- SAR retraction (with CEO)
- PEP enhanced due diligence sign-off
- Sanctions BLOCK reversal (with CEO)
- Customer BLOCK for AML reasons
- Annual MLRO Report to Board
- EDD sign-off within 24h (MLR 2017 Reg.28)
- Financial promotions review (FCA COBS 4)

**KPIs:**
- SAR filing SLA: <4h from detection
- EDD completion SLA: <24h
- False positive rate: <15% on AML alerts
- Annual SAR report: delivered by Q1 deadline
- Sanctions screening: zero missed true positives

---

### 1.3 CRO (SMF4) — TBC

| Field | Value |
|-------|-------|
| **Title** | Chief Risk Officer |
| **SMF** | SMF4 |
| **Reports to** | CEO + Board |
| **Entity** | TomPay LTD |
| **AI Agents supervised** | FraudScoringAgent, AMLPipelineAgent, ConsumerDutyAgent, RiskOversightAgent |
| **Trust Zone** | RED (L3) |

**Core Duties:**
- AI model risk assessment before production deployment
- Threshold approval for fraud/AML models (jointly with CEO)
- Consumer Duty PS22/9 fair outcomes monitoring
- 1st Line of Defence escalation to Board on material risk
- EU AI Act Art.9: risk management for high-risk AI systems
- Quarterly review of HITL decision quality

**KPIs:**
- Model accuracy: >95% on fraud detection
- Consumer Duty outcomes: quarterly compliance score
- Risk events: zero unmitigated HIGH-risk items
- HITL override quality: <5% error rate on CRO decisions

---

### 1.4 CFO (SMF2) — TBC

| Field | Value |
|-------|-------|
| **Title** | Chief Financial Officer |
| **SMF** | SMF2 |
| **Reports to** | CEO |
| **Entity** | TomPay LTD |
| **AI Agents supervised** | LedgerAgent, ReconciliationAgent, ReportingAgent, RegDataAgent, SafeguardingAgent |
| **Trust Zone** | RED (L3) |

**Core Duties:**
- FCA regulatory returns (FIN060, RegData) — must click submit personally
- Safeguarding shortfall approval (with MLRO)
- Ledger adjustment >GBP 10k requires sign-off
- Treasury decisions >GBP 100k sign-off
- CASS 15 compliance oversight
- Period-close process sign-off

**KPIs:**
- FIN060 submission: on time every month
- Safeguarding reconciliation: daily, zero unresolved breaches >3 days
- Audit findings: zero material findings
- Period-close: completed within T+5

---

### 1.5 COO (SMF24) — TBC

| Field | Value |
|-------|-------|
| **Title** | Chief Operating Officer |
| **SMF** | SMF24 |
| **Reports to** | CEO |
| **Entity** | TomPay LTD |
| **AI Agents supervised** | PaymentRouterAgent, CustomerLifecycleAgent, CustomerSupportAgent, EscalationAgent |
| **Trust Zone** | AMBER/RED |

**Core Duties:**
- Payments operations oversight (FPS/SEPA/SWIFT/CHAPS)
- Customer operations and support quality
- Transaction >GBP 50k approval (with CFO)
- Customer BLOCK decisions (operational)
- SLA enforcement for customer support
- DISP complaints workflow oversight

**KPIs:**
- Payment success rate: >99.5%
- Customer support first response: <1h
- Complaint resolution: <8 weeks (FOS requirement)
- NPS score: >40

---

### 1.6 CTO (SMF26) — Oleg (@p314pm)

| Field | Value |
|-------|-------|
| **Title** | Chief Technology Officer (CTIO) |
| **SMF** | SMF26 |
| **Reports to** | CEO |
| **Entity** | Banxe LTD |
| **AI Agents supervised** | SecurityAgent, IAMAgent, DeployAgent, MonitoringAgent, all platform agents |
| **Trust Zone** | RED (security) / AMBER (platform) |

**Core Duties:**
- AI platform architecture and reliability
- Production deployment approval
- Security/IAM (Keycloak) management
- Integration management (Modulr, Ballerine, Jube, Marble)
- Security incident triage (CRITICAL: notify CEO within 2h)
- AI model update approval (with CRO)

**KPIs:**
- Platform uptime: >99.9%
- Deployment success rate: >99%
- Security incidents: zero CRITICAL unresolved >4h
- Test coverage: >80%

---

## 2. AI Agents — AML/Compliance Department

### 2.1 AML-Analyst-v1

| Field | Value |
|-------|-------|
| **Type** | AI Agent (ACTIVE) |
| **Department** | AML/Compliance |
| **Reports to** | MLRO (SMF17) |
| **Human Double** | Compliance Officer |
| **Entity** | TomPay LTD |
| **Autonomy** | L2 Review |
| **Trust Zone** | RED |
| **Passport** | `agents/passports/aml_analyst.yaml` |

**Duties:**
- Real-time transaction monitoring against AML rules
- Risk scoring (LOW/MEDIUM/HIGH/VERY_HIGH/PROHIBITED)
- Structuring detection (multiple transactions below threshold)
- Velocity checks (daily/weekly/monthly limits)
- Generate SAR proposals for MLRO review
- Dual-entity threshold checking (I-41)

**Authorities:**
- CAN: Flag transactions, generate alerts, propose SAR
- CANNOT: File SAR, block customer, change thresholds
- HITL gate: On SAR_REQUIRED, STRUCTURING, VELOCITY_DAILY

**KPIs:**
- Alert processing: <5 min per transaction
- True positive rate: >85%
- False positive rate: <15%
- SAR proposal quality: >90% MLRO acceptance rate

**Interacts with (horizontal):**
- SanctionsScreeningAgent (shared watchlist results)
- KYC-Specialist-v2 (customer risk profile)
- FraudScoringAgent (Jube) (combined risk signal)
- ChainAnalysisAgent (crypto AML signals via Neuronext)

---

### 2.2 KYC-Specialist-v2

| Field | Value |
|-------|-------|
| **Type** | AI Agent (ACTIVE) |
| **Department** | Customer Onboarding |
| **Reports to** | MLRO (SMF17) via Compliance Officer |
| **Human Double** | Compliance Officer |
| **Entity** | TomPay LTD |
| **Autonomy** | L2 Review |
| **Trust Zone** | AMBER |

**Duties:**
- KYC process execution (FCA MLR 2017 Reg.18-27)
- ID verification via Sumsub IDV Service
- KYB via Companies House API (UBO chain, director registry)
- Customer risk assessment and profiling
- CustomerProfile creation (name, DOB, nationality, risk_level)
- Escalation to Compliance Department (high/very_high/prohibited)

**Authorities:**
- CAN: Run IDV checks, create profiles, assign LOW/MEDIUM risk
- CANNOT: Approve HIGH/PROHIBITED risk customers, override sanctions
- HITL gate: On HIGH or PROHIBITED risk assessment

**KPIs:**
- Onboarding completion: <15 min for LOW risk
- Verification accuracy: >99%
- Escalation rate: <10% of applications
- Rejection false positive: <5%

**Interacts with:**
- AML-Analyst-v1 (provides customer risk profile)
- ComplianceOfficerAgent (escalation target)
- CryptoKYCAgent (shared identity for dual-entity onboarding)
- CustomerLifecycleAgent (onboarding handoff)

---

## 3. AI Agents — Operations Department

### 3.1 PaymentRouterAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Payment Operations |
| **Reports to** | COO (SMF24) via Treasury Manager |
| **Human Double** | Treasury Manager |
| **Entity** | TomPay LTD |
| **Autonomy** | L1 Auto (<GBP 50k) / L2 Review (>GBP 50k) |
| **Trust Zone** | RED (large amounts) / GREEN (standard) |

**Duties:**
- Route payments to correct rail (FPS/SEPA/CHAPS/SWIFT)
- SCA enforcement (PSR 2017 Reg.71: strong auth >GBP 30)
- Fee calculation and application
- Payment status tracking and webhook management
- Bulk/mass payment orchestration

**KPIs:**
- Routing accuracy: >99.99%
- Payment processing SLA: <10 sec (FPS), <10 min (SEPA)
- Failed payment rate: <0.1%

---

### 3.2 SafeguardingAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (ACTIVE) |
| **Department** | Safeguarding (COO) |
| **Reports to** | CFO (SMF2) |
| **Human Double** | MLRO + External Auditor |
| **Entity** | TomPay LTD |
| **Autonomy** | L1 Auto (daily recon) / L3 (breach detection) |
| **Trust Zone** | RED |

**Duties:**
- Daily internal vs external bank reconciliation
- Shortfall/surplus detection
- FIN060 data preparation
- CASS 10A resolution pack maintenance
- ClickHouse audit trail logging

**KPIs:**
- Reconciliation: completed by 09:00 UTC daily
- Discrepancy detection: <1h from occurrence
- Zero unresolved discrepancies >3 days

---

### 3.3 CustomerLifecycleAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Customer Operations |
| **Reports to** | COO (SMF24) |
| **Human Double** | Customer Support Lead |
| **Entity** | TomPay LTD |
| **Autonomy** | L1 Auto / L2 on block |

**Duties:**
- Customer onboarding workflow management
- Account status management (active/frozen/closed)
- Dormancy detection (>6 months inactive)
- Offboarding process (fund return, account closure)

---

## 4. AI Agents — Customer Support Department

### 4.1 TicketRoutingAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Customer Support |
| **Reports to** | Head of Customer Support (via COO) |
| **Human Double** | Support Team Lead |
| **Entity** | Banxe LTD |
| **Autonomy** | L1 Auto |
| **OSS Stack** | Chatwoot (MIT) |

**Duties:**
- Incoming ticket categorisation (payment/kyc/crypto/card/general)
- Priority assignment (P1-urgent/P2-high/P3-normal/P4-low)
- SLA timer activation
- Agent/team routing based on category and load

### 4.2 CustomerSupportAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Customer Support |
| **Reports to** | Head of Customer Support |
| **Human Double** | Support Agent |
| **Autonomy** | L1 Auto |
| **OSS Stack** | Chatwoot + Ollama + ChromaDB |

**Duties:**
- FAQ bot with RAG (first-line response)
- Multilingual support (EN/RU/FR)
- Ticket context enrichment from customer profile
- Escalation to human agent on complex issues

### 4.3 EscalationAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Customer Support |
| **Reports to** | COO (SMF24) |
| **Human Double** | Head of Customer Support |
| **Autonomy** | L2 Review |
| **OSS Stack** | n8n + ClickHouse |

**Duties:**
- SLA breach monitoring and alerts
- Auto-escalation when SLA exceeded
- HITL escalation for complex complaints
- DISP workflow trigger (8-week FOS timeline)

### 4.4 FeedbackAnalyticsAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Customer Support |
| **Reports to** | CRO (quarterly) |
| **Human Double** | Head of Customer Experience |
| **Autonomy** | L1 Auto |
| **OSS Stack** | ClickHouse + Superset |

**Duties:**
- NPS/CSAT score aggregation and trending
- Consumer Duty PS22/9 Section 4 reporting
- Sentiment analysis on support interactions
- Quarterly Consumer Duty outcomes report for CRO

---

## 5. AI Agents — Marketing & Growth Department

### 5.1 CampaignAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Marketing |
| **Reports to** | Head of Marketing (via COO/CEO) |
| **Human Double** | Head of Marketing |
| **Autonomy** | L2 Review |
| **HITL Gate** | MLRO review for financial promotions (FCA COBS 4) |
| **OSS Stack** | Listmonk (AGPL) |

**Duties:**
- Email/push campaign orchestration
- A/B testing management
- Campaign performance analytics
- **CRITICAL**: ALL financial promotions MUST be reviewed by MLRO before publication

### 5.2 LeadScoringAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Marketing |
| **Reports to** | Head of Marketing |
| **Autonomy** | L1 Auto |
| **OSS Stack** | ClickHouse + scikit-learn |

**Duties:**
- Behavioral scoring (signup -> KYC -> first deposit -> active)
- Conversion funnel analysis
- At-risk customer identification

### 5.3 ContentAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Marketing |
| **Reports to** | MLRO (for financial content) |
| **Human Double** | Content Manager |
| **Autonomy** | L2 Review |
| **OSS Stack** | Ollama |

**Duties:**
- Compliance-safe content generation
- Blog/social media draft creation
- Risk disclosure text generation
- **CRITICAL**: Never auto-publish financial content

---

## 6. AI Agents — Crypto Department (Neuronext)

### 6.1 CryptoKYCAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Crypto Compliance |
| **Reports to** | Crypto Compliance Officer (Neuronext) |
| **Human Double** | Crypto Compliance Officer |
| **Entity** | Neuronext Sp. z o.o. |
| **Autonomy** | L2 Review |

**Duties:**
- AMLD6-compliant crypto-specific KYC
- Wallet origin verification
- Source of crypto funds assessment
- Cross-reference with TomPay KYC data

### 6.2 ChainAnalysisAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Crypto AML |
| **Reports to** | MLRO (Neuronext) |
| **Human Double** | Crypto AML Analyst |
| **Entity** | Neuronext Sp. z o.o. |
| **Autonomy** | L1 Auto |

**Duties:**
- Blockchain forensics (transaction tracing)
- Wallet risk scoring (mixing services, darknet, gambling)
- VASP identification for Travel Rule
- Sanctioned address detection
- Cross-entity risk signal sharing with AML-Analyst-v1

### 6.3 RateEngineAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Trading |
| **Reports to** | Head of Trading (Neuronext) |
| **Human Double** | Head of Trading |
| **Entity** | Neuronext Sp. z o.o. |
| **Autonomy** | L1 Auto |

**Duties:**
- Market rate aggregation from multiple sources
- Spread calculation and management
- Rate feed to Banxe platform (WebSocket)
- Liquidity monitoring across exchanges

---

## 7. AI Agents — Finance Department

### 7.1 LedgerAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (ACTIVE) |
| **Department** | Finance / Controlling |
| **Reports to** | CFO (SMF2) via Financial Controller |
| **Human Double** | Financial Controller |
| **Entity** | TomPay LTD |
| **Autonomy** | L2 Review |
| **OSS Stack** | Midaz, Odoo CE, Beancount |

**Duties:**
- Double-entry posting via MidazAdapter
- GL reconciliation
- Journal entry creation and validation
- Period-close preparation

### 7.2 ReportingAgent

| Field | Value |
|-------|-------|
| **Type** | AI Agent (PROPOSED) |
| **Department** | Finance / Regulatory Reporting |
| **Reports to** | CFO (SMF2) |
| **Human Double** | Head of Regulatory Reporting |
| **Autonomy** | L3 (CFO must sign) |

**Duties:**
- FIN060 monthly safeguarding return generation
- RegData submission preparation for FCA Gabriel
- Annual SAR statistics compilation
- Client statement generation (PDF/CSV)

---

## 8. Agent Summary Registry

| # | Agent | Department | Entity | Status | Autonomy | Human Double |
|---|-------|-----------|--------|--------|----------|--------------|
| 1 | AML-Analyst-v1 | AML/Compliance | TomPay | ACTIVE | L2 | Compliance Officer |
| 2 | KYC-Specialist-v2 | Customer Onboarding | TomPay | ACTIVE | L2 | Compliance Officer |
| 3 | SanctionsScreeningAgent | AML/Compliance | TomPay | ACTIVE | L1 Auto | MLRO |
| 4 | ComplianceOfficerAgent | AML/Compliance | TomPay | ACTIVE | L2 | Compliance Officer |
| 5 | FraudScoringAgent | AML/Compliance | TomPay | ACTIVE (Jube) | L1 | CRO |
| 6 | PaymentRouterAgent | Operations | TomPay | PROPOSED | L1/L2 | Treasury Manager |
| 7 | SafeguardingAgent | Safeguarding | TomPay | ACTIVE | L1/L3 | MLRO + CFO |
| 8 | CustomerLifecycleAgent | Customer Ops | TomPay | PROPOSED | L1/L2 | Customer Support Lead |
| 9 | LedgerAgent | Finance | TomPay | ACTIVE | L2 | Financial Controller |
| 10 | ReconciliationAgent | Finance | TomPay | ACTIVE | L2 | Financial Controller |
| 11 | ReportingAgent | Reg. Reporting | TomPay | PROPOSED | L3 | Head of Reg Reporting |
| 12 | SecurityAgent | Security/IAM | Banxe LTD | ACTIVE | L3 | CTO + CEO |
| 13 | NotificationAgent | Notifications | Banxe LTD | ACTIVE (n8n) | L1 | -- |
| 14 | TicketRoutingAgent | Customer Support | Banxe LTD | PROPOSED | L1 | Support Team Lead |
| 15 | CustomerSupportAgent | Customer Support | Banxe LTD | PROPOSED | L1 | Support Agent |
| 16 | EscalationAgent | Customer Support | Banxe LTD | PROPOSED | L2 | Head of Support |
| 17 | ComplaintTriageAgent | Customer Support | Banxe LTD | PROPOSED | L2 | COO |
| 18 | FeedbackAnalyticsAgent | Customer Support | Banxe LTD | PROPOSED | L1 | CRO (quarterly) |
| 19 | CampaignAgent | Marketing | Banxe LTD | PROPOSED | L2 | Head of Marketing |
| 20 | LeadScoringAgent | Marketing | Banxe LTD | PROPOSED | L1 | Head of Marketing |
| 21 | ContentAgent | Marketing | Banxe LTD | PROPOSED | L2 | MLRO (promos) |
| 22 | OnboardingNurtureAgent | Marketing | Banxe LTD | PROPOSED | L1 | -- |
| 23 | AnalyticsAgent | Marketing | Banxe LTD | PROPOSED | L1 | -- |
| 24 | CryptoKYCAgent | Crypto Compliance | Neuronext | PROPOSED | L2 | Crypto CO |
| 25 | ChainAnalysisAgent | Crypto AML | Neuronext | PROPOSED | L1 | Crypto AML Analyst |
| 26 | TravelRuleAgent | Crypto Compliance | Neuronext | PROPOSED | L1 | Crypto CO |
| 27 | CryptoAMLAgent | Crypto AML | Neuronext | PROPOSED | L2 | MLRO (Neuronext) |
| 28 | LiquidityAgent | Crypto Treasury | Neuronext | PROPOSED | L2 | Head of Treasury |
| 29 | RateEngineAgent | Crypto Trading | Neuronext | PROPOSED | L1 | Head of Trading |
| 30 | WalletSecurityAgent | Crypto Security | Neuronext | PROPOSED | L1 | CISO |
| 31 | CryptoSanctionsAgent | Crypto Compliance | Neuronext | PROPOSED | L1 | Crypto CO |
| 32 | ProWalletAgent | Pro Wallet | iLink | PROPOSED | L1 | CTO (iLink) |

**Total: 32 AI agents** (8 ACTIVE + 24 PROPOSED)

---

*Document maintained by: Perplexity Computer + Claude Code | IL-071 | 2026-04-12 | I-29 (Documentation Standard)*
