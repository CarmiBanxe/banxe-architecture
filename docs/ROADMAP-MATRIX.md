# Banxe EMI — Delivery Roadmap Matrix

**Last Updated:** 2026-04-06
**Scope:** UK FCA-authorised EMI (Electronic Money Institution)
**Format:** Block → Sub-block → Status tracking

> Priority scale: P0 = regulatory blocker (hard deadline), P1 = core banking must-have, P2 = operational, P3 = backlog

---

## Full Delivery Matrix

| Block | Sub-block | Description | Current Status | Priority | Deadline | Owner |
|-------|-----------|-------------|----------------|----------|----------|-------|
| **A — Customer Onboarding** | A-kyc | KYC individual — document verification, liveness check (PassportEye, DeepFace) | 0% | P1 | Sprint 10 | CTIO |
| **A — Customer Onboarding** | A-idv | Identity verification pipeline — OCR + biometric matching | 0% | P1 | Sprint 10 | CTIO |
| **A — Customer Onboarding** | A-kyb | KYB business — Companies House, UBO chain, director checks | 0% | P1 | Sprint 11 | CTIO |
| **B — Product Catalogue** | B-emi | EMI product definitions — e-money accounts, cards, IBAN | 0% | P1 | Sprint 10 | CEO |
| **B — Product Catalogue** | B-pricing | Pricing rules, fee schedules, product tiers | 0% | P2 | Sprint 11 | CEO |
| **C — Payment Rails** | C-fps | UK Faster Payments (FPS) — send/receive, account validation | 0% | P1 | Sprint 10 | CTIO |
| **C — Payment Rails** | C-sepa | SEPA Credit Transfer + SEPA Instant — EU corridor | 0% | P1 | Sprint 11 | CTIO |
| **C — Payment Rails** | C-swift | SWIFT MT/MX — international wires, correspondent banking | 0% | P2 | Sprint 12 | CTIO |
| **D — Core Banking Engine** | D-gl | General Ledger — Midaz (LerianStudio) PRIMARY, Apache Fineract FALLBACK | 5% — In Progress | P1 | Sprint 8 | CTIO |
| **D — Core Banking Engine** | D-fin | Financial Reporting — P&L, balance sheet, management accounts | 0% | P1 | Sprint 10 | CEO |
| **D — Core Banking Engine** | D-fee | Fee Engine & billing — per-transaction fees, monthly charges, FX markup | 0% | P1 | Sprint 10 | CTIO |
| **D — Core Banking Engine** | D-recon | Reconciliation Engine — Midaz ledger ↔ safeguarding accounts ↔ payment rails | 0% | P1 | Sprint 9 | CTIO |
| **E — Treasury / ALM / Safeguarding** | E-treasury | Treasury management — liquidity, FX positions, ALM | 0% | P2 | Sprint 12 | CEO |
| **E — Treasury / ALM / Safeguarding** | E-capital | Capital adequacy reporting — FCA ICARA (Internal Capital and Risk Assessment) | 0% | P1 | Q3 2026 | CEO |
| **E — Treasury / ALM / Safeguarding** | E-safeguard | Safeguarding account management — segregated client funds (CASS 15) | 0% | P0 | **7 May 2026** | CEO + CTIO |
| **F — Compliance & Risk** | F-aml | AML/Sanctions/KYC screening — OpenSanctions/Yente, Watchman, Marble CM | ~80% DONE | P0 | DONE | CTIO |
| **F — Compliance & Risk** | F-fatca | FATCA/CRS tax reporting — US persons, CRS automatic exchange | 0% | P2 | Sprint 11 | CEO |
| **F — Compliance & Risk** | F-finrpt | FIN-RPT regulatory returns — FCA Gabriel / RegData submissions | 0% | P0 | Q2 2026 | CEO |
| **G — Fraud Prevention** | G-rt | Real-time transaction fraud scoring — rule engine + ML model | 0% | P1 | Sprint 11 | CTIO |
| **G — Fraud Prevention** | G-device | Device fingerprinting, velocity checks, account takeover detection | 0% | P1 | Sprint 11 | CTIO |
| **H — Customer Operations** | H-crm | CRM — customer record, case history, DSAR (data subject access requests) | 0% | P2 | Sprint 12 | CEO |
| **H — Customer Operations** | H-support | Support ticketing, escalation workflows, SLA tracking | 0% | P2 | Sprint 12 | CEO |
| **I — Technology & Infrastructure** | I-infra | GMKtec compute, WSL2 dev, n8n orchestration, ClickHouse (TTL 5Y) | 70% DONE | P0 | ONGOING | CTIO |
| **I — Technology & Infrastructure** | I-security | OpenClaw hardening, PII Proxy (Presidio), Semgrep + CodeQL CI | 80% DONE | P0 | ONGOING | CTIO |
| **I — Technology & Infrastructure** | I-api | API Gateway — developer-facing endpoints, auth, rate limiting | 0% | P1 | Sprint 10 | CTIO |
| **J — Safeguarding Engine** | J-engine | FCA PS10/15 + CASS 15 safeguarding engine — segregated accounts, daily reconciliation, FCA breach reporting | 0% — ABSENT | P0 | **7 May 2026** | CEO + CTIO |
| **J — Safeguarding Engine** | J-audit | Safeguarding audit trail — immutable log to ClickHouse, FCA-producible evidence | 0% | P0 | **7 May 2026** | CTIO |
| **K — Regulatory Reporting** | K-gabriel | FCA Gabriel / RegData returns — FIN-REP, EMI statistical returns | 0% | P0 | Q2 2026 | CEO |
| **K — Regulatory Reporting** | K-fscs | FSCS (Financial Services Compensation Scheme) reporting | 0% | P1 | Q3 2026 | CEO |
| **K — Regulatory Reporting** | K-nca | NCA SARs (Suspicious Activity Reports) — automated filing, MLRO workflow | 0% | P1 | Sprint 11 | CTIO |
| **L — Data Platform** | L-lake | Data Lake — ClickHouse analytics schema, event streaming | 30% DONE | P2 | Sprint 10 | CTIO |
| **L — Data Platform** | L-bi | BI / dashboards — management reporting, FCA KPI monitoring | 0% | P3 | Sprint 13 | CEO |
| **M — Developer Platform** | M-gateway | API Gateway — public REST API, OpenAPI spec, versioning | 0% | P2 | Sprint 12 | CTIO |
| **M — Developer Platform** | M-sdk | SDK — Python + JS client libraries | 0% | P3 | Sprint 14 | CTIO |
| **M — Developer Platform** | M-sandbox | Sandbox environment — test accounts, mock payment rails | 0% | P2 | Sprint 12 | CTIO |

---

## Status Summary

| Priority | Count | Done / In Progress | Remaining |
|----------|-------|--------------------|-----------|
| P0 (Regulatory blockers) | 7 | F-aml (~80%), I-infra/security (~70-80%) | J-engine, J-audit, K-gabriel, F-finrpt, E-safeguard |
| P1 (Core banking) | 13 | D-gl (5%) | All others 0% |
| P2 (Operational) | 9 | L-lake (30%) | All others 0% |
| P3 (Backlog) | 3 | 0 | All 0% |

---

## Critical Path (7 May 2026)

```
J — Safeguarding Engine (CASS 15)
  └── E-safeguard (segregated account management)
  └── D-recon (reconciliation engine)
  └── J-audit (ClickHouse audit trail)
  └── K-gabriel (FCA breach reporting workflow via n8n)
```

**Risk:** If J-engine is not deployed by 7 May 2026, Banxe cannot hold client funds and the FCA EMI authorisation is at risk of suspension.

---

## Notes

- **F-aml**: Compliance API running on port 8093, OpenSanctions/Yente integrated, Watchman minMatch=0.80, Marble CM active, 39/39 pytest passing. Remaining 20% = FATCA/CRS + FIN-RPT integration.
- **D-gl**: Midaz (LerianStudio) selected as primary GL in Sprint 8. LedgerPort adapter in design phase.
- **I-infra**: GMKtec EVO-X2 (128GB RAM, Ryzen AI MAX+ 395) operational. n8n, ClickHouse, OpenClaw, PII Proxy all running.
- **J-engine**: Zero implementation. This is the single largest regulatory risk. Sprint 9 must begin this block immediately.
