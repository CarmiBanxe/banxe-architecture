# Architecture — Project Documentation (Layer 2)

Status: SKELETON (D2)
Sprint: D2 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12, ADR-031, ADR-032, ADR-033,
ADR-034, ADR-035, Sprint S12–S25

---

## Scope

In-scope topics for this domain (derived from the 8-domain row in
[`../PROJECT-DOCUMENTATION-MASTER-INDEX.md`](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
§5):

- Production-candidate architectural baseline (the freeze going into Phase F7).
- ADR coverage map — which ADR governs which subsystem.
- Cross-cutting architectural concerns: event bus, audit trail, identity propagation,
  transaction integrity, asynchronous messaging.
- Reference architecture diagrams, planes (`docs/PLANES.md`), and deployment topology
  at the **architectural** level. Concrete operational topology detail lives under
  `../operations/`.
- Programme-level ADR catalogue cross-references (factory + project sides).

## Out of scope

- Factory / operator-terminal architecture (Layer 1, lives in `docs/canon/`,
  `docs/factory/`).
- Implementation source code (lives in `banxe-emi-stack/` outside this repo).
- Single-service runbooks (lives in `../runbooks/` / `../operations/`).
- Compliance-evidence dossiers (lives in `../compliance/`).
- Hardware / physical inventory (out of programme; see
  `docs/canon/HW-MODEL-UPGRADE-matrix.md`).

## Definition of Done

Verbatim from [`../PROJECT-DOCUMENTATION-MASTER-INDEX.md`](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
§3 ("Definition of 100 % project documentation"):

A deliverable is DONE when **all four** of the following are true:

1. Document exists at a stable canonical path under `docs/project/` or a domain folder.
2. Document has named owner, version, and last-reviewed date in its header.
3. Document has been reviewed by the relevant track-lead and reflects current
   production reality (no stale architectural references, no removed services, no
   unmerged ADRs).
4. Document is reachable from this index in two hops or fewer
   (index → backlog → doc, or index → domain table → doc).

## Current artifacts

Real files (enumerated via `git ls-files` / `find docs/`):

- `docs/master-document/01-master-full.md` — high-level project architecture.
- `docs/master-document/02-unified-stack.md` — unified stack overview.
- `docs/master-document/03-gap-overlay.md` — gap overlay.
- `docs/master-document/04-audit-v2.md` — architecture audit v2.
- `docs/PLANES.md` — meta / inference / data / control planes.
- `docs/SYSTEM-ARCHITECTURE.md` — system architecture overview.
- `COMPOSABLE-ARCH.md` (repo root) — composable architecture.
- `docs/DEPLOYMENT-ARCHITECTURE.md` — deployment architecture.
- `SERVICE-MAP.md` (repo root) — service map.
- `STACK-LAYERS.md` (repo root) — stack layers.
- `docs/adr/INDEX.md` — ADR index (D2 publication).
- Factory ADRs in `docs/adr/`: ADR-027, ADR-031, ADR-032, ADR-033, ADR-034, ADR-035
  (see `../../adr/INDEX.md` for status, title, date).

## MISSING / TODO

| Target path                                                              | Title                                          | Anchor                                                     | Owner sprint |
|--------------------------------------------------------------------------|------------------------------------------------|------------------------------------------------------------|--------------|
| `docs/project/architecture/architecture-freeze-S12.md`                   | Architecture freeze (production-candidate)     | Backlog S12 row "Architecture freeze note"                  | S12          |
| `docs/project/architecture/adr-coverage-map.md`                          | ADR ↔ subsystem coverage map                   | Backlog S12 row "ADR coverage map"                          | S12          |
| `docs/project/architecture/audit-trail-architecture.md`                  | Audit-trail architecture (ADR-027 anchor)      | Backlog S14 audit-trail dossier                             | S14          |
| `docs/project/architecture/webhook-reliability-architecture.md`          | Webhook reliability (ADR-034 anchor)           | Backlog S15 SumSub                                          | S15          |
| `docs/project/architecture/alert-routing-architecture.md`                | Alert routing (ADR-033 anchor)                 | Backlog S16 alert routing                                   | S16          |
| `docs/project/architecture/secret-rotation-architecture.md`              | Secret rotation (ADR-032 anchor)               | Backlog S17 secrets                                          | S17          |
| `docs/project/architecture/backup-restore-architecture.md`               | Backup + restore (ADR-029 anchor)              | Backlog S18 backup                                          | S18          |
| `docs/project/architecture/auth-rate-limit-architecture.md`              | Auth rate-limit (ADR-030 anchor)               | Backlog S19 rate-limit                                       | S19          |
| `docs/project/architecture/ci-smoke-gate-architecture.md`                | CI smoke-gate (ADR-035 anchor)                 | Backlog S20 smoke-gate                                      | S20          |
| `docs/project/architecture/event-bus-architecture.md`                    | Event bus + KycReTriggerEvent reconciliation   | ADR-028 + open item flagged in source-repo Step 4/5         | S14–S15      |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md](../../adr/INDEX.md)
- ↔ Sibling domains:
  [api](../api/README.md) ·
  [runbooks](../runbooks/README.md) ·
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [data](../data/README.md) ·
  [operations](../operations/README.md) ·
  [governance](../governance/README.md)
