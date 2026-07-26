# M-GATEWAY-WEB Install Audit — 2026-07-20

**FLOOR-2 / S-A7 / EXECUTION-LINE / INSTALL-AUDIT / NO LEGAL STATUS**

## Scope & perimeter

M-GATEWAY-WEB perimeter for this audit:

- Gateway entry/exit points for payments — where payment instructions enter the gateway layer and where they leave toward the ledger/rails side.
- Web-facing edges relevant to payment initiation and routing — the API surface through which clients trigger payment-related actions.
- Relation upward: this perimeter carries the Sprint-5 payments-resilience surfaces (initiation/routing continuity, provider fallback, controlled stop) and the Sprint-4 webhook/ICT themes (retry, DLQ, incident paths) at the point where they face the world.
- Topology note (per S-A7 plan): M-GATEWAY is a productisation wrapper; the runtime gateway (routing/authZ/rate-limit) is owned by I-API — the audit inspects **both** layers under "no second gateway".

**IN scope:** gateway/web routing configuration; integration seams to identity, ledger, and error-reconciliation components; external-provider dependency points and their fallback wiring; gateway-level logging/correlation coverage; retry/replay/DLQ behaviour of gateway-related flows; incident/HITL escalation wiring for gateway failures.

**OUT of scope:** ledger internals (S-A6 lane); identity module internals (S-A5, done); product perimeter definitions (Sprint-3 line); consent/AI-governance decisions (Sprint-2 line); any legal/prudential classification — [counsel]; code or configuration changes of any kind.

## Evidence anchors

- `docs/roadmap/S-A7-EXECUTION-PLAN-M-GATEWAY-BIF-WEB-2026-07-19.md` — parent execution plan; defines the gate (after S-A6), the two-layer gateway topology, and the BIF fact-check line.
- `docs/roadmap/SPRINT-5-PHASE1-PAYMENTS-RESILIENCE-OVERVIEW-2026-07-20.md` — resilience perimeter whose gateway/web evidence this audit is expected to produce.
- `docs/sprints/sprint-4-webhook-event-lifecycle.md` · `docs/sprints/sprint-4-dora-ict-risk-framework.md` — event lifecycle and ICT risk themes the gateway checks must map to.
- `docs/audit/spec-audits/A-IDV-INSTALL-AUDIT-2026-07-20.md` · `A-KYC-INSTALL-AUDIT-2026-07-20.md` · `A-KYB-INSTALL-AUDIT-2026-07-20.md` — upstream identity evidence; gateway endpoints depending on identity outcomes are checked against these.
- `docs/roadmap/ERROR-RECONCILIATION-ROADMAP-2026-07-01.md` — reconciliation backbone for gateway-flow completion checks.
- `docs/briefs/CRO-CTO-IDV-KYB-TRACEABILITY-MEMO.md` — decision-trace vs fault-trace distinction applied in the traceability checks below.

This install-audit produces concrete checks and findings over the perimeter defined by those anchors; it does not restate their content.

## Installation checklist

**Routing configuration**
- Verify that the actual router inventory (web-facing payment endpoints) matches the expected surface in the S-A7 plan; record additions and absences.
- Verify that every payment-relevant endpoint carries an authentication dependency resolved through the IAM/identity chain, with no unauthenticated payment path.
- Verify which layer (I-API runtime vs M-GATEWAY wrapper) actually carries routing/authZ/rate-limit, and record the I-API carrier verdict ("carrier found" or "GAP confirmed"; both are valid outcomes).

**Integration points**
- Verify that endpoints gated by identity outcomes reference the identity components documented in the A-IDV/A-KYC/A-KYB install-audits, not parallel implementations.
- Verify that all ledger-touching flows pass web → gateway layer → ledger port, and that no direct web→ledger bypass exists; any bypass is a finding.
- Verify that gateway-flow outcomes feed the error-reconciliation path so that incomplete flows surface in reconciliation rather than disappearing.

**External providers and fallback**
- Verify that each external-provider dependency reachable from the gateway layer has a defined behaviour on provider unavailability (documented fallback or documented stop), and record where that behaviour is defined.
- Verify that provider credentials/config are environment-supplied, with no secrets in gateway code or config files.

**Logging and traceability**
- Verify correlation_id coverage across gateway-level request handling: present at entry, propagated downstream, present in error responses.
- Verify per hit whether decision-layer fields (agent_id, action_taken, human_reviewed_by) exist above correlation_id for decision-carrying flows; record fault-trace-only coverage as an expected gap class, not silently.

**Replay / retry / DLQ**
- Verify that gateway-related asynchronous flows use the bounded retry and DLQ behaviour documented in the Sprint-4 webhook lifecycle materials, and that retry is bounded (no infinite retry).
- Verify duplicate-prevention/idempotency handling at the gateway edge for create/submit payment operations.

**Incident and HITL wiring**
- Verify that gateway failure classes map to a defined incident/escalation path, and record which HITL gates (by class) apply to gateway-exposed decision flows.
- Verify that HITL-gated flows exposed through the gateway halt at the gate on failure rather than continuing autonomously.

## Findings slots

Findings are recorded by operators using this template; none are populated here.

| Field | Content |
|---|---|
| **Finding ID** | `MGW-F-NN` (sequential) |
| **Check reference** | Checklist item the finding arises from |
| **Observation** | What was actually observed (factual, quoted where possible) |
| **Evidence location** | File/path (and line refs) where the observation is verifiable |
| **Impact classification** | Technical / operational only; [counsel] classification left blank |
| **Status** | open / mitigated / accepted risk |

## Relationship to Sprint-5 payments resilience

- This install-audit is the gateway/web evidence producer for the Sprint-5 overview: the initiation/routing (continuity), provider-fallback, and controlled-stop surfaces listed there are answered — positively or negatively — by the checks above.
- Resilience is not proven by this document alone: a completed checklist establishes installation and wiring facts, not behaviour under real failure.
- Further evidence — runbooks, incident logs, failure simulations — must bind back to both the Sprint-5 overview and this install-audit (by Finding ID or check reference) to count toward the resilience picture.

## What this audit does not do

- Does not assert legal, EMI, DORA, PSD2, or AI Act compliance — all such characterisations remain [counsel].
- Does not change ADRs, registers, passports, or roadmap master files.
- Does not redefine product perimeter or consent/AI-governance decisions.
- Does not overwrite or reinterpret [counsel] positions; [operator] checks and [counsel] questions remain separate categories throughout.
