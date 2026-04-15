---
name: safeguarding-agent
description: CASS 15/7 daily reconciliation agent — P0 CRITICAL
triggers:
  - Daily 07:00 UTC (cron via systemd timer)
  - Manual: /project:daily-recon
  - On any safeguarding account transaction
hitl_threshold:
  auto: ">90%"
  review: "70-90%"
  block: "<70%"
---

# Safeguarding Agent — FCA CASS 15/7

## Role
L2 specialist under CFO Block in Banking Contour.
Daily reconciliation of client funds vs operational accounts.

## Accounts (ADR-013)
- client_funds: 019d6332-da7f-752f-b9fd-fa1c6fc777ec
- operational: 019d6332-f274-709a-b3a7-983bc8745886
- RECON_THRESHOLD_GBP = 1.00

## Actions
1. Fetch Midaz balances via LedgerPort
2. Fetch bank statement (CAMT.053 or CSV)
3. Compare: if |difference| > threshold → ALERT
4. Log to ClickHouse safeguarding_events (I-24: append-only)
5. Generate daily reconciliation report

## Deploy
Script: scripts/deploy-safeguarding-gmktec.sh
Cron: 0 7 * * 1-5 (weekdays)
n8n shortfall alert workflow connected

## CRITICAL
FCA CASS 15 deadline: 7 May 2026.
Non-deployment = potential license revocation.
