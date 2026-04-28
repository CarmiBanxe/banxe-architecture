# ADR-FIN-01: General Ledger Port — Double-Entry Bookkeeping via LedgerPort

## Status
Accepted

## Context
S16 (Financial Accounts) was at 0% coverage. The existing `services/ledger/`
directory contained only the Midaz HTTP adapter (`midaz_adapter.py`) and client
(`midaz_client.py`), but no domain-level General Ledger abstraction. Without a
GL service layer, financial operations cannot enforce double-entry bookkeeping
invariants, and there is no audit trail for journal entries independent of the
underlying CBS (Midaz).

GAP D-gl (Midaz GL integration) was NOT_STARTED.

## Decision
A `GLService` in `services/ledger/` provides double-entry bookkeeping with
Protocol DI:

1. **LedgerPort Protocol**: Abstract interface for GL operations (create account,
   post journal entry, get balance). `InMemoryLedger` for tests; Midaz adapter
   pattern for production.
2. **Double-entry enforcement**: Every `JournalEntry` must have balanced
   debit/credit postings per currency. Unbalanced entries raise
   `UnbalancedEntryError`. This is enforced at the service level, not just
   the database level.
3. **Account model**: `Account` with type classification (ASSET, LIABILITY,
   EQUITY, REVENUE, EXPENSE), currency, and jurisdiction.
4. **Multi-currency**: GBP, EUR, USD supported. Per-currency balance tracking.
5. **Jurisdiction blocking**: Account creation for blocked jurisdictions (I-02)
   raises `JurisdictionBlockedError`.
6. **High-value HITL**: Journal entries with total debit ≥ £50k return
   `HighValueHITLProposal` requiring MLRO approval (I-04, I-27).
7. **Audit trail**: Every GL operation (account creation, journal posting)
   records an immutable `GLAuditEntry` via `GLAuditPort` Protocol (I-24).

## Consequences
Positive:
- S16 coverage moves from 0% to ~15%.
- Double-entry invariant enforced programmatically — cannot post unbalanced entries.
- Protocol DI enables swap between Midaz and any future CBS without changing
  business logic.
- Audit trail provides FCA-evidence for all financial account operations.

Negative:
- Real Midaz GL adapter not yet wired to `LedgerPort` — InMemory only.
- No chart-of-accounts seeding — accounts created ad-hoc.
- Multi-currency FX conversion not yet handled (postings must be same-currency).

## References
- IL-FIN-01 (Sprint 44)
- PR: CarmiBanxe/banxe-emi-stack#26
- ADR-013 (Midaz PRIMARY CBS)
- I-01 (Decimal), I-02 (jurisdictions), I-04 (high-value), I-24 (audit), I-27 (HITL)
