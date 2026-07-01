---
il_ts: 2026-07-02T01:00:00Z
session_id: agent-factory-govBusinessProcess-correct-subject
source: factory
status: DONE
parent_il: IL-122-INTENT-FIRST-CANON-2026-06-07
---

### IL — Commit-subject correction: e5a2c88 labels [IL-792] but canonical ledger IL = 793

- **Type:** Errata / commit-subject correction (append-only per I-24).
- **Affected commit:** `e5a2c8844490a354b65703ef3a1a692792f96790`
  Subject: `docs(governance): business process repository [IL-792] (#943)`
- **Root cause:** Auto-merge on PR #943 fired with the queued commit subject `[IL-792]`,
  which was set before the branch was rebased a final time (each successive main advance
  forced a re-mint: IL-790 → IL-791 → IL-792 → IL-793). The auto-merge subject was not
  updated to match the final re-minted IL. Git history on `main` is immutable post-merge.
- **Canonical truth (machine-authoritative):**
  - `ledger/IL-SEQUENCE.json`: `agent-factory-govBusinessProcess-v1__e52fce87e956 → 793`
  - `INSTRUCTION-LEDGER.md` line 22800: `### IL-793 - agent-factory-govBusinessProcess-v1`
  - Shard file: `ledger/entries/agent-factory-govBusinessProcess-v1/IL-2026-07-02T00-00-00Z--business-process-v1.md`
  All three are correct. The commit subject `[IL-792]` is a label-only error.
- **Impact:** Zero. `IL-SEQUENCE.json` and `INSTRUCTION-LEDGER.md` are the authoritative
  sources for IL assignment. The commit subject is metadata only and does not affect
  ledger integrity or collision-safety. `build_ledger.py --check` passes on main.
- **Correction:** This entry supersedes the subject label. Future references to the
  business process repository artifact must use **IL-793** (not IL-792).
- **Refs:** IL-793 (canonical business process repository entry); ADR-045 §D7.3 (CLOSED);
  I-24 (append-only — no rewrite of merged commit permitted).
