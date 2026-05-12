# Architecture — Project Documentation (Layer 2)

Status: CONTENT (D3.3.1 — full sub-domain content landed)
Sprint: D3.3.1 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12,
IL-PROJECT-DOCS-SPRINT-D3-2B-CONTENT-EXPANSION-2026-05-12 (pattern),
IL-PROJECT-DOCS-SPRINT-D3-2D-1-ADR-COLLISION-RENUMBER-2026-05-12 (post-renumber anchors),
IL-PROJECT-DOCS-SPRINT-D3-2D-3-ADR-INDEX-UNIFIED-2026-05-12 (unified ADR catalogue),
ADR-013 (Midaz CBS primary), ADR-014 (composable financial stack),
ADR-015 (payment processing stack), ADR-016 (AI plane / PII-AML routing),
ADR-017 (KC IAM cutover), ADR-018 (hybrid 5-layer AI compute),
ADR-019 (AI Guardian two-family), ADR-025 (agent interaction canon),
ADR-027 (audit-trail durability), ADR-028 (KYC re-verification),
ADR-029 (Postgres backup), ADR-030 (auth rate-limit, Accepted 2026-05-12),
ADR-032 (secret rotation), ADR-033 (alert routing), ADR-034 (webhook reliability),
ADR-035 (CI smoke-gate), ADR-036 (FATF Travel Rule, Closed → S21),
ADR-038 (Vault placeholder),
ADR-039..044 (factory governance, post-D3.2d.1 renumber),
ADR-074..076 (Ghost-Mode crypto, deferred S21),
Sprint S12–S25

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
- `docs/adr/INDEX.md` — unified ADR index (D3.2d.3 publication; 43 ADRs).
- `decisions/ADR-*.md` — canonical ADR catalogue (37 files; ADR-001..036, 038, 074..076).
- `docs/adr/ADR-*.md` — factory governance ADRs post-D3.2d.1 renumber
  (6 files; ADR-039..044).

---

## A. System architecture overview

### A.1 Component map (production candidate)

- **IAM tier** — Keycloak 26.2.5 prod (canonical authority per ADR-017
  cutover). evo1 runs KC on `*:8180` (data plane) + `127.0.0.1:9000`
  (management). PostgreSQL backend at `127.0.0.1:15433` (containerised).
- **API gateway** — public ingress; per-route rate limits per ADR-030
  (Auth Surface Rate-Limit Policy, Accepted 2026-05-12).
- **Services layer** — compliance (AML / KYC / sanctions), safeguarding
  (CASS 15 client-funds segregation), reconciliation (D-recon, Sprint S16),
  ledger (Midaz CBS primary per ADR-013), payment-core (Hyperswitch +
  Paymentology per ADR-015 — repository `banxe-payment-core`).
- **Data tier** — PostgreSQL (KC + service stores), ClickHouse Guardian
  (audit sink, 5y retention per ADR-027), Redis (caching / queues — see
  D below).
- **Observability tier** — n8n + Telegram alert pipeline per ADR-033
  (G-OBS-01 and G-OBS-02 closed). Audit emission via the BufferedAuditPort
  port pattern per ADR-027.

### A.2 Composable financial stack

- ADR-014 ([decisions/ADR-014-composable-financial-stack.md](../../decisions/ADR-014-composable-financial-stack.md))
  governs the composable EMI core architecture: domain-driven boundaries,
  port-and-adapter style for cross-service integration.
- ADR-013 ([decisions/ADR-013-midaz-cbs-primary.md](../../decisions/ADR-013-midaz-cbs-primary.md))
  installs Midaz as the PRIMARY Core Banking System.
- ADR-015 ([decisions/ADR-015-payment-processing-stack.md](../../decisions/ADR-015-payment-processing-stack.md))
  fixes the payment processing stack at Hyperswitch + Paymentology.

### A.3 AI plane

- ADR-016 ([decisions/ADR-016-ai-plane-pii-aml-routing.md](../../decisions/ADR-016-ai-plane-pii-aml-routing.md))
  defines PII / AML routing across the AI plane.
- ADR-018 ([decisions/ADR-018-hybrid-5-layer-ai-compute.md](../../decisions/ADR-018-hybrid-5-layer-ai-compute.md))
  fixes the hybrid 5-layer AI compute topology (canonical target).
- ADR-019 ([decisions/ADR-019-ai-guardian-two-family.md](../../decisions/ADR-019-ai-guardian-two-family.md))
  installs the AI Guardian two-family architecture for compliance enforcement.
- ADR-025 ([decisions/ADR-025-agent-interaction-canon.md](../../decisions/ADR-025-agent-interaction-canon.md))
  governs cross-agent interaction (the operator-terminal-side canon is in
  `docs/canon/`; this project-layer reference cites the architecture-side
  decision only).

---

## B. Identity & access architecture

### B.1 Keycloak IAM cutover

- ADR-017 ([decisions/ADR-017-keycloak-iam-cutover.md](../../decisions/ADR-017-keycloak-iam-cutover.md))
  records the cutover of the `banxe-emi` realm to KC as the canonical
  authority. Production binding: evo1 KC (see A.1). The Legion-side dev
  KC (Tailscale `100.101.218.26:8180`, `--import-realm`) is a parallel
  development instance — see G-FACTORY-05 for the logical-collision risk
  flagged in S12.1 PRE-STATE.

### B.2 Auth-surface rate limiting

- ADR-030 ([decisions/ADR-030-auth-rate-limit-policy.md](../../decisions/ADR-030-auth-rate-limit-policy.md))
  is Accepted (2026-05-12). Implementation evidence: banxe-architecture
  PR #172 (commit c9de9fc) — G-API-01 and G-API-02 closed. Implementation
  chain on banxe-emi-stack: `feat/adr-030-step1-rate-limiter-port`,
  `feat/adr-030-step2-auth-wiring`, `feat/adr-030-step3-rate-limit-smoke`.

### B.3 Claude Code permissions reclassification

- ADR-039 ([docs/adr/ADR-039-claude-code-permissions-reclassification.md](../../adr/ADR-039-claude-code-permissions-reclassification.md))
  — formerly the colliding ADR-027 in `docs/adr/`; renumbered to ADR-039
  in Sprint D3.2d.1 (see
  IL-PROJECT-DOCS-SPRINT-D3-2D-1-ADR-COLLISION-RENUMBER-2026-05-12). This
  ADR governs the Claude Code permission tiering used in factory-side
  operator terminals. Cross-link only; full scope lives outside Layer 2.

---

## C. Audit & observability architecture

### C.1 Audit-trail durability (CASS 15 §15.10)

- ADR-027 ([decisions/ADR-027-audit-trail-durability.md](../../decisions/ADR-027-audit-trail-durability.md))
  is the canonical anchor for CASS 15 §15.10 / 5-year ClickHouse Guardian
  retention. Implementation closed under Track D — see
  IL-OPS-G-CASS-02-CLOSED-TRACK-D-FULLY-CLOSED-2026-05-11.
- Pattern: `BufferedAuditPort` (append-only, I-24 invariant) feeds
  ClickHouse Guardian. Buffer survives backend failure and drains on
  recovery — verified by the 5 E2E tests under G-CASS-02.
- Cross-link: [`../compliance/README.md` §A.3](../compliance/README.md)
  for the regulatory mapping.

### C.2 Alert routing

- ADR-033 ([decisions/ADR-033-alert-routing-strategy.md](../../decisions/ADR-033-alert-routing-strategy.md))
  installs Option (a) n8n + Telegram for Keycloak auth-event alerts.
  Steps 1-3 merged in banxe-emi-stack (#116 / #118 / #119). G-OBS-01
  CLOSED; G-OBS-02 also closed in Track E (see
  IL-OPS-G-OBS-02-CLOSED-TRACK-E-FULLY-CLOSED-2026-05-11).
- Important: there is a separate `docs/adr/ADR-042-ufw-perimeter.md`
  (formerly docs/adr/ADR-033 ufw, renumbered in D3.2d.1). Architecture
  citations for **alert routing** use `decisions/ADR-033`; citations for
  **ufw perimeter** use `docs/adr/ADR-042`. See E.2.

### C.3 Webhook reliability (KYC / SumSub inbound)

- ADR-034 ([decisions/ADR-034-webhook-reliability-kyc.md](../../decisions/ADR-034-webhook-reliability-kyc.md))
  installs the SumSub inbound webhook reliability strategy. Steps 1-4
  merged in banxe-emi-stack (#114 / #115 / #117 / #120). G-KYC-03 CLOSED;
  G-KYC-04 (signature / idempotency coverage) closed under Track C.

---

## D. Data architecture

### D.1 Postgres backup strategy

- ADR-029 ([decisions/ADR-029-postgres-backup-strategy.md](../../decisions/ADR-029-postgres-backup-strategy.md))
  Accepted (2026-05-10). Implementation chain on banxe-emi-stack covers
  base backup, WAL archiving, restore-drill port, offsite upload port +
  InMemory adapter, backup-chain smoke tests. Cross-link target for the
  full operational dossier: `docs/project/operations/postgres-backup-runbook.md`
  (MISSING; backlog S18).

### D.2 KYC re-verification triggers

- ADR-028 ([decisions/ADR-028-kyc-reverification-triggers.md](../../decisions/ADR-028-kyc-reverification-triggers.md))
  Accepted (2026-05-09). Implementation: banxe-emi-stack PRs #69 / #70 /
  #99 wire `ROLE_CHANGED`, `BENEFICIAL_OWNER_CHANGED`, and
  `JURISDICTION_CHANGED` events through the customer-lifecycle FSM.

### D.3 Audit emission pattern

- All bank-level state transitions emit audit events through the
  `BufferedAuditPort` (ADR-027 anchor — see C.1). Application code does
  not write to ClickHouse directly; the buffer + drain pattern is the
  contract. Failure surfaces via ERROR-level log per the G-CASS-02 E2E
  evidence (caplog assertion on dual-failure path).

### D.4 Cross-links

- [`../data/README.md`](../data/README.md) — Layer 2 data-governance domain
  (GDPR Art. 30 RoPA, retention schedule, cross-border transfer assessment).
  Currently SKELETON; expansion target is D3.3.4.
- [`../compliance/README.md` §B](../compliance/README.md) — GDPR
  obligations referencing the data architecture established here.

---

## E. Security architecture

### E.1 Secret rotation policy (interim)

- ADR-032 ([decisions/ADR-032-secret-rotation-policy.md](../../decisions/ADR-032-secret-rotation-policy.md))
  installs the interim secret-rotation policy: 90-day cadence for OAuth
  client secrets, `EnvironmentFile=` (mode 0600) for systemd services, no
  secrets in `ExecStart`. Steps 1-5 merged in banxe-emi-stack; gitleaks
  pre-commit hook enabled across repos.

### E.2 Network perimeter — ufw posture

- ADR-042 ([docs/adr/ADR-042-ufw-perimeter.md](../../adr/ADR-042-ufw-perimeter.md))
  (formerly docs/adr/ADR-033 — renumbered in D3.2d.1) governs per-host
  ufw posture. This is distinct from `decisions/ADR-033` (alert routing,
  see C.2). Architecture citations must use the explicit path to avoid
  the ADR-033 number collision.

### E.3 Vault adoption — placeholder

- ADR-038 ([decisions/ADR-038-vault-adoption-placeholder.md](../../decisions/ADR-038-vault-adoption-placeholder.md))
  records the placeholder for long-term Vault / Infisical adoption.
  Anchor stack: **Sprint S17 / G-SEC-02 / Track F (DEFERRED per
  IL-OPS-TRACKS-EF-PARTIAL-CLOSURE-2026-05-11)**. The full Vault adoption
  ADR will replace this placeholder once the operator decision lands.

### E.4 Cross-links

- [`../security/README.md`](../security/README.md) — Layer 2 security
  domain: threat model, secrets policy current vs target state, KC
  hardening evidence (S12.x), historical-leak post-mortems, Tailscale ACL.
  CONTENT level since D3.2b.

---

## F. CI/CD & ops architecture

### F.1 CI smoke-gate policy

- ADR-035 ([decisions/ADR-035-ci-smoke-gate-policy.md](../../decisions/ADR-035-ci-smoke-gate-policy.md))
  Accepted (2026-05-11). 5 implementation steps merged in banxe-emi-stack
  (#100 / #101 / #113 / #105). G-CI-01 CLOSED; G-CI-02 (branch-protection
  required-check enforcement switch) pending — operator action only.

### F.2 Factory governance ADRs (post-D3.2d.1 renumber)

The following ADRs in `docs/adr/` govern factory / agent-execution
infrastructure (Layer 1 cross-reference; full ownership stays in `docs/canon/`):

- ADR-040 ([./ADR-040-ai-execution-policy.md](../../adr/ADR-040-ai-execution-policy.md))
  — AI Execution Policy (Meta-Plane vs Inference-Plane). Formerly ADR-031.
- ADR-041 ([./ADR-041-glm45-air-distributed.md](../../adr/ADR-041-glm45-air-distributed.md))
  — GLM-4.5-Air distributed inference (USB4 RPC). Formerly ADR-032.
- ADR-043 ([./ADR-043-aider-routes.md](../../adr/ADR-043-aider-routes.md))
  — Aider / Continue routes (`ai` / `ai-heavy` / `reasoning`). Formerly ADR-034.
- ADR-044 ([./ADR-044-ai-pool-roadmap-2026-05-11.md](../../adr/ADR-044-ai-pool-roadmap-2026-05-11.md))
  — AI Pool Roadmap 2026-05-11. Formerly ADR-035.

(All four were renumbered to break the ADR-031..035 collision against the
`decisions/` catalogue. See IL-PROJECT-DOCS-SPRINT-D3-2D-1-ADR-COLLISION-RENUMBER-2026-05-12
for the full mapping.)

---

## G. Crypto architecture (deferred to Sprint S21)

The following ADRs scope crypto / Ghost-Mode features. They are recorded in
the canonical catalogue for architectural completeness; implementation is
**deferred to Sprint S21 Crypto Block** (Neuronext custody, TomPay fiat-crypto,
`CryptoCompliancePort`).

- ADR-036 ([decisions/ADR-036-travel-rule.md](../../decisions/ADR-036-travel-rule.md))
  — FATF Travel Rule for crypto-asset transfers. Status: Closed (2026-05-11);
  implementation deferred to Sprint S21.
- ADR-074 ([decisions/ADR-074-stealth-and-silent-payments.md](../../decisions/ADR-074-stealth-and-silent-payments.md))
  — Stealth Addresses, Silent Payments, ZKP Identity for Ghost Mode.
  Status: PROPOSED (deferred to S21).
- ADR-075 ([decisions/ADR-075-payjoin-and-hd-privacy-score.md](../../decisions/ADR-075-payjoin-and-hd-privacy-score.md))
  — PayJoin and HD Privacy Score for Ghost Mode. Status: PROPOSED (deferred to S21).
- ADR-076 ([decisions/ADR-076-railgun-integration-decision-gate.md](../../decisions/ADR-076-railgun-integration-decision-gate.md))
  — RAILGUN Integration Decision Gate. Status: PENDING LEGAL REVIEW.

Sprint S21 Crypto Block is the owner sprint for all four ADRs above; full
project-layer expansion deferred to a dedicated D3.x sub-sprint after S21
operator decisions land.

---

## H. Open gaps for D3.3.2+

Architecture-specific MISSING target files queued for creation in later D3.3.x
sub-sprints or owner backlog sprints. Each row carries a target path, anchor,
and owner sprint.

- `docs/project/architecture/architecture-freeze-S12.md` — production-candidate
  architecture freeze (owner sprint **S12**).
- `docs/project/architecture/adr-coverage-map.md` — ADR ↔ subsystem coverage
  map (owner sprint **S12**).
- `docs/project/architecture/api-contracts.md` — API contracts inventory; will
  cross-link with [`../api/README.md`](../api/README.md) once that domain is
  expanded in D3.3.2.
- `docs/project/architecture/service-mesh.md` — service-mesh / inter-service
  call topology; awaits Sprint S15 / S20 service onboarding.
- `docs/project/architecture/deployment-topology.md` — concrete deployment
  topology (planes, hosts, ports); high-level reference is `docs/PLANES.md`.
- `docs/project/architecture/audit-trail-architecture.md` — audit-trail
  architecture under ADR-027 (owner sprint **S14**).
- `docs/project/architecture/webhook-reliability-architecture.md` — webhook
  reliability architecture under ADR-034 (owner sprint **S15**).
- `docs/project/architecture/alert-routing-architecture.md` — alert-routing
  architecture under ADR-033 (owner sprint **S16**).
- `docs/project/architecture/secret-rotation-architecture.md` — secret rotation
  under ADR-032 (owner sprint **S17**).
- `docs/project/architecture/backup-restore-architecture.md` — backup + restore
  under ADR-029 (owner sprint **S18**).
- `docs/project/architecture/auth-rate-limit-architecture.md` — auth rate-limit
  under ADR-030 (owner sprint **S19**).
- `docs/project/architecture/ci-smoke-gate-architecture.md` — CI smoke-gate
  under ADR-035 (owner sprint **S20**).
- `docs/project/architecture/event-bus-architecture.md` — event bus +
  `KycReTriggerEvent` reconciliation, anchored on ADR-028 (owner sprint
  **S14–S15**).

### Carried-forward items (not architecture-specific but visible from this domain)

- **20 UNKNOWN-status ADRs** still need a `**Status:**` header backfill
  (per IL-PROJECT-DOCS-SPRINT-D3-2D-3-ADR-INDEX-UNIFIED-2026-05-12 §"Parse
  failures"). 15 in `decisions/` (ADR-001, 002, 003, 004, 005, 006, 008,
  009, 010, 011, 016, 017, 024, 025, 026) and 5 in `docs/adr/` (ADR-039,
  040, 041, 042, 043). Queued for a later D3.2d sub-sprint.
- **Stale worktrees**: 3 housekeeping items flagged for cleanup outside
  this README scope; not blocking D3.3 progression.
- **G-FACTORY-05**: registered in `GAP-REGISTER.md` via D3.2d.4. Resolution
  before any S12.4 prod realm-provisioning touches `banxe-emi`.

---

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
| `docs/project/architecture/api-contracts.md`                             | API contracts inventory                        | D3.3.2 api domain pairing                                   | D3.3.2 / S15 |
| `docs/project/architecture/service-mesh.md`                              | Service mesh / inter-service call topology     | S15 / S20 service onboarding                                | S15 / S20    |
| `docs/project/architecture/deployment-topology.md`                       | Deployment topology (planes / hosts / ports)   | `docs/PLANES.md` high-level                                  | S12          |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md (unified)](../../adr/INDEX.md)
- ↔ Sibling domains:
  [api](../api/README.md) ·
  [runbooks](../runbooks/README.md) ·
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [data](../data/README.md) ·
  [operations](../operations/README.md) ·
  [governance](../governance/README.md)
