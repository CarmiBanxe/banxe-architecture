---
il_ts: 2026-06-27T11:00:00Z
session_id: agent-factory-legalsep-fix-canon-scripts
source: CEO
status: DONE
---
### fix(canon): drop FR_MODULE.md refs from canon scripts post legal-separation (PR #820 follow-up)

- **Instrukciya:** PR #820 (IL-603) removed `canon/modules/FR_MODULE.md` from banxe-architecture as part of PLAN_LEGAL_SEPARATION_2026-05-20. Four canon scripts still hard-referenced that file and now fail for LEGAL/mixed profiles. Fix all 4 with minimal diffs: remove FR_MODULE checks/cp lines, add one-line comment per script, ledger shard, build_ledger --check exit 0. Open PR (no merge). ADR-060 branch.
- **Preflight (read-only):** Branch `agent/factory/legalsep/fix-canon-scripts` (id=`legalsep`, ADR-060 compliant). Worktree HEAD = `7cc209b` (PR #820 merge commit = origin/main). Max il_ts on main = 2026-06-27T10:30:00Z (IL-603). This shard il_ts = 2026-06-27T11:00:00Z (strictly greater). Max IL = 603; this shard will receive IL-604.
- **canon_preflight.sh (MODIFIED):** Removed 4-line FR_MODULE LEGAL-profile check block (lines 18-21). Replaced with 2-line comment: LEGAL profile passes without FR_MODULE.md.
- **check-canon.sh (MODIFIED):** Removed `"modules/FR_MODULE.md"` from REQUIRED_FILES bash array (line 29). Replaced with one-line comment.
- **sync-to-project.sh (MODIFIED):** Removed `cp "$CANON_DIR/modules/FR_MODULE.md" "$DEST/modules/"` from both `legal` case (line 62) and `mixed` case (line 68). Updated `legal` echo from "LEGAL + FR_MODULE добавлены" → "LEGAL добавлен". One-line comment added in each case.
- **activate-profile.sh (MODIFIED):** (1) Help text line 21: removed FR_MODULE from module list, appended "FR_MODULE → legal-reference-fr". (2) banxe INACTIVE_MODULES: removed FR_MODULE. (3) legal ACTIVE_MODULES: removed FR_MODULE. (4) mixed ACTIVE_MODULES: removed FR_MODULE. (5) legal-rules echo line 84: updated to "FR_MODULE (french law) relocated to legal-reference-fr". One-line comment added in each case.
- **Proof:** 4 files changed (14 ins / 13 del), 0 functional LOC added. `build_ledger.py` → INSTRUCTION-LEDGER.md + IL-SEQUENCE.json regenerated. `build_ledger.py --check` exit 0. Semgrep 0 findings. Branch per ADR-060.
- **Status:** DONE — 4 scripts fixed; LEGAL/mixed profiles no longer fail due to missing FR_MODULE.md. DO NOT MERGE — operator review required.
- **Refs:** `canon/scripts/canon_preflight.sh` (modified); `canon/scripts/check-canon.sh` (modified); `canon/scripts/sync-to-project.sh` (modified); `canon/scripts/activate-profile.sh` (modified); PR #820 (source of regression); IL-603 (FR_MODULE legal-sep); ADR-140 (GAP-085 reference in comment); ADR-056/057/060 (ledger/branch conventions).
