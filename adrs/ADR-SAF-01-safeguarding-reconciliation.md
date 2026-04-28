# ADR-SAF-01: Safeguarding Reconciliation Engine — FCA CASS 7 Daily Recon

## Status
Accepted

## Context
FCA CASS 7.15 mandates daily reconciliation of client funds against safeguarding
accounts. The existing `services/recon/reconciliation_engine.py` (IL-007) provides
basic MATCHED/DISCREPANCY detection against bank statements, but lacks:
- Aggregate client-funds-vs-safeguarding comparison
- Blocked jurisdiction exclusion (I-02)
- Large value flagging (I-04)
- HITL escalation for shortfalls (I-27)
- Structured report generation for FCA evidence

S6 (Safeguarding Engine) was at 20% with the reconciliation gap being the highest
priority for the 7 May 2026 CASS 15 deadline.

## Decision
A new `ReconciliationEngine` in `services/recon/` performs daily aggregate recon:

1. **LedgerPort Protocol**: Fetches client fund balances and safeguarding account
   balances via hexagonal port. `InMemoryLedgerPort` for tests; Midaz adapter
   for production.
2. **Jurisdiction exclusion**: Accounts in blocked jurisdictions (I-02:
   RU/BY/IR/KP/CU/MM/AF/VE/SY) are excluded from totals — they must not
   contaminate the safeguarding calculation.
3. **Tolerance**: £0.01 (penny-exact, FCA CASS 7). Differences within tolerance
   are BALANCED; above tolerance are DISCREPANCY.
4. **Large value flagging**: Accounts with balance ≥ £50k flagged (I-04).
5. **HITL escalation**: Shortfalls (client funds > safeguarding) trigger
   `HITLEscalation` requiring MLRO approval (I-27). Surpluses are flagged
   but do not trigger HITL.
6. **Report generation**: `ReconReportGenerator` produces JSON reports with
   FCA compliance metadata for evidence collection.
7. **Audit trail**: Every recon run produces an immutable `ReconAuditEntry` (I-24).

## Consequences
Positive:
- S6 coverage moves from 20% to ~35%.
- Daily recon satisfies FCA CASS 7.15 evidence requirement.
- HITL escalation ensures shortfalls are never silently ignored.
- Jurisdiction exclusion prevents sanctioned-country contamination.

Negative:
- Real Midaz adapter not yet wired — InMemory only for now.
- PDF report format not yet implemented (JSON only).
- External bank balance polling (S6-10) still blocked by S4 BaaS.

## References
- IL-SAF-01 (Sprint 44)
- PR: CarmiBanxe/banxe-emi-stack#24
- FCA CASS 7.15, CASS 7.13, CASS 7.14
- I-01 (Decimal), I-02 (jurisdictions), I-04 (large value), I-24 (audit), I-27 (HITL)
