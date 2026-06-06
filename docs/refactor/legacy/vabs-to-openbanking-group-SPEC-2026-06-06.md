# Refactor SPEC #10 — VABS to Open Banking migration group

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_TRANSFORM; NEW-driven; extends PartnerPort)
Scope: 10 TRANSFORM-VABS legacy projects -> Open Banking AISP/PISP via Plaid/TrueLayer (OSS)
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/ on evo1; CLASS_TRANSFORM.tsv
NEW capability: C3 (fiat payment rails / Open Banking) per ADR-020 + NEW-PROJECT-PRIORITY-MAP
Related: ADR-020 VABS-to-open-banking; SPEC #5 EMI Banking; PartnerPort CONTRACT (open_banking partner type)
Owner: Terminal B (smart refactor)

## Purpose

NEW-driven: C3 (Open Banking) authoritatively requires AISP (account info) + PISP (payment initiation) rails. Legacy VABS (Virtual Account Banking System) provided these via a proprietary stack; migrate to OSS Plaid/TrueLayer behind PartnerPort (open_banking partner type, SPEC #5 CONTRACT). Legacy VABS code is mined for account-mapping + event-flow business logic; the VABS runtime is dropped.

## Legacy inventory (10 projects)

- neuron/client-virtual-abs — VABS client (consumer of VABS API)
- banxe/vabs2/{common,core,logger,api-error,event-service,rabbit-mq} — VABS2 monorepo (7 modules: shared libs + core + async event + MQ)
- banxe/abs-api + banxe-fiat-backend/{abs-api,abs-common} — ABS API layers (3 variants/copies)

## Decision (NEW-driven)

| Legacy | Decision | Keep | Drop |
|---|---|---|---|
| neuron/client-virtual-abs | TRANSFORM | account-mapping logic, consumer patterns | VABS-specific transport |
| vabs2/core + common + api-error | TRANSFORM | domain model, error taxonomy | VABS runtime |
| vabs2/event-service + rabbit-mq | TRANSFORM | event flow design | legacy MQ wiring (use NEW RabbitMQ from midaz stack) |
| vabs2/logger | DROP | (none) | use NEW structured logging |
| abs-api x3 (3 copies) | TRANSFORM (dedupe) | one canonical API surface | 2 duplicate copies |

Net: 10 legacy projects -> one OpenBankingAdapter (PartnerPort, open_banking type) backed by Plaid/TrueLayer. Three abs-api copies deduplicated to one. VABS runtime + MQ wiring + logger dropped (NEW infra serves them).

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + decision (this SPEC).
- Phase B (Terminal B): extract account-mapping + event-flow domain model from vabs2/core; dedupe 3 abs-api copies into one canonical surface.
- Phase C (Terminal B): implement OpenBankingAdapter (PartnerPort open_banking type) on Plaid + TrueLayer SDKs; wire AISP (getAccounts/getBalance) + PISP (initiatePayment via PartnerPort).
- Phase D (Terminal B): shadow-mode AISP/PISP vs legacy VABS for one cycle; zero-mismatch on account balances + payment outcomes.
- Phase E (Terminal B): cut over to OpenBankingAdapter; remove VABS callers.
- Phase F (Terminal B): tag 10 VABS projects ARCHIVE; record decommission in IL.

## Risk register tie-in

- R-REG-04 (ACPR): Open Banking account balances must reconcile to midaz-ledger; zero-mismatch gate.
- R-MIG-DEDUP-01 (3 abs-api copies): audit all 3 for divergent business logic before deduping to one; do not lose copy-specific rules.
- R-SEC-NEW-06 (Plaid/TrueLayer keys): provider secrets under /etc/banxe-open-banking/.env mode 600; rotate per S17.

## Acceptance criteria

- account-mapping + event-flow model extracted; VABS runtime NOT in NEW dep tree.
- OpenBankingAdapter implements PartnerPort open_banking type; passes the 11-test PartnerPort CONTRACT conformance suite.
- 3 abs-api copies deduplicated to one canonical surface (no lost business rule).
- Phase D shadow-mode: 0 mismatch on AISP balances + PISP outcomes for one cycle.
- 10 VABS projects ARCHIVE; decommission in IL.

## References

- ADR-020 VABS-to-open-banking
- NEW-PROJECT-PRIORITY-MAP-2026-06-06.md (C3)
- CLASS_TRANSFORM.tsv (10 TRANSFORM-VABS rows)
- SPEC #5 emi-banking-services + emi-banking-partnerport-CONTRACT (open_banking partner type)
- RISK_REGISTER-2026-05-22.md (R-REG-04)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF VABS-to-OpenBanking SPEC #10 (CLASS_TRANSFORM; NEW-driven C3) ===
