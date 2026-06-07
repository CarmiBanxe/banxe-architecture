# Refactor SPEC #17 — CLASS_MERGE remainder (KYB + FX rate + payment-core + UX) closes CLASS_MERGE

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_MERGE final; NEW-driven; surfaces C24 KYB + C25 FX rate)
Scope: 9 remaining MERGE projects -> 4 groups (KYB, FX rate engine, payment-core merge, UX-services)
Source: BANXE.RAR; CLASS_MERGE.tsv
NEW capability: C24 (KYB business onboarding) + C25 (FX rate engine) + C3 (payment-core) + C9 (UX/notif)
Related: SPEC #8 KYC; SPEC #9 Hyperswitch; SPEC #3 NotificationPort; ADR-002 ClickHouse
Owner: Terminal B (smart refactor)

## Purpose

Close CLASS_MERGE NEW-driven sweep. Four groups of remaining MERGE projects map to NEW capabilities: KYB (business onboarding, distinct from individual KYC), FX rate engine (rates for trading/portfolio), payment-core consolidation (into banxe-payment-core + Hyperswitch), and UX-services (chat/banners/notifications).

## Groups + decisions

### KYB (C24) — banxe-companies -> kyb_onboarding + Ballerine
- Business (B2B) onboarding, distinct from C5 individual KYC. Ballerine OSS for KYB workflow. Mine company-verification logic.

### FX rate engine (C25) — crypto-api-rate + banxe-rates-api + banxe-rates -> fx_engine/rate_provider
- 3 rate services consolidate to one FX rate engine; feeds ExchangePort.getRate (SPEC #4) + portfolio (SPEC #7). Dedupe 3 -> 1.

### Payment-core (C3) — neuron-transaction-service + banxe-payments -> banxe-payment-core + Hyperswitch
- Merge into banxe-payment-core (related to SPEC #9 crypto-processing -> Hyperswitch). Mine transaction orchestration logic.

### UX-services (C9) — banxe-chat + banxe-banners + notification-api -> banxe-ux-services
- chat + banners = build-fresh UX; notification-api merges into NotificationPort (SPEC #3). Legacy as reference.

## Refactor strategy + acceptance (Phases A-F)

- Phase A (done): inventory + 4-group decision (this SPEC).
- Phase B-F (Terminal B): per group scaffold/merge/cut-over/ARCHIVE; KYB via Ballerine; FX engine dedupe 3->1; payment-core merge; notification-api into NotificationPort.
- Acceptance: C24 + C25 added to PRIORITY-MAP; FX 3->1 deduped; payment-core merged; notification-api in NotificationPort; 9 legacy ARCHIVE; CLASS_MERGE 15/15 closed.

## Risk register tie-in

- R-REG-02 (AML): KYB business onboarding gates corporate accounts.
- R-REG-04 (ACPR): FX rate accuracy affects client-money valuation.

## References

- SPEC #4 (ExchangePort rate consumer); SPEC #7 (portfolio rate consumer); SPEC #9 (Hyperswitch); SPEC #3 (NotificationPort)
- ADR-002 ClickHouse; NEW-PROJECT-PRIORITY-MAP (to amend C24 + C25)
- CLASS_MERGE.tsv (9 remaining rows); UNIVERSAL-CANON 1-12

=== END OF CLASS_MERGE remainder SPEC #17 (CLASS_MERGE 15/15 closed; NEW-driven C24 + C25) ===
