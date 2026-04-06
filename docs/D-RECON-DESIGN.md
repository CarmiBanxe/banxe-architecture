# D-RECON: Reconciliation Engine Design

**ADR-style design document**  
**Block:** D (Reconciliation)  
**Sprint:** 9  
**Status:** DESIGN (not yet implemented)  
**Owner:** CEO (Moriel Carmi) + CTIO  
**FCA Deadline (Block J dependency):** 7 May 2026  
**IL:** IL-006 Step 5

---

## Context

FCA CASS 7 requires that an FCA-authorised EMI performing safeguarding:
- Maintains a record of client funds in a qualifying institution (CASS 7.13)
- Performs **daily reconciliation** between internal ledger balances and external bank statements (CASS 7.15)
- Can produce a reconciliation report on demand for FCA supervisory review

Block J Phase 1 (completed 2026-04-06) created the Midaz safeguarding ledger with two accounts:
- `client_funds` (liability, `019d6332-da7f-752f-b9fd-fa1c6fc777ec`) — client money held
- `operational` (asset, `019d6332-f274-709a-b3a7-983bc8745886`) — BANXE's own operational funds

The gap: Midaz holds the **internal ledger balance**, but there is currently no automated link to the **external bank statement** (Barclays/Lloyds safeguarding account). Without this link, BANXE cannot prove CASS 7.15 compliance.

---

## Decision

Build a reconciliation engine that:

1. **Pulls daily Midaz balances** via LedgerPort (HTTP GET /balances)
2. **Ingests external bank statements** (CSV/CAMT.053 via SFTP or API)
3. **Compares** internal vs external balances per account, per currency
4. **Writes reconciliation events** to ClickHouse (append-only, TTL 5Y)
5. **Alerts on discrepancy** via n8n → MLRO Telegram notification

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│              D-RECON Engine (Python service)             │
├──────────────┬──────────────────┬───────────────────────┤
│  LedgerPort  │  StatementFetcher│  ReconciliationEngine  │
│  (CTX-06)    │  (SFTP/CSV/API)  │  (diff + alert logic)  │
└──────┬───────┴────────┬─────────┴──────────┬────────────┘
       │                │                    │
       ▼                ▼                    ▼
  Midaz :8095    External Bank         ClickHouse :9000
  (balances)     Statement (CSV)       (safeguarding_events)
                                            │
                                            ▼
                                       n8n :5678
                                   (MLRO alert trigger)
```

---

## ClickHouse Table: `safeguarding_events`

```sql
CREATE TABLE banxe.safeguarding_events
(
    event_id         UUID         DEFAULT generateUUIDv4(),
    event_time       DateTime64(3) DEFAULT now(),
    recon_date       Date,
    account_id       String,       -- Midaz account UUID
    account_type     LowCardinality(String),  -- 'client_funds' | 'operational'
    currency         LowCardinality(String),  -- 'GBP'
    internal_balance Decimal(18, 2),          -- Midaz ledger balance
    external_balance Decimal(18, 2),          -- Bank statement balance
    discrepancy      Decimal(18, 2),          -- external - internal
    status           LowCardinality(String),  -- 'MATCHED' | 'DISCREPANCY' | 'PENDING'
    alert_sent       UInt8         DEFAULT 0,
    source_file      String,                  -- bank statement filename
    created_by       String        DEFAULT 'recon-engine'
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(recon_date)
ORDER BY (recon_date, account_id)
TTL event_time + INTERVAL 5 YEAR    -- FCA record-keeping minimum
SETTINGS index_granularity = 8192;
```

---

## Daily Reconciliation Flow

```
06:00 CEST daily (n8n cron trigger):
  1. GET /v1/organizations/{org}/ledgers/{ledger}/accounts/{account_id}/balance
     → internal_balance (client_funds GBP)
     → internal_balance (operational GBP)

  2. SFTP pull: /statements/YYYY-MM-DD-safeguarding.csv
     OR Barclays Open Banking API: GET /accounts/{ext_account_id}/balances

  3. For each account:
       discrepancy = |external_balance - internal_balance|
       if discrepancy > threshold (£1.00):
           status = 'DISCREPANCY'
           INSERT into safeguarding_events (status='DISCREPANCY')
           POST n8n webhook → MLRO Telegram alert
       else:
           status = 'MATCHED'
           INSERT into safeguarding_events (status='MATCHED')

  4. Generate daily CASS 7.15 report:
       SELECT * FROM banxe.safeguarding_events
       WHERE recon_date = today()
       FORMAT CSV
```

---

## Alert Pipeline (MLRO Notification)

```
Discrepancy detected
    │
    ▼
n8n :5678 webhook
    │
    ▼
Telegram: @mycarmi_moa_bot (MLRO operator)
Message format:
    ⚠️ CASS 7 ALERT: Safeguarding discrepancy detected
    Date: {recon_date}
    Account: {account_type} ({account_id})
    Internal: £{internal_balance}
    External: £{external_balance}
    Delta: £{discrepancy}
    Action required: MLRO review within 24h (FCA CASS 7.15)
```

---

## FCA CASS 7.15 Compliance Mapping

| Requirement | Implementation |
|-------------|---------------|
| Daily reconciliation | n8n cron 06:00 CEST |
| Internal record | Midaz ledger balance via LedgerPort |
| External statement | SFTP CSV or Open Banking API |
| Discrepancy threshold | £1.00 (configurable) |
| MLRO notification | n8n → Telegram within 1h of detection |
| Audit trail | ClickHouse safeguarding_events, TTL 5Y |
| On-demand report | SELECT from ClickHouse → CSV |
| Regulatory producibility | ClickHouse + FCA audit trail (existing I-24) |

---

## Consequences

### Positive
- Satisfies FCA CASS 7.15 daily reconciliation requirement
- Alert pipeline ensures MLRO visibility within minutes of discrepancy
- ClickHouse provides tamper-evident 5-year audit trail (existing I-24)
- n8n cron reuses existing infrastructure (:5678)
- LedgerPort interface keeps CBS-agnostic design (Midaz → Fineract swap transparent to recon engine)

### Negative / Risks
1. **External bank statement format** — Barclays/Lloyds format unknown until bank account opened. Design uses CSV placeholder; may need CAMT.053 or Open Banking API adaptation.
2. **Midaz Transaction API** — `create_transaction()` currently `NotImplementedError`. Recon reads balances only; write path (Block D-recon transactions) depends on IL-006 Step 2.
3. **Network dependency** — if Midaz `:8095` or ClickHouse `:9000` unavailable at recon time, alert must fire for infra failure, not just discrepancy.

---

## Open Questions (for CEO / CTIO decision)

| # | Question | Default assumption |
|---|----------|--------------------|
| Q1 | External bank: Barclays or Lloyds? | Barclays (per FCA authorisation) |
| Q2 | Statement delivery: SFTP or Open Banking API? | SFTP CSV (simpler, no OAuth) |
| Q3 | Discrepancy threshold: £1.00 or £0.01? | £1.00 (FCA doesn't specify — CEO decides) |
| Q4 | Recon frequency: daily or real-time? | Daily (CASS 7.15 minimum) |
| Q5 | MLRO alert channel: Telegram or email? | Telegram (@mycarmi_moa_bot, existing) |

---

## Implementation Plan (Sprint 9)

| Step | Task | Owner |
|------|------|-------|
| D-1 | Implement LedgerPort.get_balance() (already in ledger_port.py) | Aider |
| D-2 | Implement LedgerPort.create_transaction() (IL-006 Step 2) | Aider |
| D-3 | ClickHouse table: safeguarding_events | Aider |
| D-4 | ReconciliationEngine class (Python) | Aider |
| D-5 | StatementFetcher (CSV placeholder) | Aider |
| D-6 | n8n workflow: daily cron + MLRO alert | Manual config |
| D-7 | Tests (15 unit + 5 integration) | Aider |
| D-8 | FCA report template (CSV export) | Aider |

---

## Related

- ADR-013: Midaz CBS, safeguarding account IDs
- ADR-014: Composable Financial Stack, Block J risks
- IL-006: Block D Transaction API + Recon (this sprint)
- I-24: AuditPort append-only (ClickHouse constraint)
- I-10: No fake integrations (Midaz must be live)
- CTX-06: Core Banking bounded context
- `docs/blocks-sprint8.md`: Block J IN_PROGRESS
