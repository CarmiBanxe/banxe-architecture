# AUDIT 2026-05 — Factory plane (Legion) vs Project plane (evo1+evo2)

| Field | Value |
|---|---|
| Sprint ID | IL-AUDIT-01 |
| Started | 2026-05-05 |
| Status | IN_PROGRESS (A1 DONE, A2 DONE, A3 PENDING) |
| Owner | CEO + Perplexity supervisor + Claude Code |
| Phase (GSD) | SPEC -> DESIGN -> CLOSE per artefact |

## Goal

1. Factory plane — Legion (mark-legion, WSL2 Ubuntu 24.04, RTX 4070 Laptop, 23 GiB WSL RAM cap, ~5.6 TB across mnt/c + mnt/d + /dev/sdd of which 1 TB native ext4) plus local AI tooling for coding orchestration.
2. Project plane — evo1 (banxe-NucBox-EVO-X2, 100.68.102.48, Ryzen AI MAX+ 395, 30 GiB RAM, 2.8 TB SSD) + evo2 (banxe-nucbox-evo-x2-2, 100.99.208.21, Ryzen AI MAX+ 395, 93 GiB RAM, 1.9 TB SSD) on USB4 mesh 10.0.0.0/30.

Audit scope: model completeness, HW utilisation, service health tests, AI-agents fork proposal (factory vs project), Guardian governance.

## Roadmap

| ID | Phase | Artefact | Status |
|---|---|---|---|
| A1 | SPEC | Legion baseline | DONE 2026-05-05 14:40Z |
| A2 | SPEC | evo1+evo2 baseline | DONE 2026-05-05 14:54Z |
| A3 | DESIGN | Gap-analysis | PENDING |
| A4 | DESIGN | AI-agents fleet × fork orchestration | PENDING |
| A5 | CLOSE | ADRs + IL closure + gap-register migration | PENDING |

## Sub-artefacts

- docs/roadmap/audit-2026-05/A1-legion-baseline.md
- docs/roadmap/audit-2026-05/A2-cluster-baseline.md
- docs/roadmap/audit-2026-05/A3-gap-analysis.md
- docs/roadmap/audit-2026-05/A4-agents-orchestration-proposal.md

## Anchors

- CLAUDE.md sec 1 + 11
- approval-rules.md + IL-CANON-04
- ADR-018, ADR-019, ADR-020
- MetaClaw org-cleanup/phase4-hw-matrix-roc-rpc @ 016dc26
- INS-2026-05-04-ORG-CLEANUP / P4.3-EVO2 / P4.3-Q235 / P4.2-ROCM

## Out of scope

- HW changes (BIOS, RAM, SSD swap).
- Decommission or migration of live services.
- Any prod actions outside an explicit follow-up PR.

## Status history

| Date | Status | Note |
|---|---|---|
| 2026-05-05 | OPEN | Sprint kicked off, A1+A2 collected, A3 pending |
