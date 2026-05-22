# R7 — Legal Boundary Cleanup: GUIYON Separation (PREP)

Date: 2026-05-22
Status: PREP (design + acceptance criteria; implementation scoped to S18-S19 GUIYON separation window per DELTA-ANALYSIS §4)
Source: IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22 (line 8775, R7 item)
Related repos: CarmiBanxe/guiyon (separate repo, exists); CarmiBanxe/legal-case-guyon-laval (FR civil property law); CarmiBanxe/banxe-architecture (this repo)

## Purpose

R7 (Legal boundary cleanup — GUIYON separation) ensures that the Guyon vs SCI Laval civil property case (FR jurisdiction, private legal matter) is fully segregated from BANXE production architecture, IL, and IP corpus. The two domains share no business overlap, no IP overlap, no data overlap, and must not share governance, secrets, audit trail, or branch protection rules.

This document is REFERENCE; binding closure happens during S18-S19 GUIYON separation window per docs/project/SPRINT-EXTENSION-LEGACY-REFACTOR-S18-S25.md.

## Scope

In scope:

- Verify CarmiBanxe/guiyon is the sole location for Guyon-related artefacts (separate from banxe-architecture, banxe-emi-stack, MetaClaw).
- Verify legal-case-guyon-laval is the sole location for FR civil property case materials.
- Audit banxe-architecture for any residual references to Guyon (grep -ri 'guyon|guiyon' should produce zero hits in production-bound paths).
- Confirm no Guyon-related data lives in guardian_audit_events ClickHouse table or any BANXE compliance datastore.

Out of scope:

- Legal merits of the Guyon vs SCI Laval case (handled in legal-case-guyon-laval).
- ss1 repo (separate investigative judge case, JICABDOY24000051, also FR jurisdiction).

## Acceptance criteria (DONE definition)

- grep -ri 'guyon\\|guiyon' in banxe-architecture, banxe-emi-stack, MetaClaw production paths returns zero matches in src/, services/, infra/, docs/architecture/, docs/api/, docs/compliance/, docs/security/.
- Residual mentions allowed only in: this PREP doc, audit logs (read-only history), and operator-facing canon docs that explicitly document the separation.
- CarmiBanxe/guiyon repo has README clearly stating jurisdiction (FR) and that it is a private legal matter, no BANXE dependency.
- No shared secrets, no shared API tokens, no shared CI workflows between BANXE repos and guiyon/legal-case-guyon-laval.
- IL pairing entry IL-OPS-V2-R7-GUIYON-SEPARATION-VERIFIED-<date> records the audit result.

## Open questions (route to operator during S18-S19 window)

- Is CarmiBanxe/guiyon currently sharing any CI infrastructure with BANXE repos (GitHub Actions runners, secrets, deploy keys)?
- Does the operator need a one-time grep audit run across all CarmiBanxe repos to confirm zero leakage, or is per-repo on-demand audit sufficient?
- Should the separation be enforced by branch protection (no cross-repo PR-link allowed) or by repo-level access control (different team membership)?

=== END OF R7 PREP (snapshot ad4e18e) ===
