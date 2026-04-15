# BANXE Subagent Context (обязателен для КАЖДОГО субагента)

## Stack
- CBS: Midaz (PRIMARY), Fineract (FALLBACK)
- AML: Moov Watchman + Yente + custom tx_monitor
- Audit: ClickHouse (5yr TTL, append-only)
- Agents: OpenClaw MOA on GMKtec (192.168.0.72)

## DO NOT
- Use float for money (Decimal only)
- Store secrets in code
- Use sanctioned jurisdiction tech (RU, IR, KP, BY, SY)
- Skip AML/KYC on any payment flow
- Commit without quality-gate.sh pass

## Active Compliance
- FCA CASS 15 deadline: 7 May 2026
- Invariants I-01..I-28 are absolute (see INVARIANTS.md)
- HITL mandatory for amounts ≥£10k

## Current Sprint
- Safeguarding deploy (IL-043, P0)
- FastAPI REST API Layer (P1)
