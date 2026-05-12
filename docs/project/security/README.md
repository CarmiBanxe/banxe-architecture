# Security — Project Documentation (Layer 2)

Status: CONTENT (D3.2b — full sub-domain content landed)
Sprint: D3.2b (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12,
IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12,
IL-OPS-G-OBS-02-CLOSED-TRACK-E-FULLY-CLOSED-2026-05-11,
ADR-033 (ufw perimeter — `docs/adr/ADR-033-ufw-perimeter.md`),
ADR-038 (Vault placeholder — `decisions/ADR-038-vault-adoption-placeholder.md`),
ADR-032 (secret rotation — `decisions/ADR-032-secret-rotation-policy.md`),
G-SEC-02 (Track F, DEFERRED — long-term Vault adoption), G-IAM-03, G-IAM-08, G-IAM-09,
G-SECURITY-HISTORICAL-LEAKS, G-SECURITY-LIVEBOX-NO-OUTBOUND-FILTER,
historical leak sprint S15.5, Sprint S12.x KC hardening,
Sprint S17 secrets rotation

---

## Scope

In-scope topics for this domain:

- Threat model — STRIDE-class threats per service tier, mitigations, residual risk.
- Secrets policy — rotation cadence, BYOK / KMS direction, gitleaks coverage,
  Vault adoption roadmap (G-SEC-02 status).
- Perimeter posture — ufw rules per host (ADR-033), Tailscale segmentation,
  egress allowlist.
- IAM / Keycloak realm + client model (Sprint S17).
- Rate-limit configuration matrix (ADR-030 anchor — per route, per identity).
- Webhook signature handling (SumSub HMAC; ADR-034).
- Historical-leak post-mortems and remediation (Sprint S15.5 anchor; e.g.
  `docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md`).

## Out of scope

- Source-code level mitigations (in `banxe-emi-stack/`).
- Compliance evidence dossiers (lives under `../compliance/`).
- API contract surface (lives under `../api/`).
- Operational runbooks executing security procedures (lives under `../operations/`
  or `../runbooks/`).
- Architectural rationale for security decisions (lives under `../architecture/`).
- Factory-side IAM mechanics (Layer 1; lives in `docs/canon/` for operator-terminal).

> Note: backlog rows target `docs/project/iam-security/...`. This README's canonical
> path is `security/` per the master-index 8-domain table. New documents land under
> `security/` and the backlog target paths will be reconciled in D3+.

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

- `PRIVILEGE-MODEL.md` (repo root) — privilege model (DONE).
- `INVARIANTS.md` (repo root) — bank invariants (security gates anchored).
- `docs/policies/ACCESS-AND-SECRETS.md` — access + secrets policy.
- `docs/governance/branch-protection.md` — branch-protection policy.
- `docs/adr/ADR-033-ufw-perimeter.md` — ufw perimeter posture per host.
- `decisions/ADR-032-secret-rotation-policy.md` — secret rotation policy.
- `decisions/ADR-038-vault-adoption-placeholder.md` — Vault adoption placeholder.
- `docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md` — historical incident dossier.
- `docs/incidents/COMPLIANCE-ASSESSMENT-2026-05-07-EVO1-XMRIG.md` — compliance
  assessment of the same incident.
- `docs/incidents/MEMORY-md-leakage-2026-05-07.snapshot.md` — historical leak.

---

## A. Threat model

### A.1 STRIDE high-level enumeration

STRIDE = Spoofing, Tampering, Repudiation, Information disclosure, Denial of
service, Elevation of privilege. The full per-service mapping lands in
`docs/project/security/threat-model.md` (MISSING). High-level enumeration for
D3.2b reference:

- **Spoofing** — OAuth client impersonation, KC realm token forgery,
  webhook origin spoofing (SumSub HMAC mitigation under ADR-034). Mitigations
  anchor on G-IAM-03 (service-to-service tokens, currently OPEN).
- **Tampering** — webhook payload tampering (HMAC-SHA1 SumSub digest
  verification), audit-trail tampering (I-24 append-only invariant — see
  IL-OPS-G-CASS-02-CLOSED-TRACK-D-FULLY-CLOSED-2026-05-11).
- **Repudiation** — covered by 5y ClickHouse Guardian retention + HITL gate
  per `docs/policies/hitl-l3-agent-gate-2026-05-11.md` (PARTIAL).
- **Information disclosure** — historical leak class: gitleaks 8 leaks under
  G-SECURITY-HISTORICAL-LEAKS (Sprint S15.5); ExecStart-password class under
  G-IAM-08 (Sprint S12.5 fix).
- **Denial of service** — auth-route brute-force class (mitigations under
  ADR-030 auth rate-limit policy); upstream / public ingress not yet
  ufw-tightened (cross-link ADR-033 ufw perimeter posture).
- **Elevation of privilege** — KC realm misconfiguration (Track B BLOCKED
  pending operator), service-to-service token misuse (G-IAM-03), missing
  realm provisioning on evo1 (S12.4 HOLD per S12.1 evidence).

### A.2 Attack surface inventory

- **KC** on evo1: `*:8180` data plane, `127.0.0.1:9000` management (per
  IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12).
- **KC** on Legion: collision instance (`G-FACTORY-05` — TODO: verify
  canonical GAP-ID; recorded in INSTRUCTION-LEDGER only at time of writing,
  not yet in `GAP-REGISTER.md`).
- **API gateway** — public ingress (port discovery: see
  `docs/project/api/README.md`).
- **ClickHouse** (Guardian audit sink) — 5y retention, append-only.
- **Postgres** (KC backend) — `127.0.0.1:15433` on evo1 (containerised PG).
- **Ollama / llama-server** on evo2 (`100.99.208.21:11434`, `:8082`) — local
  Tailscale-bound; not in production attack surface but flagged for the
  threat-model dossier.

- TODO: `docs/project/security/threat-model.md` (MISSING; owner sprint D3.x).
  D3.2b lands the enumeration above; full STRIDE-per-service mapping deferred.

---

## B. Secrets policy

### B.1 Current state

- **Env vars + systemd EnvironmentFile** — partial coverage. Some services
  read secrets from `EnvironmentFile=` (correct pattern), others read from
  `.env` files in service-local directories.
- **`.env` files** — historical leak risk (covered by
  G-SECURITY-HISTORICAL-LEAKS, gitleaks 8 leaks). Mitigation: `.gitignore`
  audit, gitleaks pre-commit, rotation for any leaked credential.
- **ExecStart arguments** — KC service on evo1 currently passes
  `--db-password=...` in the systemd `ExecStart` directive, exposing the
  Postgres password to any local user via `ps -ef`. Tracked under **G-IAM-08**
  (OPEN); fix planned in **Sprint S12.5** to use `--db-password-file=` or
  Quarkus env-var.

### B.2 Target state

- All secrets read from one of:
  1. `EnvironmentFile=` (mode 0600, owner = service user) for systemd
     services, OR
  2. Vault Agent template injection (long-term — DEFERRED per G-SEC-02).
- Zero secrets in `ExecStart`, command lines, or world-readable files.
- All credentials rotated on a published cadence (see B.3).
- All historical leaks rotated; gitleaks coverage of full git history
  documented in `docs/project/compliance/secrets-in-ci-scan-policy.md`
  (MISSING; backlog S17).

### B.3 Rotation cadence

- **Client secrets (OAuth)** — 90-day rotation per **Sprint S12.5**.
- **KC realm signing keys** — rotation cadence TBD (TODO: confirm in D3.2c
  alongside `docs/project/security/keycloak-realm-client-doc.md`).
- **SumSub webhook secret** — owner sprint S15; rotation procedure target
  `docs/project/security/sumsub-credential-rotation.md` (MISSING).
- **Postgres / ClickHouse / Modulr / Sardine.ai** — TBD per service onboarding
  (S20.1 Modulr, S20.4 Sardine, ongoing for PG/CH).
- Authoritative ADR for rotation strategy: **ADR-032**
  (`decisions/ADR-032-secret-rotation-policy.md`).

---

## C. Vault status

- **G-SEC-02** (long-term Vault / Infisical adoption) is **DEFERRED** per
  `IL-OPS-TRACKS-EF-PARTIAL-CLOSURE-2026-05-11`. Listed in MASTER-PLAN and
  ROADMAP as deferred work; tracked in
  `decisions/ADR-038-vault-adoption-placeholder.md` as the placeholder ADR.
- **ADR-038 placeholder** — the canonical artifact recording that the
  decision has been deferred. Full Vault adoption ADR to land alongside
  the operator decision (currently pending; **Sprint S17 / G-SEC-02 /
  Track F (DEFERRED per IL-OPS-TRACKS-EF-PARTIAL-CLOSURE-2026-05-11)**).
  D3.2d.4 anchor reconciliation: canonical anchor stack confirmed as
  S17 + G-SEC-02 + Track F (shown above).
- **Interim mitigations** while Vault is deferred:
  1. `chmod 0600` on every systemd `EnvironmentFile` reading a production
     secret; owner = service user.
  2. **No secrets in `ExecStart`** — the G-IAM-08 fix planned in
     **Sprint S12.5** is the deadline for removing the visible KC DB password.
  3. gitleaks pre-commit hook on all repos (already enabled — verify
     coverage in D3.2c against the `IL-OPS-G-CASS-02` and ADR-032 chain).
  4. No production credentials in any source-controlled `.env*` file.

---

## D. Keycloak hardening evidence (Sprint S12.x)

### D.1 S12.1 — DONE (evidence)

Anchor: `IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12`.

Production-relevant facts captured by that IL:

- KC build: **26.2.5** on **JDK 21**, profile `prod`, optimized build,
  JGroups / Infinispan cluster up (single node).
- Bind: `*:8180` (data plane), `127.0.0.1:9000` (management endpoint —
  health probes resolve here, not on 8180).
- Backend: **PostgreSQL** at `jdbc:postgresql://127.0.0.1:15433/keycloak`
  (non-standard port; containerised PG).
- No H2 / dev-file storage on the production KC node — clean prod backend.
- Service unit: `keycloak.service` loaded / active / running for ~5 days at
  time of S12.1 verification.

### D.2 S12.x open work

- **G-IAM-08** (DB password exposure via `ExecStart`) — OPEN; fix in
  **S12.5**.
- **G-IAM-09** (TODO: verify exact title of G-IAM-09 in `GAP-REGISTER.md` —
  multiple occurrences confirmed by repo grep; full text reconciliation in
  D3.2c).
- **S12.2 session timeouts** — pending. Target durations: idle 15 min,
  SSO 30 min, max session 8 h (TODO: confirm against
  `docs/canon/g-iam-01-audit-2026-05-05.md` and / or `INVARIANTS.md` in
  D3.2c).
- **S12.3 service-to-service tokens** (G-IAM-03) — pending; design lands
  in `docs/project/security/keycloak-realm-client-doc.md` (MISSING).
- **S12.4 realm `banxe-emi` provisioning** — **HOLD** until G-IAM-08 and
  G-IAM-09 are fixed; S12 PRE-STATE confirmed realm currently returns
  HTTP 404 at `/realms/banxe-emi/.well-known/openid-configuration`.

### D.3 KC backup posture

- **No KC backups located** at S12.1 PRE-STATE under `/var/backups`,
  `/opt/backups`, or any `*keycloak*backup*` path. RPO for KC realm /
  client state is currently **undefined**.
- TODO: open a KC-backup GAP (or fold into existing Postgres backup
  scope per ADR-029 — `decisions/ADR-029-postgres-backup-strategy.md`).
  Owner sprint candidate: **S18** (Postgres backup + restore drill).

---

## E. Historical leaks

- **gitleaks 8 historical leaks** — anchor **G-SECURITY-HISTORICAL-LEAKS**;
  remediation queued for **Sprint S15.5**.
- TODO: produce remediation matrix (credential class → rotation evidence →
  CI gitleaks coverage attestation). Target:
  `docs/project/security/historical-leak-remediation-matrix.md` (MISSING).
- Adjacent dossiers (already in repo):
  - `docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md`
  - `docs/incidents/COMPLIANCE-ASSESSMENT-2026-05-07-EVO1-XMRIG.md`
  - `docs/incidents/MEMORY-md-leakage-2026-05-07.snapshot.md`
- Rotation plan: for each leaked credential class, document which rotation
  ran (date, actor, evidence path). TODO in D3.2c.

---

## F. Network perimeter

### F.1 ADR-033 — ufw posture per host

- Authoritative: `docs/adr/ADR-033-ufw-perimeter.md` (ufw rules per host).
- Note: `decisions/ADR-033-alert-routing-strategy.md` is a **separate** ADR
  under the same number — number collision OI-3 (referenced in
  `INSTRUCTION-LEDGER.md` for D3.2b open issues). When citing "ADR-033 ufw
  perimeter" elsewhere, prefer the explicit path
  `docs/adr/ADR-033-ufw-perimeter.md`.

### F.2 Outbound filter — open gap

- **G-SECURITY-LIVEBOX-NO-OUTBOUND-FILTER** — Liveboxes have no outbound
  filter; risk of unauthorised egress. Owner sprint **S16.1**.

### F.3 Tailscale segmentation

- Internal control plane uses Tailscale: evo1, evo2 (`100.99.208.21`),
  Legion (Tailscale-bound dev KC at `100.101.218.26`).
- TODO: confirm Tailscale ACL artefact path (target candidate:
  `docs/project/security/tailscale-acl.md`) in D3.2c.

### F.4 Legion :8180 collision

- **G-FACTORY-05** (TODO: verify canonical GAP-ID) — Legion runs its own
  KC on `:8180` (`--hostname=100.101.218.26 ... --import-realm`), in
  parallel with evo1 production KC also on `:8180`. They do not
  bind-collide (different hosts), but cross-host routing / proxy paths
  MUST disambiguate before any S12 realm-provisioning work touches realm
  / client config.

---

## G. Audit + observability

- **ClickHouse Guardian** is the audit sink; **5-year retention** target
  (anchor: see compliance README §A.3; authoritative ADR is **ADR-027**
  `decisions/ADR-027-audit-trail-durability.md`, not ADR-019 — see the
  compliance README for the anchor reconciliation TODO).
- **Append-only / I-24 invariant** enforced by `BufferedAuditPort`
  (`banxe-emi-stack/services/recon/buffered_audit_port.py`, out of scope
  here; evidence under
  `IL-OPS-G-CASS-02-CLOSED-TRACK-D-FULLY-CLOSED-2026-05-11`).
- **Alert routing**: `IL-OPS-G-OBS-02-CLOSED-TRACK-E-FULLY-CLOSED-2026-05-11`
  closes Track E (Observability) with the alert-coverage CI smoke tests
  for KC auth-event categories (LOGIN_ERROR, CLIENT_LOGIN_ERROR,
  TOKEN_EXCHANGE_ERROR, admin DELETE_USER).
- TODO: produce the security-domain extract of the audit-and-observability
  dossier under `docs/project/security/audit-observability-extract.md`
  (MISSING; owner sprint S17).

---

## H. Open gaps for D3.2c+

Files referenced above that do not yet exist; queued for creation in D3.2c
or later sprints.

- `docs/project/security/threat-model.md` — STRIDE per-service mapping (D3.x).
- `docs/project/security/secret-rotation-runbook.md` — rotation runbook +
  cadence (S17).
- `docs/project/security/keycloak-realm-client-doc.md` — realm + client
  model, including service-to-service token design for G-IAM-03 (S17).
- `docs/project/security/byok-kms-policy.md` — BYOK / KMS policy (S17).
- `docs/project/security/vault-adoption-plan.md` — long-term Vault adoption
  plan (DEFERRED — G-SEC-02; revisit when ADR-038 is replaced by a full
  Vault ADR).
- `docs/project/security/rate-limit-configuration-matrix.md` — rate-limit
  matrix per route / per identity tier (S19; ADR-030 anchor).
- `docs/project/security/sumsub-credential-rotation.md` — SumSub credential
  rotation procedure (S15).
- `docs/project/security/perimeter-posture.md` — consolidated perimeter
  posture document, citing ADR-033 ufw + Tailscale ACL (S17).
- `docs/project/security/historical-leak-postmortem-2026-05-07.md` —
  consolidated XMRIG + MEMORY.md leak post-mortem (S15.5).
- `docs/project/security/historical-leak-remediation-matrix.md` —
  credential-class remediation matrix (S15.5).
- `docs/project/security/tailscale-acl.md` — Tailscale ACL artefact (D3.2c
  candidate; TODO: confirm with track-lead).
- `docs/project/security/audit-observability-extract.md` — security extract
  of audit + observability dossier (S17).
- TODO: verify canonical GAP-ID for the Legion :8180 collision (current
  citation `G-FACTORY-05` exists only in `INSTRUCTION-LEDGER.md`; reconcile
  to `GAP-REGISTER.md` in D3.2c).
- TODO: verify full G-IAM-09 title against `GAP-REGISTER.md` in D3.2c.
- Resolved (D3.2d.4): canonical anchors for the Vault decision are
  **Sprint S17 / G-SEC-02 / Track F (DEFERRED per
  IL-OPS-TRACKS-EF-PARTIAL-CLOSURE-2026-05-11)**. See §C and
  IL-PROJECT-DOCS-SPRINT-D3-2D-4-CITATIONS-REANCHOR-2026-05-12.

---

## MISSING / TODO

| Target path                                                              | Title                                                | Anchor                                                       | Owner sprint |
|--------------------------------------------------------------------------|------------------------------------------------------|--------------------------------------------------------------|--------------|
| `docs/project/security/threat-model.md`                                  | Service-tier threat model (STRIDE)                   | Sprint S15.5 historical leak follow-up                       | S17          |
| `docs/project/security/secret-rotation-runbook.md`                       | Secret rotation runbook + cadence                    | Backlog S17 secret rotation                                  | S17          |
| `docs/project/security/keycloak-realm-client-doc.md`                     | Keycloak realm + client documentation                | Backlog S17 KC realm doc; Track B BLOCKED                     | S17          |
| `docs/project/security/byok-kms-policy.md`                               | BYOK / KMS policy                                    | Backlog S17 BYOK                                              | S17          |
| `docs/project/security/vault-adoption-plan.md`                           | Long-term Vault / Infisical adoption                 | G-SEC-02 DEFERRED — Phase 9                                   | S17 (deferred) |
| `docs/project/security/rate-limit-configuration-matrix.md`               | Rate-limit configuration matrix                      | Backlog S19 rate-limit                                       | S19          |
| `docs/project/security/sumsub-credential-rotation.md`                    | SumSub credential rotation procedure                 | Backlog S15 SumSub                                            | S15          |
| `docs/project/security/perimeter-posture.md`                             | Perimeter posture (ADR-033 anchor)                   | ADR-033 ufw posture; egress allowlist                         | S17          |
| `docs/project/security/historical-leak-postmortem-2026-05-07.md`         | XMRIG + MEMORY.md leak post-mortem (consolidated)    | Sprint S15.5; existing dossier files                          | S15.5        |
| `docs/project/security/historical-leak-remediation-matrix.md`            | Historical-leak remediation matrix (gitleaks 8)      | Sprint S15.5; G-SECURITY-HISTORICAL-LEAKS                     | S15.5        |
| `docs/project/security/tailscale-acl.md`                                 | Tailscale ACL artefact                               | TODO: confirm path with track-lead                            | D3.2c        |
| `docs/project/security/audit-observability-extract.md`                   | Security extract of audit + observability dossier     | IL-OPS-G-OBS-02-CLOSED-TRACK-E-FULLY-CLOSED-2026-05-11        | S17          |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md](../../adr/INDEX.md)
- ↔ Sibling domains:
  [architecture](../architecture/README.md) ·
  [api](../api/README.md) ·
  [runbooks](../runbooks/README.md) ·
  [compliance](../compliance/README.md) ·
  [data](../data/README.md) ·
  [operations](../operations/README.md) ·
  [governance](../governance/README.md)
