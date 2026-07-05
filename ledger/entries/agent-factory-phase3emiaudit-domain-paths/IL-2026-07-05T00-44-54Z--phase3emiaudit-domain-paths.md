---
il_ts: 2026-07-05T00:44:54Z
session_id: agent-factory-phase3emiaudit-domain-paths
source: agent-factory
status: PROPOSED
---

# Phase 3 SSOT — banxe-emi-stack domain-path audit (companion to #1026)

## What

Read-only cross-repo verification of PHASE-3-SSOT-PLAN §3 domains 1-17,22 (the emi-stack rows #1026 marked
unverified-here). Verified via git ls-tree on banxe-emi-stack origin/main (8ca0ce4); no worktree touched (Rule 6).
Report: `docs/audit/PHASE-3-SSOT-EMI-STACK-DOMAIN-AUDIT-2026-07-05.md`.

## Findings (16/18 paths confirmed)

- **2 path discrepancies:** §3.14 ARL `services/arl/` → **`services/agent_routing/`**; §3.17 KB `services/kb/`
  → **`services/compliance_kb/`**. → feeds AMENDMENT-002.
- **Clarify:** §3.12 audit both `services/audit/` + `services/audit_trail/` exist; §3 table is 22 core of ~50+
  services (not exhaustive vs §1 "every domain").
- **Unverified:** operational flags (LIVE/CODE-READY/…) are runtime state, not path-checkable — owner-team
  attestation still owed for §8 criterion 4.

## Boundaries

Doc-only, prepare-only, cross-repo READ-ONLY (no emi-stack mutation). Report lands in banxe-architecture
governance repo. IL minted redis-serialized at ratification.

## Anchors

`docs/audit/PHASE-3-SSOT-EMI-STACK-DOMAIN-AUDIT-2026-07-05.md` · `governance/PHASE-3-SSOT-PLAN.md` §3 ·
`docs/audit/PHASE-3-SSOT-CONFORMANCE-2026-07-05.md` (#1026) · banxe-emi-stack 8ca0ce4.
