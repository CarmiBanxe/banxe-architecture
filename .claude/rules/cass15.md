---
paths: ["services/**", "dbt/**"]
---

# CASS 15 Stack Rules — BANXE AI BANK

## P0 CASS 15 — STACK MAP

> Repo: `CarmiBanxe/banxe-emi-stack` | Deadline: 7 May 2026 | IL-009/IL-010

```
┌──────────────────────────────────────────────────────────────┐
│              BANXE EMI — P0 ANALYTICS STACK                  │
│              FCA CASS 15 | Deadline: 7 May 2026              │
├──────────────────┬───────────────────┬───────────────────────┤
│  LEDGER          │  RECONCILIATION   │  REPORTING            │
├──────────────────┼───────────────────┼───────────────────────┤
│ Midaz :8095      │ bankstatementparser│ dbt Core              │
│ (PRIMARY CBS)    │ (CAMT.053/MT940)  │ stg→safeguarding→     │
│ LedgerPort ABC   │ ReconciliationEng │ fin060_monthly        │
│ get_balance()    │ StatementFetcher  │ WeasyPrint            │
│ I-28: LedgerPort │ threshold £1.00   │ → FIN060 PDF          │
│ only, no HTTP    │ MATCHED/DISC/PEND │ → RegData upload      │
├──────────────────┼───────────────────┼───────────────────────┤
│  AUDIT TRAIL     │  FX / RATES       │  INFRASTRUCTURE       │
├──────────────────┼───────────────────┼───────────────────────┤
│ pgAudit          │ Frankfurter :8181 │ PostgreSQL 17 :5432   │
│ ClickHouse :9000 │ (self-hosted ECB) │ ClickHouse :9000      │
│ (5yr TTL, I-24)  │ 160+ currencies   │ Redis :6379           │
│ safeguarding_    │ ✅ DEPLOYED IL-010 │ n8n :5678             │
│ events table     │ GBP→EUR 1.1461    │                       │
└──────────────────┴───────────────────┴───────────────────────┘
                   adorsys PSD2 Gateway (Phase 2 — FA-07)
                   → CAMT.053 bank statement auto-pull
```

| FA | Компонент | Статус | IL |
|----|-----------|--------|----|
| FA-01 | ReconciliationEngine (Midaz vs bank) | ✅ code | IL-007 |
| FA-02 | bankstatementparser (CAMT.053) | ✅ wrapper | IL-009 |
| FA-03 | dbt Core (staging→safeguarding→fin060) | ✅ models | IL-009 |
| FA-04 | pgAudit | ✅ **DEPLOYED** pgaudit 17.1 | IL-010 |
| FA-05 | WeasyPrint FIN060 PDF | ✅ code | IL-009 |
| FA-06 | Frankfurter FX :8181 | ✅ **DEPLOYED** | IL-010 |
| FA-07 | mock-ASPSP FastAPI :8888 | ✅ **DEPLOYED** (sandbox) | IL-011 |

**Safeguarding accounts (ADR-013):**
- client_funds: `019d6332-da7f-752f-b9fd-fa1c6fc777ec`
- operational:  `019d6332-f274-709a-b3a7-983bc8745886`
- RECON_THRESHOLD_GBP = 1.00 | Cron: `0 7 * * 1-5`
