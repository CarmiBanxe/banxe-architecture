# IL-CANON-04 | OPEN | P1 | Best-decision rule for Claude Code (layer 3 of 4-layer canon) | — | 2026-05-05

## Summary

Formalises the third layer of the four-layer Claude Code execution canon: **best-decision
autonomy** for tasks that fall outside the auto-run whitelist and outside the stop-barrier.

Without this layer Claude Code asks unnecessary questions for unambiguous work, breaking
flow and contradicting canon Rule 5 (WHEN IN DOUBT: pick faster, more idempotent approach).

## Scope of change

| File | Change |
|------|--------|
| `.claude/rules/approval-rules.md` | New section `## Правило неоднозначности (best-decision)` after `## Правило продолжения:` |
| `CLAUDE.md` (§1) | New governance canon item 12 — best-decision canon |
| `instruction-ledger/IL-CANON-04-best-decision-rule.md` | This file |

## Four-layer canon (reference)

| Layer | Document | Rule |
|-------|----------|------|
| 1 — Auto-run whitelist | approval-rules.md §Автоматически одобрено | execute without asking |
| 2 — Stop-barrier | safety-rules.md + CLAUDE.md §11 | STOP + OPERATOR_RUN |
| **3 — Best-decision** | **approval-rules.md §Правило неоднозначности** | **pick best, continue** |
| 4 — Session canon | MetaClaw/.claude/CLAUDE_CODE_CANON.md | sprint-level defaults |

## Related artefacts

- ADR-024: (agent autonomy level definitions)
- ADR-025: agent interaction canon + G-CANON-01
- ADR-026: Guardian third-family agent.bash
- `.claude/rules/approval-rules.md` — auto-run whitelist and stop-barrier
- `.claude/rules/safety-rules.md` — safety and compliance stop conditions
- `CLAUDE.md §1` governance canons 1–12
- `CLAUDE.md §11` — production-state mutation gate

## Acceptance criteria

- [ ] `approval-rules.md` contains both `## Правило продолжения:` and `## Правило неоднозначности (best-decision)`
- [ ] `CLAUDE.md` contains a line starting with `12. Best-decision канон:`
- [ ] This file exists at `instruction-ledger/IL-CANON-04-best-decision-rule.md`
- [ ] No other files changed in this PR

## Status history

| Date | Status | Note |
|------|--------|------|
| 2026-05-05 | OPEN | Patch applied, pending operator review and merge |
