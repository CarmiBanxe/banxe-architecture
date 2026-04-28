# IL-FIN-01: Financial Accounts — GL Integration via LedgerPort

- Sprint: 44
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: CarmiBanxe/banxe-emi-stack#25
- PR: CarmiBanxe/banxe-emi-stack#26
- Merge SHA: 9e62b7a
- Closed: 2026-04-28

## Summary

GLService with double-entry bookkeeping and Protocol DI. Account model with
type classification, multi-currency (GBP/EUR/USD), jurisdiction blocking,
high-value HITL gate, immutable audit trail.

## Deliverables

- services/ledger/gl_service.py — GLService
- services/ledger/ledger_models.py — Account, JournalEntry, Posting, PostingStatus
- services/ledger/ledger_port.py — LedgerPort Protocol
- services/ledger/inmemory_ledger.py — InMemoryLedger
- tests/test_gl_service.py — 34 tests

## Acceptance criteria — ALL MET

- test_double_entry_debit_credit_balanced (Decimal, I-01) ✅
- test_journal_entry_immutable (I-24) ✅
- test_multi_currency_posting (GBP/EUR/USD) ✅
- test_blocked_jurisdiction_account_rejected (I-02) ✅
- test_high_value_posting_flagged (I-04) ✅
- test_gl_audit_trail_complete (I-24) ✅
- Coverage 82-100%, Ruff clean ✅

## Compliance impact

- S16 Financial Accounts: 0% → 15%
