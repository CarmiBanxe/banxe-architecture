# ADR-GOV-01: FCA SMCR Compliance Framework

## Status
Accepted

## Context
S1 (Governance & SMF) was at 40%. FCA SMCR (Senior Managers & Certification
Regime) requires all authorized EMI firms to:
- Register Senior Management Function (SMF) holders with the FCA
- Maintain Statements of Responsibilities for each SMF
- Annually certify relevant staff (Certification Regime)
- Enforce Individual and Senior Manager Conduct Rules
- Report conduct rule breaches to the FCA

Without a programmatic framework, SMCR compliance relies on manual spreadsheets
and email reminders — creating regulatory risk.

## Decision
An `SMCRFramework` in `services/compliance_automation/` provides:

1. **SMF Role Registry**: Register SMF holders (SMF1 CEO, SMF16 Compliance,
   SMF17 MLRO, etc.) with FCA Individual Reference Numbers and Statements
   of Responsibilities.
2. **Certification Regime**: Track certified persons with annual expiry dates.
   `check_certifications()` returns alerts for expired/due certifications.
3. **Conduct Rules**: 9 FCA Conduct Rules defined as data (5 Individual Tier 1 +
   4 Senior Manager Tier 2).
4. **Breach Reporting**: MINOR breaches filed internally. MAJOR/CRITICAL breaches
   trigger `BreachHITLProposal` for COMPLIANCE_OFFICER review and potential
   FCA notification (I-27).
5. **FCA Export**: `export_fca_reporting_data()` produces structured data ready
   for FCA RegData submission.
6. **SMCRRegistryPort**: Protocol DI for data persistence. InMemory for tests.

## Consequences
Positive:
- S1 coverage moves from 40% to ~50%.
- Certification expiry tracking prevents regulatory breaches.
- Breach HITL ensures FCA notification obligations are met.
- RegData export reduces manual FCA reporting effort.

Negative:
- No FCA Gabriel API integration yet — export is data-only.
- Responsibility map is static — no automated SoR document generation.
- No integration with HR/people systems for staff changes.

## References
- IL-GOV-01 (Sprint 45), PR: CarmiBanxe/banxe-emi-stack#34
- FCA SMCR, FCA SUP 10C (Senior Managers), COCON (Conduct Rules)
- I-24, I-27
