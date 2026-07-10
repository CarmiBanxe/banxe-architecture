# BDSL Fleet Coverage Audit — 2026-07-10 (v3)
# Status: CORRECTED (v3) — supersedes all prior versions
# Branch: agent/factory/t5/bdsl-activation-prep
# Authoritative source: docs/audit/ORG-CODE-RECONCILIATION-v2.md
# Source SHA: b84a4babf36bb0f9cc1618b26970f3cf009620c5780cda45313a4c1b41a2f035
# Source date: 2026-06-21 | Supersedes: ORG-CODE-RECONCILIATION-2026-06-11.md

---

> **CORRECTION NOTE**: The previous version of this file (feat/bdsl-foundation) used unverified
> shell-count estimates (132 / 156 / 84-gap / CREDIT-open). Those figures came from worktree
> passport deduplication noise, not from the governance-authoritative coverage report.
> This version uses ONLY figures from ORG-CODE-RECONCILIATION-v2.md (sha b84a4bab…).

---

## Authoritative Summary

| Metric | Value | Source |
|--------|-------|--------|
| Total runtime services (banxe-emi-stack) | **106** | ORG-CODE-RECONCILIATION-v2 |
| Infrastructure / non-agent (OUT-OF-SCOPE) | **15** | Matrix D |
| **Domain services (in-scope)** | **91** | 106 − 15 |
| Directly mapped (existing passports / CTX) | **78** | Matrix A MAPPED rows |
| Orphan → PROPOSED passport (this activation) | **13** | Matrix B |
| Passports total (34 existing + 13 PROPOSED) | **47** | ORG-CODE-RECONCILIATION-v2 §Summary |
| **Domain coverage (owner assigned)** | **91/91 = 100%** | Matrix C |
| True orphans (no owner) | **0** | Matrix C |
| Physical yaml files — primary machine | **42** | Shell audit (root + aml/ + finance/ subdirs) |
| Physical yaml files — this worktree | **70** | Feature-branch additions included |
| Deduplicated unique names (all machines) | **67** | 47 v2-canonical + 20 worktree noise |

---

## Activation Status

> **BDSL activation as live-config is BLOCKED** pending operator sign-off on:
> 1. **13 PROPOSED passports** — `status: PROPOSED, autonomy: L2_REVIEW` — NOT activated.
>    Full list and ENROL/DEFER/EXCLUDE classification:
>    `docs/audit/bdsl-fleet-classification-2026-07-10.md` §Part B.
> 2. **ADR-046 Decision Record schema** (`schemas/agent_decision_record.schema.json`, sha `a95d8e95…`)
>    is the canonical schema for DecisionRecord. See `docs/audit/bdsl-i27-clarification.md`.
> 3. **Schema reconciliation ADR** (`docs/adr/ADR-schema-reconciliation-decisionrecord.md`)
>    status PROPOSED — awaits ratification before any agent emits BDSL records.
> 4. **CREDIT-GAP operator decision** — no dedicated credit_decision_agent exists; credit logic
>    embedded in `finance/apar_agent` and `channel_c_sepa_orchestrator` is unaccounted under
>    EU AI Act Annex III §5. See `bdsl-fleet-classification-2026-07-10.md` §CREDIT-GAP.
>
> No thresholds, weights, or gate specs are set here. Those live in
> `governance/novelty-pipeline-config.yaml`.

---

## Domain Coverage Map (from ORG-CODE-RECONCILIATION-v2 Matrix A)

### Directly Mapped (78 services — existing agents / bounded-contexts)

Selected key domain mappings (full list in Matrix A of ORG-CODE-RECONCILIATION-v2):

| Domain area | Example services | Owning agent / CTX |
|-------------|------------------|--------------------|
| AML / fraud | aml, crypto_aml_graph, ato_prevention, fraud, fraud_tracer | aml_orchestrator / CTX-02 |
| KYC/KYB | kyc, kyb_onboarding, device_fingerprint | jube_adapter, yente_adapter / CTX-01 |
| Payment | payment, batch_payments, multi_currency, scheduled_payments | payment_router_agent / CTX-04 |
| Compliance | compliance, compliance_automation, sanctions_screening, fatca_crs | compliance_monitoring_agent, sanctions_check / CTX-02 |
| Safeguarding | safeguarding, safeguarding-engine, recon | safeguarding_recon_governor / CTX-05 |
| Reporting | reporting, reporting_analytics, fx_exchange | reporting_agent, treasury_alm_agent / CTX-10 |
| Finance / AP-AR | ap_ar, gl_close, consolidation, ifrs | finance/apar_agent, finance/ifrs_agent / CTX-10 |
| Open Banking | psd2_gateway, open_banking | existing agents / CTX-04 |
| Lending/Credit | lending, savings, insurance, card_issuing | ⚠️ **CREDIT-GAP** — no dedicated agent; credit logic embedded in finance/apar_agent and channel_c_sepa_orchestrator. EU AI Act Annex III §5 blocker. See §CREDIT-GAP in bdsl-fleet-classification-2026-07-10.md |

### Orphan → PROPOSED (13 services — new passports, Matrix B)

See `docs/audit/bdsl-fleet-classification-2026-07-10.md` for full details.

| Service | PROPOSED passport | trust_zone | SM&CR owner |
|---------|------------------|-----------|-------------|
| case_management | `case_management_agent` | RED | MLRO (SMF17) |
| document_management | `document_management_agent` | AMBER | COO (SMF24) |
| user_preferences | `user_preferences_agent` | GREEN | COO (SMF24) |
| alerting | `alerting_agent` | AMBER | COO (SMF24) |
| hr | `hr_agent` | GREEN | HR/Legal |
| midaz_mcp | `midaz_mcp_agent` | AMBER | CTO (SMF26) |
| webhook_orchestrator | `webhook_orchestrator_agent` | AMBER | CTO (SMF26) |
| webhooks | `webhooks_agent` | AMBER | CTO (SMF26) |
| ml_pipeline | `ml_pipeline_agent` | AMBER | CTO (SMF26) |
| experiment_copilot | `experiment_copilot_agent` | AMBER | CTO (SMF26) |
| reasoning_bank | `reasoning_bank_agent` | AMBER | CTO (SMF26) |
| design_pipeline | `design_pipeline_agent` | AMBER | CTO (SMF26) |
| multi_tenancy | `multi_tenancy_agent` | AMBER | CTO (SMF26) |

### Out-of-Scope Infrastructure (15 services — Matrix D)

These services have NO agent by design; owned by CTO platform (infra custody):
`__pycache__`, `_legacy_common`, `config`, `secrets`, `shared`, `deploy`, `producers`,
`providers`, `events`, `swarm`, `agents`, `backup`, `data_quality`, `repo_watch`, `ci_governance`.

---

## BDSL Activation Gate Summary

| Gate | Description | Current Status |
|------|-------------|---------------|
| Passport coverage | 91/91 domain services have owner | CLEARED (100%) |
| True orphans | Services with no owner | CLEARED (0) |
| 13 PROPOSED passports | status=PROPOSED, await operator sign-off | PENDING operator PR |
| Decision record schema | ADR-046 `schemas/agent_decision_record.schema.json` canonical | CONFIRMED (sha `a95d8e95…`) |
| I-27 KYC HOLD | HITL-L4 operator stop on KYC/KYB/AML activation | SEPARATE GATE (see bdsl-i27-clarification.md) |
| Schema reconciliation ADR | ADR-schema-reconciliation-decisionrecord.md | PENDING ratification |
| CREDIT-GAP | No credit_decision_agent; EU AI Act Annex III §5 | BLOCKER (credit circuit only) |
| BDSL fleet classification | All 47 passports classified ENROL/DEFER/EXCLUDE | ENROL=15 DEFER=9 EXCLUDE=23 (sum=47) |
| Governance config | Thresholds and weights | `governance/novelty-pipeline-config.yaml` (not in this doc) |

**BDSL activation (AML/KYC/PAYMENT/COMPLIANCE circuits) proceeds after operator sign-off
on the 13 PROPOSED passports.** The 0-orphan / 100% domain coverage condition is already satisfied.
CREDIT circuit requires separate CREDIT-GAP operator decision (independent blocker).

---

## References

- **Authoritative source:** `docs/audit/ORG-CODE-RECONCILIATION-v2.md` (sha b84a4bab…)
- **Classification registry (all 47, ENROL/DEFER/EXCLUDE):** `docs/audit/bdsl-fleet-classification-2026-07-10.md`
- **I-27 clarification:** `docs/audit/bdsl-i27-clarification.md`
- **ADR-046 decision record:** `schemas/agent_decision_record.schema.json` (sha a95d8e95…)
- **Schema reconciliation ADR:** `docs/adr/ADR-schema-reconciliation-decisionrecord.md`
- **Canon pointer:** `docs/canon/BEST-DECISION-SELF-LEARNING-LOOP.md`
- **Governance config (thresholds):** `governance/novelty-pipeline-config.yaml`
- **HITL anchor BUG-007:** `.claude/rules/agents.md#BUG-007`
