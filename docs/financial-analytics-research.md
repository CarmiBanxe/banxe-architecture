# Open Source Stack для Banxe AI Bank: Финансово-Аналитический Блок
# MiroFish Research | IL-009 Step 1 | 2026-04-06
# Source: CEO report — 50+ verified repos, 13 functional blocks

---

## Executive Summary

EMI под FCA CASS 15 (PS25/12, deadline 7 May 2026) требует:
- Ежедневная reconciliation safeguarding-счёта
- Ежемесячные FCA-возвраты (FIN060a/b) via RegData
- Ежегодный независимый аудит + Resolution Pack (48h)
- Immutable audit trail (tamper-evident)

Текущий стек Banxe уже включает: Midaz, ClickHouse, n8n, Midaz Reporter.
Данный отчёт добавляет 40+ новых компонентов.

---

## Блок 1: Core Ledger (Двойная запись)

| Компонент | GitHub | Лицензия | Приоритет |
|-----------|--------|----------|-----------|
| **Midaz** (PRIMARY) | lerianstudio/midaz | Apache 2.0 | ✅ уже в стеке |
| **Formance Ledger** (hash chain) | formancehq/ledger | MIT | P1 — tamper-evident |
| **Blnk Finance** (reconciliation) | blnkfinance/blnk | Apache 2.0 | P0 — daily recon |
| Apache Fineract | apache/fineract | Apache 2.0 | ↗️ FALLBACK |

---

## Блок 2: Safeguarding Reconciliation (P0 — CASS 15)

### Парсеры банковских выписок

| Репозиторий | Форматы | Язык | Лицензия |
|-------------|---------|------|----------|
| sebastienrousseau/bankstatementparser | CAMT.053, PAIN.001, CSV, OFX, MT940 | Python | Apache 2.0 |
| tkarabela/okane | CAMT.053 | Python | MIT |
| moov-io/rtp20022 | ISO20022 RTP | Go | Apache 2.0 |

### Reconciliation движки

- **Blnk Reconciliation** — exact match / fuzzy match / grouped match (built-in)
- **Formance Reconciliation** — сравнение Formance Ledger с cash pools банков/PSP
- **oprekable/bank-reconcile** — CLI Go утилита

### Change Data Capture

- **Debezium** (debezium/debezium, Apache 2.0) — CDC из PostgreSQL → Kafka
- **Sequin** (sequinstream/sequin, MIT) — 50k ops/sec, Postgres CDC

---

## Блок 3: Финансовая Аналитика / BI

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| **ClickHouse** | ClickHouse/ClickHouse | Apache 2.0 | ✅ уже в стеке |
| Apache Superset | apache/superset | Apache 2.0 | CFO дашборды |
| Metabase | metabase/metabase | AGPL v3 | Compliance officers (no-SQL) |
| Grafana | grafana/grafana | AGPL v3 | ✅ уже (Midaz observability) |
| Redash | getredash/redash | BSD | SQL-first BI за firewall |

**ClickHouse materialized view для safeguarding:**
```sql
CREATE MATERIALIZED VIEW safeguarding_daily_mv
ENGINE = AggregatingMergeTree()
ORDER BY (date, currency)
AS SELECT
  toDate(created_at) AS date,
  currency,
  sum(amount) AS total_safeguarded,
  count() AS transaction_count
FROM ledger_entries
WHERE account_type = 'SAFEGUARDING'
GROUP BY date, currency;
```

---

## Блок 4: Data Transformation / ETL Pipeline

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| **dbt Core** | dbt-labs/dbt-core | Apache 2.0 | Raw → FIN060 models |
| Apache Airflow | apache/airflow | Apache 2.0 | DAG orchestration |
| Airbyte OSS | airbytehq/airbyte | ELv2/MIT | PSP → ClickHouse ELT |
| Great Expectations | great-expectations/great_expectations | Apache 2.0 | Pre-reporting validation |

**dbt repo structure:**
```
dbt/models/
├── staging/          ← raw ledger events
├── intermediate/     ← cleaned data
└── marts/
    ├── safeguarding/ ← daily reconciliation
    ├── fin060/       ← FCA return templates
    └── audit/        ← annual audit export
```

---

## Блок 5: Регуляторная Отчётность

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| Midaz Reporter | lerianstudio (built-in) | Apache 2.0 | ✅ уже в стеке |
| **JasperReports** | TIBCOSoftware/jasperreports | LGPL | FIN060 PDF |
| WeasyPrint | Kozea/WeasyPrint | BSD | HTML→PDF |
| ReportLab | Python PyPI | BSD | Programmatic PDF |
| FINOS Open RegTech | finos/open-regtech-sig | Apache 2.0 | CDM regulatory frameworks |

**FCA RegData:** SaaS FCA — данные готовятся через open source стек, загружаются вручную или через RegData API.

---

## Блок 6: AML / KYC / Fraud Detection

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| **Jube** | jube-home/aml-fraud-transaction-monitoring | AGPLv3 | ✅ уже в стеке |
| **Ballerine** | ballerine-io/ballerine | MIT | KYC/KYB orchestration |
| FINOS OpenAML | finos/open-aml | MIT | On-chain AML (crypto) |

---

## Блок 7: Workflow Orchestration

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| **n8n** | n8n-io/n8n | Fair-code | ✅ уже в стеке |
| **Temporal** | temporalio/temporal | MIT | Saga patterns, exactly-once |
| Cadence (Uber) | uber/cadence | MIT | Payment order management |
| Camunda 7 CE | camunda/camunda-bpm-platform | Apache 2.0 | BPMN compliance processes |
| Apache Airflow | apache/airflow | Apache 2.0 | Batch pipelines |

---

## Блок 8: Audit Trail / Immutability

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| **pgAudit** | pgaudit/pgaudit | PostgreSQL | All DDL/DML logging |
| Formance hash chain | built-in Formance | MIT | Blockchain-style chaining |
| Debezium CDC | debezium/debezium | Apache 2.0 | Append-only event log |
| Sequin CDC | sequinstream/sequin | MIT | 50k ops/sec |
| **OpenMetadata** | open-metadata/OpenMetadata | Apache 2.0 | Data lineage для FCA |
| eugene-khyst/postgresql-event-sourcing | GitHub | Apache 2.0 | Event sourcing reference |

---

## Блок 9: Мультивалютный Учёт / ERP

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| ERPNext / Frappe | frappe/erpnext | MIT | Full ERP accounting backend |
| LedgerSMB | ledgersmb/LedgerSMB | GPL v2 | Clean accounting backend |
| **Frankfurter** | hakanensari/frankfurter | MIT | Self-hosted ECB FX rates |
| Beancount + Fava | beancount/beancount | GPL v2 | Plain-text audit trail |

---

## Блок 10: Event Streaming / Real-Time

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| **Apache Kafka** | apache/kafka | Apache 2.0 | ✅ уже в roadmap Phase 1 |
| Apache Flink | apache/flink | Apache 2.0 | Real-time fraud scoring |
| Apache Camel | apache/camel | Apache 2.0 | Legacy bank integration |
| Mojaloop | mojaloop/mojaloop | Apache 2.0 | ISO20022 payment rails |

---

## Блок 11: IAM / Безопасность

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| **Keycloak** | keycloak/keycloak | Apache 2.0 | SSO, MFA, RBAC для агентов |
| adorsys/open-banking-gateway | adorsys/open-banking-gateway | Apache 2.0 | PSD2/XS2A → bank statements |

---

## Блок 12: Observability / Tracing

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| **OpenTelemetry** | open-telemetry | Apache 2.0 | ✅ Midaz native |
| **Jaeger v2** | jaegertracing/jaeger | Apache 2.0 | Full payment trace |
| ELK Stack | elastic | SSPL/Apache | Centralized logs |
| **Prometheus** | prometheus/prometheus | Apache 2.0 | ✅ уже (safeguarding alerts) |

---

## Блок 13: AI / LLM для Финансового Анализа

| Компонент | GitHub | Лицензия | Use Case |
|-----------|--------|----------|---------|
| FinGPT | AI4Finance-Foundation/FinGPT | MIT | Financial LLM analysis |
| OpenBB Platform | OpenBB-finance/OpenBB | Apache 2.0 | Financial data platform |

---

## Полная таблица (47 компонентов)

| Блок | Компонент | GitHub | Лицензия | Статус |
|------|-----------|--------|----------|--------|
| Ledger | Midaz | lerianstudio/midaz | Apache 2.0 | ✅ deployed |
| Ledger | Formance Ledger | formancehq/ledger | MIT | ⏳ P1 |
| Ledger | Blnk Finance | blnkfinance/blnk | Apache 2.0 | ❌ P0 recon |
| Ledger | Apache Fineract | apache/fineract | Apache 2.0 | ↗️ FALLBACK |
| Reconciliation | Blnk Reconciliation | built-in Blnk | Apache 2.0 | ❌ P0 |
| Reconciliation | Formance Recon | formancehq/stack | MIT | ⏳ P1 |
| Reconciliation | bankstatementparser | sebastienrousseau/... | Apache 2.0 | ❌ P0 |
| Reconciliation | Debezium CDC | debezium/debezium | Apache 2.0 | ❌ Phase 1 |
| Analytics | ClickHouse | ClickHouse/ClickHouse | Apache 2.0 | ✅ deployed |
| Analytics | Apache Superset | apache/superset | Apache 2.0 | ❌ Phase 1 |
| Analytics | Metabase | metabase/metabase | AGPL v3 | ❌ Phase 1 |
| Analytics | Grafana | grafana/grafana | AGPL v3 | ✅ (Midaz) |
| ETL | dbt Core | dbt-labs/dbt-core | Apache 2.0 | ❌ P0 |
| ETL | Apache Airflow | apache/airflow | Apache 2.0 | ❌ Phase 1 |
| ETL | Airbyte OSS | airbytehq/airbyte | ELv2 | ❌ Phase 2 |
| Data Quality | Great Expectations | great-expectations/... | Apache 2.0 | ❌ Phase 1 |
| Reporting | Midaz Reporter | lerianstudio | Apache 2.0 | ✅ available |
| Reporting | JasperReports | TIBCOSoftware/... | LGPL | ❌ P0 FIN060 |
| Reporting | WeasyPrint | Kozea/WeasyPrint | BSD | ❌ P0 |
| Reporting | FINOS RegTech | finos/open-regtech-sig | Apache 2.0 | ❌ Phase 2 |
| AML/KYC | Jube | jube-home/aml-fraud-... | AGPLv3 | ✅ deployed |
| KYC | Ballerine | ballerine-io/ballerine | MIT | ❌ Phase 0 |
| Workflow | n8n | n8n-io/n8n | Fair-code | ✅ deployed |
| Workflow | Temporal | temporalio/temporal | MIT | ❌ Phase 1 |
| Workflow | Cadence | uber/cadence | MIT | ↗️ Phase 2 |
| Workflow | Camunda 7 CE | camunda/camunda-bpm | Apache 2.0 | ❌ Phase 2 |
| Audit | pgAudit | pgaudit/pgaudit | PostgreSQL | ❌ P0 |
| Audit | Sequin CDC | sequinstream/sequin | MIT | ❌ Phase 1 |
| Audit | OpenMetadata | open-metadata/... | Apache 2.0 | ❌ Phase 2 |
| ERP | ERPNext | frappe/erpnext | MIT | ↗️ optional |
| ERP | LedgerSMB | ledgersmb/LedgerSMB | GPL v2 | ↗️ optional |
| ERP | Beancount | beancount/beancount | GPL v2 | ↗️ optional |
| FX | Frankfurter | hakanensari/frankfurter | MIT | ❌ Phase 0 |
| Streaming | Apache Kafka | apache/kafka | Apache 2.0 | ❌ Phase 1 |
| Streaming | Apache Flink | apache/flink | Apache 2.0 | ❌ Phase 2 |
| Integration | Apache Camel | apache/camel | Apache 2.0 | ↗️ Phase 2 |
| Payments | Mojaloop | mojaloop/mojaloop | Apache 2.0 | ↗️ Phase 2 |
| IAM | Keycloak | keycloak/keycloak | Apache 2.0 | ❌ Phase 1 |
| PSD2 | adorsys gateway | adorsys/open-banking-gateway | Apache 2.0 | ❌ Phase 0 |
| Tracing | OpenTelemetry | open-telemetry/... | Apache 2.0 | ✅ Midaz |
| Tracing | Jaeger v2 | jaegertracing/jaeger | Apache 2.0 | ❌ Phase 1 |
| Logging | ELK Stack | elastic/elasticsearch | SSPL/Apache | ❌ Phase 1 |
| Monitoring | Prometheus | prometheus/prometheus | Apache 2.0 | ✅ Midaz |
| AI/LLM | FinGPT | AI4Finance-Foundation/FinGPT | MIT | ❌ Phase 3 |
| AI/LLM | OpenBB Platform | OpenBB-finance/OpenBB | Apache 2.0 | ❌ Phase 3 |

---

## Приоритизация внедрения (по CASS 15 deadline)

### Немедленно (P0 — до 7 May 2026)
1. **Blnk или Formance Reconciliation** — automated daily safeguarding recon
2. **bankstatementparser** — парсинг CAMT.053 bank statements
3. **dbt + ClickHouse** — трансформация → FIN060 шаблоны
4. **pgAudit** — включить на всех PostgreSQL БД (5432, 15432, 15433)
5. **JasperReports или WeasyPrint** — PDF FIN060a/b для RegData
6. **Frankfurter** — self-hosted ECB FX rates
7. **adorsys PSD2 gateway** — automated bank statement retrieval

### Q2–Q3 2026 (Операционная зрелость)
- Great Expectations, Metabase/Superset, Debezium/Sequin, Temporal, Apache Kafka

### Q4 2026 (AI-First)
- Camunda 7 CE, OpenMetadata, FinGPT/OpenBB, Ballerine, Apache Flink

---

## Исключённые технологии

- Любые компоненты из РФ, Ирана, КНДР, Беларуси, Сирии
- SWIFT MT-only (без ISO20022)
- Платные SaaS без self-hosted опции
- ClickHouse Inc. — НЕ запрещён (независимая американская компания с 2021, Apache 2.0)

---

*IL-009 Step 1 DONE | Source: CEO research report 2026-04-06*
