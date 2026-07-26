# CANONICAL-ORG-CHART-v2 — Banxe AI Bank Organisational Canon (NORMATIVE)

> **Status:** Sprint-1 CANONICAL ORG FREEZE (2026-06-21). **Normative layer** of the architecture.
> **Authority:** This document is the single source of truth for the bank's top-level organisational
> structure. On any conflict with `docs/ORG-STRUCTURE.md`, `docs/DEPARTMENT-MAP.md`,
> `docs/COMPLIANCE-MATRIX.md` or `COMPLIANCE-ARCH.md`, **this canon wins** for org-structure questions;
> those documents remain authoritative for their own per-agent / per-control detail.
> **Scope guard:** Sprint 1 freezes the *structure*. It does NOT enumerate the full worker-level staff
> matrix (that is Sprint 2). Sections are based on a physical audit of the repos, not memory.

## 1. Purpose

Establish and freeze the canonical, unambiguous top-level organisation of Banxe AI Bank as a normative
architectural layer, so that `docs ↔ governance ↔ code` are aligned, duplication and contradictions are
removed, independent regulatory lines are correctly separated, and Sprint 2 (Staff Matrix) has a stable
base. This replaces the scattered/implicit org views with one authoritative chart.

## 2. Principles

1. **One owner per function** — every mandatory function has exactly one accountable line; no function is
   duplicated across two heads and none is left without an owner.
2. **Independent regulatory lines are structurally separate** — MLRO/Financial-Crime and Internal Audit
   are NOT inside any executive department; they report to the Board on their own lines.
3. **SM&CR-anchored** — every department head maps to an FCA Senior Management Function (SMF) human.
4. **Human-double only at department-head / independent-line level** — Level 2 heads and the Level 1
   independent agents carry a `human_double`; Level 3/4 agents escalate to their head (do not carry one).
5. **Three Lines of Defence preserved** — 1st = business, 2nd = risk/compliance, 3rd = internal audit.
6. **Code-aligned, not aspirational** — structure reflects what exists (passports + emi-stack services)
   plus the mandatory functions that MUST exist in the target model (flagged, not invented).
7. **Minimal breakage** — supersedes by annotation/pointer; existing docs are not rewritten destructively.

5. **Unitary executive authority (pointer)** — единоначалие CEO (SMF1) как конституционный принцип
   провозглашено в `docs/canon/CEO-UNITARY-AUTHORITY-CANON.md` (NORMATIVE, **RATIFIED 2026-07-27**, CEO Moriel Carmi SMF1; STEP10/12): sole
   accountable executive, исключения только SMF17/SMF5-линии (§4 ниже), комитеты готовят — решает CEO.
6. **No-credit perimeter (pointer)** — BANXE EMI не предоставляет кредитных продуктов; Annex III §5
   out-of-scope: `docs/canon/NO-CREDIT-PRODUCTS-CANON.md` (STEP13, PROPOSED).

## 3. The 8 Core Departments

| # | Department | SM&CR owner | Line of Defence |
|---|------------|-------------|-----------------|
| 1 | **Board & Executive** | CEO (SMF1) | Governing body |
| 2 | **Independent Functions — Risk · Compliance** | CRO (SMF4) · Head of Compliance | 2nd Line |
| 3 | **CFO Office** | CFO (SMF2) | 1st/2nd Line |
| 4 | **COO / Operations** | COO (SMF24) | 1st Line |
| 5 | **CTO / Technology, Data, AI** | CTO (SMF26) | 1st Line |
| 6 | **MLRO / Financial Crime** *(independent line)* | MLRO (SMF17) | 2nd Line — **independent, reports to Board** |
| 7 | **Front Office / Business** | CCO | 1st Line |
| 8 | **HR, Legal, Corporate Services** *(incl. DPO)* | HR/Legal lead · DPO | 2nd Line (DPO/Legal) |

> **Internal Audit (SMF5)** is the **3rd independent line** — it is NOT a department under any executive;
> it reports to the **Audit Committee / Board** (see §4).

## 4. Independent lines (structurally separate — corrects prior duplication)

| Independent line | Owner | Reports to | Distinct from |
|------------------|-------|-----------|---------------|
| **MLRO / Financial Crime** | MLRO (SMF17) | **Board** (direct, independent) | **NOT inside Compliance**; **NOT under CFO/COO** |
| **Internal Audit** | Internal Audit (SMF5, outsourced Grant Thornton sandbox) | **Audit Committee / Board** | Read-only; humans issue findings |
| **Compliance (2nd line monitoring)** | Head of Compliance (under CRO independent functions) | CRO / Board | **NOT the MLRO** — monitoring/advisory, not SAR authority |

**Corrected contradiction (physical audit):** `banxe_aml_orchestrator` was mapped as head of BOTH
Dept-2 "Compliance" AND Dept-6 "MLRO". **Canon:** `banxe_aml_orchestrator` = **MLRO / Financial-Crime
head only** (SAR, sanctions, PEP — non-delegable). **Compliance 2nd-line monitoring is a distinct
function** (head = Head of Compliance) and does NOT hold SAR/sanctions authority. MLRO is an
**independent line to the Board**, not a sub-function of Compliance and not under CFO/COO.

## 5. Executive contour (formalised)

| Layer | Agent / role | Status |
|-------|--------------|--------|
| **CEO Orchestration Agent** | top AI orchestrator of the bank (Level 1) | **MANDATORY — passport TODO** (Sprint 2) |
| **Board Reporting Agent** | prepares board/committee reporting packs; board sign-off gate | **MANDATORY — passport TODO** (Sprint 2) |
| **Independent MLRO Agent** | `banxe_aml_orchestrator` (existing passport) | ✅ exists |
| **Independent Internal-Audit Agent** | Internal-Audit assurance (Level 1 independent) | **MANDATORY — passport TODO** (Sprint 2) |

## 6. Three Lines of Defence (mapping)

| Line | Function | Departments | AI involvement |
|------|----------|-------------|----------------|
| **1st** | Business risk management | CFO ops · COO/Operations · CTO/Platform · Front Office | L1–L2 agents + automated guardrails |
| **2nd** | Risk oversight, compliance monitoring, financial crime | Risk (CRO) · Compliance · **MLRO (independent)** · DPO | L2–L3 agents with human HITL gates |
| **3rd** | Independent assurance | **Internal Audit (independent)** | Read-only agents; humans issue findings |

## 7. Owners of the previously-ambiguous mandatory functions (FIXED)

| Function | Canonical owner (line) | Agent | Code / passport evidence |
|----------|------------------------|-------|---------------------------|
| **DPO / Privacy** | HR/Legal Dept 8 (2nd line) | `privacy_compliance_agent` (+ `crm_dsar_governor`) | passport ✓ · emi-stack `services/consent_management` (7 .py), `services/user_preferences` |
| **Wind-Down Planning** | CFO Office Dept 3 (Recovery & Resolution) | `wind_down_planning_agent` | passport ✓ · emi-stack `services/resolution/wind_down_plan.py` |
| **Annual Safeguarding Audit** | **Internal Audit (3rd line)** — NOT smeared across COO | `safeguarding_audit_agent` | passport ✓ · emi-stack `src/safeguarding/annual_audit.py` (SP-THIN). *Daily safeguarding ops remain under COO Dept 4 (`safeguarding_recon_governor`).* |
| **Operational Resilience / DORA** | CTO Dept 5 (Op-Resilience) | `resilience_agent` | passport ✓ · emi-stack `services/incident_response/dora_continuity.py` |
| **MLRO / Financial Crime** | Independent line to Board | `banxe_aml_orchestrator` | passport ✓ · emi-stack `services/aml`, `services/sanctions_screening`, `services/crypto_aml_graph` |

## 8. Level 0–4 operating model

```
Level 0 — Board / Committees / Human principals      (Board, AuditCo, RiskCo, RemCo; SMF holders)
Level 1 — Executive AI layer                          (CEO Orchestration Agent · Board Reporting Agent
                                                       · Independent MLRO Agent · Independent Audit Agent)
Level 2 — Department Head Agents                       (one per department — carries human_double)
Level 3 — Team-Lead / Controller Agents               (sub-function leads — NO human_double)
Level 4 — Specialist Worker Agents                    (task executors — NO human_double)
```

`human_double` is carried **ONLY** at Level 1 (independent agents) and Level 2 (department heads).

## 9. Mandatory Department-Head Agents

| Dept | Head agent (canonical name) | Status |
|------|-----------------------------|--------|
| 1 Board/Executive | `ceo_orchestration_agent` | **MANDATORY — TODO** |
| 2 Risk | `risk_oversight_agent` (RiskOversightAgent) | **MANDATORY — TODO** |
| 2 Compliance | Head-of-Compliance monitoring agent | **MANDATORY — TODO** |
| 3 CFO Office | `cfo_orchestration_agent` | **MANDATORY — TODO** |
| 4 COO/Operations | `coo_operations_agent` | **MANDATORY — TODO** |
| 5 CTO/Tech-Data-AI | `cto_platform_agent` | **MANDATORY — TODO** |
| 6 MLRO/Financial Crime | **`banxe_aml_orchestrator`** | ✅ exists |
| 7 Front Office | `front_office_agent` | **MANDATORY — TODO** |
| 8 HR/Legal/DPO | `hr_agent` (PROPOSED) · `privacy_compliance_agent` (DPO) · `legal_corporate_agent` | partial — Legal TODO |
| Independent | `internal_audit_agent` · `board_reporting_agent` | **MANDATORY — TODO** |

## 10. Mandatory Human Doubles (SM&CR)

| Role | SMF | Holder (sandbox, per ORG-STRUCTURE §4) |
|------|-----|----------------------------------------|
| CEO | SMF1 | Moriel Carmi |
| CFO | SMF2 | David Goldstein |
| CRO | SMF4 | Elena Vasilenko |
| Internal Audit | SMF5 | Grant Thornton UK (outsourced) |
| MLRO | SMF17 | Sarah Mitchell |
| COO | SMF24 | James Hargreaves |
| CTO | SMF26 | Oleg (@p314pm) |
| DPO | — | (DPO appointment — Dept 8) |
| CCO (Front Office) | — | (Commercial lead) |

## 11. What is FIXED in Sprint 1

1. The **8 core departments** + their SM&CR owners (§3).
2. **MLRO / Financial Crime as a separate independent line to the Board** — de-duplicated from Compliance,
   not under CFO/COO (§4).
3. **Internal Audit as a separate independent 3rd line** to the Audit Committee / Board (§4, §6).
4. **Executive contour formalised**: CEO Orchestration Agent + Board Reporting Agent + independent
   MLRO/Audit agents (§5).
5. **Level 0–4 operating model** + the human_double rule (§8).
6. **Single owners fixed** for DPO, Wind-Down, Annual Safeguarding Audit, Operational Resilience/DORA (§7).
7. **Three Lines of Defence mapping** (§6).
8. The **mandatory department-head roles + mandatory human doubles** + the list of **mandatory missing
   functions** (department-head agents still TODO) — recorded, not yet built (§9, §10).

## 12. What is intentionally DEFERRED to Sprint 2

1. The full **worker-level staff matrix** (Level 3/4 agents) per department.
2. **Creating the TODO department-head passports** (`ceo_orchestration_agent`, `board_reporting_agent`,
   `internal_audit_agent`, `risk_oversight_agent`, `cfo_orchestration_agent`, `coo_operations_agent`,
   `cto_platform_agent`, `front_office_agent`, `legal_corporate_agent`, compliance-monitoring head).
3. Any **new HITL gate** for Board-report sign-off beyond the existing `HITL-MATRIX.yaml` gates.
4. Wiring each department head to its Level 3/4 controllers and emi-stack services in full.

---

*Sprint-1 Canonical Org Freeze · governance-only · based on physical audit of `~/banxe-architecture` +
`~/banxe-emi-stack` (107 services, 34 passports, 3 swarms). Companion: `docs/ORG-STRUCTURE.md` (per-agent
detail), `docs/DEPARTMENT-MAP.md` (§A–§I roll-up), `HITL-MATRIX.yaml` (gates).*
