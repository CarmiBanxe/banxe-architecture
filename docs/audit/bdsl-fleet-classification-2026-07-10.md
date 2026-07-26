# BDSL Fleet Classification Registry — 2026-07-10 (v3 AUTHORITATIVE)
# Supersedes: all prior versions (feat/bdsl-foundation v1, commit 7bba209 v2-partial)
# Branch: agent/factory/t5/bdsl-activation-prep
# Authoritative source: docs/audit/ORG-CODE-RECONCILIATION-v2.md
# Source SHA: b84a4babf36bb0f9cc1618b26970f3cf009620c5780cda45313a4c1b41a2f035
# Source date: 2026-06-21
# BDSL canon body-SHA: c4f71e729f3791e97429f5482c405c201cee395b4d8daff6d9828ed53c30553f
# ADR-046 schema SHA: a95d8e959417ad86dbb19e1d07ccd02d036671b92cd12912f640827c82db313b

---

> **v3 CORRECTION NOTE** — Prior versions contained two classes of errors:
>
> **v1 (feat/bdsl-foundation):** Classified 96+ agents sourced from unreliable worktree
> deduplication (3 806 files / 28+ worktrees). Introduced UNKNOWN-36 category and
> CREDIT-OPEN domain — both were noise artefacts, not real agents. **Removed permanently.**
>
> **v2 (commit 7bba209):** Correctly used v2 authoritative numbers but classified ONLY
> the 13 PROPOSED passports, leaving the 34 existing unclassified.
> Sum was 1+1+11=13, not 47.
>
> **This v3 classifies all 47 v2 passports.**
> ENROL(15) + DEFER(9) + EXCLUDE(23) = **47** ✓
> UNKNOWN-36 is deleted. CREDIT domain is reclassified as CREDIT-GAP (§CREDIT-GAP below).

---

## Baseline Facts (v2 authority)

| Metric | Value | Source |
|--------|-------|--------|
| Total v2 passports | **47** | ORG-CODE-RECONCILIATION-v2 §Summary |
| Existing passports (Matrix A) | **34** | Pre-v2, covers 78 MAPPED domain services |
| PROPOSED passports (Matrix B) | **13** | New passports for 13 orphan services |
| Physical yaml files — primary machine | **42** | Shell audit (root + aml/ + finance/ subdirs) |
| Physical yaml files — this worktree | **70** | Includes feature-branch additions and cores |
| Deduplicated unique names (all machines) | **67** | 47 v2-canonical + 20 worktree noise |
| True orphans (no owner) | **0** | Matrix C |

### Adapter-Pair Dedup Rule (ADR-005 Protocol DI)

For outer-adapter + inner-core pairs in the AML/KYC domain:
- **Outer adapter** (`jube_adapter`, `tx_monitor`, `sanctions_check`, …) = decision-emitting entity → **ENROL**
- **Inner core** (`aml/jube_adapter_core`, `aml/tx_monitor_core`, …) = implementation detail, not an independent decision agent → **EXCLUDE**

---

## Part A — Existing Passports (34) — v2 Matrix A

These 34 passports cover 78 domain services (Matrix A). Multiple services may share one
passport / bounded context. Full service-to-passport mapping: `ORG-CODE-RECONCILIATION-v2.md`.

### A1 — AML / Financial Crime (outer adapters)

| # | Passport | File | trust_zone | BDSL |
|---|----------|------|-----------|------|
| 1 | banxe_aml_orchestrator | `agents/passports/banxe_aml_orchestrator.yaml` | AMBER | **ENROL** |
| 2 | tx_monitor | `agents/passports/tx_monitor.yaml` | AMBER | **ENROL** |
| 3 | sanctions_check | `agents/passports/sanctions_check.yaml` | AMBER | **ENROL** |
| 4 | jube_adapter | `agents/passports/jube_adapter.yaml` | AMBER | **ENROL** |
| 5 | yente_adapter | `agents/passports/yente_adapter.yaml` | AMBER | **ENROL** |
| 6 | watchman_adapter | `agents/passports/watchman_adapter.yaml` | AMBER | **ENROL** |
| 7 | crypto_aml | `agents/passports/crypto_aml.yaml` | AMBER | **ENROL** |

ENROL rationale: all seven make consequential financial-crime risk decisions as primary function
(transaction blocking, risk scoring, screening matches). Outer adapter = decision-emitting entity.

### A2 — AML Inner Cores (implementation detail — EXCLUDE per adapter-pair rule)

| # | Passport | File | trust_zone | BDSL |
|---|----------|------|-----------|------|
| 8 | aml/jube_adapter_core | `agents/passports/aml/jube_adapter_core.yaml` | RED | **EXCLUDE** |
| 9 | aml/tx_monitor_core | `agents/passports/aml/tx_monitor_core.yaml` | RED | **EXCLUDE** |
| 10 | aml/sanctions_check_core | `agents/passports/aml/sanctions_check_core.yaml` | RED | **EXCLUDE** |
| 11 | aml/watchman_adapter_core | `agents/passports/aml/watchman_adapter_core.yaml` | RED | **EXCLUDE** |
| 12 | aml/yente_adapter_agent | `agents/passports/aml/yente_adapter_agent.yaml` | RED | **EXCLUDE** |

EXCLUDE rationale: inner cores implement adapter logic; the corresponding outer adapter is the
decision agent for BDSL purposes. Emitting duplicate DecisionRecords from cores would
double-count the same decision.

Note: `aml/banxe_aml_orchestrator.yaml` (subdirectory copy) = duplicate of #1 above —
counted once at the root level; subdir copy excluded from v2 count.

### A3 — Escalation / MLRO

| # | Passport | File | trust_zone | BDSL |
|---|----------|------|-----------|------|
| 13 | aml/mlro_report_agent | `agents/passports/aml/mlro_report_agent.yaml` | RED | **ENROL** |

ENROL rationale: SAR filing decisions and MLRO report escalation are consequential compliance
decisions requiring full BDSL DecisionRecord audit trail.

### A4 — Compliance / Oversight

| # | Passport | File | trust_zone | BDSL |
|---|----------|------|-----------|------|
| 14 | compliance_monitoring_agent | `agents/passports/compliance_monitoring_agent.yaml` | AMBER | **ENROL** |
| 15 | internal_audit_agent | `agents/passports/internal_audit_agent.yaml` | RED | **ENROL** |
| 16 | risk_oversight_agent | `agents/passports/risk_oversight_agent.yaml` | AMBER | **ENROL** |

ENROL rationale: compliance monitoring findings, audit determinations, and risk-level
decisions are consequential regulatory decisions that directly trigger downstream actions.

### A5 — Regulatory Reporting

| # | Passport | File | trust_zone | BDSL |
|---|----------|------|-----------|------|
| 17 | board_reporting_agent | `agents/passports/board_reporting_agent.yaml` | RED | **ENROL** |
| 18 | reporting_agent | `agents/passports/reporting_agent.yaml` | RED | **DEFER** |

ENROL #17: board-level FCA regulatory reporting decisions are consequential; each report
dispatch is a signed commitment to regulator.

DEFER #18: FCA submission agent (FIN060). Consequential, but BDSL DecisionRecord emission
requires ratification of `ADR-schema-reconciliation-decisionrecord.md` to resolve schema
lineage before this agent emits records. Review: 2026-10-01.

### A6 — Finance

| # | Passport | File | trust_zone | BDSL |
|---|----------|------|-----------|------|
| 19 | finance/apar_agent | `agents/passports/finance/apar_agent.yaml` | AMBER | **ENROL** ⚠️ |
| 20 | finance/ifrs_agent | `agents/passports/finance/ifrs_agent.yaml` | RED | **ENROL** |
| 21 | finance/tax_compliance_agent | `agents/passports/finance/tax_compliance_agent.yaml` | RED | **DEFER** |
| 22 | finance/gl_close_agent | `agents/passports/finance/gl_close_agent.yaml` | AMBER | **DEFER** |
| 23 | finance/consolidation_agent | `agents/passports/finance/consolidation_agent.yaml` | AMBER | **DEFER** |
| 24 | finance/beancount_export_agent | `agents/passports/finance/beancount_export_agent.yaml` | GREEN | **EXCLUDE** |

#19 `finance/apar_agent` ENROL **without credit-caveat** (STEP13: credit sub-function disabled per
NO-CREDIT-PRODUCTS-CANON; caveat below is historical): AP/AR decisions are consequential
financial decisions (ENROL). However, embedded credit-terms sub-function is unaccounted under
EU AI Act Annex III §5. See §CREDIT-GAP. Enrolment proceeds for AP/AR; credit sub-function
requires separate operator decision.

DEFER #21 tax_compliance_agent: consequential (HMRC filings) but scope of autonomous
decisions vs. human-reviewed submissions unclear. Review: 2026-10-01.

DEFER #22 gl_close_agent: GL period-close is financial but multi-step; BDSL decision
attribution (which sub-step emits the record) requires architectural review. Review: 2026-10-01.

DEFER #23 consolidation_agent: group financial consolidation; needs scope confirmation on
which consolidation decisions are autonomous vs. CFO-directed. Review: 2026-10-01.

EXCLUDE #24 beancount_export_agent: data export to Beancount format; no autonomous
financial decisions made.

### A7 — C-Suite Orchestration

| # | Passport | File | trust_zone | BDSL |
|---|----------|------|-----------|------|
| 25 | ceo_orchestration_agent | `agents/passports/ceo_orchestration_agent.yaml` | AMBER | **DEFER** |
| 26 | cfo_orchestration_agent | `agents/passports/cfo_orchestration_agent.yaml` | AMBER | **DEFER** |
| 27 | coo_operations_agent | `agents/passports/coo_operations_agent.yaml` | AMBER | **DEFER** |

DEFER rationale: C-suite orchestrators are consequential at the executive level but function
as routing/coordination layers. BDSL decision attribution (orchestrator vs. sub-agent as
emitter) requires architectural review before enrolment to avoid cascade double-counting.
Review: 2026-10-01.

### A8 — Legacy / Predecessor

| # | Passport | File | trust_zone | BDSL |
|---|----------|------|-----------|------|
| 28 | aml_orchestrator | `agents/passports/aml_orchestrator.yaml` | AMBER | **DEFER** |

DEFER rationale: Possible predecessor to `banxe_aml_orchestrator` (#1). Architectural
deduplication review required — enrolling both would double-count AML decisions. If confirmed
as retired/superseded, reclassify to EXCLUDE. Review: 2026-09-01.

### A9 — Platform / Infrastructure / Developer Tooling

| # | Passport | File | trust_zone | BDSL |
|---|----------|------|-----------|------|
| 29 | clickhouse_writer | `agents/passports/clickhouse_writer.yaml` | GREEN | **EXCLUDE** |
| 30 | cto_platform_agent | `agents/passports/cto_platform_agent.yaml` | AMBER | **EXCLUDE** |
| 31 | front_office_agent | `agents/passports/front_office_agent.yaml` | AMBER | **EXCLUDE** |
| 32 | legal_corporate_agent | `agents/passports/legal_corporate_agent.yaml` | AMBER | **EXCLUDE** |
| 33 | gap_tracker_agent | `agents/passports/gap_tracker_agent.yaml` | GREEN | **EXCLUDE** |
| 34 | spec_first_auditor | `agents/passports/spec_first_auditor.yaml` | AMBER | **EXCLUDE** |

EXCLUDE rationale: infrastructure writer, platform orchestration, customer-facing advisory,
legal advisory, dev tooling — none make consequential autonomous financial decisions.
Passport activation provides audit coverage; BDSL DecisionRecord not required.

### Part A Summary

| BDSL | Count | Passport names |
|------|-------|----------------|
| ENROL | **14** | banxe_aml_orchestrator, tx_monitor, sanctions_check, jube_adapter, yente_adapter, watchman_adapter, crypto_aml, aml/mlro_report_agent, compliance_monitoring_agent, internal_audit_agent, risk_oversight_agent, board_reporting_agent, finance/apar_agent ⚠️, finance/ifrs_agent |
| DEFER | **8** | reporting_agent, finance/tax_compliance_agent, finance/gl_close_agent, finance/consolidation_agent, ceo_orchestration_agent, cfo_orchestration_agent, coo_operations_agent, aml_orchestrator |
| EXCLUDE | **12** | aml/jube_adapter_core, aml/tx_monitor_core, aml/sanctions_check_core, aml/watchman_adapter_core, aml/yente_adapter_agent, finance/beancount_export_agent, clickhouse_writer, cto_platform_agent, front_office_agent, legal_corporate_agent, gap_tracker_agent, spec_first_auditor |
| **Total** | **34** | ✓ 14 + 8 + 12 = 34 |

---

## Part B — PROPOSED Passports (13) — v2 Matrix B

All 13 are `status: PROPOSED, autonomy: L2_REVIEW` per v2 Matrix B.
No activation has occurred. Activation requires operator PR sign-off (I-BDSL-2).

Note: `design_pipeline_agent.yaml` shows `status: ACTIVE` in the current worktree yaml
(modified during ADDS sprint IL-ADDS-01). Classified here per v2 Matrix B (PROPOSED batch).
Passport activation status is orthogonal to BDSL DecisionRecord enrolment.

### Group B1 — MLRO Ownership (Trust Zone: RED)

| # | Passport | File | trust_zone | SM&CR | BDSL |
|---|----------|------|-----------|-------|------|
| 35 | case_management_agent | `agents/passports/case_management_agent.yaml` | RED | MLRO (SMF17) | **ENROL** |

ENROL: Case management in AML/compliance context involves consequential decisions
(case escalation to SAR, hold placement, referral to MLRO). RED zone — MLRO written
sign-off required before `status: PROPOSED → ACTIVE`.

### Group B2 — COO Ownership (Trust Zone: AMBER / GREEN)

| # | Passport | File | trust_zone | SM&CR | BDSL |
|---|----------|------|-----------|-------|------|
| 36 | document_management_agent | `agents/passports/document_management_agent.yaml` | AMBER | COO (SMF24) | **DEFER** |
| 37 | user_preferences_agent | `agents/passports/user_preferences_agent.yaml` | GREEN | COO (SMF24) | **EXCLUDE** |
| 38 | alerting_agent | `agents/passports/alerting_agent.yaml` | AMBER | COO (SMF24) | **EXCLUDE** |

DEFER #36: handles documents in DSAR/regulatory context; review whether document retention
or deletion decisions constitute consequential BDSL events. Review: 2026-10-01.

EXCLUDE #37, #38: no consequential financial decisions. Passport activation useful for audit
coverage; BDSL DecisionRecord not required.

### Group B3 — HR/Legal Ownership (Trust Zone: GREEN)

| # | Passport | File | trust_zone | SM&CR | BDSL |
|---|----------|------|-----------|-------|------|
| 39 | hr_agent | `agents/passports/hr_agent.yaml` | GREEN | HR/Legal | **EXCLUDE** |

EXCLUDE: GREEN, HR domain — outside BDSL financial decision scope.

### Group B4 — CTO Ownership (Trust Zone: AMBER)

| # | Passport | File | trust_zone | SM&CR | BDSL |
|---|----------|------|-----------|-------|------|
| 40 | midaz_mcp_agent | `agents/passports/midaz_mcp_agent.yaml` | AMBER | CTO (SMF26) | **EXCLUDE** |
| 41 | webhook_orchestrator_agent | `agents/passports/webhook_orchestrator_agent.yaml` | AMBER | CTO (SMF26) | **EXCLUDE** |
| 42 | webhooks_agent | `agents/passports/webhooks_agent.yaml` | AMBER | CTO (SMF26) | **EXCLUDE** |
| 43 | ml_pipeline_agent | `agents/passports/ml_pipeline_agent.yaml` | AMBER | CTO (SMF26) | **EXCLUDE** |
| 44 | experiment_copilot_agent | `agents/passports/experiment_copilot_agent.yaml` | AMBER | CTO (SMF26) | **EXCLUDE** |
| 45 | reasoning_bank_agent | `agents/passports/reasoning_bank_agent.yaml` | AMBER | CTO (SMF26) | **EXCLUDE** |
| 46 | design_pipeline_agent | `agents/passports/design_pipeline_agent.yaml` | AMBER | CTO (SMF26) | **EXCLUDE** |
| 47 | multi_tenancy_agent | `agents/passports/multi_tenancy_agent.yaml` | AMBER | CTO (SMF26) | **EXCLUDE** |

EXCLUDE (all 8): CTO-owned AMBER platform agents — infrastructure / advisory / tooling.
No consequential autonomous financial decisions. Passport activation ensures audit coverage;
BDSL DecisionRecord NOT required.

Exceptions to verify before any scope change:
- `experiment_copilot_agent` — capabilities marked TODO in ORG-CODE-RECONCILIATION-v2 (sparse code)
- `reasoning_bank_agent` — advisory-only; no autonomous execution path currently confirmed
- `midaz_mcp_agent` — MCP adapter/proxy; no independent decision-making

### Part B Summary

| BDSL | Count | Passport names |
|------|-------|----------------|
| ENROL | **1** | case_management_agent |
| DEFER | **1** | document_management_agent |
| EXCLUDE | **11** | user_preferences_agent, alerting_agent, hr_agent, midaz_mcp_agent, webhook_orchestrator_agent, webhooks_agent, ml_pipeline_agent, experiment_copilot_agent, reasoning_bank_agent, design_pipeline_agent, multi_tenancy_agent |
| **Total** | **13** | ✓ 1 + 1 + 11 = 13 |

---

## Fleet Totals

| BDSL | Existing (A) | Proposed (B) | **Total** |
|------|-------------|-------------|-----------|
| ENROL | 14 | 1 | **15** |
| DEFER | 8 | 1 | **9** |
| EXCLUDE | 12 | 11 | **23** |
| **Total** | **34** | **13** | **47** |

**15 + 9 + 23 = 47** ✓

---

## CREDIT-GAP — EU AI Act Annex III §5 HIGH-RISK Blocker

### Status: RESOLVED (2026-07-27, STEP13) — via `docs/canon/NO-CREDIT-PRODUCTS-CANON.md` (out-of-scope)

> **RESOLVED:** BANXE EMI provides NO credit products (operator decision, CEO; Fable5 0.93 C1/C2) →
> Annex III §5 does not apply (exclusion from scope, not deferral). apar_agent ENROLs without
> credit-caveat (credit sub-function disabled by canon); channel_c_sepa_orchestrator drawdown-routing
> declared out-of-scope. Historical blocker text below preserved append-only for audit.

### Historical status: BLOCKER (CREDIT circuit only)

> This blocker does NOT affect AML / KYC / PAYMENT / COMPLIANCE / REPORTING BDSL activation.
> It blocks only the CREDIT sub-function within `finance/apar_agent` and any future
> credit-routing decisions in `channel_c_sepa_orchestrator`.

### Confirmed Fact

No dedicated `credit_decision_agent` passport exists in `agents/passports/`.
Confirmed by shell audit (2026-07-10): no yaml file named `credit_decision_agent`,
`lending_agent`, `savings_agent`, `insurance_agent`, `card_issuing_agent`, or equivalent.

### Where Credit Logic Currently Lives

| File | Credit logic type |
|------|------------------|
| `agents/passports/finance/apar_agent.yaml` | AP/AR with embedded credit-terms decisions (payment terms, credit period, credit approval for trade counterparties) |
| `agents/passports/channel_c_sepa_orchestrator.yaml` | SEPA payment routing including credit facility drawdown routing |

Credit decisions are not isolated in a dedicated decision agent. They are sub-functions
embedded within broader operational agents, producing no separately addressable DecisionRecord.

### Regulatory Requirement

**EU AI Act Annex III §5 (HIGH-RISK AI systems):**

> AI systems intended to be used for creditworthiness assessment or credit scoring, intended
> to be used by natural persons... or legal persons...

**FCA PS25/12 / CASS 15:** requires audit trail segregation for decisions affecting client money,
including credit facilities that affect safeguarding calculations.

An agent co-mingling AP/AR operations with credit decisions cannot satisfy Annex III §5's
requirement for dedicated accountability. Current architecture produces no separately addressable
`DecisionRecord` with `decision_type: CREDIT_ASSESSMENT`.

### Scope of CREDIT-GAP Blocker

| Circuit | BDSL activation blocked by this gap? |
|---------|-------------------------------------|
| AML / KYC / Sanctions | **No** |
| Payment routing (non-credit) | **No** |
| Compliance / Reporting / Audit | **No** |
| Finance AP/AR (non-credit sub-function) | **No** — ENROL proceeds with caveat |
| Finance AP/AR (credit-terms sub-function) | **Yes** — no dedicated DecisionRecord |
| CREDIT circuit (any new credit-specific agent) | **Yes** — no passport; Annex III §5 unsatisfied |

### Required Operator Decision

Choose one:

**Option A — Create `credit_decision_agent`:** New dedicated passport, BDSL ENROL, scoped
to all credit-scoring and creditworthiness decisions (lending, savings, credit cards, overdraft,
BNPL, trade credit terms). Architectural separation from AP/AR required.

**Option B — Formal out-of-scope declaration:** If Banxe does not perform Annex III §5
credit decisions autonomously (all credit decisions are human-only L4), document this as
a formal exclusion with evidence. Requires MLRO + General Counsel sign-off.

Neither option requires immediate action to unblock AML/KYC/PAYMENT BDSL activation.

---

## What "Hermes" Is NOT

**Hermes = Software Factory Lead (advisory/orchestration, runs on evo1/evo2).**
Hermes is NOT a domain-service agent making consequential financial decisions.
Hermes is OUT-OF-SCOPE for BDSL fleet enrolment — no DecisionRecord.

---

## Activation Requirements

**For 13 PROPOSED passports (`status: PROPOSED → ACTIVE`):**

- [ ] Operator sign-off on the activation PR (I-BDSL-2, Never-Autonomous)
- [ ] MLRO written sign-off for `case_management_agent` (RED / CTX-01)
- [ ] `autonomy: L2_REVIEW` confirmed as ceiling — no autonomous upgrade
- [ ] I-27 KYC HOLD gate evaluated separately — see `docs/audit/bdsl-i27-clarification.md`
- [ ] ADR-046 schema (`schemas/agent_decision_record.schema.json`, sha `a95d8e95…`) confirmed

**For ENROL-classified agents to emit BDSL DecisionRecords:**

- [ ] `docs/adr/ADR-schema-reconciliation-decisionrecord.md` ratified (currently PROPOSED)
- [ ] `governance/novelty-pipeline-config.yaml` thresholds reviewed by operator
- [ ] CREDIT-GAP operator decision for `finance/apar_agent` credit sub-function

No automated activation. `status: PROPOSED → ACTIVE` only via reviewed PR, never by agent action.

---

## References

- **Authoritative passport coverage:** `docs/audit/ORG-CODE-RECONCILIATION-v2.md` (sha `b84a4bab…`)
- **Fleet coverage summary:** `docs/audit/bdsl-fleet-coverage-2026-07-10.md`
- **I-27 clarification:** `docs/audit/bdsl-i27-clarification.md`
- **BDSL canon:** `docs/canon/BEST-DECISION-SELF-LEARNING-LOOP.md` (body-sha `c4f71e…30553f`)
- **ADR-046 schema:** `schemas/agent_decision_record.schema.json` (sha `a95d8e95…`)
- **Schema reconciliation ADR:** `docs/adr/ADR-schema-reconciliation-decisionrecord.md`
- **Governance config (thresholds/weights):** `governance/novelty-pipeline-config.yaml`
- **Agent authority matrix:** `.claude/rules/agent-authority.md`
- **BUG-007 confidence thresholds:** `.claude/rules/agents.md#BUG-007`
