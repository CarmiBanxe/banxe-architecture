# Context & scope

Install-audit for the D-GL (General Ledger core) sub-sprint of S-A6, per
`docs/architecture/D-GL-BUILD-SPEC.md` (Midaz PRIMARY / Fineract FALLBACK). Scope: locate
the GL/posting implementation in `banxe-emi-stack`, record paths + SHA, verify the
Midaz-primary/Fineract-fallback wiring against real code (not the spec's stated
assumption), verify the ABS-posting COVERED resolution against real code, and check the
spec's own "scattered 5%" consolidation-debt claim. Evidence-only; no code fixed, no spec
rewritten.

# What exists (code / config / docs — paths + SHA)

Repo: `banxe-emi-stack`, branch `agent/factory/ledgerenv/sandbox-fix`, HEAD
`26365b4500a10e33eb30fe6afb3129a8ff9f8d7a`.

- `services/ledger/ledger_port.py` — `LedgerPort` Protocol (line 27), incl.
  `post_journal_entry`/`get_balance` signatures. Last commit `362ee7463f69744a5a598f3c5934490d2e442685` (2026-06-25).
- `services/ledger/gl_service.py` — `GLService.post_journal_entry()` (line 176),
  `GLService.get_balance()` (line 170). Last commit `ebfeac693f624cc5fc1ab266accbfd01679a8909` (2026-06-25).
- `services/ledger/midaz_adapter.py` — Midaz adapter implementing `get_balance()` (lines
  114, 385). Last commit `a5bc76775719502ddb06dd7da4e19e0029b4af29` (2026-06-25).
- `services/ledger/midaz_client.py` — low-level Midaz HTTP client, incl. `get_balance()`
  (line 37).
- `services/ledger/inmemory_ledger.py` — in-memory test double implementing
  `post_journal_entry()` (line 42). Last commit `362ee7463f69744a5a598f3c5934490d2e442685` (2026-06-25).
- `services/ledger/ledger_models.py` — `Posting`, `JournalEntry`, `PostingStatus`,
  `AccountType`, `PostingDirection`, `SUPPORTED_CURRENCIES`, `BLOCKED_JURISDICTIONS`. Last
  commit `362ee7463f69744a5a598f3c5934490d2e442685` (2026-06-25).
- `services/ledger/payment_posting_service.py` + `services/ledger/posting_rules.py` —
  `PaymentEvent` → `PostingRule` engine (`PostingRuleEngine`). Last commit
  `c51709ce53e3d31155f18eb42a268dfe90507bea` (2026-04-28).
- `services/ledger/posting_models.py` — `DEFAULT_POSTING_RULES` (dict literal, line 61+),
  `PaymentEventType`, `PostingRule`.

**Chart-of-accounts:** `AccountType` enum (ASSET/LIABILITY/EQUITY/REVENUE/EXPENSE) defined
directly in `ledger_models.py` (docstring: "Chart of accounts classification") — a
hardcoded Python enum, not an external config file.

**Posting rules:** `DEFAULT_POSTING_RULES` is a hardcoded Python `dict` literal in
`posting_models.py` (e.g. `CAPTURED` → debit `CUSTOMER_FUNDS` / credit
`SETTLEMENT_PENDING`), not an external config file.

**Fineract fallback:** repo-wide search (`rg -il fineract`, all file types) found **zero**
code references anywhere in `banxe-emi-stack`. The only repo-wide mentions are in
`INSTRUCTION-LEDGER.md`, each explicitly framing it as deferred: *"Out of scope
(deferred): Fineract fallback + ledger factory"*, *"Out of scope (deferred / operator-gated):
Fineract fallback (no API ref)"* (multiple entries).

**Consumers cited by the ABS-posting COVERED note, confirmed present:**
`api/routers/ledger.py`, `api/deps.py`, `services/recon/midaz_reconciliation.py`.

**DoD test coverage (D-GL-BUILD-SPEC §5) vs actual test suite:**
`tests/test_gl_service.py` contains `test_double_entry_debit_credit_balanced` and
`test_unbalanced_entry_rejected` — functionally equivalent to the spec's
`test_journal_entry_balanced_per_currency`, but under different literal names.
`tests/test_midaz_fail_closed.py` covers Midaz-unavailable infra-failure cases. No test
named or resembling `test_fallback_swap_transparent` exists anywhere in `tests/`.

# Ledger topology & EMI-conformance notes

- Midaz is confirmed, in code, as the sole active ledger adapter: `midaz_adapter.py` +
  `midaz_client.py` are fully implemented and exercised by `gl_service.py` via
  `LedgerPort`. This matches the spec's "Midaz PRIMARY, single active source-of-truth"
  claim.
- The spec's "Fineract FALLBACK, reachable via the same LedgerPort" claim does **not**
  currently hold in code — see OPEN POINT 1 below. `LedgerPort` itself is CBS-agnostic by
  design (a second adapter class could implement it), but no such adapter exists today.
- The ABS-posting COVERED resolution
  (`docs/migration/MIG-ABS-posting-COVERED-gl-service.md`, IL-FIN-01, banxe-architecture)
  was verified against real code: every file it cites as the "covering surface"
  (`ledger_models.py`, `gl_service.py`, `payment_posting_service.py`/`posting_rules.py`,
  `midaz_adapter.py`/`inmemory_ledger.py`, plus the three consumer files) is confirmed
  present in `banxe-emi-stack`. The COVERED resolution holds by direct evidence, not text
  alone.
- The D-GL spec's own "scattered 5%" consolidation-debt framing does not match the current
  layout: all core GL/posting components live together under one directory
  (`services/ledger/`), not scattered across the repo. This part of the spec's problem
  statement appears already superseded by the current state — not evidence of unresolved
  scatter today.

# Gaps & risks (OPEN POINTS)

1. **Fineract fallback is unimplemented.** The spec's "Midaz PRIMARY / Fineract FALLBACK"
   framing, and DoD item `test_fallback_swap_transparent`, have no corresponding code,
   config, or test anywhere in `banxe-emi-stack` — confirmed by repo-wide search. This is
   already tracked as a known, deliberate deferral in `INSTRUCTION-LEDGER.md` ("operator-gated,
   no API ref"), so it is not a silent gap, but it means the ledger currently has no actual
   failover path — only Midaz.
2. **Config-as-data claim vs. hardcoded literals.** D-GL-BUILD-SPEC §3.1 states "Account
   codes/types are config-as-data (CLAUDE.md §10), not hardcoded," but both the chart-of-
   accounts classification (`AccountType` enum) and the posting-rule mapping
   (`DEFAULT_POSTING_RULES`) are hardcoded Python literals in source, not externalized
   config files. Whether this divergence is acceptable (type taxonomy vs. account
   instances) or needs remediation is not determined here.
3. **DoD test-name traceability gap (minor).** The literal test names listed in
   D-GL-BUILD-SPEC §5 (e.g. `test_journal_entry_balanced_per_currency`,
   `test_get_balance_from_committed_postings`) do not exactly match the actual test names
   in `tests/test_gl_service.py`. Functional coverage for the balance-invariant appears to
   exist; a full DoD-checklist-item-to-test 1:1 mapping was not exhaustively confirmed for
   every listed item.

# Next steps / hooks into Floor-2 rooms

- **OPEN POINT 1 (Fineract fallback):** route to the ledger/payments room for an
  operator decision on whether/when to implement the fallback adapter, consistent with
  the existing "operator-gated" framing already recorded in `INSTRUCTION-LEDGER.md`.
- **OPEN POINT 2 (config-as-data divergence):** route to the ledger/tech room for a
  decision on whether the current hardcoded enum/dict approach is intentional and
  sufficient, or whether externalization is required.
- **OPEN POINT 3 (test-name traceability):** low-priority documentation/traceability
  cleanup for the ledger room — align D-GL-BUILD-SPEC §5's named DoD tests with the
  actual test suite, or annotate the mapping explicitly.
