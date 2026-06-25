# Banxe EMI — Delivery Roadmap Matrix

**Last Updated:** 2026-05-03
**Scope:** UK FCA-authorised EMI (Electronic Money Institution)
**Format:** Block → Sub-block → Status tracking; Phase 3 cluster snapshot per repo

> Priority scale: P0 = regulatory blocker (hard deadline), P1 = core banking must-have, P2 = operational, P3 = backlog

---

## Full Delivery Matrix

| Block | Sub-block | Description | Current Status | Priority | Deadline | Owner |
|-------|-----------|-------------|----------------|----------|----------|-------|
| **A — Customer Onboarding** | A-kyc | KYC individual — document verification, liveness check (PassportEye, DeepFace) | Spec-Locked — In Progress (IL-500; A-KYC-BUILD-SPEC; individual KYC onboarding orchestration; doc-verification + liveness + biometrics DELEGATED to licensed provider via KYCProviderPort — NO in-house biometrics; KYCCase/Decision model, risk-rating + EDD step-up, privacy-by-design GDPR/PII-Proxy; gates B-emi account creation, hands off to F-aml screening; A-idv pipeline = separate sibling) | P1 | Sprint 10 | CTIO |
| **A — Customer Onboarding** | A-idv | Identity verification pipeline — OCR + biometric matching | Spec-Locked — In Progress (IL-501; A-IDV-BUILD-SPEC; identity-verification pipeline; document OCR + biometric/liveness matching DELEGATED to licensed provider via KYCProviderPort — NO in-house OCR/biometrics; VerificationResult model (score/checks/evidence-refs), pass/fail/refer flow feeding A-kyc; privacy-by-design GDPR/PII-Proxy; A-kyc orchestrates, A-idv verifies) | P1 | Sprint 10 | CTIO |
| **A — Customer Onboarding** | A-kyb | KYB business — Companies House, UBO chain, director checks | Spec-Locked — In Progress (IL-502; A-KYB-BUILD-SPEC; business KYB onboarding orchestration; Companies House registry lookup DELEGATED via RegistryProviderPort, UBO chain >25% resolution, director checks; KYBCase/BusinessEntity/UBO/Director model, business risk-rating + EDD; UBOs/directors handed to A-idv/A-kyc (IDV) + F-aml (screening); gates B-emi business account; privacy-by-design GDPR/PII-Proxy; no in-house registry/IDV/AML reimpl) | P1 | Sprint 11 | CTIO |
| **B — Product Catalogue** | B-emi | EMI product definitions — e-money accounts, cards, IBAN | Spec-Locked — In Progress (IL-498; B-EMI-BUILD-SPEC; product catalogue: e-money account types + card products + IBAN issuance/allocation, config-as-data; defines → D-gl posts (account-to-GL mapping), rails route by IBAN (C-fps/C-sepa), E-safeguard segregates relevant-funds; no GL/rail/safeguarding reimpl) | P1 | Sprint 10 | CEO |
| **B — Product Catalogue** | B-pricing | Pricing rules, fee schedules, product tiers | Spec-Locked — In Progress (IL-512; B-PRICING-BUILD-SPEC; commercial pricing catalogue: ProductTier + PricingRule + published FeeSchedule, config-as-data/Decimal; rate source consumed by D-fee engine (B-pricing defines, D-fee computes), tiers assigned to B-emi products; Consumer Duty fair-value lifecycle define/activate/retire; no fee-engine/billing/GL reimpl) | P2 | Sprint 11 | CEO |
| **C — Payment Rails** | C-fps | UK Faster Payments (FPS) — send/receive, account validation | Spec-Locked — In Progress (IL-494; C-FPS-BUILD-SPEC promotes payment-rails-research; Modulr primary / ClearBank fallback; emits to D-recon Leg C + D-gl LedgerPort) | P1 | Sprint 10 | CTIO |
| **C — Payment Rails** | C-sepa | SEPA Credit Transfer + SEPA Instant — EU corridor | Spec-Locked — In Progress (IL-496; C-SEPA-BUILD-SPEC; SCT + SCT Inst; Modulr primary / ClearBank fallback; shared PaymentRailPort with C-fps; emits to D-recon Leg C + D-gl LedgerPort) | P1 | Sprint 11 | CTIO |
| **C — Payment Rails** | C-swift | SWIFT MT/MX — international wires, correspondent banking | Spec-Locked — In Progress (IL-517; C-SWIFT-BUILD-SPEC; international rail sibling of C-fps/C-sepa; SWIFT MT (MT103/MT202/COV) + MX ISO 20022 (pacs.008/009) with MT/MX coexistence, correspondent/NOSTRO-VOSTRO + cover payments, BIC validation, gpi/UETR tracking, STP vs repair; shared PaymentRailPort; mandatory F-aml pre-send sanctions gate + FATF Travel Rule, I-02 jurisdiction block; emits to D-recon Leg C + posts to D-gl LedgerPort; no GL/recon/AML reimpl) | P2 | Sprint 12 | CTIO |
| **D — Core Banking Engine** | D-gl | General Ledger — Midaz (LerianStudio) PRIMARY, Apache Fineract FALLBACK | Spec-Locked — In Progress (5% base; IL-484; D-GL-BUILD-SPEC) | P1 | Sprint 8 | CTIO |
| **D — Core Banking Engine** | D-fin | Financial Reporting — P&L, balance sheet, management accounts | Spec-Locked — In Progress (IL-485; D-FIN-BUILD-SPEC) | P1 | Sprint 10 | CEO |
| **D — Core Banking Engine** | D-fee | Fee Engine & billing — per-transaction fees, monthly charges, FX markup | Spec-Locked — In Progress (IL-488; D-FEE-BUILD-SPEC; billing activation operator-gated per ADR-090) | P1 | Sprint 10 | CTIO |
| **D — Core Banking Engine** | D-recon | Reconciliation Engine — Midaz ledger ↔ safeguarding accounts ↔ payment rails | Spec-Locked — In Progress (IL-474; D-RECON-BUILD-SPEC promotes D-RECON-DESIGN) | P1 | Sprint 9 | CTIO |
| **E — Treasury / ALM / Safeguarding** | E-treasury | Treasury management — liquidity, FX positions, ALM | Spec-Locked — In Progress (IL-519; E-TREASURY-BUILD-SPEC; operationalises ADR-078 read-only ports (FXExposurePort/NOSTROReconPort/LiquidityForecastPort); liquidity position+forecast+buffers, FX exposure monitoring, ALM maturity-ladder/gap analysis; LiquidityPosition/FXExposure/ALMLadder model, config-as-data; TreasuryAgent L2 + ≥£100k CFO sign-off HITL, no autonomous execution/trading; consumes D-gl/NOSTRO, feeds D-fin + E-capital liquidity input; treasury ≠ capital adequacy; no capital/reporting/rail/recon reimpl, no advice) | P2 | Sprint 12 | CEO |
| **E — Treasury / ALM / Safeguarding** | E-capital | Capital adequacy reporting — FCA ICARA (Internal Capital and Risk Assessment) | Spec-Locked — In Progress (IL-497; E-CAPITAL-BUILD-SPEC; ICARA own-funds/K-factor/FOR/wind-down; consumes D-fin; submits via K-gabriel; capital ≠ safeguarded funds) | P1 | Q3 2026 | CEO |
| **E — Treasury / ALM / Safeguarding** | E-safeguard | Safeguarding account management — segregated client funds (CASS 15) | Spec-Locked — In Progress (IL-474; E-SAFEGUARD-CASS15-SPEC) | P0 | **7 May 2026** | CEO + CTIO |
| **F — Compliance & Risk** | F-aml | AML/Sanctions/KYC screening — OpenSanctions/Yente, Watchman, Marble CM | ~80% DONE | P0 | DONE | CTIO |
| **F — Compliance & Risk** | F-fatca | FATCA/CRS tax reporting — US persons, CRS automatic exchange | Spec-Locked — In Progress (IL-514; F-FATCA-BUILD-SPEC; FATCA/CRS/DAC8 tax reporting; account-holder classification + tax-residency self-cert (from A-kyc) + reportable-account determination + FATCA/CRS XML generation; submits via K-gabriel-style port, HITL on filing (no autonomous submission); consumes A-kyc self-cert + B-emi/D-gl account data; privacy-by-design legal-obligation basis + PII Proxy; no KYC/GL/submission-engine reimpl, no tax/financial advice) | P2 | Sprint 11 | CEO |
| **F — Compliance & Risk** | F-finrpt | FIN-RPT regulatory returns — FCA Gabriel / RegData submissions | Spec-Locked — In Progress (IL-481; F-FINRPT-BUILD-SPEC, content core) | P0 | Q2 2026 | CEO |
| **G — Fraud Prevention** | G-rt | Real-time transaction fraud scoring — rule engine + ML model | Spec-Locked — In Progress (IL-510; G-RT-BUILD-SPEC; real-time transaction fraud scoring; rule engine (config-as-data) + ML score DELEGATED to Jube via jube_adapter (AGPLv3 internal-use-only, I-20/ADR-004); combined PASS/REVIEW/HOLD, HITL on high score (threshold config-as-data); EU AI Act Art.14 explainability + human override + stop path; I-27 no autonomous model/threshold update — CRO sign-off HITL; consumes G-device signals, hands AML to F-aml, fronted by I-api; no AML/device/ML-training reimpl) | P1 | Sprint 11 | CTIO |
| **G — Fraud Prevention** | G-device | Device fingerprinting, velocity checks, account takeover detection | Spec-Locked — In Progress (IL-511; G-DEVICE-BUILD-SPEC; device-signal source; privacy-minimised fingerprinting + velocity checks (config-as-data) + ATO/session-anomaly detection (impossible-travel, device-change); DeviceSignal/VelocityWindow/ATOAlert model; produces feature inputs → G-rt scoring (G-device = source, G-rt = consumer); captures from I-api context, integrates I-security IAM, no fraud-scoring/AML/IAM reimpl; privacy-by-design legitimate-interest fraud-only, no secondary use, CTO/CEO-gated activation) | P1 | Sprint 11 | CTIO |
| **H — Customer Operations** | H-crm | CRM — customer record, case history, DSAR (data subject access requests) | 0% | P2 | Sprint 12 | CEO |
| **H — Customer Operations** | H-support | Support ticketing, escalation workflows, SLA tracking | 0% | P2 | Sprint 12 | CEO |
| **I — Technology & Infrastructure** | I-infra | GMKtec compute, WSL2 dev, n8n orchestration, ClickHouse (TTL 5Y) | 70% DONE | P0 | ONGOING | CTIO |
| **I — Technology & Infrastructure** | I-security | OpenClaw hardening, PII Proxy (Presidio), Semgrep + CodeQL CI | 80% DONE | P0 | ONGOING | CTIO |
| **I — Technology & Infrastructure** | I-api | API Gateway — developer-facing endpoints, auth, rate limiting | Spec-Locked — In Progress (IL-508; I-API-BUILD-SPEC; developer/partner-facing REST gateway; OpenAPI contract, authN/authZ via Keycloak IAM (ADR-015) + API keys, rate limiting/quotas config-as-data, routing to banking services, versioning/idempotency/RFC-9457 errors; integrates I-security PII Proxy on egress + I-infra observability; fronts services, no service-logic/I-security reimpl; distinct from LiteLLM AI-routing gateway) | P1 | Sprint 10 | CTIO |
| **J — Safeguarding Engine** | J-engine | FCA PS10/15 + CASS 15 safeguarding engine — segregated accounts, daily reconciliation, FCA breach reporting | Spec-Locked — In Progress (IL-472; J-ENGINE-BUILD-SPEC promotes ADR-SAF-01) | P0 | **7 May 2026** | CEO + CTIO |
| **J — Safeguarding Engine** | J-audit | Safeguarding audit trail — immutable log to ClickHouse, FCA-producible evidence | Spec-Locked — In Progress (IL-472; J-CROSS-REPO-HANDOFF acceptance contract) | P0 | **7 May 2026** | CTIO |
| **K — Regulatory Reporting** | K-gabriel | FCA Gabriel / RegData returns — FIN-REP, EMI statistical returns | Spec-Locked — In Progress (IL-480; K-GABRIEL-BUILD-SPEC) | P0 | Q2 2026 | CEO |
| **K — Regulatory Reporting** | K-fscs | FSCS (Financial Services Compensation Scheme) reporting | Spec-Locked — In Progress (IL-491; K-FSCS-BUILD-SPEC) | P1 | Q3 2026 | CEO |
| **K — Regulatory Reporting** | K-nca | NCA SARs (Suspicious Activity Reports) — automated filing, MLRO workflow | Spec-Locked — In Progress (IL-492; K-NCA-BUILD-SPEC; MLRO-HITL, no autonomous filing) | P1 | Sprint 11 | CTIO |
| **L — Data Platform** | L-lake | Data Lake — ClickHouse analytics schema, event streaming | 30% DONE | P2 | Sprint 10 | CTIO |
| **L — Data Platform** | L-bi | BI / dashboards — management reporting, FCA KPI monitoring | 0% | P3 | Sprint 13 | CEO |
| **M — Developer Platform** | M-gateway | API Gateway — public REST API, OpenAPI spec, versioning | 0% | P2 | Sprint 12 | CTIO |
| **M — Developer Platform** | M-sdk | SDK — Python + JS client libraries | 0% | P3 | Sprint 14 | CTIO |
| **M — Developer Platform** | M-sandbox | Sandbox environment — test accounts, mock payment rails | 0% | P2 | Sprint 12 | CTIO |

---

## Status Summary

| Priority | Count | Done / In Progress | Remaining |
|----------|-------|--------------------|-----------|
| P0 (Regulatory blockers) | 7 | F-aml (~80%), I-infra/security (~70-80%), J-engine/J-audit (Spec-Locked, In Progress — IL-472), E-safeguard + D-recon (Spec-Locked, In Progress — IL-474), K-gabriel (Spec-Locked, In Progress — IL-480), F-finrpt (Spec-Locked, In Progress — IL-481) | — (P0 critical-path J→E→D→K→F-finrpt fully Spec-Locked) |
| P1 (Core banking) | 13 | D-gl (Spec-Locked, In Progress — 5% base, IL-484), D-fin (Spec-Locked, In Progress — IL-485), D-fee (Spec-Locked, In Progress — IL-488, billing operator-gated), K-fscs (Spec-Locked, In Progress — IL-491), K-nca (Spec-Locked, In Progress — IL-492, MLRO-HITL), C-fps (Spec-Locked, In Progress — IL-494, FPS send/receive + CoP), C-sepa (Spec-Locked, In Progress — IL-496, SCT + SCT Inst), E-capital (Spec-Locked, In Progress — IL-497, ICARA own-funds/capital-adequacy), B-emi (Spec-Locked, In Progress — IL-498, EMI product catalogue: e-money accounts/cards/IBAN, config-as-data), A-kyc (Spec-Locked, In Progress — IL-500, individual KYC orchestration; biometrics provider-delegated via KYCProviderPort, no in-house facial processing), A-idv (Spec-Locked, In Progress — IL-501, identity-verification pipeline; OCR + biometrics provider-delegated via KYCProviderPort, no in-house facial/document processing; feeds A-kyc), A-kyb (Spec-Locked, In Progress — IL-502, business KYB orchestration; Companies House registry + UBO chain + director checks provider-delegated, individuals to A-idv/A-kyc + F-aml; no in-house registry/IDV/AML reimpl), I-api (Spec-Locked, In Progress — IL-508, API Gateway; developer-facing REST + OpenAPI, authN/authZ via Keycloak IAM + API keys, rate limiting, routing to services; integrates I-security PII Proxy + IAM, no service-logic/I-security reimpl), G-rt (Spec-Locked, In Progress — IL-510, real-time transaction fraud scoring; rule engine + ML score via Jube adapter (internal-use, I-20), PASS/REVIEW/HOLD, HITL on high score, EU AI Act Art.14 explainability, I-27 CRO-gated no autonomous model update; consumes G-device, hands AML to F-aml), G-device (Spec-Locked, In Progress — IL-511, device-signal source; minimised fingerprinting + velocity + ATO detection feeding G-rt; privacy-by-design fraud-only legitimate-interest, no secondary use, CTO/CEO-gated; no fraud-scoring/AML/IAM reimpl) | All others 0% |
| P2 (Operational) | 9 | L-lake (30%), B-pricing (Spec-Locked, In Progress — IL-512, commercial pricing catalogue: tiers/rules/published fee schedules, config-as-data; rate source for D-fee engine, no fee-engine/billing reimpl), F-fatca (Spec-Locked, In Progress — IL-514, FATCA/CRS/DAC8 tax reporting; classification + reportable-account determination + FATCA/CRS XML, submits via K-gabriel pattern HITL-gated; consumes A-kyc self-cert + B-emi/D-gl; no KYC/GL/submission reimpl, no advice), C-swift (Spec-Locked, In Progress — IL-517, SWIFT international wires MT/MX + correspondent/NOSTRO; shared PaymentRailPort with C-fps/C-sepa, F-aml pre-send + FATF Travel Rule, gpi/UETR; emits D-recon Leg C + posts D-gl; no GL/recon/AML reimpl), E-treasury (Spec-Locked, In Progress — IL-519, treasury management; operationalises ADR-078 read-only ports; liquidity+FX exposure+ALM ladders, TreasuryAgent L2 + ≥£100k CFO HITL, no autonomous trading; consumes D-gl/NOSTRO, feeds D-fin/E-capital; treasury ≠ capital adequacy, no capital/reporting/rail reimpl) | All others 0% |
| P3 (Backlog) | 3 | 0 | All 0% |

---

## Critical Path (7 May 2026)

```
J — Safeguarding Engine (CASS 15)
  └── E-safeguard (segregated account management)
  └── D-recon (reconciliation engine)
  └── J-audit (ClickHouse audit trail)
  └── K-gabriel (FCA breach reporting workflow via n8n)
  └── P3.4 — Keycloak IAM cutover (service-to-service auth; ADR-015 banxe-emi-stack, ADR-016)
```

**Risk:** If J-engine is not deployed by 7 May 2026, Banxe cannot hold client funds and the FCA EMI authorisation is at risk of suspension.

---

## Notes

- **F-aml**: Compliance API running on port 8093, OpenSanctions/Yente integrated, Watchman minMatch=0.80, Marble CM active, 39/39 pytest passing. Remaining 20% = FATCA/CRS + FIN-RPT integration.
- **D-gl**: Midaz (LerianStudio) selected as primary GL in Sprint 8. LedgerPort adapter in design phase. **Update (IL-484):** build-spec locked — `docs/architecture/D-GL-BUILD-SPEC.md` consolidates the 5% (Midaz API research + bootstrap/provisioning runbooks + IL-FIN-01 GL/posting subsystem) into one actionable spec; Midaz PRIMARY single-SoT, Fineract FALLBACK via LedgerPort swap (no dual-write). Status → Spec-Locked / In Progress; runtime completion in banxe-emi-stack = separate operator-authorized action.
- **I-infra**: GMKtec EVO-X2 (128GB RAM, Ryzen AI MAX+ 395) operational. n8n, ClickHouse, OpenClaw, PII Proxy all running.
- **J-engine**: Zero implementation. This is the single largest regulatory risk. Sprint 9 must begin this block immediately. **Update (Sprint J, IL-472):** build-spec locked — `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` (promotes ADR-SAF-01) + `docs/safeguarding/J-CROSS-REPO-HANDOFF.md` (acceptance contract for banxe-emi-stack). Status: Spec-Locked → In Progress; implementation code is a separate operator-authorized action in the stack repo.
- **P3.4 (IAM)**: Keycloak IAM cutover for EMI realm `banxe-emi` — IN_PROGRESS. ADR-022 (decision record) to follow in next PR. Deadline: 2026-05-07 (FCA CASS 15). Backout: revert to local IAM (Legion) per `banxe-emi-stack docs/Keycloak-next-session-roadmap.md §IAM cutover plan v0.1`.

---

## Phase 3 — Delivery Phases (P3.x)

> P3.x phase numbers refer to Phase 3 delivery sprints and are distinct from the P0–P3 priority scale used in the Full Delivery Matrix above.

| Phase | Title | Owner | Status | Target Date | Depends On | Risk |
|-------|-------|-------|--------|-------------|------------|------|
| P3.4 | Keycloak IAM cutover (EMI realm) | Architecture WG / IAM lead | IN_PROGRESS | **2026-05-07** | banxe-emi-stack `docs/adr/ADR-015-auth-ports.md`; [ADR-016](../decisions/ADR-016-ai-plane-pii-aml-routing.md); banxe-emi-stack `docs/Keycloak-next-session-roadmap.md` | **P0** — FCA CASS 15 deadline |

### P3.4 detail — Keycloak IAM cutover (EMI realm `banxe-emi`)

**Deliverables**
- [ ] ADR-022 (IAM cutover decision record) — next PR in banxe-architecture
- [ ] Realm `banxe-emi` deployed on evo1 (:8180)
- [ ] OIDC discovery URL registered and reachable from EMI services
- [ ] Service-to-service tokens provisioned for: banxe-compliance-api, banxe-dashboard, deep-search, drive_watcher
- [ ] Mappers, audit log, rotation policy configured
- [ ] Backout procedure documented: revert to local IAM (Legion) per `Keycloak-next-session-roadmap.md`

**Exit criteria**
- [ ] All EMI services authenticate via Keycloak realm `banxe-emi` — no direct user/password in env
- [ ] INVARIANTS.md extended with IAM invariant (to be proposed in ADR-022)
- [ ] Pre-commit hook in banxe-emi-stack: block direct credentials in env files

**References**
- ADR-015 (Auth Ports — Keycloak): `banxe-emi-stack/docs/adr/ADR-015-auth-ports.md`
- ADR-016 (AI plane / PII routing): [decisions/ADR-016-ai-plane-pii-aml-routing.md](../decisions/ADR-016-ai-plane-pii-aml-routing.md)
- IAM cutover plan v0.1 (paper): `banxe-emi-stack/docs/Keycloak-next-session-roadmap.md §IAM cutover plan v0.1`

---

> **Note on P3.x vs priority scale:** Phase 3 delivery sprint numbers (P3.1, P3.2, …) are distinct from the P0–P3 priority scale used elsewhere in this matrix.

> **`reasoning` alias status:** `reasoning` (qwen3:235b-a22b) is **planning only**; not in production compliance flow until **P3.2 PASS** is recorded in §AI Plane — Alias status below (per ADR-016 / ADR-034).

## AI Plane — Alias status

Source of truth: `banxe-infra/ai-routing/policy.yaml`. ADR authority: ADR-034 (routes), ADR-016 (PII/AML routing), ADR-031 (execution policy).

| Alias | Backing model | Status | Production compliance allowed? | Notes |
|-------|--------------|--------|-------------------------------|-------|
| `ai` | qwen3.5:35b | **ACCEPTED** | Yes | Default Aider/Continue + compliance Q&A route |
| `ai-heavy` | llama3.3:70b | **ACCEPTED** | Yes | Heavy codegen + AML screening |
| `glm-air` / `glm-4.5-air-distributed` | GLM-4.5-Air-Q4_K_M (110.5B) | **ACCEPTED** | Yes | Distributed inference evo1↔evo2 (ADR-032); 32.52/21.47 tok/s benchmark |
| `reasoning` | qwen3:235b-a22b | **PENDING_PASS** | **NO — planning only** | Not in production compliance flow until P3.2 PASS recorded here |
| `banxe-general` | (router-defined) | **ACCEPTED** | Yes (non-PII) | General staff assistant |
| `fast` | (router-defined) | **ACCEPTED** | Yes (non-PII) | Routing, classification, <200ms |
| `coding` | (router-defined) | **ACCEPTED** | Yes | Code generation, PR review |

**P3.2 PASS criteria for `reasoning`:** operator records `P3.2 PASS` in this table (row `reasoning` → ACCEPTED) after benchmark verification and CTIO sign-off. Until then, any service calling `reasoning` for AML screening, KYC, SAR filing, or FIN060 generation is in violation of ADR-034 §Notes and I-33.

## Phase 3 Cluster Snapshot — per repo (2026-05-03)

Captures the state achieved on 2026-05-03 across the MetaClaw P3 sprints and the
banxe-infra ai-routing rollout. Cross-references ADR-031..ADR-034.

| Repo | Sprint owner (P3.x) | Live AI route | ufw posture | FCA CASS 15 dependency | Last commit |
|------|---------------------|---------------|-------------|------------------------|-------------|
| MetaClaw | P3.7 (verify pass — Grafana DS + 4 Prom targets) | `ai`, `ai-heavy` (Aider/Continue per ADR-034) | n/a (orchestrator-only repo) | indirect — drives observability for safeguarding stack | `598d15f` 2026-05-03 |
| banxe-infra | P3.2 (ai-routing finalize — `policy.yaml`) | binding artifact for `ai`, `ai-heavy`, `reasoning`, `glm-air`, `glm-4.5-air-distributed` | declares evo1/evo2/legion posture per ADR-033 | indirect — perimeter for safeguarding hosts | `2681a9a` 2026-04-12 |
| banxe-payment-core | P3.x (payment rails — Hyperswitch/Modulr) | none (no LLM call in path) | hosted on safeguarding-adjacent box; ADR-033 applies | direct — payment events feed daily recon | `7166476` 2026-04-13 |
| banxe-ui | P3.x (UI sync) | `ai` (dev-time codegen via Aider) | n/a | indirect — operator surface for safeguarding alerts | `cb7250a` 2026-04-12 |
| banxe-emi-stack | P3.7 (AI-PLUMBING + dbt/Blnk/Frankfurter live) | `reasoning` (planning), `ai` (codegen) | n/a (workloads on evo cluster — ADR-033) | direct — pgAudit, Blnk recon, FIN060 | `fe26fcb` 2026-05-03 |
| banxe-architecture | this PR (Phase 3 sync — 4 ADRs + matrix) | none (docs repo); meta-plane via Claude Code per ADR-031 | n/a | meta — defines the safeguarding architecture | `49b6bad` 2026-05-03 |
| banxe-platform | P3.x (UI Skills) | `ai` (dev-time) | n/a | indirect — platform shell for FCA-facing apps | `4f0ce18` 2026-04-15 |
| banxe-business-processes | P3.x (BPMN domain mapping) | none | n/a | direct — encodes CASS 15 daily-recon process | `e40af10` 2026-04-14 |
| MiroFish | P3.x (research agent) | `ai-heavy` (research/synthesis) | n/a | indirect — feeds compliance research, no client funds | `178a68a` 2026-04-12 |
| banxe-training-data | P3.x (training corpus) | none (datasets only) | n/a | indirect — training data; no live recon path | `12a13da` 2026-04-14 |
| guiyon | P3.x (legal project, separate plane) | none — must not share `ai`/`ai-heavy`/`reasoning` context with Banxe (I-18, I-20) | n/a | none — out-of-scope for CASS 15 | `34f15a2` 2026-04-15 |
| banxe-lexisnexis-distro | P3.x (legal distro packaging) | none | n/a | none — vendor distribution, not client-fund path | `4226525` 2026-04-12 |

### How to read this table

- **Live AI route** uses the alias names from ADR-034 (`ai`, `ai-heavy`, `reasoning`)
  and ADR-032 (`glm-air`, `glm-4.5-air-distributed`). `none` = the repo does not call
  any LLM in its runtime or build path.
- **ufw posture** values resolve to ADR-033. `n/a` means the repo itself is not a
  network-exposed surface (it is code, docs, or data); the runtime that hosts it still
  inherits the ADR-033 posture for whichever evo node it runs on.
- **FCA CASS 15 dependency** marks whether the repo participates in the safeguarding
  daily-reconciliation chain. `direct` = appears in the recon path or in FIN060;
  `indirect` = supports the recon path operationally; `meta` = defines the architecture;
  `none` = out-of-scope.
- **Last commit** is the short SHA + date of `git log -1` on each sister repo as of
  2026-05-03 (read-only inspection; no modifications were made to other repos).
