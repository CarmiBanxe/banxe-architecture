---
il_ts: 2026-07-03T00:59:00Z
session_id: agent-factory-od4-tx-monitor-retirement
source: factory
status: DONE
---

### T2.5 OD-4 Step 3: TX Monitor Retirement Plan — S-4 CTIO Gate

- **Instruction:** Produce governance document `governance/T2.5-OD-4-STEP3-RETIREMENT-PLAN.md` covering Phase 1 census resolution Step 3: retire vibe-coding tx_monitor after Steps 1+2 (I-01 fix + CRYPTO_FLAG port) are merged. Document must include: executive summary, preconditions (vibe PR #3 + EMI PR #269), execution plan (3 phases: deprecation, 30-day freeze, archive), coupling audit, I-01 verification, CRYPTO_FLAG migration evidence, S-4 CTIO sign-off block, timeline, references.

- **Preconditions:** vibe-coding PR #3 (I-01 fix: float→Decimal line 63) and banxe-emi-stack PR #269 (CRYPTO_FLAG port) must be merged or approved before execution. Both were OPEN as of 2026-07-03.

- **Execution (2026-07-03 by factory):**
  1. Document created: `governance/T2.5-OD-4-STEP3-RETIREMENT-PLAN.md` (286 lines). Covers all 9 sections: executive summary, preconditions (A: vibe PR #3, B: EMI PR #269), 3-phase execution plan (deprecate→freeze→archive), coupling audit (zero EMI→vibe coupling verified), I-01 fix verification (PR #3 line 63), CRYPTO_FLAG migration (PR #269), CTIO attestation template, timeline (milestone table), references (PRs, regulatory, docs).
  2. IL shard created: `ledger/entries/agent-factory-od4-tx-monitor-retirement/IL-2026-07-03T00-59-00Z--od4-tx-monitor-retirement.md` (append-only, no edits of prior shards).
  3. Validation checks:
     - Coupling audit: grep -r "from vibe|import vibe|vibe_coding" ~/banxe-emi-stack/services/ → zero matches confirmed.
     - Vibe callers identified: 4 internal (aml_orchestrator.py, banxe_aml_orchestrator.py, api.py, orchestration_tree.py).
     - I-01 status: float violation at vibe line 63 flagged for PR #3 fix.
     - CRYPTO_FLAG source: PR #269 ports signal to EMI (source-of-truth migration).
     - Semgrep: no new findings (document only, no code changes).

- **Approval gate:** S-4 CTIO sign-off required by 2026-07-15 (12-day window). Attestation template included in §7 (checkbox + signature block).

- **Timeline:**
  - 2026-07-03: Document + shard created
  - 2026-07-15: CTIO attestation deadline
  - 2026-07-16: Merge PRs #3 + #269 + governance doc (post-CTIO)
  - 2026-07-17: Mark vibe tx_monitor @deprecated (code change)
  - 2026-07-17: Freeze period starts (30 days)
  - 2026-08-03: Semgrep enforcement enabled (no new imports)
  - 2026-08-31: Archive to vibe-coding/src/compliance/deprecated/

- **Status:** DONE. IL shard append-only, zero deletions. Document ready for CTIO review and signature.

- **References:** vibe-coding PR #3, banxe-emi-stack PR #269, banxe-architecture `governance/T2.5-OD-4-STEP3-RETIREMENT-PLAN.md`, ADR-024 (deprecation protocol), I-24 (audit trail), ADR-120/121 (worktree discipline).
