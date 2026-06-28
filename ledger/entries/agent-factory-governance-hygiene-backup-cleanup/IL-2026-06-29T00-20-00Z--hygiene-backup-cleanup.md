---
il_ts: 2026-06-29T00:20:00Z
session_id: agent-factory-governance-hygiene-backup-cleanup
source: CEO
status: DONE
---
### Hygiene cleanup — remove 2 stale `.sync-backup-20260406-*` dirs (ADR-102 Duplication Audit)
- **Decision:** Removed `.sync-backup-20260406-035133/` + `.sync-backup-20260406-035847/` (16 tracked files, 136 K total) — frozen 2026-04-06 snapshots whose live canonical originals all exist (`AGENTS.md`, `docs/COLLAB.md`, `docs/subagent-patterns.md`, `ruflo/config.yaml`, `ruflo/start-ruflo.sh`, `scripts/aider-banxe.sh`, `scripts/check-agent-instructions.sh`, `scripts/parallel-verify.sh`). **PREPARE-ONLY**, Draft PR.
- **Fail-closed verify (passed):** all 16 files have a live original (some identical, some live-newer = expected stale snapshot); repo-wide `git grep "sync-backup-20260406"` → **0 executable/config consumers**; the only 3 references are append-only historical ledger prose (one past grep-record + two self-labelling the dirs as "frozen snapshots, NOT updated") → non-breaking, remain accurate after removal.
- **Out of scope (explicitly KEPT):** `.canon/` (active-profile synced layer — `.active-profile`/`.synced-at`, NOT a duplicate); empty `instruction-ledger/sprint-53/ADR-059-A-…composition.md` (consumer at GLOSSARY.md:45 → separate governance decision, NOT touched).
- **Audit doc:** `docs/governance/DUPLICATION-AUDIT-sync-backup-cleanup-2026-06-28.md` (ADR-102 five-step: repo-wide search → source-of-truth per file → no-hidden-dependency → per-match DELETE verdict → fail-closed).
- **Canon:** Rule 6/7 (2026-04-06 debris, not an active/foreign session); deletion authorized by operator. NO merge/push-to-main; NO `.canon/`/FROZEN touched.
- **Proof:** IL **provisional, NOT hardcoded** (ADR-119 Rule 8) — `build_ledger` mints max+1 over origin/main (max 695) → IL-696 via central allocator (ADR-143/143-A); unique, 0 dups; orphan-gate 1:1 (ADR-144). Append-only (ADR-059-A): ONE tail shard, il_ts `2026-06-29T00:20:00Z` > origin/main max `2026-06-29T00:05:00Z`. Isolated worktree off origin/main `f0f039a` (ADR-120); namespace ADR-060. FROZEN untouched.
- **Status:** DONE — removal + ADR-102 audit + shard. **DRAFT PR; DO NOT MERGE — operator HITL via ADR-135.**
- **Refs:** `docs/governance/DUPLICATION-AUDIT-sync-backup-cleanup-2026-06-28.md`; ADR-102/119/120/143/143-A/144/059-A/060; GLOSSARY.md:45 (out-of-scope consumer). Operator HITL.
