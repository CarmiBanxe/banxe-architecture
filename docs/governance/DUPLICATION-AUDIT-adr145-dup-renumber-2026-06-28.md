# Duplication Audit (ADR-102) — ADR-145 number-collision renumber (a2a → ADR-150)

**Date:** 2026-06-28 · **Scope:** resolve the live duplicate ADR-145 by renumbering the later collider · **Status:** PREPARE-ONLY (Draft PR; operator HITL via ADR-135)

## 1. Target & repo-wide search
Two ADRs shared the number **ADR-145** on `main`:
- `ADR-145-factory-project-fork-target-model.md` — merged **#852** (UTC 11:06), IL-668 — **first claim**.
- `ADR-145-a2a-inter-agent-message-contract.md` — merged **#858** (UTC 11:46, +40 min), IL-667 — **later collider**.

Per ADR-119 first-claim discipline (the established entry keeps its number; the later duplicate re-mints — never renumber the prior), the **a2a ADR renumbers**. Target = next free at execution = **ADR-150** (147=lerian-mcp, 148=adoption-pack, 149=closed-loop already taken).

## 2. Source-of-truth & every consumer
Repo-wide `grep "ADR-145"` (excluding the two 145 files) → references classified per-file:

| File | Class | Action |
|---|---|---|
| `docs/adr/ADR-146-execution-sandbox-contract.md` (3 refs) | **a2a** (ESCALATION type) | → ADR-150 ✅ |
| `docs/adr/ADR-147-lerian-mcp-central-tool-registry.md` (2 refs) | **a2a** (A1 contract) | → ADR-150 ✅ |
| `docs/agent-engine-dossier/SPRINT-PLAN.md` (8 refs) | **a2a** (A1/#858/IL-667) | → ADR-150 ✅ |
| renamed file internal self-refs (5) | **a2a** (self) | → ADR-150 ✅ |
| `docs/adr/ADR-148-handson-ai-adoption-pack-v1.md` | **factory** (#852, fork model) | **untouched** ✅ |
| `ledger/entries/**` shards (a2a-contract, fork-model, sprintplan01, sandbox-contract, adoption-pack) | **append-only** (ADR-057) | **untouched** — retain historical ADR-145 ref as immutable record |
| `INSTRUCTION-LEDGER.md` | **generated** projection | regenerated from shards (not hand-edited) |

## 3. No hidden dependency (confirmed)
- The renamed ADR keeps the same IL (IL-667) — renumber changes only the ADR-NNN identifier, not the ledger entry.
- Append-only shards intentionally retain `ADR-145` references (per ADR-057 immutability + Rule 6/7 no-foreign-session-rewrite). These are historical records of "what was true when authored"; the renumber-note in the ADR + this audit document the change. Non-breaking: they are prose/path mentions, not resolved links.
- No factory-145 reference was altered (verified: ADR-148 + all shards 0-diff).

## 4. Per-match verdict & dup resolution
- **ADR-145** now resolves to a **single** file: `ADR-145-factory-project-fork-target-model.md` (unique).
- **ADR-150** = `ADR-150-a2a-inter-agent-message-contract.md` (unique).
- **No two ADRs share a number** post-change (explicit gate in the PR).

## 5. Fail-closed / escalation
Classification was unambiguous (every changed ref is a2a-context: A2A/A1/#858/IL-667; every factory ref left intact). Append-only shards preserved. PREPARE-ONLY — no merge/push; operator HITL via ADR-135. Cross-session note: the a2a ADR belongs to another session (Sprint-A A1); only its number + live-doc references are corrected, its content is unchanged (Rule 6/7).

## Anchors
ADR-102 (Duplication Audit) · ADR-119 (first-claim / stable numbering) · ADR-142 (collision-fix precedent) · ADR-057 (append-only) · parallel-session-isolation Rule 6/7. Isolated worktree off `origin/main` eba4c98 (ADR-120); namespace ADR-060.
