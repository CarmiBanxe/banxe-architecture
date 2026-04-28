# ADR-CBS-01: CBS GL — Payment Posting Logic via LedgerPort

## Status
Accepted

## Context
IL-PAY-02 (payment processing) and IL-FIN-01 (GL service) existed as isolated
services. Payment lifecycle events (capture, settle, refund) had no automatic
GL impact — journal entries had to be created manually. This creates reconciliation
risk and violates the principle that every financial event must have a corresponding
double-entry GL posting.

GAP S3-11 (GL logic integration with Midaz) was NOT_STARTED.

## Decision
A `PaymentPostingService` in `services/ledger/` bridges payments → GL:

1. **PostingRuleEngine**: Maps payment event types to debit/credit account pairs.
   CAPTURED → debit Customer Funds, credit Settlement Pending.
   SETTLED → debit Settlement Pending, credit Merchant Payable.
   REFUNDED → reverse (debit Merchant, credit Customer).
2. **AccountRegistry**: Maps logical account types to GL account IDs.
3. **Double-entry enforcement**: Every posting goes through GLService which
   validates debits == credits per currency. Unbalanced entries impossible.
4. **High-value flagging**: Events ≥ £10k flagged at posting level (I-04).
   Events ≥ £50k trigger GLService HITL (HighValueHITLProposal).
5. **Jurisdiction blocking**: Events from I-02 countries rejected before posting.
6. **No rule for AUTHORIZED/FAILED**: Authorization has no GL impact (no funds
   movement). Failed payments are not posted.

## Consequences
Positive:
- S3 CBS coverage moves from 30% toward 40%.
- Every payment event automatically creates balanced GL entries.
- Settlement reconciliation provable: capture debit == settle credit per transaction.
- Full refund zeroes out all GL balances for a transaction.

Negative:
- Real Midaz GL adapter not yet wired — InMemory only.
- Multi-currency FX postings not yet handled (same-currency only).
- Batch settlement posting not yet implemented.

## References
- IL-CBS-01 (Sprint 45), PR: CarmiBanxe/banxe-emi-stack#32
- ADR-FIN-01 (GL service), ADR-PAY-01 (payment lifecycle)
- I-01, I-02, I-04, I-24
