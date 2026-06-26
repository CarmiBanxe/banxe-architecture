---
il_ts: 2026-06-27T07:30:00Z
session_id: agent-factory-sub-b-e10-auth-orphan-exec
source: CEO
status: DONE
---
### E10 consolidation wave-1 EXECUTION — auth-legacy orphan deletion (sca/totp DELETED; role_guard ABORTED-PARKED)

- **Objective:** Operator-authorized destructive consolidation E10 — delete verified-orphan legacy auth modules. Mandatory pre-execution re-verify on fresh origin/main; per-module abort on any blocker. EMI runtime branch; sub-B does NOT push/PR/merge.
- **Re-verify (read-only shell, origin/main @ b54e10f — evidence, not memory):** sca+totp = CLEAN (0 non-test/non-self refs; 0 re-export in auth/legacy/__init__.py; 0 DI-wiring; imported ONLY by dedicated tests; totp ref'd intra-cluster only by sca; otp_fake.py only docstring-mentions, no import). role_guard = BLOCKED — non-dedicated live test consumer tests/test_wave_a_adapter_seam_scaffold.py imports LegacyRoleGuard/make_legacy_role_guard (L117/124/133), NOT in deletion-set → deleting role_guard would break repo test-collection.
- **Executed (emi branch agent/factory/consolidation/auth-legacy-orphans, commit 998040a, %G?=N):** git rm services/auth/legacy/legacy_sca_adapter.py + legacy_totp_adapter.py + tests/test_legacy_sca_adapter.py + test_legacy_totp_adapter.py. __init__.py untouched (no re-export). role_guard + its dedicated test NOT deleted (aborted).
- **Gates (all pass, recorded in commit body):** pytest --collect-only green (no import errors); pytest -k auth = 185 passed/0 failed; 0 residual refs to deleted modules; ruff clean; semgrep banxe-rules exit 0; no secrets in diff. ADR-102: removal of verified-orphan duplicates of retired auth-legacy layer; source-of-truth = production auth (non-legacy); no consumer blocks. I-20/I-24 (auth contour) preserved — no live auth path touched.
- **Abort report:** role_guard re-classified PARKED (was DELETE-ELIGIBLE-WITH-TEST). Operator-decision needed: handle tests/test_wave_a_adapter_seam_scaffold.py role_guard usage first (it is a non-orphan scaffold consumer), OR keep role_guard PARKED. Per-module re-verify protocol honored (verify-before-delete; fail-closed on the blocked module).
- **PLAN §1A flip:** sca/totp DELETE-AS-PAIR-CANDIDATE → ✅ DELETED (998040a); role_guard DELETE-ELIGIBLE-WITH-TEST → BLOCKED→PARKED (re-verify). Wave-2 итог + table updated.
- **Perimeter / canon:** EMI deletion on isolated branch (signed-attempt %G?=N — required_signatures=false, non-blocking); other legacy modules (otp/jwks/jwt) untouched (live consumers, PARKED); arch IL+PLAN on .wt-paybis; sub-B does NOT push/PR/merge (§71) — hands to MAIN. banxe-architecture origin/main IL max=561; provisional IL = max+1 frozen-at-merge (Rule 8).
- **Deliverable:** emi commit 998040a (sca/totp deletion); PLAN §1A flip; this IL shard.
- **Refs:** emi 998040a (branch agent/factory/consolidation/auth-legacy-orphans @ origin/main b54e10f); PLAN §1A E10 Wave-2; tests/test_wave_a_adapter_seam_scaffold.py (role_guard blocker); ADR-102; IL-558/559 (E10 audit + I-27 park); ADR-119/I-28; I-20/I-24.
