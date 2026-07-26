# Feature Evaluation — awesome-hermes-skills (2026-07-21)

## Feature under review

- Source: ZeroPointRepo/awesome-hermes-skills.
- Nature: curated, install-ready directory of skills for Hermes Agent.
- Claimed scope: built-in, optional, and community skills collected in one index.
- Claimed compatibility: Hermes Agent, Claude Code, OpenClaw, Cursor, and Windsurf.

## Audit summary (high-level)

- Strategic value: HIGH for agent-factory R&D and operator productivity because it
  provides a large discovery surface for reusable skills and installation paths.
- Factory value: MEDIUM until skills are filtered through factory canon; a public
  skills index is useful, but direct bulk adoption would create quality, security,
  and governance risk.
- Banksy / EMI BANXE value: LOW by default unless a specific skill is individually
  reviewed and accepted for bank-safe use.
- Main risk: this is a registry/catalog layer, not a pre-approved factory bundle;
  every candidate skill still requires per-skill review for data handling,
  security posture, execution scope, and overlap with existing Claude Code canon.

## Initial placement

- Placement: CANDIDATE REGISTRY, not blanket ACCEPT.
- Allowed next step: use as a discovery source for candidate skills.
- Not allowed by this audit: mass-installing or canonizing the whole catalog into
  factory or EMI BANXE workflows without per-skill evaluation.

## Implementation direction

- Use awesome-hermes-skills as a scouting index.
- Extract only individually useful skills into separate feature evaluations.
- Prefer Claude Code prompt-driven review or narrowly scoped shell audits per skill
  before any repo canon, CLAUDE.md, or project-level adoption.

