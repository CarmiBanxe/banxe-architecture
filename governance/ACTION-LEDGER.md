# ACTION-LEDGER — BANXE Multi-Terminal Action Log

**Status:** Active | **Invariant:** I-24 Append-only — NEVER edit existing rows
**Source:** ADR-158 D-3 | **Governed by:** Central (arbiter)

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

### Sync-Protocol Fields (ADR-158 §F — mandatory per exchange)

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

---

## Ledger

| TIMESTAMP (UTC)      | ACTOR   | ACTION      | ARTIFACT                                       | TARGET              | OUTCOME |
|----------------------|---------|-------------|------------------------------------------------|---------------------|---------|
| 2026-07-04T20:00:00Z | FACTORY | git push    | +HEAD:feat/fix-sgrd-recon (#272 rebase)        | banxe-emi-stack     | DONE    |
| 2026-07-04T20:30:00Z | FACTORY | gh pr merge | #272 squash (safeguarding recon error paths)   | banxe-emi-stack     | OP-DENIED — operator declined gh pr merge |
| 2026-07-04T20:42:16Z | FACTORY | AUDIT       | orchestration-guard-audit                      | banxe-architecture  | DONE — 3 gaps identified (ADR-158) |
| 2026-07-04T21:00:00Z | FACTORY | git push    | agent/factory/adr158/bilateral-orchestration   | banxe-architecture  | PENDING |

---

## Invariant Reminder

- I-24: Append-only. NEVER delete or edit rows above.
- D-5 (ADR-158): Factory MUST NOT modify `~/.claude/settings.json` or merge PRs.
- A PENDING row with no OUTCOME row = action still in progress or lost — investigate before next action.
- Terminal A seeing a FACTORY PENDING row → log `PAUSE` row, coordinate before proceeding.
