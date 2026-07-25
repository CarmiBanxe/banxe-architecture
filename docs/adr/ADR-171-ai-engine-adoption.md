# ADR-171: AI Engine Reference Adoption (BANXE Banksy engine, E0–E6)

**Status:** PROPOSED — no activation
**Date:** 2026-07-26
**Track:** ENGREF01 (`agent/factory/ENGREF01/engine-reference-adoption`)
**Sources:** consolidated engine reference rebuilt v2 (A–N) built from session analytics #1 (OSS catalog),
#2 (UX/UI), #3 (world experience), #4 (engine reference). **OP-A: sources are session versions —
no analytics files exist on disk** (verified by STEP-0 audit 2026-07-26).

## Context

Four analytics passes produced a consolidated open-source AI-engine reference for the BANXE bank
(7-layer architecture, agent roster, verbatim math, production gates, audit schema, security map,
CI/CD graph, E0–E6 phases). A STEP-A diff against the current repo (2026-07-26, base 07870b6) found:
no `docs/engine/`, no `roadmap/` E-phases, no `config/gates/`; canonical audit table
`banxe_audit.hitl_decisions` exists (`sql/create-banxe-audit-hitl-decisions-2026-05-12.sql`);
the engine doc + Agent Registry live ONLY in `~/banxe-dev/emi-banxe-engine.md` (**not a git repo**);
`banxe-agent-review.yml` exists ONLY as an embedded YAML block inside that doc (line ~922), not as a
real workflow.

## Decisions (all PROPOSED; activation gated per CLAUDE.md §11)

1. **Adopt the 7-layer target architecture (L1–L7)** as the engine reference, materialized in
   `docs/engine/BANXE-AI-ENGINE-REFERENCE.md`. Because `~/banxe-dev/emi-banxe-engine.md` is not
   committable (non-repo location), the repo doc is declared the **single source of truth going
   forward**; the banxe-dev copy is legacy input (Duplication-Audit: keep as historical source,
   supersede — see §Duplication Audit).
2. **L6 routing rule:** real-time/interactive → LangGraph (<300ms); complex/deep-research/report →
   DeerFlow 2.0; MCP-native production candidate → Strands SDK.
3. **License-gate (formal criterion):** production core = **MIT / Apache-2.0 / BSD-permissive only**.
   **AutoGen (CC-BY-NC-4.0) excluded from production.** OP-N1: verify `microsoft/autogen` vs AG2 fork
   licenses separately at license-audit — AG2 may be MIT and remain a candidate. Foreign-origin
   components additionally pass jurisdiction/supply-chain review (SANCTIONS-POLICY.md).
4. **Audit schema = DELTA ALTER, no second table:** extend `banxe_audit.hitl_decisions` with 8 columns
   (see `sql/alter-banxe-audit-hitl-decisions-engine-ref-2026-07-26.sql`); keep ReplacingMergeTree,
   PARTITION toYYYYMM, ORDER BY (decision_id, ts), TTL 7Y. Operator runs DDL; sub-A cannot touch the
   live cluster.
5. **Deployment confidence gates:** staging ≥0.75, production ≥0.90 + human approval; Excessive-Agency
   gate 0.90 (`config/gates/confidence-thresholds.yaml`, PROPOSED). Additive to runtime HITL canon
   (agents.md BUG-007) and adjacent to ADR-030 runtime_gate budgets
   (`config/runtime_gate/agent-budget-policy.yaml` — owned by redgate/red-budget tracks; NOT modified
   here; integration = future joint change-set with that track).
6. **Agent Registry extension** (single registry, in the engine reference doc): add FX, Savings,
   Analytics, Treasury, KYC, Support to existing Transfer + Compliance-gate. **Model bindings via
   LiteLLM aliases only** (resolves OP-M2); hardcoded model names from analytics are non-normative.
7. **E0–E6 phase naming** for engine adoption (`roadmap/BANXE-E0-E6.md`); calendar roadmap-v3 untouched.
8. **CI/CD extension as PROPOSED artifact:** extended pipeline stored at
   `docs/engine/proposed-workflows/banxe-agent-review.yml`, deliberately NOT under `.github/workflows/`
   — placing it there would self-activate on merge, violating no-activation. Promotion to live
   workflows = separate operator-gated change-set.
9. **Prompt-as-versioned-artifact** (triple-confirmed: DSPy + Latitude + Nubank Prompt Semantic
   Versioning, modules Tone/Tooling/Safety) accepted as principle; tooling choice deferred (OP-J2).
   OP-N2 (Japa vs GEPA optimizer name): precedence latest>older → GEPA, verify at materialization.

## Reserved — explicitly NOT decided here (existing canon stands)

- **L2 ledger:** ADR-013 (Midaz PRIMARY / Fineract FALLBACK) and I-28 (LedgerPort only, no direct CBS
  HTTP) remain authoritative. Formance/Blnk = candidates strictly behind LedgerPort; **no ledger
  rewiring** in any E-phase without a dedicated ADR.
- **OPERATOR DECISION 1 — wave order:** E1 TransferAgent-first vs back-office-first (BCG). Neither
  implemented.
- **OPERATOR DECISION 2 — branch reconciliation:** bank-operating-model track divergence vs origin/main.
- Friendly-mode boundary (OP-B3/G), messenger channels (OP-J1: data-residency/identity), crypto channel
  (OP-J3: separate FCA perimeter) — gated backlog, registered in the UI docs delta; none implemented.

## Duplication Audit (ADR-102)

| Match found | Location | Decision | Risk |
|---|---|---|---|
| Engine doc + Agent Registry | `~/banxe-dev/emi-banxe-engine.md` (non-repo) | **supersede** (repo doc becomes canonical; banxe-dev = legacy source, keep unmodified) | dual-source drift if banxe-dev copy keeps evolving → flagged to operator |
| hitl_decisions DDL | `sql/create-banxe-audit-hitl-decisions-2026-05-12.sql` (+`patches/` copy) | **keep + extend** (DELTA ALTER script, no new table) | none if ALTER applied once |
| agent-review workflow | embedded YAML in banxe-dev doc | **merge** into proposed-workflows artifact | activation risk handled by placement outside `.github/workflows/` |
| Repo catalog | `docs/financial-analytics-research.md` (50+/13 blocks) | **keep + delta section** (no renumbering) | none |
| UX/UI canon | `docs/BANXE-UI-{ARCHITECTURE,UX-SYSTEM,UX-RESEARCH}.md`, `BANXE-SCREEN-INVENTORY.md` | **keep + delta sections**; W-05 "AI cannot initiate payments" canon NOT overridden — state-changing Rich Cards = gated backlog | canon tension documented, resolution = operator |
| Runtime gates | `config/runtime_gate/agent-budget-policy.yaml` (foreign track) | **keep, do not touch** — cross-ref only | §72 single-writer respected |

Repo-wide search performed (STEP-0 find + STEP-A greps); consumers of hitl_decisions DDL: operator-run
ClickHouse (no code consumers in this repo detected). No delete/merge of any existing artifact.

## Consequences

- Engine model becomes reviewable in-repo, fully PROPOSED; zero behavior change until Promotion Gate.
- Two operator decisions + license-audit (OP-N1) + prompt-tooling choice (OP-J2) are the unblock path.
- QGNN/VQC parked (research-track, 2027–2028); not part of any E-phase.

## Anchors

ADR-013, ADR-030, ADR-102, ADR-103, ADR-060, ADR-119/120/121, ADR-167 (assistant-ui intent-first),
ADR-168 (Langfuse), ADR-169 (LIME/SHAP), CLAUDE.md §10/§11, SANCTIONS-POLICY.md,
`docs/engine/BANXE-ENGINE-MATH.md`, `docs/engine/BANXE-SECURITY-OWASP.md`, `roadmap/BANXE-E0-E6.md`.
