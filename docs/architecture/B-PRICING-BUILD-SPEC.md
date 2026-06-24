# B-PRICING — Pricing Catalogue Build-Spec (pricing rules, fee schedules, product tiers)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-25 · **Block:** B-pricing · **Priority:** P2 · **Sprint:** 11 · **Promotes:** the 0% (new pricing-catalogue definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines the pricing catalogue contract**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> B-pricing is the **commercial pricing catalogue** — the source-of-truth *definition* layer for product **tiers**,
> **pricing rules**, and **published fee schedules**. It **defines** the pricing data that **D-fee** (the fee
> engine) consumes to compute/decompose charges, and that **B-emi** products are assigned. B-pricing is to D-fee
> what B-emi is to D-gl: **B-pricing defines the commercial catalogue; D-fee computes/charges**. It does **not**
> reimplement the fee engine, billing, or GL posting.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/architecture/D-FEE-BUILD-SPEC.md` (IL-488) | **Fee engine** — `FeeEnginePort.decompose(action)`, runtime `FeeRule` `{product_type, fee_type, basis, value, currency, partner_tier?, effective_period}`, partner-tier **discount** computation | **keep / REUSE boundary** — D-fee is the **engine that computes**; B-pricing is the **commercial catalogue that defines** tiers + published schedules. D-fee's `FeeRule` rate tables are **populated/referenced from** B-pricing's pricing source. **No second fee engine / no fee-decomposition logic here** (ADR-102) |
| `docs/architecture/B-EMI-BUILD-SPEC.md` (IL-498) | EMI product catalogue (e-money accounts, cards, IBAN) | **keep / REUSE boundary** — B-emi defines **products**; B-pricing assigns **tiers + pricing** to those products. Product definitions **not** duplicated |
| `docs/architecture/D-GL-BUILD-SPEC.md` (IL-484) | GL posting via LedgerPort | **keep / reference** — fee charges post to GL via D-fee→D-gl; B-pricing does **not** post |
| `decisions/ADR-090...` (billing activation gate, referenced via D-fee) | billing/invoicing operator-gate | **keep / reference** — billing **activation** is operator-gated (ADR-090); B-pricing defines catalogue only, does not activate billing |

No existing `B-PRICING-BUILD-SPEC` / pricing-catalogue artifact on main (live audit: `find docs -iname '*b-pricing*'`/`*pricing*BUILD*` ⇒ empty; `ls docs/architecture` ⇒ A-IDV/A-KYC/A-KYB/B-EMI/D-FEE/D-FIN/D-GL/G-DEVICE/G-RT/I-API only). New file is **non-duplicative**; it **defines the commercial catalogue** D-fee consumes, it does not re-implement the engine.

## 1. Scope — pricing catalogue (commercial definition)

B-pricing defines three catalogue dimensions, all **config-as-data** (CLAUDE.md §10 — no hardcoded prices/thresholds; money = Decimal, I-01):

1. **Product tiers** — tier *definitions* (e.g. Free / Standard / Premium / Business): `tier_id`, entitlements/feature limits, eligibility, monthly/annual price point. Tiers are assigned to B-emi products.
2. **Pricing rules** — which **fee schedule** applies to which `{product, tier, customer_segment, corridor}`; effective-period + precedence/override resolution. These are **selection/mapping rules**, not the runtime fee-decomposition (D-fee owns that).
3. **Published fee schedules** — the **commercial schedule of charges** per tier/product (per-txn rates, monthly charges, FX-markup %, rail/corridor fees) as published to customers (Consumer Duty fair-value + transparency). This is the **rate source** D-fee's `FeeRule` tables reference.

**Out** of B-pricing: fee computation/decomposition per action (D-fee `FeeEnginePort`), billing/invoicing/settlement/metering (D-fee, operator-gated ADR-090), GL posting (D-gl), product definitions (B-emi).

## 2. Pricing data model (config-as-data)

Declarative, versioned, immutable-per-version; Decimal for money (I-01).

### 2.1 `ProductTier`
- `tier_id`, `version`, `name`, `customer_segment` (`personal | business`), `entitlements` (feature/limit set), `eligibility`, `recurring_price` `{amount: Decimal, currency, period}`.

### 2.2 `PricingRule`
- `rule_id`, `version`, `selector` `{product_id?, tier_id?, customer_segment?, corridor?}`, `fee_schedule_ref`, `effective_period`, `precedence`. Deterministic resolution: most-specific selector wins (config-driven).

### 2.3 `FeeSchedule` (published commercial schedule)
- `schedule_id`, `version`, `lines[]`: `{ charge_type (per_txn | recurring | fx_markup | rail_fee), basis (bps | flat), value: Decimal, currency, applies_to }`.
- This is the **published rate source**; D-fee's runtime `FeeRule` tables are populated/validated against it (single source-of-truth for *what* we charge; D-fee owns *how* it's computed).

## 3. Pricing lifecycle (define → activate → retire)

| State | Trigger | Effect |
|---|---|---|
| **DEFINE** | new tier/rule/schedule version (config) added | catalogued; not yet chargeable |
| **ACTIVATE** | governance approval (HITL — CLAUDE.md §9; fair-value sign-off, Consumer Duty) | live in catalogue; D-fee may reference it; B-emi products may be assigned the tier |
| **RETIRE** | governance approval | no new assignments; existing grandfathered; version frozen |

- Versions append-only (audit trail); price changes = new version, never in-place edit.
- **Consumer Duty fair-value:** activation requires a fair-value assessment record (price ↔ benefit); transparency of charges to customers.

## 4. Producer/consumer contracts (referenced, not duplicated)

- **Feeds D-fee** (`D-FEE-BUILD-SPEC` IL-488): B-pricing's `FeeSchedule` + `PricingRule` are the **rate/selection source** D-fee's `FeeEnginePort`/`FeeRule` consumes to compute charges. B-pricing **defines** the commercial price; D-fee **computes/decomposes** it. Engine **not** reimplemented.
- **Prices B-emi products** (`B-EMI-BUILD-SPEC` IL-498): tiers are assigned to e-money/card products; B-pricing references product ids, does not define products.
- **No GL/billing**: fee charges flow D-fee → D-gl (LedgerPort) and billing is operator-gated (ADR-090); B-pricing neither posts nor invoices.

## 5. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_tier_pricing_config_as_data` (tiers/rules/schedules from config; Decimal money; no hardcoded prices — CLAUDE.md §10, I-01).
- [ ] `test_pricing_rule_resolution_most_specific_wins` (deterministic selector resolution; effective-period honoured).
- [ ] `test_fee_schedule_is_rate_source_for_d_fee` (D-fee `FeeRule` references B-pricing schedule; **no fee-decomposition logic in B-pricing**; boundary test).
- [ ] `test_tier_assignment_to_b_emi_products` (tiers assigned to product ids; B-pricing does not define products).
- [ ] `test_pricing_lifecycle_governance_gated` (DEFINE→ACTIVATE→RETIRE; activation requires fair-value sign-off; versions append-only).
- [ ] `test_no_billing_or_gl` (no invoicing/settlement/GL posting; D-fee/D-gl own those; billing operator-gated ADR-090).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; D-fee/B-emi boundaries respected.

## 6. Perimeter

- **In:** commercial pricing catalogue — product tiers, pricing rules, published fee schedules, pricing lifecycle, the rate-source contract to D-fee + tier-assignment to B-emi.
- **Out (fail-closed, §7):** fee computation/decomposition (D-fee engine), billing/invoicing/settlement/metering (D-fee, operator-gated ADR-090), GL posting (D-gl), product definitions (B-emi).
- **Plane:** spec only here; runtime in `banxe-emi-stack` is a separate operator-authorized action (§8).

## 7. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no fee computation/decomposition** (D-fee `FeeEnginePort` owns it); **no second fee engine / no duplicate FeeRule logic** (ADR-102); **no billing / invoicing / settlement / metering / partner-tier enforcement / live fee data** (D-fee, operator-gated ADR-090); **no GL posting** (D-gl); **no product definitions** (B-emi); no in-place price mutation (append-only versions); no activation without Consumer Duty fair-value sign-off.

## 8. Operator gates NOT crossed

- **Cross-repo runtime** — implementing B-pricing in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Billing activation** (real charges/invoicing/settlement) = operator decision (ADR-090 / D-fee gate) — not crossed; B-pricing defines catalogue only.
- **Price/tier activation** = governance + fair-value sign-off (HITL) — not done here.
- No passport activation; no DRAFT promotion; no operator-gated PR touched; Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 9. References

`docs/architecture/D-FEE-BUILD-SPEC.md` (IL-488 — fee engine consuming B-pricing rate source; billing gate ADR-090);
`docs/architecture/B-EMI-BUILD-SPEC.md` (IL-498 — products priced/tiered by B-pricing);
`docs/architecture/D-GL-BUILD-SPEC.md` (IL-484 — fee charges post via D-fee→D-gl);
`ROADMAP-MATRIX.md` (B-emi / D-fee rows); ADR-090 (billing activation gate), ADR-027 (audit), ADR-102/103/115/116/117/119; I-01 (Decimal); CLAUDE.md §9/§10/§11 (governance, config-as-data); Consumer Duty PS22/9 (fair value + transparency).
