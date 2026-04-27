# IL-PROT-01: Branch Protection on main (Both Repos)

- Sprint: 42
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: CarmiBanxe/banxe-emi-stack#9
- Created: 2026-04-27

## Context
Neither `CarmiBanxe/banxe-architecture` nor `CarmiBanxe/banxe-emi-stack` currently has
branch protection rules enforced on `main`. Direct pushes are blocked by `.claude/settings.json`
deny rules locally, but GitHub itself does not enforce PR requirements or status check gates.
This means the CI quality gate is advisory-only at the repo level.

## Goal
Enable branch protection on `main` in both repositories via GitHub repository settings (UI only,
no CLI secret operations), so that GitHub itself enforces the quality gate independent of
local Claude Code policy.

## Scope
Required status checks to include:
- `Pytest (coverage >= 80%)` — banxe-emi-stack only
- `Ruff lint + format` — banxe-emi-stack only
- `Semgrep (banxe-rules)` — banxe-emi-stack only
- `Gitleaks - Secrets Scan` — both repos
- `Biome lint + format (Frontend)` — banxe-emi-stack only
- `Vitest (frontend)` — banxe-emi-stack only
- `CodeRabbit` — both repos (if active)

Additional rules:
- Require at least 1 PR review before merge
- Dismiss stale reviews on new push
- Restrict force-push (deny)
- Restrict branch deletion

## Acceptance criteria
- [ ] banxe-architecture main: force-push denied, branch delete denied, 1 review required
- [ ] banxe-emi-stack main: all 6 status checks required, force-push denied, 1 review required
- [ ] No direct push to main bypasses GitHub protection
- [ ] Settings configured via GitHub UI (Settings → Branches → Branch protection rules)
- [ ] Documented in `docs/adr/ADR-branch-protection.md` (or equivalent)

## Implementation notes
- Configure via GitHub UI: Settings → Branches → Add branch protection rule → `main`
- `claude-review` check: include only after IL-REVW-01 decision is made
- For banxe-architecture: fewer CI jobs, simpler rule set (Gitleaks + 1 review minimum)
- OIDC consideration: if using GitHub Actions OIDC, ensure protection rules don't break token flow

## Risks and mitigations
- Risk: required checks block merge if flaky → Mitigation: mark flaky checks as advisory initially
- Risk: single-owner repo, review requirement blocks self-merge → Mitigation: allow owner override or use CODEOWNERS

## Related
- IL-REVW-01 (claude-review decision affects required check list)
- `.claude/settings.json` deny rules (local enforcement layer)
- `.github/workflows/quality-gate.yml`
