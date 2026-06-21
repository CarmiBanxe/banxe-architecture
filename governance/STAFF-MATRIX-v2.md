# STAFF-MATRIX-v2 — Banxe AI Bank Department Staff Matrix (NORMATIVE)

> **Status:** Sprint-3 Staff Matrix (2026-06-21). **Normative** — child of the org canon.
> **Parent:** `governance/CANONICAL-ORG-CHART-v2.md` (frozen org structure, Sprint 1). On any conflict the
> parent canon wins for *structure*; this document is authoritative for the *staffing* of each department.
> **Supersedes (append-only):** `governance/STAFF-MATRIX-v1.md` (Sprint-2). v1 remains the frozen Sprint-2 record.
> **Scope:** activates the 10 PROPOSED department-head agents (PROPOSED → active), records `org_roles.py` /
> HITL gate wiring, and expands the L3/L4 per-worker layer. Closes **GAP-078**.
> **HITL note:** `HITL-MATRIX.yaml` is NOT modified — agents are *wired* to the existing 17 gates
> (HITL-001…017) via `banxe-emi-stack/services/hitl/org_roles.py`.
> **Audit base:** physical audit (107 emi-stack services, 44 passports = 34 existing + 10 activated).
> Agents marked `(A)` = active (this sprint), `(E)` = existing active passport.

## 1. Level model (unchanged from canon §8)

```
L0 Board / Committees (human)
  → L1 Executive AI (CEO-Orch · Board-Report · indep MLRO · indep Audit)
    → L2 Department-Head Agents
      → L3 Team-Lead/Controller
        → L4 Specialist Worker
```
`human_double` only at L1 (independent agents) + L2 (department heads).

## 2. Activation status — 10 dept-head agents (PROPOSED → active)

| Agent | Sprint-2 | Sprint-3 | human_double (SM&CR) | HITL gates wired |
|-------|----------|----------|----------------------|------------------|
| `ceo_orchestration_agent` | P | **A** | CEO Moriel Carmi (SMF1) | HITL-004,007,008,012,015,017 (CEO) |
| `board_reporting_agent` | P | **A** | CEO / Board | (reporting; no approval gate) |
| `internal_audit_agent` | P | **A** | Internal Audit — Grant Thornton UK (SMF5) | (independent assurance) |
| `risk_oversight_agent` | P | **A** | CRO Elena Vasilenko (SMF4) | HITL-012,014 (CRO) |
| `compliance_monitoring_agent` | P | **A** | Head of Compliance | HITL-002,006,009 (COMPLIANCE_OFFICER) |
| `cfo_orchestration_agent` | P | **A** | CFO David Goldstein (SMF2) | HITL-010,011,016 (CFO) |
| `coo_operations_agent` | P | **A** | COO James Hargreaves (SMF24) | HITL-009,016 (COO/OPERATOR) |
| `cto_platform_agent` | P | **A** | CTO Oleg (SMF26) | HITL-013,014,015 (CTO) |
| `front_office_agent` | P | **A** | CCO (Commercial lead) | (product input → HITL-017 CEO) |
| `legal_corporate_agent` | P | **A** | Legal Counsel | (agreements; no approval gate) |

Existing active heads retained: `banxe_aml_orchestrator` (E, MLRO SMF17), `privacy_compliance_agent` (E, DPO).

## 3. org_roles.py wiring (HITL gate registry — reference only)

File: `banxe-emi-stack/services/hitl/org_roles.py`. Role→SMF map (already canonical in `HITL-MATRIX.yaml`):

```
CEO→SMF1 · CFO→SMF2 · CRO→SMF4 · MLRO→SMF17 · COO→SMF24 · CTO→SMF26
COMPLIANCE_OFFICER (no SMF) · OPERATOR (no SMF)
```
Each activated agent registers under its role; gate enforcement remains as defined in `HITL-MATRIX.yaml`
(`required_roles` / `any_of_roles`). No gate definitions added, removed, or altered.

## 4. L3/L4 worker layer (per department — active)

L3/L4 sub-agents from v1 §3 are carried forward unchanged (existing passports, ~25 agents). Their
backing emi-stack services are as recorded in `STAFF-MATRIX-v1.md §2–§3`. No L3/L4 passport is
re-created; activation in Sprint-3 affects only the 10 L2 heads above.

## 5. Summary

| Metric | Count |
|--------|-------|
| Departments (canon §3) | 8 + 2 independent lines |
| Department-head + independent-line agents | 12 |
| — active after Sprint-3 | 12 (10 activated + 2 existing) |
| PROPOSED remaining | 0 |
| Passports total | 44 (34 existing + 10 activated) |
| HITL gates modified | 0 (wiring only) |

## 6. GAP closure

**Closed (Sprint 3):** GAP-078 — the 10 dept-head agents are activated, wired to `org_roles.py`, and
bound to the existing HITL gates. PROPOSED → active complete; 44/44 passports active.

---

*Sprint-3 Staff Matrix · governance record · child of `governance/CANONICAL-ORG-CHART-v2.md` · append-only over v1. Closes GAP-078. `HITL-MATRIX.yaml` untouched.*
