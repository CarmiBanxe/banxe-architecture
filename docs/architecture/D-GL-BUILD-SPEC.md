# D-GL — General Ledger Core Build-Spec (Midaz PRIMARY / Fineract FALLBACK)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-23 · **Block:** D-gl · **Priority:** P1 · **Sprint:** 8 · **Promotes:** the existing 5%.
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/consolidates**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> D-gl is the **double-entry General Ledger core** — the single source-of-truth for balances that
> **D-recon reads (Leg A)** and that **F-finrpt** derives return content from. Posting machinery already
> exists in emi-stack (IL-FIN-01); this build-spec **consolidates** the scattered 5% (Midaz API research +
> bootstrap/provisioning runbooks + the ABS-posting covered-note) into one coherent, actionable spec.

---

## 0. Duplication Audit (ADR-102)
| Artifact | Role | Decision |
|---|---|---|
| `docs/midaz-transaction-api-research.md` | Midaz v3.5.3 transaction API surface (endpoints, DSL, structs) | **keep / promote** — API basis for §3 |
| `docs/migration/MIG-ABS-posting-COVERED-gl-service.md` (IL-FIN-01) | GL/posting subsystem already in emi-stack (`services/ledger/`) | **keep** — this spec consolidates it; **no second ledger / no parallel posting port** (ADR-102) |
| `docs/runbooks/R1-MIDAZ-LEDGER-BOOTSTRAP-2026-05-22.md`, `pa-01-midaz-ledger-postgres-provisioning.md` | Midaz deploy/bootstrap/Postgres provisioning | **keep** — deploy basis (§6) |
| `docs/D-RECON-BUILD-SPEC.md` | GL = recon **Leg A** source via `LedgerPort.get_balance()` | **keep / reference** — D-gl is the **producer**; not duplicated |
| `decisions/ADR-013-midaz-cbs-primary.md` | Midaz PRIMARY, Fineract FALLBACK | **keep** — primary/fallback authority (§2) |
No existing `D-GL-BUILD-SPEC` / `docs/architecture/` dir on main → new file non-duplicative; it **specifies**, it does not re-implement the IL-FIN-01 subsystem.

## 1. What the 5% already is (promoted, verified)
Per the ABS-posting covered-note (IL-FIN-01), `services/ledger/` in emi-stack already provides:
- `ledger_models.py` — `Posting` (Decimal, I-01), `JournalEntry` (**sum debits == sum credits per currency**), `PostingDirection`/`Status`.
- `gl_service.py` — `GLService.post_journal_entry()` via `LedgerPort`; `UnbalancedEntryError`; high-value approval.
- `payment_posting_service.py` (`PaymentEvent`→`PostingRule`) + `posting_rules.py` (`PostingRuleEngine`).
- `midaz_adapter.py` (Midaz, ADR-013) + `inmemory_ledger.py` (tests).
This build-spec defines the **target GL core** that completes/coheres this base.

## 2. Primary / fallback strategy + failover boundary (ADR-013)
- **Midaz (LerianStudio) = PRIMARY, single active source-of-truth.** All posting + balance derivation go through `LedgerPort` → `midaz_adapter` (Midaz Transaction API). **No second active ledger, no dual-write** (ADR-102 / MIG-ABS covered-note).
- **Apache Fineract = FALLBACK**, reachable via the **same `LedgerPort`** abstraction (CBS-agnostic): a Fineract adapter is a **swap/failover** path, NOT concurrent. Failover = re-point `LedgerPort` to the Fineract adapter; the GL core, posting model, and consumers are unchanged.
- **Failover boundary:** Midaz unavailable at posting/derivation time ⇒ the GL core surfaces an infra-failure (no silent skip); promotion to the Fineract fallback is an **operator-authorized** runtime switch (not autonomous). `LedgerPort` keeps Midaz→Fineract transparent to D-recon / F-finrpt.

## 3. GL core model & transaction API surface
### 3.1 Chart of accounts (config-as-data)
- Accounts modelled in Midaz (org/ledger scoped). Safeguarding accounts per ADR-013 (`client_funds`, `operational`) + GL account hierarchy; aliases (`@alias`) used in postings. Account codes/types are **config-as-data** (CLAUDE.md §10), not hardcoded.

### 3.2 Double-entry posting model (invariants)
- `JournalEntry` = set of `Posting`s; **balanced per currency** (Σ debits == Σ credits); Decimal only (I-01); `UnbalancedEntryError` on violation. PostingDirection (debit/credit) + Status (PENDING/CREATED/COMMITTED/CANCELLED/REVERTED). High-value postings require approval.
- `PostingRuleEngine`: `PaymentEvent` → `PostingRule` → balanced `JournalEntry` (deterministic mapping; config-driven rules).

### 3.3 Transaction API surface (Midaz, via LedgerPort/adapter)
- Create: `POST /v1/organizations/{org}/ledgers/{ledger}/transactions/{json,inflow,outflow,annotation,dsl}`.
- Lifecycle: `commit` / `cancel` (PENDING), `revert` (CREATED), `PATCH` metadata, `GET` single/list.
- `@external` for inflow/outflow counterpart; `annotation` = records-only (no balance impact, status NOTED).
- The GL core wraps these behind `GLService.post_journal_entry()` — callers never hit Midaz HTTP directly (I-28: LedgerPort only).

### 3.4 Balance derivation
- `LedgerPort.get_balance(account, currency) -> Decimal` is the canonical read; account balances derived from committed postings. This is the **producer contract** below.

## 4. Producer contracts (referenced, not duplicated)
- **To D-recon (Leg A):** `LedgerPort.get_balance()` supplies the internal-ledger leg of the 3-leg recon (`D-RECON-BUILD-SPEC` §2 Leg A). D-gl produces; D-recon consumes.
- **To F-finrpt:** ledger balances/aggregates feed `ReconSourcePort`/`LedgerPort` reads for FIN-RPT content derivation (`F-FINRPT-BUILD-SPEC` §2/§5). D-gl is read-only source; F-finrpt does not write back.
- **No reimplementation:** D-recon/F-finrpt are referenced as consumers; their logic is not duplicated here.

## 5. DoD / acceptance criteria (for the banxe-emi-stack PR)
- [ ] `test_journal_entry_balanced_per_currency` (Σ debit == Σ credit; `UnbalancedEntryError` otherwise; Decimal I-01).
- [ ] `test_posting_via_ledgerport_only` (no direct Midaz HTTP from callers; I-28).
- [ ] `test_posting_rule_engine_payment_event_to_entry` (deterministic, config-driven).
- [ ] `test_transaction_lifecycle` (create→commit; cancel PENDING; revert CREATED; annotation = no balance impact).
- [ ] `test_high_value_posting_requires_approval`.
- [ ] `test_get_balance_from_committed_postings` (producer contract for D-recon Leg A / F-finrpt).
- [ ] `test_fallback_swap_transparent` (re-point LedgerPort Midaz→Fineract adapter; GL core + consumers unchanged; no dual-write).
- [ ] `test_midaz_unavailable_surfaces_infra_failure` (no silent skip).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; LedgerPort-only (I-28).

## 6. Deploy / bootstrap (reference)
Provisioning + bootstrap per `R1-MIDAZ-LEDGER-BOOTSTRAP` + `pa-01-midaz-ledger-postgres-provisioning` runbooks (Midaz :8095, Postgres). Deploy/runtime is a **separate operator-authorized action** in emi-stack.

## 7. Out of scope (fail-closed)
No runtime code here; no cross-repo write into banxe-emi-stack; **no second active ledger / no dual-write**; no autonomous Fineract failover (operator-authorized); no live posting of client funds (real-money posting is operator/HITL-gated); no KYC/KYB/AML; no payment-rail/PSP logic (separate blocks).

## 8. Operator gates NOT crossed
- **Cross-repo runtime** — completing D-gl in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write).
- **Fineract fallback activation** = operator-authorized runtime switch — not done here.
- No passport activation; M2.8 Roster-C + web-next + Arch-WG DRAFTs untouched.
- If any is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 9. References
`docs/midaz-transaction-api-research.md`; `docs/migration/MIG-ABS-posting-COVERED-gl-service.md` (IL-FIN-01);
`docs/runbooks/R1-MIDAZ-LEDGER-BOOTSTRAP-2026-05-22.md`, `pa-01-midaz-ledger-postgres-provisioning.md`;
`docs/D-RECON-BUILD-SPEC.md` (Leg A consumer), `docs/regulatory/F-FINRPT-BUILD-SPEC.md` (content consumer);
`decisions/ADR-013-midaz-cbs-primary.md`; ADR-102/103/115/116/117/119; I-01/I-28; CTX-06 (Core Banking).
