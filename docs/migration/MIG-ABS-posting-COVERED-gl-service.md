# MIG-ABS-posting — COVERED by existing GL/posting subsystem (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-ABS-posting-COVERED-gl-service.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. Resolves the MIG-ABS-posting blocker (PR #648 / IL-404) per operator decision A (declare-covered). -->

> **Resolves** the MIG-ABS-posting blocker (double-entry GL posting via LedgerPort already exists;
> PR #648 / IL-404). **Operator decision (2026-06-21): A — declare-covered.** The mounted `GLService` /
> posting subsystem (IL-FIN-01) satisfies the abs-posting delta. **No scaffold, no code, no merge.**

## 1. Decision

- **ABS delta `abs-posting`: CLOSED — done-by-existing.** Covered by the `services/ledger/` GL/posting
  subsystem. **No new posting port / no second ledger.**
- **`GLService` (IL-FIN-01) = canonical posting seam via `LedgerPort`**; **Midaz = single ledger SoT
  (ADR-013)**.
- **Legacy `abs-posting.service` = RETIRE after** (covered; merge-then-retire per MIG-M1.2 ABS lineage).

## 2. Covering surface (on main, IL-FIN-01)

| Capability | Covered by |
|---|---|
| Double-entry models (debit/credit, balanced) | `services/ledger/ledger_models.py` — `Posting` (Decimal I-01), `JournalEntry` (**sum debits == sum credits per currency**), PostingDirection/Status |
| GL posting via LedgerPort | `services/ledger/gl_service.py` — `GLService.post_journal_entry()` consumes `LedgerPort`; `UnbalancedEntryError`; high-value approval |
| Payment→posting mapping | `services/ledger/payment_posting_service.py` (`PaymentEvent`→`PostingRule`) + `posting_rules.py` (`PostingRuleEngine`) |
| Ledger adapter (single SoT) | `services/ledger/midaz_adapter.py` (Midaz, ADR-013) + `inmemory_ledger.py` |
| Consumers | `api/routers/ledger.py`, `api/deps.py`, `services/recon/midaz_reconciliation.py` |

The double-entry + balance-invariant + LedgerPort + Midaz machinery is already implemented and consumed
— a parallel ABS posting port would duplicate it (ADR-102).

## 3. Residual (deferred, optional — not part of "covered")

The only candidate ABS-specific slice is an **ABS `PostingRule`** (legacy ABS payment-event → GL
debit/credit account types) added to the existing `PostingRuleEngine` and posted via `GLService` — a
**rule/config addition**, **not** a new port or a second ledger, and **not** live posting. Deferred,
optional, only if a distinct ABS event→GL mapping is product-required (tracked under the GL posting-rule
family, advisory, operator-gated for any live activation).

## 4. Backlog update

- **abs-posting** → already in emi-stack (`GLService`/posting subsystem, IL-FIN-01); removed from the
  ABS-delta scaffold backlog.
- **Remaining ABS delta:** scoring / agreement / customer-contract / credential / legal-entity /
  info-field / process+cron port (each **preflight-first** — may also be covered) · **abs-customer
  re-home → identity** (consume existing customers surface).
- (Sibling backlog unchanged: M2.4c–e OB delta · M2.3 auth delta · KYC/KYB/AML pending I-27 · M2.8
  frontend after roster audit.)

## 5. What was / was NOT done

- **Done (read-only):** mandatory preflight + ADR-102 audit (blocker #648); this covered-note + IL-shard.
- **NOT done:** no scaffold (any repo); no `AbsPostingPort`/posting DTO; no backend PR; banxe-emi-stack /
  `ledger.py` / Midaz untouched; KYC carve-out not touched; no merge.

## 6. Recommended next step

Proceed to the next ABS delta — recommend **abs-customer re-home → identity** (consume the existing
mounted `customers.py` / `customer_lifecycle.py` identity-core surface; mandatory preflight first — likely
covered/reconcile) **or** an ABS sub-service port (scoring / agreement / contract — preflight-first).
KYC/KYB/AML stays gated on **I-27 HITL-L4 sign-off**; M2.8 frontend stays gated on the **roster audit**.

## References
`docs/migration/MIG-ABS-posting-COVERED-gl-service.md`; `MIG-ABS-posting-BLOCKER-gl-service-already-exists.md`
(IL-404, PR #648); read-only origin/main banxe-emi-stack `services/ledger/{ledger_models,gl_service,
posting_rules,posting_models,payment_posting_service,midaz_adapter,ledger_port}.py` + `api/models/ledger.py`
+ `api/routers/ledger.py`; MIG-M2.5 (ABS reconcile — abs-posting re-home target), MIG-M2.4a (declare-covered
precedent), MIG-M2.4-INT (thin-integration precedent); ADR-013 (Midaz LedgerPort canonical), ADR-102,
ADR-103, ADR-059-A, I-01, I-24, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
