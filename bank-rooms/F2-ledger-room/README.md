# F2/ledger-room

## Purpose / coverage
GL/double-entry ядро, reconciliation, statements, fees, period-close swarm, MCP-доступ к ledger; tax/RegData-контур (Sprint 5).

## Key agents/services
`LedgerAgent` (services/ledger/, Midaz), `ReconciliationAgent`, `TaxComplianceAgent` (accounting-swarm/Odoo), `RegDataAgent`, `FIN060Generator` (services/reporting/fin060_generator.py), `BeancountExportAgent` (audit-feed, dual F4/audit-cell), `midaz_agent` (services/midaz_mcp/ — watch: все записи через LedgerPort).

## Regulatory Status Notes
- Register areas: **#1 Tax (AMBER)** · **#6 midaz MCP→ledger (AMBER)**.
- Canonical source: `../../docs/governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`.
- Freeze: "Room status must not appear more GREEN than the worst register entry that affects it." · "No GREEN without evidence artefact linked in the register."
- Инварианты комнаты: append-only ledger (ADR-056/057, I-24) · Decimal-only деньги (I-01) · no second ledger (ADR-102) · adj>£10k → CFO.

### Sprint 5 (Tax / RegData)
Artefacts: `../../docs/sprints/sprint-5-tax-agent-autonomy-adr-draft.md` (L2 propose-only, human-submit — ратификация pending) · `../../docs/sprints/sprint-5-regdata-cycle-runbook.md` (FIN060→CFO dry-run; **no automated submission, CFO-only** per H-010). #1 AMBER→GREEN — только после ADR-ратификации + counsel-ответа, с evidence-ссылками в register.
