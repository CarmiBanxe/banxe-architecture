# Duplication Audit (ADR-102) — Taste Rubric (advisory) A-substance

**Date:** 2026-06-29 · **Scope:** add the Taste Rubric (advisory) section to the design-system source-of-truth · **Status:** PREPARE-ONLY (Draft PR; operator HITL via ADR-135)

## 1. Repo-wide search (anti-dup)
`git grep -i taste origin/main -- docs/BANXE-UI-UX-SYSTEM.md` → **0 hits**: no taste-rubric, no advisory-bands rubric anywhere on main. The section is **genuinely new** — no duplication.

## 2. Source-of-truth & reuse (not copy)
The rubric **structures** the existing `§Design Philosophy` (5 qualities) + anti-patterns (5) + token systems (`--space-*`, `--text-*`, `--color-*`) + Component Patterns + Accessibility Rules — by **reference**, restating none of their values. Substance belongs in this doc (source-of-truth); governance pointers belong in the canon (B, later).

## 3. Per-element verdict
| Element | Verdict |
|---|---|
| Taste Rubric advisory section | **ADD** (new substance) |
| Design Philosophy / anti-patterns / tokens / patterns | **reuse by reference** — not copied, not modified |
| θ value · owner · agent activation | **NOT set** — AWAITS-OPERATOR placeholders (gate activation, not authoring) |
| B governance bindings / RACI · C capability / validator | **NOT authored here** (separate steps) |

## 4. Boundaries held / fail-closed
- **advisory-not-gate** confirmed: bands only, no numeric/θ/pass-fail; taste never blocks promotion.
- **WCAG 2.1 AA floor intact:** the section explicitly states accessibility is the hard gate and a taste band cannot waive it.
- Edited ONLY `docs/BANXE-UI-UX-SYSTEM.md` + IL shard (verified). Motion-token gap = **[НЕИЗВЕСТНО]**, not invented.

## Anchors
ADR-102 · UI-TASTE-SKILLS-AUTHORING-TRANSFER-PACKAGE.md (A→B→C) · `docs/BANXE-UI-UX-SYSTEM.md` §"Accessibility Rules" (WCAG hard floor). B (governance) will bind ADR-135/145/149 later. PREPARE-ONLY; operator HITL.
