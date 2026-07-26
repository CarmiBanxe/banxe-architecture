# ADR-171: AI Engine Reference Adoption (BANXE Banksy engine, E0–E6)

**Status:** ACTIVE in SANDBOX (TRAINING data) per operator Promotion Gate 2026-07-26 — prod activation remains gated
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

## RESOLVED (PROPOSED) — Fable5 auditor verdicts, 2026-07-26

> Read-only evidence audit per FACTORY→Fable5 delegation. Verdicts are PROPOSED — operator ratifies.
> Evidence gathered 2026-07-26 (shell audit, no writes outside this section).

### DECISION 1 — Wave order: **Option B (back-office-first)** · confidence **0.95** (≥0.90 → auto-decide permitted, ratification pending)

**Verdict:** E1 is re-scoped: the first production agents are back-office — safeguarding daily
reconciliation, CASS reporting support, BI/insight — BEFORE any customer-facing TransferAgent.
TransferAgent remains the first *customer-facing* agent but moves behind the back-office wave.

**Rationale (regulatory > dependency > revenue):**
1. *Regulatory (hard constraint):* `docs/ROADMAP-STATUS-2026-06-23.md` S-PROD-1 — Safeguarding Engine is
   **P0 and OVERDUE (deadline 2026-05-07 passed)**; priority stack (agents.md) puts FCA regulations above
   everything. An EMI moving client money via a new AI agent while its CASS 7.15 daily-recon proof has a
   documented gap would invert the licence-risk hierarchy.
2. *Dependency:* `docs/D-RECON-DESIGN.md` — Midaz internal balances have **no automated link to the
   external safeguarding statement ("BANXE cannot prove CASS 7.15 compliance")**; and S-PROD-3 records
   D-gl ≈ 5% (largest core gap). TransferAgent's execute path REQUIRES ledger integrity + live daily
   reconciliation as preconditions — the dependency graph itself orders back-office first.
3. *Convergence:* BCG insight (analytics #3: back-office yields more value at lower client risk) agrees
   with the regulatory ordering; revenue argument for Option A does not outweigh licence conditions.

**Prerequisites for the wave:** emi-stack UNFREEZE (runtime for safeguarding/recon agents lives in
banxe-emi-stack, FROZEN 2026-07-18) — operator action; ledger via LedgerPort only (unchanged).

### DECISION 2 — Branch reconciliation: **origin/main authoritative; rebase + serialized re-mint path recommended** · confidence **0.80 → HITL ESCALATION (< 0.90, do NOT auto-decide)**

**Evidence:** drift measured 2026-07-26: `agent/factory/bank-operating-model/20260718` = **ahead 63 /
behind 3** vs origin/main (stable since the c02f8d8 baseline audit 2026-07-25, not growing; behind-set =
#1131/#1126/#1132 — no file-conflict-obvious overlap, but 63 commits include the 910-file GENERAL-LINE
commit c02f8d8).

**Recommended path (canon-backed direction, high confidence):** origin/main = source of truth; the branch
reconciles by rebase onto current main + ledger re-mint per Rule 8 / ADR-119 (IL numbers frozen at merge,
`build_ledger.py` on the rebased base) + serialized PR merges (strict branch protection). No force
operations beyond `--force-with-lease` on the branch's own ref.

**Why HITL (< 0.90):** the *strategy* is canon-clear, but the *shape* is an operator-scale judgment:
(a) merge the 63-commit line as one PR series vs split the 910-file GENERAL-LINE commit into reviewable
change-sets vs selective cherry-pick; (b) review burden and rollback surface are material;
(c) irreversibility-adjacent (merge into protected main). These are exactly the stop-barrier class
reserved for the operator.

**Correction to the delegation premise:** *branch* reconciliation lives in **banxe-architecture** (the
branch is in this repo) — emi-stack UNFREEZE is **NOT a prerequisite for D2**. The unfreeze prerequisite
attaches to **D1 execution** (the reconciliation *engine/agents* runtime lives in emi-stack). Premise
conflated D-recon (engine) with branch reconciliation; recorded here to prevent mis-sequencing.

**Ordering vs D1:** D2 (branch merge) and D1 wave-start are independent workstreams; recommended sequence:
ratify D1 immediately (unblocks spec-side prep), schedule D2 as its own serialized merge campaign; D2 must
complete before any S-A5/S-A6/S-A7 status uplift lands on main (those artifacts live on the drifted branch).

### Deliverable summary
- D1: **B, back-office-first**, confidence 0.95 — PROPOSED for ratification.
- D2: direction fixed (main authoritative, rebase+re-mint+serialize), shape **escalated to operator (HITL)**, confidence 0.80.
- Prerequisites: emi-stack unfreeze (for D1 wave execution); no unfreeze needed for D2; drift stable at 63/3.

## RATIFICATION UPDATE — operator-approved 2026-07-26 (factory task, post-eba1d79)

### D1 — **RATIFIED: back-office-first (Option B)**
- Operator approval recorded 2026-07-26 02:xx CEST. Rationale as verdicted: S-PROD-1 Safeguarding P0
  OVERDUE (`docs/ROADMAP-STATUS-2026-06-23.md:69`); CASS 7.15 gap (`docs/D-RECON-DESIGN.md:24`);
  D-gl ≈ 5%; dependency graph (TransferAgent execute-path requires ledger integrity + live daily recon).
- Wave order is now binding for spec prep: E0 Foundation → **back-office wave (safeguarding / recon / BI
  agents)** → THEN E1 TransferAgent. **TransferAgent (customer-facing) is BLOCKED until ledger integrity
  + live daily reconciliation are green.** Reflected in `roadmap/BANXE-E0-E6.md`.
- **emi-stack UNFREEZE: operator-APPROVED** as D1-execution prerequisite (runtime safeguarding/recon
  agents live in banxe-emi-stack, frozen 2026-07-18). Unfreeze **execution = MAIN TERMINAL** (sub-A
  cannot unfreeze). Post-unfreeze scope: back-office agents ONLY; everything else in emi-stack stays
  change-frozen until its own gate.

### D2 — HITL resolved by operator: **form (b) — change-set split**
- Confidence gap (0.80) closed by operator choice, not auto-decision. Campaign (MAIN TERMINAL, serialized):
  1. Rebase `agent/factory/bank-operating-model/20260718` onto current origin/main (07870b6+); absorb
     behind-3 first (#1131 / #1126 / #1132).
  2. **Split the 910-file GENERAL-LINE commit (c02f8d8) into reviewable change-sets by bounded
     context/layer** (ledger-recon, safeguarding, BI, UI, engine-ref, …) — one change-set = one PR.
  3. Serialize: one PR open at a time, atomic lifecycle §74, pre-commit auditor PASS per PR.
  4. Ledger re-mint per Rule 8 / ADR-119 on the rebased base — IL numbers minted at merge via
     build_ledger, never before.
  5. **D2 completes BEFORE any S-A5 / S-A6 / S-A7 status uplift lands on main.**
- ENGREF01 branch (this one, 11+ local commits) also awaits main-terminal push/PR — ordering to be
  coordinated with the D2 campaign by main terminal.

### §Unfreeze — emi-stack (executed STEP 1 of unified order, 2026-07-26)

- **Operator-approved unfreeze EXECUTED as record:** banxe-emi-stack FROZEN(2026-07-18) status is lifted
  effective 2026-07-26 (unified execution order, operator-authorized 02:xx CEST).
- **Scope limit (binding):** writes permitted ONLY for the back-office wave — safeguarding / daily-recon /
  CASS reporting / BI agents. All other emi-stack surfaces remain change-frozen until their own gates.
- Mechanics: no `.FROZEN` flag file exists — the freeze was operational; this ADR section is the canonical
  unfreeze record. Executor: main terminal. emi-stack verified writable (fetch OK, tree clean,
  origin/main = 562cc99).

### Status after ratification
- Engine artifacts: still **PROPOSED / no activation** — Promotion Gate (CLAUDE.md §11) remains a separate
  operator-gated change-set; ratification of D1/D2 changes SEQUENCING, not activation.
- All barriers unchanged (LedgerPort-only, W-05 guard, runtime_gate foreign track, MEMORY.md, OP-N1,
  legacy banxe-dev doc superseded/double-source flag).

## Anchors

ADR-013, ADR-030, ADR-102, ADR-103, ADR-060, ADR-119/120/121, ADR-167 (assistant-ui intent-first),
ADR-168 (Langfuse), ADR-169 (LIME/SHAP), CLAUDE.md §10/§11, SANCTIONS-POLICY.md,
`docs/engine/BANXE-ENGINE-MATH.md`, `docs/engine/BANXE-SECURITY-OWASP.md`, `roadmap/BANXE-E0-E6.md`.

## STEP 4 — SANDBOX ACTIVATION (operator Promotion Gate §11 = SANDBOX, 2026-07-26)

- Entire engine-reference set flipped PROPOSED → **ACTIVE in SANDBOX** on TRAINING data
  (BANXE_ENV=sandbox, BANXE_DATA_CLASS=TRAINING, **BANXE_PROD_READY=false** — unchanged).
- Activated (sandbox only): confidence gates (active_environment=sandbox), agentic CI pipeline
  (`.github/workflows/banxe-agent-review.yml`, triggers restricted to sandbox branch patterns; source
  in `docs/engine/proposed-workflows/` marked superseded), monitoring passports (engine-health,
  fleet-liveness, agent-liveness → sandbox-active), TransferAgent, state-changing Rich Cards
  (**W-05 lifted in SANDBOX only; prod stays gated**), messenger channels (test bots only),
  crypto channel (testnet only) — manifest: `config/sandbox/sandbox-activation.yaml`.
- SQL-ALTER (`sql/alter-banxe-audit-hitl-decisions-engine-ref-2026-07-26.sql`): operator runs MANUALLY
  on **SANDBOX ClickHouse only** — never on live/prod cluster.

### PROD-CUTOVER CONTRACT (binding, per sandbox amendment S5)
1. Before ANY prod activation: **PURGE all TRAINING data**; re-seed real data under a separate
   operator-gated change-set.
2. `BANXE_PROD_READY` flips true ONLY via an explicit **PROD Promotion Gate** (separate authorization —
   NOT granted by this sandbox pass).
3. Any artifact/row with `data_class=TRAINING` is **BLOCKED from prod**.
4. Standing barriers survive sandbox: ledger via LedgerPort only (ADR-013), config/runtime_gate/ foreign
   (§72), AutoGen excluded / AG2 verify (OP-N1), MEMORY.md untouched.

## STEP 6 — Canonical DDL TTL fix (2026-07-26) — STEP5 OPEN POINT RESOLVED

- **RESOLVED:** `sql/create-banxe-audit-hitl-decisions-2026-05-12.sql` TTL expression fixed:
  `TTL ts + …` → `TTL toDateTime(ts) + INTERVAL 7 YEAR DELETE` (CH ≥24.x rejects DateTime64 directly in
  TTL, BAD_TTL_EXPRESSION). Nothing else changed: `ts` stays DateTime64(3,'UTC'); engine/partition/order
  intact; 7Y retention unchanged. ALTER header comment synced (comment only).
- **Proof:** fixed CREATE applied to a CLEAN temp DB (`banxe_audit_ttltest`) on the sandbox instance —
  passed without BAD_TTL_EXPRESSION; 14 columns; `TTL toDateTime(ts) + toIntervalYear(7)` confirmed via
  system.tables; temp DB dropped; working sandbox `banxe_audit` untouched (22 columns intact).
- Canonical DDL is now **CH-24.x-compatible / prod-safe**. PROD-CUTOVER CONTRACT above remains fully in
  force (purge TRAINING; separate PROD Promotion Gate; PROD_READY=false).
