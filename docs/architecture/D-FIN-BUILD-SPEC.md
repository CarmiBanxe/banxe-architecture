# D-Fin — Financial Reporting Core Build-Spec (P&L / Balance Sheet / Management Accounts)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-23 · **Block:** D-fin · **Priority:** P1 · **Sprint:** 10
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> D-fin is the **management & statutory financial-reporting core** — it **derives** P&L, balance sheet, and
> management accounts **from D-gl GL data** (journal entries + chart of accounts). It does **not** post to the
> GL (that is D-gl) and does **not** submit regulatory returns (that is F-finrpt/K-gabriel); it may **feed**
> F-finrpt where regulatory return content maps from the financial statements.

---

## 0. Duplication Audit (ADR-102)
| Artifact | Role | Decision |
|---|---|---|
| `docs/architecture/D-GL-BUILD-SPEC.md` | GL core — `JournalEntry`/`Posting`, chart of accounts, `LedgerPort.get_balance()` | **keep / reference** — D-gl is the **data source**; D-fin reads, never posts |
| `docs/regulatory/F-FINRPT-BUILD-SPEC.md` | FIN-RPT regulatory-returns content (`FinRepContentProvider`) | **keep / reference** — D-fin **may feed** it; D-fin does NOT do regulatory mapping/submission |
| `docs/D-RECON-BUILD-SPEC.md` | 3-leg recon | **keep** — sibling GL consumer; no overlap with reporting |
| GAP-018 (financial-reporting **governance**) | reporting governance | **fence** — D-fin is the reporting **core**; governance is GAP-018, not duplicated |
No existing D-fin build-spec on main → new file non-duplicative; it **specifies** the reporting core, does not reimplement GL posting or regulatory returns.

## 1. Boundary (D-fin vs D-gl vs F-finrpt) — drift reconciled
| Concern | Owner | This spec |
|---|---|---|
| Journal entries, postings, balances (source of truth) | **D-gl** | **reads** (consumer) |
| **Financial statements** — P&L, balance sheet, management accounts (derivation, period close, accruals) | **D-fin** | **builds** |
| Regulatory-return **content** (FIN-REP/RegData) + submission | F-finrpt (GAP-007) / K-gabriel (GAP-006) | **feeds / references** (D-fin statements are a source for FIN-REP mapping; D-fin does NOT submit) |
| Financial-reporting **governance** | GAP-018 | **fences** |
D-fin sits **between** D-gl (source) and F-finrpt (one consumer of its outputs).

## 2. Scope — financial reporting core
1. **P&L (income statement)** — income/expense aggregation by account type + period (Decimal, I-01).
2. **Balance Sheet** — asset/liability/equity positions at period-end, derived from GL balances.
3. **Management accounts** — internal P&L by segment/cost-centre/product (dimensions from GL metadata), variance vs prior period.
4. **Period close** — lock a reporting period, close P&L to retained earnings (carry-forward), produce an immutable versioned statement set.
5. **Accrual treatment** — accrual-basis recognition; period-end accruals/deferrals exist as adjusting **journal entries posted via D-gl** (D-fin computes the report; it does **not** post the JEs itself).

## 3. Report data model & derivation rules
| Element | Definition |
|---|---|
| `FinancialStatementSet` | `{ period, basis(accrual\|cash), version, pnl, balance_sheet, mgmt_accounts, derived_at, source_refs[], statement_hash, status }` — immutable once `FINAL` |
| Statement line | `{ account_type, account_code, amount: Decimal, currency, period }` |
| Account classification | chart-of-accounts `account_type` (asset / liability / equity / income / expense) — **config-as-data** (CLAUDE.md §10), same CoA D-gl owns |
| Derivation | aggregate **committed** `JournalEntry` postings (D-gl) by account_type + period; balance sheet from period-end balances; mgmt accounts add segment dimension |
- **Invariants:** P&L + retained-earnings roll-forward reconciles to balance-sheet equity movement; assets = liabilities + equity at period-end; Decimal only (I-01); `FINAL` statement sets immutable (versioned, `statement_hash`) for audit/evidence (I-24/I-28).

## 4. Interfaces (hexagonal; referenced, not duplicated)
- **Consumes (from D-gl):** `GLReadPort` — committed `JournalEntry` stream + `LedgerPort.get_balance()` aggregates per account/period (read-only; no posting). D-gl is the producer (D-GL §3.4/§4).
- **Provides:** `FinancialStatementProvider.get_statements(period, basis) -> FinancialStatementSet` (FINAL/validated/versioned; raises if period not closed) + `list_closed_periods()`.
- **Feeds F-finrpt:** F-finrpt's FIN-REP line items may **map from** D-fin's `FinancialStatementSet` (D-fin = financial figures source; F-finrpt = regulatory mapping/computation per `FinRepContentProvider`). Referenced; D-fin does not compute regulatory items or submit.

## 5. DoD / acceptance criteria (for the banxe-emi-stack PR)
- [ ] `test_pnl_aggregates_income_expense_by_period` (Decimal, I-01).
- [ ] `test_balance_sheet_assets_eq_liabilities_plus_equity` (period-end identity).
- [ ] `test_pnl_closes_to_retained_earnings` (period close roll-forward reconciles).
- [ ] `test_mgmt_accounts_segment_dimension` (by cost-centre/segment; variance vs prior).
- [ ] `test_statements_derived_from_committed_je_only` (reads GL via GLReadPort; **no posting**; ignores PENDING).
- [ ] `test_statement_set_immutable_after_final` (versioned, `statement_hash`; no mutate after FINAL — I-24/I-28).
- [ ] `test_accrual_basis_recognition` (accrual vs cash; adjusting JEs posted via D-gl, not by D-fin).
- [ ] `test_no_regulatory_submission_present` (D-fin produces statements; does NOT submit — that is F-finrpt/K-gabriel).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; GL reads via port only (I-28).

## 6. Out of scope (fail-closed)
No runtime code here; no cross-repo write into banxe-emi-stack; **no GL posting** (D-gl); **no regulatory-returns content/submission** (F-finrpt/K-gabriel); no financial-reporting **governance** (GAP-018); no KYC/KYB/AML; read-only over GL (no write-back).

## 7. Operator gates NOT crossed
- **Cross-repo runtime** — building D-fin in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write).
- No passport activation; M2.8 Roster-C + web-next + Arch-WG DRAFTs untouched.
- If any is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 8. References
`docs/architecture/D-GL-BUILD-SPEC.md` (GL source: `JournalEntry`, `LedgerPort.get_balance`); `docs/regulatory/F-FINRPT-BUILD-SPEC.md` (`FinRepContentProvider` consumer of D-fin figures); `docs/D-RECON-BUILD-SPEC.md`; GAP-018 (governance, fenced); `docs/ROADMAP-MATRIX.md` (D-fin); ADR-013, ADR-102/103/115/116/117/119; I-01/I-24/I-28; CTX-06.
