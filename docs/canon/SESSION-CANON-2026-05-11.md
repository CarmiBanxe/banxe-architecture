# SESSION-CANON-2026-05-11

**Status:** Normative
**Supersedes:** operator-canon-2026-05.md (partial)
**Effective:** 2026-05-11
**Scope:** All Banxe sub-terminal sessions operating under this date canon.

---

## Clause 1 — Best-Decision Rule

Every output produced by a sub-terminal session MUST end with exactly one concrete
next step. The next step is either:
- A fully-formed Claude Code prompt ready to paste into the sub-terminal, or
- A shell command that can be copy-pasted and executed without modification.

Ambiguous, multi-option, or "you could do X or Y" endings are prohibited.

---

## Clause 2 — Decision Criteria Order

When evaluating any action or proposal, apply criteria in this order. Higher
criteria override lower:

1. **(a) Security / compliance** — FCA, UK GDPR, AML/KYC invariants, I-71..I-74,
   amendment-B.11.N+2 Статья 4.
2. **(b) Regression risk** — does the action risk breaking an existing service,
   model, or audit trail?
3. **(c) User / project impact** — does the action advance the stated project goal?
4. **(d) Implementation simplicity** — prefer the simpler path when (a)–(c) are equal.

An action that fails (a) is blocked regardless of (b), (c), or (d).

---

## Clause 3 — Tool Hierarchy

- **Claude Code = primary tool** for all file creation, editing, and structured
  reasoning tasks.
- **Shell = diagnostics and system actions only**: health checks, `git status`,
  `curl -sf`, `docker ps`, filesystem inspection. Shell must not be used to bypass
  Claude Code file-write patterns.
- Never use shell `echo >>` or `cat > file` where a Claude Code Write/Edit tool
  invocation is available and not blocked by a hook.

---

## Clause 4 — Atomic Action Rule

One step = one command or one prompt. No parallel actions in a single execution block.
Rationale: parallel actions produce interleaved output that cannot be audited as a
single logical unit, and they obscure causality when a step fails.

---

## Clause 5 — Language Boundary

| Artifact type | Language |
|---------------|----------|
| Operator prose (chat replies, status updates) | Russian |
| Technical artifacts (commits, branches, IL/GAP/Invariant IDs, prompts) | English |
| Code, config, YAML, JSON | English |
| ADR, runbook, compliance doc | English |
| Canon clauses (this document) | English |

Mixed-language artifacts are permitted only when quoting an existing artifact
in its original language within an English document.

---

## Clause 6 — Sub-terminal Authority Boundary

Sub-terminal authority is bounded by §II of the multi-terminal canon
(PROMPT-CANON-PROJECT.md §15, I-71):

**Permitted without escalation:**
- Create local branches and commits in worktrees
- Read any non-secret file in any repo
- Run diagnostic commands (git log, git status, curl health checks)
- Write documentation, ADRs, runbooks, canon files

**Prohibited — requires main factory terminal:**
- `git push` to any remote
- `gh pr create`, `gh pr merge`, `gh pr close`
- `git tag` (any form)
- Branch protection changes
- Any write to production infrastructure (evo1 model swap, evo2 config change)

Attempting a prohibited action MUST trigger Clause 7.

---

## Clause 7 — Explicit-Permission Boundary

When a sub-terminal reaches an action that is:
- Listed as prohibited in Clause 6, or
- Not covered by existing invariants, or
- Classified T6 (production-only) under amendment-B.11.N+2 Статья 4

The sub-terminal MUST:
1. **STOP** — do not execute the action.
2. **Emit** an explicit confirmation request to the operator in chat, stating:
   - The exact action that requires permission
   - The invariant or amendment that restricts it
   - The consequence of proceeding vs. deferring
3. **Wait** for operator confirmation before proceeding.

Silence from the operator = do not proceed.
