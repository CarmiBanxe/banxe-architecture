# MIG-M2.8 — Roster-C (split) KICKOFF SPEC + ADR-102 Duplication Audit

**Status:** SPEC / audit only — **NO scaffold, NO code, NO file moves, NO merge** · **Date:** 2026-06-22
**Operator gate:** Roster **C (split)** confirmed — `banxe-ui` = design-system; `banxe-platform` = app-shells. KYC/KYB/AML = **HOLD** (carve-out intact, out-of-scope here).
**Discipline:** ADR-102 (mandatory Duplication Audit before any structural change), ADR-103 (server-only refactor), fail-closed (Rule 10 — scaffold only at confirmed genuine gap; here = findings + plan only).

> This document defines the *target boundary* and the *duplication audit* for the M2.8 frontend split. It moves nothing. Every non-trivial divergence is marked **AWAITS OPERATOR**; the factory does not pick a canonical implementation where the two diverge.

---

## 0. Provenance & method

- **Verified (read-only, this session, local checkouts):** `banxe-platform` (HEAD `4f0ce18`) and `banxe-ui` (HEAD `ce49bdf`) — workspace package enumeration + dependency graph + divergence counts below.
- **Operator-attested / prior M2.8-PRE (handoff):** collision-matrix (IL-429), roster-audit (IL-424), shell-inventory (IL-431), tompayment-provenance (IL-437).
- **AWAITS OPERATOR — branch state.** M2.8-PRE handoff recorded both repos on feature branches (`factory/ai-onboarding` / `feat/ai-onboarding`); local checkouts read here are on `main` (platform `4f0ce18`, ui `ce49bdf`). The authoritative branch for the split + the branch→main promotion window are an **operator decision** (verify server-side on evo1 per ADR-103 before any promotion).

---

## 1. Verified package inventory

**banxe-platform** (`@banxe/*`, 3 packages + root):

| Package | Path | Class |
|---|---|---|
| @banxe/shared | packages/shared | shared lib **(COLLISION)** |
| @banxe/mobile | packages/mobile | app-shell (RN) **(COLLISION)** |
| @banxe/web | packages/web | app-shell (web) |

**banxe-ui** (`@banxe/*`, 8 packages + root):

| Package | Path | Class |
|---|---|---|
| @banxe/ui | packages/ui | design-system |
| @banxe/design-tokens | packages/design-tokens | design-system |
| @banxe/storybook | storybook | design-system |
| @banxe/mocks | mocks | design-system support |
| @banxe/shared | packages/shared | shared lib **(COLLISION)** |
| @banxe/mobile | apps/mobile | app-shell (RN) **(COLLISION)** |
| @banxe/web-next | apps/web-next | app-shell (web) |
| @banxe/web-vite | apps/web-vite | app-shell (web) |

---

## 2. Duplication Audit (ADR-102) — the two collisions

### 2.1 `@banxe/shared` — **DIVERGENT** (not a clean duplicate)

| Aspect | banxe-platform/packages/shared | banxe-ui/packages/shared |
|---|---|---|
| File count | **43** | **10** |
| Build | `main: dist/index.js`, `types: dist/...` (compiled) | `type: module`, `main: src/index.ts` (source export) |
| Top-level src | api-client, design-tokens, store, tokens, types | api, hooks, types |
| **Consumers (enumerated)** | @banxe/web, @banxe/mobile (workspace:*) | @banxe/web-next, @banxe/mobile (workspace:*) |

**Finding:** the two `@banxe/shared` are **different implementations** sharing a name — platform's is richer (store, api-client, design-tokens) and pre-built; ui's is a source-export with hooks + api. A blind merge/delete would break consumers. **Hidden-dependency status:** consumers enumerated above (4 total); but the *internal export surface* of each `index.ts` is not byte-compared here → **fail-closed**.
**Decision:** **merge — but canonical pick = AWAITS OPERATOR.** Owner must decide: (a) which becomes canonical `@banxe/shared`, (b) where it lives post-split (design-system vs app-shell layer — note it carries BOTH design-tokens *and* api/store, straddling the split line), (c) export-surface reconciliation. No move until this is resolved.

### 2.2 `@banxe/mobile` — **DIVERGENT** (different RN + size)

| Aspect | banxe-platform/packages/mobile | banxe-ui/apps/mobile |
|---|---|---|
| File count | **15** | **31** |
| React Native | **0.76.5** | **0.76.9** |
| Expo | ~53.0.0 | ~53.0.0 |
| Depends on | @banxe/shared (workspace:*) | @banxe/shared (workspace:*) |
| External consumers | none (leaf app) | none (leaf app) |

**Finding:** divergent RN patch (0.76.5 vs 0.76.9) + different maturity (ui/mobile is larger, 31 vs 15 files). Leaf apps (nothing imports them), so no hidden downstream consumers — but they are two *different* app-shells under one name.
**Decision:** **keep ONE as canonical app-shell in `banxe-platform`; RN version unify = AWAITS OPERATOR.** Which mobile shell is canonical (and the unified RN/Expo target) is an operator/owner call — not auto-selected.

---

## 3. Target boundary under Roster C (PROPOSED — no execution)

| Package | Current repo | Target repo (Roster C) | Action | Provenance |
|---|---|---|---|---|
| @banxe/ui | banxe-ui | **banxe-ui** (design-system) | keep | verified |
| @banxe/design-tokens | banxe-ui | **banxe-ui** | keep | verified |
| @banxe/storybook | banxe-ui | **banxe-ui** | keep | verified |
| @banxe/mocks | banxe-ui | **banxe-ui** | keep | verified |
| @banxe/web | banxe-platform | **banxe-platform** (app-shell) | keep | verified |
| @banxe/web-next | banxe-ui | **banxe-platform** | move (app-shell out of design-system repo) | PROPOSED — AWAITS OPERATOR |
| @banxe/web-vite | banxe-ui | **banxe-platform** | move / or retire (web-next vs web-vite overlap) | PROPOSED — AWAITS OPERATOR |
| @banxe/mobile | both | **banxe-platform** | **merge→one canonical** | AWAITS OPERATOR (§2.2) |
| @banxe/shared | both | **AWAITS OPERATOR** (straddles design-system↔app-shell) | **merge→one canonical** | AWAITS OPERATOR (§2.1) |

> Rationale for Roster C boundary: design-system (`@banxe/ui`, `@banxe/design-tokens`, `@banxe/storybook`, `@banxe/mocks`) consolidates in `banxe-ui`; all app-shells (`web`, `web-next`, `web-vite`, `mobile`) consolidate in `banxe-platform`. The two collisions cross the boundary and are not auto-resolved.

### 3.1 branch→main promotion (PROPOSED, not executed)
Both repos default to `main`; M2.8-PRE recorded active work on feature branches. Promotion of the split result → `main` of each repo happens **only** server-side (ADR-103) via smart-refactor discipline (ADR-102 Duplication Audit on the promotion PR), after the AWAITS-OPERATOR items below are resolved. Not performed in this SPEC.

---

## 4. Open items register (AWAITS OPERATOR)

1. **`@banxe/shared` canonical** — which implementation (platform-43-files vs ui-10-files) becomes canonical, its post-split home (it carries both design-tokens *and* api/store → straddles the split), and export-surface reconciliation (§2.1).
2. **`@banxe/mobile` canonical** — which mobile app-shell is canonical; **RN/Expo unify target** (0.76.5 vs 0.76.9) (§2.2).
3. **Next unify** — `@banxe/web` (Next 15.3/React 19) vs `@banxe/web-next` (Next 16.2) vs `@banxe/web-vite` — target framework/version + whether web-vite is retired (§3).
4. **Authoritative branch + promotion window** — feature branch vs main; branch→main promotion timing (§0, §3.1).
5. **Owner assignment** — single owner for `@banxe/shared` + `@banxe/mobile` post-split.
6. **KYC/KYB/AML** — out-of-scope (I-27 HITL-L4 gate = HOLD); no frontend KYC surface touched here.

---

## 5. Provenance footer (sources)

- Verified read-only this session: `banxe-platform@4f0ce18`, `banxe-ui@ce49bdf` (workspace package.json inventory, dependency graph, file-count divergence).
- M2.8-PRE canon: collision-matrix (IL-429), roster-audit (IL-424), shell-inventory (IL-431), tompayment-provenance (IL-437).
- Discipline: ADR-102 (Duplication Audit), ADR-103 (server-only refactoring), ADR-059-A (append-only ledger), ADR-060 (branch namespace).

*No file was moved, created (beyond this spec + its ledger shard), merged, or scaffolded. No canonical implementation was selected where the two repos diverge — those are AWAITS OPERATOR. KYC untouched.*

---

## 6. DIVERGENCE Evidence — `@banxe/shared` & `@banxe/mobile` (addendum)

**Added:** 2026-06-22 · **Provenance:** `verified-legion` (re-verified read-only on Legion clones — **evo1 was unavailable**, so this is operator-attested-Legion, NOT verified-evo1; re-confirm server-side before any promotion). **Decides nothing** — fixes evidence for AWAITS-OPERATOR #1/#2/#5; canonical/versions remain operator's call (Rule 11).

### 6.1 `@banxe/shared` — distinct role under one name

| Aspect | banxe-platform/packages/shared | banxe-ui/packages/shared | Provenance |
|---|---|---|---|
| src files (.ts/.tsx) | **16** | **7** | verified-legion |
| src modules | api-client.ts, design-tokens.ts, store, tokens, types, index.ts | api, hooks, types, index.ts | verified-legion |
| exports surface | `.` only (single barrel; dist-built `main: dist/index.js`) | `.`, `./api`, `./types`, `./hooks` (granular; src-module) | verified-legion |
| version | 0.1.0 | 0.1.0 | verified-legion |
| **overlap** | `index.ts` + `types` | `index.ts` + `types` | verified-legion |
| **unique** | api-client, **store**, design-tokens, tokens | **hooks**, api (granular) | verified-legion |

### 6.2 `@banxe/mobile` — distinct role under one name

| Aspect | banxe-platform/packages/mobile | banxe-ui/apps/mobile | Provenance |
|---|---|---|---|
| src files (.ts/.tsx) | **10** | **19** | verified-legion |
| `app/` routes | (tabs), auth, cards, sca, kyc | (tabs), auth, kyc | verified-legion |
| `src/` layers | — | components, screens, theme | verified-legion |
| React Native | **0.76.5** | **0.76.9** | verified-legion |
| React | **18.3.2** | **18.3.1** | verified-legion |
| Expo | ~53.0.0 | ~53.0.0 | verified-legion |

> NB (inventory-only, no action): both mobile shells contain an `app/kyc/` route. This is recorded as structure inventory only — **the KYC/KYB/AML track stays HOLD (I-27); nothing in any KYC surface is read-into, modified, or scaffolded here.** platform/mobile additionally carries `cards` + `sca` routes; ui/mobile carries a `src/screens`+`theme` layer.
>
> Correction to §2 estimates: ui/mobile source count = **19** `.ts/.tsx` (verified-legion), vs the earlier whole-tree `find` figure (31) and a 15-file estimate; platform/shared = **16**, ui/shared = **7** source files (the §2.1 "43 vs 10" were whole-tree counts incl. config/dist). Role conclusions are unchanged.

### 6.3 Conclusion

Both collisions are **distinct roles sharing one package name**, not byte-duplicates:
- `@banxe/shared`: platform = app-data layer (store/api-client/tokens, single barrel, pre-built); ui = view-support layer (hooks/granular-api, source-module). Only `index.ts`+`types` overlap.
- `@banxe/mobile`: two different Expo apps (different route sets, RN/React patch, src layering).

⇒ **namespace-dedup is MANDATORY at split** (cannot keep two `@banxe/shared` / two `@banxe/mobile` in a unified roster). This addendum does **not** choose the canonical or the merge direction.

### 6.4 AWAITS OPERATOR (sharpened, still operator's call — Rule 11)
- **#1 `@banxe/shared` canonical + merge-of-uniques:** which barrel is canonical, and where each unique lands — e.g. `store`/`api-client`/`tokens` (app-data) vs `hooks`/granular-`api` (view-support). Note it straddles design-system↔app-shell. **AWAITS OPERATOR — not selected.**
- **#2 `@banxe/mobile` canonical + RN/React unify:** RN 0.76.5↔0.76.9, React 18.3.2↔18.3.1; which app-shell is canonical; reconcile route sets (cards/sca vs src/screens). **AWAITS OPERATOR — not selected.**
- **#5 owners:** single owner for the unified `@banxe/shared` + `@banxe/mobile`. **AWAITS OPERATOR.**
