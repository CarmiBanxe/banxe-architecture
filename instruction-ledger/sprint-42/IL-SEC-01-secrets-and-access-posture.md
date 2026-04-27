# IL-SEC-01: Secrets and Access Posture Review

- Sprint: 42
- Status: PROPOSED
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: <fill after issue creation>
- Created: 2026-04-27

## Context
Sprint 41 closeout revealed that `ANTHROPIC_API_KEY` was absent from banxe-emi-stack
repo secrets, blocking the `claude-review` CI job. This is a symptom of a broader gap:
no inventory of which secrets exist in which GitHub repo, no rotation schedule, no OIDC
substitution plan where applicable. The `gh secret set` CLI command is blocked by policy;
all secret operations must go through the GitHub UI. A formal posture review is needed.

## Goal
Produce a secrets inventory and access posture document for both repositories, establish
a "secrets only via UI" rule as a documented policy, and identify where GitHub Actions
OIDC can eliminate long-lived secrets.

## Scope
- Audit of required secrets per workflow in `banxe-emi-stack/.github/workflows/`
- Audit of required secrets per workflow in `banxe-architecture/.github/workflows/` (if any)
- Identify OIDC candidates (AWS, GCP, Azure integrations if any)
- Produce `docs/security/secrets-inventory.md` in banxe-architecture
- No `gh secret set`, no secret values in code or chat, no `.env` committed

## Acceptance criteria
- [ ] `docs/security/secrets-inventory.md` committed to banxe-architecture
- [ ] Inventory table: secret name | repo | workflow | rotation policy | OIDC candidate
- [ ] Every CI workflow's secret dependencies documented
- [ ] "Secrets only via UI" policy formalised (reference to `.claude/settings.json` deny rule)
- [ ] OIDC candidates identified with migration path (even if not yet implemented)
- [ ] No secret values appear in any committed file, log, or chat message
- [ ] Gitleaks scan passes on the commit (enforced by CI)

## Implementation notes
- Approach: read workflow YAML files, extract all `${{ secrets.* }}` references
- Document format: Markdown table in `docs/security/secrets-inventory.md`
- Rotation policy template: 90-day for API keys, 180-day for service tokens
- OIDC: GitHub Actions → AWS via `aws-actions/configure-aws-credentials` OIDC provider
- `ANTHROPIC_API_KEY`: include in inventory; rotation is manual via Anthropic Console

## Risks and mitigations
- Risk: secrets in workflow YAML (e.g., hardcoded token) → Mitigation: Gitleaks scan on every commit (required check)
- Risk: stale inventory → Mitigation: inventory update required on every new workflow addition (IL lifecycle gate)
- Risk: OIDC misconfiguration grants excess privilege → Mitigation: least-privilege IAM role per workflow

## Related
- IL-REVW-01 (ANTHROPIC_API_KEY decision)
- IL-PROT-01 (Gitleaks as required check)
- `.claude/settings.json` deny rules (`gh secret set`, `cat .env*`)
- `.github/workflows/quality-gate.yml` (Gitleaks job)
- Gitleaks configuration (`.gitleaks.toml` if present)
