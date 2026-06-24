# E-Capital — Capital Adequacy Reporting Build-Spec (FCA ICARA)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-24 · **Block:** E-capital · **Priority:** P1 · **Deadline:** Q3 2026
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119. Additive; mutates no prior artifact.

> E-capital implements the **FCA ICARA process** (Internal Capital Adequacy and Risk Assessment) for
> the EMI. It **derives** own-funds composition and capital-adequacy calculations **from D-fin financial
> statements and D-gl GL balances**, generates the ICARA document and capital-adequacy returns, and
> routes regulatory submissions via the **K-gabriel submission pattern** (referenced, not duplicated).
> **Capital adequacy is distinct from safeguarded client funds** — E-safeguard (CASS 15) manages
> segregated client money; E-capital manages the firm's **own** regulatory capital.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/architecture/D-FIN-BUILD-SPEC.md` (IL-485) | Financial reporting core — P&L, balance sheet, own-funds figures derivation from GL | **keep / reference** — E-capital **consumes** D-fin's `FinancialStatementSet` for own-funds composition; does NOT reimplement financial reporting |
| `docs/architecture/D-GL-BUILD-SPEC.md` (IL-484) | General Ledger — `LedgerPort`, journal entries, balances | **keep / reference** — E-capital **reads** GL balances via D-fin; does NOT post to GL |
| `docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md` (IL-474) | Safeguarding — segregated client funds (CASS 15) | **keep / fence** — capital ≠ safeguarded funds; E-capital is the firm's own regulatory capital; E-safeguard is client money segregation — distinct regimes |
| `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` (IL-472) | Safeguarding engine — CASS 15 orchestration | **keep / fence** — safeguarding context; E-capital does not interact with safeguarding engine |
| `docs/regulatory/K-GABRIEL-BUILD-SPEC.md` (IL-480) | FCA Gabriel/RegData submission pattern — `GabrielSubmissionPort`, deadline tracking, HITL sign-off | **keep / reuse pattern** — E-capital reuses the submission/audit pattern for ICARA return submission; does NOT reimplement the submission platform |
| `docs/regulatory/F-FINRPT-BUILD-SPEC.md` (IL-481) | FIN-RPT regulatory returns content core | **keep / reference** — sibling regulatory return; E-capital is a separate return type (ICARA vs FIN-REP) |
| ROADMAP E-capital row | Capital adequacy 0% P1 Q3 2026 | **update** — status → Spec-Locked / In Progress |
No existing `E-CAPITAL-BUILD-SPEC` on main → new file non-duplicative.

## 1. Boundary (E-capital vs E-safeguard vs D-fin vs D-gl) — drift reconciled

| Concern | Owner | This spec |
|---|---|---|
| **ICARA process + own-funds calc + capital-adequacy return** | **E-capital** | **builds** |
| Financial statements (P&L, balance sheet, own-funds figures) | **D-fin** | **consumes** (read-only) |
| General Ledger (journal entries, balances) | **D-gl** | **consumes via D-fin** (no direct GL posting) |
| Segregated **client** funds (CASS 15 safeguarding) | **E-safeguard** | **distinct regime** — capital ≠ client money |
| Safeguarding engine (CASS 15 orchestration, breach reporting) | **J-engine** | out of scope — no interaction |
| FCA regulatory submission platform | **K-gabriel** | **reuses pattern** (submission/audit/HITL) |
| FIN-REP regulatory returns content | **F-finrpt** | sibling return type — no overlap |

**Key distinction:** E-capital manages the firm's **own regulatory capital** (CET1, Tier 1, Tier 2, K-factors, fixed-overheads requirement). E-safeguard manages **client money** held in segregated accounts under CASS 15. These are separate regulatory regimes with separate calculations, thresholds, and reporting obligations.

## 2. Scope — FCA ICARA (Internal Capital Adequacy and Risk Assessment)

### 2.1 Own-funds composition
- **CET1 (Common Equity Tier 1):** share capital + retained earnings + other reserves, less intangible assets, deferred tax assets, and regulatory deductions.
- **Additional Tier 1 (AT1):** qualifying AT1 instruments (if any; typically nil for startup EMI).
- **Tier 2 (T2):** qualifying T2 instruments + general provisions (if applicable; typically nil for startup EMI).
- **Total own funds:** CET1 + AT1 + T2.
- **Derivation:** own-funds figures **consumed from D-fin** `FinancialStatementSet` (balance sheet equity components, retained earnings from P&L close). D-fin reads D-gl; E-capital does not access GL directly.
- All amounts: **Decimal only** (I-01, no float). Currency: GBP.

### 2.2 Capital requirements (IFPR / MIFIDPRU as applicable)
EMI capital requirements under FCA rules (MIFIDPRU for investment-firm-like obligations, or EMI-specific own-funds requirements under EMD2/PSR):

| Requirement | Calculation | Source |
|---|---|---|
| **Permanent minimum requirement (PMR)** | Fixed amount per FCA EMI authorisation (currently £350,000 for EMIs) | FCA EMD2 / PSR |
| **Fixed overheads requirement (FOR)** | 25% of prior-year fixed overheads (from D-fin P&L) | MIFIDPRU 4.4 / EMI rules |
| **Own-funds threshold requirement (OFTR)** | Higher of PMR and FOR | MIFIDPRU 4.3 |
| **K-factor requirement (KFR)** | Sum of applicable K-factors (K-CMH, K-ASA, K-COH, etc.) — most K-factors nil for pure EMI; K-CMH (client money held) may apply if relevant | MIFIDPRU 4.6–4.14 |
| **Overall own-funds requirement** | Higher of OFTR and KFR (if applicable) | MIFIDPRU 4.3 |

- **K-factor applicability:** for a pure EMI, most K-factors (K-AUM, K-CMH, K-ASA, K-COH, K-DTF, K-NPR, K-CMG, K-TCD, K-CON) are nil or not applicable. K-CMH (client money held) may be relevant — config-as-data flag per K-factor.
- **Fixed overheads:** derived from D-fin P&L (prior-year audited figures or latest management accounts); adjustable items per MIFIDPRU 4.4.3R.

### 2.3 Wind-down planning & trigger analysis
- **Wind-down trigger:** own funds fall below OFTR + wind-down buffer (configurable threshold, e.g., 110% of OFTR).
- **Wind-down analysis:** estimated costs to wind down the firm in an orderly manner (staff costs, lease obligations, IT decommissioning, regulatory costs) — config-as-data, updated annually or on material change.
- **Liquid-asset requirement:** sufficient liquid assets (cash, qualifying liquid instruments) to cover wind-down costs for the wind-down period (default 3 months for EMI; configurable).
- **HITL trigger:** if own funds < wind-down trigger threshold → alert to Senior Management Function (SMF) + compliance; no autonomous action.

### 2.4 ICARA document
- **Periodic assessment:** annual full ICARA review (Board-approved), with interim updates on material change.
- **Document structure:** own-funds composition → capital requirements → risk assessment (credit, market, operational, concentration, liquidity) → wind-down analysis → stress testing → capital plan.
- **Risk assessment:** qualitative + quantitative per risk category; for startup EMI, primarily operational risk + concentration risk + business risk.
- **Stress testing:** base, adverse, and severely adverse scenarios; impact on own funds and capital adequacy ratio.
- **Capital plan:** projected own funds over 3-year horizon vs requirements; actions if shortfall projected.

### 2.5 Capital-adequacy return / regulatory submission
- **Return type:** MIFIDPRU capital-adequacy data items (MIF001–MIF007 or EMI-specific equivalents) submitted to FCA via Gabriel/RegData.
- **Cadence:** quarterly (config-as-data; FCA may specify different frequency).
- **Submission:** via K-gabriel `GabrielSubmissionPort` (reuse pattern — E-capital prepares the return content, K-gabriel handles submission/deadline/validation/sign-off).
- **HITL gate:** every capital-adequacy return requires **SMF/Board sign-off** before submission — no autonomous regulatory filing.

## 3. Data model & capital-adequacy calculation

| Element | Definition |
|---|---|
| `OwnFundsComposition` | `{ cet1: Decimal, at1: Decimal, t2: Decimal, total_own_funds: Decimal, deductions: Decimal, as_of_date, source_statement_ref, status }` |
| `CapitalRequirement` | `{ pmr: Decimal, for_amount: Decimal, oftr: Decimal, kfr: Decimal, overall_requirement: Decimal, as_of_date }` |
| `KFactorLine` | `{ k_factor_type: str, applicable: bool, value: Decimal, calculation_basis: str }` |
| `CapitalAdequacyResult` | `{ own_funds: OwnFundsComposition, requirement: CapitalRequirement, surplus_deficit: Decimal, adequacy_ratio: Decimal, wind_down_trigger_breached: bool, assessed_at }` |
| `ICARADocument` | `{ period, version, own_funds, requirements, risk_assessment, wind_down_analysis, stress_tests[], capital_plan, status(DRAFT\|REVIEWED\|APPROVED), approved_by, document_hash }` |
| `CapitalReturn` | `{ return_type, period, data_items: dict, prepared_by, signed_off_by, submission_ref, status }` — immutable once `SUBMITTED` |

- **Invariants:** `total_own_funds = cet1 + at1 + t2 - deductions`; `oftr = max(pmr, for_amount)`; `overall_requirement = max(oftr, kfr)`; `surplus_deficit = total_own_funds - overall_requirement`; Decimal only (I-01); `APPROVED`/`SUBMITTED` records immutable (I-28, 5Y TTL per I-24).
- **Wind-down trigger:** `surplus_deficit < wind_down_buffer` → `wind_down_trigger_breached = true` → HITL alert.

## 4. Interfaces (hexagonal; referenced, not duplicated)

- **Consumes (from D-fin):** `FinancialStatementProvider.get_statements(period, basis)` → own-funds figures from balance sheet (equity, reserves, intangibles for deduction) + P&L (fixed overheads for FOR calc). Read-only; no posting.
- **Reuses (K-gabriel pattern):** `GabrielSubmissionPort` — E-capital produces `CapitalReturn` content; K-gabriel handles submission to FCA, deadline tracking, pre-submission validation, sign-off audit trail. Referenced; not duplicated.
- **Provides:** `CapitalAdequacyPort.assess() → CapitalAdequacyResult` — current capital position vs requirements; `get_icara_document(period) → ICARADocument` — versioned ICARA document.
- **Alerts:** `CapitalAlertPort` — wind-down trigger breach → n8n :5678 webhook → SMF/compliance notification (HITL, no autonomous action).
- **Audits:** `AuditPort` — append-only capital assessment + ICARA + return lifecycle → ClickHouse (5Y TTL, I-24/I-28), reusing J-audit evidence pattern.

## 5. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_own_funds_composition_from_dfin` (CET1/AT1/T2 derived from D-fin balance sheet; Decimal I-01).
- [ ] `test_own_funds_deductions` (intangible assets, deferred tax deducted from CET1).
- [ ] `test_pmr_fixed_amount` (£350,000 PMR for EMI; config-as-data).
- [ ] `test_fixed_overheads_requirement` (25% of prior-year fixed overheads from D-fin P&L).
- [ ] `test_oftr_is_max_pmr_for` (OFTR = max(PMR, FOR)).
- [ ] `test_kfactor_nil_for_pure_emi` (all K-factors nil when not applicable; config flags).
- [ ] `test_overall_requirement_max_oftr_kfr` (overall = max(OFTR, KFR)).
- [ ] `test_surplus_deficit_calculation` (own funds - overall requirement; Decimal).
- [ ] `test_wind_down_trigger_alerts` (surplus < buffer → HITL alert to SMF; no autonomous action).
- [ ] `test_icara_document_immutable_after_approved` (APPROVED version immutable; I-28).
- [ ] `test_capital_return_requires_signoff` (no submission without SMF/Board sign-off — HITL mandatory).
- [ ] `test_capital_return_submission_via_kgabriel` (content prepared by E-capital; submitted via K-gabriel pattern).
- [ ] `test_capital_audit_trail_5y` (append-only assessment/return lifecycle; I-24/I-28).
- [ ] Coverage ≥ 90%, Ruff + Semgrep clean.

## 6. Out of scope (fail-closed)

No runtime code in this document; no cross-repo write to `banxe-emi-stack`; **no GL/financial-reporting reimplementation** (D-gl / D-fin own those); **no FCA submission platform reimplementation** (K-gabriel owns that); **no safeguarded client-funds management** (E-safeguard / CASS 15 — separate regime); no AML/KYC/KYB; no investment advice or portfolio management; no Midaz production credentials; no autonomous regulatory submission (HITL mandatory); PROPOSED passports not activated.

## 7. Operator gates NOT crossed

- **Runtime implementation** in `banxe-emi-stack` is a **separate operator-authorized action** — this spec documents the design; it does not ship code.
- **Board/SMF approval** of ICARA document — human governance gate; not automated.
- **FCA capital-adequacy return submission** — via K-gabriel, HITL-gated; no autonomous filing.
- No DRAFT promotion; M2.8 Roster-C + web-next + Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 8. References

`docs/architecture/D-FIN-BUILD-SPEC.md` (IL-485, financial reporting — own-funds source);
`docs/architecture/D-GL-BUILD-SPEC.md` (IL-484, GL — balance source via D-fin);
`docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md` (IL-474, client-money safeguarding — **distinct regime, not capital**);
`docs/safeguarding/J-ENGINE-BUILD-SPEC.md` (IL-472, safeguarding engine — **no interaction with capital**);
`docs/regulatory/K-GABRIEL-BUILD-SPEC.md` (IL-480, FCA submission pattern — **reused**);
`docs/regulatory/F-FINRPT-BUILD-SPEC.md` (IL-481, FIN-RPT — sibling return type);
ADR-102/103/115/116/117/119; I-01 (Decimal only), I-24 (5Y TTL), I-27 (HITL), I-28 (append-only);
FCA MIFIDPRU (4.3–4.14, own funds, K-factors, FOR); EMD2/PSR (EMI own-funds requirements);
FCA ICARA guidance (PS21/6, FG20/1); FCA Gabriel/RegData.
