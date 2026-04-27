# IL-REVW-01: claude-review Workflow Decision

- Sprint: 42
- Status: PROPOSED
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: CarmiBanxe/banxe-emi-stack#10
- Created: 2026-04-27

## Context
The `claude-review` job in `quality-gate.yml` (banxe-emi-stack) uses
`anthropics/claude-code-action@v1` and requires `ANTHROPIC_API_KEY` as a repo secret.
During Sprint 41 closeout the secret was absent, causing the job to fail and blocking
PR merge (if set as required). CodeRabbit already provides automated PR review.
Two code-review layers are potentially redundant.

## Goal
Make an explicit architectural decision: either activate `claude-review` with
`ANTHROPIC_API_KEY` and set it as a required check, or remove the workflow as redundant
given CodeRabbit coverage.

## Scope
One of two options (to be decided by owner):

**Option A — Activate:**
- Add `ANTHROPIC_API_KEY` via GitHub UI (Settings → Secrets → Actions) in banxe-emi-stack
- Set `claude-review` as required status check in branch protection (IL-PROT-01)
- Document rationale: claude-review provides financial-domain context CodeRabbit lacks

**Option B — Remove:**
- Delete or disable `.github/workflows/claude-review.yml` (or equivalent) in banxe-emi-stack
- Update `quality-gate.yml` to remove any dependency on the job
- Document rationale: CodeRabbit + Semgrep + human review sufficient; avoid duplicate cost

## Acceptance criteria
- [ ] Decision documented in `docs/adr/ADR-claude-review.md`
- [ ] If Option A: `ANTHROPIC_API_KEY` added via UI, job passing, set as required check
- [ ] If Option B: workflow file removed, no dangling references in quality-gate.yml
- [ ] IL-PROT-01 updated with final required check list after decision
- [ ] No `ANTHROPIC_API_KEY` value ever committed to code or logged in chat

## Implementation notes
- Option A cost: ~$0.01–0.05 per PR review call (Sonnet 4.6 input tokens)
- Option B: zero ongoing cost, simpler CI surface
- If Option A: set `continue-on-error: false` after confirming key works
- Secret must be added via GitHub UI only — `gh secret set` is blocked by policy

## Risks and mitigations
- Risk (A): key rotation burden → Mitigation: document rotation procedure in runbook
- Risk (B): losing AI-assisted review layer → Mitigation: CodeRabbit + Semgrep covers majority of patterns

## Related
- IL-PROT-01 (branch protection required checks)
- IL-SEC-01 (secrets posture)
- `.github/workflows/quality-gate.yml`
- CodeRabbit configuration (`.coderabbit.yaml` if present)
