# API — Project Documentation (Layer 2)

Status: CONTENT (D3.3.2 — full sub-domain content landed)
Sprint: D3.3.2 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12,
IL-PROJECT-DOCS-SPRINT-D3-3-1-ARCHITECTURE-CONTENT-2026-05-12 (Layer-2 peer pattern),
IL-PROJECT-DOCS-SPRINT-D3-2D-4-CITATIONS-REANCHOR-2026-05-12 (anchor reconciliation done),
ADR-012 (compliance API port 8093), ADR-013 (Midaz CBS primary),
ADR-015 (payment processing stack), ADR-016 (AI plane PII/AML routing),
ADR-017 (KC IAM cutover), ADR-025 (agent interaction canon),
ADR-027 (audit-trail durability), ADR-030 (auth rate-limit, Accepted 2026-05-12),
ADR-033 (alert routing), ADR-034 (webhook reliability KYC),
G-IAM-03 (service-to-service tokens — OPEN), G-OBS-01, G-OBS-02 (closed),
Sprint S12.3, S15, S16.4, S17, S19, S22, S22.1

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
- Multi-agent inter-service communication contract (Sprint S22.1 anchor —
  OpenAPI / AsyncAPI gap).

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
- `docs/adr/INDEX.md` — unified ADR catalogue (D3.2d.3 publication; 43 ADRs).
- Bank-side ADRs anchoring the API surface live in `decisions/` in **this**
  repo: ADR-012 (compliance API port), ADR-013 (Midaz), ADR-015 (payment stack),
  ADR-016 (AI plane routing), ADR-017 (KC cutover), ADR-025 (agent interaction
  canon), ADR-027 (audit-trail), ADR-030 (auth rate-limit), ADR-033 (alert
  routing), ADR-034 (webhook reliability KYC). Source-of-truth API code lives
  in `banxe-emi-stack/api/` (out of this docs repo).

---

## A. API surface overview

### A.1 Public-facing API ports

- **Compliance API — port 8093**
  ([decisions/ADR-012-compliance-api-port-8093.md](../../decisions/ADR-012-compliance-api-port-8093.md)).
  AML / KYC / sanctions screening endpoints. Migrated from :8090 → :8093 per
  ADR-012 (ACCEPTED). Authoritative for compliance-side decisions.
- **Payment APIs — Hyperswitch ports 8096-8098**
  ([decisions/ADR-015-payment-processing-stack.md](../../decisions/ADR-015-payment-processing-stack.md)).
  Hyperswitch + Paymentology stack (ACCEPTED 2026-04-13). Payment intent,
  payment method, refund, capture endpoints.
- **Midaz CBS — port 8095**
  ([decisions/ADR-013-midaz-cbs-primary.md](../../decisions/ADR-013-midaz-cbs-primary.md)).
  PRIMARY Core Banking System (ACCEPTED). Ledger / account / transaction
  endpoints. Programmable-ledger semantics.

### A.2 Internal service APIs

- **Safeguarding** — client-funds segregation per EMR 2011 reg. 20–24
  (S20 owner sprint). Read endpoints for daily reconciliation.
- **Reconciliation** — D-recon engine, Sprint S16.4 prep underway (recent
  Sub-B prep package). Endpoints for run lifecycle, break detection,
  audit emission.
- **KYC** — Customer Lifecycle FSM transitions
  (re-verification triggers per `decisions/ADR-028-kyc-reverification-triggers.md`).
- **Ledger** — Midaz-backed internal interface (see A.1 / ADR-013).

### A.3 Auth surface (6 endpoints per ADR-030)

The auth surface covered by ADR-030 rate-limit policy comprises:

1. `POST /auth/initiate` — start an SCA challenge.
2. `POST /auth/verify` — verify an SCA challenge response.
3. `POST /auth/resend` — resend OTP / push.
4. `GET /auth/methods` — list available SCA methods for the actor.
5. `GET /auth/methods/{id}` — method metadata.
6. `POST /auth/token` — token issuance after SCA pass.

Per-endpoint rate-limit configuration is anchored on
[decisions/ADR-030-auth-rate-limit-policy.md](../../decisions/ADR-030-auth-rate-limit-policy.md).
Implementation evidence: banxe-architecture PR #172 (commit c9de9fc) +
banxe-emi-stack `feat/adr-030-step1-rate-limiter-port`,
`feat/adr-030-step2-auth-wiring`, `feat/adr-030-step3-rate-limit-smoke`.

---

## B. API contracts & specifications

### B.1 REST (OpenAPI 3.x)

- **Source-of-truth**: FastAPI route declarations in `banxe-emi-stack`.
  OpenAPI 3.x spec auto-generated from FastAPI for every public service.
- **Export discipline**: snapshot exports MISSING in this docs repo (see
  §H "openapi-export.md"); current snapshots live only with the service
  code. Drift gate is a planned S22 deliverable.

### B.2 Event-driven (AsyncAPI)

- **Sprint S22.1 multi-agent communication protocol** — target document
  `docs/project/api/multi-agent-protocol.md` is MISSING. AsyncAPI 2.6+
  is the planned spec format.
- **Anchor (architectural)**: AI plane PII / AML routing per
  [decisions/ADR-016-ai-plane-pii-aml-routing.md](../../decisions/ADR-016-ai-plane-pii-aml-routing.md);
  agent interaction canon per
  [decisions/ADR-025-agent-interaction-canon.md](../../decisions/ADR-025-agent-interaction-canon.md).

### B.3 Versioning + deprecation policy

- **Versioning**: SemVer per service. **Major** for any backwards-incompatible
  change to a public route or webhook envelope. **Minor** for additive,
  non-breaking changes. **Patch** for fixes.
- **Dual-stack period** during major bumps: TODO — formalise duration
  (proposed minimum 90 days) in `docs/project/api/api-versioning-policy.md`
  (MISSING; owner sprint S12).
- **Deprecation notice**: minimum **90 days** before route removal. TODO
  confirm with operator and codify in the same versioning policy file.

---

## C. Auth & rate-limiting

### C.1 Keycloak IAM cutover

- Canonical authority: Keycloak `banxe-emi` realm on production KC. Per
  [decisions/ADR-017-keycloak-iam-cutover.md](../../decisions/ADR-017-keycloak-iam-cutover.md),
  the cutover designated KC as the IAM authority for bank tier. The
  Legion-side dev KC at `100.101.218.26:8180` (`--import-realm`) is a
  parallel development instance — see G-FACTORY-05 (logical collision
  risk flagged in S12.1 PRE-STATE) and `../security/README.md` §D for
  production KC binding (evo1).

### C.2 Rate-limit configuration matrix

- Per-route, per-identity-tier limits anchored on
  [decisions/ADR-030-auth-rate-limit-policy.md](../../decisions/ADR-030-auth-rate-limit-policy.md).
- Detailed matrix target: `docs/project/security/rate-limit-configuration-matrix.md`
  (currently PARTIAL per D3.1; owner sprint S19).

### C.3 Service-to-service tokens

- **G-IAM-03 — OPEN** (service-to-service token model not yet formalised).
  Owner sprint **S12.3**. Design will land in
  `docs/project/security/keycloak-realm-client-doc.md` (MISSING) and a
  parallel `docs/project/api/service-to-service-token-contract.md` (also
  MISSING, queued for D3.3.3+).

### C.4 SCA flow

The 6 auth endpoints (see A.3) compose the SCA flow under PSR 2017 + PSD2
SCA RTS. ADR-030 rate-limit policy applies per-endpoint to mitigate the
PSD2-relevant brute-force class (G-API-01 / G-API-02 closure was the
implementation milestone).

---

## D. Webhook reliability

### D.1 ADR-034 — webhook reliability (KYC / SumSub inbound)

- Authoritative anchor:
  [decisions/ADR-034-webhook-reliability-kyc.md](../../decisions/ADR-034-webhook-reliability-kyc.md).
  ACCEPTED (2026-05-11). 4 implementation steps merged in banxe-emi-stack
  (PRs #114 / #115 / #117 / #120). G-KYC-03 CLOSED; G-KYC-04 (signature /
  idempotency coverage) closed under Track C.

### D.2 Idempotency requirement

- **TODO**: formalise idempotency contract for **all** inbound webhooks
  in `docs/project/api/webhook-idempotency-policy.md` (MISSING; owner
  sprint S15 — extends ADR-034 inbound to non-KYC sources). Each provider
  carries a different idempotency key (SumSub: `applicantId + type`,
  Modulr: `eventId`, Marble: TODO confirm in D3.3.3).

### D.3 Retry policy + dead-letter queue

- Inbound retry policy: TODO — confirm and codify. SumSub provider-side
  retry happens on receipt of 4xx/5xx; bank-side response window is the
  key knob.
- Dead-letter queue (DLQ) for inbound webhooks: TODO — confirm whether the
  ADR-034 design extends DLQ semantics to non-KYC inbound (current scope
  is KYC-only). Owner sprint S15.

### D.4 Signature verification per source

- **SumSub** — HMAC-SHA1 of body with shared secret (per
  ADR-034 §"Signature verification" — covered by the G-KYC-04 tests).
- **Modulr** — TODO confirm signature scheme in
  `docs/project/api/webhook-contracts.md` (MISSING).
- **Marble** — TODO confirm signature scheme; cross-link with
  `decisions/ADR-005-marble-elastic-v2.md` boundary.

---

## E. Inter-service messaging

### E.1 Sprint S22.1 — multi-agent communication protocol

- **Target**: `docs/project/api/multi-agent-protocol.md` — MISSING.
- **Owner sprint**: **S22.1** (the explicit multi-agent comms target row in
  the backlog).
- **Anchor (architectural)**: ADR-016 (PII / AML routing) +
  ADR-025 (agent interaction canon). Concrete bus / topic / payload schema
  pending; design lands in S22.1.

### E.2 AI plane routing

- ADR-016 ([decisions/ADR-016-ai-plane-pii-aml-routing.md](../../decisions/ADR-016-ai-plane-pii-aml-routing.md))
  governs how PII / AML-sensitive payloads are routed across the AI plane.
  This constrains the multi-agent protocol's transport selection (e.g.,
  PII-bearing traffic must terminate inside the trusted plane).

### E.3 Agent interaction canon

- ADR-025 ([decisions/ADR-025-agent-interaction-canon.md](../../decisions/ADR-025-agent-interaction-canon.md))
  defines the architectural-side agent interaction rules. The
  operator-terminal-side canon is in `docs/canon/` (Layer 1, out of scope
  here).

### E.4 Bus selection — TODO

- **NATS** vs **Kafka** vs **Redis Streams** — operator decision pending.
  Captured as a TODO with anchor **S22.1**. The trade-offs (durability,
  ordering, fan-out, schema registry support) will be enumerated in the
  multi-agent-protocol target above. Do not assume any bus in S15 / S16
  implementation; treat as bus-agnostic until S22.1 closes.

---

## F. Error & status codes

### F.1 Standardised HTTP error envelope

- **TODO** — formalise an error envelope schema (`type`, `title`,
  `status`, `detail`, `instance`, plus BANXE-specific `audit_id` for
  ClickHouse correlation). Target:
  `docs/project/api/error-vocabulary.md` (MISSING; owner sprint S22).
- Likely baseline: RFC 7807 Problem Details, plus BANXE extensions.

### F.2 429 audit emission

- Every 429 response (rate-limit triggered) emits an
  **AUTH_RATE_LIMIT_EXCEEDED** audit event per
  [decisions/ADR-030-auth-rate-limit-policy.md](../../decisions/ADR-030-auth-rate-limit-policy.md)
  Step 4, routed to ClickHouse Guardian per
  [decisions/ADR-027-audit-trail-durability.md](../../decisions/ADR-027-audit-trail-durability.md)
  buffered-port pattern.
- Implementation evidence: banxe-emi-stack `feat/adr-030-step4-audit-emitter`
  (recorded in IL-OPS-MIRROR-BACKFILL-V4-ADR-028-2026-05-12 mirror chain).

### F.3 Severity vocabulary

Per ADR-030 §"Severity vocabulary", the 429 emission carries a severity
field with values **Low** / **Medium** / **High** depending on the rate-limit
class. Mapping rationale is in the ADR; no project-layer redefinition.

---

## G. API observability

### G.1 Per-endpoint metrics

Required (target inventory; concrete collector left to operations):

- **Latency** — p50 / p95 / p99 per route.
- **Error rate** — 4xx / 5xx by class.
- **Throughput** — RPS per route, per identity-tier.

Per-endpoint dashboards land under `../operations/` (Layer 2 operations
domain — D3.3.5 expansion). API-layer responsibility is **emit the right
metrics labels**, not host the dashboards.

### G.2 Audit trail

- Every privileged API action emits an audit event through the
  `BufferedAuditPort` pattern (ADR-027 anchor — see compliance README §A.3
  for the regulatory mapping).
- Retention: 5 years in ClickHouse Guardian (CASS 15 §15.10 compliance).
- Failure surface: ERROR-level log on dual-failure path (verified by
  G-CASS-02 E2E tests; `caplog` assertion).

### G.3 Alert routing

- ADR-033 ([decisions/ADR-033-alert-routing-strategy.md](../../decisions/ADR-033-alert-routing-strategy.md))
  routes severity-relevant API events to n8n → Telegram.
- Coverage closed: **G-OBS-01** (alert routing implementation) and
  **G-OBS-02** (CI smoke for alert categories) both CLOSED under Track E
  (IL-OPS-G-OBS-02-CLOSED-TRACK-E-FULLY-CLOSED-2026-05-11).

---

## H. Open gaps for D3.3.3+

API-specific MISSING target files queued for creation in later D3.3.x
sub-sprints or owner backlog sprints.

- `docs/project/api/api-contracts.md` — API contracts inventory (cross-link
  with `../architecture/README.md` §H "Open gaps"). Owner sprint **D3.3.3
  / S15**.
- `docs/project/api/openapi-export.md` — OpenAPI snapshot publication
  procedure + drift gate (no current export; specs live in service code).
  Owner sprint **S22**.
- `docs/project/api/async-events-catalog.md` — AsyncAPI catalogue of
  event-driven inter-service messages. Owner sprint **S22 / S22.1**.
- `docs/project/api/webhook-idempotency-policy.md` — idempotency contract
  for all inbound webhooks (extends ADR-034 inbound scope). Owner sprint
  **S15**.
- `docs/project/api/deprecation-policy.md` — explicit deprecation cadence,
  notice period, sunset procedure. Owner sprint **S12**.
- `docs/project/api/multi-agent-protocol.md` — multi-agent communication
  protocol; bus selection + payload schema. Owner sprint **S22.1**.
- `docs/project/api/service-to-service-token-contract.md` — S2S token
  format / scope / rotation (extends G-IAM-03 closure). Owner sprint **S12.3**.

### Carried-forward (not API-specific but visible here)

- **20 UNKNOWN-status ADRs** — `**Status:**` backfill queued per
  IL-PROJECT-DOCS-SPRINT-D3-2D-3-ADR-INDEX-UNIFIED-2026-05-12.
- **Real OpenAPI specs not yet exported** — currently live only in service
  source; needs an export + drift-detection mechanism (see
  `openapi-export.md` above).
- **G-FACTORY-05** — Legion :8180 logical collision with evo1 KC; must
  resolve before any S12.4 prod realm-provisioning touches `banxe-emi`
  (cross-link `../security/README.md` §F.4).

---

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
| `docs/project/api/api-contracts.md`                             | API contracts inventory                        | D3.3.3 pairing; cross-link architecture                  | D3.3.3 / S15 |
| `docs/project/api/openapi-export.md`                            | OpenAPI snapshot + drift gate procedure        | S22 OpenAPI gap                                          | S22          |
| `docs/project/api/async-events-catalog.md`                      | AsyncAPI event catalogue                       | S22 / S22.1                                              | S22 / S22.1  |
| `docs/project/api/webhook-idempotency-policy.md`                | Webhook idempotency policy (all inbound)       | Extends ADR-034 inbound                                  | S15          |
| `docs/project/api/deprecation-policy.md`                        | Deprecation cadence + sunset                   | Cross-link S12 architecture freeze                       | S12          |
| `docs/project/api/multi-agent-protocol.md`                      | Multi-agent communication protocol             | ADR-016 + ADR-025; bus selection TODO                    | S22.1        |
| `docs/project/api/service-to-service-token-contract.md`         | S2S token format / scope / rotation            | G-IAM-03 OPEN closure                                    | S12.3        |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md (unified)](../../adr/INDEX.md)
- ↔ Sibling domains:
  [architecture](../architecture/README.md) ·
  [runbooks](../runbooks/README.md) ·
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [data](../data/README.md) ·
  [operations](../operations/README.md) ·
  [governance](../governance/README.md)
