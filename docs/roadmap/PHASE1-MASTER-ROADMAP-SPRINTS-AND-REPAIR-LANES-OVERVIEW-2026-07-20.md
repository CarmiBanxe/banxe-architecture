# Phase-1 Master Roadmap — Sprints and Repair Lanes Overview

**PHASE-1 ROADMAP / MASTER OVERVIEW / FIRST MATERIALISATION / NO LEGAL STATUS**

## Purpose & audiences

- This document is the Phase-1 master map of sprints and repair lanes — how the individual overviews and execution plans fit together.
- It serves two audiences: external consultants (high-level picture, where input is most useful) and the factory (permitted self-repair and verification lanes).
- It is descriptive, not a compliance opinion; all legal/regulatory status remains [counsel].

## Sprint map (3–9 + S-GATE-REPAIR + A-chain)

| Sprint / Plan | Domain | Type | Status | Primary risk lane | Notes for consultants | Notes for factory |
|---|---|---|---|---|---|---|
| SPRINT-3 | Products | overview | planned-only | medium (high where KYB gates acquiring) | Product perimeter and launch questions | May inventory product code against perimeter; no domain activation |
| SPRINT-4 | ICT / webhooks / DORA | overview | planned-only | medium→high on ledger/payment impact | Event/ICT/incident perimeter | May expand webhook install-audit checks |
| SPRINT-5 | Payments resilience | overview | planned-only | high-risk-by-policy | Continuity/fallback/reconciliation surfaces | May bind reconciliation evidence to audits |
| SPRINT-6 | Agent roles / routing / code-lift | overview | ready-for-execution | mixed by lane | How work is routed into governed lanes | May run code-lift/inventory within this perimeter |
| SPRINT-7 | AI governance / domains / risk lanes | overview | planned-only | defines all lanes | The risk-lane and autonomy model | Must operate within these autonomy limits |
| SPRINT-8 | Consent / DPO / GDPR | overview | planned-only | high-risk-by-policy | Consent front boundary; DPO interim | No free changes to consent flows |
| SPRINT-9 | Tax / ledger / audit-cell | overview | planned-only | high-risk-by-policy (ledger) | Tax/ledger/audit governance stance | May run Midaz/ledger verification sprints |
| S-GATE-REPAIR | Gateway/auth perimeter | repair-plan | ready-for-execution | high-risk-by-policy | Unified perimeter for ledger/payments | Anchors the top-severity repair backlog |
| S-A5 (identity) | Identity lane | execution-plan + audits | execution-ongoing (audits done) | high-risk-by-policy | Identity execution spine | Findings slots await operator population |
| S-A6 (ledger/EMI) | Ledger lane | execution-plan + audit | execution-ongoing (audit shell) | high-risk-by-policy | Ledger execution spine | Verification sprints permitted (no direct writes) |
| S-A7 (gateway/web) | Gateway lane | execution-plan + audit | execution-ongoing (audit shell) | high-risk-by-policy | Gateway execution spine | Feeds S-GATE-REPAIR |

## Floor-2 A-chain summary

- S-A5 (identity) → S-A6 (ledger/EMI) → S-A7 (gateway/web), each with an execution plan and an install-audit (A-IDV/A-KYC/A-KYB done; LEDGER-EMI and M-GATEWAY-WEB as audit shells), form the execution spine of Phase-1.
- S-GATE-REPAIR attaches to the S-A7 end of the spine (unified gateway/auth perimeter) and reaches back to S-A5/S-A6 for identity and ledger integration.
- Sprint 7–9 attach as governance layers over the spine: Sprint 7 sets the risk lanes, Sprint 8 the consent front boundary (S-A5 side), Sprint 9 the tax/ledger/audit governance (S-A6 side).
- Likely future verification/repair sprints: Midaz-to-ledger no-direct-write proof (S-A6), external-gate proof and coverage expansion (S-A7 / S-GATE-REPAIR), decision-trace coverage across high-risk lanes.

## Closed vs open blocks

"Closed" means governance-planned and mapped — not compliant, not finished.

**Closed (planned and governance-mapped)**
- Identity and onboarding (IDV/KYC/KYB, consent/DPO).
- Products perimeter (Sprint 3).
- ICT/webhooks/DORA perimeter (Sprint 4).
- Payments resilience (Sprint 5).
- Agent roles and routing (Sprint 6).
- AI governance domains and risk lanes (Sprint 7).
- Tax/ledger/audit-cell governance (Sprint 9).
- Gateway/auth perimeter repair plan (S-GATE-REPAIR).

**Open (design and evidence still to come)**
- Cards and card-adjacent products.
- Crypto/MiCA and on/off-ramp specifics.
- Extended merchant/tax products.
- Webhook provider controls and Register-of-Information.
- Further DORA/PSD2/EMI evidence and the regrep/reporting line.

## Factory self-repair lanes

- **Factory may run autonomously (within existing controls):**
  - Verification sprints proving stated constraints (e.g. no MCP→ledger direct writes, gateway coverage).
  - Install-audit expansions (adding/exercising checks, populating findings for operator review).
  - Code-lift / inventory sprints within the Sprint-6 / S-A8 perimeter.
- **Design-only, under the project brain:**
  - New product domains.
  - Changes to governance or risk lanes (Sprint 7).
  - New repair plans of the S-GATE-REPAIR class.

## Consultant-facing notes

- **How to read this map:** each sprint covers one domain (see the table); overviews set perimeter and questions, execution/repair plans and install-audits carry facts and checks.
- **Where input is most valuable next cycle:** the Open blocks — cards, crypto/MiCA, extended products, webhook provider controls, and further DORA/PSD2/EMI evidence.
- **Audit-first and HITL already embedded:** every lane is audit-first (no execution before an install-audit), high-risk lanes require HITL and decision-trace, and [operator]/[counsel] responsibilities stay separate throughout.

## Next-cycle roadmap hints

Hints, not commitments:

- Cards and card-risk line.
- Crypto/MiCA and treasury/rails.
- Regrep and reporting.
- Extended DORA/PSD2 evidence.
- Further factory self-repair around code and evidence.

## What this master overview does not do

- Does not change any sprint content.
- Does not prove compliance or readiness.
- Does not commit to specific next-cycle dates or scopes.
- Does not create or alter legal positions — all such matters remain [counsel].
