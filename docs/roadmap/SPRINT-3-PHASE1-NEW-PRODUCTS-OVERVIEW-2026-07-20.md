# Sprint 3 — New Products Overview

PHASE-1 ROADMAP / PLANNING-ONLY / FIRST MATERIALISATION (2026-07-20) / NO LEGAL STATUS

## Purpose & role

Sprint 3 exists in Phase 1 as the product line: it turns “which products the bank may have” into a discipline of evidence packs and permissions mapping before any pilot or activation. It complements Sprint 1, which defines where products live in rooms and gates, and Sprint 2, which defines the consent, DPO, and AI-governance rules under which product agents act. It runs alongside the Floor-2 execution chain (`S-A5 → S-A6 → S-A7`) without replacing it: the A-chain audits installed code and control paths, while Sprint 3 describes product readiness above that layer.

## Existing artefacts

- `docs/sprints/sprint-3-product-evidence-pack-template.md` — template for per-product evidence packs, including ARO-style appendices.
- `docs/sprints/sprint-3-per-product-evidence-packs.md` — tracking and fact-only stubs for Savings, Insurance, Merchant, and Card.
- `docs/sprints/sprint-3-permissions-map-per-product.md` — non-legal wiring of products to gates and permissions labels, including the KYB perimeter note.
- `docs/briefs/SPRINT-3-NEW-PRODUCTS-OPERATOR-MEMO.md` — operator/board/counsel memo on product readiness and decision points.

This overview is the navigation layer above those artefacts: details live there; here the goal is map, perimeter, and linkage.

## Product perimeter

- Customer accounts / wallets — identity: yes (KYC entry); ledger/EMI/safeguarding: yes (core dependency); AI-governance: yes (lifecycle agents under L4-style gates).
- Cards — identity: yes; ledger: yes (transaction flow); high-risk-by-policy review: likely, especially around fraud-scoring or transaction decision support; domain remains RED until BIN/scope decisions are resolved.
- Crypto rails / on-off ramp — identity: yes; ledger: yes; AI-governance: yes (transfers at or above threshold escalate to HITL); domain remains RED pending CASP-perimeter and go-live position [counsel].
- Merchant acquiring — identity: yes (KYB gates activation); ledger: yes (settlement and operational finance linkage); AI-governance: yes (for example UBO-screening escalation to MLRO).
- Payout / treasury-facing surfaces — identity: indirect; ledger/safeguarding: yes; AI-governance: threshold-based CFO and finance-control gates may apply.

## Identity, KYB and permissions coupling

- Product treatment must read KYB together with merchant-activation and permissions logic, not in isolation; this is the accepted working orientation, while the licensing and perimeter outcome remains [counsel].
- Identity decisions sit at product entry and lifecycle points, including onboarding, activation, change-of-status, and offboarding under gated control paths.
- The internal classification frame for identity-related flows is: “non-Annex-III, treated as high-risk internally by policy”; legal characterisation remains [counsel].
- Traceability limits are explicitly recognised: `correlation_id` supports technical fault tracing, but not full regulatory decision traceability on its own, so product decisions need decision-layer fields above that technical trace.

## Dependencies on other sprints

- Sprint 1 (Operating Model) — provides the rooms and gates in which products live, including payments, customer operations, and marketing/COBS-style control edges.
- Sprint 2 (Consent / DPO / AI Governance) — provides the classification notes, oversight framing, and governance constraints that apply to product agents and product-linked AI flows.
- Sprint 4 (ICT / webhooks / DORA risk) — product events such as payment, card, or lifecycle signals depend on webhook and ICT control patterns defined there.
- Sprint 5 (Payments resilience) — rails reliability and customer-facing resilience are prerequisites for any product promise involving movement of funds.
- Floor-2 A-chain — `S-A5` provides the factual identity-install base, `S-A6` provides the ledger/EMI base, and `S-A7` provides the web-edge and gateway base where products meet the customer.

## What this overview does not do

- It does not replace detailed Sprint 3 artefacts such as evidence packs, permissions mapping, or operator memo.
- It does not create legal classification; all legal or regulatory characterisations remain [counsel].
- It does not create execution evidence; audit evidence remains in the A-chain and spec-audits.
- It does not change registers, ADRs, or roadmap master files.

## Next documentation steps

- Deep product flows remain in the per-product evidence packs and are filled before any product pilot or activation.
- The permissions map still awaits legal validation per product; resulting gap flags feed register evidence where applicable.
- The card domain depends on Sprint 1 scope-note outcomes and BIN decisions before any evidence-pack finalisation.
- Future install-audits of product modules, if created in the style of the A-chain, may be linked from this overview as the execution layer advances.
- Matching overview wrappers for Sprint 1, Sprint 2, Sprint 4, and Sprint 5 remain an operator batch decision if naming-scheme symmetry is desired across Phase 1.
