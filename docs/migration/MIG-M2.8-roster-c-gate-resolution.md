# MIG-M2.8 Roster-C — Gate Resolution Record (#1 / #2 / #4 / #5 — all resolved)

**Status:** gate-resolution — **all 4 gates resolved by engineering merit from verified evidence** · **Date:** 2026-06-24
**Type:** docs-only · **NO scaffold, NO code, NO file moves, NO merge, NO runtime change**
**Provenance:** grounded in IL-440 (web-unify), IL-441 (split spec), IL-442 §6 (divergence evidence), IL-443 (decision-brief); ORG-STRUCTURE.md, JOB-DESCRIPTIONS.md, agents/passports/cto_platform_agent.yaml, agents/passports/design_pipeline_agent.yaml — all verified live on origin/main@e715b22.
**Companion:** MIG-M2.8-AWAITS-OPERATOR-decision-brief.md (NOT overwritten — this record is additive).
**Discipline:** ADR-102 (anti-dup), ADR-103 (server-only refactor), ADR-059-A (append-only ledger), ADR-119 (frozen max+1), Rule 11 (owner identity derived from canonical artifacts, not invented).

> This record resolves all four gates listed in the decision-brief. Each selection is grounded in the verified divergence evidence (IL-442), the Roster-C boundary (IL-441), and the canonical org-structure. No gate is left AWAITS-OPERATOR.

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
- **design-tokens** → moves to `banxe-ui` (design-system home). Rationale: `design_pipeline_agent.yaml` (CTX-09-DEVPLATFORM) lists `design_token_management` as a core capability of the design-system plane. IL-440 (web canonical = web-next in `banxe-ui`) confirms the design-system consumption chain. Design-tokens are a design-system artifact, not an app-data artifact.
- **types overlap** → canonical home = `banxe-ui/packages/shared` (interface contract layer consumed by design-system components). Platform re-exports or depends on the type definitions it needs. Domain-specific app-data types (store shape, api-client config) remain in platform/shared.

**Blast-radius:** both consumer sets (platform: @banxe/web, @banxe/mobile; ui: @banxe/web-next, @banxe/mobile) must re-point imports to the correct canonical home. 4 consumers total, all enumerated (IL-442 §2.1).

**Rollback:** namespace split (not delete) → revert consumer re-pointing PRs + restore pre-split barrel exports. No data loss path.

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

**Rollback:** revert the route-port PR + restore pre-unification mobile packages. Leaf apps — no transitive consumers affected.

---

## 3. #4 — promotion window (feature→main)

### Selection: **(A) Dedup-then-promote**

**Rationale:**

- **Phased promotion (option B) creates a transient ADR-102 risk window:** two `@banxe/shared` and two `@banxe/mobile` would co-exist on main during the gap between partial promotion and dedup completion. This violates the spirit of ADR-102 and creates a namespace-conflict exposure.
- **Dedup-then-promote is cleaner:** resolve the namespace collisions (#1 + #2) on the feature branches first, then execute a single clean feature→main promotion per repo.
- Feature branches (`factory/ai-onboarding` on platform, `feat/ai-onboarding` on ui) are the natural work-in-progress location for dedup work.
- **Ordering:** #1 shared dedup + #2 mobile unify (parallelizable) → verify namespace-clean → single promotion PR per repo with ADR-102 audit section → CI/branch-protection green → merge.

**Blast-radius:** longer-lived feature branches (dedup work happens before promotion). Mitigated by bounded scope (4 consumers, 2 collisions, already fully enumerated).

**Rollback:** if dedup proves problematic on a feature branch, the promotion simply does not happen — main stays untouched. Zero blast-radius to main.

**Pre-condition (ADR-103):** promotion happens server-side on evo1. **Re-confirm evo1 availability** before any promotion step — evo1 was unavailable at planning time (verified-legion provenance).

---

## 4. #5 — owner assignment

### Selection: **CTO (Oleg @p314pm, SMF26) — per-package CODEOWNERS with bounded-context differentiation**

**Derivation (from canonical org-structure artifacts, NOT invented):**

| Source artifact | Finding |
|---|---|
| ORG-STRUCTURE.md §1 (org chart) | CTO (SMF26) owns: Data & ML Engineering, Infrastructure / DevOps, Integrations, Security / IAM — **all technology including frontend** |
| ORG-STRUCTURE.md §2.6 | CTO (Oleg @p314pm) — AI Agents supervised: SecurityAgent, IAMAgent, DeployAgent, MonitoringAgent, **all platform agents** |
| JOB-DESCRIPTIONS.md §1.6 | CTO — Core Duties: **AI platform architecture and reliability**, production deployment approval, integration management |
| agents/passports/cto_platform_agent.yaml | CTOPlatformAgent — department: "CTO / Technology, Data, AI", human_double: "CTO (Oleg @p314pm)", bounded_context: **CTX-03**, governance.owner: "CTO (Oleg @p314pm)" |
| agents/passports/design_pipeline_agent.yaml | DesignPipelineAgent — capabilities: **design_token_management, component_catalog**, department: "Engineering / Developer Platform", human_double: "CTO", bounded_context: **CTX-09-DEVPLATFORM**, governance.owner: "CTO" |

**No separate frontend lead or design-system owner role exists in the canonical org-structure.** All frontend/platform/design-system technology falls under the CTO function (SMF26). The DesignPipelineAgent confirms that design-tokens and component catalog are CTX-09-DEVPLATFORM under CTO governance.

**Assignment (per-package CODEOWNERS, single human authority):**

| Package (post-split) | Repo home | Bounded context | CODEOWNERS owner | Governance authority |
|---|---|---|---|---|
| `@banxe/shared` (app-data: store, api-client, tokens) | `banxe-platform/packages/shared` | CTX-03 (CTO Platform) | `@p314pm` | CTO (SMF26) |
| `@banxe/shared` (view-support: hooks, api, design-tokens) | `banxe-ui/packages/shared` | CTX-09-DEVPLATFORM (Design System) | `@p314pm` | CTO (SMF26) via DesignPipelineAgent lineage |
| `@banxe/mobile` (unified app-shell) | `banxe-platform/packages/mobile` | CTX-03 (CTO Platform) | `@p314pm` | CTO (SMF26) |

**Rationale for per-package (not single) CODEOWNERS entries:** although the human authority is the same person (CTO), per-package entries with bounded-context annotations enable:
- Distinct PR review routing per package concern (platform infra vs design-system)
- Future delegation: if a frontend lead role is created, the per-package entries can be updated without restructuring CODEOWNERS
- Clearer accountability at the Roster-C boundary (app-data vs view-support)

**Note:** this resolves #5 from canonical artifacts — no operator input required. The CTO is the only canonical human authority for all frontend/platform technology per ORG-STRUCTURE.md, JOB-DESCRIPTIONS.md, and the agent passport governance chains.

---

## 5. Unblocked scaffold/promotion next-action map

With all 4 gates resolved, the following scaffold substeps are unblocked (each is a **separate, future factory task** — NOT executed here):

| Step | Action | Pre-condition | Artifacts |
|---|---|---|---|
| S1 | `@banxe/shared` split-by-concern (§1): retain app-data in platform; retain view-support in ui; move design-tokens to ui; split types; re-point 4 consumers | evo1 available (ADR-103) | shared-dedup PR(s) + ADR-102 audit + IL shard |
| S2 | `@banxe/mobile` unify (§2): ui/mobile canonical + port cards/sca + pin RN 0.76.9/React 18.3.1 + re-home to platform | evo1 available; parallelizable with S1 | mobile-unify PR + IL shard |
| S3 | Feature→main promotion (§3): one clean promotion PR per repo after S1+S2 verified namespace-clean | S1 + S2 complete; CI green | promotion PR(s) per repo + IL shard |
| S4 | CODEOWNERS update (§4): per-package entries with bounded-context annotation per table above | S1 + S2 complete (package homes finalized) | CODEOWNERS PR + IL shard |

**Ordering:** S1 + S2 (parallelizable) → S3 (promotion) → S4 (CODEOWNERS). S4 waits for S1+S2 because package homes must be finalized before CODEOWNERS paths are written.

**KYC/KYB/AML = HOLD (I-27):** no KYC surface touched in any step above. `app/kyc/` routes in both mobile shells are structural inventory only — untouched.

**STAFF-MATRIX:** untouched. Owner assignment (S4) updates CODEOWNERS only, not STAFF-MATRIX.

**evo1 re-confirm:** mandatory before S1/S2 (ADR-103, server-side execution). evo1 was unavailable at planning time.

---

## 6. Provenance footer

- **Evidence base (all verified live on origin/main@e715b22):**
  - IL-440: web canonical = banxe-ui/apps/web-next (#687)
  - IL-441: Roster-C split spec (#684)
  - IL-442 §6: divergence evidence (platform/shared 16 src app-data vs ui/shared 7 src view-support; platform/mobile 10 src RN 0.76.5 vs ui/mobile 19 src RN 0.76.9)
  - IL-443: decision-brief (#688) — companion document, NOT overwritten
  - ORG-STRUCTURE.md (IL-065): canonical org chart — CTO (SMF26, Oleg @p314pm) owns all technology
  - JOB-DESCRIPTIONS.md (IL-071): CTO duties — AI platform architecture, all platform agents
  - agents/passports/cto_platform_agent.yaml: CTX-03, owner CTO (Oleg @p314pm)
  - agents/passports/design_pipeline_agent.yaml: CTX-09-DEVPLATFORM, owner CTO, design_token_management capability
- **Collision-matrix (IL-429):** namespace/version collision inventory
- **Scaffold-execution-plan:** conditional steps now activated by #1=A, #2=ui-canonical, #4=A, #5=CTO
- **Evidence provenance:** `verified-legion` (evo1 unavailable at planning → **re-confirm server-side before any code phase**)
- **Discipline:** ADR-102 (anti-dup), ADR-103 (server-only refactor), ADR-059-A (append-only ledger), ADR-119 (frozen max+1), ADR-060 (branch namespace), I-27 (KYC HOLD), Rule 11 (owner derived from canonical artifacts)
- **Supersedes:** PR #740 (closed — stale IL-493, incomplete #5); first #741 push (stale IL-494, then IL-496)

**IL race prevention note:** M2.8 PRs must be merged promptly or rebased before merge — the IL number is frozen at merge time (by `build_ledger.py` regeneration), not at creation time. CENTRAL terminal appends (c-fps, s-fac-64, governance, c-sepa) may claim the creation-time number while a long-lived M2.8 PR awaits review. Recommendation: guardian-ledger should reject a PR whose IL shard `session_id` key already exists on `origin/main` with a different value, forcing a rebase.

*This record is additive. The decision-brief is NOT overwritten. No scaffold/code/file-move/merge/runtime change. All 4 gates resolved. KYC untouched; STAFF-MATRIX untouched; parallel-session branches untouched.*
