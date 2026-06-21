# MIG-ABS-posting — BLOCKER: double-entry GL/posting via LedgerPort already exists in banxe-emi-stack (no scaffold)

<!-- Source: docs/migration/MIG-ABS-posting-BLOCKER-gl-service-already-exists.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. ADR-102 duplication stop-barrier. -->

> **STATUS: BLOCKED.** Mandatory read-only preflight + ADR-102 Duplication Audit stopped the
> abs-posting scaffold **before any code.** banxe-emi-stack **already implements double-entry
> bookkeeping (GL) posting via `LedgerPort`** (`GLService`, IL-FIN-01). Scaffolding a new `AbsPostingPort`
> + double-entry DTO would duplicate it → **STOP, no scaffold** (ADR-102 HARD RULE; same posture as
> M2.4 / M2.5 / M2.3 / M2.4a). Docs-only blocker + IL-shard.

## 1. Preflight outcome (read-only, origin/main 3228d3d)

The posting / double-entry / GL subsystem is **already fully implemented** in `services/ledger/`:

| Capability | Existing |
|---|---|
| Double-entry models | `services/ledger/ledger_models.py` — `Posting` (debit/credit, **Decimal I-01**, immutable I-24), `PostingDirection` (debit/credit), `PostingStatus`, `JournalEntry` (**invariant: sum debits == sum credits per currency**), `HIGH_VALUE_THRESHOLD` |
| **GL posting service via LedgerPort** | `services/ledger/gl_service.py` — **`GLService`** (IL-FIN-01) `post_journal_entry()` **consumes `LedgerPort`** (`from services.ledger.ledger_port import LedgerPort`); `UnbalancedEntryError` (debits != credits); high-value approval |
| Payment→posting mapping | `services/ledger/payment_posting_service.py` (`PaymentEvent` → `PostingRule`) + `posting_rules.py` (`PostingRuleEngine`, `PostingRule` debit/credit account types) |
| Ledger adapter (LedgerPort impl) | `services/ledger/midaz_adapter.py` (Midaz, ADR-013) + `inmemory_ledger.py` |
| Consumers | `api/routers/ledger.py`, `api/deps.py`, `services/recon/midaz_reconciliation.py` |

## 2. Why scaffold is blocked

The proposed `AbsPostingPort` (ABC) + posting-intent/entry DTO (double-entry debit/credit legs,
balanced) + LedgerPort consumption **already exists** as `GLService.post_journal_entry()` +
`Posting`/`JournalEntry` (balanced double-entry) + `payment_posting_service` (rules) + LedgerPort/Midaz
adapter. A new posting port would **duplicate** the GL subsystem → ADR-102 violation (existing surface
has registered consumers + tests). **Midaz remains the single ledger SoT (ADR-013); `GLService` is the
canonical posting seam via `LedgerPort`.**

The MIG-M2.5 ABS reconcile listed "abs-posting → re-home to ledger/Midaz via LedgerPort (not a 2nd
store)". The preflight confirms the **home already exists** (`GLService` + posting subsystem) → abs-posting
is **covered**, not a green-field scaffold.

## 3. Distinction (what is genuinely absent)

- **Present (do not duplicate):** double-entry GL posting via LedgerPort (`GLService`), posting models,
  posting-rule engine, Midaz adapter.
- **Possibly absent (the only candidate):** an **ABS-specific `PostingRule`** mapping legacy ABS payment
  events to GL debit/credit account types — a **config/rule addition** consuming the existing
  `PostingRuleEngine` + `GLService`, **not** a new posting port or a second ledger.

## 4. Decision required (operator/governance)

- **A — declare-covered** (mirror M2.4a): abs-posting satisfied by `GLService`/posting subsystem
  (IL-FIN-01); legacy ABS posting = retire-after; no scaffold.
- **B — thin ABS posting-rule** (mirror M2.4-INT): add an ABS `PostingRule` (legacy ABS payment-event →
  GL debit/credit account types) consuming the existing `PostingRuleEngine` + `GLService` — advisory,
  no new port, no second ledger, no live posting. Only if a distinct ABS posting mapping is required.
- **C — reconcile/gap-audit**: ADR-102 audit of legacy `abs-posting.service` vs `GLService` → delta +
  keep/merge/retire.

## 5. What was / was NOT done

- **Done (read-only):** mandatory preflight (`services/` + `api/` grep for posting/ledger_port) +
  classification of the GL/posting subsystem (IL-FIN-01); confirmed LedgerPort + `ledger.py` (Midaz live
  SoT) as consume-target; pre-checked global sys.modules fence-tests (M2.5-BIF lesson); this blocker doc
  + IL-shard (isolated worktree, Rule 1/6).
- **NOT done:** no scaffold (any repo); no `AbsPostingPort`/posting DTO; no backend PR; banxe-emi-stack
  untouched (0 `mig-abs-posting` factory branches); `ledger.py` / Midaz not touched; KYC carve-out not
  touched; no merge.

## 6. Recommended next step

Operator resolves §4 (recommend **A — declare-covered**, or **B — thin ABS posting-rule** only if a
distinct ABS event→GL mapping is product-required). Then proceed to the next ABS delta (scoring /
agreement / contract / credential / legal-entity / info-field port — each preflight-first) or
**abs-customer re-home → identity**. Correct the backlog: **abs-posting = already in emi-stack
(`GLService`/posting subsystem, IL-FIN-01).**

## References
`docs/migration/MIG-ABS-posting-BLOCKER-gl-service-already-exists.md`; read-only origin/main `3228d3d`
banxe-emi-stack `services/ledger/{ledger_models,gl_service,posting_rules,posting_models,payment_posting_service,midaz_adapter,ledger_port}.py`
+ `api/models/ledger.py` (Midaz live SoT) + `api/routers/ledger.py`; MIG-M2.5 (ABS reconcile — abs-posting
re-home target), MIG-M2.4a (declare-covered precedent), MIG-M2.4-INT (thin-integration precedent);
ADR-013 (Midaz LedgerPort canonical), ADR-102, ADR-103, ADR-059-A, I-01, I-24, I-28;
/tmp/banxe-migration-mapping-v0.claude.txt.
