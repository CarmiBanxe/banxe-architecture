# Runbooks — Project Documentation (Layer 2)

Status: SKELETON (D2)
Sprint: D2 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12, existing
`docs/runbooks/` inventory, KC Phase F/G runbook gap (Track B), Sprint S23

---

## Scope

In-scope topics for this domain:

- Operational runbooks for production bank services (drain, restore, alert response,
  webhook ops, secret rotation, KC failure).
- Scheduled-operations procedures (cron / systemd timer triggers and ownership).
- Failure-recovery procedures for individual subsystems.
- Library index that consolidates the scattered runbooks under `docs/runbooks/`
  into a single navigable list (Sprint S23 deliverable).
- KC Phase F/G live-ops runbook (currently a gap — Track B BLOCKED).

## Out of scope

- Top-level incident response procedure (lives under `../operations/`).
- Compliance-evidence dossiers cross-referenced from runbooks (lives under
  `../compliance/`).
- Architectural rationale of a subsystem (lives under `../architecture/`).
- Source code that runbooks operate on (lives in `banxe-emi-stack/`).
- Factory-side runbooks for AI inference / GPU plane (Layer 1; lives in
  `docs/runbooks/` itself but is factory-canon, not project-canon).

> Naming convention: backlog rows target `docs/project/operations/...` for runbooks.
> This README documents the conceptual "runbooks" domain; canonical home for new
> runbook documents is `../operations/`.

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

Real files in `docs/runbooks/` (enumerated via `ls`):

- `docs/runbooks/hitl-decision-recording.md` — HITL decision recording.
- `docs/runbooks/evo2-vulkan-gpu-runbook-2026-05-11.md` — evo2 Vulkan GPU runbook.
- `docs/runbooks/fa-01-legion-ollama-coder-install.md` — Legion Ollama install.
- `docs/runbooks/fa-02-litellm-canonical-aliases.md` — LiteLLM aliases.
- `docs/runbooks/fa-evo1-bios-uma-audit.md` — evo1 BIOS UMA audit.
- `docs/runbooks/fa-evo2-gpu-stack.md` — evo2 GPU stack.
- `docs/runbooks/fa-wsl2-ram-cap-and-ollama-cache.md` — WSL2 RAM cap.
- `docs/runbooks/legion-do-not-do.md` — Legion do-not-do list.
- `docs/runbooks/legion-litellm-cache.md` — Legion LiteLLM cache.
- `docs/runbooks/legion-llm-router-setup.md` — Legion LLM router.
- `docs/runbooks/legion-officecli-setup.md` — Legion Office CLI.
- `docs/runbooks/legion-tailscale-quick-reference.md` — Legion Tailscale.
- `docs/runbooks/maintenance-window-evo2-q8-2026-05-11.md` — evo2 maintenance window.
- `docs/runbooks/pa-01-midaz-ledger-postgres-provisioning.md` — Midaz Postgres prov.
- `docs/runbooks/pa-05-frankfurter-decommission.md` — Frankfurter decommission.
- `docs/ops/phase-f-execution-2026-05-06.md`, `docs/ops/phase-g-execution-2026-05-06.md` — Phase F/G execution notes.

The S23 deliverable below indexes this collection and splits factory-vs-bank ownership.

## MISSING / TODO

| Target path                                                  | Title                                            | Anchor                                                     | Owner sprint |
|--------------------------------------------------------------|--------------------------------------------------|------------------------------------------------------------|--------------|
| `docs/project/operations/runbook-library-index.md`           | Runbook library index (factory ↔ bank split)     | Backlog S23 runbook library index                          | S23          |
| `docs/project/operations/audit-buffer-drain-runbook.md`      | Audit-buffer drain runbook (ADR-027)             | Backlog S14 drain runbook                                  | S14          |
| `docs/project/operations/sumsub-webhook-runbook.md`          | SumSub webhook ops (HMAC / replay / DLQ)         | Backlog S15 SumSub runbook                                 | S15          |
| `docs/project/operations/postgres-backup-runbook.md`         | Postgres backup chain runbook (ADR-029)          | Backlog S18 backup runbook                                 | S18          |
| `docs/project/operations/postgres-restore-drill-runbook.md`  | Restore drill runbook + cadence                  | Backlog S18 restore drill                                  | S18          |
| `docs/project/operations/alert-on-call-playbook.md`          | Alert on-call playbook                           | Backlog S16 alert routing                                  | S16          |
| `docs/project/operations/kc-phase-f-g-runbook.md`            | KC Phase F/G live-ops runbook                    | Track B BLOCKED — operator-led KC live-ops sprint          | S17          |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md](../../adr/INDEX.md)
- ↔ Sibling domains:
  [architecture](../architecture/README.md) ·
  [api](../api/README.md) ·
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [data](../data/README.md) ·
  [operations](../operations/README.md) (canonical home for new runbooks) ·
  [governance](../governance/README.md)
