# ADR-HMR-01: HMRC FATCA/CRS Reporting — Annual Tax Information Exchange Pipeline

## Status
Accepted

## Context
UK EMI firms are obliged under FATCA (US IGA) and CRS (OECD/HMRC) to submit annual
account and payment information for reportable persons to HMRC. The submission requires
exact monetary amounts (no rounding artefacts), jurisdiction classification of each
account-holder, and deterministic reproducibility to support amendment filings.
Reportable jurisdictions must be derived from a configuration-controlled list so that
blocked jurisdictions (I-02) are automatically excluded and the list can be updated
without code changes.

## Decision
A dedicated `services/fatca_crs/` service implements the annual reporting pipeline
as four sequential stages: `collect → classify → format → submit`. All monetary amounts
are stored and processed as `Decimal` throughout the pipeline; they are serialised as
`DecimalString` in the XML output schema. Jurisdiction classification consults the
I-02 config at `services/aml/aml_thresholds.py` to exclude blocked jurisdictions.
The pipeline is idempotent per reporting year and produces a deterministic output
given the same source data, enabling amendment re-runs without manual intervention.
All pipeline execution events are written to the ClickHouse audit table (append-only).

## Consequences
Positive:
- Zero float-rounding errors in submission amounts; passes HMRC schema validation.
- Jurisdiction filter is centralised and config-driven; no code change for list updates.
- Deterministic pipeline supports amendment filings with full audit trail.
- Append-only execution log satisfies HMRC record-keeping requirements.

Negative:
- Annual operational cadence requires scheduled trigger and monitoring for submission
  confirmation receipts.
- Additional testing burden: jurisdiction edge cases and Decimal serialisation must
  be covered by negative test cases.

## Invariants
I-01: All monetary amounts in the pipeline use `Decimal`; `float` is forbidden at
every stage including intermediate calculations and XML serialisation.
I-02: Blocked jurisdictions (RU/BY/IR/KP/CU/MM/AF/VE/SY) are excluded via the
centralised jurisdiction config before classification; no reportable entry is
generated for a blocked jurisdiction account-holder.
I-24: All pipeline execution events (collect, classify, format, submit, amend) are
written to ClickHouse as append-only records; no UPDATE or DELETE is permitted.

## References
- IL: instruction-ledger/sprint-41/IL-HMR-01-hmrc-fatca-crs-reporting.md
- Code: banxe-emi-stack/services/fatca_crs/
- Code: banxe-emi-stack/services/aml/aml_thresholds.py
- Tests: banxe-emi-stack/tests/test_fatca_crs/
