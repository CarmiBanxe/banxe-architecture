# Duplication Audit (ADR-102) — a2a→ADR-150 renumber completion (residual live-canon refs)

**Date:** 2026-06-28 · **Scope:** finish the #876 renumber by correcting 7 residual A2A-contract references · **Status:** PREPARE-ONLY (Draft PR; operator HITL via ADR-135)

## 1. Context — why this corrective exists
The a2a-contract ADR was renumbered **ADR-145 → ADR-150** in PR #876 (first-claim discipline; the canonical ADR-145 is `ADR-145-factory-project-fork-target-model.md`, #852). That sweep updated `ADR-146`/`ADR-147`/`SPRINT-PLAN.md` but **missed two live-canon files**, because its classification grep used `grep --include=*.md` — which **skipped `planner.yaml` (.yaml)** entirely and did not enumerate `intent-layer-masks.md`. Result: those two files still called the A2A contract "ADR-145", which now (incorrectly) collides with the factory⊕project model.

## 2. Target & repo-wide search (suffix-agnostic, the lesson applied)
Search used **all extensions** (NOT `*.md`-only):
```
git grep "ADR-145" -- docs/ | grep -iE 'a2a|A2AMessage|inter-agent|message contract|envelope'
```
This is the corrected sweep that would have caught the miss in #876.

## 3. Per-reference verdict (every changed line is A2A-context)
| File | Line | Before → After | A2A-context? |
|---|---|---|---|
| `docs/canon/intent-layer-masks.md` | 7 | `ADR-145 (A2A contract)` → `ADR-150 (A2A contract)` | ✅ |
| | 86 | `…via A2A; ADR-145 contract` → `ADR-150 contract` | ✅ |
| | 128 | `ADR-145 A2A message envelope` → `ADR-150 …` | ✅ |
| | 131 | `ADR-145 A2A contract must be ACCEPTED` → `ADR-150 …` | ✅ |
| | 140 | `ADR-145: A2A Inter-Agent Message Contract` → `ADR-150: …` | ✅ |
| `docs/canon/passports/planner.yaml` | 39 | `contract: ADR-145 A2AMessage types` → `ADR-150 …` | ✅ |
| | 40 | `A2A routing per ADR-145` → `…per ADR-150` | ✅ |

**Decision per match: UPDATE → ADR-150.** Verified pre-fix that **every** `ADR-145` occurrence in both files is A2A-context (the non-A2A sanity grep returned ∅) — so none was skipped and none mis-targeted.

## 4. What is NOT touched (positively confirmed)
- **Factory⊕project ADR-145 references** (the canonical model, #852) — **untouched** (none exist in these 2 files; verified ∅).
- **Append-only ledger shards** (ADR-057) — **untouched** (0 edits under `ledger/`).
- **`ADR-049`** (intent layer) and **`ADR-048`** references — **untouched** (verified still present).
- **0 edits outside the 2 files / 7 lines.**

## 5. Fail-closed / completeness
Post-fix suffix-agnostic re-grep → **0 remaining STALE/functional A2A↔ADR-145** references in consuming docs. The only 4 matches repo-wide are **intentional historical documentation** that MUST be preserved (changing them would erase the record of the renumber):
- `docs/adr/ADR-150-a2a-inter-agent-message-contract.md:8` — the **renumber-note** itself ("from duplicate **ADR-145** → **ADR-150**"), which by design records the prior number.
- `docs/governance/DUPLICATION-AUDIT-adr145-dup-renumber-2026-06-28.md` (×3) — the **#876 audit** that documents the ADR-145 collision and the move to ADR-150 (historical record; same immutability rationale as append-only shards).

These are documentary, not functional references — no consumer resolves "ADR-145" to mean the A2A contract anymore. The renumber is now complete. PREPARE-ONLY — no merge/push; operator HITL via ADR-135.

## 6. Changelog for the renumber canon (process lesson)
> **Renumber sweeps MUST be suffix-agnostic (NOT `--include=*.md`-only).** The #876 miss was caused by restricting the back-ref grep to `*.md`, which silently skipped `planner.yaml`. Any future ADR/IL/ordinal renumber back-ref sweep MUST grep **all tracked extensions** (`.md`, `.yaml`, `.yml`, `.json`, `.sh`, …) and verify `0 remaining` with the same all-extensions pattern before closing.

## Anchors
ADR-102 (Duplication Audit) · ADR-119/142 (first-claim collision-fix) · ADR-057 (append-only) · #876 (`DUPLICATION-AUDIT-adr145-dup-renumber-2026-06-28.md`, the renumber this completes) · ADR-150 (`ADR-150-a2a-inter-agent-message-contract.md`). Isolated worktree off `origin/main` abae680 (ADR-120); namespace ADR-060.
