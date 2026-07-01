---
name: github-navigation
description: Navigate the CarmiBanxe repos (banxe-architecture, banxe-emi-stack) — locate governance files (INSTRUCTION-LEDGER, COMPLIANCE-MATRIX, agent passports), read/search content, and review PRs. Use when finding a file, an IL entry, or reviewing a pull request.
---

# GitHub Navigation

## Repositories
- `CarmiBanxe/banxe-architecture` — architecture, IL, compliance/governance.
- `CarmiBanxe/banxe-emi-stack` — EMI stack, microservices.

## Navigation actions
- Read files (via the repo tools / `git show`, `gh` read-only views).
- Review PRs (`gh pr view` / `gh pr diff`); merge only as a deliberate, operator-gated step.
- Search: `repo:CarmiBanxe/banxe-architecture <query>`.

## Key governance files
- `INSTRUCTION-LEDGER.md` — task register (generated; see the `spec-writing` skill).
- `COMPLIANCE-MATRIX.md` — compliance mapping.
- `BLOCKED-TASKS.md` — blocked tasks.
- `PLANES.md` — strategic plans.
- `DEPARTMENT-MAP.md` — department map.
- `agents/passports/` — agent passports.

## Binding (factory canon)
- **Read-only navigation** (listing, reading, searching, `gh pr view`/`diff`) ⇒ emit a **`[SHELL]`** artifact.
- **A PR merge is a state change** ⇒ emit a **`[CLAUDE CODE]`** artifact (`.claude/rules/agents.md` — Best
  Single Artifact / Factory-Only Execution).
- No skill bypasses `quality-gate.sh` or invariants **I-01..I-28** (`.claude/rules/agents.md` — Skills
  Governance).
