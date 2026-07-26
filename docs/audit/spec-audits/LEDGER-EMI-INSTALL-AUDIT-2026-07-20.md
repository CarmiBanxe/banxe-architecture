> ⚠ TRAINING DATA — SANDBOX — NOT FOR PRODUCTION

# LEDGER / EMI Install Audit — 2026-07-20

**FLOOR-2 / S-A6 / EXECUTION-LINE / INSTALL-AUDIT / NO LEGAL STATUS**

## Scope & perimeter

**IN scope**
- Core ledger (general ledger / EMI book) ports and services handling balances and safeguarding movements.
- `LedgerPort` surfaces where external systems (including MCP / Midaz-controlled agents and gateway flows) attach to the ledger.
- Links between product flows (Sprint-3), payment legs (Sprint-5), and ledger postings.
- Error-reconciliation hooks where ledger outcomes are reconciled against expected balances.
- Safeguarding-related posting paths (customer vs house accounts) at a technical level.

**OUT of scope**
- Detailed prudential / safeguarding legal classification (Annex-III, EMI, PSD2/PSD3) — [counsel].
- Identity internals (S-A5 lane, covered by A-IDV/A-KYC/A-KYB install-audits).
- Gateway/web internals (S-A7 lane, covered by the M-GATEWAY-WEB install-audit).
- Product perimeter definitions (Sprint-3 overview).
- Consent / AI-governance decisions (Sprint-2 line).
- Any code or configuration change (read-only audit).

## Evidence anchors

- `docs/roadmap/S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` — parent execution plan; defines the ledger/EMI/BIF lanes and the M2.5-BIF verdict line.
- `docs/roadmap/ERROR-RECONCILIATION-ROADMAP-2026-07-01.md` — reconciliation backbone for ledger completion and safeguarding checks.
- `docs/audit/spec-audits/M-GATEWAY-WEB-INSTALL-AUDIT-2026-07-20.md` — upstream gateway/web behaviour feeding ledger entry points.
- `docs/audit/spec-audits/A-IDV-INSTALL-AUDIT-2026-07-20.md` · `A-KYC-INSTALL-AUDIT-2026-07-20.md` · `A-KYB-INSTALL-AUDIT-2026-07-20.md` — upstream identity evidence for customer/merchant accounts.
- `docs/roadmap/SPRINT-3-PHASE1-NEW-PRODUCTS-OVERVIEW-2026-07-20.md` · `SPRINT-5-PHASE1-PAYMENTS-RESILIENCE-OVERVIEW-2026-07-20.md` — product and payments-resilience perimeter whose ledger evidence this audit supports.
- `docs/roadmap/SPRINT-4-PHASE1-MIDAZ-WEBHOOKS-DORA-ICT-RISK-OVERVIEW-2026-07-20.md` and the Sprint-4 webhook/ICT/DORA materials — where ICT incidents impact ledger reliability.
- `docs/briefs/CRO-CTO-IDV-KYB-TRACEABILITY-MEMO.md` — decision-trace vs fault-trace distinction applied to ledger traceability checks.

This install-audit produces concrete checks and findings over the surfaces defined by those anchors; it does not restate their content.

## Installation checklist

Checks only; findings left to operators. Each phrased as an audit check.

**Ledger surfaces**
- Verify that ledger ports exposed to application code (including via `LedgerPort`) match the expected map in the S-A6 plan; record additions/absences.
- Verify that all customer-balance movements go through the EMI/ledger layer and are not bypassed via shadow balances or off-ledger tracking.
- Verify that safeguarding segregation (customer vs house accounts) is reflected in technical posting rules and configuration.

**Integration points (gateway, MCP, Midaz)**
- Verify that gateway-originated flows (S-A7) enter the ledger only via documented ports and services; any direct web→ledger bypass is a finding.
- Verify that MCP/Midaz-controlled AI agents reach ledger-related actions only through the gateway/MCP control surfaces (no direct DB/API access), and that policy enforcement is in place at those surfaces.
- Verify that correlation_id and decision-layer fields propagate into ledger logs for decision-carrying flows (e.g. credit decisions, high-risk transactions).

**Reconciliation and error handling**
- Verify that ledger postings feed into the error-reconciliation pipeline described in `ERROR-RECONCILIATION-ROADMAP-2026-07-01.md`, and that incomplete/mismatched postings surface there.
- Verify that double-posting / missing-posting scenarios are detectable via reconciliation and not silently hidden.

**Safeguarding and Annex-III-sensitive flows**
- Verify that EMI/safeguarding-sensitive flows (customer funds vs own funds) have distinct technical paths and controls; record where this is documented.
- Verify that high-risk-by-policy flows (non-Annex-III, treated as high-risk internally by policy [counsel]) are traceable end-to-end from identity through ledger.

**Logging and traceability**
- Verify that ledger operations have sufficient logging to support technical fault tracing (IDs, amounts, timestamps, correlation_id).
- Verify where decision-layer fields are present or absent; record expected gaps explicitly rather than silently.

**Incident and HITL wiring**
- Verify that ledger-impacting failures (posting rejection, ledger outage, data corruption) map to defined incident/escalation paths.
- Verify that HITL gates exist for critical ledger changes exposed to AI agents, and that failures halt at the gate rather than auto-continue.

## Findings slots

Findings are recorded by operators using this template; none are populated here.

| Field | Content |
|---|---|
| **Finding ID** | `LED-F-NN` (sequential) |
| **Check reference** | Checklist item the finding arises from |
| **Observation** | Factual description (quoted where possible) |
| **Evidence location** | File/path (and line refs) where verifiable |
| **Impact classification** | Technical / operational only; [counsel] classification left blank |
| **Status** | open / mitigated / accepted risk |

## Relationship to overviews and resilience

- **Sprint-3 (products):** supports the per-product ledger touchpoints — each product's balance and posting legs land on the surfaces checked here.
- **Sprint-5 (payments resilience):** supports the overview by establishing the ledger as the settlement/safeguarding leg of payment flows; the reconciliation and safeguarding checks answer its ledger-dependency surfaces.
- **Sprint-4 (ICT/webhooks/DORA):** relates through ICT incidents that affect ledger reliability (posting backlog, event-driven mis-postings); ledger-impacting incident classes bind back to the Sprint-4 perimeter.
- Resilience and compliance are NOT proven by this document alone; it establishes installation and wiring facts that later evidence (runbooks, incident logs, reconciliation runs, simulations) must attach to by Finding ID or check reference.

## What this audit does not do

- Does not assert Annex-III, EMI, PSD2/PSD3, DORA, or other legal compliance — all such characterisations remain [counsel].
- Does not change ADRs, registers, passports, or roadmap master files.
- Does not redefine product perimeter or consent/AI-governance decisions.
- Does not overwrite or reinterpret [counsel] positions; [operator] checks and [counsel] questions remain separate categories throughout.
