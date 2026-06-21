# STAFF-MATRIX-v1 — Banxe AI Bank Department Staff Matrix (NORMATIVE)

> **Status:** Sprint-2 Staff Matrix (2026-06-21). **Normative** — child of the org canon.
> **Parent:** `governance/CANONICAL-ORG-CHART-v2.md` (frozen org structure, Sprint 1). On any conflict the
> parent canon wins for *structure*; this document is authoritative for the *staffing* of each department
> (head → L3/L4 agents → human double → emi-stack service).
> **Scope:** maps every department head to its Level-1/2 head agent, its Level-3/4 sub-agents, the SM&CR
> human double, and the backing emi-stack service(s). Based on a physical audit (107 emi-stack services,
> 34 + 10 new passports). **No service code is created in Sprint 2** — service implementation = Sprint 3
> (GAP-078). Agents marked `(P)` = PROPOSED (new this sprint), `(E)` = existing passport.

## 1. Level model (from canon §8)

```
L0 Board / Committees (human)  →  L1 Executive AI (CEO-Orch · Board-Report · indep MLRO · indep Audit)
                               →  L2 Department-Head Agents  →  L3 Team-Lead/Controller  →  L4 Specialist Worker
```
`human_double` only at L1 (independent agents) + L2 (department heads).

## 2. Executive & Independent lines (Level 1)

| Line | Head agent (L1) | human_double (SM&CR) | L3/L4 reports | Backing service(s) |
|------|-----------------|----------------------|---------------|--------------------|
| Board / Executive | `ceo_orchestration_agent` (P) | CEO Moriel Carmi (SMF1) | all L2 dept-heads | — (orchestration) |
| Board reporting | `board_reporting_agent` (P) | CEO / Board | `reporting_agent` (E), `bi_dashboard_governor` (E) | `services/regulatory_reporting`, `services/reporting_analytics` |
| **MLRO / Financial Crime** (independent → Board) | `banxe_aml_orchestrator` (E) | MLRO Sarah Mitchell (SMF17) | `tx_monitor`, `aml_orchestrator`, `jube_adapter`, `sanctions_check`, `watchman_adapter`, `yente_adapter`, `crypto_aml` | `services/aml`, `services/sanctions_screening`, `services/crypto_aml_graph` |
| **Internal Audit** (independent → Audit Committee) | `internal_audit_agent` (P) | Internal Audit — Grant Thornton UK (SMF5) | `safeguarding_audit_agent` (E) | `src/safeguarding/annual_audit.py`, `services/audit_trail` |

## 3. Department staff matrix (Level 2 heads → L3/L4)

### Dept 2 — Independent Functions (Risk · Compliance) — 2nd Line
| Head (L2) | human_double | L3/L4 agents | Service(s) |
|-----------|--------------|--------------|------------|
| Risk → `risk_oversight_agent` (P) | CRO Elena Vasilenko (SMF4) | risk metrics / oversight (read-only) | `services/risk`, `services/risk_management` |
| Compliance → `compliance_monitoring_agent` (P) | Head of Compliance | `adverse_media_governor` (E), `fatca_crs_reporting_governor` (E), `privacy_compliance_agent` (E) | `services/adverse_media`, `services/fatca_crs`, `services/compliance` |

### Dept 3 — CFO Office — 1st/2nd Line
| Head (L2) | human_double | L3/L4 agents | Service(s) |
|-----------|--------------|--------------|------------|
| `cfo_orchestration_agent` (P) | CFO David Goldstein (SMF2) | `treasury_alm_agent` (E), `reporting_agent` (E), `regulatory_returns_governor` (E), `bi_dashboard_governor` (E), `wind_down_planning_agent` (E) | `services/treasury`, `services/regulatory_reporting`, `services/resolution/wind_down_plan.py`, `services/ledger` |

### Dept 4 — COO / Operations — 1st Line
| Head (L2) | human_double | L3/L4 agents | Service(s) |
|-----------|--------------|--------------|------------|
| `coo_operations_agent` (P) | COO James Hargreaves (SMF24) | `payment_router_agent` (E), `channel_c_sepa_orchestrator` (E), `channel_c_swift_orchestrator` (E), `safeguarding_recon_governor` (E), `customer_lifecycle_agent` (E), `support_sla_governor` (E) | `services/payment`, `services/safeguarding`, `services/recon`, `services/customer`, `services/support` |

### Dept 5 — CTO / Technology, Data, AI — 1st Line
| Head (L2) | human_double | L3/L4 agents | Service(s) |
|-----------|--------------|--------------|------------|
| `cto_platform_agent` (P) | CTO Oleg @p314pm (SMF26) | `m_gateway_api_governor` (E), `sandbox_rails_governor` (E), `sdk_release_governor` (E), `resilience_agent` (E, DORA), `data_lake_elt_agent` (E) | `services/api_gateway`, `services/incident_response/dora_continuity.py`, `services/observability`, `services/voice_support` |

### Dept 6 — MLRO / Financial Crime
See §2 (independent line — `banxe_aml_orchestrator`).

### Dept 7 — Front Office / Business — 1st Line
| Head (L2) | human_double | L3/L4 agents | Service(s) |
|-----------|--------------|--------------|------------|
| `front_office_agent` (P) | CCO (Commercial lead) | `pricing_fee_governor` (E), `crm_dsar_governor` (E) | `services/fee_management`, `services/crm`, `services/merchant_acquiring` |

### Dept 8 — HR / Legal / Corporate Services (incl. DPO) — 2nd Line (DPO/Legal)
| Head (L2) | human_double | L3/L4 agents | Service(s) |
|-----------|--------------|--------------|------------|
| HR → `hr_agent` (PROPOSED, PR #638) | HR lead | — | `services/hr` |
| DPO → `privacy_compliance_agent` (E) | DPO | `crm_dsar_governor` (E), `consent_management` | `services/consent_management`, `services/user_preferences` |
| Legal → `legal_corporate_agent` (P) | Legal Counsel | `agreement_agent` (E) | `services/agreement` |

## 4. Summary

| Metric | Count |
|--------|-------|
| Departments (canon §3) | 8 + 2 independent lines |
| Department-head + independent-line agents | 12 |
| — existing (E) heads | 2 (`banxe_aml_orchestrator`, `privacy_compliance_agent` DPO) |
| — PROPOSED this sprint (P) | 10 (ceo_orchestration, board_reporting, internal_audit, risk_oversight, compliance_monitoring, cfo_orchestration, coo_operations, cto_platform, front_office, legal_corporate) |
| L3/L4 sub-agents mapped (existing passports) | ~25 (reused, not re-created) |
| New passport stubs added | 10 (all `status: PROPOSED`, no service code) |

## 5. What is fixed in Sprint 2 / deferred to Sprint 3

**Fixed (Sprint 2):** every department head now has a passport (existing or PROPOSED stub); the head → L3/L4
→ human_double → emi-stack service mapping is normatively recorded.

**Deferred (Sprint 3, GAP-078):** service-code implementation of the 10 new head agents; wiring into
`org_roles.py` / HITL; activation (PROPOSED → active) of any head agent; full per-worker capability
specs. `org_roles.py` and service code are NOT touched in Sprint 2.

---

*Sprint-2 Staff Matrix · governance-only · child of `governance/CANONICAL-ORG-CHART-v2.md` · based on
physical audit. Closes GAP-077; opens GAP-078 (Sprint-3 service-impl).*
