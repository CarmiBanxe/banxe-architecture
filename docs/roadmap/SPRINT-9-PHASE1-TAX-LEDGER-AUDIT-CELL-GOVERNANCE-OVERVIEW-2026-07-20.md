> ⚠ TRAINING DATA — SANDBOX — NOT FOR PRODUCTION

# Sprint 9 — Tax, Ledger and Audit-Cell Governance Overview

**PHASE-1 ROADMAP / GOVERNANCE / FIRST MATERIALISATION / NO LEGAL STATUS**

## Purpose & role

- Sprint 9 defines how AI-assisted tax, ledger, and audit-cell activities are governed in Phase 1.
- It connects the ledger-room, tax capabilities, audit-cell views, and the Sprint-7 risk lanes into one governance map.
- It is a governance map for tax/ledger/audit, not a legal or accounting opinion; filing positions, IFRS treatment, and audit opinions remain [counsel]/auditor topics.

## Existing artefacts consumed

Sprint 9 wraps the following verified artefacts; it does not replace them.

- `docs/roadmap/S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` and `docs/audit/spec-audits/LEDGER-EMI-INSTALL-AUDIT-2026-07-20.md`.
- `docs/briefs/FLOOR2-A-CHAIN-CONTEXT-FOR-CONSULTANTS.md`.
- Ledger-room and audit-cell room kits (`agents-*.yaml` content, TaxComplianceAgent, midazagent, Beancount/Fava/Odoo/ERPNext references).
- `docs/roadmap/SPRINT-3-...` through `SPRINT-8-PHASE1-CONSENT-DPO-GDPR-GOVERNANCE-OVERVIEW-2026-07-20.md`.
- `docs/roadmap/S-GATE-REPAIR-EXECUTION-PLAN-UNIFIED-GATEWAY-AUTH-LEDGER-PAYMENTS-2026-07-20.md`.
- External-consultant brief sections on Tax (TaxComplianceAgent, CFO block, audit evidence, room placement) and Midaz/ledger (no second ledger, LedgerPort control, audit constraints).

## Tax domain and workflows

High-level governance stance only; no legal/accounting detail.

- Conceptual tax-assisted workflows: preparation packs, calculations, and reconciliations that support human tax and finance staff.
- Placement in the CFO/ledger block: GL close, IFRS treatment, AP/AR, consolidation — the tax assistance sits alongside these, not over them.
- Propose-only vs limited execution: calculation, scenario packs, and reconciliation suggestions are propose-only; any posting or adjustment is a candidate for limited execution only under explicit human sign-off.

## Audit-cell views and evidence

- Beancount/Fava and export views function as read-only audit evidence surfaces — they present ledger state for assurance, they do not mutate it.
- The audit-cell relates to the ledger-room as its evidence-placement counterpart: ledger produces the record, the audit-cell holds the assurance view.
- "Audit-first" artefacts here are documents that exist primarily for assurance (evidence packs, reconciliation views); this is a conceptual role, not a definition of any audit standard.

## Midaz/MCP to ledger governance

- **Existing canon:** no second ledger; adjustments and close actions under human sign-off; LedgerAgent gates; all ledger traffic via the LedgerPort path.
- **Open question from brief:** an explicit prohibition and a technical proof against direct MCP-to-ledger writes are still required.
- **Governance expectations:** midazagent and MCP-connected components must traverse LedgerPort + LedgerAgent gates; append-only, sign-off, and traceability constraints must hold whenever Midaz participates in a ledger flow.

## Agentic domains and risk lanes (tax/ledger/audit)

Using the Sprint-7 lane model.

- **Tax agents** (TaxComplianceAgent, regrep assistants) — Tax/reporting domain; medium lane, escalating to high-risk-by-policy where figures feed regulated submissions. Autonomy: propose-only for filed positions; L2 alert-to-human otherwise.
- **Ledger / safeguarding assistants** (midazagent, posting/reconciliation) — Ledger and safeguarding domain; high-risk-by-policy lane. Autonomy: L3 auto-up-to-gate with mandatory HITL at any posting/adjustment; full decision-trace required.
- **Audit-cell assistants** — medium lane, focused on evidence and read-only views. Autonomy: L1/L2 for view generation; no write path to the ledger.

## Ownership and accountability

- **CFO:** accountable owner of the finance/tax block and final sign-off.
- **Financial Controller / Chief Accountant:** GL close, IFRS treatment, and posting sign-off.
- **Tax Manager:** tax preparation and filed-position ownership (with [counsel] on positions).
- **Internal Audit:** read-only assurance layer over ledger and tax evidence; does not own or mutate records.
- The room migration must make ownership of each tax/ledger/audit artefact unambiguous — one accountable owner per artefact.

## Guardrails

- **Human-only tax decisions:** filed positions, IFRS choices, and any submission to an authority.
- **AI may propose, not decide:** calculations, scenario packs, reconciliation suggestions, evidence assembly.
- **Midaz/MCP constraints:** no direct writes to the ledger; no new/second ledger; no bypass of LedgerPort/LedgerAgent gates; no bypass of audit-cell read-only views.

## Relationship to future execution and migration sprints

- Feeds future S-A6/Midaz-related repair and verification sprints (e.g. proving the no-direct-write constraint technically).
- Informs tax-related install-audits and regrep documentation — the sign-off, append-only, and decision-trace expectations become audit checks.
- Interacts with factory self-repair by ensuring ledger/tax/audit changes are governed, not ad hoc — no "free" changes to posting, tax, or evidence flows.

## What this overview does not do

- Does not define tax policy or IFRS treatment.
- Does not prove audit sufficiency.
- Does not authorise autonomous tax filing or ledger mutation.
- Does not change legal or accounting positions — all such matters remain [counsel]/auditor.
