# MIG — migration coverage-acceptance (backend phase) — BANXE.RAR → EMI

<!-- Source: docs/migration/MIG-coverage-acceptance.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no merge. Summary/acceptance of the backend migration phase (core + follow-ups + genuine-gaps). -->

> **Backend migration phase summary + acceptance.** The M2 core, the follow-ups, and the genuine-gap
> shortlist are on `main`. This is the docs-only acceptance roll-up (mirror of MIG-M2.8 / MIG-M1.8). No
> code, no merge.

## 1. Genuine-gaps closed (the only real ports)

| Gap | Surface | IL | Merge SHA (banxe-emi-stack) | Posture |
|---|---|---|---|---|
| #1 abs-info-field | `services/abs/info_field.py` (AbsInfoFieldPort, descriptive field metadata) | IL-412 | `72334ce` | advisory/sandbox, config-as-data, fail-closed, I-01 no-float |
| #2 login-history | `services/auth/login_history.py` (LoginHistoryPort, auth-audit) | IL-413 | `4378207` | advisory, **PII-masked** (mask_ip), timestamp caller-supplied, DI + collision-safe |
| #3 SRP | `services/auth/srp.py` (SrpPort, login-strategy state-machine) | IL-414 | `1e39ad1` | **SECURITY-SENSITIVE — no real crypto/secret-material, placeholder refs**, fail-closed |

All three: additive sibling surfaces (not duplicates), no live integration, no Midaz/KYC/ledger, global
fence-check NONE. CI-gated 9-check green; CodeRabbit/ruff findings remediated **in-branch** (no bypass).

## 2. Anti-dup statistics (ADR-102 preflight discipline)

Mandatory read-only preflight on **every** substep prevented mis-scaffolds:

| Class | Substeps | Outcome |
|---|---|---|
| **Covered / reconcile** (surface already existed) | M2.4 open-banking · M2.5 ABS · M2.3 identity/auth · M2.4a/b scheduled · abs-posting | 5 → reconcile/covered, **no scaffold** |
| **Target-mismatch** (wrong repo) | M2.7 platform-core · M2.5-BIF Bifrost | 2 → re-scope/retarget |
| **Genuine-gap** (truly absent) | abs-info-field · login-history · SRP | 3 → **precise scaffold** |

**7 mis-scaffolds avoided; 3 precise scaffolds delivered.** Plus 1 coverage-audit sweep (IL-411) that
classified the whole remaining delta in one pass (replacing further per-substep blocker cycles).

## 3. Full migration map (all on `main`)

| Substep | Result | Home / SHA |
|---|---|---|
| M2.7 platform-core | re-scope (consume from `banxe-shared-libs`) | IL-373 |
| M2.2 accounts SoT | scaffold | banxe-emi-stack · `fb1d431` |
| M2.1 payments engine | scaffold | banxe-payment-core · `09f7825` |
| M2.6 SEPA rail | scaffold | banxe-payment-core · `428d75c` |
| M2.4 open-banking | reconcile | banxe-emi-stack · `0b70728` |
| M2.5 ABS | reconcile | banxe-emi-stack · `4fd425d` |
| M2.3 identity/auth | reconcile | banxe-emi-stack · `f6322b8` |
| M2.8 acceptance | checkpoint | `3cef846` |
| M2.4-INT open-banking integration | scaffold (bridge) | banxe-emi-stack · `b3c936d` |
| M2.5-BIF Bifrost Wave-D | scaffold (retargeted) | banxe-emi-stack · `3228d3d` |
| M2.4a/b scheduled | covered | IL-401/402 |
| abs-posting | covered | IL-405/406 |
| coverage-audit | sweep | IL-411 |
| genuine-gap #1/#2/#3 | scaffold | `72334ce` / `4378207` / `1e39ad1` |

**Backend homes resolved:** accounts SoT / open-banking / ABS / identity-auth / GL-posting → `banxe-emi-stack`;
payments engine / SEPA rail → `banxe-payment-core`; platform-core contracts → consumed from `banxe-shared-libs`.

## 4. KYC/KYB/AML carve-out status (gate)

**PENDING operator/governance sign-off (I-27 HITL-L4).** The regulated layer (KYC/KYB workflows, Sumsub,
scoring/risk, adverse-media/sanctions, MLRO approve-EDD, `kyb_onboarding` legal-entity) is
**advisory-descriptive only** across the whole migration — **no code written/changed without sign-off**
(CLAUDE.md never-skip-AML/KYC). Not touched in any substep. This is the explicit blocking gate for any
identity/KYC follow-up.

## 5. Remaining backlog

| Item | Status / gate |
|---|---|
| M2.4c — file (bulk/batch) payments (+consents) | OB delta — **preflight-first** (may be covered) |
| M2.4d — international-scheduled payments (+consents) | OB delta — preflight-first |
| M2.4e — intl per-consent funds-confirmation + CBPII consent lifecycle | OB delta — preflight-first |
| KYC/KYB/AML | **blocked on I-27 HITL-L4 sign-off** |
| M2.8 frontend | **blocked on frontend roster audit** (banxe-platform vs banxe-ui, MIG-M2.7 deferral) |
| Optional integrations | M2.4-INT family (OB scheduled-consent facade); ABS PostingRule; per-capability ports — all advisory, gated |

## 6. Governance learnings (now canon)

1. **Preflight-discipline** — mandatory read-only preflight (api/ + repo-wide `services/`/`src/`) before
   ANY scaffold; filename-collision + repo-wide search are required. Prevented 7 mis-scaffolds.
2. **Coverage-audit sweep** — one read-only classification pass over a remaining delta beats a series of
   per-substep blocker→covered cycles (the "5 consecutive covered" observation → IL-411 sweep).
3. **In-branch remediation** — CI/CodeRabbit findings (DI, audit-collision, S105 false-positive,
   docstring-substring fences) fixed **in the same branch, never bypassed / no `--admin` / no skip-flags**.
4. **Factory-only execution** — every state change ran through the factory (server-side evo1, isolated
   worktrees, paired backend+arch PRs, no merge without explicit governance); shell used for **read-only
   audit only**. ADR-059-A append-only ledger with monotonic il_ts throughout.

## 7. Acceptance statement + preconditions

**The BANXE.RAR → EMI backend migration phase is ACCEPTED** — M2 core (M2.1–M2.7) + acceptance + the
M2.4-INT / M2.5-BIF integrations + the covered reconciles (M2.4a/b, abs-posting) + the 3 genuine-gap
scaffolds are all on `main`, backend homes resolved, all ADR-102/ADR-103/ADR-059-A compliant, regulated
surfaces + KYC/KYB/AML carve-out intact.

**Preconditions for the next phase:**
1. **I-27 HITL-L4 sign-off** — unblocks KYC/KYB/AML work (hard gate).
2. **Frontend roster audit** (banxe-platform vs banxe-ui) — unblocks M2.8 frontend.
3. **M2.4c–e preflight** — each OB delta verified before scaffold (likely partially covered).
4. Each follow-up stays advisory / server-side / paired-PR / no-merge until its gate clears.

## References
`docs/migration/MIG-coverage-acceptance.md`; genuine-gaps: MIG-abs-info-field (IL-412), MIG-login-history
(IL-413), MIG-srp (IL-414); coverage-audit (IL-411); covered: MIG-M2.4a (IL-401/402), abs-posting
(IL-405/406); reconciles M2.4/M2.5/M2.3; M2.8 acceptance (IL-393); M2.4-INT (IL-395), M2.5-BIF (IL-398/399);
ADR-013, ADR-025 §15-16, ADR-102, ADR-103, ADR-059-A, I-01, I-05, I-24, I-27, I-28;
/tmp/banxe-migration-mapping-v0.claude.txt.
