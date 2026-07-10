# BDSL Fleet Classification Registry — 2026-07-10
# Status: CORRECTED (v2) — supersedes earlier draft on feat/bdsl-foundation
# Branch: feat/bdsl-activation-prep
# Authoritative source: docs/audit/ORG-CODE-RECONCILIATION-v2.md
# Source SHA: b84a4babf36bb0f9cc1618b26970f3cf009620c5780cda45313a4c1b41a2f035
#
# PURPOSE: Registry of 13 PROPOSED passports awaiting operator activation.
# NO thresholds, weights, or activation config here.
# Status PROPOSED → ACTIVE only via human-gated operator PR (Never-Autonomous, I-BDSL-2).

---

> **CORRECTION NOTE**: The previous version of this file (feat/bdsl-foundation) used unverified
> fleet estimates and assigned ENROL/EXCLUDE/DEFER to 96+ agents based on worktree noise.
> This version is grounded exclusively in ORG-CODE-RECONCILIATION-v2 Matrix B.
> The only agents requiring explicit activation decision are the **13 PROPOSED** passports below.
> All other domain services are already MAPPED to existing agents (Matrix A, 78 services).

---

## Baseline Facts (from v2 authoritative source)

| Metric | Value |
|--------|-------|
| Total domain services | 91 |
| Services with existing (pre-v2) passport / CTX | 78 (MAPPED) |
| Services with new PROPOSED passport (this PR) | 13 |
| True orphans (no owner assigned) | **0** |
| Total passports after activation | 47 (34 + 13) |

---

## 13 PROPOSED Passports — Activation Candidates

All 13 are `status: PROPOSED, autonomy: L2_REVIEW`. No activation has occurred.
Passport files exist in `agents/passports/<name>.yaml` on current branch.

### Group 1 — MLRO Ownership (Trust Zone: RED)

RED trust_zone = highest sensitivity; MLRO (SMF17) double-check required per agent-authority.md.

| # | Service | Passport file | trust_zone | bounded_context | SM&CR owner | BDSL domain |
|---|---------|--------------|-----------|-----------------|-------------|-------------|
| 1 | case_management | `agents/passports/case_management_agent.yaml` | **RED** | CTX-01 (AML/Compliance) | MLRO (SMF17) | COMPLIANCE |

Activation note for #1: RED zone requires MLRO written sign-off before `status: PROPOSED → ACTIVE`.

### Group 2 — COO Ownership (Trust Zone: AMBER / GREEN)

| # | Service | Passport file | trust_zone | bounded_context | SM&CR owner | BDSL domain |
|---|---------|--------------|-----------|-----------------|-------------|-------------|
| 2 | document_management | `agents/passports/document_management_agent.yaml` | AMBER | CTX-06 (Operations) | COO (SMF24) | DEFER* |
| 3 | user_preferences | `agents/passports/user_preferences_agent.yaml` | GREEN | CTX-06 (Operations) | COO (SMF24) | EXCLUDE** |
| 4 | alerting | `agents/passports/alerting_agent.yaml` | AMBER | CTX-06 (Operations) | COO (SMF24) | EXCLUDE** |

\* `document_management_agent` — DEFER for BDSL DecisionRecord: handles documents under DSAR/regulatory context;
  review whether decisions qualify as consequential before ENROL. Review date: 2026-10-01.
\** `user_preferences_agent`, `alerting_agent` — EXCLUDE from BDSL loop: no consequential financial decisions.
  Passport activation (L2_REVIEW) is still useful for audit trail but BDSL DecisionRecord not required.

### Group 3 — HR/Legal Ownership (Trust Zone: GREEN)

| # | Service | Passport file | trust_zone | bounded_context | SM&CR owner | BDSL domain |
|---|---------|--------------|-----------|-----------------|-------------|-------------|
| 5 | hr | `agents/passports/hr_agent.yaml` | GREEN | CTX-08 (HR) | HR/Legal | EXCLUDE** |

\** GREEN + HR domain = outside BDSL financial decision scope. Passport activation useful for audit
  but no BDSL DecisionRecord required.

### Group 4 — CTO Ownership (Trust Zone: AMBER)

| # | Service | Passport file | trust_zone | bounded_context | SM&CR owner | BDSL domain |
|---|---------|--------------|-----------|-----------------|-------------|-------------|
| 6 | midaz_mcp | `agents/passports/midaz_mcp_agent.yaml` | AMBER | CTX-03 (Platform) | CTO (SMF26) | EXCLUDE** |
| 7 | webhook_orchestrator | `agents/passports/webhook_orchestrator_agent.yaml` | AMBER | CTX-03 (Platform) | CTO (SMF26) | EXCLUDE** |
| 8 | webhooks | `agents/passports/webhooks_agent.yaml` | AMBER | CTX-03 (Platform) | CTO (SMF26) | EXCLUDE** |
| 9 | ml_pipeline | `agents/passports/ml_pipeline_agent.yaml` | AMBER | CTX-03 (Platform) | CTO (SMF26) | EXCLUDE** |
| 10 | experiment_copilot | `agents/passports/experiment_copilot_agent.yaml` | AMBER | CTX-03 (Platform) | CTO (SMF26) | EXCLUDE** |
| 11 | reasoning_bank | `agents/passports/reasoning_bank_agent.yaml` | AMBER | CTX-03 (Platform) | CTO (SMF26) | EXCLUDE** |
| 12 | design_pipeline | `agents/passports/design_pipeline_agent.yaml` | AMBER | CTX-09 (Platform) | CTO (SMF26) | EXCLUDE** |
| 13 | multi_tenancy | `agents/passports/multi_tenancy_agent.yaml` | AMBER | CTX-09 (Platform) | CTO (SMF26) | EXCLUDE** |

\** CTO-owned AMBER platform agents — infrastructure/advisory, no consequential financial decisions.
  Passport activation ensures audit coverage; BDSL DecisionRecord NOT required.
  Exception: `reasoning_bank_agent` — advisory only (no autonomous execution); verify before ENROL.
  Note: `experiment_copilot_agent` capabilities marked TODO in ORG-CODE-RECONCILIATION-v2 (sparse code).

---

## BDSL Enrolment Summary for 13 PROPOSED

| BDSL status | Count | Agents |
|------------|-------|--------|
| ENROL-candidate (COMPLIANCE) | 1 | case_management_agent (RED, after MLRO sign-off) |
| DEFER (review 2026-10-01) | 1 | document_management_agent |
| EXCLUDE from BDSL loop | 11 | remaining 11 (platform/ops/HR/GREEN) |

Only `case_management_agent` (RED/MLRO) is a BDSL ENROL candidate from this batch.
Passport activation for the other 12 proceeds independently of BDSL loop enrolment.

---

## What "Hermes" Is NOT

Per ORG-CODE-RECONCILIATION-v2 and governance canon:

**Hermes = Software Factory Lead (advisory/orchestration, runs on evo1/evo2).**
Hermes is NOT a domain-service agent making consequential decisions.
Hermes is therefore OUT-OF-SCOPE for BDSL fleet enrolment.
This classification is final — no BDSL DecisionRecord for Hermes.

---

## Activation Requirements (operator checklist)

For each of the 13 PROPOSED passports to become ACTIVE:

- [ ] **Operator sign-off** on the PR activating this batch
- [ ] **MLRO written sign-off** specifically for `case_management_agent` (RED / CTX-01)
- [ ] **Never-Autonomous confirmed**: `autonomy: L2_REVIEW` is the ceiling (I-BDSL-2)
- [ ] **I-27 KYC HOLD** is a separate gate — see `docs/audit/bdsl-i27-clarification.md`
- [ ] **ADR-046 schema** (`schemas/agent_decision_record.schema.json`, sha a95d8e95…) is canonical

No automated activation. No threshold changes. Status change `PROPOSED → ACTIVE` only in passport YAML, via reviewed PR.

---

## References

- **Authoritative source:** `docs/audit/ORG-CODE-RECONCILIATION-v2.md` (sha b84a4bab…)
- **Fleet coverage:** `docs/audit/bdsl-fleet-coverage-2026-07-10.md`
- **I-27 clarification:** `docs/audit/bdsl-i27-clarification.md`
- **Agent authority matrix:** `.claude/rules/agent-authority.md`
- **Canon pointer:** `docs/canon/BEST-DECISION-SELF-LEARNING-LOOP.md`
- **ADR-046 schema:** `schemas/agent_decision_record.schema.json` (sha a95d8e95…)
