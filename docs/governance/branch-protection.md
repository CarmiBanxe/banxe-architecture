# Branch Protection Policy — banxe-architecture

**IL:** IL-PROT-01 (Sprint 42)
**Effective:** 2026-04-27
**Configured via:** GitHub UI (Settings → Branches → Branch protection rules)

> This document is the canonical description of branch protection rules.
> The authoritative enforcement is in GitHub's branch protection settings.
> `gh api` is never used to configure these rules — all changes via GitHub UI only.

---

## Scope

| Branch | Protected |
|--------|-----------|
| `main` | ✅ Yes |
| `feat/*`, `fix/*`, `chore/*` | No (feature branches are ephemeral) |

---

## Required Pull Request Reviews

| Setting | Value |
|---------|-------|
| Minimum approvals required | 1 |
| Dismiss stale reviews on new push | Yes |
| Require review from CODEOWNERS | Yes (see `.github/CODEOWNERS`) |
| Restrict who can dismiss reviews | No additional restriction |

---

## Required Status Checks

All of the following checks must pass before merge is allowed:

| Check name | Workflow | Notes |
|------------|----------|-------|
| `Gitleaks - Secrets Scan` | `.github/workflows/` | Secrets detection |
| `CodeRabbit` | External | AI code review |

> Additional checks (Pytest, Ruff, Semgrep) are not applicable to this
> repo as it contains documentation and architecture artefacts only.
> If Python tooling is added in future, update this table and the
> GitHub UI settings accordingly.

---

## Branch Restrictions

| Setting | Value |
|---------|-------|
| Allow force pushes | ❌ No |
| Allow branch deletions | ❌ No |
| Require linear history (squash-only) | ✅ Yes |
| Include administrators | ✅ Yes (admins not exempt) |

---

## CODEOWNERS

Defined in `.github/CODEOWNERS`. All paths owned by `@mmber`.
Critical paths with explicit ownership:

| Path | Owner |
|------|-------|
| `*` (all files) | `@mmber` |
| `/instruction-ledger/` | `@mmber` |
| `/adrs/` | `@mmber` |
| `/compliance-experiments/` | `@mmber` |
| `/.claude/` | `@mmber` |
| `/CLAUDE.md` | `@mmber` |

---

## Rationale

- Linear history ensures a clean, bisectable `git log` on `main`.
- Admin inclusion prevents privileged bypass of required checks.
- CODEOWNERS ensures the primary maintainer reviews all IL entries,
  ADRs, and compliance experiments before they land on `main`.
- No `gh secret set` / `gh api` for protection rules — all changes
  are human-initiated via GitHub UI to maintain audit trail.

## Related

- IL-PROT-01: `instruction-ledger/sprint-42/IL-PROT-01-branch-protection-main.md`
- Counterpart: `banxe-emi-stack/docs/governance/branch-protection.md`
- IL-SEC-01: secrets posture review (Sprint 42)
- `.github/CODEOWNERS` (this repo)
