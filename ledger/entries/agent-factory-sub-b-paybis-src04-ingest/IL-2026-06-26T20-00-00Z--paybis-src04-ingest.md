---
il_ts: 2026-06-26T20:00:00Z
session_id: agent-factory-sub-b-paybis-src04-ingest
source: CEO
status: DONE
---
### PAYBIS SRC-04 agreement ingested — contractual layer НЕИЗВЕСТНО → FACT (commercial/settlement) (docs-plane)

- **Objective:** Ingest the operator-provided BANXE↔PAYBIS agreement (Corporate-On_Off-Ramp_BANXE-LTD-rev.-1.docx, excerpt §8/§9.3/General) into the dossier: update SRC-01 placeholder → real intake, reflect into DOSSIER Section 3, flip SRC-04 BLOCKED→PRESENT in the intake register. Docs-plane only; no invented terms.
- **Live audit:** banxe-architecture origin/main@9ef6c49; branch agent/factory/paybis/neuronext-retirement-adr (ADR-126 IL-545, DOSSIER IL-546, SRC-01 IL-547, REGISTER IL-548). Provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates). Full .docx not on disk → only operator-provided excerpt ingested; fields beyond excerpt kept НЕИЗВЕСТНО.
- **FACT ingested (literal, traceable to agreement):** §8 Payment — Paybis disburses Partner Fees; monthly (or as agreed) invoice notice incl. tax; non-EU Partner invoice without certain references; all taxes Partner's responsibility; remit within 30 days of an invoice undisputed by Paybis to wallet address OR bank account; Paybis not obligated to pay beyond Partner Fees. §9.3 Shortfall Fee — Paybis sole discretion: (1) invoice payable within 14 days, or (2) set-off/deduct from accrued Partner Fees/commissions (relevant/subsequent period). General — notice emails (invoice@/finance@/support@banxe.com; users@/legal@paybis.com); Annex 1 (and future) integral; Agreement prevails over Commercial Offer; Paybis disclaims warranties, no warranty Services fully secure/uninterrupted/error-free. Party identities Partner=BANXE LTD, counterparty=Paybis.
- **INFERENCE flagged (not literal):** dual payout rails (wallet+bank); 30-day undisputed-invoice dispute/recon window; fee netting (shortfall set-off); warranty-disclaimer → runtime resilience + independent reconciliation; Annex 1 binding fee-config + Agreement>Commercial-Offer conflict rule; configurable billing cadence.
- **Still НЕИЗВЕСТНО (outside excerpt — not invented):** approved domains/URLs/subdomains/ICT/environments/use-cases; prior-written-approval change procedure; security/incident/remediation/audit clauses; sublicensing/white-label scope; full API surface/rate-limits/data-residency; exact Paybis legal entity. Owners: operator/legal (full .docx) + Paybis (API). → SRC-05/06/07/08 remain BLOCKED; dossier §3b НЕИЗВЕСТНО.
- **Files updated:** SRC-01 (placeholder→INGESTED), DOSSIER §3 (3a FACT / 3b НЕИЗВЕСТНО / 3c INFERENCE), SRC-INTAKE-REGISTER (SRC-04 BLOCKED→PRESENT + update note).
- **Perimeter / canon:** docs-plane only; no runtime/code/secrets; no cross-repo write; no invented contractual facts; one excerpt per concept; isolated worktree off arch origin/main; signed; sub-B hands to MAIN per §71/§74.
- **Refs:** Corporate-On_Off-Ramp_BANXE-LTD-rev.-1.docx (§8/§9.3/General, operator excerpt); ADR-108/114/126; SRC-01/DOSSIER/REGISTER (IL-547/546/548); ADR-119/I-28.
