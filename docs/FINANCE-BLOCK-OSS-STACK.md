# FINANCE-BLOCK-OSS-STACK.md — Banxe AI Bank: Finance Block Corrected OSS Architecture
> IL-067 | Developer Plane | banxe-architecture
> Created: 2026-04-09 | Supersedes: section 0 of FINANCE-BLOCK-ROLES.md (IL-066)
>
> **Purpose**: Authoritative corrected open-source stack for the CFO/Finance block.
> Resolves 13 structural and licensing errors from the previous analysis.
> Source: "Banxe AI Bank: Классический Финансово-Аналитический Блок EMI — Исправленная Архитектура"

---

## 0. Critical Corrections from Previous Analysis

| # | Error | Type | Fix |
|---|-------|------|-----|
| 1 | AML/KYC/Fraud included in finance block | Structural | Moved to MLRO function (independent from CFO) |
| 2 | FP&A block absent | Structural | Level 2: FP&A (dbt+ClickHouse+Superset+OSEM) |
| 3 | Treasury/ALM absent | Structural | Level 3: Treasury (QuantLib+OSEM+Frankfurter+Blnk) |
| 4 | Financial Controlling not explicit | Structural | Level 1: Controlling (Odoo+ERPNext+Midaz+Beancount) |
| 5 | IFRS 9/18 not mentioned | Regulatory | OCA IFRS modules; IFRS 18 prep target: Q4 2026 |
| 6 | Consolidation absent | Structural | Odoo multicompany + ERPNext multi-subsidiary |
| 7 | OpenBB as "banking analytics" | Classification | OpenBB = market data tool, not banking P&L/regulatory |
| 8 | Camunda 7 CE (EOL) | Critical | **FINOS Fluxnova** (Apache 2.0) |
| 9 | JasperReports Server CE (withdrawn) | Critical | **WeasyPrint + ReportLab** (BSD) |
| 10 | OpenBB licence listed as Apache 2.0 | Licensing | OpenBB = AGPL v3, requires legal review before use |
| 11 | ELK Stack (SSPL) as "open source" | Licensing | **OpenSearch** (Apache 2.0) |
| 12 | RegData — programmatic API | Regulatory | My FCA portal only; no public API; manual submission |
| 13 | "62% EMI" stat without source | Accuracy | Removed — unverifiable |

---

## 1. Level 1 — Financial Controlling

**Function**: Single chart of accounts, double-entry, period close, segmented P&L,
IFRS 9 ECL, IFRS 18 preparation, multi-entity consolidation.

| Component | Repo | Licence | Role |
|-----------|------|---------|------|
| **Odoo Community CE** ⭐ | `odoo/odoo` | LGPL v3 | Primary GL, AP/AR, bank reconciliation, multi-currency, CAMT/MT940 via OCA |
| **ERPNext / Frappe** | `frappe/erpnext` | MIT | Alternative API-first accounting engine; REST API to Midaz |
| **Midaz (LerianStudio)** | `lerianstudio/midaz` | Apache 2.0 | Transactional ledger → feed to Odoo/ERPNext via webhooks |
| **Formance Ledger** | `formancehq/ledger` | MIT | Numscript programmable flows; hash-chain audit |
| **Beancount + Fava** | `beancount/beancount` | GPL v2 | Plain-text IFRS audit trail; LLM-compatible; Fava web UI for auditors |
| **LedgerSMB** | `ledgersmb/LedgerSMB` | GPL v2 | Lightweight PostgreSQL-native accounting (reserve option) |
| **OCA account-reconcile** | `OCA/account-reconcile` | AGPL v3 | CAMT.053/MT940 auto-matching in Odoo |
| **OCA account-financial-tools** | `OCA/account-financial-tools` | LGPL v3 | IFRS chart of accounts, FX classification |

**IFRS 18 note**: Effective January 2027. Odoo + OCA modules support FX classification
(operating/investing/financing). Chart of accounts adaptation required by Q4 2026.

**Consolidation**: Odoo multicompany + ERPNext multi-subsidiary.
FX translation via Frankfurter ECB rates (see Treasury stack).

---

## 2. Level 2 — FP&A (Financial Planning & Analysis)

**Function**: Budgeting, rolling forecasts, scenario analysis, variance reporting,
capital planning, ALCO management reporting.

**Important**: No enterprise-grade full-suite open source FP&A tool equivalent to
Anaplan/Adaptive exists in 2026. Banxe must use a composite OSS stack.

| Component | Repo | Licence | Role |
|-----------|------|---------|------|
| **Metabase** | `metabase/metabase` | AGPL v3 | Self-service reporting, variance dashboards, no-SQL for CFO |
| **Apache Superset** | `apache/superset` | Apache 2.0 | Advanced BI, scenario overlays, MCP AI integration |
| **dbt Core** | `dbt-labs/dbt-core` | Apache 2.0 | SQL models for budget-vs-actual, rolling forecasts from ClickHouse |
| **ClickHouse** | `ClickHouse/ClickHouse` | Apache 2.0 | OLAP core: P&L by segment, product, cohort |
| **OSEM (Open Source Economic Model)** | `open-source-modelling/Open_Source_Economic_Model` | MIT | Agent-based ALM + portfolio model, Python/Pandas/Ollama integration |
| **H2O.ai open source core** | `h2oai/h2o-3` | Apache 2.0 | AutoML for financial forecasting (stress testing, NII, churn) |
| **Apache Airflow** | `apache/airflow` | Apache 2.0 | DAG orchestration: monthly budget cycle, variance runs |

**Constraint**: `OpenBB` is explicitly excluded — it is a market data tool (equities, macro),
not a banking P&L/regulatory analytics tool. Its licence is AGPL v3, not Apache 2.0.

---

## 3. Level 3 — Treasury / ALM

**Function**: Safeguarding pool management, liquidity buffers (CASS 15), FX risk,
IRRBB, ALCO reporting, covenant monitoring, funding strategy.

**Important**: No production-ready open source ALM system equivalent to Moody's ALM
or SAS ALM exists. Banxe builds on Python libraries + ClickHouse + OSEM models.

| Component | Repo | Licence | Role |
|-----------|------|---------|------|
| **Frankfurter** | `lineofflight/frankfurter` | MIT | Self-hosted ECB FX rates API, 160+ currencies |
| **OSEM** | `open-source-modelling/Open_Source_Economic_Model` | MIT | ALM model: portfolio cash flows, liability matching, LLM insights |
| **QuantLib** | `lballabio/QuantLib` | BSD | Mature C++ library: yield curves, duration, convexity, FX derivatives pricing |
| **Blnk Finance** | `blnkfinance/blnk` | Apache 2.0 | Safeguarding pool balance monitoring + real-time alerts |
| **Prometheus + Grafana** | — | Apache 2.0 / AGPL v3 | ALCO dashboard: safeguarding coverage ratio, LCR proxy, balance thresholds |
| **ClickHouse Materialized Views** | — | Apache 2.0 | Real-time intraday liquidity position, balance snapshots |

---

## 4. Level 4 — Regulatory Reporting (FCA CASS 15)

**Function**: FIN060a/b generation, monthly CASS 15 safeguarding return, Resolution Pack,
external audit support, data quality gates before every submission.

**Critical**: FCA submission is via **My FCA portal** (renamed from RegData on 31 March 2025).
No public programmatic API exists. All submissions are manual by an authorised person.

| Component | Repo | Licence | Role |
|-----------|------|---------|------|
| **Midaz Reporter** | `lerianstudio/lerian-reporter` | Apache 2.0 | Async report generation: PDF/HTML/CSV/XML |
| **WeasyPrint** ⭐ | `Kozea/WeasyPrint` | BSD | HTML/CSS → PDF for FCA returns (replaces JasperReports Server CE) |
| **ReportLab** | PyPI | BSD | Programmatic PDF generation for compliance documents |
| **FINOS ORR/DRR** | `finos-labs/opensource-reg-reporting` | Apache 2.0 | CDM-based regulatory reporting framework |
| **OpenMetadata** | `open-metadata/OpenMetadata` | Apache 2.0 | Data lineage: auditability of every figure in FCA returns |
| **pgAudit** | `pgaudit/pgaudit` | PostgreSQL Licence | Immutable audit log at PostgreSQL level |
| **Debezium** | `debezium/debezium` | Apache 2.0 | CDC append-only event log for external auditor |
| **Great Expectations** | `great-expectations/great_expectations` | Apache 2.0 | Data quality validation gate before every FCA reporting cycle |
| **bankstatementparser** | `sebastienrousseau/bankstatementparser` | Apache 2.0 | CAMT.053/MT940 parsing of custodian bank statements |
| **Blnk/Formance Reconciliation** | — | Apache 2.0/MIT | Daily safeguarding reconciliation engine |

**Removed**: JasperReports Server CE (Community Edition discontinued).
**Removed**: Camunda 7 CE (End of Life). Replaced by FINOS Fluxnova.

---

## 5. Level 5 — Data Analytics & BI Infrastructure

**Function**: Unified analytics platform, data pipelines, real-time monitoring,
audit log search, data quality enforcement.

| Component | Repo | Licence | Role |
|-----------|------|---------|------|
| **ClickHouse** | `ClickHouse/ClickHouse` | Apache 2.0 | OLAP core: sub-second queries, materialized views |
| **dbt Core + dbt-clickhouse** | `dbt-labs/dbt-core` | Apache 2.0 | SQL transformations, data lineage, CI/CD tests |
| **Apache Superset** | `apache/superset` | Apache 2.0 | CFO/ALCO dashboards, 40+ viz types, MCP integration |
| **Metabase** | `metabase/metabase` | AGPL v3 | Self-service for compliance, no-SQL queries |
| **Grafana** | `grafana/grafana` | AGPL v3 | Real-time operational monitoring, AlertManager |
| **Apache Airflow** | `apache/airflow` | Apache 2.0 | DAG pipelines: ETL, reconciliation, reporting cycles |
| **Airbyte OSS** | `airbytehq/airbyte` | ELv2* | ELT from PSP/external sources → ClickHouse |
| **Sequin / Debezium** | MIT / Apache 2.0 | — | CDC real-time streaming from PostgreSQL ledger |
| **OpenSearch** ⭐ | `opensearch-project/OpenSearch` | Apache 2.0 | Replaces ELK (SSPL): audit log search, compliance log management |

*ELv2: source-available, not OSI open source; no restrictions for internal use.
**Removed**: ELK Stack (Elasticsearch/Kibana SSPL is not open source compatible).

---

## 6. Cross-cutting: Workflow, AI Agents, IAM, Observability

| Layer | Component | Licence | Role |
|-------|-----------|---------|------|
| **Workflow** | **FINOS Fluxnova** ⭐ | Apache 2.0 | BPMN human approval workflows; replaces Camunda 7 CE (EOL) |
| **Workflow** | Temporal | MIT | Durable workflow execution for long-running finance processes |
| **AI Agents** | OpenClaw | MIT | Operational agents: ClickHouse queries via Telegram, alerts, report generation |
| **AI Agents** | MetaClaw | MIT | Self-learning: accumulates finance skills from real CFO queries |
| **AI Agents** | Ruflo (Claude Flow v3) | MIT | Multi-agent orchestration: parallel monthly FCA reporting swarm |
| **IAM** | Keycloak | Apache 2.0 | OIDC, SM&CR role enforcement, FCA SYSC 4.7 |
| **Observability** | OpenTelemetry + Jaeger | Apache 2.0 | CNCF standard; distributed tracing across finance agent pipeline |

---

## 7. Full Integration Chain

```
Midaz / Formance Ledger
    │ event webhooks
    ▼
Odoo Community CE (GL/AP/AR) ←── OCA CAMT.053 reconcile ←── Bank statements (CAMT.053/MT940)
    │                                                          parsed by bankstatementparser
    │ dbt Core transformations
    ▼
ClickHouse (OLAP)
    ├──► Apache Superset / Metabase  ──► CFO / ALCO dashboards
    ├──► dbt variance models          ──► FP&A variance reports
    ├──► Great Expectations           ──► Data quality gate (blocks FCA return on failure)
    ├──► Midaz Reporter / WeasyPrint  ──► FIN060 / CASS 15 return PDF
    │                                        │
    │                                        ▼
    │                                   My FCA portal (manual upload by CFO/Head of Reg Reporting)
    │
    ├──► Beancount export              ──► External Auditor (Fava read-only UI)
    ├──► OpenMetadata                  ──► Data lineage for every FCA figure
    └──► OpenSearch                    ──► Audit log search for compliance/Internal Audit

Prometheus + Grafana ──► ALCO real-time dashboard (safeguarding coverage, LCR proxy)
Blnk Finance         ──► Safeguarding pool balance monitoring + breach alerts
Frankfurter API      ──► ECB FX rates for revaluation and consolidation

FINOS Fluxnova (BPMN) ──► Human approval workflows (CFO sign-off on FCA returns, Controller sign-off on close)
Temporal               ──► Durable orchestration of monthly FCA reporting cycle
OpenClaw / Ruflo       ──► AI agent coordination of above pipeline steps
```

---

## 8. AI Agent Framework Summary (OpenClaw / MetaClaw / Ruflo)

| Framework | Finance block application |
|-----------|--------------------------|
| **OpenClaw** | Operational agents: ClickHouse queries via Telegram, reconciliation alerts, ad-hoc CFO report generation |
| **MetaClaw** | Self-learning: accumulates finance skills from real CFO queries; improves answer accuracy over time |
| **Ruflo** | Complex multi-step workflows: parallel agents for monthly FCA reporting cycle (extract → transform → validate → PDF) |

**Accounting swarm** (from IL-066): `agents/swarms/accounting-swarm.yaml`
**Monthly FCA swarm**: `agents/swarms/monthly-fca-return.yaml` (see section 9)

---

## 9. Ruflo Swarm: Monthly FCA Return (monthly-fca-return.yaml)

```yaml
# Ruflo multi-agent swarm: Monthly CASS 15 Return
# Replaces previous Camunda 7 CE workflow
name: monthly_fca_return
topology: hierarchical
coordinator: cfo_analytics_agent

agents:
  - id: data_extractor
    soul: agents/souls/fca-data-extraction-agent.md
    tools: [clickhouse_query, midaz_api, odoo_api]
    parallel: true

  - id: data_validator
    soul: agents/souls/reg-data-quality-agent.md
    tools: [run_great_expectations_suite, generate_validation_report]
    depends_on: [data_extractor]
    parallel: false

  - id: reconciliation_checker
    soul: agents/souls/safeguarding-reconciliation-agent.md
    tools: [blnk_reconcile, formance_reconcile, compare_balances]
    depends_on: [data_extractor]
    parallel: true

  - id: report_generator
    soul: agents/souls/fca-return-generator-agent.md
    tools: [dbt_run, weasyprint_generate, openmetadata_lineage]
    depends_on: [data_validator, reconciliation_checker]

  - id: cfo_reviewer
    soul: agents/souls/cfo-controller-agent.md
    tools: [send_telegram, fluxnova_bpmn_trigger, approval_workflow]
    depends_on: [report_generator]
    human_in_loop: true
    human_double: "CFO / Head of Regulatory Reporting"
    hitl_gate: HITL-010

memory:
  type: shared_persistent
  backend: postgresql

output:
  - type: pdf
    template: templates/fca-monthly-return.html
    renderer: weasyprint
    destination: ./output/monthly-returns/
  - type: audit_log
    backend: openmetadata
    dataset: fca_return_pipeline_runs
```

---

## 10. MetaClaw Finance Skills Initialisation

```yaml
# metaclaw_finance_skills_init.yaml — seed skills for CFO finance block
skills:
  - name: safeguarding_balance_query
    trigger: "safeguarding balance|coverage ratio|protected funds"
    action: "SELECT currency, sum(amount) FROM safeguarding_daily_mv WHERE date = today()"

  - name: reconciliation_break_analysis
    trigger: "reconciliation break|difference|mismatch"
    action: "run_blnk_reconciliation_report(period=last_7_days)"

  - name: monthly_pl_summary
    trigger: "P&L|profit loss|monthly results"
    action: "odoo_trial_balance(period=current_month) + dbt_run(model=monthly_pnl)"

  - name: fx_exposure_report
    trigger: "FX exposure|currency risk|forex position"
    action: "clickhouse_query(fx_positions_mv) + frankfurter_rates()"

  - name: cass15_countdown
    trigger: "FCA return|CASS 15|monthly return|safeguarding return"
    action: "calculate_days_to_deadline() + check_great_expectations_status()"

  - name: resolution_pack_status
    trigger: "resolution pack|client funds|living document"
    action: "midaz_balance_snapshot() + generate_account_mapping()"
```

---

## 11. Full Corrected Stack Table (CFO Office)

| CFO Level | Component | Licence | Maturity |
|-----------|-----------|---------|----------|
| Financial Controlling | Odoo Community CE | LGPL v3 | Mature |
| Financial Controlling | ERPNext / Frappe | MIT | Mature |
| Financial Controlling | Midaz Ledger | Apache 2.0 | Production |
| Financial Controlling | Formance Ledger | MIT | Production |
| Financial Controlling | Beancount + Fava | GPL v2 | Stable |
| Financial Controlling | OCA account-reconcile | AGPL v3 | Mature |
| Financial Controlling | OCA account-financial-tools | LGPL v3 | Mature |
| FP&A | dbt Core | Apache 2.0 | Mature |
| FP&A | ClickHouse | Apache 2.0 | Production |
| FP&A | Apache Superset | Apache 2.0 | Mature |
| FP&A | Metabase | AGPL v3 | Mature |
| FP&A | H2O.ai open source | Apache 2.0 | Research |
| FP&A | OSEM ALM Model | MIT | Research |
| FP&A | Apache Airflow | Apache 2.0 | Mature |
| Treasury/ALM | Frankfurter | MIT | Stable |
| Treasury/ALM | QuantLib | BSD | Mature |
| Treasury/ALM | Blnk Finance | Apache 2.0 | Production |
| Treasury/ALM | OSEM | MIT | Research |
| Treasury/ALM | Prometheus + Grafana | Apache 2.0 / AGPL v3 | Mature |
| Reg. Reporting | Midaz Reporter | Apache 2.0 | Production |
| Reg. Reporting | WeasyPrint ⭐ | BSD | Stable |
| Reg. Reporting | ReportLab | BSD | Mature |
| Reg. Reporting | FINOS ORR/DRR | Apache 2.0 | Active |
| Reg. Reporting | OpenMetadata | Apache 2.0 | Production |
| Reg. Reporting | Great Expectations | Apache 2.0 | Mature |
| Reg. Reporting | bankstatementparser | Apache 2.0 | Stable |
| Reg. Reporting | pgAudit | PostgreSQL Licence | Mature |
| Reg. Reporting | Debezium / Sequin | Apache 2.0 / MIT | Mature |
| Analytics | Apache Airflow | Apache 2.0 | Mature |
| Analytics | Airbyte OSS | ELv2* | Production |
| Analytics | OpenSearch ⭐ | Apache 2.0 | Mature |
| Analytics | Grafana | AGPL v3 | Mature |
| Workflow | FINOS Fluxnova ⭐ | Apache 2.0 | Production |
| Workflow | Temporal | MIT | Production |
| AI Agents | OpenClaw | MIT | Production |
| AI Agents | MetaClaw | MIT | Research |
| AI Agents | Ruflo (Claude Flow v3) | MIT | Production |
| IAM | Keycloak | Apache 2.0 | Mature |
| Observability | OpenTelemetry + Jaeger | Apache 2.0 | CNCF Standard |

*ELv2: source-available; no restrictions for internal use.
⭐ = newly added / corrected in IL-067.

---

*Document maintained by: Claude Code | IL-067 | 2026-04-09 | I-29 (Documentation Standard)*
*Supersedes erroneous OSS references in previous analyses.*
