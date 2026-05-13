# ADR-039 — Claude Code permissions reclassification

**Status:** Accepted
**Date:** 2026-05-05
**Source-of-determination:** body table row `| Status | ACCEPTED |` + Status history table entry `2026-05-05 | ACCEPTED` (markdown table-form headers — not matched by INDEX generator regex `^\*\*Status:\*\*`)

| Field | Value |
|---|---|
| Status | ACCEPTED |
| Date | 2026-05-05 |
| Authors | CEO (operator) + Perplexity supervisor |
| Scope | ~/.claude/settings.json on Legion (mark-legion) |
| Reperential commit | main @ 9d53979 |
| Related | IL-CANON-04 (best-decision rule), IL-CANON-OPERATOR-2026-05, .claude/rules/approval-rules.md, .claude/rules/safety-rules.md |

## Context

В ходе аудита IL-AUDIT-01 (PRs #50, #52, #54, #55) и последующих sprint kickoffs (IL-FACTORY-AUDIT-01 PR #57, IL-PROJECT-AUDIT-01 PR #58) Claude Code блокировался на каждом `git push`, `gh pr create`, `gh pr comment` запросом approval. Это:

1. Тормозило flow аудитной серии (5+ PR за сессию).
2. Противоречило `.claude/rules/approval-rules.md` whitelist'у (`git add/commit/push` явно в auto-run).
3. Нарушало IL-CANON-04 best-decision principle (для git/gh операций, не подпадающих под stop-barrier).

Текущее состояние `~/.claude/settings.json` `permissions.ask` до правки:

```
Bash(git push *)
Bash(docker push *)
Bash(alembic upgrade *)
Bash(alembic downgrade *)
Bash(git -C * push *)
Bash(gh pr create *)
Bash(gh pr comment *)
```

## Decision

Реклассифицировать 4 git/gh правила из `permissions.ask` в `permissions.allow`, оставив 3 destructive в `permissions.ask`.

### Reclassified to `allow` (auto-run, no approval prompt)

| Rule | Layer (per 4-layer canon) | Justification |
|---|---|---|
| `Bash(git push *)` | Layer 1 — auto-run whitelist | matches `.claude/rules/approval-rules.md` "git add / commit / push — ДА"; reversible via `git revert` / new commit |
| `Bash(git -C * push *)` | Layer 1 — auto-run whitelist | semantically identical to above with explicit `-C` path; same reversibility |
| `Bash(gh pr create *)` | Layer 1 — auto-run whitelist | PR creation is non-destructive (PR can be closed without merge); branch protection prevents accidental main mutation |
| `Bash(gh pr comment *)` | Layer 1 — auto-run whitelist | comment is non-destructive metadata; no code/state change |

### Retained in `ask` (stop-barrier per Layer 2)

| Rule | Layer (per 4-layer canon) | Justification |
|---|---|---|
| `Bash(docker push *)` | Layer 2 — stop-barrier | publishes container image to registry; potential prod deployment trigger; irreversible without explicit registry rollback |
| `Bash(alembic upgrade *)` | Layer 2 — stop-barrier | DB schema mutation forward; potential prod data impact per CLAUDE.md §11 |
| `Bash(alembic downgrade *)` | Layer 2 — stop-barrier | DB schema mutation reverse; data loss possible even with downgrade scripts |

### NOT changed

- All other entries in `permissions.allow` / `permissions.deny` / `permissions.ask` remain untouched.
- Guardian-shim `enforce/closed` defaults remain unchanged (independent governance layer).
- Spec-First Auditor pre-commit hook remains active (independent guard).
- `.claude/rules/approval-rules.md` and `.claude/rules/safety-rules.md` are the canonical reference; settings.json is the local enforcement.

## 4-layer canon mapping

| Layer | Canon document | Settings.json mapping |
|---|---|---|
| 1 — Auto-run whitelist | `.claude/rules/approval-rules.md` § "Автоматически одобрено" | `permissions.allow` |
| 2 — Stop-barrier | `.claude/rules/safety-rules.md` + `CLAUDE.md` §11 + `permissions.ask` | `permissions.ask` |
| 3 — Best-decision | IL-CANON-04 (`.claude/rules/approval-rules.md` § "Правило неоднозначности") | applied within `allow` for ambiguous cases |
| 4 — Guardian audit | ADR-024/025/026 + `~/.banxe/guardian-shim/` | independent of settings.json (POST /audit on every claude.bash) |

## Backup & rollback

Backup of `~/.claude/settings.json` was created by operator on 2026-05-05 before the change:

```
cp ~/.claude/settings.json ~/.claude/settings.json.bak.20260505-<HHMMSS>
```

To rollback:

```
cp ~/.claude/settings.json.bak.20260505-<HHMMSS> ~/.claude/settings.json
```

The change takes effect on next Claude Code session start (settings.json is read at startup).

## Anchors

- IL-CANON-04 (best-decision rule)
- IL-CANON-OPERATOR-2026-05 (operator canon binding)
- `.claude/rules/approval-rules.md`
- `.claude/rules/safety-rules.md`
- `CLAUDE.md` §1, §11
- ADR-024 (Guardian Bash Shim)
- ADR-025 (Agent Interaction Canon)
- ADR-026 (Guardian third family)

## Status history

| Date | Status | Note |
|---|---|---|
| 2026-05-05 | ACCEPTED | settings.json reclassified by operator; ADR-039 created post-hoc to formalise governance decision |
