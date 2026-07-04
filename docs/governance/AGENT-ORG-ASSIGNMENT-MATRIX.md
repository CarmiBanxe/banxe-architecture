# Agent Org-Assignment Matrix — 70 canonical passports mapped to the bank org (V + H links)

> **Status:** governance data-matrix. **Additive, pointer-first (ADR-102).** **Read-derived, not invented:**
> every `department / human_double / trust_zone / autonomy / line_of_defence` is **extracted from the passport
> itself**; `reports_to` (vertical V) follows `governance/CANONICAL-ORG-CHART-v2.md`; `collaborates_with`
> (horizontal H) follows `agents/swarms/*`. Agents whose passport carries **no department and no canon
> placement** go to **§UNMAPPED** (escalated, not invented). **No passport is edited; no agent activated.**

## Canon basis (CANONICAL-ORG-CHART-v2 §3–§7)
8 departments: **Board&Executive (CEO/SMF1) · Independent Functions Risk·Compliance (CRO/SMF4) · CFO Office
(SMF2) · COO/Operations (SMF24) · CTO/Technology-Data-AI (SMF26) · MLRO/Financial-Crime (SMF17, independent →
Board) · Internal Audit (SMF5, 3rd line → Audit Committee) · Front Office/Business.** MLRO is an **independent
line to the Board** (canon §4: `banxe_aml_orchestrator` = MLRO/Financial-Crime, NOT under Compliance/CFO/COO).

## 1. Board & Executive — reports_to: Board (SMF1) — 1st/Exec
| agent_id | sub_dept | human_double | tz | autonomy | hitl_gate | collaborates_with (H) |
|---|---|---|---|---|---|---|
| ceo_orchestration_agent | Executive orchestration | CEO (Moriel Carmi) | AMBER | L2_REVIEW | exec | all dept orchestrators |
| board_reporting_agent | Board reporting | CEO/Board | RED | L2_REVIEW | board sign-off | cfo/mlro/risk reporters |

## 2. Independent Functions — Risk · Compliance — reports_to: CRO (SMF4) — 2nd Line
| agent_id | sub_dept | human_double | tz | autonomy | hitl_gate | H |
|---|---|---|---|---|---|---|
| risk_oversight_agent | Risk | CRO (Elena Vasilenko) | AMBER | L2_REVIEW | risk-review | board_reporting |
| compliance_monitoring_agent | Compliance (2nd line) | Head of Compliance | AMBER | L2_REVIEW | L2 | crm_dsar, privacy |
| crm_dsar_governor | Compliance / Customer | Head of Compliance | AMBER | L2_REVIEW | L2 | privacy_compliance |
| fatca_crs_reporting_governor | Compliance / Tax Reporting | Head of Compliance | AMBER | L2_REVIEW | L2 | reporting_agent |
| privacy_compliance_agent | Data Protection (DPO) | Head of Compliance | AMBER | L2_REVIEW | L2 | crm_dsar |

## 3. CFO Office — reports_to: CFO (SMF2) — 1st/2nd Line
| agent_id | sub_dept | human_double | tz | autonomy | hitl_gate | H (accounting-swarm) |
|---|---|---|---|---|---|---|
| cfo_orchestration_agent | CFO Office | CFO (David Goldstein) | AMBER | L2_REVIEW | finance | accounting-swarm coord |
| gl_close_agent | Controlling & Accounting | Financial Controller / Chief Accountant | AMBER | L2_REVIEW | L2 | ifrs, apar, consolidation, tax, beancount |
| ifrs_agent | Controlling & Accounting | Chief Accountant / Financial Controller | RED | L2_REVIEW | L2 | gl_close, consolidation |
| apar_agent | Controlling & Accounting | Financial Controller (AP) / Head of Treasury | AMBER | L2_REVIEW | L2 | gl_close, consolidation |
| consolidation_agent | Controlling & Accounting | Financial Controller | AMBER | L2_REVIEW | L2 | gl_close, ifrs, tax |
| tax_compliance_agent | Controlling & Accounting | Tax Manager / Financial Controller | RED | L2_REVIEW | L2 | consolidation |
| beancount_export_agent | Controlling & Accounting | Financial Controller + Head of Internal Audit | GREEN | L1_AUTO | none | accounting-swarm |
| pricing_fee_governor | Commercial / Finance | CFO | AMBER | L2_REVIEW | L2 | front_office |
| wind_down_planning_agent | Recovery & Resolution | CFO | AMBER | L2_REVIEW | L2 | risk_oversight |

## 4. COO / Operations — reports_to: COO (SMF24) — 1st Line
| agent_id | sub_dept | human_double | tz | autonomy | hitl_gate | H |
|---|---|---|---|---|---|---|
| coo_operations_agent | Operations | COO (James Hargreaves) | AMBER | L2_REVIEW | ops | alerting, document, support |
| alerting_agent | Operations / Alerting | COO | AMBER | L2_REVIEW | L2 | coo_operations |
| document_management_agent | Customer Ops / Documents | COO | AMBER | L2_REVIEW | L2 | customer_lifecycle |
| user_preferences_agent | Customer Ops / Consent | COO | GREEN | L2_REVIEW | L2 | customer_lifecycle |
| support_sla_governor | Customer Ops / Support | Head of Customer Operations | AMBER | L2_REVIEW | L2 | customer_lifecycle |
| customer_lifecycle_agent | Customer Management | Customer Support Lead | GREEN | L1_AUTO | none | support, document |

## 5. CTO / Technology, Data, AI — reports_to: CTO (SMF26) — 1st Line
| agent_id | sub_dept | human_double | tz | autonomy | hitl_gate | H |
|---|---|---|---|---|---|---|
| cto_platform_agent | Platform | CTO (Oleg) | AMBER | L2_REVIEW | tech | design_pipeline, resilience |
| design_pipeline_agent | Developer Platform | CTO | AMBER | L2_REVIEW | L2 | sandbox_rails, sdk_release |
| sandbox_rails_governor | Developer Platform | Head of Platform Engineering | AMBER | L2_REVIEW | L2 | sdk_release, design_pipeline |
| sdk_release_governor | Developer Platform | Head of Platform Engineering | AMBER | L2_REVIEW | L2 | sandbox_rails |
| multi_tenancy_agent | Developer Platform | CTO | AMBER | L2_REVIEW | L2 | cto_platform |
| resilience_agent | Operational Resilience | CTIO | AMBER | L2_REVIEW | L2 | cto_platform |
| m_gateway_api_governor | API Governance | CTIO | AMBER | L2_REVIEW | L2 | webhook_orchestrator |
| webhook_orchestrator_agent | Integrations | CTO | AMBER | L2_REVIEW | L2 | webhooks_agent |
| webhooks_agent | Integrations | CTO | AMBER | L2_REVIEW | L2 | webhook_orchestrator |
| midaz_mcp_agent | Integrations | CTO | AMBER | L2_REVIEW | L2 | cto_platform |
| ml_pipeline_agent | Data & ML Engineering | CTO | AMBER | L2_REVIEW | L2 | experiment_copilot |
| experiment_copilot_agent | Data & ML Engineering | CTO | AMBER | L2_REVIEW | L2 | ml_pipeline |
| reasoning_bank_agent | AI Platform | CTO | AMBER | L2_REVIEW | L2 | cto_platform |
| bi_dashboard_governor | Data / Analytics | Head of Data | AMBER | L2_REVIEW | L2 | data_lake_elt |
| data_lake_elt_agent | Data / Analytics | Head of Data | GREEN | L2_REVIEW | L2 | bi_dashboard |

## 6. MLRO / Financial Crime — reports_to: MLRO (SMF17) → Board (independent) — 2nd Line
> Canon §4: this line is **independent** (not under Compliance/CFO/COO). `banxe_aml_orchestrator` = MLRO
> function. H-links = **banxe-aml-swarm** co-membership.
| agent_id | sub_dept | human_double | tz | autonomy | hitl_gate | dept-source |
|---|---|---|---|---|---|---|
| banxe_aml_orchestrator | AML Orchestration (SMF17) | HEAD_OF_FINCRIME / MLRO | RED | L3 | SAR/sanctions HITL | passport fca_basis SMF17 |
| aml_orchestrator | AML Orchestration | (MLRO) | AMBER | — | HITL | canon §4 (aml/) |
| case_management_agent | Case Management | MLRO | RED | L2_REVIEW | L2 | passport department |
| mlro_report_agent | MLRO reporting | (MLRO) | RED | L2 | HITL | canon §4 (aml/) |
| crypto_aml | Crypto AML | (MLRO) | AMBER | — | HITL | canon §4 |
| sanctions_check / sanctions_check_core | Sanctions | (MLRO) | AMBER/RED | L3 | BLOCK+L3 | canon §4 (aml/) |
| tx_monitor / tx_monitor_core | Transaction Monitoring | (MLRO) | AMBER/RED | L3 | L1-auto/L2-threshold | canon §4 (aml/) |
| jube_adapter / jube_adapter_core | TM adapter (Jube) | (MLRO) | AMBER/RED | L3 | HITL | canon §4 (aml/) |
| watchman_adapter / watchman_adapter_core | Sanctions adapter (Watchman) | (MLRO) | AMBER/RED | L3 | HITL | canon §4 (aml/) |
| yente_adapter / yente_adapter_agent | Sanctions adapter (Yente) | (MLRO) | AMBER/RED | L3 | HITL | canon §4 (aml/) |
| reporting_agent | FCA Regulatory (MLRO+CFO) | CFO + MLRO | RED | L3_MLRO | MLRO | passport department |
| payment_router_agent | Payment Ops (AML-gated) | Treasury Manager | RED | L3_MLRO | MLRO | passport department |

> **Data-hygiene note (not invented):** the `aml/` core adapters carry no top-level `department` field; they are
> placed on the MLRO line **by canon §4 + banxe-aml-swarm membership** (not a fabricated department).
> `human_double` for these is `(MLRO)` pending an explicit passport field — **operator confirm** (data follow-up).

## 7. Front Office · Payments · HR/Legal
| agent_id | department | human_double | tz | autonomy | reports_to | H |
|---|---|---|---|---|---|---|
| front_office_agent | Front Office / Business | CCO (Commercial) | AMBER | L2_REVIEW | CCO/CEO | pricing_fee |
| channel_c_sepa_orchestrator | Payments / Channel C | CTIO | AMBER | L2_REVIEW | CTIO/Treasury | swift_orchestrator |
| channel_c_swift_orchestrator | Payments / Correspondent Banking | Head of Treasury | AMBER | L2_REVIEW | Treasury | sepa_orchestrator |
| agreement_agent | Agreement / Contract | Legal Counsel | AMBER | L2_REVIEW | Legal Counsel | legal_corporate |
| legal_corporate_agent | HR / Legal / Corporate | Legal Counsel | AMBER | L2_REVIEW | Legal Counsel | agreement, hr |
| hr_agent | HR / Legal | HR/Legal | GREEN | L2_REVIEW | HR/Legal | legal_corporate |

## 8. Internal Audit — reports_to: Audit Committee / Board (SMF5) — 3rd Line
| agent_id | sub_dept | human_double | tz | autonomy | line_of_defence |
|---|---|---|---|---|---|
| internal_audit_agent | Internal Audit (independent) | Internal Audit (Grant Thornton, outsourced) | RED | L2_REVIEW | 3rd Line |
| safeguarding_audit_agent | Internal Audit / Safeguarding | Head of Internal Audit | RED | L2_REVIEW | 3rd Line |

## §UNMAPPED — PLACEMENT PROPOSED (pending operator ratification; see `UNMAPPED-AGENTS-PLACEMENT.md`)
> Resolved from **passport function only** (not invented); operator ratifies the final org-call. Full rationale
> + alternatives: `docs/governance/UNMAPPED-AGENTS-PLACEMENT.md`.
| agent_id | passport function (evidence) | PROPOSED placement | status |
|---|---|---|---|
| clickhouse_writer | "ClickHouse Audit Writer" — GREEN L3 adapter persisting DecisionEvents to ClickHouse (CTX-03, DORA 5-yr) | **PROPOSED → CTO / Data-Analytics** (Head of Data; peer of `data_lake_elt_agent`) · alt: Internal Audit (consumer) | **PROPOSED (pending ratification)** |
| spec-first-auditor / spec_first_auditor | "Spec-First Auditor" — CTX-00-DEVELOPER methodology controller, `~/developer/` audit script | **PROPOSED → Developer/Factory plane governance-tooling (out-of-bank-org)** · alt: CTO / Engineering-Developer-Platform | **PROPOSED (pending ratification)** |

**Summary:** **70/70 placed** — ~68 by passport-department / canon §4, and the **2 former UNMAPPED now carry an
evidence-grounded PROPOSED placement** (pending operator ratification; `UNMAPPED-AGENTS-PLACEMENT.md`). **0
unmapped remaining.** Vertical (V) = `reports_to` per org-chart;
Horizontal (H) = `collaborates_with` per swarm co-membership. Three Lines of Defence per canon §6.

## Anchors
`governance/CANONICAL-ORG-CHART-v2.md` (§3 8-departments, §4 MLRO-independent, §6 3-lines — the V basis) ·
`HITL-MATRIX.yaml` (SMF gates — SAR/sanctions/threshold) · `docs/RELATIONSHIP-TREE.md` · `agents/swarms/*`
(accounting-swarm / banxe-aml-swarm / monthly-fca-return — the H basis) · `agents/passports/*` (the extracted
source-of-truth — read-only, unedited) · ADR-128 (HITL L1/L2/L3) · ADR-102 (Duplication Audit — restates none).
Operator directive 2026-07-03 (Front 3: distribute 70 passports by org, V+H links; canon-grounded; UNMAPPED
escalated not invented; passports not edited).
