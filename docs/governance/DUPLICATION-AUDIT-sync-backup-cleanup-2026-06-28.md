# Duplication Audit (ADR-102) — `.sync-backup-20260406-*` stale-backup removal

**Date:** 2026-06-28 · **Scope:** remove 2 tracked stale backup directories · **Status:** PREPARE-ONLY (Draft PR; operator HITL via ADR-135)

Per the **ADR-102 HARD RULE** (no structural change without a repo-wide Duplication Audit), this report
records the five mandatory steps for the removal of `.sync-backup-20260406-035133/` and
`.sync-backup-20260406-035847/`.

## 1. Target & repo-wide search
Two directories created by a sync operation on **2026-04-06** (03:51:33 and 03:58:47), tracked in git,
**68 K each (136 K total), 16 files (8 × 2)**. Each is a frozen snapshot of canonical project files.

## 2. Source-of-truth per file (every consumer enumerated)
For each of the 16 backup files the **live canonical original exists** (verified `[ -f ]` on `origin/main`,
path = backup path with the `.sync-backup-…/` prefix stripped):

| Backup file (×2 dirs) | Live canonical source | Backup vs live |
|---|---|---|
| `AGENTS.md` | `AGENTS.md` | live newer (evolved) |
| `docs/COLLAB.md` | `docs/COLLAB.md` | live newer |
| `docs/subagent-patterns.md` | `docs/subagent-patterns.md` | identical |
| `ruflo/config.yaml` | `ruflo/config.yaml` | live newer / identical |
| `ruflo/start-ruflo.sh` | `ruflo/start-ruflo.sh` | live newer / identical |
| `scripts/aider-banxe.sh` | `scripts/aider-banxe.sh` | identical |
| `scripts/check-agent-instructions.sh` | `scripts/check-agent-instructions.sh` | live newer / identical |
| `scripts/parallel-verify.sh` | `scripts/parallel-verify.sh` | identical |

**Decision per match: DELETE** the backup copy. Where the live original *differs*, it is **newer** (the
backup is a stale 2026-04-06 snapshot the live file has since evolved past) — expected and confirms the
backup carries no unique content.

## 3. No hidden dependency (positively confirmed)
- **Code/config consumers:** repo-wide `git grep "sync-backup-20260406"` on `origin/main` → **zero**
  executable/config consumers (no script, workflow, or import resolves these paths).
- **Documentary mentions (non-breaking, append-only ledger):** 3 prose references, all historical —
  `INSTRUCTION-LEDGER.md` / `ledger/FROZEN-ARCHIVE.md` (a past grep-result record) and the
  `legal-sep-remove-fr-module` shard / ledger line that **explicitly labels these dirs "frozen snapshots,
  tracked but NOT updated."** These are append-only historical records; they remain accurate after removal
  (they describe a past state) and are **not** edited by this cleanup.
- **Unique-content check:** none of the 16 files is unique (every one has a live original) → no content lost.

## 4. Per-match verdict
| Match | Verdict | Risk |
|---|---|---|
| `.sync-backup-20260406-035133/` (8 files) | **DELETE** | none — all 8 have live originals; no consumer |
| `.sync-backup-20260406-035847/` (8 files) | **DELETE** | none — all 8 have live originals; no consumer |
| `.canon/` (active-profile synced layer) | **KEEP — out of scope** | intentional (`.active-profile`/`.synced-at`); NOT a duplicate |
| `instruction-ledger/sprint-53/ADR-059-A-…composition.md` (empty) | **KEEP — out of scope** | has a GLOSSARY.md:45 consumer → separate governance decision, NOT removed here |

## 5. Fail-closed / escalation
No uncertainty about a hidden consumer remains (grep clean; the only references are self-labelled frozen
snapshots). The two **out-of-scope** items (`.canon/`, empty ADR-059-A) are explicitly preserved.
PREPARE-ONLY — no merge/push; operator HITL via ADR-135.

## Anchors
ADR-102 (Duplication Audit hard rule) · ADR-059-A / GLOSSARY.md:45 (empty-file consumer → out of scope) ·
parallel-session-isolation Rule 6/7 (no foreign-session state touched; the backups are 2026-04-06 debris,
not an active session). Isolated worktree off `origin/main` f0f039a (ADR-120); branch namespace ADR-060.
