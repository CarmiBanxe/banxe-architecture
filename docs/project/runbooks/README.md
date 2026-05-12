# Runbooks — Project Documentation (Layer 2)

Status: CONTENT (D3.3.3 — full sub-domain content landed)
Sprint: D3.3.3 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12,
IL-PROJECT-DOCS-SPRINT-D3-3-1-ARCHITECTURE-CONTENT-2026-05-12 (Layer-2 peer pattern),
IL-PROJECT-DOCS-SPRINT-D3-3-2-API-CONTENT-2026-05-12 (Layer-2 peer pattern),
IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12,
ADR-027 (audit-trail durability — rollback event audit sink),
HITL-MATRIX.yaml (READ-ONLY reference; gate authoritative source),
Sprint S12.4 (KC prod realm provisioning), S12.5 (G-IAM-08 fix),
S12.6 (G-IAM-09 prep), S13.8 (G-FACTORY-05 owner), S16.4 (safeguarding + recon),
S23 (runbook library index), S25.4 (quarterly HITL review),
G-FACTORY-05, G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION, G-IAM-09,
banxe-emi-stack PR #133 (S12.5 prep, 17/17 PASS),
banxe-emi-stack PR #134 (S12.6 prep, 29/29 PASS),
banxe-emi-stack PR #135 (S16.4 prep, 33/33 PASS)

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

Real files in `docs/runbooks/` (enumerated via `ls docs/runbooks/`):

19 runbook files under `docs/runbooks/` + 2 Phase F/G execution notes under
`docs/ops/`. Catalogued in §C below. Anchored on the
IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12 ownership rule
(Central authors / approves; per-task execution may delegate to Sub-A / Sub-B).

---

## A. Runbook catalogue overview

### A.1 Domain grouping

The 19 existing runbooks fall into the following operational domains. Domain
labels are not encoded in filenames today; this grouping is documentation-side
classification only.

- **KC (Keycloak / IAM)** — currently MISSING. Production KC live-ops runbook
  (`kc-deploy-runbook.md`) is gated on Track B; see §H.
- **Sandbox lifecycle** — sandbox condition-activation runbooks
  (`condition-d-step3-apply-runbook-2026-05-12.md`,
  `conditions-abcd-activation-runbook-2026-05-12.md`).
- **Safeguarding + reconciliation** — Sprint S16.4 prep package landed in
  banxe-emi-stack PR #135 (33/33 PASS); project-side runbook target queued
  for D3.3.4 / S16.
- **Observability** — drain runbook + alert on-call playbook are MISSING;
  see §H.
- **Infra** — factory infra (Legion / evo1 / evo2 / WSL2) and AI plane
  (LiteLLM / Ollama / LLM router / OfficeCLI) runbooks; 14 of the 19 fall
  into this group.

### A.2 Naming convention

Runbook filenames follow one of two shapes:

- `<topic>-<verb>-runbook-YYYY-MM-DD.md` — for operational procedures bound
  to a specific dated event or version (examples:
  `condition-d-step3-apply-runbook-2026-05-12.md`,
  `evo2-vulkan-gpu-runbook-2026-05-11.md`).
- `<topic>-<verb>-YYYY-MM-DD.md` or `<topic>.md` — for evergreen or
  install-time procedures (examples: `legion-llm-router-setup.md`,
  `redis-evo1-setup.md`).

New runbooks SHOULD use the dated `-runbook-` form when the procedure is
versioned to a sprint or window; the undated form is acceptable for setup
material that does not expire.

### A.3 Ownership

Owner: **Central** per
IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12. Authoring and approval
sit with Central; execution may delegate to Sub-A or Sub-B per the
runbook's HITL block (see §F). Layer-1 / factory-canon runbooks under
`docs/canon/` remain out of scope; this domain covers product-side
runbooks only.

---

## B. Runbook structure standard

Every project runbook must include the following blocks, in order:

1. **H1 title** — `# <Service> — <Operation> runbook`.
2. **Status block** — `Status:` (DRAFT / PARTIAL / CONTENT / DEPRECATED),
   sprint, owner, version, last-reviewed date. Mirrors the Layer-2 README
   header style established in D2.
3. **Pre-flight** — environment + identity + branch + repo state checks.
   Mandatory: `git status --porcelain` empty; prod host reachable
   read-only; services healthy.
4. **Numbered idempotent steps** — each step MUST be safely re-runnable.
   Steps that mutate state MUST identify the mutation explicitly.
5. **HITL gate** — required approvers and severity threshold; cite
   `HITL-MATRIX.yaml` (READ-ONLY canonical source). See §F.
6. **Rollback** — reverse-procedure block or alternative recovery path.
   See §G.
7. **Validation script reference** — link to `scripts/<topic>-validate.sh`
   (bash `set -euo pipefail`; lint-only; exit 0 + PASS count). See §E.
8. **Anchors** — IL / ADR / GAP / Sprint references. Each anchor MUST
   exist in canon at write time (no invented references).

Deviations from this template are allowed only when an explicit IL records
the deviation rationale; otherwise the auditor flags structural drift.

---

## C. Existing runbooks index (19 files)

Real files under `docs/runbooks/`, one-line descriptions only. No invention.

### Sandbox lifecycle (2)

- `condition-d-step3-apply-runbook-2026-05-12.md` — Sandbox Condition D
  Step 3 apply procedure.
- `conditions-abcd-activation-runbook-2026-05-12.md` — Sandbox Conditions
  A/B/C/D activation order.

### Maintenance & emergency procedures (1)

- `maintenance-window-evo2-q8-2026-05-11.md` — evo2 Q8 maintenance window.

### LLM / AI plane (5)

- `legion-llm-router-setup.md` — Legion LLM router setup.
- `legion-litellm-cache.md` — Legion LiteLLM cache.
- `litellm-shadow-tap-patch-2026-05-12.md` — LiteLLM shadow-tap patch.
- `fa-01-legion-ollama-coder-install.md` — Legion Ollama install.
- `fa-02-litellm-canonical-aliases.md` — LiteLLM canonical aliases.

### Hardware / OS infra (5)

- `evo2-vulkan-gpu-runbook-2026-05-11.md` — evo2 Vulkan GPU runbook.
- `fa-evo1-bios-uma-audit.md` — evo1 BIOS UMA audit.
- `fa-evo2-gpu-stack.md` — evo2 GPU stack.
- `fa-wsl2-ram-cap-and-ollama-cache.md` — WSL2 RAM cap + Ollama cache.
- `redis-evo1-setup.md` — Redis on evo1 setup.

### Workstation / dev environment (3)

- `legion-officecli-setup.md` — Legion Office CLI.
- `legion-tailscale-quick-reference.md` — Legion Tailscale quick reference.
- `legion-do-not-do.md` — Legion do-not-do list (defensive).

### Provisioning / decommission (2)

- `pa-01-midaz-ledger-postgres-provisioning.md` — Midaz ledger Postgres
  provisioning.
- `pa-05-frankfurter-decommission.md` — Frankfurter decommission.

### HITL / process (1)

- `hitl-decision-recording.md` — HITL decision recording procedure
  (cross-link `../operations/` for HITL workflow mechanics).

### Adjacent (out-of-tree but related) — `docs/ops/` (2)

- `docs/ops/phase-f-execution-2026-05-06.md` — Phase F execution notes.
- `docs/ops/phase-g-execution-2026-05-06.md` — Phase G execution notes.

The S23 deliverable `docs/project/operations/runbook-library-index.md`
(MISSING; see §H) will consolidate this list and split factory-vs-bank
ownership.

---

## D. Operational lifecycle

### D.1 Creation

Two creation paths:

- **Sprint deliverable** — runbook scoped in the backlog (e.g., S14 audit
  drain runbook, S18 backup chain runbook). Sprint-owner authors; Central
  reviews against the structure standard (§B).
- **HITL-ASK driven** — a coordination request from Sub-A or Sub-B that
  reveals a missing runbook for a recurring operation; Central authors
  the runbook before the next execution.

### D.2 Review

- Auditor (Spec-First Auditor v2) must pass 12/12.
- Anchor verification: every IL / ADR / GAP / Sprint anchor in the runbook
  MUST exist in canon at commit time.
- Cross-link review: cross-references to Layer-2 peers
  (compliance / security / data / operations) MUST resolve.

### D.3 Deployment

- **No auto-deploy to prod.** Every prod-impacting runbook executes under
  a HITL gate (see §F).
- Dry-run / read-only validation precedes any mutation step.

### D.4 Update

- Append-only via IL pairing: every material change to a runbook is paired
  with an IL entry in `INSTRUCTION-LEDGER.md` per
  IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12.
- Status block (§B item 2) bumped on each update.

### D.5 Retirement

- Mark `Status: DEPRECATED` and add a `**Successor:**` line pointing at
  the replacement runbook (or "no successor — procedure no longer required"
  with IL anchor).
- Deprecated runbooks are not deleted; the trail is preserved for audit.

---

## E. Pre-flight & validation pattern

### E.1 Standard pre-flight checklist

Every project runbook's pre-flight MUST verify:

1. `cd <repo>` (target repo per the runbook).
2. `git fetch origin --prune` + `git status --porcelain` empty.
3. On the correct branch (or branch created from `main`).
4. Prod host reachable **read-only** first (e.g., `ssh -o BatchMode=yes`
   echo round-trip; `curl /health/ready`).
5. Dependent services healthy (per the runbook's service-map).
6. Validation script (`scripts/<topic>-validate.sh`) returns PASS before
   any mutation step proceeds.

### E.2 Validation script template

- Shebang: `#!/usr/bin/env bash`.
- `set -euo pipefail` mandatory.
- Lint-only / read-only checks; never mutate.
- Exit `0` on PASS; non-zero on any FAIL.
- Print `N/N PASS` summary line at the end.

### E.3 Reference precedent (banxe-emi-stack)

The validation-script pattern is anchored on three Sub-B prep packages
already merged in `banxe-emi-stack` (cross-repo evidence; not in this
docs repo):

- **S12.5 prep** — G-IAM-08 fix prep, banxe-emi-stack PR **#133**
  (validation 17/17 PASS).
- **S12.6 prep** — G-IAM-09 backup-restore prep, banxe-emi-stack PR
  **#134** (validation 29/29 PASS).
- **S16.4 prep** — safeguarding + reconciliation prep, banxe-emi-stack
  PR **#135** (validation 33/33 PASS).

New project runbooks SHOULD borrow the same script shape (lint-only,
PASS-count summary, idempotent steps) until a project-side validation
template lands under `../operations/`.

---

## F. HITL gates in runbooks

### F.1 Canonical source

`HITL-MATRIX.yaml` (repo root) is the **READ-ONLY** canonical source of
HITL gate definitions. Runbooks reference matrix entries by ID; they do
not redefine the gate criteria locally.

### F.2 Standard approval pattern

For any prod-impacting runbook:

- **Central review** — runbook structure + anchors + HITL clause valid.
- **Operator approval** — operator signs off the specific execution
  window.
- **MLRO co-sign** — required for procedures touching compliance,
  safeguarding, or KYC state.

### F.3 EMERGENCY override

For incidents where the standard HITL chain cannot meet the time budget:

- Operator may execute under EMERGENCY override.
- **Retrospective sign-off** is mandatory: Central + MLRO co-sign within
  a Sprint S25.4 quarterly review window.
- Every EMERGENCY execution emits a HITL audit event to ClickHouse
  Guardian via ADR-027 (see §G).

### F.4 Compliance / safeguarding / KYC gate

Procedures touching the following classes always require the MLRO co-sign
clause, with no EMERGENCY-only path:

- Sanctions match adjudication (target runbook MISSING — see §H).
- FCA SUP 15.3.11R incident notification (G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION;
  target runbook MISSING — see §H).
- GDPR Art. 33 personal-data breach notification (72 h clock; target
  runbook MISSING — see §H).
- Safeguarding daily reconciliation break adjudication (S16.4 follow-up).

---

## G. Rollback patterns

### G.1 Rollback requirement

Every project runbook MUST include a Rollback block. The block contains
one of:

- **Reverse procedure** — explicit undo steps for each mutation step,
  executed in reverse order (mandatory pattern for backwards-compatible
  changes).
- **Alternative recovery path** — when the original procedure is not
  trivially reversible (e.g., schema migrations), name the recovery
  procedure or runbook used instead.

### G.2 Rollback validation

- Post-rollback diagnostic MUST confirm pre-deploy state. The diagnostic
  is the same read-only check that ran in §E pre-flight.
- If the diagnostic does not return to the pre-deploy baseline, the
  runbook's HITL block escalates to operator + MLRO.

### G.3 Rollback audit

- Every rollback event MUST emit an audit event to ClickHouse Guardian
  per [decisions/ADR-027-audit-trail-durability.md](../../decisions/ADR-027-audit-trail-durability.md)
  (5-year retention, CASS 15 §15.10 compliance).
- Event class: `RUNBOOK_ROLLBACK_EXECUTED` (target convention; codify in
  the runbook template once the first project-side runbook lands).

---

## H. Open gaps for D3.3.4+

Project runbook target files queued for creation in later D3.3.x sub-sprints
or owner backlog sprints.

- `docs/project/operations/runbook-library-index.md` — runbook library
  index (factory ↔ bank split). Owner sprint **S23**.
- `docs/project/operations/audit-buffer-drain-runbook.md` — audit-buffer
  drain runbook under ADR-027. Owner sprint **S14**.
- `docs/project/operations/sumsub-webhook-runbook.md` — SumSub webhook
  ops (HMAC / replay / DLQ). Owner sprint **S15**.
- `docs/project/operations/postgres-backup-runbook.md` — Postgres backup
  chain under ADR-029. Owner sprint **S18**.
- `docs/project/operations/postgres-restore-drill-runbook.md` — restore
  drill cadence; G-IAM-09 follow-up. Owner sprint **S18**.
- `docs/project/operations/alert-on-call-playbook.md` — alert on-call
  playbook (KC auth + safeguarding + admin events). Owner sprint **S16**.
- `docs/project/operations/kc-phase-f-g-runbook.md` — KC Phase F/G
  live-ops runbook. Owner sprint **S17**; **Track B BLOCKED** pending
  operator-led KC live-ops sprint.
- `docs/project/operations/kc-deploy-runbook.md` — KC prod realm
  provisioning (Sprint **S12.4**); HOLD on G-IAM-08 and G-IAM-09 fixes
  landing first.
- `docs/project/operations/production-deploy-checklist.md` — generic
  production deploy checklist; cross-link with S20 release checklist.
- `docs/project/operations/fca-incident-notification-runbook.md` —
  FCA SUP 15.3.11R notification SOP (G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION;
  owner sprint **S25**).
- `docs/project/operations/gdpr-72h-breach-runbook.md` — GDPR Art. 33
  72-hour personal-data breach procedure (owner sprint **S21 / S25**).
- `docs/project/operations/sanctions-match-adjudication-runbook.md` —
  sanctions match adjudication runbook (4-eye + MLRO co-sign). Owner
  sprint **S13**.
- `docs/project/operations/restore-drill-runbook.md` — G-IAM-09 follow-up
  restore drill (specific to KC backup gap).

### Carried-forward (not runbook-specific but visible here)

- **20 UNKNOWN-status ADRs** — `**Status:**` backfill queued per
  IL-PROJECT-DOCS-SPRINT-D3-2D-3-ADR-INDEX-UNIFIED-2026-05-12.
- **G-FACTORY-05** — Legion :8180 logical collision with evo1 KC; OPEN
  until **S13.8**. Resolution must precede any S12.4 KC realm runbook.
- **G-IAM-08** — DB password exposure via systemd `ExecStart`; OPEN until
  **S12.5** fix (banxe-emi-stack PR #133 is the prep package).
- **G-IAM-09** — backup/restore drill gap; OPEN until **S12.6** fix
  (banxe-emi-stack PR #134 is the prep package).
- **Track B BLOCKED** — KC Phase F/G live-ops sprint awaiting operator;
  blocks the KC live-ops runbook above.

---

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
| `docs/project/operations/kc-deploy-runbook.md`               | KC prod realm provisioning runbook               | S12.4; HOLD on G-IAM-08 + G-IAM-09 fixes                   | S12.4        |
| `docs/project/operations/production-deploy-checklist.md`     | Production deploy checklist                      | Cross-link S20 release checklist                            | S20          |
| `docs/project/operations/fca-incident-notification-runbook.md`| FCA SUP 15.3.11R notification SOP               | G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION                  | S25          |
| `docs/project/operations/gdpr-72h-breach-runbook.md`         | GDPR Art. 33 72h breach procedure                | S21 / S25 incident chain                                   | S21 / S25    |
| `docs/project/operations/sanctions-match-adjudication-runbook.md`| Sanctions match adjudication (4-eye + MLRO) | S13 alongside sanctions policy                              | S13          |
| `docs/project/operations/restore-drill-runbook.md`           | Restore drill (G-IAM-09 follow-up)               | G-IAM-09; banxe-emi-stack PR #134 prep                      | S12.6        |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md (unified)](../../adr/INDEX.md)
- ↔ Sibling domains:
  [architecture](../architecture/README.md) ·
  [api](../api/README.md) ·
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [data](../data/README.md) ·
  [operations](../operations/README.md) (canonical home for new runbooks) ·
  [governance](../governance/README.md)
