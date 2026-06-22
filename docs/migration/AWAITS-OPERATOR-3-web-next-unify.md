# AWAITS-OPERATOR #3 — Web framework unify decision (Next canonical)

**Status:** DECISION captured (operator/governance artifact) · **Date:** 2026-06-22 · **Type:** docs-only governance, **NO code migration, NO app-code merge, NO runtime change**
**Refers:** AWAITS-OPERATOR #3 of `docs/migration/MIG-M2.8-roster-c-split-spec.md` (Roster C split) · **Discipline:** ADR-102 (anti-dup), ADR-103 (server-only when promotion happens), ADR-059-A (append-only ledger).
**Provenance:** audit evidence = `verified-legion` (read-only on Legion clones `banxe-ui`, `banxe-platform`; **evo1 unavailable** → re-confirm server-side before any code phase).

> This document records the operator-attested **decision** for AWAITS-OPERATOR #3. It moves no files and migrates no code (see Non-goals). It resolves only the *which-web-framework-is-canonical* question; canonical picks for `@banxe/shared`/`@banxe/mobile` (#1/#2) and owners (#5) remain open.

---

## 1. Decision

| Surface | Decision |
|---|---|
| **`banxe-ui/apps/web-next`** | **CANONICAL web target** — Next App Router, React 19; closest to the target EMI / BANXE AI BANK web shell. |
| **`banxe-platform/packages/web`** | **platform-owned web package/surface** — subject to review for **re-home or shrink-to-shared-web-kernel**; **NOT** the final product-web shell. |
| **`banxe-ui/apps/web-vite`** | **transitional/legacy web client — RETIRE candidate**. Not promoted as canonical; reduced via **phased route-by-route migration / adapter** into Next. |

---

## 2. Audit evidence (verified-legion)

| Aspect | banxe-ui/apps/web-next | banxe-ui/apps/web-vite | banxe-platform/packages/web |
|---|---|---|---|
| Framework | **Next 16.2.3** (App Router) | **Vite ^5.0.0** (SPA) | Next 15.3.0 |
| React | **19.2.4** | ^18.0.0 | ^19.0.0 |
| src files (.ts/.tsx) | 25 | 35 | 20 |
| Top-level structure | `app/`: auth, dashboard, kyc, preview, settings, transfers, `layout.tsx`, `page.tsx` | `src/`: App.tsx, **router.tsx**, main.tsx, **layouts/**, **screens/**, features, components, hooks, api, theme | `src/` (Next config present) |
| Legacy/transitional indicators | — (modern App Router, RSC-capable) | **`src/router.tsx`** (react-router SPA), **`src/layouts/AuthLayout.tsx`**, **`src/screens/AIAssistant/index.tsx`** | platform-owned; not product shell |

**Reading:** `web-next` is the modern App-Router/React-19 shell aligned to the EMI target. `web-vite` carries a fuller *legacy* SPA surface (own router, AuthLayout, AIAssistant screen) — evidence of transitional role, not a second canonical product shell. `platform/web` is a platform-owned Next surface, smaller, fit for re-home/shrink rather than product shell.

---

## 3. ADR-102 anti-dup conclusion

- **Do NOT maintain two product-web shells** (`web-next` + `web-vite`) in the unified roster — that is the duplication ADR-102 forbids.
- **Unify on Next** (`web-next` canonical).
- **`web-vite` is reduced via route-by-route migration / adapter plan**, not carried as a parallel product shell.
- `platform/web` is **not** a third product shell; review for re-home or shrink-to-shared-web-kernel.
- Hidden-dependency note: route/feature parity between `web-vite` and `web-next` is **not** byte-verified here → the inventory step (§4.2) is mandatory before any retire; **fail-closed** until parity confirmed.

---

## 4. Phased plan (PROPOSED — not executed here)

1. **Freeze** `web-vite` as **non-canonical** (no new product surfaces added there).
2. **Inventory** `web-vite` routes/screens/features (router.tsx + screens/ + features/) and diff vs `web-next` `app/` → parity gap list.
3. **Migrate** missing surfaces into `web-next` (App Router), per route/screen.
4. **Compatibility adapters** only where strictly needed during transition.
5. **Retire** `web-vite` once parity is reached and no consumer depends on it.

*Each step is a later, separately-gated, server-side (ADR-103) code task — not part of this governance doc.*

---

## 5. Explicit non-goals (this step)

- **NO** code migration now.
- **NO** app-code merge.
- **NO** runtime change / build/deploy change.
- **NO** file moves between repos/packages.
- Does **not** resolve AWAITS-OPERATOR #1 (`@banxe/shared`), #2 (`@banxe/mobile`), #5 (owners), or KYC (I-27 HOLD).

---

## 6. Open items still AWAITS OPERATOR
- #1 `@banxe/shared` canonical + merge-of-uniques; #2 `@banxe/mobile` canonical + RN/React unify; #5 owners (see Roster-C spec §6.4).
- `platform/web` final disposition (re-home vs shrink-to-shared-web-kernel) — review pending.
- `web-vite` retire trigger (parity-confirmed) — pending §4.2 inventory.

---

## 7. Provenance footer
- Verified read-only this session (verified-legion): `banxe-ui/apps/web-next` (Next 16.2.3/React 19.2.4, 25 src), `banxe-ui/apps/web-vite` (Vite ^5/React ^18, 35 src, router.tsx+AuthLayout+AIAssistant), `banxe-platform/packages/web` (Next 15.3.0/React ^19, 20 src).
- Parent governance: `docs/migration/MIG-M2.8-roster-c-split-spec.md` (Roster C split + §6 divergence evidence), AWAITS-OPERATOR #3.
- Discipline: ADR-102, ADR-103, ADR-059-A, ADR-060.

*No code was migrated, merged, moved, or executed. This artifact captures the operator/governance web-unify decision only.*
