# Master Roadmap — single entry point (consolidation index)

> **Status:** governance consolidation index. **Date:** 2026-06-30. **Line 5 of 7.**
> **This is NOT a new parallel roadmap.** Per **ADR-102** it is a deliberate **consolidation**: it provides one
> entry point to the EMI BANXE product phases and then **points to** every existing roadmap fragment, classifying
> each as **AGGREGATED** (a live source this index indexes) or **SUPERSEDED** (replaced/historical, **retained,
> not deleted**). It **copies no fragment's content** and **deletes no file** — so that it does not become the
> twenty-sixth parallel roadmap. Owner-terminal assignments use `docs/governance/TERMINAL-OWNERSHIP.md` (line 1).

## 1. Product phase view (single entry point)
Phases of EMI BANXE AI BANK, each with its **owner-terminal**, key **dependency**, and **gate**. Detail lives in
the **source** column (pointer, not copied); values not determinable without invention are **[НЕИЗВЕСТНО]**.

| Phase / block | Owner-terminal | Key dependency | Gate | Authoritative source (pointer) |
|---|---|---|---|---|
| **Safeguarding Engine (CASS 15, S-PROD-1)** | project delivery via **A** *(factory builds; runtime in `banxe-emi-stack`)* | Midaz ledger | **CASS 15 / FCA PS10-15**; daily-recon + shortfall auto-FCA (immutable) | `docs/ROADMAP-STATUS-2026-06-23.md` §3 |
| **Payment Rails (S-PROD-5)** | project delivery | ClearBank / Modulr (S4) | ≥£50k → L2 COO/CFO (**HITL-016**) | `docs/ROADMAP-STATUS-2026-06-23.md` §3 |
| **Agent Engine** | **A** (factory; `docs/agent-engine-dossier/` zone) | engine-roadmap inputs | **[НЕИЗВЕСТНО]** | `docs/agent-engine-dossier/ENGINE-ROADMAP.md` (+ `ENGINE-ROADMAP-INPUTS.md`, `SPRINT-PLAN.md`) |
| **Trading block** | **B** (right; trading/recon zone) | **[НЕИЗВЕСТНО]** | **[НЕИЗВЕСТНО]** | `docs/roadmap/TRADING-BLOCK-ROADMAP-AND-SPRINTS-2026-06-28.md` |
| **Legacy refactor (right-track 8Q)** | **B** (right) | legacy sources (`banxe-emi-stack`) | server-only refactor + Duplication Audit (**ADR-103 / ADR-102**) | `docs/project/right-track/ROADMAP_8Q-2026-05-22.md`; `docs/project/DELTA-ANALYSIS-LEGACY-REFACTOR-vs-CURRENT-ROADMAP.md` |
| **Factory build-out** | **A** (factory) | — | guardian gates + quality-gate | `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` |
| **Neuronext → Paybis migration** | project delivery | Paybis (sole crypto provider, ADR-138) | operator HITL | `docs/paybis-dossier/PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md` |
| **Governance / target-model conformance** | **Central** | — | operator HITL (**ADR-135**) | `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-25.md`; `docs/ROADMAP-STATUS-2026-06-23.md` §1–2 |

> Completion percentages per block are **not restated** here — they live in `docs/ROADMAP-MATRIX.md` (pointer).
> The **forward sprint plan to 100%** lives in `docs/ROADMAP-STATUS-2026-06-23.md` §3 (pointer).

## 2. Source-fragment registry (classification — pointer only, nothing copied or deleted)

### 2.1 AGGREGATED — live sources this index points to (retained)
| Fragment | Role |
|---|---|
| `ROADMAP.md` | top-level roadmap |
| `docs/ROADMAP-MATRIX.md` | per-block completion-% matrix |
| `docs/ROADMAP-STATUS-2026-06-23.md` | current status + forward sprint plan to 100% (primary status source) |
| `docs/agent-engine-dossier/ENGINE-ROADMAP.md`, `ENGINE-ROADMAP-INPUTS.md`, `SPRINT-PLAN.md` | Agent-Engine roadmap (owner A) |
| `docs/agent-engine-dossier/SRC-03-implementation-state.md` | engine implementation-state |
| `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` | factory build-out (owner A) |
| `docs/roadmap/TRADING-BLOCK-ROADMAP-AND-SPRINTS-2026-06-28.md` | trading block (owner B) |
| `docs/project/right-track/ROADMAP_8Q-2026-05-22.md`, `docs/project/DELTA-ANALYSIS-LEGACY-REFACTOR-vs-CURRENT-ROADMAP.md` | legacy refactor / right-track (owner B) |
| `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-25.md` | target-model conformance (latest) |
| `docs/architecture/EMI-IMPL-STATE-REFRESH-2026-06-26.md` | EMI implementation-state (latest) |
| `docs/paybis-dossier/PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md` | Neuronext→Paybis migration |
| `docs/roadmap/FACTORY-AUDIT-INDEX-2026-07-20.md` | audit-plane discoverability hook (S-FAC-R3) — indexes `docs/audit/*` factory artefacts this index does not itself cover |

### 2.2 SUPERSEDED / historical — retained, NOT deleted (superseding a file is a separate operator-gated action)
| Fragment | Superseded by / role |
|---|---|
| `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-24.md` | superseded by the 2026-06-25 conformance doc |
| `docs/migration/EMI-IMPLEMENTATION-STATE-2026-06-25.md` | superseded by `EMI-IMPL-STATE-REFRESH-2026-06-26.md` |
| `docs/adr/ADR-044-ai-pool-roadmap-2026-05-11.md` | historical AI-pool roadmap — remains an ADR (not re-classified) |
| `docs/roadmap/intent-first-migration-roadmap-2026-06-08.md` | historical migration roadmap |
| `docs/roadmap/audit-2026-05-factory-vs-project.md`, `audit-2026-05/A3-gap-analysis.md`, `audit-2026-05/A4-agents-orchestration-proposal.md` | historical 2026-05 roadmap audits |
| `docs/roadmap/sprint-factory-developer-audit-2026-05.md`, `sprint-project-cluster-audit-2026-05.md` | historical sprint audits |
| `docs/sessions/HANDOFF-2026-05-07-fixes-roadmap.md`, `HANDOFF-2026-05-09-incident-monitor-roadmap-unfreeze.md`, `SESSION-2026-05-10-UNIFIED-CANON-ROADMAP.md` | historical session handoffs |

## 3. [НЕИЗВЕСТНО] / operator decisions
- The **aggregated-vs-superseded** call for any borderline fragment is the operator's to confirm; the
  classifications above are proposed, not asserted as final.
- **No fragment is deleted by this PR.** If the operator wishes to physically retire a SUPERSEDED file, that is
  a separate deletion — operator-owned per `docs/governance/CTIO-CARRY-FORWARD.md` (line 3).
- Phase **owner / gate** values marked **[НЕИЗВЕСТНО]** above await determination from the source fragments or
  operator decision; they are not invented here.

## 4. Factory-canon repair notes (S-FAC-R3, 2026-07-20 — additive, does not reclassify §1–§3)

> Path note: `S-FAC-R3`'s repair scope named this file as `docs/roadmap/MASTER-ROADMAP.md`; no
> such file exists. This is the actual consolidation index (`docs/governance/MASTER-ROADMAP.md`),
> identified as the intended target by `FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md`
> and edited here instead of creating a duplicate roadmap-plane file at the stated path.

### 4.1 Sprint-namespace note
"Sprint N" / "S-A-N" prefixes are **ambiguous without qualification** — at least five
non-communicating sprint-ID namespaces exist across this repo (Sprint 1/3/7/8 Software-
Factory-Canon lineage; S1–S6 governance-artifact lineage; S-FAC-60–69 factory build-out;
S-FAC-R1/R2/R3 factory-canon repair line; S-A0–S-A13 BANK launch-readiness). Canonical
explanation and full table: `docs/roadmap/FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md`
§"Sprint namespace model". This index does not rename or reassign any existing sprint ID.

### 4.2 Dependency/override note — Sprint 3 → Sprint 7/8
Neither this index nor `docs/roadmap/BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md`
previously described the relationship between `docs/audit/sprint3-routing-canon-enforcement-2026-05-14.md`
(status OPEN; exit criteria — Guardian rules F9/F10 — unmet) and
`docs/audit/sprint{7,8}-*-2026-05-14.md` (both declared DONE despite listing Sprint 3 as a
hard dependency). Per the dependency/override model in
`docs/roadmap/FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md`, both should be read as
**DONE-WITH-OVERRIDE (skips: Sprint 3 F9/F10)**, not clean DONE. Recorded here, once, as the
consolidation index's note of record; the two sprint documents themselves are not edited.

## Anchors
ADR-102 (Duplication Audit — consolidation discipline) · `docs/governance/TERMINAL-OWNERSHIP.md` (owner-terminals) ·
`docs/governance/CTIO-CARRY-FORWARD.md` (deletion is operator-owned) · ADR-103 (server-only refactor) · ADR-138
(Paybis) · ADR-135 (HITL) · the 25 roadmap fragments registered in §2. Operator directive 2026-06-30 (line 5 of 7).
· §4 added 2026-07-20 (S-FAC-R3), pointing to `FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md` and
`FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md`.


---
> **SUPERSEDED (2026-07-23):** consolidated into the single **GENERAL-LINE** roadmap → `../roadmap/GENERAL-LINE-ROADMAP-2026-07-23.md` (see its §4 mapping / §5 register). This file is retained for history; the GENERAL-LINE is the source of truth. IL-ledger unaffected.
