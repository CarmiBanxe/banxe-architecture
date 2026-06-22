# MIG-M2.8 Roster-C — AWAITS-OPERATOR decision-brief (#1 / #2 / #4 / #5)

**Status:** decision-brief — **consolidates facts + options, selects NOTHING** (operator gate, Rule 11) · **Date:** 2026-06-22
**Type:** docs-only · **NO scaffold, NO code, NO file moves, NO merge, NO runtime change**
**Provenance:** `verified-legion` (read-only on Legion clones; **evo1 unavailable** — re-confirm server-side before any code phase).
**Already on main (context, not re-decided here):** IL-440 web-unify decision (#687: canonical web = `banxe-ui/apps/web-next`); IL-441 Roster-C split spec; IL-442 §6 divergence evidence.

> Single entry-point for the operator to resolve the four remaining gates. Each item lists verified facts + options with trade-offs/blast-radius. The factory **does not choose** — selection is the operator's (Rule 11). Resolving these unblocks the scaffold/promotion phase (see §7 Next-action map).

---

## 1. Scope

This brief consolidates the four open M2.8 Roster-C gates after the SPEC phase closed:
- **#1** `@banxe/shared` canonical + merge-direction
- **#2** `@banxe/mobile` canonical + RN/React unify
- **#4** promotion window (feature→main) for both repos
- **#5** owner assignment for the unified `@banxe/shared` + `@banxe/mobile`

KYC/KYB/AML stays **HOLD (I-27)** and is out of scope. `@banxe/shared`/`@banxe/mobile` canonical, versions, owners, and promotion order remain **AWAITS OPERATOR**.

---

## 2. #1 — `@banxe/shared` canonical + merge-direction

**Verified facts (IL-442):** divergent, not byte-duplicate.

| | platform/packages/shared | ui/packages/shared |
|---|---|---|
| src (.ts/.tsx) | 16 | 7 |
| role | **app-data**: api-client, store, design-tokens, tokens, types | **view-support**: api, hooks, types |
| build/exports | dist-built; export `.` (single barrel) | src-module; granular `.` `./api` `./types` `./hooks` |
| consumers | @banxe/web, @banxe/mobile | @banxe/web-next, @banxe/mobile |
| overlap | `index.ts` + `types` | `index.ts` + `types` |

**Options (AWAITS OPERATOR — not selected):**
- **(A) Split by concern** — app-data (store/api-client/tokens/design-tokens) → `banxe-platform`; view-support (hooks/granular-api) → `banxe-ui` design-system. *Trade-off:* cleanest role-alignment with Roster-C boundary; blast-radius = both consumer sets must re-point imports; `types` overlap needs one canonical home (or a shared types sub-package).
- **(B) `ui` canonical barrel** — fold platform uniques into ui/shared. *Trade-off:* keeps design-system-centric; but pulls app-data (store/api-client) into the design-system repo, blurring the split; blast-radius = platform consumers re-point.
- **(C) `platform` canonical barrel** — fold ui uniques into platform/shared. *Trade-off:* keeps richer/pre-built barrel; but design-system repo loses its view-support hooks home; blast-radius = ui consumers re-point.

**Note:** `design-tokens` straddles design-system↔app-data — its home interacts with #687 (web canonical = web-next). Flagged, not decided.

---

## 3. #2 — `@banxe/mobile` canonical + RN/React unify

**Verified facts (IL-442):** two distinct Expo apps under one name.

| | platform/packages/mobile | ui/apps/mobile |
|---|---|---|
| src (.ts/.tsx) | 10 | 19 |
| React Native | 0.76.5 | 0.76.9 |
| React | 18.3.2 | 18.3.1 |
| Expo | ~53.0.0 | ~53.0.0 |
| routes/layers | app/: (tabs), auth, **cards**, **sca**, kyc | app/: (tabs), auth, kyc + src/: **components, screens, theme** |

**Options (AWAITS OPERATOR — not selected):**
- **(A) `ui/apps/mobile` canonical** — larger, layered (screens/theme/components); adopt RN 0.76.9/React 18.3.1; port platform's `cards`+`sca` routes in. *Trade-off:* keeps the more mature app; must migrate cards/sca; per Roster-C, app-shell home is `banxe-platform` → would also require re-home.
- **(B) `platform/packages/mobile` canonical** — Roster-C app-shell home; adopt platform RN 0.76.5/React 18.3.2; port ui's screens/theme/components in. *Trade-off:* aligns with app-shell-in-platform boundary; must migrate ui's richer layers + downgrade RN patch.
- **RN/React unify direction** (0.76.9 vs 0.76.5; 18.3.1 vs 18.3.2): **AWAITS OPERATOR** — pick a single target pair regardless of canonical app.

---

## 4. #4 — promotion window (feature→main)

**Verified facts:** both repos carry active work on feature branches — `banxe-platform` `factory/ai-onboarding`, `banxe-ui` `feat/ai-onboarding` (M2.8-PRE handoff; local clones currently on `main` — re-confirm authoritative branch server-side).

**Options (AWAITS OPERATOR — not selected):**
- **(A) dedup-then-promote** — resolve #1/#2 (namespace-dedup) on the feature branches first, then a single feature→main promotion per repo. *Trade-off:* one clean promotion; longer-lived feature branches.
- **(B) phased promotion** — promote non-colliding packages to main first, dedup the two collisions in follow-up. *Trade-off:* faster partial main convergence; but two `@banxe/shared`/`@banxe/mobile` co-exist transiently (ADR-102 risk window).

**Dependency:** promotion (#4) should follow #1/#2 resolution (you cannot promote a clean unified roster while two collisions exist). See §6.

---

## 5. #5 — owner assignment

**Options (AWAITS OPERATOR — not selected):**
- **(A) single owner** for both `@banxe/shared` + `@banxe/mobile` post-split. *Trade-off:* one accountable point; risk of bottleneck.
- **(B) per-package owner** — separate owners. *Trade-off:* parallelism; needs interface-contract discipline at the package boundary.

Cross-cutting: owner choice interacts with where each package lands (#1/#2) and SMCR/role mapping (do not alter STAFF-MATRIX here).

---

## 6. Dependency order

```
#1 (@banxe/shared canonical) ─┐
                              ├─► namespace-dedup ─► #4 promotion (feature→main)
#2 (@banxe/mobile canonical) ─┘
#5 (owners) ── cross-cutting (applies to #1/#2 outcomes) ──────────────┘
context: #687 web-decision (IL-440) already fixed — canonical web = web-next
```
- **#1 + #2 are prerequisites** for namespace-dedup, which is a prerequisite for **#4** promotion.
- **#5** is cross-cutting (assign once #1/#2 land each package's home).
- Parity-inventory (fail-closed) precedes any `web-vite` retire (per IL-440), independent of #1/#2.

---

## 7. Next-action map (per outcome → unblocked scaffold-substep — NOT executed)

| Gate | Operator outcome | Unblocks (later, server-side, separately gated) |
|---|---|---|
| #1 | A / B / C for `@banxe/shared` | scaffold: dedup `@banxe/shared` per chosen direction; re-point enumerated consumers |
| #2 | canonical mobile + RN/React target | scaffold: unify `@banxe/mobile`; migrate route/layer gap; pin RN/React |
| #4 | A dedup-then-promote / B phased | promotion PRs feature→main (per repo) under ADR-102 + ADR-103 |
| #5 | single / per-package owner | assign CODEOWNERS / governance owner for unified packages |

*No substep above is performed here; each is a future, separately-gated task that starts only after the corresponding operator decision (fail-closed).*

---

## 8. Provenance footer
- Consolidated from main: **IL-440** (web-unify, #687), **IL-441** (Roster-C split spec), **IL-442** (§6 divergence evidence).
- Evidence provenance: `verified-legion` (read-only Legion clones `banxe-ui`/`banxe-platform`; evo1 unavailable → re-confirm server-side).
- Discipline: ADR-102 (anti-dup), ADR-103 (server-only refactor), ADR-059-A (append-only ledger), ADR-060 (branch namespace), I-27 (KYC HOLD), Rule 11 (operator gates).

*Selects nothing. No code/scaffold/file-move/merge/runtime change. canonical/versions/owners/promotion remain AWAITS OPERATOR. KYC untouched; STAFF-MATRIX untouched; parallel-session branches untouched.*
