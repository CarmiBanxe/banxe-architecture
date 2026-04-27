# ADR-CST-01: Client Statements — Periodic Account Statement Generation

## Status
Accepted

## Context
FCA CASS 15 and PSR 2017 require EMI firms to make periodic account statements
available to clients in a durable medium. Statements must accurately reflect all
transactions in the period with exact amounts and must be immutable once issued —
a subsequent correction requires a new versioned statement, not an in-place edit.
PDF and CSV renderings must be deterministic: the same source data must always
produce byte-identical output to support regulatory audit and client dispute resolution.

## Decision
A dedicated `services/client_statements/` service generates statements via a
deterministic renderer pipeline: `query → aggregate → render → store`. All monetary
amounts are typed as `Decimal` throughout; formatted for display only at the render
stage using `Intl`-equivalent string formatting. Each issued statement is written as
an immutable version to append-only storage; subsequent corrections produce a new
version with a supersession reference to the prior version. No in-place mutation of
an issued statement is permitted. The storage schema tracks `statement_id`,
`version`, `issued_at`, `superseded_by`, and `content_hash`.

## Consequences
Positive:
- Exact monetary totals; no rounding artefacts in client-facing documents.
- Immutable versioning supports audit and dispute resolution without ambiguity.
- Deterministic renderer enables regression testing against golden outputs.
- Compatible with FCA CASS 15 durable-medium requirement.

Negative:
- Template migrations require careful version management to preserve render
  stability across statement history.
- Storage grows monotonically; archival strategy required for long-term retention.

## Invariants
I-01: All monetary amounts use `Decimal`; display formatting is applied only at the
render boundary and never fed back into calculations.
I-24: Issued statements are written as append-only versioned records; no UPDATE or
DELETE is permitted on the statement store.

## References
- IL: instruction-ledger/sprint-41/IL-CST-01-client-statements.md
- Code: banxe-emi-stack/services/client_statements/
- Tests: banxe-emi-stack/tests/test_client_statements/
