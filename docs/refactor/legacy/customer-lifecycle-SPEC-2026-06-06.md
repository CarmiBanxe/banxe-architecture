# Refactor SPEC #16 — Customer lifecycle group (C23 customer data)

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_MERGE; NEW-driven; surfaces C23 customer lifecycle)
Scope: 4 legacy reference-data projects -> banxe-customer-lifecycle service
Source: BANXE.RAR; CLASS_MERGE.tsv (banxe-accounts, banxe-contacts, banxe-dictionary, banxe-addresses)
NEW capability: C23 (customer lifecycle / reference data) — surfaced by CLASS_MERGE NEW-driven sweep
Related: SPEC #5 EMI Banking; SPEC #8 KYC (customer identity link); ADR-021 PII routing
Owner: Terminal B (smart refactor)

## Purpose

NEW-driven: C23 (customer lifecycle + reference data) consolidates 4 fragmented legacy services (accounts, contacts, dictionary, addresses) into one banxe-customer-lifecycle service holding the canonical customer record. Mandatory for EMI (single customer view for KYC, SAR/GDPR, AML). PII routing per ADR-021.

## Legacy inventory + decision (4 -> 1 service)

- banxe-accounts -> customer account records (link to midaz-ledger account ids).
- banxe-contacts -> contact details (email/phone, GDPR-relevant PII).
- banxe-dictionary -> reference data (countries, currencies, enums).
- banxe-addresses -> address records (KYC proof-of-address relevant).
- All MERGE into banxe-customer-lifecycle; single canonical customer record; PII fields routed per ADR-021.

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + consolidation decision (this SPEC).
- Phase B-C (Terminal B): banxe-customer-lifecycle service; merge 4 schemas; canonical customer aggregate; PII routing.
- Phase D (Terminal B): SAR/GDPR export endpoint (R-PRIV-02); reference-data caching.
- Phase E-F (Terminal B): cut callers; ARCHIVE 4 legacy; IL record.

## Risk register tie-in

- R-PRIV-01/02 (GDPR/SAR): single customer record enables compliant SAR export + redaction.
- R-REG-04 (ACPR): customer-to-ledger-account mapping must be authoritative.
- R-MIG-DEDUP-03: audit 4 schemas for overlapping fields before merge.

## Acceptance criteria

- banxe-customer-lifecycle holds canonical customer record; 4 legacy schemas merged; no lost field.
- SAR/GDPR export endpoint works; PII routed per ADR-021.
- PRIORITY-MAP amended with C23.
- 4 legacy projects ARCHIVE.

## References

- SPEC #5 + SPEC #8; ADR-021 PII routing; NEW-PROJECT-PRIORITY-MAP (to amend C23)
- CLASS_MERGE.tsv (4 reference-data rows); RISK_REGISTER R-PRIV-01/02
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF Customer lifecycle SPEC #16 (CLASS_MERGE; NEW-driven C23) ===
