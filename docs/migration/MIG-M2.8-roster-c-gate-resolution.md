# MIG-M2.8 Roster-C — Gate Resolution Record (#1 / #2 / #4 / #5)

**Status:** gate-resolution — **selects by engineering merit from verified evidence** · **Date:** 2026-06-24
**Type:** docs-only · **NO scaffold, NO code, NO file moves, NO merge, NO runtime change**
**Provenance:** grounded in IL-440 (web-unify), IL-441 (split spec), IL-442 §6 (divergence evidence), IL-443 (decision-brief); all verified live on origin/main@0efaba2.
**Companion:** MIG-M2.8-AWAITS-OPERATOR-decision-brief.md (NOT overwritten — this record is additive).
**Discipline:** ADR-102 (anti-dup), ADR-103 (server-only refactor), ADR-059-A (append-only ledger), ADR-119 (frozen max+1), Rule 11 applied per gate.

> This record resolves the four gates listed in the decision-brief. Each selection is grounded in the verified divergence evidence (IL-442) and the Roster-C boundary (IL-441). Gate #5 (owner identity) cannot be resolved on engineering merit alone and is marked AWAITS-OPERATOR with a technical recommendation.

---

## 1. #1 — `@banxe/shared` canonical + merge-direction

### Selection: **(A) Split by concern**

**Rationale (from verified evidence — IL-442 §6.1):**

The two `@banxe/shared` implementations are **distinct roles sharing a name**, not duplicates:

| | platform/shared (16 src) | ui/shared (7 src) |
|---|---|---|
| Role | **app-data**: store, api-client, tokens, design-tokens | **view-support**: hooks, granular api |
| Build | pre-built (dist barrel) | source-module (granular exports) |
| Overlap | index.ts + types only | index.ts + types only |

Options B (ui barrel) and C (platform barrel) both violate the Roster-C split principle — B pulls app-data into the design-system repo; C strips the design-system of its view-support layer.

**Option A preserves role alignment with the Roster-C boundary:**
- **app-data** (store, api-client, tokens) → stays in `banxe-platform/packages/shared` (app-shell infrastructure)
- **view-support** (hooks, granular api) → stays in `banxe-ui/packages/shared` (design-system support)
- **design-tokens** → moves to `banxe-ui` (design-system home); aligns with IL-440 (web canonical = web-next in banxe-ui, which consumes design-tokens)
- **types overlap** → canonical home = `banxe-ui/packages/shared`; platform re-exports or depends on the type definitions it needs. Domain-specific app-data types (store shape, api-client config) remain in platform.

**Blast-radius:** both consumer sets (platform: @banxe/web + @banxe/mobile; ui: @banxe/web-next + @banxe/mobile) must re-point imports to the correct canonical home. 4 consumers total, all enumerated.

**Rollback:** since this is a namespace split (not a delete), rollback = revert the consumer re-pointing PRs + restore the pre-split barrel exports. No data loss path.

---

## 2. #2 — `@banxe/mobile` canonical + RN/React unify

### Selection: **ui/apps/mobile as canonical app-shell; re-home to `banxe-platform`; RN 0.76.9 / React 18.3.1**

**Rationale (from verified evidence — IL-442 §6.2):**

| | platform/mobile (10 src) | ui/mobile (19 src) |
|---|---|---|
| Architecture | flat routes only | **layered**: src/screens + theme + components |
| Unique routes | **cards, sca** (payment/auth) | src layers (theme, components) |
| RN | 0.76.5 | **0.76.9** (newer patch) |
| React | 18.3.2 | 18.3.1 |
| Expo | ~53.0.0 | ~53.0.0 |

- **ui/mobile is the more mature shell** — nearly 2× source files, layered architecture (screens/theme/components separation), established patterns.
- **RN 0.76.9** is the newer patch within the same minor — more bug-fixes, zero breaking changes vs 0.76.5.
- **React 18.3.1 vs 18.3.2** is negligible; 18.3.1 is what the larger canonical app already uses.
- **Expo ~53.0.0** is equal — no change.
- platform/mobile's unique value = **cards + sca routes** — these port into the canonical shell as route additions (additive, non-breaking).

**Per Roster-C boundary (IL-441):** all app-shells consolidate in `banxe-platform`. The canonical ui/mobile is re-homed to `banxe-platform` after unification.

**RN/React unify target:**
- **React Native 0.76.9** (newer patch, forward-looking)
- **React 18.3.1** (canonical app's current version)
- **Expo SDK ~53.0.0** (unchanged)

**Blast-radius:** ui/mobile (canonical) absorbs platform/mobile routes (cards, sca). Platform/mobile is then retired. No downstream consumers (both are leaf apps). Re-home = workspace move from ui → platform.

**Rollback:** revert the route-port PR + restore the pre-unification mobile packages. Leaf apps — no transitive consumers affected.

---

## 3. #4 — promotion window (feature→main)

### Selection: **(A) Dedup-then-promote**

**Rationale:**

- **Phased promotion (option B) creates a transient ADR-102 risk window:** two `@banxe/shared` and two `@banxe/mobile` would co-exist on main during the gap between partial promotion and dedup completion. This violates the spirit of ADR-102 and creates a namespace-conflict exposure.
- **Dedup-then-promote is cleaner:** resolve the namespace collisions (#1 + #2) on the feature branches first, then execute a single clean feature→main promotion per repo.
- Feature branches (`factory/ai-onboarding` on platform, `feat/ai-onboarding` on ui) are the natural work-in-progress location for dedup work.
- **Ordering:** #1 shared dedup + #2 mobile unify (can be parallelized) → verify namespace-clean → single promotion PR per repo with ADR-102 audit section → CI/branch-protection green → merge.

**Blast-radius:** longer-lived feature branches (dedup work happens before promotion). Mitigated by the fact that dedup is a bounded scope (4 consumers, 2 collisions, already fully enumerated).

**Rollback:** if dedup proves problematic on a feature branch, the promotion simply does not happen — main stays untouched. Zero blast-radius to main.

**Pre-condition (ADR-103):** promotion happens server-side on evo1. **Re-confirm evo1 availability** before any promotion step — evo1 was unavailable at planning time (verified-legion provenance).

---

## 4. #5 — owner assignment

### Selection: **AWAITS-OPERATOR** (technical recommendation: per-package owner)

**Why AWAITS-OPERATOR:** owner identity is a human/organizational decision that cannot be resolved on engineering merit alone. The factory does not name people or assign roles (Rule 11).

**Technical recommendation (for operator consideration):**

- **(B) Per-package owner** is preferred over single owner:
  - `@banxe/shared` and `@banxe/mobile` serve fundamentally different roles (shared lib vs app-shell).
  - After the #1 split, `@banxe/shared` will exist as two domain-specific packages in two repos — a single owner for both may bottleneck.
  - Per-package ownership enables parallel PR review and clearer accountability at the package boundary.
  - Interface-contract discipline at the boundary (already imposed by Roster-C split) provides the coordination mechanism.

- If the operator prefers a **single owner** for simplicity: acceptable, but the owner must have cross-repo context (platform + ui) and bandwidth for both packages.

**Operator action required:** assign specific person(s)/team(s) as CODEOWNERS for the unified `@banxe/shared` and `@banxe/mobile` post-split.

---

## 5. Unblocked scaffold/promotion next-action map

With gates #1/#2/#4 resolved, the following scaffold substeps are unblocked (each is a **separate, future factory task** — NOT executed here):

| Step | Action | Pre-condition | Artifacts |
|---|---|---|---|
| S1 | `@banxe/shared` split-by-concern (§1): move design-tokens to ui; split types; re-point 4 consumers | evo1 available (ADR-103) | shared-dedup PR(s) + ADR-102 audit + IL shard |
| S2 | `@banxe/mobile` unify (§2): ui/mobile canonical + port cards/sca + pin RN 0.76.9/React 18.3.1 + re-home to platform | evo1 available; can parallelize with S1 | mobile-unify PR + IL shard |
| S3 | Feature→main promotion (§3): one clean promotion PR per repo after S1+S2 verified namespace-clean | S1 + S2 complete; CI green; operator go | promotion PR(s) per repo + IL shard |
| S4 | CODEOWNERS assignment (§4): per-package or single owner | **AWAITS-OPERATOR** #5 decision | CODEOWNERS PR + IL shard |

**KYC/KYB/AML = HOLD (I-27):** no KYC surface touched in any step above. `app/kyc/` routes in both mobile shells are structural inventory only — untouched.

**STAFF-MATRIX:** untouched. Owner assignment (S4) updates CODEOWNERS only, not STAFF-MATRIX.

---

## 6. Provenance footer

- **Evidence base (all verified live on origin/main@0efaba2):**
  - IL-440: web canonical = banxe-ui/apps/web-next (#687)
  - IL-441: Roster-C split spec (#684)
  - IL-442 §6: divergence evidence (platform/shared 16 src app-data vs ui/shared 7 src view-support; platform/mobile 10 src RN 0.76.5 vs ui/mobile 19 src RN 0.76.9)
  - IL-443: decision-brief (#688) — companion document, NOT overwritten
- **Collision-matrix (IL-429):** namespace/version collision inventory
- **Scaffold-execution-plan:** conditional steps now activated by #1=A, #2=ui-canonical, #4=A
- **Evidence provenance:** `verified-legion` (evo1 unavailable at planning → **re-confirm server-side before any code phase**)
- **Discipline:** ADR-102 (anti-dup), ADR-103 (server-only refactor), ADR-059-A (append-only ledger), ADR-119 (frozen max+1), ADR-060 (branch namespace), I-27 (KYC HOLD), Rule 11 (#5 operator gate)

*This record is additive. The decision-brief is NOT overwritten. No scaffold/code/file-move/merge/runtime change. Gate #5 (owner identity) remains AWAITS-OPERATOR. KYC untouched; STAFF-MATRIX untouched; parallel-session branches untouched.*
