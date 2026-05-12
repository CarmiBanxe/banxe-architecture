# Operations — Project Documentation (Layer 2)

Status: CONTENT (D3.3.5 — full sub-domain content landed)
Sprint: D3.3.5 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12,
IL-PROJECT-DOCS-SPRINT-D3-3-1-ARCHITECTURE-CONTENT-2026-05-12 (Layer-2 peer),
IL-PROJECT-DOCS-SPRINT-D3-3-2-API-CONTENT-2026-05-12 (Layer-2 peer),
IL-PROJECT-DOCS-SPRINT-D3-3-3-RUNBOOKS-CONTENT-2026-05-12 (Layer-2 peer),
IL-PROJECT-DOCS-SPRINT-D3-3-4-DATA-CONTENT-2026-05-12 (Layer-2 peer),
IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12,
IL-OPS-G-OBS-02-CLOSED-TRACK-E-FULLY-CLOSED-2026-05-11,
ADR-013 (Midaz CBS), ADR-015 (payment stack), ADR-016 (AI plane / PII-AML),
ADR-017 (KC IAM cutover), ADR-018 (hybrid 5-layer compute),
ADR-019 (AI Guardian two-family), ADR-027 (audit-trail durability),
ADR-030 (auth rate-limit, Accepted 2026-05-12), ADR-033 (alert routing),
HITL-MATRIX.yaml (READ-ONLY canonical reference — 17 gates),
HITL §0.2 Levels 1–5,
G-IAM-08, G-IAM-09, G-FACTORY-05 (S13.8), G-OBS-01, G-OBS-02 (closed),
G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION (OPEN, retroactive MLRO/DPO/Legal),
Sprint S12.4, S13.8, S16.4, S17–S18, S18, S20, S22, S22.2, S23, S23.5, S25.4

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

---

## A. Operations overview

### A.1 Production hosts

- **evo1** (`banxe-NucBox-EVO-X2`) — production tier. Hosts production KC
  (`*:8180` per
  [decisions/ADR-017-keycloak-iam-cutover.md](../../decisions/ADR-017-keycloak-iam-cutover.md))
  + containerised Postgres (`127.0.0.1:15433`). Verified at S12.1
  PRE-STATE diagnostic
  (IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12).
- **Legion** (`mark-legion`) — dev / factory tier. Runs a Tailscale-bound
  development KC instance at `100.101.218.26:8180` (`--import-realm`).
  Logical-collision risk with evo1 prod KC is tracked under
  **G-FACTORY-05** (OPEN until **S13.8**).
- **evo2** — TBD per
  [decisions/ADR-018-hybrid-5-layer-ai-compute.md](../../decisions/ADR-018-hybrid-5-layer-ai-compute.md);
  current operational role centred on inference plane (Ollama, llama-server,
  Tailscale endpoint). Bank-tier production role TBD per S20+.

### A.2 Services in scope

| Service                          | Port(s)      | Anchor                                                                                                  |
|----------------------------------|--------------|---------------------------------------------------------------------------------------------------------|
| Compliance API                   | 8093         | [decisions/ADR-012-compliance-api-port-8093.md](../../decisions/ADR-012-compliance-api-port-8093.md)    |
| Midaz CBS                        | 8095         | [decisions/ADR-013-midaz-cbs-primary.md](../../decisions/ADR-013-midaz-cbs-primary.md)                  |
| Hyperswitch payments             | 8096-8098    | [decisions/ADR-015-payment-processing-stack.md](../../decisions/ADR-015-payment-processing-stack.md)    |
| Keycloak IAM                     | 8180         | [decisions/ADR-017-keycloak-iam-cutover.md](../../decisions/ADR-017-keycloak-iam-cutover.md)            |
| Safeguarding + reconciliation    | (internal)   | Sprint S16.4 prep package (banxe-emi-stack PR #135, 33/33 PASS — cross-repo evidence)                   |
| AI plane                         | (multi)      | ADR-016 (PII / AML routing), ADR-018 (5-layer compute), ADR-019 (AI Guardian two-family)                 |

### A.3 On-call

- **MLRO / SMF roster** — TODO appoint per **Sprint S20**.
- **Interim operator** — Central terminal + human double per §0.2 Level 2
  (operator-dubler model recorded in repo-root
  `PRIVILEGE-MODEL.md`).
- Detailed rotation, escalation tree, comms — see §C and the MISSING target
  `on-call-playbook.md` in §H.

---

## B. HITL gates catalogue

### B.1 Canonical source

`HITL-MATRIX.yaml` (repo root) is the **READ-ONLY** canonical source. **17
gates** are defined there at this writing (HITL-001 … HITL-017). This
README does not duplicate gate policy text; consumers programmatically
read the matrix (consumed by `banxe-emi-stack/services/hitl/org_roles.py`
per the matrix header).

### B.2 Gates by category

Categories below are documentation-side groupings only; the canonical
list (with ID, name, trigger, required_roles, SLA, FCA basis, severity,
notes) lives in `HITL-MATRIX.yaml`.

- **Realm provisioning** — KC `banxe-emi` prod realm provisioning;
  currently **HOLD** at **S12.4** pending G-IAM-08 + G-IAM-09 fix.
- **KC backup deploy** — G-IAM-09 follow-up; prep landed in
  banxe-emi-stack PR #134 (29/29 PASS).
- **Credential migration** — G-IAM-08 (DB password exposure via systemd
  `ExecStart`); prep landed in banxe-emi-stack PR #133 (17/17 PASS).
- **Safeguarding reconciliation first run** — S16.4 deploy; prep landed
  in banxe-emi-stack PR #135 (33/33 PASS); MLRO co-sign required for
  break adjudication.
- **Incident notifications** — FCA SUP 15.3.11R + GDPR Art. 33 72h
  (cross-link `../compliance/README.md` §A.2 + §B.3).
- **SAR / STR filing** — MLRO non-delegable (HITL-001 in the matrix).
- **Sanctions match adjudication** — 4-eye review + MLRO escalation
  (see `../compliance/README.md` §E.3).
- **ADR acceptance** — Architecture WG approval; recorded via IL
  pairing (IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12).
- **IL fixation** — Central authors / fixes IL entries; Sub-A / Sub-B
  cannot fix Central canon.
- **Canon overrides** — explicit canon-amendment IL required; never
  silent.

### B.3 Co-sign rules

- **Standard ops** — Central review + operator approval.
- **Compliance / safeguarding / KYC** — add **MLRO** co-sign (no
  EMERGENCY-only path).
- **§0.2 Level 4-5** — add **Board** co-sign (CEO dashboard + AI MLRO;
  Sprint S18 deployment).

### B.4 EMERGENCY override

For incidents where the standard chain cannot meet the time budget:

- Operator-only execution permitted.
- **Retrospective sign-off** is mandatory: Central + MLRO co-sign within
  the **Sprint S25.4** quarterly review window.
- Every EMERGENCY execution emits a HITL audit event to ClickHouse
  Guardian per ADR-027.

---

## C. Incident response

### C.1 Detection

- **ClickHouse Guardian** is the audit sink + first-line detector
  ([decisions/ADR-027-audit-trail-durability.md](../../decisions/ADR-027-audit-trail-durability.md)).
- Alert routing via n8n + Telegram per
  [decisions/ADR-033-alert-routing-strategy.md](../../decisions/ADR-033-alert-routing-strategy.md)
  (G-OBS-01 and G-OBS-02 CLOSED under Track E —
  IL-OPS-G-OBS-02-CLOSED-TRACK-E-FULLY-CLOSED-2026-05-11).

### C.2 Triage

- Severity vocabulary per
  [decisions/ADR-030-auth-rate-limit-policy.md](../../decisions/ADR-030-auth-rate-limit-policy.md)
  §"Severity vocabulary": **Low / Medium / High**.
- **P0** events page Central + operator + MLRO **within 15 minutes**.
- Severity escalation rules: P1 (within 30 min), P2 (within 1 h), P3 (next
  business day).

### C.3 Containment

Containment steps are encoded in the relevant subsystem runbook (see
`../runbooks/README.md` §C). The IR procedure (target
`docs/project/operations/incident-response-procedure.md`, MISSING; owner
sprint **S23**) is the top-level traffic cop that selects which runbook
applies.

### C.4 Notification

- **FCA SUP 15.3.11R** — operational-incident notification (cross-link
  `../compliance/README.md` §A.2). Target SOP runbook:
  `docs/project/operations/fca-incident-notification-runbook.md`
  (MISSING; owner **S25**).
- **GDPR Art. 33** — 72-hour personal-data breach (cross-link
  `../compliance/README.md` §B.3). Target runbook:
  `docs/project/operations/gdpr-72h-breach-runbook.md` (MISSING; owner
  **S21 / S25**).
- **MLRO / DPO / Legal** advisory chain — standard for any
  compliance-touching event.

### C.5 Post-mortem

- Blameless RCA target pattern:
  `docs/audit/<incident-id>-post-mortem-YYYY-MM-DD.md` (existing dossier
  family; see `docs/audit/`).
- Required sections: detection / response timeline, root cause analysis,
  containment evaluation, remediation backlog, IL closure entry.

### C.6 Reference incident (2026-05-08)

- **G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION** is **OPEN** following the
  2026-05-08 incident.
- Retroactive 72h FCA SUP 15.3.11R decision pending MLRO / DPO / Legal
  sign-off — TODO: discover the sign-off artefact and link from this
  section once available (cross-link `../compliance/README.md` §A.2).

---

## D. Observability

### D.1 Metrics

- **Prometheus** per
  [decisions/ADR-018-hybrid-5-layer-ai-compute.md](../../decisions/ADR-018-hybrid-5-layer-ai-compute.md)
  plane decomposition; per-service exporters.
- Per-endpoint API metrics covered in `../api/README.md` §G.1 (latency /
  error rate / throughput labels).

### D.2 Logs

- Structured logs sink into **ClickHouse Guardian** with **5-year
  retention** per ADR-027 (CASS 15 §15.10 compliance).
- Append-only contract (`BufferedAuditPort` pattern). Cross-link
  `../compliance/README.md` §A.3 for the regulatory mapping.

### D.3 Tracing

- **TODO** — tracing backend selection pending. Candidates: **Jaeger**
  or **Tempo**. Sprint **S22** decision. Do not assume any tracer in
  S15 / S16 / S18 implementation work; treat as tracer-agnostic until
  S22 closes.

### D.4 Alert routing

- ADR-033 (n8n + Telegram). Categories covered by the G-OBS-02 CI
  smoke tests: `AUTH_BRUTE_FORCE`, `CLIENT_SECRET_EXPOSURE`,
  `TOKEN_REPLAY`, `ADMIN_USER_DELETE`. Latency budget < 1 s adapter-side
  (per ADR-033 60 s end-to-end target).

### D.5 Dashboards

- Sprint **S22.2** — real-time dashboard (Superset or Metabase, TBD).
- Pre-S22.2: ad-hoc query on ClickHouse Guardian; on-call uses Telegram
  alert stream as the primary interaction surface.

---

## E. Capacity & performance

### E.1 Baseline thresholds (TODO per service)

Initial proposed thresholds; final values confirmed in Sprint **S22 / S23**:

- **Compliance API** (port 8093) — p99 latency target **< 100 ms**.
- **Midaz CBS** (port 8095) — p99 latency target **< 500 ms**.
- **Keycloak IAM** (port 8180) — p99 auth-flow latency target **< 200 ms**.
- **Hyperswitch payments** (ports 8096-8098) — TODO confirm per route.
- All thresholds TODO — confirm with operator in S22; record in
  `docs/project/operations/performance-baselines.md` (MISSING).

### E.2 Scale targets

- Per-service scale targets land in **Sprint S22 / S23** production
  readiness work; the `performance-baselines.md` target carries the matrix.

### E.3 Load testing

- E2E load harness target: **Sprint S23.5**.
- Pre-S23.5: per-service smoke tests + the four CI smoke gates already
  in place (mock tier required in branch-protection; full tier deferred
  to Phase 9 per Track G closure IL).

---

## F. Maintenance windows

### F.1 Scheduled cadence (TODO)

- **TODO** — define a recurring weekly window. Current process is
  ad-hoc per HITL approval. Target codification: `maintenance-window-procedure.md`
  (MISSING; see §H).

### F.2 Communication

- For any window touching compliance / safeguarding / KYC data: operator
  + MLRO **24-hour pre-window advisory** is mandatory.
- For pure-infra windows (factory / inference plane): operator-only
  advisory acceptable.

### F.3 Rollback

- Every maintenance window MUST follow the rollback discipline defined in
  `../runbooks/README.md` §G (mandatory rollback block + post-rollback
  validation + audit-trail emission per ADR-027).

---

## G. Operational metrics & SLIs

### G.1 Customer-impact SLIs

- **KYC onboarding latency** — time from `applicantCreated` to
  `applicantReviewed` returning a terminal state.
- **Payment success rate** — accepted / (accepted + rejected) per route
  per day.
- **Login availability** — Keycloak auth-flow success rate, error
  budget against the rate-limit policy (ADR-030).
- **Audit-trail durability** — daily reconciliation pass per CASS 15
  §15.10 (ADR-027 anchor); zero silent loss enforced by the G-CASS-02
  E2E tests.

### G.2 Internal SLIs

- **Pre-commit auditor 12/12 PASS rate** — proxy for canon hygiene.
- **PR cycle time** — from commit to merge.
- **IL pairing completeness** — every project-doc sprint commit
  paired with an IL entry per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12.

### G.3 SLO / error budgets

- **TBD** per Sprint **S22 / S23** production-readiness work. Target
  document: `docs/project/operations/slo-error-budget-policy.md`
  (MISSING; see §H).

### G.4 Quarterly review

- Cadence: **Sprint S25.4** quarterly review. MLRO + Board cadence
  (§0.2 Levels 4-5; cross-link `../compliance/README.md` §A.1).

---

## H. Open gaps for D3.3.6+

Operations MISSING target files queued for creation in later sprints. Each
row carries an owner sprint.

- `docs/project/operations/on-call-rotation.md` — appoint MLRO / SMF
  roster (owner sprint **S20**).
- `docs/project/operations/incident-response-procedure.md` — top-level
  IR runbook (owner sprint **S23**).
- `docs/project/operations/slo-error-budget-policy.md` — SLO + error
  budget policy (owner sprint **S22 / S23**).
- `docs/project/operations/maintenance-window-procedure.md` — weekly
  window cadence + comms (owner sprint **S20 / S23**).
- `docs/project/operations/performance-baselines.md` — per-service p99
  thresholds (owner sprint **S22**).

### Carried-forward (not operations-specific but visible here)

- **20 UNKNOWN-status ADRs** — `**Status:**` backfill queued per
  IL-PROJECT-DOCS-SPRINT-D3-2D-3-ADR-INDEX-UNIFIED-2026-05-12.
- **G-FACTORY-05 OPEN** until **S13.8** (cross-host KC :8180 routing).
- **G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION** — retroactive 72h
  decision pending MLRO / DPO / Legal sign-off.
- **§0.2 Level 4-5 deployment** — Sprint **S18** (CEO dashboard + AI
  MLRO).
- **Tracing backend decision** (§D.3) — Sprint **S22** Jaeger / Tempo
  choice.
- **G-IAM-08 / G-IAM-09 OPEN** — credential migration + KC backup deploy
  HITL-gated.

---

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
| `docs/project/operations/on-call-rotation.md`                | MLRO / SMF on-call rotation                          | Sprint S20 on-call appointment                           | S20          |
| `docs/project/operations/slo-error-budget-policy.md`         | SLO + error-budget policy                            | Sprint S22 / S23                                         | S22 / S23    |
| `docs/project/operations/maintenance-window-procedure.md`    | Maintenance window cadence + comms                    | Sprint S20 / S23                                         | S20 / S23    |
| `docs/project/operations/performance-baselines.md`           | Per-service p99 thresholds                           | Sprint S22                                               | S22          |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md (unified)](../../adr/INDEX.md)
- → [HITL-MATRIX.yaml](../../../HITL-MATRIX.yaml) (READ-ONLY reference, 17 gates)
- ↔ Sibling domains:
  [architecture](../architecture/README.md) ·
  [api](../api/README.md) ·
  [runbooks](../runbooks/README.md) ·
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [data](../data/README.md) ·
  [governance](../governance/README.md)
