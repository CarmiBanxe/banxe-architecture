---
il_ts: 2026-06-30T10:00:00Z
session_id: agent-factory-governance-reporting-style-canon
source: CEO
status: DONE
---
### Reporting-Style Canon — operator-mandated expansive academic prose for factory reports
- **Decision:** Per operator directive 2026-06-30, authored `docs/canon/REPORTING-STYLE-CANON.md` — a pointer-style behavioural canon requiring all factory reports to the operator (status reports, triage findings, audit summaries, gate/merge updates) to be written in **plain, expansive, academic language**: explain substance/causes/context in full sentences, not terse tables alone; tables may support but must be surrounded by explanatory prose. **PREPARE-ONLY**, Draft PR.
- **Relationship to existing canon:** governs PROSE STYLE only; **additive** — does NOT alter the **Best Single Artifact** canon (one artifact after output; `[CLAUDE CODE]` vs `[SHELL]` routing; no self-deviation; operator-line priority), which remains fully in force.
- **Anti-dup (ADR-102):** no dedicated reporting-style canon exists on main (the prose/academic/reporting matches in SESSION-CANON/UNIVERSAL-CANON/GLOSSARY are incidental, not a style rule); this new doc points to `AGENTS.md` / `.claude/rules/agents.md` Best-Single-Artifact canon rather than restating it. ONE new doc; no parallel canon.
- **Scope/flow:** authored per the merged #900 corrective runbook — doc + paired shard ATOMIC in one PR; NO hand-edit of the generated INSTRUCTION-LEDGER.md; NO hardcoded IL (minted by `python ledger/build_ledger.py`). ONE doc + this shard; 0 off-scope.
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 743) → IL-744 via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-06-30T10:00:00Z` > main max `2026-06-30T09:00:00Z`. Fresh worktree off origin/main `aa5cc4e` (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — canon doc + shard. **DRAFT PR; DO NOT MERGE — operator HITL.**
- **Refs:** `docs/canon/REPORTING-STYLE-CANON.md`; `AGENTS.md` / `.claude/rules/agents.md` §"CANON — Best Single Artifact"; ADR-102/119/143/144/120/060; #900 (corrective ledger-flow runbook, the flow this follows). Operator directive 2026-06-30.
