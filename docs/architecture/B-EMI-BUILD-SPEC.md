# B-EMI — EMI Product Catalogue Build-Spec (e-money accounts, cards, IBAN)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-24 · **Block:** B-emi · **Priority:** P1 · **Sprint:** 10 · **Promotes:** the 0% (new product-catalogue definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> B-emi is the **EMI product catalogue** — the source-of-truth *definition* layer for what Banxe sells:
> e-money account product types, card products, and the IBAN issuance/allocation model. It **defines
> products** that downstream blocks **consume**: D-gl posts product balances via `LedgerPort`, the payment
> rails (C-fps/C-sepa) route by allocated IBAN, and E-safeguard segregates the e-money liability under
> CASS 15. B-emi **does not** re-implement GL posting, rail integration, or safeguarding logic — it is the
> product-definition contract those layers read.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/architecture/D-GL-BUILD-SPEC.md` | GL core; chart-of-accounts (config-as-data), `LedgerPort.post_journal_entry()` / `get_balance()` | **keep / reference** — B-emi product accounts **map to** GL accounts; B-emi defines the product, D-gl posts. **No second ledger, no posting logic here** (ADR-102) |
| `docs/payments/C-FPS-BUILD-SPEC.md` | UK FPS rail; IBAN/sort-code-bearing accounts; CoP; `PaymentRailPort` | **keep / reference** — B-emi-issued IBANs are the **routing key** the rail consumes; rail integration **not** duplicated |
| `docs/payments/C-SEPA-BUILD-SPEC.md` | SEPA CT + Instant; EU IBAN corridor; shared `PaymentRailPort` | **keep / reference** — EUR e-money products + IBANs gate SEPA eligibility; rail logic **not** duplicated |
| `docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md` | segregated `client_funds` account management; `relevant_funds_fully_segregated` | **keep / reference** — every e-money product balance is a **relevant-funds liability** E-safeguard segregates; segregation logic **not** duplicated |
| `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` | CASS 15 safeguarding engine; daily recon | **keep / reference** — consumes the e-money liability total B-emi products define; not duplicated |
| `ROADMAP-MATRIX.md` row B-emi (`B — Product Catalogue`) + B-pricing | catalogue block split | **keep** — B-emi = product definitions; **B-pricing** (separate sub-block, P2) owns fees/tiers — not in scope here |

No existing `B-EMI-BUILD-SPEC` / B-emi product-catalogue artifact on main (live audit: `find docs -iname '*b-emi*'` ⇒ empty; `ls docs/architecture` ⇒ D-FEE/D-FIN/D-GL only). New file is **non-duplicative**; it **defines** products, it does not re-implement any consuming subsystem.

## 1. Scope — EMI product catalogue

B-emi defines three catalogue dimensions, all **config-as-data** (CLAUDE.md §10 — no hardcoded thresholds/limits):

1. **E-money account products** — product *types* a customer can hold (e.g. personal current-equivalent, business, multi-currency wallet), each with: currency set, balance/transaction limits, feature flags (rail eligibility, card-linkable, interest=none for e-money), and the GL/safeguarding mapping.
2. **Card products** — virtual / physical, scheme (e.g. Mastercard/Visa via BIN sponsor), linkage to a parent e-money account product, spend controls reference (limits are config-as-data).
3. **IBAN issuance / allocation model** — how an IBAN (and, for UK, sort code + account number) is *allocated* to an e-money account at activation, and which payment rails the resulting account is *eligible* for.

**Out** of B-emi: pricing/fees/tiers (→ **B-pricing**, P2), KYC/KYB onboarding (→ A-kyc/A-kyb, prerequisite), GL posting (→ D-gl), rail send/receive (→ C-fps/C-sepa), safeguarding segregation (→ E-safeguard/J-engine).

## 2. Product data model (config-as-data)

Products are **declarative records** (YAML/JSON in repo config, loaded at runtime — not hardcoded), versioned and immutable-per-version:

### 2.1 E-money account product
- `product_id`, `version`, `name`, `customer_segment` (`personal` | `business`).
- `currencies: [GBP, EUR, ...]` — supported settlement currencies (one ledger sub-account per currency).
- `limits` (config-as-data): per-product balance ceiling, per-txn / daily / monthly velocity caps — **values live in config**, governance-tunable (CLAUDE.md §10).
- `features`: `{ card_linkable, rail_eligibility: [FPS, SEPA_CT, SEPA_INST, ...], statement_frequency, ... }`.
- `gl_account_mapping`: chart-of-accounts key(s) into D-gl (§4.1).
- `safeguarding_class`: `relevant_funds` (always, for e-money) → E-safeguard `client_funds` liability (§4.3).

### 2.2 Card product
- `card_product_id`, `version`, `form_factor` (`virtual` | `physical`), `scheme` (`mastercard` | `visa`), `bin_sponsor_ref`.
- `parent_account_product_id` — card must link to an e-money account product (cards spend from the e-money balance; no separate float).
- `spend_controls_ref` — reference to config-as-data limits (per-txn, daily, ATM, contactless); **values in config**.

### 2.3 IBAN allocation record
- `iban`, `scheme` (`GB` w/ sort_code+account_number | `EU` IBAN), `allocation_state`, `account_product_id`, `customer_account_id`.
- Allocation is **at activation** (§3): account product → IBAN issued/assigned → rail eligibility derived from product `features.rail_eligibility` ∩ IBAN scheme.

## 3. Product lifecycle (define → activate → retire)

| State | Trigger | Effect |
|---|---|---|
| **DEFINE** | new product record (config) added, version bumped | product catalogued; **not** sellable yet; no customer accounts allowed |
| **ACTIVATE** | governance approval (HITL — CLAUDE.md §9/§11) | product sellable; customer accounts may be opened against it; IBAN allocation enabled |
| **RETIRE** | governance approval | no **new** accounts/IBANs against the product; existing accounts unaffected (grandfathered); product version frozen |

- Lifecycle transitions are **governance-gated** (rules-based + human-in-the-loop per CLAUDE.md §9); activation/retire that affects sellable products is **not** autonomous.
- Versions are append-only: a change = new `version`; prior versions remain for grandfathered accounts (audit trail).

## 4. Producer/consumer contracts (referenced, not duplicated)

B-emi **produces definitions**; the following are **consumers** — their logic is referenced, never re-implemented here.

### 4.1 To D-gl — account-to-GL mapping
- Each e-money account product carries a `gl_account_mapping` keyed into D-gl's chart-of-accounts (config-as-data, `D-GL-BUILD-SPEC` §3.1). When a customer account is opened/funded, D-gl posts via `LedgerPort` (Dr/Cr per `PostingRuleEngine`). **B-emi defines the mapping; D-gl owns posting** (I-28: LedgerPort only; no HTTP from here).

### 4.2 To C-fps / C-sepa — IBAN allocation + rail eligibility
- B-emi allocates the IBAN (UK sort code + account number, or EU IBAN) and exposes `rail_eligibility` per product. The rails (`C-FPS-BUILD-SPEC` §2, `C-SEPA-BUILD-SPEC` §2) **route by IBAN** and validate eligibility before send/receive. **B-emi is the IBAN/eligibility producer; the rails own send/receive + CoP** (not duplicated).

### 4.3 To E-safeguard — e-money → CASS 15 safeguarding linkage
- Every e-money account balance is a **relevant-funds liability** (`safeguarding_class: relevant_funds`). E-safeguard (`E-SAFEGUARD-CASS15-SPEC` §2) segregates this into `client_funds` and reconciles daily (J-engine). **B-emi classifies the product as relevant-funds; E-safeguard owns segregation + daily recon** (`relevant_funds_fully_segregated` invariant — not duplicated).

## 5. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_product_record_is_config_as_data` (products load from repo config; no hardcoded limits — CLAUDE.md §10).
- [ ] `test_emoney_product_currencies_and_limits` (currency set + limit ceilings validated from config; Decimal for any money value — I-01).
- [ ] `test_card_product_requires_parent_account_product` (card links to e-money account product; no orphan card float).
- [ ] `test_iban_allocation_at_activation` (IBAN issued/assigned on activate; UK = sort code + account number; EU = IBAN).
- [ ] `test_rail_eligibility_is_product_feature_intersect_iban_scheme` (eligibility derived, not hardcoded; FPS⇒GB, SEPA⇒EU).
- [ ] `test_gl_account_mapping_resolves_to_d_gl_chart` (mapping key resolves into D-gl chart-of-accounts; B-emi does **not** post).
- [ ] `test_emoney_classified_relevant_funds` (every e-money product → `relevant_funds`; E-safeguard consumes; B-emi does **not** segregate).
- [ ] `test_product_lifecycle_governance_gated` (DEFINE→ACTIVATE→RETIRE; activate/retire require governance approval; transitions audit-logged; versions append-only).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; no GL posting / rail / safeguarding logic in B-emi modules (boundary test).

## 6. Perimeter

- **In:** product-catalogue *definitions* — e-money account product types, card products, IBAN issuance/allocation model, product lifecycle, the mapping/eligibility/classification *contracts* to D-gl/rails/E-safeguard.
- **Out (fail-closed, §7):** GL posting, rail send/receive, safeguarding segregation, pricing/fees (B-pricing), KYC/KYB.
- **Plane:** spec only here; runtime in `banxe-emi-stack` is a separate operator-authorized action (§8).

## 7. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no GL posting / no second ledger** (D-gl owns posting via LedgerPort); **no payment-rail / PSP / CoP logic** (C-fps/C-sepa own it); **no safeguarding segregation or daily recon** (E-safeguard/J-engine own it); **no pricing / fee / tier logic** (B-pricing, separate sub-block); no KYC/KYB onboarding; no real IBAN issuance against a live BIN/sponsor (operator/HITL-gated); no opening of real customer accounts or movement of client funds (operator/HITL-gated, CLAUDE.md §11).

## 8. Operator gates NOT crossed

- **Cross-repo runtime** — implementing B-emi in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Product activation / IBAN issuance against a live BIN sponsor** = governance + operator-authorized runtime action — not done here.
- No passport activation; **M2.8 Roster-C (PR #744) + web-next + Arch-WG DRAFTs untouched**.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 9. References

`docs/architecture/D-GL-BUILD-SPEC.md` (account-to-GL mapping consumer / posting owner);
`docs/payments/C-FPS-BUILD-SPEC.md`, `docs/payments/C-SEPA-BUILD-SPEC.md` (IBAN routing / rail-eligibility consumers);
`docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md`, `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` (relevant-funds / segregation consumers);
`ROADMAP-MATRIX.md` (B-emi / B-pricing split); ADR-102/103/115/116/117/119; I-01/I-28; CLAUDE.md §9/§10/§11 (governance, config-as-data, fund-state gate).
