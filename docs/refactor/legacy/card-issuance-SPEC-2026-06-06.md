# Refactor SPEC #15 — Card issuance group (CardPort + Paymentology)

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_MERGE; NEW-driven; surfaces C22 card issuance)
Scope: 2 legacy card projects -> CardPort + Paymentology adapter (banxe-emi-stack)
Source: BANXE.RAR; CLASS_MERGE.tsv (banxe-cards, banxe-multi-card-api)
NEW capability: C22 (card issuance) — surfaced by CLASS_MERGE NEW-driven sweep; mandatory for EMI card product
Related: SPEC #5 EMI Banking; PartnerPort (Paymentology as card partner); S20 external blockers (Paymentology appointment)
Owner: Terminal B (smart refactor)

## Purpose

NEW-driven sweep of CLASS_MERGE surfaced C22 (card issuance), mandatory for the EMI card product but absent from C1-C21. Legacy banxe-cards + banxe-multi-card-api -> one CardPort backed by Paymentology (card issuing processor). Mine card-lifecycle business logic (issue/activate/freeze/limits); drop legacy card runtime.

## Legacy inventory + decision

- banxe-cards -> primary card-lifecycle source; mine issue/activate/block/limits logic.
- banxe-multi-card-api -> multi-card-per-user logic; dedupe into CardPort.
- Both MERGE into one CardPort behind banxe-emi-stack; Paymentology as the issuing processor adapter.

## CardPort contract (new, high-level)

issueCard(userId, type, currency) -> CardRef; activate(cardRef); freeze/unfreeze(cardRef); setLimits(cardRef, limits); getCard(cardRef); handleAuthorization(webhook) -> approve/decline. Idempotent on clientCardId; audited to guardian_audit_events; PII redacted (PAN never stored, tokenised via Paymentology).

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + CardPort decision (this SPEC).
- Phase B-C (Terminal B): CardPort + PaymentologyAdapter; merge banxe-cards + multi-card-api lifecycle logic.
- Phase D (Terminal B): conformance tests; PCI-DSS scope review (PAN tokenisation; never store PAN).
- Phase E-F (Terminal B): cut over; Paymentology appointment (S20) gates go-live; ARCHIVE 2 legacy; IL record.

## Risk register tie-in

- R-SEC-PCI-01 (PAN handling): PAN never stored; tokenised via Paymentology; PCI-DSS scope minimised.
- R-EXT-02 (Paymentology appointment, S20): card go-live gated on processor contract.
- R-COMP-FCA-06 (card auth audit): every authorization decision audited for MLRO.

## Acceptance criteria

- CardPort defined; PaymentologyAdapter passes conformance; PAN never persisted.
- banxe-cards + multi-card-api merged into CardPort; no lost card rule.
- PRIORITY-MAP amended with C22.
- 2 legacy card projects ARCHIVE.

## References

- SPEC #5 emi-banking-services + PartnerPort CONTRACT; NEW-PROJECT-PRIORITY-MAP (to amend C22)
- CLASS_MERGE.tsv (2 card rows); S20 external blockers (Paymentology)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF Card issuance SPEC #15 (CLASS_MERGE; NEW-driven C22) ===
