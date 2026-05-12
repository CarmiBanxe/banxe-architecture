# ADR Index — banxe-architecture

This repo maintains TWO ADR catalogues with intentional separation:

| Directory | Numbering | Format | Purpose |
|-----------|-----------|--------|---------|
| `decisions/` | ADR-001 .. ADR-NNN (sequential, current head: ADR-017) | Prose headers (Status / Date / Deciders / Scope / Related / Context / Decision / Consequences / Compliance mapping / Enforcement / Rollout) | Canonical numbered ADRs — single source of truth for binding architectural decisions. |
| `docs/adr/` | ADR-040 .. ADR-NNN (thematic, Phase-aligned) | YAML frontmatter | Phase-specific or thematic ADRs (e.g. Phase 3 cluster: ADR-040..034). |

## Numbering gap (018–030)

The gap between ADR-017 (last in `decisions/`) and ADR-040 (first in `docs/adr/`) is **intentional and reserved** for future entries in `decisions/` so that `docs/adr/` can keep Phase-aligned numbering without future renumbering.

## Adding a new ADR

- New canonical, repo-wide architectural decision → next free number in `decisions/` (currently ADR-018+).
- New thematic Phase-3+ decision → next free number in `docs/adr/` (currently ADR-044+).
- Always update INVARIANTS.md and GAP-REGISTER.md if the new ADR introduces invariants or open gaps.

## Index (canonical decisions/)

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| ADR-001 | Privilege model | Accepted | — |
| ADR-002 | Telegram bot scope | Accepted | — |
| ADR-003 | Training developer-only | Accepted | — |
| ADR-004 | Jube AGPLv3 boundary | Accepted | — |
| ADR-005 | Marble Elastic v2 | Accepted | — |
| ADR-006 | Evidence bundle | Accepted | — |
| ADR-007 | Scenario registry design | Accepted | — |
| ADR-008 | Jurisdiction label | Accepted | — |
| ADR-009 | OpenSanctions / Yente | Accepted | — |
| ADR-010 | AMLTrix taxonomy | Accepted | — |
| ADR-011 | Reference vs dependency | Accepted | — |
| ADR-012 | Compliance API port :8093 | Accepted | — |
| ADR-013 | Midaz CBS primary | Accepted | — |
| ADR-014 | Composable financial stack | Accepted | — |
| ADR-015 | Payment processing stack | Accepted | — |
| ADR-016 | AI plane and PII/AML routing | Accepted | 2026-05-03 |
| ADR-017 | Keycloak IAM cutover (P3.4) | Accepted | 2026-05-03 |

## Index (thematic docs/adr/)

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| ADR-CST-01 | Client statements | Accepted | — |
| ADR-FOS-01 | FOS escalation | Accepted | — |
| ADR-HMR-01 | HMRC FATCA/CRS reporting | Accepted | — |
| ADR-LCY-01 | Customer lifecycle FSM | Accepted | — |
| ADR-040 | AI execution policy | Accepted | — |
| ADR-041 | GLM-4.5-Air distributed inference | Accepted | — |
| ADR-042 | ufw perimeter posture per host | Accepted | — |
| ADR-043 | Aider/Continue routes | Accepted | — |
