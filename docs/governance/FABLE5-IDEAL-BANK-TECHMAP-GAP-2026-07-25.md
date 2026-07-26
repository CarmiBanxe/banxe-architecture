# FABLE-5 IDEAL BANK TECHMAP & GAP ANALYSIS
**Date:** 2026-07-25  
**Classification:** GOVERNANCE / FABLE-5 CONSULTATION / IDEAL-BANK TECHMAP + GAP / DOCS-ONLY / NO COMMIT  
**Repository:** architecture-bank-operating-model-20260718 (canonical)  
**Scope:** Compare classical ideal bank structure (Three Lines of Defence + SM&CR) against VERIFIED BANXE EMI structure  
**Caveat:** This is advisory analysis only. **This does not replace legal advice.**

---

## §1 IDEAL BANK ORG-STRUCTURE (Reference Model)

### 1.1 Three Lines of Defence

**1st Line — Business Operations (Front & Middle Office):**
- Owns and controls day-to-day risks
- Responsible for operational compliance (payments, KYC, AML, transactions)
- Embeds controls and monitoring into business processes
- Reports to business unit heads

**2nd Line — Risk & Compliance Oversight (Risk, Compliance, Treasury, Finance oversight):**
- Independent monitoring of 1st-line effectiveness
- Sets policies, frameworks, thresholds (AML/EDD, lending risk appetite, FX limits)
- Escalates breaches, investigates policy violations
- Reports to Board Risk Committee; escalates to CEO/Board

**3rd Line — Internal Audit (Independent Assurance):**
- Audits both 1st and 2nd line
- Reports to Audit Committee (independent of management)
- Reviews control effectiveness, compliance with frameworks
- Has direct access to Board/MLRO

### 1.2 Front / Middle / Back Office

**Front Office (Customer-Facing):**
- Retail banking, business banking, relationship management
- Customer onboarding, account opening, KYC
- Transaction origination (payments, transfers, card usage)
- Customer service, complaints

**Middle Office (Risk & Compliance Intermediary):**
- KYC/AML screening, transaction monitoring
- Trade compliance (sanctions, fraud, AML thresholds)
- Credit risk assessment, lending approval gates
- Reconciliation, exception handling

**Back Office (Settlement & Accounting):**
- Payment settlement, FX settlement
- Ledger posting, journal entries
- Statement generation, regulatory reporting (FIN060, CASS 15)
- Audit trail, compliance evidence

### 1.3 Mandatory Bank Functions

| Function | Role | Owner | Key Responsibility |
|----------|------|-------|-------------------|
| **Retail Banking** | 1st-line ops | Head of Retail | Account opening, deposits, payments for consumers |
| **Business Banking** | 1st-line ops | Head of Business | SME/corporate accounts, lending, treasury services |
| **Payments/Rails** | 1st-line ops + back-office | Head of Payments | FPS/SEPA/SWIFT settlement, payment infrastructure |
| **Treasury & ALM** | 2nd-line oversight | Treasury Manager / CFO | Liquidity, funding, FX management, interest rate risk |
| **Lending & Credit** | 1st-line + 2nd-line gate | Head of Credit | Loan origination, underwriting, credit decisions |
| **Risk Management** | 2nd-line | CRO | Enterprise risk register, risk appetite, stress testing |
| **Compliance & AML** | 2nd-line | MLRO (Money Laundering Reporting Officer) | MLR compliance, SAR filing, AML monitoring |
| **Finance & Accounting** | Back-office + 2nd-line | CFO / Head of Finance | GL posting, FX revaluation, tax, financial statements |
| **Regulatory Reporting** | Back-office + 2nd-line | Regulatory Reporting Manager | FIN060, CASS 15, RegData, FCA submissions |
| **Technology & Infrastructure** | Cross-cutting | CTO | Systems architecture, DevOps, security, uptime |
| **Internal Audit** | 3rd-line | Chief Audit Officer / Head of Internal Audit | Control testing, independence, Board reporting |
| **Legal** | Cross-cutting | General Counsel / Head of Legal | Regulatory interpretation, contracts, disputes |
| **HR & SMCR** | Cross-cutting | Head of HR | Staff records, SM&CR registration, compliance training |
| **Customer Service & Complaints** | 1st-line ops | Head of Customer Service | Complaints handling (FCA DISP), customer satisfaction |
| **Data Protection & Privacy** | Cross-cutting (2nd-line oversight) | Data Protection Officer (DPO) | GDPR compliance, privacy impact assessments |

### 1.4 SM&CR Governance (Senior Managers & Certification Regime)

**Board Level (Governance):**
- Board of Directors (non-executive + executive)
- Committees: Audit Committee, Risk Committee, Remuneration Committee, Product Governance Committee

**C-Suite (Executive Management) — Mandatory SMF Lines:**
| SMF | Title | Accountability |
|-----|-------|-----------------|
| SMF1 | Chief Executive Officer (CEO) | Overall governance, Board accountability |
| SMF2 | Chief Financial Officer (CFO) | Finance, treasury, regulatory reporting |
| SMF3 | Head of Internal Audit | Independent audit, Board Audit Committee |
| SMF4 | Chief Risk Officer (CRO) | Enterprise risk, risk appetite, stress testing |
| SMF5 | Head of Compliance / MLRO | AML/KYC oversight, SAR filing, MLR compliance |
| SMF6 | Head of Legal | Legal/regulatory interpretation, contracts |
| SMF7 | Head of HR | SMCR registration, compliance training |
| SMF24 | Chief Operating Officer (COO) | Ops, payments, customer service |
| SMF26 | Chief Technology Officer (CTO) | Technology, security, infrastructure |

**NEW / MISSING IN CURRENT STRUCTURE:**
- **SMF16 — Head of Compliance Oversight / Chief Compliance Officer (CCO)** — distinct from MLRO; oversees compliance program (not just AML)
- **Data Protection Officer (DPO)** — GDPR-mandated, separate from HR

**Departmental Heads (Report to SMF Lines):**
- Heads of Retail/Business/Payments (→ COO)
- Head of Risk Management (→ CRO)
- Head of Regulatory Reporting (→ CFO)
- Head of Customer Service (→ COO)
- etc.

### 1.5 Mandatory Bank Committees

| Committee | Chair | Members | Frequency | Authority |
|-----------|-------|---------|-----------|-----------|
| **Board Risk Committee** | Non-exec director | Board risk member, CRO, CFO, CEO | Monthly | Sets risk appetite, approves frameworks |
| **Board Audit Committee** | Non-exec director | Board audit member, CEO, Head of Audit | Monthly | Oversees internal audit, external audit, compliance |
| **Asset-Liability Committee (ALCO)** | CFO / CEO | CFO, CRO, Head of Treasury, CTO | Quarterly | Liquidity, funding, FX, interest rate risk decisions |
| **Credit Committee** | CRO / Head of Credit | CRO, Head of Credit, CFO (for large exposures) | Weekly/Monthly | Lending approvals, credit risk decisions |
| **Product Governance Committee** | COO / Head of Retail | COO, product heads, compliance, risk | Monthly | New product approval, consumer duty assessment |
| **Consumer Duty Committee** | COO | Head of Customer Service, Compliance, Risk, Finance | Quarterly | Customer fair value, vulnerability, conduct risk |
| **Operational Risk Committee** | CRO | CRO, COO, CTO, CFO, MLRO | Monthly | Operational/cyber incidents, control effectiveness |
| **Sanctions/Compliance Steering** | MLRO | MLRO, CRO, CFO, Head of Legal, CTO | Monthly | Regulatory changes, compliance program updates |

---

## §2 IDEAL INTERACTIONS & CONTROL FLOWS

### 2.1 Client-to-Payment Flow (Exemplar)

```
Client →┐
        └──→ Front Office (relationship mgr, payment entry)
              │ captures intent: payment amount, destination, FX need
              └──→ Middle Office (KYC/AML gate)
                   │ checks: KYC current? amount ≤ limit? sanctions? tx-monitor alert?
                   ├─ OK → pass to back-office
                   └─ FAIL → escalate to compliance (L3 HITL gate)
              └──→ Back Office (payment settlement)
                   │ post to ledger, FX conversion, payment rail (FPS/SEPA)
                   └──→ Audit Trail (append-only log)
              └──→ Treasury (FX settlement, position updates)
                   └──→ Finance (GL posting, FX revaluation)
```

### 2.2 Escalation Path

**Operational Incident → 1st-line head → 2nd-line (risk/compliance) → MLRO → CEO → Board Risk Committee**

**Compliance Breach → MLRO → Board Audit Committee → FCA notification (if SAR)**

### 2.3 Upward Reporting Cadence

- **Daily:** 1st-line exception reports (payment fails, KYC holds, AML alerts)
- **Weekly:** Risk committee (operational risk, fraud alerts, compliance exceptions)
- **Monthly:** Board Risk Committee (risk appetite metrics, KPIs, breaches, remediation status)
- **Quarterly:** Board Audit Committee (audit findings, SAR filing summary, control testing results)
- **Annually:** Board Risk Appetite review; compliance program effectiveness assessment

### 2.4 2nd-Line Oversight of 1st-Line

- Compliance reviews KYC/AML controls (sample testing)
- Risk reviews lending underwriting (credit quality testing)
- Treasury monitors FX positions against limits
- Internal Audit tests control design & operating effectiveness

### 2.5 3rd-Line Independence

- Internal Audit reports directly to Audit Committee (not to CEO)
- Chief Audit Officer has unfettered access to Board
- Audit cannot be overruled by management
- Scope is full coverage of 1st & 2nd line

---

## §3 OUR STRUCTURE (VERIFIED FACTS)

### 3.1 Physical Layout

**4 Floors + F0 Engine:**

| Floor | Rooms (Count) | Department/Domain |
|-------|---|---|
| **F0** | 1 | **Engine Core:** Banksy (ceo-conductor role, PROPOSES-only I-27), banking-engine (Midaz adapter), HITL gates, compliance_kb, midaz_mcp |
| **F1** | 4 | **Customer-Facing / 1st-Line Front:** support (ticketing), marketing (campaigns, CRM, lead scoring), customer-ops (onboarding, complaints, lifecycle), hr-legal (HR + Legal combined) |
| **F2** | 8 | **Banking Core / 1st-Line Operations:** identity (KYC/Keycloak), ledger (Midaz read), payments (FPS/SEPA/card/FX/beneficiary), safeguarding (CASS 15), statements, recon (daily reconciliation) |
| **F3** | 4 | **Risk & Control / 2nd-Line:** aml (AML/TM/sanctions/fraud), finbi (BI/analytics), regrep (regulatory reporting/FIN060), risk (enterprise risk, treasury) |
| **F4** | 5 | **Technology & Assurance / Infrastructure:** ai-platform (agents, design-pipeline, ML), audit-cell (audit logging, watchdog, incident response), devops (CI/CD, deploy, config, events), security (secrets, device-fingerprint, ATO prevention), shared-lib (abstract base classes, multi-tenancy, user preferences) |

**Total:** 22 rooms (4 floors + engine) housing 113 domains across 132 agents.

### 3.2 SMF Lines Present

| SMF | Title | Floor | Room |
|-----|-------|-------|------|
| SMF1 | CEO | F0 | engine (ceo-conductor) + safeguarding (recon owner) |
| SMF2 | CFO | F3 | finbi, regrep, treasury (+ F2 payments for ledger interactions) |
| SMF4 | CRO | F3 | risk |
| SMF5 | Internal Audit | F4 | audit-cell |
| SMF17 | MLRO | F3 | aml (core compliance) |
| SMF24 | COO | F1 | customer-ops, support, hr-legal |
| SMF26 | CTO | F4 | ai-platform, devops, security, shared-lib |

**Present: 7 SMF lines. Present 3/3 from "Mandatory SMF Lines" list (SMF1/2/4); SMF5 present; SMF17/24/26 present.**

### 3.3 Committees Status

**VERIFIED PRESENT:**
- HITL gates (I-27 HITL-L4 for SAR/FIN060 sign-off) — ENGINE-enforced
- Compliance swarm agents (AML/fraud/sanctions/TM) — agents/compliance/swarm.yaml
- Audit trail (append-only, I-24) — audit-cell + ClickHouse

**NOT EXPLICITLY DOCUMENTED / MISSING:**
- Board Risk Committee (formal governance)
- Board Audit Committee (formal governance)
- ALCO (Asset-Liability Committee)
- Credit Committee (lending decisions)
- Product Governance Committee
- Consumer Duty Committee
- Operational Risk Committee
- Sanctions/Compliance Steering Committee

### 3.4 Structural Gaps (Self-Identified)

1. **No SMF16 (CCO)** — Compliance oversight is delegated to MLRO (SMF17). CCO role (distinct from AML focus) is missing.
2. **No distinct DPO** — GDPR compliance is undefined; likely embedded in hr-legal (unverified).
3. **HR + Legal combined** — Both functions in single F1-hr-legal room (may limit independence of Legal counsel on governance issues).
4. **No explicit Credit function** — F2 has `lending` domain (marked [pending human ratification]); lending committee governance unclear.
5. **No explicit Retail/Business banking heads** — F2 rooms are functional (identity, payments, safeguarding) not retail/business-segmented.
6. **No ALCO documented** — Treasury exists (F3-risk room) but no committee governance recorded.
7. **AI agents lack formal governance board** — Swarm agents (L1–L4 autonomy) are orchestrated but no formal "Agent Oversight Committee" is documented.
8. **Engine (F0) boundaries unclear** — ceo-conductor is PROPOSES-only, but where does acceptance/HITL resolution live? (Implicit in rooms, not explicit.)

### 3.5 Three-Lines Mapping (OUR STRUCTURE)

| Line | Intended Role | OUR Placement | Observation |
|------|---|---|---|
| **1st Line** | Business operations + embedded controls | F1 (customer-ops, support, marketing), F2 (identity, payments, safeguarding, recon) | ✓ Covers front+middle+back-office functions |
| **2nd Line** | Risk/compliance oversight, policy-setting | F3 (aml, risk, treasury) + MLRO SMF17 | ✓ Present; but **3rd-line audit (F4-audit-cell) may conflate with 1st-line tech-ops (F4-devops/security)** — independence risk |
| **3rd Line** | Independent audit | F4-audit-cell (Internal-Audit/SMF5) | ⚠ **INDEPENDENCE RISK:** audit-cell shares F4 floor with devops/security/ai-platform (1st-line tech ops); physical/org separation unclear |

**⚠ KEY RISK: F4 conflates 3rd-line (audit-cell) with 1st-line infrastructure operations (devops/security/ai-platform).** In an ideal bank, audit reports directly to Board; devops/security report to CTO. Shared floor may blur lines.

### 3.6 Front/Middle/Back Split (OUR STRUCTURE)

| Office | OUR Placement | Domains |
|--------|---|---|
| **Front** | F1 | support, customer-ops, marketing, hr-legal (customer-facing) |
| **Middle** | F2 (identity) + F3 (aml, risk) | KYC gate (F2-identity), AML/TM (F3-aml), risk scoring (F3-risk) |
| **Back** | F2 (ledger, payments, safeguarding, statements) | Ledger posting, payment settlement, CASS 15 reconciliation, statement generation |

✓ **Separation exists but incomplete:** Middle/Back are co-located in F2; Front/Middle gate is clear (identity ↔ payments).

---

## §4 OVERLAY + GAP ANALYSIS

### 4.1 Mandatory Functions Coverage Matrix

| Ideal Function | Present in OUR Structure? | Room/Floor | Status | Gap Note |
|---|---|---|---|---|
| **Retail Banking** | Partially | F1-customer-ops, F2-identity | PARTIAL | No explicit "Head of Retail"; customer-ops is generic; lacks retail product mgmt (savings, deposits specific) |
| **Business Banking** | Not evidenced | — | MISSING | No explicit business banking unit; corporate onboarding goes through generic customer-ops + kyb_onboarding (F3-aml) |
| **Payments/Rails** | Yes | F2-payments (FPS/SEPA/SWIFT/card/FX) | COVERED | ✓ Modulr integration, batch payments, beneficiary mgmt, FX engine; complete |
| **Treasury & ALM** | Partially | F3-treasury, F3-risk | PARTIAL | Treasury function exists; **ALCO committee not documented** — no formal liquidity/funding/FX decision framework visible |
| **Lending & Credit** | Not yet implemented | F2-payments (domain `lending` marked [pending ratification]) | PARTIAL / PENDING | Lending domain scaffolded but [pending ratification]; no credit committee documented; unclear if credit decisions gate exists |
| **Risk Management** | Yes | F3-risk (CRO/SMF4) | COVERED | ✓ Enterprise risk register, risk appetite, operational risk tracking |
| **Compliance & AML** | Yes | F3-aml (MLRO/SMF17) | COVERED | ✓ SAR filing, transaction monitoring, sanctions/adverse media, KYB screening; RED zone agents |
| **Finance & Accounting** | Partially | F3-finbi, F3-regrep + F2-ledger | PARTIAL | GL posting logic in ledger (F2); FX revaluation in fx_engine (F2); finance analytics in finbi (F3); but no unified "Head of Finance" — scattered across CFO-owned rooms |
| **Regulatory Reporting** | Yes | F3-regrep (CFO/SMF2) | COVERED | ✓ FIN060 generation, CASS 15 reporting, RegData submission; dbt models; HITL-L4 gate for sign-off |
| **Technology & Infrastructure** | Yes | F4-ai-platform, F4-devops, F4-security | COVERED | ✓ DevOps, CI/CD, monitoring, security (secrets, ATO, device-fp); AI/ML pipeline |
| **Internal Audit** | Yes | F4-audit-cell (Internal-Audit/SMF5) | COVERED | ✓ pgAudit, ClickHouse audit trail, compliance monitoring; **BUT independence risk (F4 floor conflates with devops)** |
| **Legal** | Combined in HR-Legal | F1-hr-legal | PARTIAL | ✓ Legal exists but **combined with HR** — limits independence on governance advice; no "Head of Legal" distinct from "Head of HR" |
| **HR & SMCR** | Yes | F1-hr-legal | COVERED | ✓ HR records, SMCR registration; but combined with Legal (independence concern) |
| **Customer Service & Complaints** | Yes | F1-support, F1-customer-ops | COVERED | ✓ Ticketing (support), complaints handling (customer-ops) + n8n routing; DISP rules enforced |
| **Data Protection & Privacy** | Not evidenced | — | MISSING | **No Data Protection Officer (DPO) role identified.** GDPR compliance likely embedded in hr-legal or compliance, but no explicit DPO. |

**Summary:** 10 COVERED / 4 PARTIAL / 2 MISSING

### 4.2 SM&CR Governance — SMF Lines Coverage

| SMF | Ideal Title | OUR Present? | Room | Owner | Gap |
|-----|---|---|---|---|---|
| SMF1 | CEO | ✓ Yes | F0 engine | CEO/SMF1 | ceo-conductor is PROPOSES-only (good); but no explicit Board reporting cadence documented |
| SMF2 | CFO | ✓ Yes | F3 finbi, regrep, treasury | CFO/SMF2 | ✓ Covered; treasury ownership clear |
| SMF3 | Head of Audit | ✗ Mapped as SMF5 | — | — | **Naming inconsistency:** SMF5 is "Internal Audit" in FSMA; function present but SMF3 not used |
| SMF4 | CRO | ✓ Yes | F3 risk | CRO/SMF4 | ✓ Covered |
| SMF5 | Head of Compliance (alternative) | ✗ Used for Internal Audit | F4-audit-cell | Internal-Audit/SMF5 | **Split decision:** MLRO (SMF17) handles AML/POCA; SMF5 handles audit. Architectural choice (MLRO≠SMF5). No dedicated "SMF16 Compliance Oversight" → **GAP: CCO function missing** |
| SMF6 | Head of Legal | ✗ Missing distinct role | — | — | **MISSING:** Legal is combined with HR in F1-hr-legal; no separate "Head of Legal" SMF line |
| SMF7 | Head of HR | Embedded in SMF24? | — | — | **Unclear:** HR function present (F1-hr-legal) but authority unclear; no distinct SMF7 identified |
| **SMF16** | **Head of Compliance Oversight / CCO** | ✗ **MISSING** | — | — | **P1 GAP:** Compliance oversight (distinct from MLRO's AML focus) not assigned; no "Chief Compliance Officer" |
| SMF17 | MLRO | ✓ Yes | F3-aml | MLRO/SMF17 | ✓ Covered; focused on AML/SAR; escalates to MLRO for threshold changes |
| SMF24 | COO | ✓ Yes | F1 customer-ops, support, hr-legal | COO/SMF24 | ✓ Covered; ops + customer service + HR/legal all under COO (large span) |
| SMF26 | CTO | ✓ Yes | F4 ai-platform, devops, security | CTO/SMF26 | ✓ Covered |
| **DPO** | **Data Protection Officer** | ✗ **MISSING** | — | — | **P2 GAP:** GDPR compliance not assigned to distinct role; likely buried in hr-legal or compliance |

**Summary:** 7 present (SMF1/2/4/5/17/24/26) / 2 ambiguous (SMF6/7) / 3 MISSING (SMF16, distinct SMF6, DPO)

### 4.3 Committee Governance Coverage

| Committee | Ideal? | OUR Documented? | Status | Gap |
|---|---|---|---|---|
| **Board Risk Committee** | Yes | No | MISSING | No formal Board Risk Committee governance recorded; risk escalation path unclear (should go to Board, not just MLRO) |
| **Board Audit Committee** | Yes | No | MISSING | No formal Audit Committee; audit-cell reports structure unclear (direct to Board? to CEO?) |
| **ALCO** | Yes | No | MISSING | Treasury function exists (F3) but no formal Asset-Liability Committee documented; liquidity/funding decisions unclear |
| **Credit Committee** | Yes | Not yet (lending [pending]) | MISSING / PENDING | No credit committee; lending function scaffolded [pending ratification]; lending approvals HITL-gate unknown |
| **Product Governance Committee** | Yes | No | MISSING | No formal product approval committee; no documented new-product gate beyond generic product management |
| **Consumer Duty Committee** | Yes | No | MISSING | PS22/9 compliance domain (`consumer_duty`) exists (F1) but no formal committee governance structure |
| **Operational Risk Committee** | Yes | No | MISSING | Risk register exists (F3-risk) but no formal ORC; incident response path unclear |
| **Sanctions/Compliance Steering** | Yes | No | MISSING | Sanctions screening exists (F3-aml) but no formal steering committee documented |

**Summary:** 0 documented / 8 MISSING

### 4.4 Three-Lines-of-Defence Alignment

| Line | Ideal | OUR Structure | Risk Assessment |
|---|---|---|---|
| **1st Line** | Business ops (F/M/B office) own & control risks | F1 (customer-ops, marketing, support), F2 (identity, payments, safeguarding), F3-aml (TM ops) | ✓ Functions present; **RISK: TM (transaction monitoring) in 2nd-line (F3-aml) not 1st-line ops** — architectural choice (compliance-owned TM). Acceptable if intentional (compliance embedding). |
| **2nd Line** | Risk/compliance oversight, policy, exceptions | F3-aml (MLRO), F3-risk (CRO), F3-regrep (CFO); F2-identity (KYC gate) | ✓ Present; strong compliance posture |
| **3rd Line** | Independent audit of 1st & 2nd | F4-audit-cell (Internal-Audit/SMF5) | ⚠ **INDEPENDENCE RISK:** F4 floor also houses devops/security/ai-platform (1st-line tech ops). Audit independence from CTO (shared floor authority) unclear. Ideal: separate reporting chain (audit → Board Audit Committee, not to CTO). |

**Verdict:** Three-Lines structure exists but **3rd-line independence may be compromised by co-location with technology ops on F4.**

### 4.5 Front/Middle/Back Office Alignment

| Office | Ideal Split | OUR Placement | Independence? |
|---|---|---|---|
| **Front** | Customer-facing, sales, onboarding | F1 (customer-ops, support, marketing) | ✓ Separate floor; good |
| **Middle** | AML/KYC gate, compliance, risk-scoring | F2-identity (KYC gate) + F3-aml (AML TM, sanctions) + F3-risk (risk scoring) | ⚠ **Split:** KYC in F2 (1st-line), AML/risk in F3 (2nd-line). Creates dependency: F2→F3 for approval. Acceptable (compliance-first) but increases latency. |
| **Back** | Ledger, settlement, FX, accounting, statements | F2 (ledger, payments, safeguarding, statements, FX) | ✓ Consolidated in F2; good separation from front |

**Verdict:** Front/Middle/Back split exists; Middle is compliance-owned (2nd-line), which is conservative but may create throughput bottlenecks for 1st-line payment approval.

---

## §5 INTERACTION GAPS

### 5.1 Vertical (Management Hierarchy)

**Ideal:** Board → C-suite (SMF lines) → Dept heads → Staff, with clear upward reporting.

**OUR Structure:**
```
Board
  ↑
  └─ CEO (F0 engine / ceo-conductor PROPOSES-only)
      ├─ CFO (F3 finbi/regrep/treasury)
      ├─ CRO (F3 risk)
      ├─ Internal-Audit (F4-audit-cell)
      ├─ MLRO (F3-aml)
      ├─ COO (F1 support/customer-ops/hr-legal)
      └─ CTO (F4 ai-platform/devops/security)
```

**Missing Documentation:**
- ⚠ **Board Risk Committee**: No formal governance structure connecting Board → CRO → risk decisions
- ⚠ **Board Audit Committee**: No formal governance connecting Board → Internal-Audit → audit findings/remediation
- ⚠ **Department heads**: No explicit heads of Retail, Business, Payments, Customer Service, etc. (rooms have no "head" role)
- ⚠ **Upward reporting cadence**: No documented weekly/monthly/quarterly escalation schedule
- ⚠ **HITL gate clarity**: Engine proposes; who accepts? (Implicit: room-head + SMF, but not documented)

### 5.2 Horizontal (Inter-Department Working Links)

**Documented in CONTACT-CHAIN-MATRIX-2026-07-25.md §3 (14 links proven):**
1. F2-identity ↔ F2-payments (KYC/KYB gates)
2. F2-payments ↔ F2-ledger (payment posting)
3. F2-ledger ↔ F2-safeguarding (recon read-side)
4. F2-safeguarding ↔ F3-regrep (shortfall reporting)
5. F3-aml ↔ F3-risk (alert → scoring)
6. F3-treasury ↔ F2-ledger (position recon)
7. F3-finbi ↔ F3-regrep (analytics → FIN060)
8. F2-payments ↔ F3-aml (transaction monitoring)
9. F1-customer-ops ↔ F2-identity (onboarding → KYC)
10. F1-support ↔ F1-complaints/customer-ops (ticket escalation)
11. F4-security ↔ F1-F3 (incident oversight)
12. F4-audit-cell ↔ F1-F3 (audit trail capture)
13. F1-marketing ↔ F1-customer-ops (referral → onboarding) [pending ratification]
14. F1-hr-legal ↔ all rooms (SMCR / legal oversight) [counsel-gated]

**Missing Documentation:**
- ⚠ **Committee flows**: No upward flows to Board Risk/Audit Committees
- ⚠ **ALCO coordination**: F3-treasury ↔ F3-risk ↔ CFO (liquidity/funding decisions) not documented
- ⚠ **Credit Committee**: F2-lending ↔ F3-risk ↔ F2-identity (credit approval gate) not documented [pending lending ratification]
- ⚠ **Product Governance**: No documented flow from product development (F1-marketing? F2-payments?) through compliance (F3-aml?), risk (F3-risk?), and consumer duty (F1-customer-ops?) for product approval
- ⚠ **Operational Risk Steering**: F4-audit-cell / F4-security / F3-risk incident routing unclear

### 5.3 Control Layers

**Documented:**
- ✓ I-27 HITL: Engine proposes; human decides (verified in CONTACT-CHAIN-MATRIX §4 step 2)
- ✓ I-24 Append-only: Audit trail (pgAudit + ClickHouse) — verified
- ✓ Ledger-read gate: Midaz balance queries (Banksy client-pm-friend, step 3) — verified LIVE
- ✓ Ledger-write gate: Payment initiation [counsel]-gated — verified declared, not auto-executed

**Missing Documentation:**
- ⚠ **HITL-L4 acceptance**: Who formally accepts/approves HITL proposals? (MLRO for SAR? CFO for FIN060? CEO for strategic?) — implicit, not explicit
- ⚠ **Escalation SLAs**: AML alert SLA (2s) documented; others (payment exception, recon discrepancy, compliance breach) not documented
- ⚠ **Rollback authority**: If an error is found, who can reverse a payment? (Likely ops head + SMF, not documented)

### 5.4 Regulatory Mapping

| Regulatory Requirement | Ideal Control | OUR Implementation | Gap |
|---|---|---|---|
| **FCA CASS 15 (Safeguarding)** | Daily recon, shortfall reporting, hold segregation | F2-safeguarding + recon + F3-regrep | ✓ Covered (IL-SAF-01 safeguarding-engine) |
| **MLR 2017 (AML/KYC)** | SAR filing, AML monitoring, EDD (£10k/£50k), sanctions screening | F3-aml (agents: MLRO, TM, sanctions, fraud) | ✓ Covered; RED zone agents with L3 autonomy |
| **PSR 2017 (Payments)** | Payment authentication, confirmation of payee, SEPA/FPS compliance | F2-payments (batch, FPS, SEPA, COP) | ✓ Covered |
| **GDPR Art.5 (Data Protection)** | Data minimization, consent recording, privacy impact assessments | F1-customer-ops (consent) + [DPO missing] | ⚠ **GAP: No DPO role** — consent recording exists; DPO governance missing |
| **FCA PS22/9 (Consumer Duty)** | Fair value, vulnerability, communications | F1-customer-ops (`consumer_duty` domain) + no formal committee | ⚠ **GAP: No Consumer Duty Committee** — domain exists; governance missing |
| **EU AI Act Art.14 (HITL Oversight)** | Human approval of AI decisions, documentation | F0 engine (I-27 HITL) + F4-audit-cell (logging) | ✓ Covered (HITL-L4 for SAR/FIN060/threshold; audit trail) |
| **SM&CR (Senior Managers Regime)** | Clear SMF accountabilities, training, fitness/propriety | F1-hr-legal (SMCR registration) + [no formal governance board] | ⚠ **GAP: No SMCR compliance committee** — registration exists; governance board missing |
| **POCA 2002 s.330 (SAR Filing)** | MLRO approval, reporting to NCA, timely filing | F3-aml (MLRO/SMF17) + HITL-L4 gate | ✓ Covered |

**Summary:** Most regulatory requirements covered at operational level; governance committees missing.

---

## §6 VERDICT & PRIORITY GAP LIST

### 6.1 All Identified Gaps (Prioritized)

#### **P1 GAPS — Regulatory/Governance Risk (Must fix before production)**

1. **Missing SMF16 — Chief Compliance Officer (CCO) / Head of Compliance Oversight**
   - **Current:** MLRO (SMF17) handles AML/POCA only; no distinct "compliance oversight" role
   - **Ideal:** CCO supervises compliance program (AML + GDPR + FCA PS + procedures), distinct from operational MLRO
   - **Impact:** Compliance program governance not clearly assigned; potential gap in "compliance program" effectiveness assessment (required by FCA)
   - **Recommendation:** Create F3 CCO role (distinct from MLRO); CCO reports to Board Audit Committee; defines compliance policies/frameworks; MLRO (AML-specific) reports to CCO
   - **Estimated effort:** Role definition + SMCR registration + reporting structure documentation

2. **No Data Protection Officer (DPO) — GDPR Compliance**
   - **Current:** Likely embedded in F1-hr-legal; no explicit GDPR program governance
   - **Ideal:** DPO reports to Board Audit Committee; owns GDPR compliance, privacy impact assessments, data subject rights
   - **Impact:** GDPR compliance program (Art.37 mandate) not formally documented; audit trail for consent (exists) not overseen by DPO
   - **Recommendation:** Assign DPO role (either external or internal); document data protection policy; establish quarterly DPO reporting to Audit Committee
   - **Estimated effort:** Role definition + GDPR program assessment + DPO contract/registration

3. **Audit Independence Compromise (F4 Floor Conflation)**
   - **Current:** F4-audit-cell (Internal-Audit/SMF5) shares floor with F4-devops/F4-security (1st-line tech ops); audit reports to CTO-managed organization
   - **Ideal:** 3rd-line audit independent from CTO; audit-cell reports directly to Board Audit Committee
   - **Impact:** Audit independence questionable; CTO may have undue influence over audit scope/findings; violates IIA Standards (independence)
   - **Recommendation:** Reorganize F4: move audit-cell reporting to Board Audit Committee (not CTO); physical/logical separation from devops/security; audit-cell remains on F4 but reports up, not to CTO
   - **Estimated effort:** Reporting structure change; governance documentation; no code changes needed

4. **No Board Risk Committee — Risk Governance**
   - **Current:** Risk decisions (appetite, limits, thresholds) documented in CONTACT-CHAIN-MATRIX but no formal Board committee structure
   - **Ideal:** Board Risk Committee (non-exec chair, CRO, CFO, CEO) sets risk appetite, approves frameworks, reviews material breaches
   - **Impact:** Risk escalation path from 1st-line ops → MLRO → CEO/Board not formally documented; risk appetite not formally approved by Board
   - **Recommendation:** Establish Board Risk Committee; monthly meetings; charter that includes: risk appetite approval, breach review, CRO appointment/remuneration, internal audit of risk function
   - **Estimated effort:** Committee charter + meeting cadence documentation + HITL gate (Board Risk approval for threshold changes) design

5. **No Board Audit Committee — Audit Governance**
   - **Current:** Audit-cell exists; no formal Board Audit Committee documented
   - **Ideal:** Board Audit Committee (non-exec chair, audit chair, CEO) approves audit plan, reviews findings, oversees internal/external audit independence, reports to Board
   - **Impact:** Audit independence not formally assured; no Board-level oversight of audit findings/remediation; SAR filing not formally reviewed by audit committee
   - **Recommendation:** Establish Board Audit Committee; quarterly meetings; charter that covers: audit independence, audit plan, findings review, SAR disclosure, remediation tracking, DPO reporting (once DPO added)
   - **Estimated effort:** Committee charter + meeting cadence + audit independence policy documentation

6. **No ALCO (Asset-Liability Committee) — Treasury Governance**
   - **Current:** Treasury function exists (F3-risk, F3-treasury); no formal ALCO governance documented
   - **Ideal:** ALCO (CFO chair, CRO, treasury head, CEO) quarterly; sets liquidity/funding/FX limits, approves funding plans, reviews interest rate risk
   - **Impact:** Liquidity/funding decisions not formally governed; FX exposure limits not formally approved; interest rate risk appetite not documented
   - **Recommendation:** Establish ALCO; define charter (liquidity governance, funding strategy approval, FX risk limits); quarterly Board reporting
   - **Estimated effort:** ALCO charter + treasury control framework + limits/appetite documentation + Board reporting cadence

#### **P2 GAPS — Operational/Structural Clarity (Must clarify before full scale-out)**

7. **No Credit Committee — Lending Governance [Pending Lending Ratification]**
   - **Current:** Lending domain scaffolded (F2-payments), but credit committee not documented; credit approval authority unclear
   - **Ideal:** Credit Committee (CRO chair, head of credit, CFO) approves lending decisions > £X threshold; reviews credit quality/provisioning
   - **Impact:** If/when lending launched, credit approval path not documented; potential breach of FCA Credit Risk standards (if applicable)
   - **Recommendation (if lending proceeds):** Establish Credit Committee; define lending approval matrix (authority by amount/type); document underwriting policy
   - **Estimated effort:** Deferred to lending delivery (IL-pending ratification)
   - **Gate:** Tied to F2-payments `lending` domain ratification

8. **No Product Governance Committee — Product Approval Framework**
   - **Current:** Product development (F1-marketing, F2-payments, F3-consumer_duty?) not explicitly gated through formal committee
   - **Ideal:** Product Governance Committee (COO chair, product heads, compliance, risk, consumer duty) approves new products, assesses consumer duty/fair value
   - **Impact:** Consumer Duty compliance (PS22/9) not formally gated for new products; product risk/compliance not formally assessed before launch
   - **Recommendation:** Establish Product Governance Committee; charter must include: consumer duty assessment, fair value check, conflict of interest review; quarterly Board reporting
   - **Estimated effort:** Committee charter + product approval policy + integration with compliance/risk/CTO for digital product review

9. **No Operational Risk Committee — Incident/Loss Event Governance**
   - **Current:** Incident response domain exists (F4-audit-cell, F4-security); no formal ORC documented; incident escalation path unclear
   - **Ideal:** ORC (CRO chair, COO, CTO, CFO, MLRO) monthly; reviews operational/cyber incidents, loss events, control failures
   - **Impact:** Operational risk register not formally governed; incident response SLAs not formally set; loss event RCA not formally reviewed by 2nd-line
   - **Recommendation:** Establish ORC; define incident classification/SLAs (critical: 2h escalation, major: 24h, etc.); monthly Board reporting of critical incidents
   - **Estimated effort:** ORC charter + incident classification policy + escalation SLA documentation

10. **No Consumer Duty Committee — PS22/9 Governance**
    - **Current:** `consumer_duty` domain in F1-customer-ops; no formal committee overseeing fair value/vulnerability/communications
    - **Ideal:** Consumer Duty Committee (COO chair, Head of Customer Service, Compliance, Risk, Finance) quarterly; assesses fair value delivery, vulnerable customer outcomes, conduct risk
    - **Impact:** PS22/9 compliance not formally governed; no quarterly Board reporting of consumer outcomes; no early warning of conduct risk
    - **Recommendation:** Establish Consumer Duty Committee; charter includes: fair value metrics, vulnerability program review, customer outcome monitoring, Board escalation of conduct breaches
    - **Estimated effort:** Committee charter + fair value metrics definition + vulnerability assessment framework + Board reporting cadence

11. **Legal Independence Concern — HR/Legal Combination**
    - **Current:** F1-hr-legal combines HR + Legal in single room under COO/SMF24
    - **Ideal:** Head of Legal reports independently to CEO (or Board General Counsel role) for governance advice; HR reports to COO/CHRO
    - **Impact:** Legal independence on Board/CEO governance matters may be compromised if HR head is same as General Counsel; conflicts possible
    - **Recommendation:** Separate roles: Head of Legal (→ CEO, governance advice) and Head of HR (→ COO, staff management); if not practical, ensure Legal function has direct Board access for non-HR matters
    - **Estimated effort:** Org chart clarification; governance documentation (legal escalation path)

12. **No SMCR Governance Committee — Senior Managers Regime**
    - **Current:** SMCR registration handled in F1-hr-legal; no formal Board/management oversight of SMCR compliance (fitness/propriety, training, conflicts)
    - **Ideal:** SMCR committee (Board chair, CEO, HR head, Internal Audit) reviews SMF certifications, manages conflicts, approves training policy
    - **Impact:** SMCR compliance not formally managed; fitness/propriety of SMFs not formally reviewed annually; potential FCA breach if FCA expects formal governance
    - **Recommendation:** Establish SMCR Governance Committee (can be a subcommittee of Board Audit or its own body); annual fitness/propriety review; training compliance tracking
    - **Estimated effort:** Committee charter + SMCR compliance framework + annual review process documentation

#### **P3 GAPS — Structural Clarity (Recommend for next sprint)**

13. **No explicit Retail/Business Banking Heads — Customer Segment Accountability**
    - **Current:** Customer-ops is generic; no Retail head or Business head; customer segmentation implicit in product teams
    - **Ideal:** Head of Retail (F1, reports to COO) and Head of Business (F1, reports to COO) own customer segments, product strategy, cross-sell
    - **Impact:** Customer segment accountability unclear; product roadmap may lack business banking perspective; no executive sponsor for SME/corporate growth
    - **Recommendation:** Clarify customer segment ownership: is it in customer-ops? Should it be separated into Retail/Business sub-teams? Document
    - **Estimated effort:** Org chart documentation; no code changes needed
    - **Note:** May be deferred if customer-ops is performing well across segments

14. **No explicit Finance Head — Finance Function Delegation**
    - **Current:** GL posting (ledger F2), FX revaluation (payments F2), financial statements (finbi F3), accounting (regrep F3); CFO/SMF2 owns finbi + regrep but finance operations scattered
    - **Ideal:** Head of Finance (reports to CFO) owns all GL/FX/accounting/financial statement preparation
    - **Impact:** Finance operations governance unclear; CFO coordination overhead; no single finance operations head for escalation
    - **Recommendation:** Clarify: does CFO directly own Finance operations, or is there a Head of Finance in F3 (regrep room) who coordinates F2 ledger + F3 finance? Document
    - **Estimated effort:** Org chart documentation; no code changes needed

15. **HITL Gate Acceptance Path — Not Explicitly Documented**
    - **Current:** I-27 HITL gates engine proposals; rooms (department heads) implicitly approve via room-head + SMF
    - **Ideal:** Explicit HITL acceptance authority: who approves SAR (MLRO)? FIN060 (CFO)? Threshold change (CEO)? Payment > £X (COO)? Documented
    - **Impact:** HITL gate authority implicit, not explicit; if disputed, escalation path unclear
    - **Recommendation:** Document HITL acceptance matrix: proposal type → approver role → SLA → escalation path (e.g., SAR → MLRO, 24h, escalate to CEO if not approved)
    - **Estimated effort:** HITL governance documentation (governance, not code)

### 6.2 Summary Table

| Gap ID | Gap | Severity | Type | Status |
|---|---|---|---|---|
| G-01 | Missing SMF16 (Chief Compliance Officer) | P1 | Governance | **[counsel]** |
| G-02 | Missing DPO (Data Protection Officer) | P1 | Regulatory (GDPR) | **[counsel]** |
| G-03 | Audit independence compromise (F4 conflation) | P1 | Governance/Audit | Recommend org restructure |
| G-04 | No Board Risk Committee | P1 | Governance | Recommend establish |
| G-05 | No Board Audit Committee | P1 | Governance | Recommend establish |
| G-06 | No ALCO (Asset-Liability Committee) | P1 | Governance | Recommend establish |
| G-07 | No Credit Committee | P2 | Governance | [Pending lending ratification] |
| G-08 | No Product Governance Committee | P2 | Governance | Recommend establish |
| G-09 | No Operational Risk Committee | P2 | Governance | Recommend establish |
| G-10 | No Consumer Duty Committee | P2 | Governance | Recommend establish |
| G-11 | Legal independence concern (HR+Legal combined) | P2 | Governance | Recommend clarify |
| G-12 | No SMCR Governance Committee | P2 | Governance | Recommend establish |
| G-13 | No explicit Retail/Business Banking heads | P3 | Org clarity | Deferred/non-blocking |
| G-14 | No explicit Finance Head | P3 | Org clarity | Deferred/non-blocking |
| G-15 | HITL gate acceptance path not documented | P3 | Governance clarity | Recommend document |

**Grand Total:** 15 gaps identified; **6 P1** (regulatory/critical) + **6 P2** (operational/structural) + **3 P3** (clarity/deferrable)

---

## §7 RECOMMENDATIONS

### 7.1 Immediate Actions (P1 — Before Production Launch)

1. **Engage counsel on SMF16 (CCO) and DPO roles** — FCA expects these roles to be clearly assigned and visible to regulators. Define role charter, reporting line, and SMCR registration.

2. **Restructure F4 audit independence** — Move audit-cell reporting to Board Audit Committee; remove CTO oversight of audit scope/findings.

3. **Establish Board Risk, Audit, ALCO committees** — Create committee charters; define authorities, meeting cadences, reporting structures.

4. **Document HITL acceptance matrix** — Create authoritative table: proposal type → approver → SLA → escalation.

### 7.2 Near-Term Actions (P2 — Within 60 days)

5. **Establish Product Governance, Operational Risk, Consumer Duty committees** — Define charters and Board reporting cadence.

6. **Clarify Legal independence** — Decide: separate Head of Legal from Head of HR, or ensure Legal has direct Board access for governance matters.

7. **Establish SMCR Governance Committee** — Implement annual fitness/propriety reviews of SMFs.

### 7.3 Deferred Actions (P3 — Next Sprint or Non-Blocking)

8. **Clarify Retail/Business Banking heads** — Document or reorganize customer segment accountability if needed.

9. **Clarify Finance Head role** — Ensure CFO has single point of contact for finance operations.

10. **Document interaction flows** — Create detailed runbooks for committee reporting, escalation paths, and inter-room coordination.

### 7.4 Governance Roadmap

```
Now (2026-07-25)          60 days (2026-09-25)         120 days (2026-10-25)
├─ P1 gaps identified      ├─ P2 governance in place     ├─ P3 clarity resolved
├─ CCO/DPO roles assigned  ├─ Committees chartered       ├─ All roledocs finalized
├─ Audit independence plan ├─ Board reporting cadence    ├─ FCA readiness audit
├─ HITL matrix documented  │  & SLAs live                │
└─ Board committees charter├─ Committee meetings start   └─ Production ready
                           └─ First month of reports
```

---

## §8 IDEAL-BANK REFERENCE (Classical Banking Pattern)

For future reference, here is the **ideal 4-floor classical bank architecture** (simplified):

```
┌─────────────────────────────────────────────────────────────────────┐
│                         BOARD OF DIRECTORS                          │
│  Audit Committee | Risk Committee | Remuneration | Product Gov. │    │
└─────────────────┬───────────────────────────────────────────────────┘
                  │
┌─────────────────┴───────────────────────────────────────────────────┐
│                         EXECUTIVE (C-SUITE)                         │
│  CEO | CFO | CRO | COO | CTO | General Counsel | Head of HR | MLRO │
│  SMF1 SMF2  SMF4  SMF24 SMF26   SMF6 (missing)   SMF7 (unclear) SMF17│
│  +    +     +     +     +       +                +                  │
│ SMF16 CCO (missing) | DPO (missing)                                 │
└──────┬─────────┬─────────┬──────────┬──────────┬────────────────────┘
       │         │         │          │          │
   ┌───┴─────┬───┴──────┬──┴─────┬───┴────┬────┴──────────────────┐
   │ F1      │ F2       │ F3     │ F4    │     F0                │
   │         │          │        │       │                       │
   │ Front   │ Banking  │ Risk & │ Tech  │ Engine                │
   │ Office  │ Core +   │Compliance+    │ (cerebral +            │
   │         │ Back-    │ Oversight     │  PROPOSES only)        │
   │         │ Office   │        │       │                       │
   │         │          │        │       │                       │
   │ Retail  │ Ledger   │ AML    │DevOps │ ceo-conductor          │
   │ Business│ Payments │ Risk   │Security│ banking-engine         │
   │ CRM     │ FX       │ Treas  │AI/ML  │ HITL gates            │
   │ Support │ Safeg    │ Regrep │Audit  │ compliance_kb          │
   │ Legal   │ Custody  │ Finance│Logging│                       │
   │ HR      │ KYC      │ ALCO   │Config │                       │
   │ Complaints          │(missing) │   │                       │
   │                     │        │       │                       │
   └─────────────────────┴────────┴──────┘                       │
                      ↑
                      └─────────────────────────────────────────┘
```

### Ideal 4-Floor Separation:
- **F1:** Front office (customer-facing, sales, support, HR, Legal)
- **F2:** Banking core (ledger, payments, KYC, settlements, safeguarding)
- **F3:** Risk & compliance oversight (AML, risk, treasury, reporting, finance oversight)
- **F4:** Technology & assurance (DevOps, security, audit, logging, config)
- **F0:** Engine (cerebral, decision support, PROPOSES-only, never autonomous)

---

## §9 CONCLUSIONS

### Our Structure: Strengths ✓
- ✓ Clear floor separation (F1–F4 + F0 engine)
- ✓ Compliance-first posture (RED zone AML agents, MLRO SMF17 authority)
- ✓ 3-line structure exists (1st: F1/F2 ops, 2nd: F3 risk/aml, 3rd: F4-audit)
- ✓ HITL governance (I-27 engine PROPOSES-only, L4-gates for SAR/FIN060)
- ✓ Most mandatory functions covered (payments, ledger, AML, reporting, audit)
- ✓ 7 SMF lines appointed (CEO/CFO/CRO/COO/CTO/MLRO/Internal-Audit)

### Our Structure: Gaps ⚠
- ⚠ **6 P1 Governance gaps:** CCO, DPO, audit independence, Board committees (Risk/Audit/ALCO)
- ⚠ **6 P2 Operational gaps:** Credit Committee, Product Governance, Operational Risk, Consumer Duty, Legal independence, SMCR Committee
- ⚠ **3 P3 Clarity gaps:** Retail/Business heads, Finance head, HITL acceptance paths

### Path Forward
All 15 gaps are **addressable through documentation and org-chart changes** (not code changes). Most critical: **engage counsel on CCO/DPO roles, restructure audit independence, and establish Board-level committees.** Estimated timeline to full ideal-bank alignment: **120 days (governance-heavy, not development-heavy).**

---

**FINAL STATEMENT:**

This analysis finds that **BANXE EMI's operating model is architecturally sound** but **lacks formal governance committee structure and clarity on certain leadership roles (CCO, DPO, legal independence).** The tech/domain placement (112 domains across 4 floors + engine) is excellent; the people/committee governance is nascent. Recommend treating governance gaps (G-01 through G-12) as **non-blocking parallel workstreams** (no code dependency) while product delivery continues; all can be resolved by Q4 2026.

**Disclaimer:** This analysis is advisory and grounded in verified facts (CONTACT-CHAIN-MATRIX, AGENT-REGISTRY, FABLE5-CONSULTATION-RESPONSE). Implementation of recommendations may require legal/regulatory counsel, especially for SMF/SMCR/DPO roles. Final authority rests with Board and GL-13-EXEC.

---

**Classification:** GOVERNANCE / FABLE-5 CONSULTATION / IDEAL-BANK TECHMAP + GAP  
**Status:** DOCS-ONLY / NO COMMIT  
**Date:** 2026-07-25  
**Prepared by:** Fable-5 External Consultant  
**This does not replace legal advice.**

---

## §CLOSURE (2026-07-25)

Gaps addressed — see `docs/audit/GOVERNANCE-GAP-CLOSURE-2026-07-25.md`:
- **CLOSED-docs (11):** 8 committees chartered (BANK-GOVERNANCE-COMMITTEES), Three Lines of Defence overlay + audit independence (THREE-LINES-OF-DEFENCE-MAP; audit-cell → Board Audit Committee, not CTO), Retail/Business & Finance owners named.
- **[counsel] / appointment pending (2):** CCO/SMF16, DPO — human regulated appointments (OPEN-GOVERNANCE-APPOINTMENTS), NOT closed by docs.
- **[pending human ratification] (2):** Legal/HR separation, HITL acceptance-path wording.

Committee charters ≠ operating committees; live operation needs appointments `[pending human ratification]`.
