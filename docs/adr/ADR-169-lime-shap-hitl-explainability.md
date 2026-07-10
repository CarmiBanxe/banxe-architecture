# ADR-169: LIME/SHAP Decision-Rationale Explainability (XAI) paired with HITL

## Status
Proposed

> ADOPT #66 (`lime-shap-hitl-explainability`) from `governance/ADOPTION-FINALIZATION-SP41.md` §1
> (ADOPT, S=0.6275) — SP41 roadmap §4 **cluster-3** (UI / observability / XAI), **3rd / final item**.
> Scope: **decision-rationale XAI (LIME / SHAP) paired with HITL**, on the ADR-046 decision-lineage
> substrate. Handoff: GAP-DECISION-LINEAGE-XAI. **Design / governance decision record only** — no code,
> no model wiring, no installs (ADR-102 pointer-first, no restate). **This ADR completes the ADOPT
> roadmap (9/9).**

## Context
Decision lineage already records **WHAT** was decided and **WHO/WHEN** a human gates it — but not
**WHY** a model produced its output. Each existing layer is cross-referenced pointer-first, not restated:

- **`docs/adr/ADR-046-decision-lineage-schema.md`** — the `AgentDecisionRecord` schema (**WHAT** is recorded).
- **`docs/adr/ADR-128-banking-agents-hitl-matrix.md` + `HITL-MATRIX.yaml`** — **WHO / WHEN** a human gates a decision.
- **`governance/decision-lineage/README.md`, `docs/runbooks/hitl-decision-recording.md`,
  `docs/policies/hitl-l3-agent-gate-2026-05-11.md`** — the HITL recording / gating machinery.

The missing piece is **WHY** — human-readable **feature-attribution** for a model decision. Without it,
an MLRO/HITL reviewer sees the decision and the gate but not the model's reasoning — a gap now sharpened
by the cluster-2 fraud models (`ADR-FRAUD-03/04/05`), whose outputs feed regulated fraud decisions.

## Decision
Adopt **LIME + SHAP** as the **feature-attribution explainability (XAI) layer**:

1. **Rationale on the lineage record.** LIME/SHAP produce a human-readable **feature-attribution
   rationale** (which inputs drove the decision, and how much) attached to the **`AgentDecisionRecord`**
   (ADR-046) — the *WHY* alongside the existing *WHAT*.
2. **Surfaced to the HITL reviewer.** The rationale is rendered on the **HITL review surface** governed
   by `ADR-128` / `HITL-MATRIX.yaml` — giving the human gate the model's reasoning at decision time.
3. **Primary target: fraud models** (`ADR-FRAUD-03` LightGBM, `ADR-FRAUD-04` HGNN, `ADR-FRAUD-05`
   tx-embedding) — GBM/tree attributions are SHAP-native; graph/sequence models use their attribution
   analogues. **Secondary: LLM outputs** (rationale for LLM-backed decisions).
4. **Framework-agnostic at this ADR level.** Concrete LIME/SHAP wiring (per-model explainers, the
   rationale field, the review-surface rendering) is deferred to a **follow-up integration ADR**.

**Scope fixed now:**
- **What is explained:** model inputs → feature attribution (per decision).
- **Where it attaches:** an `AgentDecisionRecord` rationale field (ADR-046) + the HITL review surface (ADR-128).
- **Boundary:** **advisory-only** — the explanation informs the human; it never decides.

## Non-Goals
- **No code, no model integration, no installs** in this sprint.
- **Does not replace** the HITL matrix (ADR-128) or the lineage schema (ADR-046) — it **adds the WHY** onto them.
- **No framework/library commitment** beyond naming LIME + SHAP as the adopted approach — wiring is a follow-up.
- **No activation** — PROPOSED; operator/SMF ratify.

## Duplication Audit (ADR-102)
| Existing artefact | What it already provides | Relation to #66 |
|---|---|---|
| `docs/adr/ADR-046-decision-lineage-schema.md` | `AgentDecisionRecord` schema (WHAT) | #66 **adds a rationale field** onto this record. KEEP |
| `docs/adr/ADR-128-...hitl-matrix.md` + `HITL-MATRIX.yaml` | WHO/WHEN a human gates (matrix) | #66 **surfaces the rationale** to that gate. KEEP |
| `governance/decision-lineage/README.md`, `docs/runbooks/hitl-decision-recording.md`, `docs/policies/hitl-l3-agent-gate-2026-05-11.md` | HITL recording/gating machinery | #66 feeds it the WHY; machinery unchanged. KEEP |
| `adrs/ADR-FRAUD-03/04/05` | Fraud models (the decisions to explain) | Primary explainability targets. KEEP |

**Conclusion:**
- **What already exists:** the lineage schema (WHAT), the HITL matrix + machinery (WHO/WHEN), and the
  fraud models whose decisions need explaining.
- **What would be duplicated if coded now:** standing up explainers without the decision would re-encode
  the lineage record / HITL surface those layers already own.
- **What is genuinely missing:** the adopted decision to produce **feature-attribution rationale (WHY)**
  and attach it to the lineage record + HITL surface. This ADR supplies exactly that; it duplicates
  nothing (ADD the ADR; KEEP every referenced layer).
- **Why documentation/governance only:** the missing piece is the *decision + attachment points*, not
  code — LIME/SHAP wiring is a separately-audited follow-up.

## Governance / perimeter constraints
- **Advisory-only (I-27).** Explanations are **advisory input to HITL** — never an autonomous decision,
  and never an override of a human gate. The human decides; the rationale informs.
- **PII / DP.** Model inputs feeding the explainers may contain PII → DP / redaction applies before any
  real explanation is generated or stored (nothing is captured this sprint).
- **No credit / lending** — explainability targets **fraud-use only** (SP41 §2; consistent with
  `ADR-FRAUD-03` fraud-only scope). No credit-scoring explanation.
- **Perimeter (ADR-117)** — runs within a single perimeter; no cross-perimeter rationale store.
- **No authority (ADR-127 / ADR-130)** — a rationale observes/explains; it confers no permission.

## Follow-ups (separate, gated sprints — not this PR)
- **Integration ADR** — per-model LIME/SHAP explainers, the `AgentDecisionRecord` rationale field
  (ADR-046 amendment), HITL review-surface rendering (ADR-128), and the PII/DP pipeline for explainer inputs.

> **ADOPT roadmap status: 9/9 COMPLETE.** With #66, all nine SP41 §1 ADOPT items are landed as PROPOSED
> design records — cluster-1 LLM-safety (#64/#65/#104), cluster-2 fraud engine (#111/#49/#46),
> cluster-3 UI/observability/XAI (#56/#68/#66). Implementation of each remains its own gated sprint.

## References
- `governance/ADOPTION-FINALIZATION-SP41.md` §1 (ADOPT #66), §4 (cluster-3 / roadmap 9/9), §2 (fraud-only / no credit).
- `docs/adr/ADR-046-decision-lineage-schema.md` — decision-lineage schema (KEEP; rationale attaches here).
- `docs/adr/ADR-128-banking-agents-hitl-matrix.md` + `HITL-MATRIX.yaml` — HITL matrix (KEEP; rationale surfaced here).
- `governance/decision-lineage/README.md`, `docs/runbooks/hitl-decision-recording.md`, `docs/policies/hitl-l3-agent-gate-2026-05-11.md` — HITL machinery (KEEP).
- `adrs/ADR-FRAUD-03-lightgbm-gbm-baseline.md`, `adrs/ADR-FRAUD-04-heterogeneous-gnn.md`, `adrs/ADR-FRAUD-05-tx-embedding-transformer.md` — primary explainability targets (KEEP).
- ADR-102 (additive / pointer-first), ADR-117 (perimeter), ADR-127 / ADR-130 (no authority), I-27 (HITL), I-24 (audit append-only).
