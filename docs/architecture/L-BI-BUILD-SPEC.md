# L-BI — Business Intelligence & Dashboard Layer Build-Spec
**IL-551 | P3 Sprint 13 | Status: Spec-Locked**
**Source: CEO | Session: agent-factory-l-bi**

---

## 0. Duplication Audit (ADR-102)

| Component | Repo | Relation |
|---|---|---|
| L-lake | banxe-emi-stack | Data source — ClickHouse analytics tables. L-bi READS from L-lake; does NOT reimplement. |
| D-fin | banxe-emi-stack | Financial reporting engine. L-bi consumes D-fin output data for management P&L views; does NOT reimplement reporting or GL. |
| K-gabriel / F-finrpt | banxe-emi-stack | Regulatory submission pipeline. L-bi reads KPIs derived from those outputs; does NOT duplicate or reimplement submission logic. |
| Metabase / Superset | P1 backlog | Candidate BI rendering tier (self-hosted); selection is an operator decision, not in this spec. |

**Boundary:** L-bi = BI/dashboard layer (management reporting + FCA KPI monitoring) reading from L-lake/ClickHouse + D-fin outputs. Read-only analytics. No write to ledger, reporting engine, or data lake.

---

## 1. Scope

L-bi provides the **management reporting and FCA KPI monitoring** dashboard layer for Banxe AI Bank. It reads pre-computed analytics data from L-lake (ClickHouse) and D-fin outputs, and exposes structured KPI views to operators, CFO, and MLRO.

### 1.1 Management reporting views

| View | Data source | Refresh |
|---|---|---|
| Daily P&L summary | D-fin `pl_daily` mart | Daily 07:00 UTC |
| Monthly balance sheet | D-fin `balance_sheet_monthly` | Monthly T+1 |
| Revenue by product tier | L-lake `product_revenue` ClickHouse | Daily |
| FX exposure snapshot | E-treasury `fx_exposure` (read-only) | Hourly |
| Client-funds safeguarding balance | `safeguarding_events` ClickHouse (D-recon) | Daily after recon run |

### 1.2 FCA KPI monitoring

| KPI | Source | Threshold / SLA |
|---|---|---|
| Safeguarding coverage ratio (client funds vs segregated account) | `safeguarding_events` | ≥ 100% (CASS 15 §2.2) |
| Recon discrepancy streak | `safeguarding_breaches` ClickHouse | 0 consecutive shortfalls (MLRO alert at 1) |
| Consumer Duty outcome scores | `consumer_duty_outcomes` ClickHouse | Quarterly trend ≥ target |
| Regulatory submission deadline tracker | K-gabriel submission log | 0 overdue (FCA FIN060 15th of month+1) |
| AML alert closure rate | F-aml `aml_alert_log` ClickHouse | ≤ 48h mean time-to-close (MLRO SLA) |
| SAR filing timeliness | F-aml SAR log | 100% within 24h of MLRO decision |

### 1.3 KPI definitions — config-as-data

All KPI thresholds, refresh cadences, and alert recipients are defined in config, not hardcoded:

```yaml
# l_bi_kpi_config.yaml (config-as-data, banxe-emi-stack/services/bi/)
kpis:
  safeguarding_coverage:
    source: clickhouse
    table: banxe.safeguarding_events
    threshold_min: 1.0        # 100%
    alert_on: below_threshold
    alert_recipient: MLRO
  recon_discrepancy_streak:
    source: clickhouse
    table: banxe.safeguarding_breaches
    threshold_max: 0
    alert_on: above_threshold
    alert_recipient: MLRO
  regulatory_deadline_overdue:
    source: k_gabriel_log
    threshold_max: 0
    alert_on: above_threshold
    alert_recipient: CFO
```

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────┐
│                L-BI DASHBOARD LAYER                  │
│  (read-only; no write to ledger/reporting/lake)     │
├──────────────┬──────────────────┬───────────────────┤
│  KPI Engine  │  Report Builder  │  Dashboard Render │
│  (config-as- │  (D-fin mart     │  (Metabase /      │
│   data KPIs) │   aggregations)  │   Superset —      │
│              │                  │   operator picks) │
└──────┬───────┴────────┬─────────┴───────────────────┘
       │                │
       ▼                ▼
┌─────────────┐  ┌─────────────────┐
│  L-lake     │  │  D-fin output   │
│  ClickHouse │  │  (mart tables)  │
│  :9000      │  │  PostgreSQL     │
└─────────────┘  └─────────────────┘
```

### 2.1 Data access pattern

- **Read-only ports only:** L-bi uses `AnalyticsQueryPort` (Protocol) — no direct ClickHouse client instantiation in business logic.
- **No cross-service write:** L-bi MUST NOT write to `safeguarding_events`, `aml_alert_log`, or any financial table.
- **InMemory stub for tests:** `InMemoryAnalyticsPort` returns fixture data; no live ClickHouse required in CI.

### 2.2 Hexagonal ports

```python
class AnalyticsQueryPort(Protocol):
    async def query_kpi(self, kpi_id: str, as_of: date) -> KPISnapshot: ...
    async def query_management_view(self, view_id: str, period: DateRange) -> DataFrame: ...

class KPIAlertPort(Protocol):
    async def send_alert(self, kpi_id: str, value: Decimal, threshold: Decimal, recipient: str) -> None: ...
```

Adapters: `ClickHouseAnalyticsAdapter` (live), `InMemoryAnalyticsPort` (tests).

### 2.3 Invariants

| Invariant | Rule |
|---|---|
| I-01 | All monetary KPI values use `Decimal`. Never `float`. |
| I-24 | L-bi reads audit tables; never deletes or updates them. |
| I-27 | KPI threshold changes require CFO/MLRO sign-off (HITL — AI proposes, human decides). |
| I-28 | All KPI snapshot queries logged (source, timestamp, value) for FCA audit reproducibility. |

---

## 3. Definition of Done / Acceptance Criteria

- [ ] `services/bi/` created in banxe-emi-stack with `KPIEngine`, `AnalyticsQueryPort`, `InMemoryAnalyticsPort`.
- [ ] KPI config loaded from `l_bi_kpi_config.yaml` (config-as-data, no hardcoded thresholds).
- [ ] All 6 FCA KPIs queryable via `KPIEngine.get_kpi_snapshot(kpi_id, as_of)`.
- [ ] `KPIAlertPort` sends alert when threshold breached (InMemory in tests).
- [ ] ≥ 15 tests: KPI threshold logic, alert trigger, config-as-data load, InMemory adapter.
- [ ] Coverage ≥ 80% on `services/bi/`.
- [ ] `ruff` clean, `mypy` clean, `semgrep banxe-rules` 0 findings.
- [ ] Dashboard rendering tier (Metabase / Superset) is an **operator decision** — NOT activated here.
- [ ] No write to any financial table.

---

## 4. Out of Scope (fail-closed)

- No reimplementation of L-lake ClickHouse schema or ingestion pipelines.
- No reimplementation of D-fin reporting engine or GL.
- No reimplementation of K-gabriel / F-finrpt submission logic.
- No activation of Metabase/Superset (operator decision, P1 backlog item).
- No KYC/KYB/AML/payment rail logic.
- No write to ledger, audit trail, or safeguarding tables.
- Runtime implementation in banxe-emi-stack is a **separate operator-authorized action**.

---

## 5. Operator Gates

| Gate | Condition | Decision-maker |
|---|---|---|
| Dashboard rendering tier selection | Metabase vs Superset vs custom — not decided | CEO + CTIO |
| KPI threshold live-config activation | Moving thresholds from defaults to production values | CFO + MLRO |
| BI layer live activation | Connecting to production ClickHouse | CTIO |

---

## 6. References

- L-lake: `docs/architecture/L-LAKE-BUILD-SPEC.md` (ClickHouse data source, 30%)
- D-fin: `docs/architecture/D-FIN-BUILD-SPEC.md` (financial reporting engine)
- K-gabriel: `docs/architecture/K-GABRIEL-BUILD-SPEC.md` (FCA submission + breach reporting)
- F-finrpt: `docs/architecture/F-FINRPT-BUILD-SPEC.md` (FIN060 generation)
- E-safeguard: `docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md` (safeguarding KPI source)
- ROADMAP-MATRIX: `docs/ROADMAP-MATRIX.md`
- ADR-102: deduplication rule
- ADR-119: append-only ledger
- Invariants: I-01 (Decimal), I-24 (append-only), I-27 (HITL), I-28 (audit reproducibility)
