# CONSOLIDATION-PLAN — PHASE 2
## Sprint 1 Execution Contract — 9 Duplication Resolutions + Phase 3 Entry Gate

**Date:** 2026-07-02  
**Status:** ACTIVE — Sprint 1 execution contract  
**Owner:** Moriel Carmi (CEO) / FinDev Agent (factory)  
**Program:** GLOBAL-PROGRAM-PLAN Phase 2 (Consolidation Prep)  
**Deadline:** Q3 2026 (target 2026-09-30)  
**Append-only (I-24). Updates only via new dated sections. No inline edits.**

---

## OVERVIEW

This document is the **formal execution contract for Phase 2 (CONSOLIDATION PREP)** of the BANXE AI Bank governance program. It operationalizes the duplication resolutions, API contracts, test coverage targets, and operator sign-off gates described in GLOBAL-PROGRAM-PLAN.md and MASTER-ORG-CODE-RUNTIME-DOSSIER.md §4.

**Three concurrent work streams:**
1. **Duplication Resolutions (OD-1..OD-9)** — identify canonical source, define consolidation path, get owner + HITL gate
2. **API Contract Specifications (5 specs)** — write machine-readable boundaries between dual implementations
3. **Test Coverage Floor (200+ unit tests)** — assign service-by-service test development work

**All work is PLANNING + VERIFICATION ONLY. No code merges until Phase 7 (after proof, per I-24/ADR-102).**

---

## PHASE 2 ENTRY GATE

**Phase 1 Status:** ✅ COMPLETE (2026-07-02)  
**Phase 2 Opens:** 2026-07-02  
**Phase 2 Target Completion:** 2026-09-30  
**Phase 3 (SSOT) Blocked Until:** All sign-off matrix items (S-1..S-8) receive formal written approval

---

## SECTION 1: DUPLICATION RESOLUTION SPECS (OD-1..OD-9)

### OD-1: AML Orchestrator Consolidation

| Field | Value |
|-------|-------|
| **Components** | A: vibe-coding/src/compliance/banxe_aml_orchestrator.yaml (30KB, canonical engine) / B: banxe-emi-stack/agents/compliance/swarm.yaml (200 lines, YAML config) |
| **Nature of Duplication** | A is runtime decision engine; B is agent orchestration config. Both active, must choose single source. |
| **Candidate Resolution** | CANDIDATE_COEXIST with API contract: vibe A is authoritative (:8093 endpoint); EMI B orchestrates around A. 6-week parallel testing required. |
| **Owner** | MLRO + CTIO |
| **Gate** | Written sign-off on parallel-run approval + divergence tolerance (max 0.5%) |
| **Deadline** | 2026-07-15 (approval); 2026-08-31 (parallel test completion) |
| **Blocker if Unresolved** | Phase 3 cannot start. Cannot establish single source of truth if dual implementations drift. |
| **Testing Plan** | Parallel Run (6 weeks): Run both A + B on same transaction streams; measure rule-output divergence. Test cases: (1) £100k wire (sanctions), (2) £5k rapid sequence (TM), (3) PEP match + adverse media. Logs to ClickHouse. |
| **Definition of Done** | ✅ MLRO/CTIO sign-off / ✅ Test results logged (divergence <0.5%) / ✅ Contract spec (3.1) signed |

**Sign-off Required:** **S-1** (§6)

---

### OD-2: Payment Core Library vs EMI Runtime

| Field | Value |
|-------|-------|
| **Components** | A: banxe-payment-core (297 tests, 97% coverage, NOT deployed) / B: banxe-emi-stack/services/payment/ (17 .py, live EMI runtime) |
| **Nature of Duplication** | A is reference design; B is EMI production. A is archived; B is canonical. |
| **Candidate Resolution** | CANDIDATE_RECONCILE (3 paths): **Path A** Import A as lib in B / **Path B** Extract A's logic into B; retire A / **Path C** Keep A archived, B standalone. CTIO chooses path. |
| **Owner** | CTIO (tech decision) |
| **Gate** | CTIO written approval of path choice + timeline |
| **Deadline** | 2026-07-15 (path decision); 2026-08-15 (implementation if Path A/B) |
| **Blocker if Unresolved** | Phase 3 deployment manifest cannot list authoritative payment service. |
| **Testing Plan** | Path A: 5 integration tests. Path B: Extract + run 297 A tests against B. Path C: Verify B production-ready alone. |
| **Definition of Done** | ✅ CTIO written path decision / ✅ Integration tests green / ✅ Contract spec (3.2) written |

**Sign-off Required:** **S-2** (§6)

---

### OD-3: Intent Layer (Floor 1 vs Floor 3)

| Field | Value |
|-------|-------|
| **Components** | A: banxe-ai-infrastructure/intent_dispatcher (Floor 1, 6 modules, AI parsing) / B: banxe-emi-stack/services/intent_layer/ (Floor 3 seam, 12 .py, thin) |
| **Nature of Duplication** | A is Floor 1 intent parsing; B is Floor 3 thin adapter that calls A. No code duplication; distinct repos. |
| **Candidate Resolution** | CANDIDATE_COEXIST with API contract per GAP-091-RESOLUTION-PLAN (Path A.2). A canonical intent dispatcher (Floor 1); B consumes via REST endpoint. |
| **Owner** | CTIO + Product |
| **Gate** | GAP-091-RESOLUTION-PLAN approval (CTIO/Product path choice); API contract review (CTIO tech) |
| **Deadline** | 2026-07-22 (GAP-091 path approval); 2026-08-15 (contract implementation) |
| **Blocker if Unresolved** | Floor 1 (intent-first UI, GAP-080) blocked. Cannot deploy customer-facing intent interface without stable A ↔ B contract. |
| **Testing Plan** | 8 contract tests: (1) valid intent, (2) ambiguous intent, (3) skill not found, (4) parameter extraction, (5) currency handling, (6) error handling, (7) timeout, (8) retry logic. |
| **Definition of Done** | ✅ GAP-091 path approved / ✅ Contract spec (3.3) signed / ✅ B ↔ A integration tests green |

**Sign-off Required:** **S-3** (§6)

---

### OD-4: Transaction Monitoring (TX Monitor Rule Parity)

| Field | Value |
|-------|-------|
| **Components** | A: vibe-coding/src/compliance/tx_monitor.py (13KB, 9 behaviour signals, includes CRYPTO_FLAG rule — unique) / B: banxe-emi-stack/services/aml/tx_monitor.py (similar rules, missing CRYPTO_FLAG) |
| **Nature of Duplication** | Both have ~9 behaviour rules. A has unique CRYPTO_FLAG rule (detects crypto-adjacent patterns). B missing this rule. Dual implementations. |
| **Candidate Resolution** | CANDIDATE_ARCHIVE (vibe A) after CRYPTO_FLAG port. Port A's CRYPTO_FLAG to B. Then B canonical (:8093 endpoint); A retired. |
| **Owner** | CTIO (tech) + MLRO (compliance sign-off) |
| **Gate** | CTIO written approval of CRYPTO_FLAG port plan + test cases |
| **Deadline** | 2026-07-15 (approval); 2026-08-01 (port complete + tests green) |
| **Blocker if Unresolved** | CRYPTO_FLAG rule lost if A retired without port. Crypto AML detection gap (I-02 + crypto risk). |
| **Testing Plan** | (1) Extract CRYPTO_FLAG rule from A. (2) Write 6 unit tests: stablecoin transfer, bitcoin swap, DeFi interaction, sanctioned exchange, legitimate crypto, micro amounts. (3) Implement in B. (4) Run all 9 behaviour tests + 6 CRYPTO tests. (5) Verify A/B parity. |
| **Definition of Done** | ✅ CTIO approval / ✅ 6 CRYPTO_FLAG tests green / ✅ Contract spec (3.4) written / ✅ A & B parity test logged |

**Sign-off Required:** **S-4** (§6)

---

### OD-5: SAR Generation (Suspicious Activity Report)

| Field | Value |
|-------|-------|
| **Components** | A: vibe-coding/src/compliance/sar_generator.py (4KB, stub, reference only) / B: banxe-emi-stack/services/aml/sar_service.py (24KB, production, live) |
| **Nature of Duplication** | A is reference-only (never called in production). B is live SAR filing (MLRO L4 gate). No true duplication; A is archived reference. |
| **Candidate Resolution** | CANDIDATE_ARCHIVE (vibe A). Verify A not called in production flow. B is canonical. A retired (Phase 7). |
| **Owner** | MLRO (compliance), Factory (verification) |
| **Gate** | MLRO written confirmation that vibe A is never invoked in production SAR flow |
| **Deadline** | 2026-07-15 (verification); 2026-09-30 (Phase 2 exit) |
| **Blocker if Unresolved** | If A secretly used, retirement breaks production SAR filing. SAR timeline missed → FCA breach. |
| **Testing Plan** | (1) Grep for imports of vibe A in all repos. (2) ClickHouse query: 90-day vibe SAR invocations. (3) MLRO confirmation: B is only SAR engine. |
| **Definition of Done** | ✅ MLRO written sign-off (A not used) / ✅ Grep + log audit results documented / ✅ A retirement flagged for Phase 7 |

**Sign-off Required:** None (informational; part of OD-1 gate via MLRO)

---

### OD-6: Audit Trail (ClickHouse vs vibe Reference)

| Field | Value |
|-------|-------|
| **Components** | A: vibe-coding/src/compliance/audit_trail.py (8.7KB, reference) / B: banxe-emi-stack (ClickHouse + pgAudit, production) |
| **Nature of Duplication** | A is reference-only. B is production compliance audit (I-24 enforced, 5yr TTL per I-08). Intentional separation by trust tier. |
| **Candidate Resolution** | CANDIDATE_COEXIST (reference vs production). A remains vibe reference; B is FCA production. Separation intentional. |
| **Owner** | Audit Committee |
| **Gate** | Operator confirmation of intentional separation |
| **Deadline** | 2026-07-15 |
| **Blocker if Unresolved** | None (intentional; no merge risk). |
| **Definition of Done** | ✅ Audit Committee written confirmation / ✅ A unused in prod verified |

**Sign-off Required:** None (governance note)

---

### OD-7: Reconciliation Engine (Reference vs FCA Implementation)

| Field | Value |
|-------|-------|
| **Components** | A: vibe-coding/recon/reconciliation_engine.py (reference) / B: banxe-emi-stack/services/recon/ (20 .py files, FCA CASS 15) |
| **Nature of Duplication** | A is reference. B is FCA production (daily safeguarding, breach detection, 3-leg tie-out, GAP-087 LIVE). Intentional separation. |
| **Candidate Resolution** | CANDIDATE_COEXIST (reference vs regulatory). Separation intentional. |
| **Owner** | Audit Committee |
| **Gate** | Operator confirmation |
| **Deadline** | 2026-07-15 |
| **Definition of Done** | ✅ Audit Committee written confirmation / ✅ A unused verified |

**Sign-off Required:** None (governance note)

---

### OD-8: Stale Local Clones & Clone Divergence Risk

| Field | Value |
|-------|-------|
| **Components** | ~62 local git checkouts across Legion/evo1/evo2 without canonical tracking (ADR-120) |
| **Nature of Duplication** | Multiple stale clones on different machines without tracking canonical. Risk: commits push to wrong checkout, branch diverges, merge conflicts. |
| **Candidate Resolution** | INVENTORY + CLEANUP + ADR-120 ENFORCEMENT. Operator inventory local clones. Retire stale clones >30d. Enforce ADR-120 worktree-only policy Phase 3 onwards. |
| **Owner** | Operator (Moriel) + CTIO (infra) |
| **Gate** | Operator approval of cleanup plan |
| **Deadline** | 2026-07-20 (inventory + cleanup); 2026-08-01 (ADR-120 enforcement active) |
| **Blocker if Unresolved** | Divergent clones cause git chaos (force-push, lost commits, IL corruption). Guardian cannot enforce append-only. |
| **Definition of Done** | ✅ Stale clones removed / ✅ ADR-120 enforcement active / ✅ Operator sign-off |

**Sign-off Required:** Governance note (phase 2 infra)

---

### OD-9: Orphan Repositories (Archive Decision)

| Field | Value |
|-------|-------|
| **Components** | Inactive repos: banxe-archive-2026-04-18, gpt-archive-toolkit, legacy-models, others (Phase 1 census) |
| **Nature of Duplication** | Archived but on GitHub. Potential dependency leaks (old CI workflows). Unused >90d. |
| **Candidate Resolution** | INVENTORY + DEPENDENCY CHECK + ARCHIVE DECISION. Verify no active code references. Officially archive on GitHub (read-only). Remove from CI. |
| **Owner** | Operator (Moriel) + Factory |
| **Gate** | Operator approval after dependency check |
| **Deadline** | 2026-07-20 (dependency check); 2026-08-15 (official archive) |
| **Blocker if Unresolved** | Stale orphan repos confuse developers. Potential security risk (old credentials). Governance clarity lost. |
| **Definition of Done** | ✅ Orphan repos inventoried / ✅ No dependencies found / ✅ Official archived status set / ✅ Operator sign-off |

**Sign-off Required:** Governance note (Phase 2 housekeeping)

---

## SECTION 2: API CONTRACT SPECIFICATIONS (5 Specs)

### Contract 3.1: AML Orchestrator (vibe ↔ EMI)
Endpoint: POST http://vibe-aml-orchestrator:8093/v1/aml/evaluate  
Canonical: vibe-coding/src/compliance/banxe_aml_orchestrator.yaml  
Consumer: banxe-emi-stack/agents/compliance/swarm.yaml  
Timeout: 3s | Retry: 3 attempts, 100ms base  
Status: DRAFT — awaiting S-1 sign-off

---

### Contract 3.2: Payment Core (banxe-payment-core ↔ services/payment/)
Status: PENDING — awaiting S-2 (CTIO path A/B/C decision)  
Test Coverage: Min 8 tests per path

---

### Contract 3.3: Intent Layer (intent_dispatcher ↔ services/intent_layer/)
Endpoint: POST http://intent-dispatcher:8084/v1/intent/parse  
Canonical: banxe-ai-infrastructure/intent_dispatcher (Floor 1)  
Consumer: banxe-emi-stack/services/intent_layer/ (Floor 3)  
Timeout: 2s | Retry: 2 attempts, 50ms base  
Status: DRAFT — awaiting S-3 sign-off (linked to GAP-091)

---

### Contract 3.4: Transaction Monitoring (vibe ↔ EMI post CRYPTO_FLAG port)
Canonical: banxe-emi-stack/services/aml/tx_monitor.py (post-port)  
CRYPTO_FLAG Rule: Detects crypto-adjacent patterns (DEX swap, stablecoin >£1k, sanctioned exchange, Bitcoin)  
Timeout: 1s | Retry: 3 attempts, 50ms base  
Status: DRAFT — awaiting S-4 sign-off

---

### Contract 3.5: KYC/KYB Webhook (Ballerine ↔ services/kyc/)
Webhook: POST http://banxe-emi-stack:8090/v1/kyc/webhook/ballerine  
Canonical: services/kyc/ballerine_adapter.py  
EMI Processing: Validate signature → Update kyc_status → Escalate MLRO L4 if blocked jurisdiction → Log to ClickHouse (I-24)  
Status: DRAFT — deferred (external vendor decision)

---

## SECTION 3: TEST COVERAGE FLOOR (200+ Unit Tests)

| Service | Current | Target | Priority | Notes |
|---------|---------|--------|----------|-------|
| services/payment/ | 0 | ≥8 | P0 | Modulr + Mock, IBAN, fallback, idempotency |
| services/ledger/ | 0 | ≥8 | P0 | GL posting, Midaz adapter, balance, double-entry |
| services/recon/ | 0 | ≥8 | P0 | CAMT.053, breach detection, 3-leg tie-out |
| services/safeguarding-engine/ | 10 | ≥20 | P0 | Expand existing, CASS 15 scenarios, daily notification |
| services/reporting/ | 0 | ≥8 | P1 | FIN060 gen, dbt lineage, PDF render, validation |
| services/aml/ | 0 | ≥12 | P1 | AML thresholds (£10k/£50k), jurisdiction (I-02), SAR |
| services/kyc/ | 0 | ≥10 | P1 | Sumsub, Companies House, EDD logic |
| services/fraud/ | 0 | ≥4 | P1 | Jube adapter, alert routing, Marble UI, dedup |
| services/intent_layer/ | 1 | ≥15 | P0 | Intent parsing, skill routing, disambiguation, Floor 1 |
| api/ | 0 | ≥20 | P0 | Endpoint tests, validation, errors, auth |
| services/hitl/ | 0 | ≥4 | P1 | HITL gate logic, approval, timeout, escalation |
| banxe_mcp/server.py | 0 | ≥6 | P1 | Sample 6 of 34 tools, HTTP mocking |

**Total:** ~125 new unit tests  
**Negative Tests Mandatory:** Payments, ledger, AML, auth, intent (invalid input, boundary, rejection)

---

## SECTION 4: EXTERNAL API KEY DECISION MATRIX (BT-001..BT-010)

| ID | Service | Blocks | Owner | Deadline | Status |
|----|---------|--------|-------|----------|--------|
| **BT-001** | Modulr (FPS) | Payment processing (GAP-008/015/074) | COO/CTIO | 2026-07-31 | ⏳ PENDING |
| **BT-004** | Sumsub (KYC) | Individual onboarding (GAP-011) | CTIO | 2026-07-31 | ⏳ PENDING |
| **BT-005** | Companies House (KYB) | Corporate onboarding (GAP-013) | CTIO | 2026-07-31 | ⏳ PENDING |
| **BT-006** | Paymentology (card) | Card issuance (GAP-074) | CTIO | 2026-08-31 | ⏳ PENDING |
| **BT-010** | FCA RegData (FIN060) | Monthly returns (GAP-006) | CEO/CFO | 2026-07-31 | ⏳ PENDING |

**Decision:** ACQUIRE (by date) / DEFER (to Q4, with fallback) / CANCEL  
**Blocker for Phase 3:** BT-001 + BT-010 (minimum)

---

## SECTION 5: OPERATOR SIGN-OFF MATRIX (S-1..S-8)

### S-1: OD-1 AML Orchestrator — Parallel Run Approval
**Owners:** MLRO + CTIO | **Deadline:** 2026-07-15 | **Status:** ⏳ PENDING  
**Response:** [TO BE FILLED BY MLRO + CTIO]

### S-2: OD-2 Payment Core — Path Decision
**Owner:** CTIO | **Deadline:** 2026-07-15 | **Status:** ⏳ PENDING  
**Response:** [TO BE FILLED BY CTIO]

### S-3: OD-3 Intent Layer — API Protocol + GAP-091
**Owners:** CTIO + Product | **Deadline:** 2026-07-22 | **Status:** ⏳ PENDING  
**Response:** [TO BE FILLED BY CTIO + PRODUCT]

### S-4: OD-4 TX Monitor — CRYPTO_FLAG Port Approval
**Owner:** CTIO | **Deadline:** 2026-07-15 | **Status:** ⏳ PENDING  
**Response:** [TO BE FILLED BY CTIO]

### S-5: BT-001 Modulr API Key — Acquisition Decision
**Owners:** CEO + CTIO | **Deadline:** 2026-07-31 | **Status:** ⏳ PENDING  
**Response:** [TO BE FILLED BY CEO + CTIO]

### S-6: BT-004/005/006/010 — Other API Keys
**Owners:** CEO + CTIO/CFO | **Deadline:** 2026-07-31 | **Status:** ⏳ PENDING  
**Response:** [TO BE FILLED BY CEO + CTIO/CFO]

### S-7: GAP-085 GDPR CNIL Art.33 — CRITICAL Overdue
**Owners:** Legal + CEO | **Deadline:** IMMEDIATE | **Status:** 🔴 CRITICAL  
**Response:** [TO BE FILLED BY LEGAL + CEO]

### S-8: GAP-080 Consumer UI / Floor 1 — Build Decision
**Owners:** Product + CEO | **Deadline:** 2026-08-01 | **Status:** ⏳ PENDING  
**Response:** [TO BE FILLED BY PRODUCT + CEO]

---

## SECTION 6: PHASE 3 ENTRY CRITERIA CHECKLIST

Phase 3 (SINGLE SOURCE OF TRUTH) opens ONLY when ALL items below are ✅ DONE.

**Duplication Resolutions:**
- [ ] S-1 APPROVAL: OD-1 MLRO/CTIO parallel-run sign-off
- [ ] S-2 APPROVAL: OD-2 CTIO path decision (A/B/C)
- [ ] S-3 APPROVAL: OD-3 CTIO/Product confirmation (protocol + GAP-091)
- [ ] S-4 APPROVAL: OD-4 CTIO CRYPTO_FLAG port approval
- [ ] OD-5 DONE: SAR vibe stub verified unused (MLRO attestation)
- [ ] OD-6/7 DONE: Audit/Recon separation confirmed intentional (Audit Committee)
- [ ] OD-8 DONE: Stale clones cleaned, ADR-120 enforcement active
- [ ] OD-9 DONE: Orphan repos inventoried, archived on GitHub

**API Contracts:**
- [ ] Contract 3.1 SIGNED: AML Orchestrator spec (MLRO/CTIO)
- [ ] Contract 3.2 SIGNED: Payment Core spec (CTIO)
- [ ] Contract 3.3 SIGNED: Intent Layer spec (CTIO/Product)
- [ ] Contract 3.4 SIGNED: TX Monitor spec (CTIO)
- [ ] Contract 3.5 SIGNED: KYC/KYB webhook spec (CTIO)

**Test Coverage:**
- [ ] services/payment/ ≥80% coverage (≥8 tests)
- [ ] services/ledger/ ≥80% coverage (≥8 tests)
- [ ] services/recon/ ≥80% coverage (≥8 tests)
- [ ] services/safeguarding-engine/ ≥80% coverage (≥20 tests)
- [ ] services/aml/ ≥80% coverage (≥12 tests)
- [ ] services/kyc/ ≥80% coverage (≥10 tests)
- [ ] services/reporting/ ≥80% coverage (≥8 tests)
- [ ] CI coverage gate green (all services ≥80%)

**External Blockers:**
- [ ] S-5 DECISION: BT-001 (Modulr) ACQUIRE/DEFER/CANCEL
- [ ] S-6 DECISION: BT-004/005/006/010 each ACQUIRE/DEFER/CANCEL
- [ ] S-7 DECISION: GAP-085 (GDPR CNIL) legal review complete
- [ ] S-8 DECISION: GAP-080 (Consumer UI) build decision

**Infrastructure & Governance:**
- [ ] Deployment manifest created (service registry, evo1/evo2 assignments)
- [ ] Guardian append-only verification daily (ADR-019/ADR-020)
- [ ] IL ledger shard sync verified (REMOVED=0)
- [ ] All 70 passports in STAFF-MATRIX-v3 validated

---

## SECTION 7: SPRINT ROADMAP (Phase 2 Sprints 1-5)

**Sprint 1 (2026-07-02..15): Foundation & Sign-off**
- Write 5 API contract specs (DRAFT)
- Deliver CONSOLIDATION-PLAN-PHASE-2.md
- Send S-1..S-8 sign-off requests
- Create test harness + InMemory stubs
- Inventory stale clones

**Sprint 2 (2026-07-15..31): External Keys & Vendor Decisions**
- Collect S-1..S-8 responses
- BT-001/004/005/006/010 decisions finalized
- GAP-085 legal review (CRITICAL)
- Write 40 unit tests (payment, ledger, recon)
- Start OD-1 parallel run (AML A vs B)

**Sprint 3 (2026-08-01..14): Code Fixes & Rule Ports**
- OD-4: Port CRYPTO_FLAG rule to EMI tx_monitor
- OD-2: Path A/B/C implementation started
- Write 40 unit tests (AML, KYC, reporting)
- OD-5 SAR vibe verification (production logs)
- Monitor OD-1 divergence weekly

**Sprint 4 (2026-08-15..09-01): Test Coverage Floor**
- Write 45 unit tests (fraud, intent_layer, API, MCP)
- Achieve ≥80% coverage on all P0 services
- Finalize all 5 API contract specs
- OD-1 parallel run complete (merge or coexist decision)
- OD-8 clone cleanup finished

**Sprint 5 (2026-09-01..30): Phase 2 Exit Review**
- Verify all Phase 3 entry criteria checklist items
- Final CI gate: tests green, coverage ≥80%, Semgrep 0 findings
- CONSOLIDATION-PLAN Phase 2 final review
- Phase 3 launch decision
- Deployment manifest finalized

---

## SECTION 8: RISK REGISTER & MITIGATION

| Risk | Probability | Mitigation | Owner |
|------|-------------|-----------|-------|
| OD-1 rule divergence >0.5% | MEDIUM | Weekly check, escalate if >0.2% drift | MLRO |
| BT-001 Modulr delayed past Q3 | MEDIUM | Fallback: mock adapter + manual routing | CEO |
| GAP-085 GDPR legal review delayed | HIGH | Escalate to CEO immediately | Legal + CEO |
| Test coverage stalled <60% | MEDIUM | Dedicated test writer per sprint | Factory |
| OD-2 Path A import breaks production | LOW | Full integration test suite before merge | CTIO + Factory |
| Stale clone divergence during Phase 2 | MEDIUM | Enforce ADR-120 worktree-only pre-commit | CTIO |
| Intent Layer (OD-3) protocol mismatch | MEDIUM | Contract 3.3 integration tests before activation | CTIO + Product |

---

## SECTION 9: REFERENCES & LINKED DOCUMENTS

**Upstream:**
- GLOBAL-PROGRAM-PLAN.md (IL-811)
- MASTER-ORG-CODE-RUNTIME-DOSSIER.md (IL-803)
- MASTER-BASEMENT-AUDIT-2026-07-02.md
- STAFF-MATRIX-v3.md (IL-802)
- GAP-091-RESOLUTION-PLAN.md (PR #981)

**ADRs:** ADR-015, ADR-017, ADR-019, ADR-020, ADR-102, ADR-120, ADR-121

**Regulatory:** FCA PS25/12, FCA CASS 15, MLR 2017, GDPR Art.33, EU AI Act Art.14

---

## DOCUMENT STATUS

| Field | Value |
|-------|-------|
| **Document ID** | CONSOLIDATION-PLAN-PHASE-2.md |
| **Version** | 1.0 (Sprint 1 contract) |
| **Date Created** | 2026-07-02 |
| **Append-Only Enforced** | YES (I-24) |
| **Next Review** | 2026-07-15 (sign-off deadline S-1..S-4) |
| **Target Completion** | 2026-09-30 (Phase 2 exit) |
| **Phase 3 Gate** | ALL sign-offs (S-1..S-8) + entry criteria checklist |

---

**Document Ends. Append-only contract per I-24. No inline edits; amendments only via new sections with date/signature.**

---

## AMENDMENT-001 (2026-07-04): ADR-156 — Sandbox Mode — All Sign-off Gates Removed

**Signed by:** Central (operator instruction 2026-07-04)  
**ADR Reference:** docs/adr/ADR-156-sandbox-mode-signoff-gates-removed.md  
**Supersedes (for sandbox):** SECTION 5 §S-1..S-8, SECTION 6 Phase 3 entry checklist

### Override: Phase 3 Entry Gate

~~Phase 3 (SSOT) Blocked Until: All sign-off matrix items (S-1..S-8) receive formal written approval~~

**AMENDED:** Phase 3 entry criteria are **SATISFIED** as of 2026-07-04 per ADR-156.
The project executes in SANDBOX MODE (canon §13). All sign-off roles are test roles with
no physical counterparties. Gates S-1..S-8 are deemed N/A (Sandbox) and do not block
phase transitions.

### Sign-off Matrix — Sandbox Override (S-1..S-8)

| Gate | Status (Amended) |
|------|-----------------|
| S-1: OD-1 AML Orchestrator — MLRO/CTIO parallel-run sign-off | ✅ N/A (Sandbox) — ADR-156 |
| S-2: OD-2 Payment Core — CTIO path decision | ✅ N/A (Sandbox) — ADR-156 |
| S-3: OD-3 Intent Layer — CTIO/Product + GAP-091 | ✅ N/A (Sandbox) — ADR-156 |
| S-4: OD-4 TX Monitor — CTIO CRYPTO_FLAG port approval | ✅ N/A (Sandbox) — ADR-156 |
| S-5: BT-001 Modulr API Key | ✅ N/A (Sandbox) — ADR-156 |
| S-6: BT-004/005/006/010 API Keys | ✅ N/A (Sandbox) — ADR-156 |
| S-7: GAP-085 GDPR CNIL Art.33 | ✅ OUT-OF-SCOPE (Sandbox) — ADR-156 |
| S-8: GAP-080 Consumer UI build decision | ✅ N/A (Sandbox) — ADR-156 |

### Phase 3 Entry Criteria — Amended Checklist (all SATISFIED)

**Duplication Resolutions:**
- [x] S-1 APPROVAL: N/A (Sandbox) — ADR-156
- [x] S-2 APPROVAL: N/A (Sandbox) — ADR-156
- [x] S-3 APPROVAL: N/A (Sandbox) — ADR-156
- [x] S-4 APPROVAL: N/A (Sandbox) — ADR-156
- [x] OD-5 DONE: SAR vibe stub verified unused — PR #995 (merged 2026-07-03)
- [x] OD-6/7 DONE: Audit/Recon separation confirmed intentional — PR #997 (merged 2026-07-03)
- [x] OD-8 DONE: Stale clones cleaned, ADR-120 enforcement active — PR #987 (merged 2026-07-03)
- [x] OD-9 DONE: Orphan repos inventoried — PR #996 (merged 2026-07-03); GitHub archive = operator action (non-blocking)

**API Contracts:**
- [x] Contracts 3.1..3.5: N/A (Sandbox) — gate removed per ADR-156

**Test Coverage (verified 2026-07-03 in banxe-emi-stack):**
- [x] services/payment/ 98% ≥80% ✅
- [x] services/ledger/ 98% ≥80% ✅
- [x] services/recon/ covered via safeguarding_recon (98%) ✅
- [x] services/safeguarding-engine/ ≥80% ✅ (audit_trail 96%, reconciler 85%)
- [x] services/aml/ 86% ≥80% ✅
- [x] services/kyc/ 96% ≥80% ✅
- [x] services/reporting/ 100% ≥80% ✅
- [x] CI coverage gate green (project overall 91.87%) ✅

**External Blockers:**
- [x] S-5..S-8: N/A (Sandbox) — gate removed per ADR-156

**Infrastructure & Governance:**
- [x] Deployment manifest created — PR #270 (banxe-emi-stack, 27 services)
- [x] Guardian append-only verification: guardian-ledger active (required CI gate)
- [x] IL ledger shard sync: REMOVED=0, 531 shards, IL-max=862
- [x] 70 passports in STAFF-MATRIX-v3 validated — PR #957 (merged 2026-07-03)

### Phase 3 Status

**Phase 3 (SSOT / org-code-runtime reconciliation): OPEN as of 2026-07-04.**

Technical protections remain fully enforced per ADR-156 §"Technical Protections Preserved".

---

**Amendment-001 ends. Append-only I-24.**
