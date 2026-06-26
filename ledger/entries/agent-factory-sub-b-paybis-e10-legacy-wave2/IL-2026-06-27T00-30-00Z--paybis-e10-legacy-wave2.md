---
il_ts: 2026-06-27T00:30:00Z
session_id: agent-factory-sub-b-paybis-e10-legacy-wave2
source: CEO
status: DONE
---
### E10 legacy dup-audit RESULT (wave 2) — 18 legacy modules; verify-before-delete; NO deletion (docs-plane)

- **Objective:** Record E10 wave-2 legacy dup-audit + DELETE-candidate verification into PLAN §1A + update §5A points 3-4. Read-only shell-evidence; NO deletion/rename this step. Count correction: total */legacy/* .py (excl __init__) = 18 (verified), not 22.
- **Live audit (evidence, not memory; sub-B independent re-verification):** banxe-emi-stack origin/main — verified 18 legacy modules. The briefed "0 refs → DELETE-ELIGIBLE" for 3 candidates was REFINED by re-verification (test-coupling found): 
  1. compliance/legacy/legacy_bkyc_adapter.py = CONFIRMED ORPHAN (0 refs to any symbol BKYC*/LegacyBKYCAdapter in services/api/tests; no re-export, no test) → DELETE-ELIGIBLE clean.
  2. auth/legacy/role_guard.py = 0 production refs BUT dedicated tests/test_legacy_role_guard.py imports LegacyRoleGuardAdapter/require_roles/make_legacy_role_guard → DELETE-ELIGIBLE-WITH-TEST (delete adapter + its test together).
  3. compliance/legacy/legacy_binancekyc_adapter.py = 0 production refs (other ref = a COMMENT in _legacy_common/state_machine.py) BUT BinanceKYCError imported by shared tests/test_shared_errors.py → VERIFY-THEN-DELETE (excise that section, don't break shared error-tests).
- **Cluster:** auth/legacy/legacy_sca_adapter.py (0 external refs) + legacy_totp_adapter.py (ref'd ONLY by sca, verified) → DELETE-AS-PAIR-CANDIDATE (DI-trace first).
- **Reclassified to PARKED (NOT orphan — live symbols, operator-briefed + verified):** payment/legacy/bifrost_adapter.py (to_minor_units used by open_banking/intl_scheduled.py + m24_int_bridge.py, verified 2); payment/legacy/legacy_transactions_adapter.py (TransactionRecord → ledger/midaz_adapter.py verified 13×; TransactionApplicationError → shared/errors.py).
- **Remaining PARKED:** auth/legacy {legacy_otp_adapter, jwks_models, jwt_strategy}; compliance/legacy {_edd, _jurisdictions, legacy_sumsub_adapter}; payment/legacy {legacy_abs_payment_adapter, legacy_sepa_adapter}; ledger/legacy/legacy_crypto_* (E10 PAYBIS-cutover).
- **Key lesson (canon):** simple import-count insufficient — full-symbol+re-export+dynamic+test-ref verification flipped 4/7 import-count candidates; sub-B re-verification further refined the 3 "0-ref orphans" to test-coupled (only 1/3 clean). "Verify before delete / fail-closed on doubt" enforced.
- **§5A acceptance:** point 3 — legacy wave-2 AUDITED (18 modules); point 4 — 1 confirmed orphan + 1 delete-with-test + 1 verify-then-delete + 1 pair-candidate + rest PARKED-with-justification (no silent residue, no deletion this step).
- **Deletion-execution rule:** confirmed orphans removed in dedicated scoped track (legacy_bkyc clean; role_guard + dedicated test; legacy_binancekyc excise shared-test section; sca/totp DI-trace then pair) — full test-suite green + gitleaks clean + ADR-102 re-confirm at execution time (main moves).
- **Perimeter / canon:** docs-plane only; NO deletion/rename; FROZEN ports untouched; every verdict traceable to shell-evidence (sub-B re-verified, no invented/parroted refs); isolated worktree off arch origin/main; signed; sub-B hands to MAIN per §71/§74.
- **Deliverable:** PLAN §1A "E10 — legacy dup-audit RESULT (wave 2)" table + Deletion-execution rule + §5A points 3-4 update, this IL shard.
- **Refs:** PLAN §1A E10/_v2-wave1/§5A (IL-553/554/556/557); ADR-102 (verify-before-delete); tests/test_legacy_role_guard.py, tests/test_shared_errors.py, services/_legacy_common/state_machine.py, services/open_banking/intl_scheduled.py, services/ledger/midaz_adapter.py; ADR-119/I-28.
