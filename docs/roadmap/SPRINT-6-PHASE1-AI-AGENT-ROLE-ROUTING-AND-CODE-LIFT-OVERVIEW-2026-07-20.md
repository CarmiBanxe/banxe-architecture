# Sprint 6 — AI Agent Role Routing and Code Lift Overview

**PHASE-1 ROADMAP / PLANNING-ONLY / FIRST MATERIALISATION / NO LEGAL STATUS**

## Purpose & role

- Sprint 6 exists to organise accumulated code and work-in-progress into the governed bank-operating-model, by role, responsibility, and agent routing.
- It is the role-routing and code-lift line of Phase 1: it says where work goes and who may touch it, not what any product does.
- It sits above the Sprint-3/4/5 overviews and above the Floor-2 execution lanes without replacing install-audits; it routes work toward those artefacts rather than producing evidence itself.

## What "code lift" means here

High-level definition only:

- Lifting accumulated basement code / drafts / fragments / sidecar logic into named governed lanes.
- Mapping each code family to the correct execution, audit, product, or control perimeter.
- Preventing unmanaged "shadow code" from remaining outside the operating model.

## Existing anchors

This overview is a navigation layer above the following verified artefacts; details live there.

- `docs/roadmap/SPRINT-3-PHASE1-NEW-PRODUCTS-OVERVIEW-2026-07-20.md` · `SPRINT-4-PHASE1-MIDAZ-WEBHOOKS-DORA-ICT-RISK-OVERVIEW-2026-07-20.md` · `SPRINT-5-PHASE1-PAYMENTS-RESILIENCE-OVERVIEW-2026-07-20.md` — Phase-1 perimeter overviews.
- `docs/roadmap/S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md` · `S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` · `S-A7-EXECUTION-PLAN-M-GATEWAY-BIF-WEB-2026-07-19.md` — Floor-2 execution plans.
- `docs/audit/spec-audits/A-IDV-INSTALL-AUDIT-2026-07-20.md` · `A-KYC-INSTALL-AUDIT-2026-07-20.md` · `A-KYB-INSTALL-AUDIT-2026-07-20.md` · `LEDGER-EMI-INSTALL-AUDIT-2026-07-20.md` · `M-GATEWAY-WEB-INSTALL-AUDIT-2026-07-20.md` — install-audit shells.
- `docs/briefs/FLOOR2-A-CHAIN-CONTEXT-FOR-CONSULTANTS.md` — Floor-2 A-chain context.
- `docs/briefs/CRO-CTO-IDV-KYB-TRACEABILITY-MEMO.md` — traceability boundaries.
- `docs/briefs/HIGH-RISK-AI-REGISTER-OPERATOR-MEMO.md` — high-risk AI register orientation.

## Role model for AI agents

High-level roles only. Each states responsibility, what it may create, what it must not do, and HITL expectation.

- **Roadmap agent** — Responsibility: perimeter/overview wrappers. May create: Phase-1 overview files. Must not: produce execution evidence, edit master ROADMAP/registers, assert legal status. HITL: no (planning artefact), but operator commit discipline applies.
- **Execution-audit agent** — Responsibility: install-audit shells and checklists over a named lane. May create: `docs/audit/spec-audits/*` install-audits with empty findings slots. Must not: populate findings as fact without operator verification, change code, assert compliance. HITL: yes for findings sign-off.
- **Product/perimeter agent** — Responsibility: product-domain notes and permissions/evidence-pack anchors (Sprint-3 line). May create: `docs/sprints/*` product artefacts. Must not: activate dormant domains, define legal classification. HITL: yes at product-launch gate.
- **Reconciliation/evidence agent** — Responsibility: binding evidence (runbooks, reconciliation runs, incident logs) back to install-audits by Finding ID. May create: runbooks / evidence packs. Must not: overwrite audit findings, hide mismatches. HITL: yes for discrepancy resolution.
- **Project-coordination agent** — Responsibility: sequencing, inventory, routing sheets across lanes. May create: routing/index artefacts. Must not: merge lanes, bypass audit-first. HITL: no for indexing; yes to authorise a lane transition.
- **Supervisor/routing agent** — Responsibility: enforce that tasks reach the correct role and control surface. May create: routing decisions/logs. Must not: grant AI agents direct ledger/gateway access outside documented control surfaces. HITL: yes for any critical-lane routing.

## Task-routing rules

- Perimeter/overview and naming-symmetry tasks → roadmap agents.
- Lane installation/wiring checks and findings scaffolds → execution-audit agents.
- Any task touching ledger, gateway, MCP/Midaz, or agent-exposed critical actions → routed through MCP/gateway/supervisor control surfaces, never direct.
- Legal / prudential / EMI / DORA / PSD2 / AI Act characterisation → human-only, [counsel]-only; never produced by an agent.
- Cross-lane tasks are split into per-lane sub-tasks (one artefact each), not merged into a single mixed document.

## Code-lift perimeter

High-level categories only, each with its landing lane.

- **Basement code fragments** → named execution plan or install-audit lane once a perimeter is assigned; unassigned fragments stay quarantined, not merged.
- **Sidecar scripts** → runbook or scripts lane under a documented owner; ad-hoc scripts without an owner go to the deprecation bucket.
- **Undocumented integration logic** → install-audit lane (gateway/ledger/identity) for wiring verification before any reuse.
- **Draft runbooks / notes / partial mappings** → sprint artefact or runbook lane; kept as drafts until an owner binds them.
- **Unbound evidence artefacts** → attached to the relevant install-audit by Finding ID / check reference; unbound evidence does not count toward readiness.
- **Duplicate or shadow implementations** → explicit deprecation bucket with a documented supersede-by pointer; never silently retained.

## Governance and guardrails

- Audit-first before execution: no code-move or execution sprint starts before the target lane has (or gains) an install-audit.
- One prompt → one artefact where possible; cross-lane work is split, not combined.
- No direct code move into a governed lane without a named perimeter and owner.
- No merging of [operator] and [counsel] items; they remain separate categories everywhere.
- No direct AI-agent access to critical ledger/gateway actions outside documented control surfaces (MCP/gateway/supervisor).

## Dependencies on current bank model

- **Sprint 3 (products):** product-family code lands against the product perimeter.
- **Sprint 4 (ICT/event control):** event/webhook and integration code routes through the ICT/DORA control perimeter.
- **Sprint 5 (payments resilience):** payment-path code binds to the resilience surfaces and reconciliation backbone.
- **S-A5 / S-A6 / S-A7 execution lanes:** identity, ledger/EMI, and gateway/web code lifts land against their respective install-audits.
- **Floor-2 A-chain consultant context:** the routing model preserves the A-chain topology and its [counsel] boundaries.

## What this overview does not do

- Does not itself migrate code.
- Does not prove operational readiness.
- Does not replace install-audits or execution evidence.
- Does not assign legal accountability — all such characterisations remain [counsel].
- Does not activate autonomous agent execution beyond current controls.

## Next documentation steps

- Identify a basement-code inventory format (family, owner, candidate lane, status).
- Map legacy fragments to governed lanes using that inventory.
- Create role passports or routing sheets where missing.
- Connect unbound evidence artefacts to the relevant install-audits by Finding ID.
- Define the deprecation path (supersede-by pointer) for shadow/duplicate code.
- Plan future execution sprints from this routing layer, audit-first.
