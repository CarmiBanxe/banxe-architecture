# Banksy .claude Adaptation Map (GL-21 Step 2) — 2026-07-24

**BANK CORE / GL-21 ADAPTATION MAP / DOCS-ONLY / STAGED**
Classifies the 14 banxe-specific `.claude` references for Banksy context: **adapt** (strip Banxe paths/IDs → Banksy) vs **reference-only** (bank canon, not forced onto the Banksy art-layer).

**Important scope note (honest):** these 14 files are the **arch-repo's own `.claude/` governance rules** — there is **no separate Banksy handoff copy** in the F0 zone. This map is the **classification decision**; the actual per-file edits are **`[pending human ratification]`** because editing the arch repo's live canon (esp. cass15/financial-invariants) is not a Banksy-private change. GL-21 is STAGED — no live cutover.

## Classification (14)

| # | file | classification | reason |
|---|---|---|---|
| 1 | `.claude/CLAUDE.md` | adapt | project identity → Banksy identity |
| 2 | `.claude/agents/controller.md` | adapt | controller agent → Banksy-context paths |
| 3 | `.claude/commands/docs-build.md` | adapt | generic command; strip banxe paths |
| 4 | `.claude/commands/new-adr.md` | adapt | ADR command; references banxe-architecture → Banksy ADR home |
| 5 | `.claude/commands/validate-mermaid.md` | adapt | domain-agnostic; minor path adapt |
| 6 | `.claude/rules/agents.md` | adapt (partial) | agent rules; bank MLRO/HITL clauses → reference-only where bank-specific |
| 7 | `.claude/rules/cass15.md` | **reference-only** | CASS 15 = bank regulatory canon; NOT for Banksy art-layer |
| 8 | `.claude/rules/infrastructure.md` | adapt | infra rules; banxe paths → Banksy zone paths |
| 9 | `.claude/rules/parallel-session-isolation.md` | adapt | generic isolation rule |
| 10 | `.claude/rules/testing.md` | adapt | generic testing rule |
| 11 | `.claude/settings.json` | adapt | settings; strip banxe-specific hooks |
| 12 | `.claude/skills/github-navigation/SKILL.md` | adapt | generic skill |
| 13 | `.claude/skills/spec-writing/SKILL.md` | adapt | generic skill |
| 14 | `.claude/skills/testing/SKILL.md` | adapt | generic skill |

**Also reference-only (bank canon, per GL-18 handoff decision):** `financial-invariants`, `compliance-boundaries` — bank regulatory canon, not applied to the Banksy art-layer.

## Result
- **adapt:** 12 · **reference-only:** 2 (cass15 + agents.md bank-specific clauses; financial-invariants/compliance carried reference-only per handoff).
- **Edits NOT performed** on the shared arch-repo `.claude` files (they are the repo's live canon). Actual adaptation → `[pending human ratification]`; when done, it must target Banksy's own `.claude` copy, not overwrite the arch-repo canon.

---
**This does not replace legal advice.**
