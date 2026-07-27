# Context & scope

Install-audit for the B-EMI (EMI product catalogue) sub-sprint of S-A6, per
`docs/architecture/B-EMI-BUILD-SPEC.md`. Scope: locate the EMI product-catalogue
implementation in `banxe-emi-stack`, record paths + SHA, verify whether product
definitions are declarative/versioned/immutable-per-version, verify whether the
product→GL mapping points at the same `LedgerPort` identified in the D-GL install-audit,
and search for duplicate posting logic outside D-GL. Evidence-only; no code fixed, no
spec rewritten. Where D-GL evidence was needed for comparison, the already-created
`D-GL-INSTALL-AUDIT-2026-07-20.md` and the underlying `services/ledger/` code were read,
but only this file was written.

# What exists (code / config / docs — paths + SHA)

Repo: `banxe-emi-stack`, branch `agent/factory/ledgerenv/sandbox-fix`, HEAD
`26365b4500a10e33eb30fe6afb3129a8ff9f8d7a`.

- `src/products/emi_products.py` — self-labeled in its own docstring as **"GAP-014
  B-emi"**. Defines `ProductType` (`EMONEY_ACCOUNT`, `PREPAID_CARD`, `VIRTUAL_IBAN`,
  `SAVINGS_POT`), `ProductStatus` (`ACTIVE`, `SUNSET`, `WITHDRAWN`), `RegulatoryScheme`,
  `FairValueAssessment` (frozen dataclass), the `EMIProduct` dataclass, and
  `ProductCatalogue` (registry class with a `.default()` classmethod that constructs four
  hardcoded product instances). Last commit `f44251b6250300e897858fee2eaf18a341e0524e`
  (2026-04-13).
- `src/products/__init__.py` — re-exports the above six names; module docstring also
  labels it "GAP-014 B-emi".
- No `gl_account_mapping` field or equivalent GL-mapping mechanism found anywhere
  (`rg -il gl_account_mapping|gl_mapping` across all `.py` files: zero hits).
- No lifecycle-state code matching `DEFINE`/`ACTIVATE`/`RETIRE` found anywhere in
  `emi_products.py` (zero matches) — the only state model present is the flat
  `ProductStatus` enum (`ACTIVE`/`SUNSET`/`WITHDRAWN`).
- No dedicated IBAN-allocation record class or fields (`allocation_state`,
  `account_product_id`, `customer_account_id`) found anywhere (zero matches).
- No `LedgerPort`/`post_journal_entry`/`JournalEntry` reference anywhere in
  `src/products/` (zero matches) — i.e. no duplicate posting logic found here.
- Consumers: `rg` for imports of `ProductCatalogue`/`EMIProduct` outside
  `src/products/emi_products.py` found exactly one hit — `tests/test_src_products.py`. No
  GL, payment-rail, or safeguarding module imports this catalogue.
- Sibling, out-of-scope-for-B-EMI product-catalogue modules noted for completeness, not
  analysed further here: `services/savings/product_catalog.py`,
  `services/insurance/product_catalog.py` (separate domains, separate specs).

# Ledger topology & EMI-conformance notes

- **Declarative/config-as-data claim does not hold.** Spec §2 states products are
  "declarative records (YAML/JSON in repo config, loaded at runtime — not hardcoded)."
  In code, all four products are hardcoded Python `EMIProduct(...)` instances constructed
  directly inside `ProductCatalogue.default()` — no YAML/JSON product-definition file
  exists anywhere in the repo.
- **`gl_account_mapping` (spec §4.1, DoD `test_gl_account_mapping_resolves_to_d_gl_chart`)
  is unimplemented.** No field, method, or reference resolves an `EMIProduct` to a D-GL
  chart-of-accounts key. The producer contract to D-GL described in the spec does not
  exist in code today.
- **No product→GL posting duplication found** (positive finding): `src/products/`
  contains no `LedgerPort`/posting-logic reference at all — the "no second ledger, no
  posting logic here" boundary (ADR-102) holds, simply because there is no GL
  integration code of any kind yet, not because a correct integration was verified.
- **Product lifecycle (spec §3: DEFINE → ACTIVATE → RETIRE, governance-gated,
  append-only versioning) is not implemented as specified.** Code only has a flat
  `ProductStatus` (`ACTIVE`/`SUNSET`/`WITHDRAWN`) with no transition methods, no
  governance-approval hook, and no audit logging of state changes visible in this file.
  `ProductCatalogue.register()` **overwrites** an existing `product_id` in place (logging
  a warning), which contradicts the spec's "versions are append-only... prior versions
  remain for grandfathered accounts" requirement.
- **Card product and IBAN allocation are not separate schemas.** Spec §2.2/§2.3 define
  `card_product_id` (+ `parent_account_product_id`) and a distinct IBAN-allocation record
  (`iban`, `allocation_state`, `account_product_id`, `customer_account_id`) as their own
  data models. In code, `PREPAID_CARD` and `VIRTUAL_IBAN` are simply two more values of
  the same `ProductType` enum on the single `EMIProduct` dataclass — there is no
  parent-account linkage field for cards, and no allocation-state tracking for IBANs.
- **Zero consumers wired.** `ProductCatalogue`/`EMIProduct` are imported only by their own
  test file. The spec's §4 producer/consumer contracts to D-GL, C-fps/C-sepa, and
  E-safeguard/J-engine describe relationships that do not currently exist as code
  dependencies in either direction.
- **Cross-check vs. D-GL install-audit:** the D-GL `LedgerPort`/`GLService` code
  (`services/ledger/`) exists and is real, but nothing in `src/products/` references it —
  confirming the B-EMI↔D-GL integration described in the spec is unimplemented on the
  B-EMI side specifically (D-GL itself does not need B-EMI to function correctly today).

# Gaps & risks (OPEN POINTS)

1. **Spec's own "Promotes: the 0%" framing appears incorrect.** `src/products/emi_products.py`
   (labeled "GAP-014 B-emi" in its own docstring) already existed in `banxe-emi-stack`
   since 2026-04-13 — over two months before `B-EMI-BUILD-SPEC.md` (dated 2026-06-24). The
   spec's own Duplication Audit (§0) only searched `docs/` in `banxe-architecture`
   (`find docs -iname '*b-emi*'` ⇒ empty) — it did not search the runtime repo, which is
   where the pre-existing "GAP-014 B-emi" implementation actually lives. This is a
   cross-repo ADR-102 blind spot, not a fabricated claim — the spec-plane search was
   accurate for its own repo, just incomplete in scope.
2. **Config-as-data claim vs. hardcoded literals.** Product records are hardcoded Python
   dataclass instances, not externalized YAML/JSON — directly contrary to spec §2.
3. **`gl_account_mapping` is entirely unimplemented** — the core D-GL integration point
   the spec defines (§4.1) and the corresponding DoD test do not exist in code.
4. **Product lifecycle governance (DEFINE→ACTIVATE→RETIRE) is unimplemented** — only a
   flat, differently-named status enum exists, with no governance-gated transition logic
   or audit trail found.
5. **Version handling contradicts append-only requirement** — `register()` overwrites a
   product_id's prior version in place rather than retaining it for grandfathered
   accounts.
6. **Card-product and IBAN-allocation are not separate schemas** — the spec's 3-dimension
   model is collapsed into one `EMIProduct`/`ProductType` model, with no parent-account
   linkage for cards and no allocation-state tracking for IBANs.
7. **Zero producer/consumer wiring exists** to D-GL, C-fps/C-sepa, or E-safeguard/J-engine
   — the spec's §4 contracts describe relationships that are not yet code dependencies in
   either direction.

# Next steps / hooks into Floor-2 rooms

- **OPEN POINT 1 (cross-repo duplication-audit blind spot):** route to the governance /
  ledger-tech room — future spec Duplication Audits (ADR-102 §0) should search the
  runtime repo (`banxe-emi-stack`), not only the spec-plane repo, before asserting a "0%"
  or "new" status.
- **OPEN POINTs 2–6 (spec-vs-code structural divergence: config-as-data, GL mapping,
  lifecycle, versioning, card/IBAN schema split):** route to the product/ledger room for
  an operator decision on direction — retrofit the existing `src/products/emi_products.py`
  toward the spec's model, or treat the spec as needing revision to match the code
  actually shipped under GAP-014, before B-EMI can be called READY.
- **OPEN POINT 7 (zero consumer wiring):** route to the ledger + payments rooms jointly —
  this determines whether B-EMI's producer contracts to D-GL/rails/safeguarding are real
  integration work still to be done, or whether an equivalent integration already exists
  under a different module name not surfaced by this audit's search terms.
