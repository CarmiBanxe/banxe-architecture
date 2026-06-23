# D-Fee — Fee Engine & Billing Build-Spec (promotes ADR-090 fee-engine seam)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-23 · **Block:** D-fee · **Priority:** P1 · **Sprint:** 10
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime → `CarmiBanxe/banxe-emi-stack` (billing engine) + `banxe-trading-backend` (existing fee-attribution seam). This doc **specifies**; ships **no** runtime code and makes **no** cross-repo write.
**Promotes:** `docs/adr/ADR-090-dynamic-fee-engine-advisory-seam.md` (ACCEPTED) → actionable D-fee build-spec.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119. Additive.

> D-fee computes fees and (when activated) bills them. **Fee *computation/attribution* exists today as
> ADR-090's analytics-only `FeeEnginePort` (mock, no billing).** **Real billing — charges, recurring/
> monthly invoicing, FX-markup *settlement*, metering, partner-tier *enforcement*, live fee data — is
> OPERATOR-GATED** (ADR-090 D5 "billing stays out of the factory train" + "OPERATOR DECISION REQUIRED").
> This build-spec specifies the target architecture for both halves; it **does not activate billing**.

---

## 0. Duplication Audit (ADR-102)
| Artifact | Role | Decision |
|---|---|---|
| `docs/adr/ADR-090-dynamic-fee-engine-advisory-seam.md` (IL-225) | `FeeEnginePort` fee-attribution decomposition (mock, analytics-only, no billing) | **keep / promote** — the **computation** core of D-fee; billing is its explicit gated successor |
| `docs/architecture/D-GL-BUILD-SPEC.md` | GL posting via `LedgerPort` / `JournalEntry` | **keep / reference** — D-fee **posts** fee journal entries to D-gl; does NOT reimplement posting |
| `docs/architecture/D-FIN-BUILD-SPEC.md` | P&L / financial statements | **keep / reference** — fee revenue **surfaces in** D-fin P&L; D-fee does NOT report |
| `banxe-trading-backend` fee seam (`ports/fee_engine_port.py`, `api/fees.py`) | existing mock `FeeEnginePort` + `/api/v1/fees/preview` | **keep** — the seam this spec promotes; not re-authored |
No existing D-fee build-spec on main → new file non-duplicative; this **promotes** ADR-090 + specifies the gated billing layer (no second fee port).

## 1. Boundary (D-fee vs D-gl vs D-fin) — drift reconciled
| Concern | Owner | This spec |
|---|---|---|
| Fee **computation / attribution** (per-action decomposition) | **D-fee** (promotes ADR-090 `FeeEnginePort`) | **builds** (mock-default, fail-closed) |
| Fee **billing** — charging, recurring/monthly invoices, FX-markup settlement, metering | **D-fee** | **specifies — OPERATOR-GATED activation** (ADR-090 D5) |
| Posting fee charges/revenue as `JournalEntry` | **D-gl** | D-fee **calls** `LedgerPort` (no reimpl) |
| Fee revenue in P&L / statements | **D-fin** | **surfaces in** (referenced; D-fee does not report) |

## 2. Scope
1. **Fee computation (live as mock, promoted from ADR-090):** `FeeEnginePort` decomposes an action into components (`integrator_fee`, `builder_code_fee`, `referral_fee`, `performance_fee`, `maker_rebate`, `bid_ask_spread_capture`) with `bps`/`usd`/`source` + totals; deterministic `MockFeeEngine` (fixture rate tables, partner-tier *discount* on platform-take); `BANXE_FEE_PROVIDER=mock` default, **fail-closed** on any other value (live data = operator-gated/ODR).
2. **Per-transaction fees:** computed per transaction from fee-rule config; **charging** (posting to GL) = gated (§4/§5).
3. **Monthly / recurring charges:** billing-cycle model for periodic platform/account charges — **specified, gated for activation**.
4. **FX markup:** markup model over the FX rate (Frankfurter/quote source) applied at fee computation; **markup *settlement* as a real charge = gated**.

## 3. Fee-rule model (config-as-data) & computation
- `FeeRule` = `{ product_type, fee_type(per_txn|recurring|fx_markup), basis(bps|flat), value: Decimal, currency, partner_tier?, effective_period }` — **config-as-data** (CLAUDE.md §10), versioned.
- Computation = deterministic `FeeEnginePort.decompose(action) -> FeeDecomposition` (Decimal, I-01); partner-tier discount applied to platform-take components only (ADR-090).
- FX markup = `markup_bps` over the reference rate; produces a fee component, not a rate mutation.

## 4. Producer/consumer contracts (referenced, not duplicated)
- **Posts to D-gl (when billing activated):** a charged fee → balanced `JournalEntry` via `LedgerPort` (debit customer/settlement, credit fee-income), per D-GL §3. D-fee calls the port; D-gl owns posting.
- **Surfaces in D-fin:** fee-income GL accounts roll up into D-fin P&L (income) — D-fin §2; D-fee does not compute statements.
- **Analytics seam (live, mock):** internal `POST /api/v1/fees/preview` (ADR-090 D3) — metadata, `signed:false`, `submitted:false`; not on the `/v1` partner facade.

## 5. Billing activation — OPERATOR-GATED (NOT crossed here)
Per ADR-090 D2/D4/D5 + "OPERATOR DECISION REQUIRED", the following are **operator-gated** and **not** designed-as-active here (specified as target only):
- Real **billing/metering** (Lago / Orb / Stripe), invoicing, settlement, on-chain fee hooks.
- Partner-tier **enforcement** (vs discount-only), live fee/attribution data sources, real keys.
- Any `/v1` partner-contract change for fees.
- Posting real fee charges to GL (live money) — HITL/operator-gated.
The factory ships only the **mock-default, fail-closed computation seam spec**; billing activation is a separate operator decision (G-sprint).

## 6. DoD / acceptance criteria (for the future banxe-emi-stack / trading-backend PR)
- [ ] `test_fee_decomposition_deterministic_mock` (components + totals; Decimal I-01).
- [ ] `test_fee_provider_fail_closed` (`BANXE_FEE_PROVIDER` != mock → fail at startup).
- [ ] `test_partner_tier_discount_platform_take_only`.
- [ ] `test_fx_markup_produces_component_not_rate_mutation`.
- [ ] `test_recurring_charge_billing_cycle_model` (period schedule computed; **no real charge** without operator gate).
- [ ] `test_fee_posts_journal_entry_via_ledgerport` (gated path: balanced JE via D-gl; no posting reimpl).
- [ ] `test_no_billing_without_operator_gate` (real billing/metering/settlement fail-closed; analytics seam = `submitted:false`).
- [ ] `test_fee_preview_internal_only` (not on `/v1` facade → 404 there).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; GL posting via `LedgerPort` only (I-28).

## 7. Out of scope (fail-closed)
No runtime code here; no cross-repo write; **no GL posting reimplementation** (D-gl); **no financial-reporting reimplementation** (D-fin); **no live billing/metering/invoicing/settlement** (operator-gated, ADR-090 D5); no partner-tier enforcement / live fee data / real keys (ODR); no `/v1` fee contract change; no KYC/KYB/AML.

## 8. Operator gates NOT crossed
- **Billing activation** (real charges/invoicing/settlement/metering/partner-tier enforcement/live fee data) = **operator decision** (ADR-090 D5 / G-sprint) — not crossed.
- **Cross-repo runtime** — building D-fee in `banxe-emi-stack` / `banxe-trading-backend` is a **separate operator-authorized action**.
- No passport activation; M2.8 Roster-C + web-next + Arch-WG DRAFTs untouched.
- If any is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 9. References
`docs/adr/ADR-090-dynamic-fee-engine-advisory-seam.md`; `docs/architecture/D-GL-BUILD-SPEC.md` (posting), `docs/architecture/D-FIN-BUILD-SPEC.md` (P&L); ADR-083 (composable DeFi stack); `banxe-trading-backend` fee seam; `docs/ROADMAP-MATRIX.md` (D-fee); ADR-102/103/115/116/117/119; I-01/I-28.
