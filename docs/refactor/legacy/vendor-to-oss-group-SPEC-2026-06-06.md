# Refactor SPEC #9 — Vendor-to-OpenSource migration group

Date: 2026-06-06
Status: SPEC (design baseline; first CLASS_TRANSFORM SPEC; NEW-driven per priority-map)
Scope: 14 TRANSFORM-VENDOR-TO-OS legacy projects -> Midaz + Hyperswitch + FastAPI (OSS)
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/ on evo1; CLASS_TRANSFORM.tsv
NEW capability: C3 (fiat rails) + C4 (BaaS) + C14 (ledger via Midaz) per NEW-PROJECT-PRIORITY-MAP
Related: ADR-017 vendor-to-os; ADR-013 Midaz; SPEC #5 EMI Banking; ~$650k/year vendor cost saving (first-session audit)
Owner: Terminal B (smart refactor)

## Purpose

First SPEC of the CLASS_TRANSFORM category. NEW-driven: C3/C4 (EMI fiat core) + C14 (ledger) authoritatively require replacing three expensive proprietary vendors (Temenos core, Tribe payments, crypto-processing PHP) with OSS (Midaz, Hyperswitch, FastAPI). Legacy vendor code is reused ONLY for its business logic (chart of accounts, routing rules), never the vendor runtime. Estimated saving ~$650k/year (Temenos + Tribe licences).

## Legacy inventory (3 vendor groups, 14 projects)

### Group A — Temenos core -> Midaz (4 projects)
- banxe/temenos_r19.12, banxe/temenos_r20, banxe/temenos_r19-apis (+ apis variant)
- Vendor: Temenos R19/R20 (proprietary banking core, multi-million licence)
- Reuse: chart of accounts, GL mapping, party model (business config, NOT vendor runtime)
- Target: Midaz (Lerian OS) — already running on evo1 (PR #303)
- Serves: C14 (ledger) + C4 (BaaS account model)

### Group B — Tribe payments -> Hyperswitch (3 projects)
- banxe/tribe, banxe/banxe-tribe, banxe/banxe-fiat-backend/banxe-tribe-otp
- Vendor: Tribe (proprietary payment processor)
- Reuse: routing rules, retry logic, business rules (config, NOT vendor runtime)
- Target: Hyperswitch (Apache 2.0)
- Serves: C3 (fiat payment rails)

### Group C — crypto-processing PHP -> Hyperswitch + FastAPI (8 projects)
- crypto-processing/{system,admin-front,payments,gateway,my-account,backend,schemas,merchant}
- Vendor: in-house PHP processing stack (legacy, unmaintainable)
- Reuse: payment flows, merchant model (rewrite, NOT keep PHP)
- Target: Hyperswitch routing + FastAPI services
- Serves: C3 (crypto payment processing)

## Decision (NEW-driven)

| Group | Decision | Keep from legacy | Drop |
|---|---|---|---|
| A Temenos | TRANSFORM-CONFIG | chart of accounts, GL mapping, party model | entire Temenos runtime + licence |
| B Tribe | TRANSFORM-RULES | routing rules, retry logic, business rules | Tribe runtime + licence |
| C crypto-processing | REWRITE | payment flows, merchant data model | all PHP code (rewrite FastAPI) |

Canon: NEW C3/C4/C14 need fiat+ledger capability; the vendors are dropped because OSS (Midaz/Hyperswitch) serves the same NEW need at ~$650k/year less. Legacy is mined for business config only.

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + 3-group decision (this SPEC).
- Phase B (Terminal B): extract business config from each vendor group (chart of accounts, routing rules, merchant model) into NEW config artefacts; no vendor runtime copied.
- Phase C (Terminal B): map Temenos GL -> Midaz accounts; map Tribe routing -> Hyperswitch rules; rewrite crypto-processing flows as FastAPI behind PartnerPort (SPEC #5 CONTRACT).
- Phase D (Terminal B): shadow-mode run OSS vs vendor for one reconciliation cycle; zero-mismatch on GL balances + payment routing outcomes.
- Phase E (Terminal B): cut over to Midaz + Hyperswitch + FastAPI; decommission Temenos + Tribe licences (saving realised).
- Phase F (Terminal B): tag 14 legacy vendor projects ARCHIVE; record decommission + licence termination in IL.

## Risk register tie-in

- R-MIG-VENDOR-02 (vendor cut-over): Strangler Fig + shadow-mode per Phase D; never flip Temenos/Tribe off until OSS green for one full recon cycle.
- R-REG-04 (ACPR capital adequacy): Midaz GL must reproduce Temenos chart-of-accounts exactly; zero-mismatch gate before cut-over.
- R-MIG-LICENSE-02 (crypto-processing PHP): audit PHP for undocumented business logic before rewrite; do not lose merchant-specific rules.
- R-COST-01 (saving realisation): ~$650k/year saving only realised at Phase E licence termination, not at Phase A.

## Acceptance criteria

- Business config extracted from all 3 groups; NO vendor runtime in NEW dependency tree.
- Temenos GL mapped to Midaz with zero-mismatch on a full chart-of-accounts reconciliation.
- Tribe routing rules expressed as Hyperswitch config; contract tests pass.
- crypto-processing rewritten as FastAPI behind PartnerPort; conformance suite (SPEC #5 CONTRACT) passes.
- Phase D shadow-mode: 0 mismatch on GL + routing for one recon cycle.
- 14 legacy vendor projects ARCHIVE; Temenos + Tribe licences terminated; saving recorded in IL.

## References

- ADR-017 vendor-to-OpenSource policy; ADR-013 Midaz
- NEW-PROJECT-PRIORITY-MAP-2026-06-06.md (C3 + C4 + C14)
- CLASS_TRANSFORM.tsv (14 TRANSFORM-VENDOR-TO-OS rows)
- SPEC #5 emi-banking-services + PartnerPort CONTRACT (crypto-processing rewrite target)
- RISK_REGISTER-2026-05-22.md (R-REG-04 ACPR; vendor cost saving)
- midaz-ledger (PR #303, running on evo1)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF Vendor-to-OSS SPEC #9 (first CLASS_TRANSFORM SPEC; NEW-driven C3/C4/C14) ===
