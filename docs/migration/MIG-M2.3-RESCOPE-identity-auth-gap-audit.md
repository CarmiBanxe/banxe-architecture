# MIG-M2.3 — RE-SCOPE: identity/auth reconcile / gap-audit (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M2.3-RESCOPE-identity-auth-gap-audit.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. ADR-102 Duplication Audit. Resolves the MIG-M2.3 blocker (PR #632 / IL-389) per pre-authorised operator decision A. KYC/KYB/AML carve-out (I-27). -->

> **Resolves** the MIG-M2.3 blocker (identity/auth already exists in banxe-emi-stack; PR #632 / IL-389).
> **Operator pre-authorised decision A — reconcile/gap-audit** (as MIG-M2.4 / MIG-M2.5). ADR-102
> Duplication Audit of legacy `banxe-auth-backend` (canonical auth, M1.4.1) + `banxe-identity` vs the
> existing emi-stack surface → delta + keep/merge/retire. **No scaffold, no code, no merge.**
> **KYC/KYB/AML = regulated carve-out — advisory-descriptive only; no code without operator/governance
> sign-off (I-27 HITL-L4).** Audited read-only.

## 1. Re-scope rationale (anti-duplication)

Mandatory preflight found a **mounted** identity/auth/KYC surface already in banxe-emi-stack. A new
`IdentityAuthPort` would duplicate it → **ADR-102 HARD RULE: reconcile, not scaffold** (same posture as
MIG-M2.4 open-banking + MIG-M2.5 ABS).

## 2. Legacy scope (canonical, per MIG-M1.4 / M1.4.1)

- **`banxe-auth-backend`** (`banxe-fiat-backend/banxe-auth-backend`, **canonical auth** per M1.4.1):
  `srp`, `token`, `.well-known`/**JWKS**, `api-key`, `scope`, `project`, `session`, `login-history`,
  `user` (+ `keystore`, `jwt-token`, `convert-key`).
- **`banxe-identity`** (`banxe-fiat-backend/banxe-identity`): heavily **regulated** —
  `bkyc` + `bkyc-document`, **`sumsub-connector` + `sumsub-connector-applicant`**,
  `scoring-risk-level`, `companies-documents` (KYC/KYB/AML carve-out); plus identity-adjacent
  `dictionary`, `crm-connector`, `files`; cross-cutting `messanger`, `amplitude`, `users-notification`.
- **`banxe_auth`** = **frontend** (package.json + public + src) → re-home to frontend (M2.8).
- **Auth variants** (retire): `auth-service`, `banxe-tx-auth`, `banxe_auth`(FE), `banxe-auth-old`,
  `common_auth_web`, `banxe-auth`, `auth-api`, `banxe-identity-config-manager` (config).
- Auth contract / `auth-connector` canonical = `banxe-shared-libs` (MIG-M2.0).

## 3. Existing emi-stack surface (audited, mounted)

- **auth:** `api/routers/auth.py` (thin; `AuthApplicationService` + `ScaApplicationService`; SCA
  verify/resend/methods) + `api/models/{auth,sca,sca_adapters}.py`.
- **identity-core:** `api/routers/customers.py` (onboard/list/profile/lifecycle) +
  `customer_lifecycle.py` (FSM) + `api/models/customers.py`.
- **regulated KYC/KYB/AML (carve-out):** `api/routers/kyc.py` (workflows/documents/MLRO approve-EDD) +
  `kyb_onboarding.py` + `adverse_media.py` (sanctions) + `consent_management.py` + `fos_escalation.py`
  + `api/models/kyc.py` + compliance services (`case_management/marble_adapter`, `compliance_automation/*`).

## 4. Delta / gap-matrix

| Capability | Legacy | emi-stack | Status |
|---|---|---|---|
| Login / refresh / SCA | banxe-auth-backend | `auth.py` (+SCA) | **covered** |
| **SRP** (secure remote password) | `srp` | — | **GAP → port (auth)** |
| **JWKS / `.well-known`** | `.well-known` | — | **GAP → port (auth)** |
| **API-key management** | `api-key` | — | **GAP → port (auth)** |
| **Scopes / projects** | `scope`, `project` | partial (SCA only) | **GAP → port (auth)** |
| Session / login-history | `session`, `login-history` | — | **GAP → port (auth)** |
| Customers / profile / lifecycle | banxe-identity adjacent | `customers.py` + FSM | **covered** |
| Dictionary / CRM connector / files | banxe-identity | — | **GAP → port/re-home (identity-core)** |
| **KYC (`bkyc`, documents)** | banxe-identity | `kyc.py` | **carve-out — descriptive** |
| **Sumsub connector (+applicant)** | banxe-identity | (KYC workflow) | **carve-out — descriptive (no code w/o sign-off)** |
| **Scoring / risk-level** | banxe-identity | (compliance services) | **carve-out — descriptive** |
| **KYB / companies-documents** | banxe-identity | `kyb_onboarding.py` | **carve-out — descriptive** |
| messanger / amplitude / users-notification | banxe-identity | — | **re-home → notifications / analytics** |

## 5. Decision (keep / merge / retire) — ADR-102

| Item | Decision | Rationale |
|---|---|---|
| emi-stack `auth.py` (+SCA app services) | **KEEP — canonical auth home** | mounted; thin-router pattern |
| Legacy auth delta (SRP / JWKS / api-key / scopes / projects / session / login-history) | **MERGE → port additively into emi-stack auth** | per-capability substeps; canonical source = `banxe-auth-backend` (M1.4.1) |
| emi-stack `customers.py` + `customer_lifecycle.py` | **KEEP — identity-core home** | mounted FSM |
| Legacy identity-adjacent (dictionary / crm / files) | **MERGE → port/re-home** | identity-core or documents |
| **KYC/KYB/AML (bkyc / sumsub / scoring / kyb / companies-docs)** | **CARVE-OUT — advisory-descriptive; NO code without operator/governance sign-off (I-27 HITL-L4)** | regulated; CLAUDE.md never-skip-AML/KYC |
| `banxe_auth` (frontend) | **RE-HOME → frontend (M2.8)** | not backend auth |
| messanger / amplitude / notification | **RE-HOME → notifications / analytics** | cross-cutting |
| `auth-api` + auth-variants (auth-service / banxe-tx-auth / banxe-auth-old / common_auth_web / banxe-auth / config-manager) | **RETIRE** | canonical = `banxe-auth-backend` (M1.4.1); historical tails |
| `auth-connector` contract | **KEEP canonical = `banxe-shared-libs`** (M2.0) | single contract |

**Single identity/auth bounded context confirmed:** auth home = emi-stack `auth.py` (canonical source
`banxe-auth-backend`); identity-core home = emi-stack customers/lifecycle; KYC/KYB/AML = mounted
regulated carve-out. No parallel port.

## 6. KYC/KYB/AML carve-out status (gate)

The regulated layer (bkyc / sumsub / scoring-risk-level / kyb / companies-documents / adverse-media /
MLRO approve-EDD) is **NOT touched** in this migration. Any port/change requires **operator/governance
sign-off (I-27 HITL-L4)** and stays fail-closed per project canon. Status: **PENDING sign-off** —
documented advisory-descriptive only.

## 7. Preconditions / next + remaining M2 follow-ups

- **MIG-M2.3 closed as reconcile** (not scaffold). Auth delta ports (SRP/JWKS/api-key/scopes/session)
  + identity-adjacent re-home = scheduled substeps, no merge.
- **KYC/KYB/AML carve-out** = pending operator/governance sign-off (I-27).
- **Remaining M2 follow-ups:** M2.4-INT (open-banking integration) + M2.4a–e (OB delta ports);
  M2.5-BIF (Bifrost Wave D) + ABS delta/re-home; M2.3 auth delta ports + identity re-home.
- **M2.8 (frontend)** = after the frontend roster audit (banxe-platform vs banxe-ui, deferred per
  MIG-M2.7); `banxe_auth` (FE) re-homes there.
- Correct the M2-sequencing note: **M2.3 = reconcile (done), not scaffold.**

## References
`docs/migration/MIG-M2.3-RESCOPE-identity-auth-gap-audit.md`; `MIG-M2.3-BLOCKER-identity-auth-already-exists.md`
(IL-389, PR #632); read-only legacy `banxe-fiat-backend/{banxe-auth-backend,banxe-identity}` (+ auth-variants,
`banxe_auth` FE, `banxe-identity-config-manager`) + banxe-emi-stack `api/routers/{auth,customers,customer_lifecycle,kyc,kyb_onboarding,adverse_media}.py`
+ `api/models/{auth,sca,customers,kyc}.py`; MIG-M1.4 / M1.4.1 (identity/auth boundary + auth dup-audit),
MIG-M2.0 (auth-connector canonical), MIG-M2.4 / M2.5 (reconcile precedents), MIG-M2.7 (frontend roster
deferral); ADR-102, ADR-103, ADR-059-A, I-27, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
