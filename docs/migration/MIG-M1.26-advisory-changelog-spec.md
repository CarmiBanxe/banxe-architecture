# MIG-M1.26 — Advisory-surface changelog (governance SPEC, code PROPOSED)

**Status:** governance spec — **code PROPOSED / deferred to evo1 (ADR-103); NOT executed** · **Date:** 2026-06-22
**Type:** docs-only (this artifact lives in `banxe-architecture`) · **NO code produced, backend repo untouched, NO merge**
**Target repo (later, server-side):** `CarmiBanxe/banxe-trading-backend` · **Track:** M1.x advisory surfaces (advisory-seam ADRs).

> Operator decision (this session): produce the **governance spec only** now; the backend code for M1.26 is **PROPOSED** and runs later **server-side on evo1** (ADR-103) once evo1 is re-confirmed (open pre-flight item, see `MIG-M2.8-preflight-readiness.md` / IL-445). The factory did **not** clone or edit the backend repo on Legion.

---

## 1. Why spec-only now (ADR-103 stop-barrier)

- M1.26 is a **code change** to a product repo (`banxe-trading-backend`): new DTO + router + tests + router registration.
- **ADR-103 PART 1** (server-only): product code edits + working copies + commit/push run **ONLY on evo1**; Legion = thin client. This session is bound to **Legion (`mark-legion`)**; the backend repo is **not** present locally; **evo1 re-confirm is OPEN**.
- Therefore code execution is **deferred**; this doc captures the spec/contract so the evo1 run is deterministic when unblocked.

---

## 2. Surface spec (PROPOSED)

**New endpoint:** `GET /api/v1/catalogue/changelog` → `AdvisorySurfaceChangelog` (fourth meta/inventory surface).

**DTOs (frozen, config-as-data):**
- `ChangelogEntry { substep: str, title: str }` — `substep` is a **non-exhaustive string, never an enum** (the list grows).
- `AdvisorySurfaceChangelog { entries: list[ChangelogEntry], total_entries: int, version: str (reuse __version__), source: str }`.

**Files (to be created on evo1):**
- `app/meta/changelog.py` — `_ADVISORY_CHANGELOG` curated list (M1.1…M1.26) + frozen DTOs + pure `build_advisory_surface_changelog()` (no I/O).
- `app/api/catalogue_changelog.py` — router, built once at import (static config-as-data).
- register router in `app/main.py` (`include_router`).
- `tests/test_advisory_changelog.py` — characterization + contract + fail-closed + negative-fence.

*(Full reference implementation provided by the operator's factory prompt; not reproduced inline — it is the build input for the evo1 run, not an arch-repo code artifact.)*

---

## 3. ADR-102 four-way distinction (no overlap)

| Endpoint | Counts / provenance |
|---|---|
| `catalogue_meta` (M1.14) | catalogue DATA-row counts |
| advisory-surface manifest (M1.24) | advisory ENDPOINT families |
| schema inventory (M1.25) | advisory DTO/SCHEMA families |
| **changelog (M1.26)** | advisory SUBSTEP history/provenance |

Distinct dimension (substep timeline) → no duplication of the prior three. A full **execution-time ADR-102 re-audit** is still required on evo1 before the code lands (state may drift).

---

## 4. Invariants / fences (to enforce in the evo1 build)

- Config-as-data, **not** a reflection/scan; fixed curated list (fail-closed).
- **Zero `LedgerPort` / `FeeEnginePort` refs**; no balances/positions/postings/fees.
- Frozen DTOs; existing `CatalogueMeta` / `AdvisorySurfaceManifest` / `SchemaInventory` **untouched**.
- Reuse `__version__` (no second version source).
- **Negative-fence:** no live/regulated/auth substep keywords (order/execution/ledger/payment/wallet/custody/kyc/aml/auth/sandbox/internal…).
- Advisory-only (consistent with advisory-seam ADRs); no live data, no runtime mutation.

---

## 5. Execution plan (evo1, when unblocked)

1. **Pre-flight:** evo1 re-confirm (ADR-103) + authoritative-branch confirm + ADR-102 execution-time re-audit.
2. Isolated worktree on evo1 from fresh `banxe-trading-backend` origin/main; branch `agent/factory/m1/advisory-changelog-m1-26` (ADR-060).
3. Add the 3 files + register router; run `pytest` + `ruff` + `mypy` green.
4. Commit + push; open backend PR **DO NOT auto-merge** (operator-gated).
5. Follow-up **DONE** IL-shard in `banxe-architecture` recording the merged code (this spec shard is PROPOSED, not the completion record).

---

## 6. Provenance footer
- This artifact: governance spec only; backend code **PROPOSED / not executed**; backend repo untouched; produced on Legion (docs repo) per operator decision.
- Related: M2.8 pre-flight readiness gate (evo1 re-confirm open item); advisory-seam ADRs; ADR-102 (Duplication Audit), ADR-103 (server-only), ADR-059-A (append-only), ADR-060 (branch namespace), I-27 (KYC HOLD), I-28.

*No backend code produced or pushed. `banxe-trading-backend` not cloned/edited on Legion. No merge. Spec is PROPOSED; code execution deferred to evo1 server-side.*
