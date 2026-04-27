# IL-POL-01: .claude/settings.json Policy Revision (banxe-architecture)

- Sprint: 42
- Status: PROPOSED
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: CarmiBanxe/banxe-emi-stack#8
- Created: 2026-04-27

## Context
After Sprint 41 PR #9 merged, `banxe-architecture/.claude/settings.json` has a local
uncommitted modification (`M .claude/settings.json` in `git status --short`). This was
an intentional local session-only edit made during Sprint 41. The committed version in
origin/main is the canonical policy. The local diff needs to be either discarded
(`git checkout -- .claude/settings.json`) or promoted to a new feature PR if the
changes represent a genuine policy improvement.

## Goal
Resolve the local `settings.json` modification in banxe-architecture: either discard it
(restore to committed state) or produce a clean, reviewed `feat/claude-permissions-v2` PR
with an explicit diff and rationale for each change.

## Scope
- `banxe-architecture/.claude/settings.json` only
- No changes to `~/.claude/settings.json` or `banxe-emi-stack/.claude/settings.json`
- No changes to `CLAUDE.md`, `agents/*`, or any other policy files

## Acceptance criteria
- [ ] `git status --short` shows no `M .claude/settings.json` in banxe-architecture
- [ ] If discarded: `git checkout -- .claude/settings.json` run and confirmed
- [ ] If promoted: PR `feat/claude-permissions-v2` created with diff shown and owner-approved
  before merge; each added/removed rule has a one-line rationale in commit message
- [ ] Working tree clean in banxe-architecture (ignoring compliance-experiments/ untracked)

## Implementation notes
- First step: `git -C /home/mmber/banxe-architecture diff .claude/settings.json` to inspect the diff
- Decision point: if diff is trivial or accidental → discard; if intentional improvement → PR
- Branch for promotion: `feat/claude-permissions-v2` off fresh main
- Commit format: `config(permissions): <rationale> [IL-POL-01]`

## Risks and mitigations
- Risk: discarding an intended improvement → Mitigation: always show diff to owner before discarding
- Risk: policy file drift across three settings files → Mitigation: IL-POL-01 tracks only banxe-architecture; each repo has its own policy IL if needed

## Related
- Sprint 41 PR #9 (original settings.json commit)
- `banxe-architecture/.claude/settings.json` (current local state)
- IL-SEC-01 (secrets and access posture)
