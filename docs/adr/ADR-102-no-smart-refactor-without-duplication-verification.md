---
id: ADR-102
title: No smart refactor without repo-wide duplication verification (mandatory Duplication Audit)
status: ACCEPTED
date: 2026-06-16
accepted: 2026-06-16
supersedes: []
related:
  - "ADR-056-ledger-coupling.md (artefact-coupling precedent for mandatory steps)"
  - ".claude/rules/agents.md (agent orchestration rules — hard rule added there)"
  - "AGENTS.md (developer-core canon — hard rule referenced there)"
il_anchor: IL-247
scope: BANXE-only
concept_only: false
---

# ADR-102: No smart refactor without repo-wide duplication verification

**Status:** ACCEPTED — 2026-06-16
**IL:** IL-247
**Applies to:** Claude Code, MetaClaw/OpenClaw, and every fleet agent that performs
code changes. This is a **hard rule** (a STOP-barrier), not a guideline.

## Context

"Smart refactors" — restructuring, moving modules, deleting code, or deduplicating —
are high-risk when a codebase has hidden duplicates (parallel implementations, copied
DTOs/helpers, near-identical SQL or migration fragments, forked docs). Merging or
deleting one copy without finding the others silently breaks consumers, drops a
needed variant, or resurrects a removed behaviour. The migration track (legacy
`BANXE.RAR` → EMI) makes this acute: large legacy bases are full of duplication.

## Decision

**Hard rule: "No smart refactor without repo-wide duplication verification."**

Before ANY structural change — restructuring, moving modules, deleting code, or
deduplication — the agent MUST complete the **Duplication Audit** protocol and record
its result in the task/ADR artefact. No structural change may merge without it.

### Mandatory Duplication Audit protocol (all five steps)

1. **Search repo-wide** (semantic + textual) for duplicate implementations,
   interfaces, DTOs, helpers, SQL, migration fragments, and docs related to the
   target. Cover all repos in scope, not just the file being edited.
2. **Identify the source-of-truth** and **every consumer** of each duplicate found.
3. **No delete/merge is permitted until** the absence of hidden dependencies is
   positively confirmed (consumers enumerated and checked).
4. **Attach a "Duplication Audit" section** to the task/ADR with: the matches found,
   the decision per match (**keep / merge / delete**), and the risks.
5. **If in doubt → fail-closed and escalate to a human.** Uncertainty about a hidden
   consumer blocks the refactor; it does not get a best-guess.

### Where the rule lives

- `AGENTS.md` (developer-core canon) — the hard rule + pointer to this ADR.
- `.claude/rules/agents.md` — the rule as a STOP-barrier in the agent orchestration
  rules, with the five-step protocol.

## Consequences

- **Positive:** structural changes can no longer silently drop or fork a needed
  variant; every merge/delete carries an auditable Duplication Audit.
- **Cost:** a mandatory verification step before refactors — intended friction.
- **Enforcement:** a refactor PR without a "Duplication Audit" section is incomplete;
  reviewers (human or agent) reject it. Fail-closed on doubt.

## Duplication Audit (for THIS change)

This ADR adds a rule and changes no code. Repo-wide check for an existing
duplicate/equivalent rule: none found in `docs/adr/`, `.claude/rules/`, or `AGENTS.md`
(searched `duplicat*` / "smart refactor" / "source of truth"). Decision: **keep**
(new rule); no merge/delete; risk: none (additive governance).

## References

- `.claude/rules/agents.md`, `AGENTS.md`; ADR-056 (ledger-coupling); IL-247.
