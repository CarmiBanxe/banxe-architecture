# Governance — Project Documentation (Layer 2)

Status: CONTENT (D3.3.6 — full sub-domain content landed; D3.3.X programme 8/8 COMPLETE)
Sprint: D3.3.6 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12,
IL-PROJECT-DOCS-SPRINT-D3-3-1-ARCHITECTURE-CONTENT-2026-05-12 (Layer-2 peer),
IL-PROJECT-DOCS-SPRINT-D3-3-2-API-CONTENT-2026-05-12 (Layer-2 peer),
IL-PROJECT-DOCS-SPRINT-D3-3-3-RUNBOOKS-CONTENT-2026-05-12 (Layer-2 peer),
IL-PROJECT-DOCS-SPRINT-D3-3-4-DATA-CONTENT-2026-05-12 (Layer-2 peer),
IL-PROJECT-DOCS-SPRINT-D3-3-5-OPERATIONS-CONTENT-2026-05-12 (Layer-2 peer),
IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12,
IL-CANON-F01-REINFORCE-ALWAYS-ONE-ACTIONABLE-2026-05-12,
ADR-019 (AI Guardian two-family), ADR-025 (agent interaction canon),
ADR-027 (audit-trail durability — Board / MLRO audit-chain sink),
HITL-MATRIX.yaml (READ-ONLY canonical reference — 17 gates),
HITL §0.2 Levels 1–5, SMF1 / SMF3 / SMF16 / SMF17 / SMF24 (FCA SUP 10A),
Certification Regime (FCA SUP 10C), PSR 2017 + EMR 2011 (FCA EMI),
Sprint S18, S18.2, S20, S20.8, S20.9, S20.10, S24, S24.4, S25, S25.4

---

## Scope

In-scope topics for this domain:

- SMR (Senior Managers Regime) mapping — SMF1–SMF17 holders, allocation of
  Prescribed Responsibilities, Statements of Responsibilities (SoR).
- Board composition, board calendar, board pack template.
- MLRO governance — appointment, escalation, decision-record retention.
- DPO governance — appointment, communication channel with ICO.
- Internal Audit charter, plan, finding-tracker.
- Change-control policy — Architecture Review Board (ARB), exception handling.
- Quarterly review cadence (Sprint S25.4 anchor).
- Sign-off ledger (final cross-functional sign-off pre-go-live).

## Out of scope

- Compliance attestations and regulatory dossiers (lives under `../compliance/`).
- HITL gate POLICY mechanics (lives under `../operations/` / `HITL-MATRIX.yaml`).
- Source code (lives in `banxe-emi-stack/`).
- Factory-side governance (Layer 1; lives in `docs/canon/` for operator canon).
- Day-to-day on-call rotation (lives under `../operations/`).

## Definition of Done

Verbatim from [`../PROJECT-DOCUMENTATION-MASTER-INDEX.md`](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
§3:

A deliverable is DONE when **all four** of the following are true:

1. Document exists at a stable canonical path under `docs/project/` or a domain folder.
2. Document has named owner, version, and last-reviewed date in its header.
3. Document has been reviewed by the relevant track-lead and reflects current
   production reality (no stale architectural references, no removed services, no
   unmerged ADRs).
4. Document is reachable from this index in two hops or fewer
   (index → backlog → doc, or index → domain table → doc).

## Current artifacts

Real files (enumerated via `git ls-files` / `find docs/`):

- `docs/governance/branch-protection.md` — branch-protection policy (existing).
- `INSTRUCTION-LEDGER.md` (repo root) — instruction ledger (governance anchors;
  referenced only, not edited here).
- `MASTER-PLAN-2026-05-05.md` (repo root) — master plan (governance anchor;
  referenced only).
- `ROADMAP.md` (repo root) — factory roadmap (anchored from governance; not edited).
- `docs/canon/HW-MODEL-UPGRADE-matrix.md` — HW matrix (governance-controlled
  inventory; factory).
- `HITL-MATRIX.yaml` (repo root) — HITL gate matrix (READ-ONLY canonical
  reference, 17 gates).

---

## A. Governance overview

### A.1 FCA EMI authorization regime

- **PSR 2017** (Payment Services Regulations 2017, transposing PSD2) +
  **EMR 2011** (Electronic Money Regulations 2011, transposing EMD2)
  govern the BANXE EMI authorization perimeter.
- FCA EMI submission planned for **Sprint S24** (BLOCKED on Sprint S20
  completion — see §B and §H).
- Cross-link `../compliance/README.md` §A.1 for the regulatory mapping
  (authorization regime, SUP 15 notification, CASS 15, SYSC 4.1).

### A.2 Current state

- **SMF holders NOT appointed** — Sprint S20 dependency (see §B).
- **Interim governance** during the pre-S20 window:
  - Central terminal + human double per §0.2 **Level 2** (operator-dubler
    model recorded in `PRIVILEGE-MODEL.md`).
  - Operator co-sign on every prod-impacting HITL gate (cross-link
    `../operations/README.md` §B.3).
  - Compliance / safeguarding / KYC procedures stay HITL-gated with no
    EMERGENCY-only path (per `../operations/README.md` §B.4 + §F.4).

### A.3 Sprint dependencies

| Sprint   | Governance deliverable                                       | Status                                         |
|----------|--------------------------------------------------------------|------------------------------------------------|
| S18      | §0.2 Level 4-5 deployment (CEO dashboard + AI MLRO)          | DESIGN PENDING (Architecture WG approval)      |
| S18.2    | CEO governance dashboard on banxe-platform Next.js 15        | DESIGN PENDING                                 |
| S20      | SMF holders appointment (SMF1, SMF3, SMF16, SMF17, SMF24)    | OPEN (all five TODO)                           |
| S20.8    | MLRO appointment (Sprint S20.8 — see §B.4)                   | OPEN (candidate per IL — not appointed)        |
| S20.9    | Board formation (NEDs incl. independents)                    | OPEN                                           |
| S20.10   | Internal Audit appointment (outsourced minimum)              | OPEN                                           |
| S24      | FCA EMI submission                                           | BLOCKED on Sprint S20 completion               |
| S24.4    | MLRO annual report                                           | TODO — depends on S20.8                        |
| S25      | Go-live                                                      | TODO — depends on S24                          |
| S25.4    | Quarterly MLRO + CEO + Board review                          | TODO — cadence locked, first review at S25.4   |

---

## B. Senior Managers & Certification Regime

### B.1 SMF holders — TODO appointment

Required senior-manager functions per **FCA SUP 10A**:

- **SMF1 — CEO** — TODO appointment (Sprint **S20.9** Board formation).
- **SMF3 — Executive Director** — TODO appointment.
- **SMF16 — Compliance Oversight** — TODO appointment; interim coverage
  via HITL gate co-sign per the matrix.
- **SMF17 — MLRO (Money Laundering Reporting Officer)** — TODO
  appointment (Sprint **S20.8**). Candidate referenced in IL roadmap
  entries: **Sarah Mitchell** (UK interim MLRO) — **candidate only, not
  appointed**; final selection requires Board sign-off.
- **SMF24 — Chief Operations** — TODO appointment.

### B.2 Statements of Responsibility (SoR)

- Required for every SMF holder per FCA SUP 10A.
- Statements of Responsibility encode the Prescribed Responsibilities
  allocated to each holder.
- Target document: `docs/project/governance/smf-mapping.md` (MISSING;
  owner sprint **S20**).

### B.3 Certification Regime (non-SMF certified persons)

- **FCA SUP 10C** Certification Regime — annual fitness-and-propriety
  certification for specified non-SMF roles.
- TODO — enumerate certified-person roles for BANXE EMI scope; owner
  sprint **S20** (alongside SMF appointment).

### B.4 MLRO appointment specifics

- **SMF17 MLRO** — non-delegable for SAR filing per HITL-MATRIX gate
  **HITL-001** (cross-link `../operations/README.md` §B.2).
- Interim: HITL gate co-sign by Central + operator; MLRO function exercised
  via the matrix until S20.8 appointment lands.
- Audit chain: every MLRO decision → IL fixation → ClickHouse Guardian
  per [decisions/ADR-027-audit-trail-durability.md](../../decisions/ADR-027-audit-trail-durability.md)
  (5-year retention, CASS 15 §15.10 compliance).

### B.5 Certification cadence

- Annual fitness-and-propriety certification per FCA SUP 10C.
- Target document: `docs/project/governance/certification-regime.md`
  (TODO — D3.4+ candidate).

---

## C. Board of Directors

### C.1 Board formation — Sprint S20.9

- Board formation is **OPEN** under Sprint **S20.9** (Board formation
  pending operator and FCA SMF allocation).
- **Composition target**: 5+ NEDs including 2 independent directors
  (FCA EMI guidance; TODO — confirm exact FCA-EMI guidance citation in
  D3.4+).
- Cross-reference: §0.2 **Level 4-5** (CEO dashboard + AI MLRO) is
  Board-overseen.

### C.2 Quarterly meetings

- Cadence: **Sprint S25.4** quarterly review (MLRO + CEO + Board cadence,
  cross-link `../operations/README.md` §G.4).
- First quarterly review window: post-go-live (after S25 go-live close).
- Inputs to each quarterly review:
  - Compliance metrics — `../compliance/README.md` §G sprint-mapping
    summary.
  - Operations SLIs — `../operations/README.md` §G (customer-impact +
    internal SLIs).
  - Audit-trail durability evidence — ClickHouse Guardian 5y under
    ADR-027.

### C.3 Board pack template

- TODO — draft Board pack template covering: compliance attestation,
  operations metrics, incident dossier, sign-off ledger updates, action
  items.
- Target document: `docs/project/governance/board-pack-template.md`
  (TODO — D3.4+ candidate; owner sprint **S20.9 / S25.4**).

---

## D. Internal Audit

### D.1 Appointment

- **Sprint S20.10** — outsourced Internal Audit appointment is the
  minimum. Full in-house IA function is deferred.
- IA function reports to **Board + MLRO**.
- Audit trail: copies of IA reports flow into ClickHouse Guardian per
  ADR-027 (append-only, 5-year retention).

### D.2 Annual IA plan

- **TODO** — annual IA plan covering control testing, compliance review,
  IT general controls, third-party risk.
- Target document: `docs/project/governance/internal-audit-plan.md`
  (MISSING; owner sprint **S20.10 / S22**).

### D.3 Finding tracker

- Findings tracked with status (Open / In Progress / Closed) and remediation
  owner.
- Audit-trail emission: every finding state change → ClickHouse Guardian
  per ADR-027.

---

## E. AI MLRO autonomous (§0.2 Level 5)

### E.1 §0.2 Level 5 deployment

- **Sprint S18** — Level 5 deployment of the AI MLRO function. Design
  is **PENDING Architecture WG approval**.
- Hybrid pattern **Option B**: AI MLRO primary + human MLRO co-sign.
  Final design (Option A vs B vs C) gated on Architecture WG decision.

### E.2 HITL audit chain for AI MLRO

Every AI MLRO decision MUST flow through the four-step audit chain:

1. **AI MLRO decision** — produced by the AI Guardian agent under
   [decisions/ADR-019-ai-guardian-two-family.md](../../decisions/ADR-019-ai-guardian-two-family.md)
   architectural enforcement.
2. **Human MLRO co-sign** — the human SMF17 holder reviews and counter-signs
   (no auto-execute on SAR / STR class decisions per HITL-MATRIX
   HITL-001).
3. **IL fixation** — every decision pair (AI + human co-sign) is recorded
   via IL pairing per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12.
4. **Board review** — quarterly aggregate review at Sprint **S25.4**
   cadence (sample-based control testing + drift assessment).

### E.3 Governing ADRs

- [decisions/ADR-019-ai-guardian-two-family.md](../../decisions/ADR-019-ai-guardian-two-family.md)
  — AI Guardian two-family compliance enforcement architecture.
- [decisions/ADR-025-agent-interaction-canon.md](../../decisions/ADR-025-agent-interaction-canon.md)
  — Agent interaction canon (architectural-side; operator-terminal-side
  canon lives in `docs/canon/` Layer 1, out of scope here).
- [decisions/ADR-027-audit-trail-durability.md](../../decisions/ADR-027-audit-trail-durability.md)
  — Audit-trail durability (ClickHouse Guardian 5y); the audit chain
  above writes every decision into this store.

### E.4 Pre-deployment HITL gates

- AI MLRO primary deployment requires:
  - Architecture WG approval (Sprint S18 design close).
  - MLRO holder appointment (Sprint S20.8 close).
  - Board sign-off (Sprint S20.9 Board formation + S25.4 quarterly
    review activation).
- All three are **OPEN** as of D3.3.6 baseline; AI MLRO autonomous
  function stays HITL-gated until all three close.

---

## F. §0.2 Level 4 CEO dashboard

### F.1 Sprint S18.2 — CEO governance dashboard

- **Sprint S18.2** — CEO governance dashboard hosted on `banxe-platform`
  (Next.js 15). Design is **PENDING** (Architecture WG approval +
  CEO requirements gathering).

### F.2 Dashboard components (proposed)

| Component                      | Source                                                              |
|--------------------------------|---------------------------------------------------------------------|
| HITL counter                   | ClickHouse Guardian (ADR-027) — HITL audit events                   |
| SMF holder status              | `docs/project/governance/smf-mapping.md` (MISSING; S20)             |
| FCA deadlines                  | Compliance calendar (cross-link `../compliance/README.md` §A.1)     |
| Operator queue                 | HITL-MATRIX.yaml live state + outstanding co-sign requests          |
| Incident dossier               | `docs/incidents/` index (top-3 latest)                              |

### F.3 Access model

- **Read-only** access for: CEO (SMF1), SMF16 Compliance Oversight,
  full Board.
- **Write-protected** per
  [decisions/ADR-019-ai-guardian-two-family.md](../../decisions/ADR-019-ai-guardian-two-family.md)
  invariants — no human-side mutation of the dashboard state; all state
  derives from the canonical audit + governance data sources.

### F.4 Target spec

- Target document: `docs/project/governance/ceo-dashboard-spec.md`
  (MISSING; owner sprint **S18.2**).

---

## G. Quarterly review cadence

### G.1 Sprint S25.4

- Cadence: every quarter post-go-live.
- Attendees: **MLRO + CEO + Board** (mandatory); Compliance Oversight,
  DPO, Internal Audit (advisory).

### G.2 Inputs

- **Compliance metrics** — sprint-mapping summary from
  `../compliance/README.md` §G; SAR / STR submission rate; sanctions
  match adjudication backlog.
- **Operations SLIs** — from `../operations/README.md` §G (customer-impact
  + internal SLIs).
- **Audit trail** — ClickHouse Guardian sample-based review per ADR-027
  (5-year retention).
- **Incident dossier** — any incidents since the last quarterly review
  (cross-link `docs/incidents/`).
- **EMERGENCY override retrospectives** — every EMERGENCY override
  executed since last review (per `../operations/README.md` §B.4).

### G.3 Outputs

- **Board minutes** — recorded, distributed to all attendees, archived.
- **MLRO annual report** — Sprint **S24.4** consolidated report.
- **Regulatory action items** — tracked into the next quarter's sprint
  backlog.

---

## H. Open gaps for D3.4+

Governance MISSING target files queued for creation in later sprints.

- `docs/project/governance/smf-appointment-register.md` — SMF holder
  appointment register (owner sprint **S20**).
- `docs/project/governance/board-charter.md` — Board charter (owner
  sprint **S20.9**).
- `docs/project/governance/internal-audit-plan.md` — annual IA plan
  (owner sprint **S20.10 / S22**).
- `docs/project/governance/ai-mlro-design.md` — §0.2 Level 5 AI MLRO
  design (owner sprint **S18**; PENDING Architecture WG).
- `docs/project/governance/ceo-dashboard-spec.md` — §0.2 Level 4 CEO
  dashboard spec (owner sprint **S18.2**).
- `docs/project/governance/quarterly-review-template.md` — quarterly
  review template (owner sprint **S25.4**).
- `docs/project/governance/regulatory-reporting-register.md` —
  regulatory-reporting register (FCA SUP / CASS / SAR / GDPR Art. 33
  filings) (owner sprint **S24**).
- `docs/project/governance/certification-regime.md` — Certification
  Regime non-SMF roles (TODO — D3.4+ candidate).
- `docs/project/governance/board-pack-template.md` — Board pack template
  (TODO — D3.4+ candidate; owner sprint **S20.9 / S25.4**).

### Carried-forward (not governance-specific but visible here)

- **20 UNKNOWN-status ADRs** — `**Status:**` backfill queued per
  IL-PROJECT-DOCS-SPRINT-D3-2D-3-ADR-INDEX-UNIFIED-2026-05-12.
- **§0.2 Level 4-5 deployment** — Sprint **S18** design pending
  Architecture WG approval.
- **All SMF holders OPEN** — Sprint S20.8 / S20.9 / S20.10.
- **FCA submission Sprint S24 BLOCKED** on Sprint S20 completion.
- **G-FACTORY-05 OPEN** until S13.8 (cross-link
  `../operations/README.md` §A.1).
- **G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION** OPEN — retroactive
  72h decision pending MLRO / DPO / Legal (cross-link
  `../compliance/README.md` §A.2).

### D3.3.X programme milestone

This commit **closes the D3.3.X domain expansion programme** —
**8/8 Layer-2 domain READMEs are now CONTENT**:

1. compliance (D3.2b — 401 lines)
2. security (D3.2b — 376 lines)
3. architecture (D3.3.1 — 402 lines)
4. api (D3.3.2 — 396 lines)
5. runbooks (D3.3.3 — 451 lines)
6. data (D3.3.4 — 441 lines)
7. operations (D3.3.5 — 435 lines)
8. **governance (D3.3.6 — this commit)**

---

## MISSING / TODO

| Target path                                                              | Title                                                | Anchor                                                  | Owner sprint |
|--------------------------------------------------------------------------|------------------------------------------------------|---------------------------------------------------------|--------------|
| `docs/project/governance/smf-mapping.md`                                 | SMF1–SMF17 mapping + Statements of Responsibility    | Sprint S20 SMR                                           | S20          |
| `docs/project/governance/smf-appointment-register.md`                    | SMF holder appointment register                      | Sprint S20 SMR                                           | S20          |
| `docs/project/governance/board-formation.md`                             | Board composition + calendar + pack template         | Sprint S20.9 Board formation                             | S20.9        |
| `docs/project/governance/board-charter.md`                               | Board charter                                        | Sprint S20.9                                             | S20.9        |
| `docs/project/governance/board-pack-template.md`                         | Board pack template                                  | Sprint S20.9 / S25.4                                     | S20.9 / S25.4 |
| `docs/project/governance/mlro-governance.md`                             | MLRO governance (appointment + escalation)           | Sprint S20.8 MLRO                                        | S20.8        |
| `docs/project/governance/dpo-governance.md`                              | DPO governance (appointment + ICO channel)           | Sprint S21 GDPR DPO anchor                               | S21          |
| `docs/project/governance/internal-audit-charter.md`                      | Internal Audit charter + plan + finding tracker      | Sprint S22 IA charter                                    | S22          |
| `docs/project/governance/internal-audit-plan.md`                         | Annual Internal Audit plan                           | Sprint S20.10 / S22                                      | S20.10 / S22 |
| `docs/project/governance/change-control-policy.md`                       | Change-control policy + ARB                          | Sprint S20 ARB / change-control                          | S20          |
| `docs/project/governance/quarterly-review-cadence.md`                    | Quarterly review cadence                             | Sprint S25.4 quarterly review                            | S25.4        |
| `docs/project/governance/quarterly-review-template.md`                   | Quarterly review template                            | Sprint S25.4                                             | S25.4        |
| `docs/project/governance/ai-mlro-design.md`                              | §0.2 Level 5 AI MLRO design                          | Sprint S18 (PENDING Architecture WG)                     | S18          |
| `docs/project/governance/ceo-dashboard-spec.md`                          | §0.2 Level 4 CEO dashboard spec                      | Sprint S18.2                                             | S18.2        |
| `docs/project/governance/regulatory-reporting-register.md`               | Regulatory-reporting register                        | Sprint S24                                               | S24          |
| `docs/project/governance/certification-regime.md`                        | Certification Regime non-SMF roles (FCA SUP 10C)     | Sprint S20 alongside SMF appointment                     | S20          |
| `docs/project/governance/signoff-ledger.md`                              | Cross-functional sign-off ledger (pre-go-live)       | Backlog S25 sign-off ledger                              | S25          |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md (unified)](../../adr/INDEX.md)
- → [HITL-MATRIX.yaml](../../../HITL-MATRIX.yaml) (READ-ONLY reference, 17 gates)
- ↔ Sibling domains:
  [architecture](../architecture/README.md) ·
  [api](../api/README.md) ·
  [runbooks](../runbooks/README.md) ·
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [data](../data/README.md) ·
  [operations](../operations/README.md)
