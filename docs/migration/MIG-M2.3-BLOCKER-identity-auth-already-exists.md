# MIG-M2.3 — BLOCKER: identity/auth surface already exists in banxe-emi-stack (no scaffold)

<!-- Source: docs/migration/MIG-M2.3-BLOCKER-identity-auth-already-exists.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. ADR-102 duplication stop-barrier. KYC/KYB/AML carve-out (I-27). -->

> **STATUS: BLOCKED.** Mandatory read-only preflight + ADR-102 Duplication Audit stopped MIG-M2.3
> **before any scaffold.** banxe-emi-stack **already implements a mounted identity / auth / KYC
> surface.** Scaffolding a new `IdentityAuthPort` would duplicate it → **STOP, no scaffold** (ADR-102
> HARD RULE, fail-closed). Same anti-dup posture as the MIG-M2.4 / MIG-M2.5 blockers. Docs-only blocker
> report + IL-shard. **KYC/KYB/AML = regulated carve-out — advisory-descriptive only; no code without
> operator/governance sign-off (I-27 HITL-L4).**

## 1. Preflight outcome (read-only, origin/main 1a90a41)

Existing surface found and **mounted** in `api/main.py`, classified into three layers:

| Layer | Existing in emi-stack | Mounted? |
|---|---|---|
| **auth** (login/token/SCA/session) | `api/routers/auth.py` (thin router; `AuthApplicationService` + `ScaApplicationService`; SCA verify/resend/methods) + `api/models/{auth,sca,sca_adapters}.py` | **MOUNTED** (main.py:175) |
| **identity-core** (customers/profile/lifecycle) | `api/routers/customers.py` (onboard/list/profile/lifecycle) + `api/routers/customer_lifecycle.py` (FSM) + `api/models/customers.py` | **MOUNTED** (176, 306) |
| **regulated KYC/KYB/AML (carve-out)** | `api/routers/kyc.py` (KYC/KYB workflows, documents, MLRO approve-EDD) + `kyb_onboarding.py` + `adverse_media.py` (sanctions/adverse-media) + `consent_management.py` + `fos_escalation.py` + `api/models/kyc.py` + compliance services (`case_management/marble_adapter`, `compliance_automation/*`) | **MOUNTED** (177, 185, …) |

## 2. Why scaffold is blocked

MIG-M2.3 proposed a new `IdentityAuthPort` (ABC) + identity/auth DTOs. **The auth + identity-core
layers already exist and are mounted** (auth.py/customers.py/customer_lifecycle.py). A new port would
duplicate them (parallel to `AuthApplicationService`/customers) → ADR-102 violation (existing surface
has registered consumers + tests). **STOP, no scaffold.** (Mirrors MIG-M2.4 open-banking and MIG-M2.5
ABS — the EMI backend already carries these domains.)

## 3. KYC/KYB/AML carve-out (regulated — gate)

The KYC/KYB/AML layer (`kyc.py`, `kyb_onboarding.py`, `adverse_media.py`, compliance services, MLRO
approve-EDD) is a **regulated carve-out**. Per project canon (CLAUDE.md: never skip AML/KYC validation;
I-27 HITL-L4): **no code is written/changed in this layer without explicit operator/governance
sign-off.** In this migration it is treated as **advisory-descriptive only** — documented, not touched.

## 4. Decision (pre-authorised: A — reconcile/gap-audit)

Per the MIG-M2.3 scenario the operator pre-authorised **decision A** (reconcile/gap-audit, as
MIG-M2.4 / MIG-M2.5). The reconcile is filed as the paired follow-up doc
`MIG-M2.3-RESCOPE-identity-auth-gap-audit.md`: legacy `banxe-auth-backend` (canonical auth, M1.4.1) +
`banxe-identity` (identity-core) **vs** the existing emi-stack surface → delta + keep/merge/retire;
auth-api / auth-variants retire; KYC/KYB/AML stays carve-out (no code without sign-off).

## 5. What was / was NOT done

- **Done (read-only):** mandatory preflight (api/ grep + main.py registration) + repo-wide
  (services/, src/) identity/auth/kyc audit; classification (auth / identity-core / KYC carve-out);
  this blocker doc + IL-shard (isolated worktree, Rule 1/6).
- **NOT done:** no scaffold (any repo); no `IdentityAuthPort`/DTO created; no backend PR; **no touch of
  the KYC/KYB/AML carve-out**; banxe-emi-stack untouched (0 `mig-m2.3` factory branches); no merge.

## 6. Recommended next step

Proceed to the paired reconcile/gap-audit (decision A, this turn). Then MIG-M2.3 is closed as a
reconcile. KYC/KYB/AML carve-out work remains **pending operator/governance sign-off (I-27 HITL-L4)**.
Correct the M2-sequencing note: **M2.3 = reconcile, not scaffold.**

## References
`docs/migration/MIG-M2.3-BLOCKER-identity-auth-already-exists.md`; read-only origin/main `1a90a41`
banxe-emi-stack `api/routers/{auth,customers,customer_lifecycle,kyc,kyb_onboarding,adverse_media,consent_management,fos_escalation}.py`
+ `api/models/{auth,sca,sca_adapters,customers,kyc}.py` + `api/main.py` + `services/{case_management,compliance_automation}/*`;
legacy `banxe-fiat-backend/banxe-auth-backend` (+ `banxe-identity`, `banxe-identity-config-manager`,
auth-variants); MIG-M1.4 / M1.4.1 (identity/auth boundary + auth dup-audit), MIG-M2.4 / M2.5 (reconcile
precedents); ADR-102, ADR-103, ADR-059-A, I-27, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
