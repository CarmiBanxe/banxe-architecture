---
il_ts: 2026-07-04T20:20:03Z
session_id: agent-factory-governance-factory-operating-rules-pointer
source: agent-factory
status: PROPOSED
---

# Factory Operating Rules — pointer-doc (index only, no canon duplication)

## What

Add **one thin pointer-doc** `docs/factory/FACTORY-OPERATING-RULES.md` that indexes the
already-canonical factory operating rules. A duplication-audit (ADR-102) concluded that a fresh
standalone "factory canon" file would duplicate repo canon and drift, so this file **links only** —
it defines no rule and restates no rule body (minimal navigation preface excepted).

## Artifacts

- **NEW** `docs/factory/FACTORY-OPERATING-RULES.md` — pointer/entry-point with Source-of-Truth,
  How-to-Use, and Non-Goals sections; link-only.

## Source-of-truth it points to (unchanged, not copied)

- `.claude/rules/agents.md` (§ Factory-Only Execution, § Best Single Artifact) · `AGENTS.md` · `CLAUDE.md`
  (CENTRAL TERMINAL rules) — execution-lane.
- `docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md` — duplication gate.
- `docs/canon/software-factory-canon-v1.md` · `docs/factory/FACTORY-CANON-ADDENDUM-2026-05-12.md` — consolidated.

## Boundaries

Doc-only, prepare-only. No canon text duplicated. No ADR/rule/passport/config/runtime edit. No file
created under `~/developer` or any unversioned workspace copy. `docs/factory` had no index/shard system
to append to — none invented. No merge/push to main.

## Anchors

`docs/factory/FACTORY-OPERATING-RULES.md` · ADR-102 (duplication-verification — the rule this honours) ·
`docs/canon/software-factory-canon-v1.md`. Operator directive 2026-07-04 (author one thin pointer-doc,
link-only, one Draft PR).
