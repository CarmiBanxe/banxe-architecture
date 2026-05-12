# API — Project Documentation (Layer 2)

Status: SKELETON (D2)
Sprint: D2 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12, ADR-034, Sprint S15,
Sprint S22 (multi-agent comms + OpenAPI/AsyncAPI gap), Sprint S17

---

## Scope

In-scope topics for this domain:

- Public-API contract surface (FastAPI routes under `api/routers/` in the bank
  source repo `banxe-emi-stack`).
- API versioning policy, deprecation policy, breaking-change protocol.
- Webhook contracts (inbound SumSub + outbound subscribers — ADR-034 anchor).
- Authentication / authorisation boundaries (Bearer, SCA, rate-limit per
  ADR-030 + IAM model from `PRIVILEGE-MODEL.md`).
- API error vocabulary and HTTP status semantics (incl. 429 audit-emission
  contract from the auth chain).
- Multi-agent inter-service communication contract (S22 anchor — OpenAPI /
  AsyncAPI gap).

## Out of scope

- Internal service-to-service ports (Layer 1 architectural detail; lives in
  `../architecture/`).
- Implementation source code (out of this repo).
- IAM mechanism details (Keycloak realm configuration is under `../security/`).
- Compliance evidence dossiers for API-side events (lives under `../compliance/`).
- HITL gate mechanics (under `../operations/`).

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

- `docs/master-document/01-master-full.md` — API plane + authentication overview.
- `SERVICE-MAP.md` (repo root) — service-to-service map (includes API gateway nodes).
- `PRIVILEGE-MODEL.md` (repo root) — auth + authz boundaries.
- `docs/adr/` — factory ADRs only; bank-side ADR-030 / ADR-034 live in
  `banxe-emi-stack/docs/adr/` (cross-ref in `../../adr/INDEX.md` MISSING block).

Source-of-truth API code lives in `banxe-emi-stack/api/` (out of this docs repo).

## MISSING / TODO

| Target path                                                     | Title                                          | Anchor                                                  | Owner sprint |
|-----------------------------------------------------------------|------------------------------------------------|---------------------------------------------------------|--------------|
| `docs/project/api/api-versioning-policy.md`                     | API versioning + deprecation policy            | Backlog S12 architecture freeze (cross-ref)             | S12          |
| `docs/project/api/webhook-contracts.md`                         | Webhook contract reference (ADR-034 anchor)    | Backlog S15 SumSub                                       | S15          |
| `docs/project/api/auth-contract.md`                             | Auth flow contract (Bearer / SCA / 2FA)        | Backlog S17 IAM hardening                                | S17          |
| `docs/project/api/rate-limit-contract.md`                       | 429 response + Retry-After + audit emission    | Backlog S19 rate-limit                                   | S19          |
| `docs/project/api/error-vocabulary.md`                          | Canonical error codes ↔ HTTP statuses          | Backlog S22 testing/QA traceability                      | S22          |
| `docs/project/api/openapi-snapshot.md`                          | OpenAPI snapshot publication + drift gate      | Backlog S22 OpenAPI/AsyncAPI gap                         | S22          |
| `docs/project/api/multi-agent-comms-contract.md`                | Multi-agent comms contract                     | Backlog S22 multi-agent comms                            | S22          |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md](../../adr/INDEX.md)
- ↔ Sibling domains:
  [architecture](../architecture/README.md) ·
  [runbooks](../runbooks/README.md) ·
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [data](../data/README.md) ·
  [operations](../operations/README.md) ·
  [governance](../governance/README.md)
