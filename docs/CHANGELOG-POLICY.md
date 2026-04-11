# CHANGELOG-POLICY.md
## Banxe AI Bank — Changelog & Versioning Policy

---

## 1. Conventional Commits Standard

All commits across both repositories MUST follow [Conventional Commits v1.0.0](https://www.conventionalcommits.org/).

### Format
```
<type>(<scope>): <description>

[optional body]

[optional footer: IL-NNN, BREAKING CHANGE, etc.]
```

### Types
| Type | When to use | SemVer impact |
|------|------------|---------------|
| `feat` | New feature for users | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | None |
| `refactor` | Code change (no feature/fix) | None |
| `test` | Adding/updating tests | None |
| `ci` | CI/CD pipeline changes | None |
| `infra` | Infrastructure changes | None |
| `chore` | Maintenance tasks | None |
| `perf` | Performance improvements | PATCH |
| `security` | Security fixes | PATCH |
| `compliance` | Regulatory changes | MINOR |
| `BREAKING CHANGE` | Footer keyword | MAJOR |

### Scopes (optional)
| Scope | Area |
|-------|------|
| `onboarding` | KYC/KYB flows |
| `payments` | SEPA/SWIFT/FPS |
| `compliance` | AML/Sanctions |
| `agents` | AI agent system |
| `ledger` | Financial ledger |
| `crypto` | Crypto block |
| `ui` | Frontend/UI |
| `api` | REST API |
| `infra` | Docker/CI/CD |
| `monitoring` | Dashboards/alerts |

---

## 2. Versioning Strategy

### Semantic Versioning (SemVer)
```
MAJOR.MINOR.PATCH
  │     │     └── Bug fixes, patches
  │     └───── New features (backward compatible)
  └─────────── Breaking changes
```

### Version Sources
| Repository | Version file | Tool |
|-----------|-------------|------|
| `banxe-architecture` | `mkdocs.yml` (via mike) | mike |
| `banxe-emi-stack` | `pyproject.toml` | commitizen |

---

## 3. Auto-Changelog Generation

### Tool: Commitizen

**Install:**
```bash
pip install commitizen
```

**Configuration (`pyproject.toml`):**
```toml
[tool.commitizen]
name = "cz_conventional_commits"
version = "0.1.0"
tag_format = "v$version"
changelog_file = "CHANGELOG.md"
update_changelog_on_bump = true
major_version_zero = true
```

**Commands:**
```bash
# View current version
cz version

# Generate/update CHANGELOG.md
cz changelog

# Bump version + update changelog + create git tag
cz bump --changelog

# Dry run (preview)
cz bump --dry-run

# Check if commits follow convention
cz check --rev-range HEAD~5..HEAD
```

### CHANGELOG.md Format (auto-generated)
```markdown
## v0.2.0 (2026-04-12)

### Features
- **onboarding**: add Sumsub IDV integration (IL-045)
- **crypto**: implement fiat-to-crypto bridge (IL-071)

### Bug Fixes
- **payments**: correct SEPA timeout handling (IL-052)

### Documentation
- add CRYPTO-BLOCK.md (IL-070)
- add JOB-DESCRIPTIONS.md (IL-080)

### Infrastructure
- add mkdocs.yml (IL-084)
- add GitHub Pages deploy workflow (IL-086)
```

---

## 4. Git Hooks Enforcement

### Pre-commit hook (commit-msg validation)
```bash
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/commitizen-tools/commitizen
    rev: v3.27.0
    hooks:
      - id: commitizen
        stages: [commit-msg]
```

### Install:
```bash
pip install pre-commit
pre-commit install --hook-type commit-msg
```

This ensures **every commit** follows conventional format. Non-conforming commits are rejected.

---

## 5. Release Process

```
1. Feature complete → all tests pass
2. cz bump --changelog → updates version + CHANGELOG
3. git push --tags → triggers CI
4. CI builds + deploys docs
5. GitHub Release created (auto from tag)
```

### Release naming:
- `v0.1.0` — Initial scaffold
- `v0.2.0` — Compliance block complete
- `v0.3.0` — Crypto block complete
- `v1.0.0` — Production-ready MVP

---

## 6. IL (Instruction Ledger) Integration

Every commit SHOULD reference its IL number in the footer:
```
docs: add CRYPTO-BLOCK.md

Complete crypto operations documentation including
Neuronext/TomPay entity relationships and flows.

IL-070
```

This creates a traceable link between:
- INSTRUCTION-LEDGER entry (task definition)
- Git commit (implementation)
- CHANGELOG entry (release notes)
- ROADMAP item (progress tracking)

---

> Document Version: 1.0 | Created: Phase 3 | I-29 (Documentation Standards)
> Last Updated: 2025-01-20 | Status: ACTIVE
> Cross-references: DEV-DOCUMENTATION-GUIDE.md, ROADMAP.md, pyproject.toml
