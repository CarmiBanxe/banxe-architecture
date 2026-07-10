# ADR-FRAUD-03: LightGBM Gradient-Boosting Baseline — FRAUD-USE ONLY

## Status
Proposed

> ADOPT #111 (`lightgbm-fraud-credit-gbm`) from `governance/ADOPTION-FINALIZATION-SP41.md` §1.1 (ADOPT,
> S=0.695) — **fraud-use only**. SP41 roadmap §4 cluster-2 (fraud engine), **first item** (the GBM
> baseline that precedes the deep GNN work #49/#46). Handoff **GAP-FRAUD-ENGINE**. This is a
> **decision record only** — no model code, no training pipeline, no import (ADR-102 pointer-first).

## Context

BANXE's fraud stack today is rule/heuristic-led: `ADR-FRAUD-01` (device fingerprinting) and
`ADR-FRAUD-02` (ATO velocity/session anomaly). The T1 statistical fraud classifier
(`docs/governance/model-cards/fraud-classifier-evo2.md`) is a **DRAFT gap-tracking card — model TBD,
AWAITS OPERATOR**; no distinct fraud ML model is yet named or measured. SP41 cluster-2 will introduce
deep models (**#49** heterogeneous GNN, **#46** tx-embedding discriminator), but those are high-AC and
harder to explain to a regulator.

A **gradient-boosting (GBM) baseline** is the standard, low-risk first step before deep learning: it is
**interpretable** (feature importance / SHAP-friendly, cf. #66 XAI), **low-latency** at inference, and
**strong on tabular transaction features** — the right production baseline to establish measurable
fraud-detection performance and a comparison floor for the later GNN work.

**SP41 §2 scope boundary (HARD).** The upstream register named this finding "fraud/credit GBM". Per
operator ruling (SP41 §2), **credit / lending is REJECTED-OUT-OF-SCOPE permanently** for BANXE's EMI
remit — **not** licence-gated. Therefore this ADR adopts LightGBM **strictly as an EMI-scope fraud
discriminator**. There is **no** `B-EMI-CREDIT-GATE-001` holding here and **no** credit-scoring use is
proposed, now or later.

## Decision

Adopt **Microsoft LightGBM** as the **fraud GBM baseline** — **FRAUD-USE ONLY**.

1. **Role — fraud discriminator baseline.** A tabular gradient-boosting classifier over transaction /
   account / device features, producing a **fraud risk score** that feeds the existing fraud-decision
   path alongside `ADR-FRAUD-01`/`-02`. It is a **baseline / comparison floor**, explicitly **before**
   and **complementary to** the deep GNN (#49) and tx-embedding (#46) work — not a replacement for
   either, and not for the T1 classifier role in the evo2 model-card.
2. **FRAUD-ONLY — credit REJECTED-OOS.** LightGBM is adopted **only** for fraud detection. **No
   credit-scoring, lending, or affordability use** is authorised or proposed (SP41 §2 permanent scope
   exclusion). Any future credit use would be a **separate, currently-rejected** matter — not reachable
   from this ADR.
3. **XGBoost (#112) — evaluated sibling, not a second adoption.** `#112 xgboost-fraud-credit-gbm` is the
   **dedup sibling** of #111 (same GBM capability-need; SP41 DUP `112→111`). LightGBM is chosen
   **keep-best** (native categorical handling, lower memory/latency, faster training); XGBoost remains a
   documented **alternative**, and swapping the backing library is an implementation choice inside this
   same baseline role — **not** a new ADOPT.
4. **Explainability & governance.** As a T1-adjacent fraud input, the model's output MUST feed **HITL**
   (no autonomous regulated fraud action — I-27), carry **feature-attribution** for MLRO rationale
   (aligns with #66 LIME/SHAP XAI, ADR-046 decision-lineage), and register under **MRM** tiering when a
   trained model exists (`docs/governance/MODEL-RISK-MANAGEMENT.md`; complements the evo2 model-card).
5. **Config-over-hardcoding.** All hyperparameters (num_leaves, learning_rate, max_depth, class weights,
   decision threshold) and the fraud-score cutoff are **governed-config proposals** (CLAUDE.md §10) —
   they live in versioned model config when the model is built, **not** in code and **not** in this ADR.

## Consequences

**Positive**
- Establishes an **interpretable, low-latency production baseline** and a measurable comparison floor
  before the higher-AC deep GNN cluster-2 work (#49/#46).
- Strong tabular performance with regulator-friendly explainability (feature importance / SHAP).
- Scope is unambiguous: **fraud only**, credit permanently out-of-scope (SP41 §2).

**Negative / constraints**
- **No model code in this PR.** Training pipeline, feature spec, the trained-model **model-card**
  (MRM registration), and any serving wiring are **follow-up** work under GAP-FRAUD-ENGINE.
- A baseline is a floor, not the target — the deep GNN (#49) and tx-embedding (#46) remain the
  cluster-2 endpoints; this ADR does not pre-empt their design.
- Credit/lending remains rejected — this ADR must not be cited to justify any credit-scoring use.

## Alternatives Considered
- **XGBoost (#112)** — REJECTED as a *separate* adoption; kept as the evaluated sibling/alternative
  inside the same GBM-baseline role (LightGBM chosen keep-best).
- **Skip the baseline, go straight to deep GNN (#49/#46)** — REJECTED: loses the interpretable floor and
  the low-latency comparison point; higher AC and weaker regulator explainability up front.

## References
- `governance/ADOPTION-FINALIZATION-SP41.md` §1.1 (ADOPT #111, fraud-use only), §2 (credit REJECTED-OOS), §4 (cluster-2 roadmap).
- `adrs/ADR-FRAUD-01-device-fingerprinting.md`, `adrs/ADR-FRAUD-02-ato-prevention.md` — existing fraud stack (KEEP; referenced, not rewritten).
- `docs/governance/model-cards/fraud-classifier-evo2.md` — T1 fraud-classifier role (DRAFT, AWAITS OPERATOR) this baseline complements.
- Cluster-2 endpoints: **#49** hgnn-heterogeneous-gnn-fraud, **#46** nuformer-tx-embedding-model (later ADOPT sprints). Sibling: **#112** xgboost (DUP-of-#111).
- ADR-102 (additive / pointer-first), ADR-046 (decision-lineage XAI), #66 LIME/SHAP, `docs/governance/MODEL-RISK-MANAGEMENT.md` (MRM), I-01/I-02/I-24/I-27.
