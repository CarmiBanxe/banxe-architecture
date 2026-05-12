# Operations — Project Documentation (Layer 2)

Status: SKELETON (D2)
Sprint: D2 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12, HITL-MATRIX.yaml
(reference only — do not duplicate content here), HITL §0.2 Levels 1–5,
Sprint S17–S18 (backup + restore drill + secret rotation cadence),
Sprint S23 (runbook consolidation + on-call + IR)

---

## Scope

In-scope topics for this domain:

- HITL gates registry — the operational mapping of HITL Levels 1–5 to actual
  workflows, owners, and escalation rules (HITL §0.2 Levels 1–5; references
  `HITL-MATRIX.yaml` without duplicating it).
- Incident response procedure (top-level IR runbook).
- On-call playbook — rotation, escalation, comms.
- Subsystem-specific runbooks (audit-buffer drain, ClickHouse outage,
  SumSub webhook, postgres backup/restore, alert routing, 429 incidents,
  release checklist, branch protection, post-go-live handover).
- Sprint S17–S18 ops anchors: secret rotation cadence operationalisation,
  backup + restore drill ops.
- Sprint S23 ops consolidation: runbook library index, on-call playbook,
  IR procedure.

## Out of scope

- Architectural rationale for ops choices (lives under `../architecture/`).
- Compliance dossiers cross-referenced from ops procedures (lives under
  `../compliance/`).
- Implementation source code (lives in `banxe-emi-stack/`).
- Factory-side operations (Layer 1; lives in `docs/canon/`, `docs/factory/`).
- HITL gate POLICY text itself (lives in `HITL-MATRIX.yaml` and is a binding
  artifact — referenced here, not copied).

## Definition of Done

Verbatim from [`../PROJECT-DOCUMENTATION-MASTER-INDEX.md`](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
§3:

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

- `docs/runbooks/hitl-decision-recording.md` — HITL decision recording.
- `docs/runbooks/` — full runbook directory (see [`../runbooks/README.md`](../runbooks/README.md)
  for the enumeration).
- `docs/ops/phase-f-execution-2026-05-06.md` — Phase F execution.
- `docs/ops/phase-g-execution-2026-05-06.md` — Phase G execution.
- `docs/policies/hitl-l3-agent-gate-2026-05-11.md` — HITL L3 agent gate (PARTIAL).
- `HITL-MATRIX.yaml` (repo root) — HITL gate matrix (referenced, not duplicated).

## MISSING / TODO

| Target path                                                  | Title                                                | Anchor                                                  | Owner sprint |
|--------------------------------------------------------------|------------------------------------------------------|---------------------------------------------------------|--------------|
| `docs/project/operations/audit-buffer-drain-runbook.md`      | Audit-buffer drain runbook (ADR-027)                 | Backlog S14                                              | S14          |
| `docs/project/operations/clickhouse-outage-response.md`      | ClickHouse outage response                           | Backlog S14                                              | S14          |
| `docs/project/operations/sumsub-webhook-runbook.md`          | SumSub webhook ops (HMAC / replay / DLQ)             | Backlog S15                                              | S15          |
| `docs/project/operations/alert-on-call-playbook.md`          | Alert on-call playbook                               | Backlog S16                                              | S16          |
| `docs/project/operations/n8n-telegram-pipeline.md`           | n8n + Telegram pipeline runbook                      | Backlog S16                                              | S16          |
| `docs/project/operations/alert-severity-ownership-matrix.md` | Alert severity ↔ ownership matrix                    | Backlog S16                                              | S16          |
| `docs/project/operations/postgres-backup-runbook.md`         | Postgres backup chain runbook                        | Backlog S18                                              | S18          |
| `docs/project/operations/postgres-restore-drill-runbook.md`  | Postgres restore drill runbook                       | Backlog S18                                              | S18          |
| `docs/project/operations/postgres-offsite-verification.md`   | Postgres offsite upload verification                 | Backlog S18                                              | S18          |
| `docs/project/operations/429-incident-response.md`           | 429 incident response                                | Backlog S19                                              | S19          |
| `docs/project/operations/branch-protection-contract.md`      | Branch-protection contract                           | Backlog S20                                              | S20          |
| `docs/project/operations/release-checklist.md`               | Release checklist (sandbox → prod)                   | Backlog S20                                              | S20          |
| `docs/project/operations/runbook-library-index.md`           | Runbook library index                                | Backlog S23                                              | S23          |
| `docs/project/operations/on-call-playbook.md`                | On-call playbook                                     | Backlog S23                                              | S23          |
| `docs/project/operations/incident-response-procedure.md`     | Incident response procedure                          | Backlog S23                                              | S23          |
| `docs/project/operations/post-go-live-handover.md`           | Post-go-live ops handover                            | Backlog S25                                              | S25          |
| `docs/project/operations/secret-rotation-cadence.md`         | Secret rotation cadence (ops side)                   | Sprint S17 secret rotation                               | S17          |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md](../../adr/INDEX.md)
- → [HITL-MATRIX.yaml](../../../HITL-MATRIX.yaml) (reference only)
- ↔ Sibling domains:
  [architecture](../architecture/README.md) ·
  [api](../api/README.md) ·
  [runbooks](../runbooks/README.md) ·
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [data](../data/README.md) ·
  [governance](../governance/README.md)
