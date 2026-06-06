# Refactor SPEC #13 — Partner-bank adapters group (PartnerPort instances + AccountPort)

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_PORT; NEW-driven; concretises PartnerPort + surfaces AccountPort)
Scope: 7 PORT-ADAPTER bank projects -> 4 PartnerPort bank adapters (Wallester/ClearJunction/ClearBank/ContoMobile) + AccountPort (bank-api)
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/ on evo1; CLASS_PORT.tsv
NEW capability: C3 (fiat rails) + C4 (BaaS) per PartnerPort; surfaces C20 (account management) via AccountPort
Related: SPEC #5 + PartnerPort CONTRACT; S20 external blockers (ClearBank/Modulr appointments); ADR-020
Owner: Terminal B (smart refactor)

## Purpose

SPEC #5 + PartnerPort CONTRACT defined a generic PartnerPort. This SPEC concretises it with 4 specific bank-partner adapters (each implementing PartnerPort with its own external API). It also surfaces AccountPort (C20 account management) from bank-api. NEW-driven: C3/C4 EMI fiat rails require real banking partners; each legacy bank integration is mined for its API mapping, behind one uniform PartnerPort.

## Legacy inventory + decision (7 projects)

- banxe-wallester -> WallesterAdapter (PartnerPort baas type; card issuance partner)
- clear-junction-api + clear-junction-common -> ClearJunctionAdapter (PartnerPort sepa type); dedupe common into adapter
- clearbank-api -> ClearBankAdapter (PartnerPort sepa type; UK rails)
- contomobile-api + contomobile-common -> ContoMobileAdapter (PartnerPort open_banking type); dedupe common
- bank-api -> AccountPort (C20 account management; generic bank account ops, distinct from payment PartnerPort)

All 4 bank adapters implement the identical PartnerPort CONTRACT (SPEC #5); selection by PaymentInstruction.fromAccount.partner. AccountPort is a new port for account lifecycle (open/close/balance), separate from payment initiation.

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + 4-adapter + AccountPort decision (this SPEC).
- Phase B (Terminal B): scaffold 4 bank adapters + AccountPort under banxe-open-banking / banxe-baas; dedupe *-common into adapters.
- Phase C (Terminal B): implement each adapter against PartnerPort CONTRACT (SPEC #5); map each bank's external API to PartnerPort types; implement AccountPort (open/close/balance/freeze).
- Phase D (Terminal B): per-adapter shadow-mode vs legacy; PartnerPort 11-test conformance per adapter; reconcile balances to midaz-ledger.
- Phase E (Terminal B): activate adapters by config flag; partner appointments per S20 (ClearBank/Modulr) gate go-live.
- Phase F (Terminal B): tag 7 legacy projects ARCHIVE; record in IL.

## Risk register tie-in

- R-REG-04 (ACPR): each bank adapter balance reconciles to midaz-ledger; zero-mismatch gate.
- R-MIG-DEDUP-02 (*-common copies): audit clear-junction-common + contomobile-common before merging into adapters; no lost mapping.
- R-EXT-01 (S20 external blockers): adapter activation gated on real partner appointments (ClearBank, Modulr, SumSub, ContoMobile contracts).
- R-SEC-NEW-08 (bank API keys): each partner secret under /etc/banxe-<partner>/.env mode 600.

## Acceptance criteria

- 4 bank adapters (Wallester/ClearJunction/ClearBank/ContoMobile) each pass PartnerPort 11-test conformance.
- AccountPort defined + implemented (account lifecycle distinct from payment).
- *-common copies merged into adapters; no lost business rule.
- Per-adapter balance reconciliation to midaz-ledger zero-mismatch.
- PRIORITY-MAP amended with C20 (account management).
- 7 legacy projects ARCHIVE.

## References

- SPEC #5 emi-banking-services + emi-banking-partnerport-CONTRACT (the contract these adapters implement)
- NEW-PROJECT-PRIORITY-MAP-2026-06-06.md (C3/C4; to amend with C20)
- CLASS_PORT.tsv (7 bank-partner rows)
- S20 external blockers (partner appointments)
- RISK_REGISTER-2026-05-22.md (R-REG-04)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF Partner-bank adapters SPEC #13 (CLASS_PORT; NEW-driven C3/C4 + C20 AccountPort) ===
