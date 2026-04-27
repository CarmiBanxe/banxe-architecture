# IL-DOC-01: ADRs for Phase 56 (Sprint 41 IL-FOS-01, IL-HMR-01, IL-CST-01, IL-LCY-01)

- Sprint: 42
- Status: PROPOSED
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: <fill after issue creation>
- Created: 2026-04-27

## Context
Sprint 41 Phase 56 delivered four significant components:
- IL-FOS-01: FOS Escalation (complaints service, FCA DISP 1.4)
- IL-HMR-01: HMRC FATCA/CRS reporting pipeline
- IL-CST-01: Client Statements generation (CAMT.053 / PDF)
- IL-LCY-01: Customer Lifecycle FSM (prospect → customer → restricted → closed)

None of these have corresponding Architecture Decision Records (ADRs). The ADR gap means
architectural choices (e.g., FSM library, FATCA schema, statement format) are undocumented
and cannot be referenced in future IL entries or compliance evidence.

## Goal
Create four ADRs in `docs/adr/` (banxe-architecture), one per Sprint 41 IL, each
documenting the key design decision, rationale, alternatives considered, and binding
invariants (I-01, I-02, I-24, I-27).

## Scope
Four new files in `banxe-architecture/docs/adr/`:
- `ADR-FOS-01-complaint-escalation-design.md`
- `ADR-HMR-01-fatca-crs-reporting-pipeline.md`
- `ADR-CST-01-client-statements-format.md`
- `ADR-LCY-01-customer-lifecycle-fsm.md`

Standard ADR format: Title | Date | Status | Context | Decision | Consequences | Alternatives considered | Invariants bound.

## Acceptance criteria
- [ ] All four ADR files created in `docs/adr/`
- [ ] Each ADR references the originating IL entry by ID (IL-FOS-01, etc.)
- [ ] Each ADR lists which invariants (I-01/I-02/I-24/I-27) apply and how they constrain the design
- [ ] Each ADR status: `Accepted` (decision already implemented in Sprint 41)
- [ ] ADR index (`docs/adr/README.md` or `index.md`) updated with all four entries
- [ ] Committed to banxe-architecture via feat branch PR (not direct to main)

## Implementation notes
- ADR-FOS-01: decision = use FastAPI + async complaint handler with L2 HITL for FOS escalation; I-27 binds (AI proposes, MLRO decides escalation)
- ADR-HMR-01: decision = pull-based HMRC submission via FATCA XML schema (FATCA2.0); I-01 binds (Decimal amounts in XML)
- ADR-CST-01: decision = generate statements as CAMT.053 XML + WeasyPrint PDF; I-24 binds (append-only audit, no retroactive edit)
- ADR-LCY-01: decision = use `django-fsm`-style explicit state machine with HITL gate at `restricted → customer`; I-27 binds
- Reference commit: `fe675b9` (Sprint 41 Phase 56 merge base)

## Risks and mitigations
- Risk: ADR becomes stale as implementation evolves → Mitigation: ADR update required on any breaking change to the documented design (IL lifecycle gate)
- Risk: ADR contradicts actual code → Mitigation: ADR references specific file paths; code review checks alignment

## Related
- IL-FOS-01, IL-HMR-01, IL-CST-01, IL-LCY-01 (Sprint 41)
- I-01 (Decimal), I-02 (jurisdictions), I-24 (audit trail), I-27 (HITL)
- `docs/adr/` directory (banxe-architecture)
- Sprint 41 merge commit `fe675b9` (banxe-emi-stack)
