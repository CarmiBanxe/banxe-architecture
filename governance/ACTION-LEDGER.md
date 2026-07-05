# ACTION-LEDGER — BANXE Multi-Terminal Action Log

**Status:** Active | **Invariant:** I-24 Append-only — NEVER edit existing rows
**Source:** ADR-160 D-3 | **Governed by:** Central (arbiter)

## Purpose

Shared append-only ledger visible to all terminals (Central, Factory, Terminal A, Terminal B).
Every state-changing action MUST be recorded BEFORE execution (intent row) and after (outcome row).

## Usage Protocol

**Before action** (intent — write this FIRST):
```bash
echo "| $(date -u +%FT%TZ) | <ACTOR> | <ACTION> | <ARTIFACT> | <TARGET> | PENDING |" \
  >> ~/banxe-architecture/governance/ACTION-LEDGER.md
```

**After action** (outcome — append NEW row, do NOT edit PENDING row):
```bash
echo "| $(date -u +%FT%TZ) | <ACTOR> | OUTCOME  | <ARTIFACT> | <TARGET> | <DONE/FAIL/ABORT> |" \
  >> ~/banxe-architecture/governance/ACTION-LEDGER.md
```

**ACTOR values:** `FACTORY` | `CENTRAL` | `TERMINAL-A` | `TERMINAL-B`
**ACTION values:** `git push` | `gh pr merge` | `git rebase` | `alembic upgrade` | `schema change` | `PAUSE`

### Sync-Protocol Fields (ADR-160 §F — mandatory per exchange)

Every row MUST also include sync metadata as a follow-up annotation row (format below).
Annotation rows are append-only (I-24) and reference the action row by timestamp.

**A→Factory direction (task assignment rows):**
```
| <TIMESTAMP> | TERMINAL-A | SYNC-CTX | direction=A→F | phase=<phase> | node=<task> | a_state=<what A does> | expected=<what factory produces> | ledger_ref=<PENDING row timestamp> |
```

**Factory→A direction (response rows):**
```
| <TIMESTAMP> | FACTORY | SYNC-RPT | direction=F→A | what_done=<summary> | files=<count> | deviations=<none/list> | what_not_done=force/+HEAD:/merge/settings.json | awaiting_operator=<list> | ledger_ref=<OUTCOME row timestamp> |
```

**what_not_done** MUST always be explicitly listed, even when empty:
- `force push: NO`
- `+HEAD: refspec: NO`
- `gh pr merge: NO`
- `settings.json change: NO`

**B→A direction — specproj start and novelty-found events (ADR-160 §H-1/H-3):**
```
| <TIMESTAMP> | TERMINAL-B | NOVELTY  | <novelty-id>: <description>                   | banxe-architecture | PENDING  |
| <TIMESTAMP> | TERMINAL-B | SYNC-CTX | direction=B→A | event=novelty_found | specproj=<id> | novelty=<id> | artifact=PR-NNN | ledger_ref=<PENDING ts> |
```
For specproj_start events replace `NOVELTY` with `SPECPROJ-START`.

**LOCK / RELEASE format (ADR-160 §H-4 — shared-file single-writer lock):**
```
| <TIMESTAMP> | <ACTOR> | LOCK | file=<repo-relative path> | holder=<ACTOR> | status=HELD     |
| <TIMESTAMP> | <ACTOR> | LOCK | file=<repo-relative path> | holder=<ACTOR> | status=RELEASED |
```
Any terminal seeing `status=HELD` → write `WAIT` row; do NOT write to the locked file.
Arbiter: Factory. Decision appended to ACTION-LEDGER.

---

## Ledger

| TIMESTAMP (UTC)      | ACTOR   | ACTION      | ARTIFACT                                       | TARGET              | OUTCOME |
|----------------------|---------|-------------|------------------------------------------------|---------------------|---------|
| 2026-07-04T20:00:00Z | FACTORY | git push    | +HEAD:feat/fix-sgrd-recon (#272 rebase)        | banxe-emi-stack     | DONE    |
| 2026-07-04T20:30:00Z | FACTORY | gh pr merge | #272 squash (safeguarding recon error paths)   | banxe-emi-stack     | OP-DENIED — operator declined gh pr merge |
| 2026-07-04T20:42:16Z | FACTORY | AUDIT       | orchestration-guard-audit                      | banxe-architecture  | DONE — 3 gaps identified (ADR-158) |
| 2026-07-04T21:00:00Z | FACTORY | git push    | agent/factory/adr158/bilateral-orchestration   | banxe-architecture  | PENDING |
| 2026-07-04T22:28:08Z | FACTORY    | OUTCOME     | agent/factory/adr158/bilateral-orchestration — PR #1018 squash-merged by operator | banxe-architecture | DONE |
| 2026-07-05T00:00:00Z | TERMINAL-B | LOCK        | file=INSTRUCTION-LEDGER.md | holder=TERMINAL-B | status=HELD |
| 2026-07-05T00:00:00Z | TERMINAL-B | NOVELTY     | sp04:ADR-159 novelty-pipeline (PR #1017) | banxe-architecture | PENDING — needs rebase on origin/main post-#1018 |
| 2026-07-05T00:00:00Z | TERMINAL-B | SYNC-CTX    | direction=B→A | event=specproj_start | specproj=sp04 | branch=agent/specproj/sp04/adr-ba-novelty-pipeline | novelty=ADR-159 | ledger_ref=2026-07-05T00:00:00Z |
| 2026-07-05T00:45:00Z | FACTORY    | LOCK        | file=docs/adr/ADR-158-bilateral-orchestration-write-gate.md | holder=FACTORY | status=HELD |
| 2026-07-05T00:45:00Z | FACTORY    | LOCK        | file=governance/ACTION-LEDGER.md | holder=FACTORY | status=HELD |
| 2026-07-05T00:45:00Z | FACTORY    | git push    | agent/factory/adr158b/tri-party-sync-terminal-b | banxe-architecture | PENDING |

---

## Invariant Reminder

- I-24: Append-only. NEVER delete or edit rows above.
- D-5 (ADR-160): Factory MUST NOT modify `~/.claude/settings.json` or merge PRs.
- A PENDING row with no OUTCOME row = action still in progress or lost — investigate before next action.
- Terminal A seeing a FACTORY PENDING row → log `PAUSE` row, coordinate before proceeding.
| 2026-07-05T01:00:00Z | FACTORY | git push | agent/factory/adr158b/fix-adr160-stale-refs | banxe-architecture | PENDING |
| 2026-07-05T00:00:54Z | FACTORY | LOCK | file=docs/adr/ADR-160-bilateral-orchestration-write-gate.md | holder=FACTORY | status=RELEASED |
| 2026-07-05T00:00:54Z | FACTORY | LOCK | file=governance/ACTION-LEDGER.md | holder=FACTORY | status=RELEASED |
| 2026-07-05T00:00:54Z | FACTORY | OUTCOME | agent/factory/adr158b/tri-party-sync-terminal-b — PR #1020 squash-merged | banxe-architecture | DONE |
| 2026-07-05T00:00:54Z | FACTORY | OUTCOME | agent/factory/adr158b/fix-adr160-stale-refs — PR #1022 squash-merged | banxe-architecture | DONE |
| 2026-07-05T02:00:00Z | FACTORY | LOCK | file=governance/ACTION-LEDGER.md | holder=FACTORY | status=HELD |
| 2026-07-05T02:00:00Z | FACTORY | LOCK | file=governance/PHASE-3-SSOT-PLAN.md | holder=FACTORY | status=HELD |
| 2026-07-05T02:00:00Z | FACTORY | RELEASED | file=docs/adr/ADR-158-bilateral-orchestration-write-gate.md | reason=stale-lock-cleanup: 00:45 session ended; adr158b work merged as PR #1022 | status=RELEASED |
| 2026-07-05T02:00:00Z | FACTORY | RELEASED | file=governance/ACTION-LEDGER.md | reason=stale-lock-cleanup: 00:45 HELD from dead session (same FACTORY actor, self-resolution) | status=RELEASED |
| 2026-07-05T02:00:00Z | FACTORY | OUTCOME | push=agent/factory/adr158/bilateral-orchestration | result=MERGED as PR #1018 (2026-07-04); IL-lock was for ADR-158 file write, superseded | status=DONE |
| 2026-07-05T02:00:00Z | FACTORY | OUTCOME | push=agent/factory/adr158b/tri-party-sync-terminal-b | result=DROPPED: content absorbed into fix-adr160-stale-refs branch which became PR #1022 | status=DONE |
| 2026-07-05T02:00:00Z | FACTORY | OUTCOME | push=agent/factory/adr158b/fix-adr160-stale-refs | result=MERGED as PR #1022 (2026-07-05); stale-refs hook fix applied | status=DONE |
| 2026-07-05T02:00:00Z | FACTORY | git push | agent/factory/phase3ssot/amendment-002-003-cleanup | banxe-architecture | PENDING |
| 2026-07-05T02:00:00Z | FACTORY | LOCK | file=governance/PHASE-3-SSOT-PLAN.md | holder=FACTORY | status=RELEASED |
| 2026-07-05T02:00:00Z | FACTORY | LOCK | file=governance/ACTION-LEDGER.md | holder=FACTORY | status=RELEASED |
