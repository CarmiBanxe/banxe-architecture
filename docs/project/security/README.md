# Security — Project Documentation (Layer 2)

Status: CONTENT-PARTIAL (D3.2a — sub-domains scaffolded; full CONTENT pending in D3.2b)
Sprint: D2 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12, ADR-033 (ufw perimeter),
ADR-038 (placeholder, currently MISSING in `../../adr/INDEX.md`), G-SEC-02
(deferred — long-term Vault adoption), historical leak sprint S15.5,
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
- `docs/incidents/INCIDENT-2026-05-07-EVO1-XMRIG.md` — historical incident dossier.
- `docs/incidents/COMPLIANCE-ASSESSMENT-2026-05-07-EVO1-XMRIG.md` — compliance
  assessment of the same incident.
- `docs/incidents/MEMORY-md-leakage-2026-05-07.snapshot.md` — historical leak.

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
