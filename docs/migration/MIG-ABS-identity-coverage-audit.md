# MIG — ABS / identity / auth coverage-audit (single sweep) — BANXE.RAR → EMI

<!-- Source: docs/migration/MIG-ABS-identity-coverage-audit.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only, read-only sweep | No code, no scaffold, no merge. -->

> **Single read-only coverage sweep** of the remaining ABS / identity / auth delta — classifying every
> item **covered / partial / genuine-gap in one pass**, replacing a series of per-substep blocker→covered
> cycles (governance observation: 5 consecutive substeps resolved as covered/reconcile). **No code, no
> scaffold, no merge.** Audited read-only on banxe-emi-stack origin/main `3228d3d` + legacy
> `banxe-fiat-backend/{abs-api,banxe-auth-backend}`.

## 1. Scope

Remaining non-regulated delta after M2.x + abs-posting closure: ABS sub-services (scoring, agreement,
customer-contract, credential, legal-entity, info-field, process/cron), abs-customer re-home, and the
M2.3 auth delta (SRP, JWKS, api-key, scope, session, login-history). One grep sweep over `services/` +
`api/`, cross-referenced to legacy sources.

## 2. Coverage matrix — ABS sub-services

| Legacy item (abs-api) | Existing emi-stack capability (evidence) | Status | Note |
|---|---|---|---|
| `abs-scoring` | `services/risk_management/` (`risk_scorer.py`, `risk_aggregator`, `threshold_manager`, `risk_agent`) + `services/lead_scoring/` + `services/audit_dashboard/risk_scorer.py` | **COVERED** | risk/scoring engines present; ABS-specific score = thin rule if needed |
| `abs-agreement` | **`services/agreement/`** (`agreement_port.py`, `agreement_service.py`) | **COVERED** | dedicated agreement service |
| `abs-customer-contract` | `services/customer/` (`customer_port`, `customer_service`) + `services/agreement/` | **PARTIAL** | contract semantics via customer+agreement; no dedicated "contract" entity |
| `abs-credential` | `services/auth/` (`auth_application_service`, `otp_delivery_port`, sca/legacy adapters) | **PARTIAL** | credential = auth domain; ABS-credential maps to auth (no dedicated ABS credential store) |
| `abs-legal-entity` | `services/customer/customer_port.py` + **`services/kyb_onboarding/`** (`companies_house_adapter`, `ubo_registry`, `application_manager`) | **COVERED** (carve-out-adjacent) | KYB/legal-entity present; **KYB touches the regulated carve-out → any code = I-27 gated** |
| `abs-info-field` | — (no match) | **GENUINE-GAP** | small descriptive field-metadata service; not present |
| `abs-process` / `abs-cron-process` | `services/scheduled_payments/schedule_executor` (M2.4a) + `services/compliance_automation/` + `services/events/event_bus.py` | **PARTIAL** | generic process/event/scheduler infra exists; no dedicated ABS workflow orchestration |

## 3. Coverage matrix — abs-customer re-home

| Legacy item | Re-home target (evidence) | Status |
|---|---|---|
| `abs-customer` | `api/routers/customers.py` + `api/routers/customer_lifecycle.py` + `api/models/customers.py` + `services/customer/{customer_port,customer_service}.py` | **COVERED** (re-home target exists; identity-core home) |

## 4. Coverage matrix — auth delta (vs legacy `banxe-auth-backend` dirs: api-key, login-history, scope, session, srp, token, user)

| Legacy auth item | Existing emi-stack capability (evidence) | Status |
|---|---|---|
| **SRP** (secure remote password) | — (no match in `services/auth`; only `voice_support` false-positive) | **GENUINE-GAP** |
| JWKS / `.well-known` | `services/auth/legacy/jwks_models.py` | **COVERED** |
| api-key | `services/api_gateway/api_key_manager.py` | **COVERED** |
| scope | `services/auth/legacy/jwks_models.py` + `legacy_sca_adapter` | **COVERED** |
| session | `services/auth/auth_application_service.py` + `token_manager.py` | **COVERED** |
| token / user | `services/auth/token_manager.py` + `api/.../customers` | **COVERED** |
| credential / 2FA / SCA | `services/auth/` (`sca_*`, `two_factor`, `otp_delivery_port`, rate_limiter) | **COVERED** |
| **login-history** | — (no match) | **GENUINE-GAP** |

(auth surface is mounted via `api/routers/auth.py` + `AuthApplicationService` / `ScaApplicationService`,
per MIG-M2.3.)

## 5. Decision per row + genuine-gap shortlist

**Decisions:** COVERED rows → **done-by-existing** (legacy retire-after); PARTIAL rows → **consume/extend
existing** (thin rule/adapter only if a distinct ABS mapping is product-required — not a new
bounded-context scaffold); abs-customer → **re-home to existing customers/identity** (covered).

**Genuine-gap shortlist (the only real port candidates):**
1. **SRP** (auth) — secure-remote-password login strategy; absent from `services/auth`. Port candidate
   behind the existing auth surface (canonical source `banxe-auth-backend/srp`).
2. **login-history** (auth) — login audit/history; absent. Port candidate behind the existing auth
   surface (`banxe-auth-backend/login-history`).
3. **abs-info-field** (ABS) — descriptive ABS field-metadata; absent. Small advisory port candidate.

Everything else (scoring, agreement, contract, credential, legal-entity, process/cron, abs-customer,
JWKS, api-key, scope, session, token) = **COVERED / PARTIAL — no scaffold**.

## 6. KYC/KYB/AML carve-out status

- `abs-legal-entity` resolves to **`kyb_onboarding`** (KYB) — **regulated carve-out**. Any code there =
  **pending operator/governance sign-off (I-27 HITL-L4)**; read-only descriptive only here.
- All KYC/KYB/AML items remain gated; this audit touches none of them in code.

## 7. Next-action plan (point scaffolds for the 3 genuine-gaps)

Replace the per-substep blocker series with **3 targeted scaffolds** (each: mandatory preflight →
advisory/server-side → paired PR + arch IL → CI-gated → no merge), ordered low-risk first:
1. **abs-info-field** (ABS advisory descriptive surface; smallest, no auth/regulated touch).
2. **login-history** (auth audit; behind existing auth surface; non-credential).
3. **SRP** (auth login strategy; behind existing auth surface; **security-sensitive — extra review**).

Then: M2.4c–e (OB delta, preflight-first) · M2.8 frontend (after roster audit). **KYC/KYB/AML stays
gated on I-27.** Each genuine-gap scaffold still runs its own preflight (this sweep narrows the field; it
does not pre-authorise skipping preflight).

## References
`docs/migration/MIG-ABS-identity-coverage-audit.md`; read-only origin/main `3228d3d` banxe-emi-stack
`services/{risk_management,lead_scoring,agreement,customer,kyb_onboarding,auth,scheduled_payments,
compliance_automation,api_gateway}/*` + `api/routers/{customers,customer_lifecycle,auth}.py` +
`api/models/customers.py` + `services/auth/legacy/jwks_models.py`; legacy
`banxe-fiat-backend/{abs-api,banxe-auth-backend}`; MIG-M2.3 (identity/auth reconcile), MIG-M2.5 (ABS
reconcile), MIG-ABS-posting (covered), MIG-M2.4a (covered); ADR-102, ADR-103, ADR-059-A, I-27, I-28;
/tmp/banxe-migration-mapping-v0.claude.txt.
