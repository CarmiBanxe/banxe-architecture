# MIG-M2.8 Roster-C — Scaffold execution-plan skeleton (CONDITIONAL)

**Status:** execution-plan **skeleton — plan, NOT execution** · **Date:** 2026-06-22
**Type:** docs-only · **NO scaffold, NO code, NO file moves, NO merge, NO selection**
**Activation:** every branch below is **`IF operator picks X → steps`**. Nothing here runs until the operator resolves AWAITS #1/#2/#4/#5 (Rule 11). The factory does **not** fix canonical/versions/owners/promotion.
**Provenance:** `verified-legion` (evo1 unavailable — **re-confirm server-side before any step**).
**Governance baseline on main:** IL-440 web-unify (#687), IL-441 split spec (#684), IL-442 §6 evidence (#684), IL-443 decision-brief (#688).

> This skeleton is the ready-to-run plan that the corresponding operator decision will *activate*. Until then it is fail-closed documentation.

---

## 1. Scope
Conditional scaffold/promotion plan for M2.8 Roster-C, parametrized by operator outcomes of:
- **#1** `@banxe/shared` canonical + merge-direction (A split / B ui-barrel / C platform-barrel)
- **#2** `@banxe/mobile` canonical app-shell + RN/React unify
- **#4** promotion window feature→main (dedup-then-promote / phased)
- **#5** owner assignment

KYC/KYB/AML = **HOLD (I-27)**, excluded from every branch. Web canonical already fixed = `banxe-ui/apps/web-next` (IL-440) — used as context, not re-decided.

---

## 2. Pre-flight gate (common to ALL branches — mandatory before any move)
1. **ADR-102 re-audit** — repo-wide duplication re-check at execution time (state may have drifted since IL-442); enumerate consumers again; "Duplication Audit" section on each scaffold PR.
2. **ADR-103 server-side** — all moves/edits on evo1 (`/srv`), Legion = thin client; **re-confirm evo1 availability** (was unavailable at planning).
3. **Parity-inventory before any retire** — e.g. `web-vite` retire (IL-440) requires route/feature parity vs `web-next` confirmed first; **fail-closed** until parity proven.
4. **Promotion = separate go** — branch→main promotion is a distinct operator go (see §5), never bundled into a dedup PR.
5. **Per-PR discipline** — paired backend/frontend PRs + arch IL shard; guardian/ledger green; no `--admin`/bypass; `--force-with-lease` only.

---

## 3. #1 `@banxe/shared` — conditional steps

Facts (IL-442): platform 16 src (app-data: store/api-client/tokens/design-tokens) vs ui 7 src (view-support: hooks/granular-api); overlap = `index.ts`+`types`.

**IF operator picks (A) split by concern →**
1. Create/confirm target homes: app-data → `banxe-platform/packages/shared`; view-support → `banxe-ui/packages/shared`.
2. Move `hooks` + granular `api` exports to ui/shared; keep `store`/`api-client`/`tokens`/`design-tokens` in platform/shared.
3. `index.ts`+`types` overlap → single-source `types` (one home or a shared `@banxe/types` sub-package); update both barrels.
4. Re-point consumers: platform(web,mobile) + ui(web-next,mobile) imports per new homes.
5. Fences/tests: build both packages; type-check consumers; no cross-repo cyclic dep.

**IF operator picks (B) ui canonical barrel →**
1. Fold platform uniques (store/api-client/tokens/design-tokens) into ui/shared.
2. Adopt ui's granular exports as canonical surface; deprecate platform/shared.
3. Re-point platform consumers (web,mobile) to ui/shared.
4. Note: app-data now lives in design-system repo — record boundary exception.

**IF operator picks (C) platform canonical barrel →**
1. Fold ui uniques (hooks/granular-api) into platform/shared.
2. Adopt platform's pre-built `.` barrel as canonical; deprecate ui/shared.
3. Re-point ui consumers (web-next,mobile) to platform/shared.
4. Note: design-system repo loses view-support home — record boundary exception.

*(All three: ADR-102 audit section + consumer re-point list mandatory on the PR.)*

---

## 4. #2 `@banxe/mobile` — conditional steps

Facts (IL-442): platform 10 src (RN 0.76.5/React 18.3.2; routes cards/sca) vs ui 19 src (RN 0.76.9/React 18.3.1; src/screens+theme+components).

**IF canonical = ui/apps/mobile →**
1. Designate ui mobile canonical; per Roster-C app-shell home = `banxe-platform` → plan re-home of canonical app into platform.
2. Port platform routes `cards` + `sca` into canonical.
3. RN/React unify: **target pair = AWAITS OPERATOR** (e.g. 0.76.9/18.3.1) — pin once chosen; bump Expo accordingly.
4. Tests: Expo build; route smoke; shared-dep resolves per #1 outcome.

**IF canonical = platform/packages/mobile →**
1. Designate platform mobile canonical (aligns app-shell-in-platform).
2. Port ui layers `src/screens` + `theme` + `components` into canonical.
3. RN/React unify: target pair = AWAITS OPERATOR (e.g. 0.76.5/18.3.2) — pin once chosen.
4. Tests: as above.

**RN/React unify direction is operator's** in both cases — plan pins whatever target the operator sets; factory does not choose.

---

## 5. #4 promotion window feature→main — conditional

Facts: active feature branches (platform `factory/ai-onboarding`, ui `feat/ai-onboarding`); re-confirm authoritative branch server-side.

**IF (A) dedup-then-promote →**
1. Resolve #1+#2 on feature branches (namespace-dedup complete).
2. Single promotion PR per repo feature→main, each with ADR-102 audit (ADR-103 server-side).
3. CI/branch-protection gates green; no `--admin`.

**IF (B) phased →**
1. Promote non-colliding packages to main first (per repo).
2. Dedup #1/#2 in follow-up PRs; **flag transient ADR-102 risk window** (two `@banxe/shared`/`@banxe/mobile` co-exist) — time-box + track.
3. Final dedup promotion closes the window.

---

## 6. #5 owners — conditional (plan, not edit)

**IF single owner →** one CODEOWNERS entry for unified `@banxe/shared`+`@banxe/mobile`; single PR-routing target.
**IF per-package owner →** separate CODEOWNERS entries; interface-contract review at package boundary.
*(No CODEOWNERS edit here; STAFF-MATRIX untouched.)*

---

## 7. Activation map (operator decision → first scaffold-substep → paired artifacts; all AFTER go)

| Decision | First substep activated | Paired artifacts |
|---|---|---|
| #1 = A/B/C | `@banxe/shared` dedup per direction (§3) | shared-dedup PR (server-side) + ADR-102 audit + arch IL shard |
| #2 = canonical+versions | `@banxe/mobile` unify + route reconcile (§4) | mobile-unify PR + RN/React pin + arch IL shard |
| #4 = A/B | promotion sequencing (§5) | promotion PR(s) feature→main per repo + branch-protection gate |
| #5 = single/per-pkg | CODEOWNERS assignment (§6) | CODEOWNERS PR + governance IL shard |

**Ordering (from IL-443 §6):** #1 + #2 → namespace-dedup → #4 promotion; #5 cross-cutting. No substep runs before its decision (fail-closed).

---

## 8. Provenance footer
- Baseline on main: IL-440 (web-unify), IL-441 (split spec), IL-442 (§6 divergence evidence), IL-443 (decision-brief).
- Evidence provenance: `verified-legion` (evo1 unavailable → re-confirm server-side before execution).
- Discipline: ADR-102, ADR-103, ADR-059-A, ADR-060, I-27 (KYC HOLD), Rule 11.

*Plan only. No scaffold/code/file-move/merge/runtime change. canonical/versions/owners/promotion remain AWAITS OPERATOR. KYC untouched; STAFF-MATRIX untouched; parallel-session branches untouched.*
