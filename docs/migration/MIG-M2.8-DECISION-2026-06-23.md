# MIG-M2.8 Decision Record — 2026-06-23

> Thin decision-shard. Records the one resolved item and **parks** the still-open
> binding items. Reference-only — does NOT re-spec or duplicate existing briefs
> (ADR-102). No code, no file moves, no merge. Binding values/owners stay
> **AWAITS OPERATOR** (Rule 11 — factory does not invent them).

## §1 — Resolved (already on main; reference, not re-spec)

- **AWAITS-OPERATOR #3 — canonical web target = `banxe-ui/apps/web-next`.**
  - `banxe-ui/apps/web-vite` = transitional/legacy SPA, **RETIRE candidate** (route-by-route migration, not a parallel shell).
  - `banxe-platform/packages/web` = platform-owned surface, **re-home / shrink** (not the final product shell).
  - Source of truth (do not duplicate): [`docs/migration/AWAITS-OPERATOR-3-web-next-unify.md`](./AWAITS-OPERATOR-3-web-next-unify.md)
    and the parent [`docs/migration/MIG-M2.8-AWAITS-OPERATOR-decision-brief.md`](./MIG-M2.8-AWAITS-OPERATOR-decision-brief.md).

## §2 — STILL AWAITS OPERATOR (parked — NOT chosen here, Rule 11)

| # | Open binding item | Options | Status |
|---|---|---|---|
| 1 | `@banxe/shared` canonical | A (split) / B (ui) / C (platform) | **AWAITS OPERATOR** |
| 1 | `types` home + `design-tokens` home | overlap unresolved | **AWAITS OPERATOR** |
| 2 | `@banxe/mobile` canonical | A (ui) / B (platform) + RN/React target pair | **AWAITS OPERATOR** |
| 5 | Owners for unified `shared` / `mobile` | — | **AWAITS OPERATOR** |
| — | Cross-repo write authorization → `banxe-emi-stack` | gates S-PROD-1/2/3 code phase | **AWAITS OPERATOR** |

Full enumeration lives in `MIG-M2.8-AWAITS-OPERATOR-decision-brief.md` — referenced, not restated.

## §3 — Note

Gated items stay gated. Resolving §2 unblocks **S-MIG-M2.8** and **S-PROD-8**.
No runtime/build/file-move change is implied by this record.
