# GLOBAL PROGRAM PLAN — BANXE AI BANK
**Date:** 2026-07-02  
**Author:** Moriel Carmi (CEO)  
**Status:** ACTIVE  
**Scope:** 8-phase orchestrated governance delivery (phases 1-3 active, phases 4-8 planned)  

---

## PROGRAM NAME & MANDATE

**MASTER-ORG-CODE-RUNTIME-DOSSIER: Full Bank Governance Delivery (2026-2027)**

Eight-phase program to establish canonical governance, compliance, and operational readiness for BANXE AI Bank EMI platform (P0 deadline: 7 May 2026 — CASS 15, now extended through 2026 for consolidation).

---

## PHASES & DELIVERABLES

| Phase | Name | Timeline | Output | Status |
|-------|------|----------|--------|--------|
| **1** | MASTER DOSSIER | Q2-Q3 2026 | MASTER-ORG-CODE-RUNTIME-DOSSIER.md (7 sections: census, 4-floor, system-of-record, duplicates, thin zones, sprint roadmap, consolidation prerequisites) | 🟡 IN PROGRESS |
| **2** | CONSOLIDATION PREP | Q3 2026 | Resolution plans for all duplicates (banxe_aml_orchestrator.yaml dup, vibe-coding overlap analysis); reconciliation gates signed off by MLRO/CEO | PLANNED |
| **3** | SINGLE SOURCE OF TRUTH (SSOT) | Q3 2026 | Unified domain map, service registry, agent passport authoritative location; migration plan from 3-repo to 2-repo stable state | PLANNED |
| **4** | RUNTIME HARDENING | Q4 2026 | Guardian activation (ADR-019/020), memory governance enforcement, pre-commit hook upgrade, HITL-MATRIX wiring to all agents | PLANNED |
| **5** | DEPARTMENT-HEAD DEEP-BUILD | Q4 2026 | Activation of proposed swarm agents (MLRO/Audit/Finance/COO lines); all 70 passports operational under I-27 HITL-L4 governance | PLANNED |
| **6** | EXTERNALIZE & PARTNER | Q1 2027 | BaaS API contract + external partner routing; wind-down protocols (GAP-057); AGPL-boundary resolution (GAP-081) | PLANNED |
| **7** | COMPLIANCE CERTIFICATION | Q2 2027 | Final FCA pre-authorisation audit (SM&CR, CASS 15, Consumer Duty); sign-off on all invariants (I-01..I-28) | PLANNED |
| **8** | PRODUCTION HANDOFF | Q2 2027 | Cutover to customer production; operator → SMCR team transition; Guardian autonomous (3-layer governance lock) | PLANNED |

---

## NON-NEGOTIABLE RULES

1. **I-24 Enforcement (Append-Only Audit):** No edits to INSTRUCTION-LEDGER.md, GAP-REGISTER.md, constitution/amendments/. Guardian blocks inline changes. All updates via new entries or amendment-NN.md files.

2. **I-27 HITL Discipline:** All AI agents operate at L1-L4 autonomy. L3+ decisions require human review gate (Marble UI / MLRO Telegram bot). No autonomous activation of compliance decisions.

3. **Domain Isolation (Compliance Boundary):** AML/KYC/fraud/reporting/reconciliation services remain **isolated** from core payment/ledger logic. API contracts only; no direct imports between domains.

4. **Memory Governance (ADR-020):** 10 mandatory memory sources (MEMORY.md, IL, GAP-REGISTER, PROMPT-CANON, HITL-MATRIX, constitution, decisions/, ADRs, passports, sprints) must be loaded and validated by Guardian on every major execution. Guardian blocks execution if any source is unread for >7 days.

5. **FCA Deadline Extension:** P0 (CASS 15) items must meet functional completion by Q3 2026. External blockers (BT-001..BT-010 API keys) are operator responsibility (CEO/CTIO); AI agents cannot proceed without formal sign-off on all 5 open regulatory gaps (GAP-079..086).

---

## CURRENT PHASE: PHASE 1 (MASTER DOSSIER)

**Status:** 🟡 IN PROGRESS (Research reports analyzed; consolidated dossier in production)

**Key Milestones:**
- ✅ EMI service census (109 services, 1,931 tests, 696 source files)
- ✅ vibe-coding analysis (179 modules, 0 coupling to EMI stack)
- ✅ GAP-REGISTER audit (83 total; 5 open P0/FCA blockers; 76% L2-complete)
- ✅ Runtime & ADR inventory (37 ADRs, 70 agent passports, 5-layer docker stack)
- ✅ STAFF-MATRIX-v3 (70 total passports; all 4 department lines + support stubs active)
- ✅ Full repo census (33 GitHub repos catalogued + 1 EXCLUDED; 62 local checkouts; duplicate clone risks documented — §8 ADDENDUM)

**Deliverable:** MASTER-ORG-CODE-RUNTIME-DOSSIER.md (this document) — canonical governance reference (append-only, enforced by Guardian).

**Next Step:** Phase 2 consolidation prep (operator approval required on all duplication resolutions).

---

## REFERENCE DOCUMENTS

- **MASTER-ORG-CODE-RUNTIME-DOSSIER.md** — Phase 1 output (7 sections: full inventory, system of record, duplicates, thin zones, roadmap, prerequisites)
- **ADR-019** — AI Guardian architecture (two-family governance)
- **ADR-020** — Memory governance (append-only contracts)
- **INSTRUCTION-LEDGER.md** — Operator purchase log (IL-803 max)
- **HITL-MATRIX.yaml** — HITL gate definitions (17 gates, L1-L4 autonomy)
- **PLANES.md** — Three-plane isolation (Developer / Product / Standby)


---

## Phase Status Amendment — 2026-07-02

| Phase | Previous Status | New Status | Date | IL |
|-------|----------------|-----------|------|-----|
| 1 | 🟡 IN PROGRESS | ✅ COMPLETE | 2026-07-02 | IL-803 |
| 2 | PLANNED | 🟡 IN PROGRESS | 2026-07-02 | IL-811 |

*Append-only amendment per I-24. Original table above unchanged.*
