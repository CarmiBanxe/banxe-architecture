# BANXE EMI — Roadmap Status & Forward Sprint Plan to 100%

**Date:** 2026-06-23 · canonical for *status*.
**Supersedes (status only):** `docs/ROADMAP-MATRIX.md` (Last Updated 2026-05-03) — that matrix
remains the **product-block registry** (Block → Sub-block taxonomy); this document is the current
**status + forward plan** reconciled against actual `main`. No product blocks are redefined here.
**Canon:** ADR-102 (anti-dup — references, does not duplicate the matrix), ADR-056 (ledger-coupled),
ADR-059/ADR-119 (append-only frozen ledger), Rule 1/6, Rule 11 (operator decides gated items).
**Baseline:** `main` IL up to IL-470.

---

## §1. Status header

The 2026-05-03 matrix is stale relative to `main`. Since then the governance/org build-out
(SPRINT-4..8), six governance canons, agent-factory Sprints 45–59, and the BANXE.RAR→EMI backend
migration all landed or closed on `main`. This doc reconciles that and publishes the forward plan to
100% implementation. **Every value not asserted on `main` is marked `AWAITS OPERATOR`** (Rule 11).

---

## §2. DONE (verified on `main`)

### 2a. Governance / org line — DONE
| Artifact | Status | Source |
|---|---|---|
| MLRO independent line | DONE | `governance/SPRINT-4-MLRO-LINE.md` |
| Internal Audit (3rd line) | DONE | `governance/SPRINT-5-INTERNAL-AUDIT-LINE.md` |
| CFO deep-build | DONE | `governance/SPRINT-6-CFO-DEEP-BUILD.md` |
| COO deep-build | DONE | `governance/SPRINT-7-COO-DEEP-BUILD.md` |
| COO resilience / AI-gov-of-ops | DONE | `governance/SPRINT-8-COO-DEEP-BUILD.md` |
| Canonical org chart v2 | DONE | `governance/CANONICAL-ORG-CHART-v2.md` |

### 2b. Governance canons — DONE (structural; binding values per §4)
MRM (`docs/governance/MODEL-RISK-MANAGEMENT.md`), DevSecOps/SSDLC (`DEVSECOPS-SSDLC.md`), KPI/DORA
four-keys D-1..D-4 (`KPI-DORA-FRAMEWORK.md`), UI/UX canon (`UI-UX-DESIGN-SYSTEM-CANON.md`),
open-banking API mgmt (`OPEN-BANKING-API-MANAGEMENT.md`), Glossary (`GLOSSARY.md`).

### 2c. Agent-factory Sprints 45–59 — IMPLEMENTED
Treasury · Risk-Oversight · Data-Quality · Deploy · Chargeback · Credit-Scoring · Contract · NPS ·
Churn · Lead-Scoring · Campaign · Incident-Response · HR · ML-Pipeline.

### 2d. Backend migration — CLOSED
`docs/migration/MIG-INDEX-final-state-register.md` (CLOSED), `MIG-coverage-acceptance.md` (ACCEPTED);
genuine-gaps abs-info-field / login-history / SRP DONE in banxe-emi-stack (IL-412 / IL-413 / IL-414);
7 mis-scaffolds avoided (ADR-102 discipline).

### 2e. Partial % (from `docs/ROADMAP-MATRIX.md`; drive to 100% in §3)
| Block | Sub | Now | Target |
|---|---|---|---|
| F | aml | ~80% | 100% |
| I | security | ~80% | 100% |
| I | infra | ~70% | 100% |
| L | lake | ~30% | 100% |
| D | gl | ~5% | 100% |

> Percentages = matrix's last estimates; exact current % **AWAITS OPERATOR** re-baseline.

---

## §3. Forward Sprint Plan to 100%

> Each sprint runs the §5 canon: audit → ONE artifact, ADR-102 anti-dup (completion-over-existing),
> ledger-coupled (one IL shard), isolated worktree (Rule 1), guardian-green, no bypass. Codes
> reference `docs/ROADMAP-MATRIX.md`.

| Sprint | P | Scope (sub-blocks) | Dependency | Best-solution note |
|---|---|---|---|---|
| **S-PROD-1** | **P0** | Safeguarding Engine — J-engine (IL-SAF-01 prompt-ready), J-audit, E-safeguard | CASS 15 / PS10-15; Midaz | **⚠ OVERDUE — deadline 2026-05-07 passed.** Highest priority; daily-recon + shortfall auto-FCA (immutable, no-suppress) |
| **S-PROD-2** | **P0** | FCA Regulatory Reporting — F-finrpt, K-gabriel (Gabriel/RegData) | Q2 2026; safeguarding figs | submission boundary = CFO personally (HITL-010); agents draft-only |
| **S-PROD-3** | **P1** | Core Banking — D-gl→100% (Midaz), D-recon, D-fee, D-fin | Midaz CBS (ADR-013) | D-gl ~5% = largest core gap; via LedgerPort/I-28 (no direct HTTP) |
| **S-PROD-4** | **P1** | Onboarding — A-kyc, A-idv, A-kyb | **HOLD — KYC gated I-27 HITL-L4** | A-kyc/kyb advisory-only until I-27; non-KYC A-idv parts may proceed |
| **S-PROD-5** | **P1** | Payment Rails — C-fps, C-sepa, C-swift | ClearBank/Modulr (S4) | behind PaymentRouter; ≥£50k → L2 COO/CFO (HITL-016) |
| **S-PROD-6** | **P1** | Product Catalogue + Capital — B-emi, B-pricing, E-capital (ICARA) | EMI permissions | ICARA capital prudential; binding figures AWAITS OPERATOR |
| **S-PROD-7** | **P1** | Fraud + SAR — G-rt, G-device, K-nca | velocity/Redis; MLRO | SAR→NCA via MLRO (HITL); thresholds config-as-data |
| **S-PROD-8** | **P2** | API / Developer Platform — I-api, M-gateway, M-sdk, M-sandbox | open-banking canon | builds on OPEN-BANKING-API-MANAGEMENT.md; needs M2.8 roster |
| **S-PROD-9** | **P2/P3** | Ops / Data — E-treasury, H-crm, H-support, L-bi, F-fatca | data-lake (L-lake 30%) | L-bi/L-lake→100%; F-fatca CRS |
| **S-MIG-M2.8** | **gated** | Roster-C frontend migration | **AFTER operator A/B/C + owners** | banxe-ui / banxe-platform / split (§4); namespace-collision + Next-unify |
| **S-GOV-CLOSE** | **governance** | close residual AWAITS-OPERATOR (§4) | operator inputs | SAST-tool, DORA reporting workflow, binding MRM-tiers, DORA bands, ADR-117 Q6 |

---

## §4. AWAITS-OPERATOR register (Rule 11 — operator decides; nothing selected here)

| Item | Options (operator selects) | Source |
|---|---|---|
| M2.8 web unify | canonical=`web-next` (proposed) / alt | `docs/migration/AWAITS-OPERATOR-3-web-next-unify.md` |
| M2.8 Roster-C | A `banxe-ui` / B `banxe-platform` / C split + owners | `docs/migration/MIG-M2.8-AWAITS-OPERATOR-decision-brief.md` |
| ADR-117 Q6 | dev-composition decision | ADR-117 |
| DevSecOps SAST tool | tool selection (GAP) | `docs/governance/DEVSECOPS-SSDLC.md` |
| DORA reporting workflow | reporting/automation workflow | `docs/governance/KPI-DORA-FRAMEWORK.md` |
| Binding MRM tiers | per-model T1/T2/T3 criticality + thresholds | `docs/governance/MODEL-RISK-MANAGEMENT.md` (§4/§8) |
| DORA numeric bands | D-1..D-4 target bands | `docs/governance/KPI-DORA-FRAMEWORK.md` (§5) |
| KYC/KYB/AML start | I-27 HITL-L4 sign-off | CLAUDE.md (I-27) |

> All rows **AWAITS OPERATOR**. This doc selects none (Rule 11; binding values stay un-asserted).

---

## §5. Canon of execution (every forward sprint)

1. **Audit-first → ONE artifact.** Read-only ADR-102 preflight (duplication audit) before any
   scaffold; classify covered / partial / genuine-gap; emit exactly one next-action artifact.
2. **Completion-over-existing.** Extend/reference existing surfaces; never duplicate (migration's 7
   mis-scaffolds-avoided is the precedent).
3. **Ledger-coupled, append-only.** One IL shard per sprint; `build_ledger --check` green; I-28 /
   ADR-057 / ADR-059 / ADR-119 frozen numbering (no renumber, no re-mint).
4. **No bypass.** No `--admin` / `--auto` / `--no-verify` / protection circumvention; guardian
   checks (factory/project/ledger/append-only) green before merge.
5. **Gated stays gated.** KYC/KYB/AML (I-27), M2.8 roster, binding MRM/DORA values — operator
   decides (Rule 11); agents prepare materials only.
6. **Isolated worktree (Rule 1) + parallel-session isolation (Rule 6).**

---

### Refs
`docs/ROADMAP-MATRIX.md` (superseded for status; product registry retained); `governance/SPRINT-4..8`;
`governance/CANONICAL-ORG-CHART-v2.md`; `docs/governance/{MODEL-RISK-MANAGEMENT,DEVSECOPS-SSDLC,
KPI-DORA-FRAMEWORK,UI-UX-DESIGN-SYSTEM-CANON,OPEN-BANKING-API-MANAGEMENT,GLOSSARY}.md`;
`docs/migration/{MIG-INDEX-final-state-register,MIG-coverage-acceptance,AWAITS-OPERATOR-3-web-next-unify,
MIG-M2.8-AWAITS-OPERATOR-decision-brief}.md`; agent-factory Sprints 45–59; IL-412/413/414;
ADR-102, ADR-056, ADR-013, ADR-117, ADR-119; I-27, I-28; CASS 15 / FCA PS10-15.
