# MIG-M2.8 Roster-C — Pre-flight readiness gate

**Status:** readiness note — **gate BEFORE scaffold phase** · **Date:** 2026-06-22
**Type:** docs-only · **NO scaffold, NO code, NO target-repo mutation, NO selection, NO merge**
**Provenance discipline:** facts tagged `verified-legion` (read-only Legion clones) vs `operator-attested` (handoff assertions) — kept separate (Rule 9). **evo1 was unavailable → server-side re-confirm mandatory.**
**Baseline on main:** IL-440 web-unify · IL-441 split spec · IL-442 §6 evidence · IL-443 decision-brief · IL-444 conditional execution-plan.

> Scaffold/promotion does not start until (a) operator resolves AWAITS #1/#2/#4/#5, (b) the banxe-ui dirty blocker (#B1) is cleared, and (c) evo1 server-side state is re-confirmed. This note records readiness; it changes nothing and touches no target repo (Rule 6 — dirty trees are reported, not auto-resolved).

---

## 1. Scope
Pre-flight readiness check for the M2.8 Roster-C scaffold phase. Gate sits between the on-main governance baseline (IL-440..444) and any scaffold substep (which itself is gated on operator resolution of #1/#2/#4/#5, per IL-443/IL-444).

---

## 2. Readiness matrix

| Repo | operator-attested (handoff) | verified-legion (this session, read-only) | Readiness |
|---|---|---|---|
| **banxe-platform** | branch `factory/ai-onboarding`, head `68a692a`, CLEAN → "ready" | branch **`main`**, head **`4f0ce18`**, **DIRTY** (1 file: `turbo.json`) | **NOT confirmed** — local clone diverges from attested feature branch + is dirty → **server-side (evo1) re-confirm required** |
| **banxe-ui** | branch `feat/ai-onboarding`, head `d0eac8d`, DIRTY → blocker | branch **`main`**, head **`ce49bdf`**, **DIRTY** (29 files; `.agents/skills/...` + more) | **BLOCKED** (dirty in both views) — see #B1 |

> **Discrepancy flagged (Rule 9):** the Legion clones are on `main` (not the attested `*/ai-onboarding` feature branches) and both are dirty. The authoritative state is server-side (evo1); the attested feature-branch/head values are **not** verifiable from Legion. This *strengthens* the evo1 re-confirm pre-flight item — neither repo is confirmed-ready from Legion.

---

## 3. BLOCKER #B1 — banxe-ui dirty working tree

- **Observed (verified-legion):** `banxe-ui` has **29 uncommitted changes** (e.g. `.agents/skills/ckm-design-system/...`, `.agents/skills/ckm-design/...`). banxe-platform also dirty (`turbo.json`).
- **Rule:** the factory **does NOT touch a dirty target repo** (parallel-session isolation Rule 6 + fail-closed). Scaffold over a dirty tree risks clobbering parallel-session work (Rule 7).
- **Resolution required (operator/infra, not factory):** decide whether the dirty state is (a) work to commit/stash, or (b) parallel-session work to leave untouched, OR (c) a stale Legion clone to be ignored in favour of authoritative evo1 state. Until cleared/attested, scaffold cannot start on banxe-ui.

---

## 4. Open pre-flight items (from IL-444 execution-plan)

1. **evo1 server-side re-confirm (ADR-103)** — evo1 was unavailable at planning; all scaffold runs are server-side. Re-confirm evo1 availability + authoritative repo state (branch/head/clean) before any move. **OPEN.**
2. **ADR-102 execution-time re-audit** — duplication state may have drifted since IL-442 (08:15); re-run repo-wide audit + consumer enumeration at scaffold time. **OPEN.**
3. **Authoritative-branch re-confirm** — reconcile attested `*/ai-onboarding` feature branches vs observed `main` on Legion (§2 discrepancy). **OPEN.**

---

## 5. Gate status — scaffold phase BLOCKED until ALL of:

- [ ] (a) Operator resolves AWAITS **#1 / #2 / #4 / #5** (Rule 11 — factory does not choose).
- [ ] (b) **#B1** banxe-ui dirty tree resolved/attested (operator/infra).
- [ ] (c) **evo1** server-side re-confirmed (ADR-103) + authoritative-branch reconciled.
- [ ] (d) ADR-102 execution-time re-audit clean.

Until all four are satisfied: **fail-closed — no scaffold, no file moves, no promotion.**

---

## 6. Provenance footer
- Baseline on main: IL-440 (web), IL-441 (spec), IL-442 (evidence), IL-443 (decision-brief), IL-444 (execution-plan).
- This session (verified-legion, read-only): banxe-platform `main@4f0ce18` dirty (turbo.json); banxe-ui `main@ce49bdf` dirty (29 files). evo1 unavailable → server-side re-confirm required.
- Discipline: ADR-102, ADR-103, ADR-059-A, ADR-060, Rule 6 (dirty reported not resolved), Rule 7, Rule 9 (provenance split), Rule 11 (operator gates), I-27 (KYC HOLD).

*No target repo was modified (banxe-ui dirty tree untouched). No scaffold/code/file-move/merge/runtime change. AWAITS #1/#2/#4/#5 not selected. KYC untouched; STAFF-MATRIX untouched; parallel-session/sprint branches untouched.*
