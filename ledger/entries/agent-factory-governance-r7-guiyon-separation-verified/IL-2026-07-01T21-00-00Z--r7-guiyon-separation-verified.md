---
il_ts: 2026-07-01T21:00:00Z
session_id: agent-factory-governance-r7-guiyon-separation-verified
source: factory
status: DONE
parent_il: R7-GUIYON-LEGAL-BOUNDARY-CLEANUP-PREP-2026-05-22
---

### IL — R7 GUIYON legal-boundary separation — VERIFIED 2026-07-01

**ID:** IL-OPS-V2-R7-GUIYON-SEPARATION-VERIFIED-2026-07-01
**Date:** 2026-07-01
**Parent:** `docs/runbooks/R7-GUIYON-LEGAL-BOUNDARY-CLEANUP-PREP-2026-05-22.md`
**Scope:** governance audit record only. No prod code changed.

#### Audit evidence

**banxe-architecture production paths** (`docs/architecture/`, `docs/api/`,
`docs/compliance/`, `docs/security/`, `services/`, `infra/`) — **CLEAN**.

Three hits found, all in explicitly exempt categories:
- `docs/runbooks/R7-GUIYON-LEGAL-BOUNDARY-CLEANUP-PREP-2026-05-22.md` — this PREP
  document is an operator-facing canon doc about the separation (R7 AC: allowed).
- `INSTRUCTION-LEDGER.md` — read-only ledger history (R7 AC: allowed).
- `ledger/FROZEN-ARCHIVE.md` — read-only frozen archive (R7 AC: allowed).

**banxe-emi-stack production paths** — **CLEAN (with one operator-approved exempt)**.

Two hits found in `infra/guardian-shim/diagnostics/`:
- `D2-home-settings.json:164  "mcp__guiyon-files__*"`
- `D2-settings.json:10        "mcp__guiyon-files__*"`

These are Claude Code settings **diagnostic snapshots** (D2 series), not active
production config. They captured the MCP wildcard permission `mcp__guiyon-files__*`
that existed in the operator session at snapshot time.
**Operator decision 2026-07-01: EXEMPT as read-only diagnostic history. Not scrubbed.**

**CarmiBanxe/guiyon `.mcp.json`** — **CLEAN**.

Only `"AUTH_TOKEN"` present — guiyon's own auth token, no BANXE credentials,
no shared Postgres/Redis/API keys, no BANXE service cross-references.

#### Open follow-up (deferred — S18-S19 window)

- **guiyon README with FR-jurisdiction disclaimer** — `CarmiBanxe/guiyon` repo has no
  `README.md`. R7 AC requires a README clearly stating FR jurisdiction (Guyon vs SCI
  Laval, FR civil property law) and no BANXE dependency.
  **Status:** DEFERRED to S18-S19 GUIYON separation window per
  `docs/project/SPRINT-EXTENSION-LEGACY-REFACTOR-S18-S25.md`. Separate repo, low risk,
  no data or IP crossover confirmed.

#### Verdict

R7 separation is **operationally verified** as of 2026-07-01. All production paths in
banxe-architecture and banxe-emi-stack are clean. No shared secrets between BANXE and
guiyon repos. One deferred item (guiyon README disclaimer) remains open for S18-S19.

Invariants upheld: I-24 (append-only, no records modified). ADR-059-A (sharded ledger).
