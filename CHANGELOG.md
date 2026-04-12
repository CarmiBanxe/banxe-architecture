# Architecture Changelog

All notable architecture decisions and changes to this repository.

## [2.0] — 2026-04-12

### Added
- ORG-CHART v2.0: 8 blocks, 50 AI agents, Three Lines of Defence (finalized)
- HITL-FRAMEWORK.md: L1/L2/L3 zones, confidence thresholds, override logs
- GAP-ANALYSIS-v2.md: all 7 gaps closed (CISO, MRM, HITL, TPRM, CDAO, MLRO, COO)
- AI Risk & Ethics Sub-Committee under Board (Gap 6)
- Model Risk Management (MRM) under CRO (Gap 2)
- CDAO — Chief Data & AI Officer role (Gap 5)
- TPRM — Third-Party Risk under CRO/COO (Gap 4)
- Wind-Down Planning agent (IL-065 compliance)
- ADR-001 through ADR-014 covering all major decisions
- CI/CD: MkDocs → GitHub Pages (docs.yml)
- CI/CD: Mermaid validation + gitleaks + ADR check (ci.yml)

### Changed
- CISO moved to 2LoD (under CRO/Board, NOT under CTO) — Gap 1

## [1.0] — 2026-04-10

### Added
- Initial ORG-CHART v1.0: 8 blocks, 45 agents
- GSD methodology (Phase 7 workflow: SPEC→DESIGN→IMPLEMENT→TEST→REVIEW→DEPLOY→CLOSE)
- INVARIANTS.md, PRIVILEGE-MODEL.md, COMPLIANCE-ARCH.md, SANCTIONS-POLICY.md
- SOUL-TEMPLATE.md for agent definitions
- domain/: bounded-contexts.md, context-map.yaml, orchestration-tree.md
- governance/: trust-zones, risk-mapping, Rego policies
- validators/ and scripts/ for compliance verification
- 14 initial ADRs

## [0.1] — 2026-03-01

### Added
- Repository initialized
- README.md with GSD methodology overview
- Initial stack layers documentation
