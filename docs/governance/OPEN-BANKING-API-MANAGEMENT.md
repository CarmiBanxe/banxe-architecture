# Open Banking / API Management — Governance Canon (S5)

<!-- Source: docs/governance/OPEN-BANKING-API-MANAGEMENT.md | Sprint: S5 (Open Banking / API Management) | Date: 2026-06-22 | Lane: governance canonicalization | docs-only | NO new implementation, NO scaffold, NO merge. ADR-102 reference-not-duplicate. -->

> **STATUS: GOVERNANCE CANON.** This document is a **management / governance canon** layered over the
> **ALREADY-EXISTING, FCA-wired** Open Banking + API surface in `banxe-emi-stack`. It **creates no code,
> no model, no router, no port, no YAML API artifact.** Per the **ADR-102 HARD RULE** (no new structure
> without repo-wide duplication verification; fail-closed on uncertainty) and the operator decision of
> **2026-06-21 (A — reconcile/gap-audit, NOT scaffold)**, S5 produces **governance only** and references
> the prior read-only audits rather than duplicating their subject. Any temptation to scaffold an
> `open_banking` / `psd2` / `consent` / `api_gateway` artifact is a **canon violation → STOP.**

---

## 1. Purpose & scope

**Purpose.** Establish the **governance and management canon** for Banxe's Open Banking (PSD2 / OBIE)
and broader public-API surface: who owns it, how it is versioned, how backward compatibility and
deprecation are governed, the regulatory posture (AISP / PISP / CBPII), partner / TPP integration
governance, and the open items awaiting an operator decision.

**Scope (in).** Governance rules, ownership / RACI, policy statements, and a pointer-inventory of the
existing surface. **The surface already exists and is FCA-wired** — this canon governs it, it does not
build it.

**Scope (out — ADR-102 fail-closed).** This sprint **MUST NOT**:

- scaffold or create any `*.py` router / model / port (e.g. a new `api/routers/open_banking.py` would
  **collide on the exact filename** of the existing one and duplicate a more mature surface);
- create any `*.yaml` API / OpenAPI / passport artifact;
- modify, mount, merge, or retire any existing router;
- introduce a second/parallel Open Banking bounded context.

Concrete API design parameters (version scheme, sunset windows, TPP onboarding workflow, gateway runtime
config) that are **not repo-asserted** are marked **AWAITS OPERATOR** — they are **not invented** here.

---

## 2. Existing API surface inventory (POINTERS — do not duplicate)

The following is a **reference inventory** drawn from the prior read-only audits. Endpoint names are
reproduced **only as already enumerated in those audits** — no router source is opened or copied here.

### 2.1 Open Banking / PSD2 routers (canonical home = `banxe-emi-stack`)

| Router (pointer) | Ledger ref | Covers (per audits) | Mount / wiring status (per RESCOPE audit, origin/main `1a90a41`) |
|---|---|---|---|
| `api/routers/open_banking.py` | IL-OBK-01 (Phase 15) | **AISP consents** (create / get / **authorise** / revoke) + **PISP** `/payments` initiate + `/payments/{id}/status` + `/accounts` + `/aspsps` | **MOUNTED** (`include_router` ✓); PISP status = **mock**; **0 refs** to PaymentEnginePort (M2.1) / accounts SoT (M2.2); HITL ×1 |
| `api/routers/psd2_gateway.py` | IL-PSD2GW-01 (adorsys XS2A AISP) | `/psd2/consents` (HITL L4) + `/psd2/accounts` + `/psd2/transactions` + `/psd2/balances` + auto-pull | imported ✓ but **NOT mounted** (`include_router` ✗); **live** adorsys XS2A; `balance_amount: str` (DecimalString I-01); IBAN (I-02); HITL ×5 |
| `api/routers/consent_management.py` | IL-CNS-01 (Phase 49) | consent grants / validate + **PISP** `/pisp/initiate` + **AISP** `/aisp/complete` + **CBPII** `/cbpii/check` (confirmation of funds) + **TPP registry** | imported ✓ but **NOT mounted** (`include_router` ✗); live (7 client refs); HITL ×10 |

> **Models:** no dedicated `open_banking` / `psd2` / `consent` model module — inline schemas +
> `api/models/payments.py` (per RESCOPE audit). Stated for inventory; **not** an instruction to create one.

### 2.2 API gateway / versioning surface (per `m_gateway_api_governor.yaml` passport)

The API-governor passport asserts the gateway and versioning surface **already exists** in
`banxe-emi-stack` (GAP-023 DONE) and is **explicitly off-limits to reimplementation**:

- `services/api_gateway/*` — `api_key_manager`, `rate_limiter`, `quota_manager`, `ip_filter`,
  `request_logger`, `gateway_agent` (GAP-023 DONE).
- `api/routers/api_gateway.py`, `api/routers/api_versioning.py`, `api/routers/psd2_gateway.py`.

> Passport `non_goals` explicitly forbid reimplementing any of the above or duplicating their passports.

### 2.3 API governance agent (passport — PROPOSED, not activated)

`agents/passports/m_gateway_api_governor.yaml` — `MGatewayApiGovernor` (L2, AMBER, CTX-01):
curates the unified public-API surface; reviews OpenAPI publication + versioning policy; oversees PSD2
endpoint exposure. **Status: PROPOSED (I-27) — PROPOSES only, NOT activated until a separate operator
gate.** Owner: CTIO; approvers: CTIO + COO; change_class CLASS_B.

---

## 3. API Management governance

Governance **rules** (the *what / who decides*). Concrete numeric parameters live in repo config
(Config-over-Hardcoding, CLAUDE.md §10), not here; where not repo-asserted → **AWAITS OPERATOR**.

### 3.1 Versioning policy

- **Rule:** every change to a public / PSD2 / OBIE-facing API contract is governed by the API-governor
  channel (`MGatewayApiGovernor`, once activated) and reviewed against the FCA Open Banking
  versioning & change-management standard (passport `fca_references`).
- **Rule:** versioning is enforced through the **existing** `api/routers/api_versioning.py` surface —
  **no new versioning module** is created (ADR-102; passport non-goal).
- **Concrete version scheme** (e.g. URI vs header versioning, semver mapping, OBIE version pinning) =
  **AWAITS OPERATOR** — not repo-asserted, not invented.

### 3.2 Backward-compatibility policy

- **Rule:** breaking changes to a published contract require an API-governor review + CTIO approval
  (CLASS_B governance) before publication; additive (non-breaking) changes follow the normal
  Quality-Gate path.
- **Rule:** TPP-facing contracts must preserve backward compatibility across a deprecation window
  (see §3.3); a breaking change without a sunset plan is rejected.
- **Concrete compatibility guarantees** (N-1 support depth, contract-test gate) = **AWAITS OPERATOR**.

### 3.3 Deprecation / sunset policy

- **Rule:** deprecation is a governed lifecycle: announce → deprecate (still served) → sunset (removed),
  each transition logged via `AuditPort` (I-08) and gated by CTIO (CLASS_B).
- **Concrete sunset windows / notice periods** (retention, escalation thresholds) are governance
  parameters and **MUST** live in repo config, not in code or this canon (CLAUDE.md §10) →
  **AWAITS OPERATOR** for the values.

---

## 4. Open Banking / PSD2 / OBIE compliance posture

### 4.1 Coverage map (references existing routers — see §2.1)

| OBIE / PSD2 role | Existing coverage (pointer) | FCA-wiring / status (per audits) |
|---|---|---|
| **AISP** — account-access consents | `open_banking.py` (mounted) + `consent_management.py` `/aisp/complete` (unmounted, richer) | FCA-wired; consent lifecycle present |
| **AISP** — accounts / balances / transactions | `open_banking.py` `/accounts` (mounted) + `psd2_gateway.py` balances/transactions (unmounted) | **partial** — psd2 detail not exposed (mount gap) |
| **PISP** — domestic payment initiation | `open_banking.py` `/payments` + `consent_management.py` `/pisp/initiate` | **partial** — initiation status = **mock**; 0 PaymentEnginePort (M2.1) refs |
| **CBPII** — confirmation of funds | `consent_management.py` `/cbpii/check` (unmounted) | **partial** — check only, unmounted |
| **adorsys XS2A** dedicated interface | `psd2_gateway.py` (unmounted) | **live** XS2A; DecimalString (I-01), IBAN (I-02); HITL ×5 |
| **TPP registry / HITL gating** | `consent_management.py` + `psd2_gateway.py` | emi-stack-only; HITL ×16 total across the three routers |

### 4.2 Posture statements

- **Single bounded context:** the canonical Open Banking home = `banxe-emi-stack` (confirmed by the
  RESCOPE audit). **No second/parallel surface** is permitted (ADR-102).
- **Mount gap (governance item):** `psd2_gateway` + `consent_management` are present + tested but
  **not mounted** into the app. Decision **expose vs intentionally-unmounted** = **REVIEW** (own
  substep) — see §8.
- **Live-execution guard (ADR-103 PART 2):** no live payment initiation/execution and **no
  funds-confirmation against live balances** in any advisory path; funds-confirmation stays
  descriptive/sandbox; live execution stays operator-gated.
- **FCA references** (per passport): PSRs 2017 + PSD2 RTS (dedicated interface / API exposure);
  OpenAPI 3.x publication; FCA Open Banking versioning & change management.

---

## 5. Partner / TPP integration governance

- **TPP registry:** maintained by the **existing** `consent_management.py` surface (TPP registry per
  audits) — governed, not rebuilt.
- **Rule:** TPP onboarding/offboarding and consent grants are HITL-gated (the three routers carry
  HITL ×16 total); CBPII / AISP / PISP grants follow the consent lifecycle already implemented.
- **Vendor integration gate:** per ORG-STRUCTURE §2.7.3, third-party integrations (e.g. Modulr) are
  gated by **COO** with CTIO ownership of integration management (JOB-DESCRIPTIONS, CTIO core duties).
- **Concrete TPP onboarding policy** (eIDAS/QWAC cert handling, sandbox→prod promotion criteria,
  per-TPP rate/quota tiers) = **AWAITS OPERATOR** — not repo-asserted.

---

## 6. API gateway governance

- **Reference:** `agents/passports/m_gateway_api_governor.yaml` (`MGatewayApiGovernor`) is the
  governance/orchestration channel over the **existing** `services/api_gateway/*` (GAP-023 DONE).
  It **routes to**, and never reimplements, that surface (passport non-goals).
- **Rule:** gateway concerns — API keys, rate limiting, quota, IP filtering, request logging — are
  owned by the existing `services/api_gateway/*` modules; governance changes flow through the
  API-governor channel (once activated) with CTIO + COO approval (CLASS_B).
- **Activation:** the API-governor channel is **PROPOSED / not activated** (I-27) — activation is a
  **separate operator gate**.
- **Concrete gateway runtime config** (rate-limit tiers, quota ceilings, IP allowlists, key-rotation
  cadence) lives in repo config (CLAUDE.md §10) → **AWAITS OPERATOR** for the values.

---

## 7. Roles & RACI (API / platform governance)

Repo-asserted owners (JOB-DESCRIPTIONS.md, ORG-STRUCTURE.md §2.7, passport governance block):

| Concern | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| API platform architecture / reliability | Platform agents | **CTIO (SMF26)** | COO | CEO |
| Open Banking / PSD2 surface ownership | API-governor (PROPOSED) | **CTIO** | COO, MLRO (compliance-adjacent) | CEO |
| API versioning / backward-compat / deprecation | API-governor (PROPOSED) | **CTIO** | COO | — |
| Gateway runtime (keys/rate/quota) | `services/api_gateway/*` | **CTIO** | COO | — |
| Vendor / TPP integration gate | Integration owner | **CTIO** (integration mgmt) | **COO** (gate) | CEO |
| API-governor channel **activation** | — | **Operator** (separate gate) | CTIO, COO | — |

- **Dedicated API/Platform product owner** (distinct from CTIO line) = **AWAITS OPERATOR** if a role
  separate from the SMF26 Technology function is intended.

---

## 8. Open-items register

| # | Item | State | Owner | Ref |
|---|---|---|---|---|
| O-1 | **Version scheme** (URI/header, semver, OBIE pinning) | **AWAITS OPERATOR** | CTIO | §3.1 |
| O-2 | **Backward-compat depth** (N-1 support, contract-test gate) | **AWAITS OPERATOR** | CTIO | §3.2 |
| O-3 | **Sunset windows / notice periods** (config values) | **AWAITS OPERATOR** | CTIO | §3.3 |
| O-4 | **Mount gap** — expose vs intentionally-unmounted `psd2_gateway` / `consent_management` | **REVIEW** (own substep) | CTIO | §4.2, RESCOPE §5 |
| O-5 | **TPP onboarding policy** (QWAC/eIDAS, sandbox→prod, per-TPP tiers) | **AWAITS OPERATOR** | CTIO/COO | §5 |
| O-6 | **Gateway runtime config** (rate/quota/IP/key-rotation) | **AWAITS OPERATOR** | CTIO | §6 |
| O-7 | **API-governor channel activation** | **AWAITS OPERATOR** (separate gate, I-27) | Operator | §6, passport |
| O-8 | **Legacy `banxe-open-banking` (NestJS) reconcile** — delta ports (domestic-scheduled, standing-orders, file-payments, international-scheduled, intl funds-confirmation, CBPII lifecycle); top-level **RETIRE after delta ported**; nested `fiat-backend/banxe-open-banking` **RETIRE (duplicate)** | **MERGE-then-RETIRE pending** (per RESCOPE §5) | CTIO | RESCOPE §5/§6 |
| O-9 | **Three-router internal consolidation** (`open_banking` / `psd2_gateway` / `consent_management`) | **CONSOLIDATE** (separate governance-gated substep) | CTIO | RESCOPE §5 |
| O-10 | **M2.1 / M2.2 wiring** — PISP→PaymentEnginePort, accounts→SoT projection (currently 0 refs) | **MIG-M2.4-INT pending** (optional, no merge) | CTIO | RESCOPE §6 |
| O-11 | **Dedicated API/Platform product owner** distinct from SMF26 | **AWAITS OPERATOR** | — | §7 |

---

## 9. Canon sources (cite — not duplicated)

- `docs/migration/MIG-M2.4-BLOCKER-open-banking-already-exists.md` (IL-381, PR #624) — existing-surface
  inventory + ADR-102 stop (no scaffold).
- `docs/migration/MIG-M2.4-RESCOPE-open-banking-gap-audit.md` — legacy vs emi-stack gap audit; keep /
  merge / retire decisions; mount/wiring status (origin/main `1a90a41`).
- `docs/migration/MIG-M1.1-open-banking-dup-audit.md` — duplication audit (legacy canonical scope).
- `agents/passports/m_gateway_api_governor.yaml` — API governor passport (PROPOSED; gateway / versioning
  non-goals; FCA references; CTIO/COO governance).
- `docs/JOB-DESCRIPTIONS.md`, `docs/ORG-STRUCTURE.md` §2.7 (CTO / AI Platform, SMF26) — API/platform
  ownership.
- Existing routers (referenced by path only, **not** opened/duplicated):
  `banxe-emi-stack` `api/routers/{open_banking,psd2_gateway,consent_management,api_gateway,api_versioning}.py`;
  `services/api_gateway/*` (GAP-023).
- ADR-102 (no smart refactor without duplication verification), ADR-103 (server-only + promotion gate),
  ADR-059-A (sharded ledger), ADR-060 (branch naming), I-01, I-02, I-08, I-27, I-28; CLAUDE.md §10
  (Config-over-Hardcoding).

---

## 10. Provenance footer

- **Sprint:** S5 — Open Banking / API Management (governance canonicalization).
- **Produced:** 2026-06-22, branch `agent/factory/openbanking/s5-api-management-canon`, from
  `origin/main` `aaa8d49`.
- **Anti-duplication:** ADR-102 reference-not-duplicate — **zero** new API code / model / router / port /
  YAML created; this is a governance doc + one append-only ledger shard only.
- **Decision basis:** operator 2026-06-21 = **A (reconcile/gap-audit, not scaffold)**.
- **Unknowns:** every non-repo-asserted parameter is marked **AWAITS OPERATOR** (§8) — nothing invented.
- **Disposition:** DO NOT MERGE — governance review pending.
