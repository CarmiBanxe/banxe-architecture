# Duplication Audit (ADR-102) — SRC-09 union-consolidation (#846 + #851)

**Date:** 2026-06-29 · **Status:** PREPARE-ONLY (Draft PR; operator HITL via ADR-135; operator closes #846+#851)

## 1. Context
#846 (agenteng05) and #851 (agenteng10) both rewrote `SRC-09-preaudit-synthesis.md` from the same base —
complementary enrichments, not redundant. Closing either loses content. This unions both into one file.

## 2. Union construction (no loss)
- **Base (lines 1-150):** taken from **#851** — its fully-resolved base (all 5 `→ RESOLVED` flips: line 40
  НЕИЗВЕСТНО header, §7, ReAct/MCTS/Bayesian rows). Chosen over #846's base to preserve #851's resolution work.
- **+ #846 tail:** Agent behavior/decision canon (ADR-025, IL-CANON-04 BEST-DECISION, UNIVERSAL-CANON-TOPOLOGY, summary).
- **+ #851 tail:** ENRICHMENT + §U table (§U-1..§U-5) + §X summary.

## 3. No-duplication / no-loss verification
- Base headings appear **exactly once**: Центральный тезис ×1, ENRICHMENT ×1, Agent-behavior-canon ×1 (verified by grep).
- Both source tails captured in full (behavior-canon §151-263; §U/§X §264-415).
- `→ RESOLVED` references ("см. §U-x ниже") resolve — §U sits below the base flips.
- 415 lines total = 150 (resolved base) + 112 (#846 tail) + 153 (#851 tail incl. separator).

## 4. Scope / fail-closed
Touched ONLY `SRC-09-preaudit-synthesis.md` + the IL shard. The two source PRs (#846/#851) are **operator-closed**,
NOT force-pushed by this task (Rule 6/7). No content from either enrichment is dropped.

## Anchors
ADR-102 · ADR-119 · #846 (behavior-canon) · #851 (UNKNOWN-resolution) · SRC-09-preaudit-synthesis.md.
