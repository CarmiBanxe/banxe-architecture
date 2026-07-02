# CONSOLIDATION-PLAN — Phase 2
**Date:** 2026-07-02
**Status:** IN PROGRESS
**Owner:** Moriel Carmi (CEO)
**Depends on:** GLOBAL-PROGRAM-PLAN (IL-803), MASTER-ORG-CODE-RUNTIME-DOSSIER (IL-803)
**Parent:** GLOBAL-PROGRAM-PLAN.md (Phase 2: CONSOLIDATION PREP)

---

## Principle (operator-approved 2026-07-02)

Canonical = (active in runtime) AND (correct domain location) AND (system-of-record per DOSSIER §3).
Duplicate twins are NEVER deleted now — flagged archive-candidate, physically touched only in Phase 7
after proof (I-24, ADR-102). This plan = planning + verification only. NO code merges until Phase 7.

---

## Duplicate Resolutions (4)

| # | Duplicate | CANONICAL (keep) | Twin (archive-candidate) | Status |
|---|-----------|-----------------|--------------------------|--------|
| 1 | `banxe_aml_orchestrator.yaml` | `agents/passports/aml/banxe_aml_orchestrator.yaml` (L3, complete) | `agents/passports/banxe_aml_orchestrator.yaml` (root, autonomy=unset) | **PENDING MLRO/CTIO SIGN-OFF** — blocking |
| 2 | vibe-coding vs EMI stack | BOTH RETAINED — distinct, no overlap (DOSSIER §4, vibe-coding = 0 coupling) | — | **RESOLVED** — not a duplicate |
| 3 | Payment (`banxe-payment-core` vs `services/payment/`) | `services/payment/` (EMI runtime domain, ADR-015 payment orchestration) | `banxe-payment-core` (evaluate as lib or archive — Phase 2 verification required) | **CANONICAL SET** — verification pending |
| 4 | Intent (`banxe-ai-infrastructure` vs `services/intent_layer/`) | `banxe-ai-infrastructure` Intent-Dispatcher (live Floor 1, active b2 branch 2026-07-01) | `services/intent_layer/` in EMI = thin seam (GAP-091, INTENT_LAYER_ENABLED=false, ADR-049) | **CANONICAL SET** — GAP-091 resolution pending |

---

## Phase 2 Scope

**This phase = planning + verification. NO merges.**

### Tasks

| Task | Owner | Status | Blocker |
|------|-------|--------|---------|
| T2.1 | AML orchestrator canonical sign-off | MLRO / CTIO | **BLOCKING** — must resolve before Phase 3 |
| T2.2 | `banxe-payment-core` runtime verification (is it deployed? standalone lib?) | CTIO / Factory | PENDING |
| T2.3 | GAP-091 resolution plan (Intent-Dispatcher deployment) | Product / CTIO | PENDING — Phase 2 verification |
| T2.4 | MIG-M2.4 A/B/C PSD2 router consolidation selection | CTIO | PENDING |
| T2.5 | Produce per-duplicate verification evidence (before any Phase 7 archive action) | Factory | PENDING |
| T2.6 | Stale local clone cleanup plan (§8.2 duplicate checkout risk) | Operator | PENDING |

### Non-negotiable guards

- **I-24 append-only**: archive actions only in Phase 7 with documented proof
- **ADR-102**: no domain deletion without MLRO/CEO sign-off
- **ADR-120**: all factory git work in worktrees only
- **Controlled merge ONLY in Phase 7** with per-duplicate verification evidence

---

## Open Operator Decisions (carried forward from Phase 1)

| OD | Decision | Owner | Urgency |
|----|----------|-------|---------|
| OD-1 | `banxe_aml_orchestrator.yaml` dup: deprecate root copy or reconcile autonomy fields | MLRO / CTIO | **BLOCKING Phase 3** |
| OD-2 | MIG-M2.4: A/B/C selection for PSD2 router consolidation | CTIO | Q2-2026 |
| OD-3 | USB4 peer 10.0.0.1 physical identity + hostname | Operator | Q3-2026 |
| OD-5 | `privacy_compliance_agent` status mismatch (v2=active, YAML=PROPOSED) | DPO / CTIO | Q3-2026 |

---

## Phase 2 → Phase 3 Gate

Phase 3 (SSOT) may not begin until:
- [ ] OD-1 resolved (MLRO/CTIO sign-off on AML orchestrator canonical)
- [ ] T2.2 complete (payment canonical verification evidence)
- [ ] T2.3 complete (intent layer GAP-091 resolution plan)
- [ ] T2.5 complete (per-duplicate verification evidence produced)

---

## Append-only lineage

| Version | Date | Key change |
|---------|------|-----------|
| v1 | 2026-07-02 | Initial Phase 2 plan — 4 dup resolutions, operator decisions, Phase 3 gate |

---

*Phase 2 CONSOLIDATION PREP · child of GLOBAL-PROGRAM-PLAN · append-only (I-24). DO NOT rewrite history.*
