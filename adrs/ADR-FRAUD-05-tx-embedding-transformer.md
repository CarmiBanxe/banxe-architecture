# ADR-FRAUD-05: Transaction-Embedding Transformer — Sequence Fraud Discriminator

## Status
Proposed

> ADOPT #46 (`nuformer-tx-embedding-model`) from `governance/ADOPTION-FINALIZATION-SP41.md` §1.1
> (ADOPT, S=0.625) — SP41 roadmap §4 cluster-2 (fraud engine), **LAST item**: the sequence/temporal
> model that completes the fraud engine alongside the GBM baseline (`ADR-FRAUD-03`, #111) and the
> heterogeneous GNN (`ADR-FRAUD-04`, #49). Handoff **GAP-FRAUD-ENGINE**. **Decision record only** — no
> model code, no pretraining pipeline, no import (ADR-102 pointer-first).

## Context

The fraud engine now has a **tabular** layer (`ADR-FRAUD-03` LightGBM — per-transaction, interpretable,
low-latency) and a **relational** layer (`ADR-FRAUD-04` heterogeneous GNN — cross-entity graph
patterns). Neither captures the **sequential / temporal** dimension well: the *order and rhythm* of a
merchant/account's transaction history (bursts, dormancy-then-spike, sequence anomalies) carries fraud
signal that a per-row model and a static graph snapshot both under-use.

A **transformer pre-trained on merchant transaction sequences** learns dense **transaction embeddings**
that encode this temporal/behavioural structure — the same self-supervised-pretraining idea that powers
language models, applied to tx sequences. The embedding is both a **standalone discriminator** and a
**rich feature** the other two layers can consume.

## Decision

Adopt a **transaction-embedding transformer** as the **third ML layer** of the fraud engine —
**fraud-use only**.

1. **Model & output.** A transformer pre-trained (self-supervised) on merchant/account transaction
   sequences, emitting **tx embeddings** that encode temporal/behavioural patterns. Used (a) as a
   **sequence fraud discriminator** producing a risk score, and (b) as **embedding features** fed into
   the GBM (`ADR-FRAUD-03`) and/or HGNN (`ADR-FRAUD-04`) — an ensemble view rather than a competitor.
2. **Position — the sequence layer.** It complements, does not replace: GBM = tabular floor; HGNN =
   relational graph; tx-embedding = temporal/sequence. Each sees a dimension the others cannot.
3. **Accuracy / adoption-cost trade-off (explicit).** Highest-AC of the three — **pretraining cost**
   (compute + a curated tx-sequence corpus), embedding-serving infra, and lower intrinsic
   explainability than the GBM. Adopted because the temporal signal is additive to the other two
   layers; the GBM floor keeps the engine resilient if the transformer is unavailable.
4. **Explainability & governance.** As a T1-adjacent fraud input, the score/embedding MUST feed
   **HITL** (no autonomous regulated fraud action — I-27), carry attribution rationale for MLRO
   (attention/attribution over the sequence; pairs with #66 LIME/SHAP XAI, `ADR-046` decision-lineage),
   and register under **MRM** tiering when a trained model exists
   (`docs/governance/MODEL-RISK-MANAGEMENT.md`; complements the evo2 fraud-classifier model-card).
5. **Config-over-hardcoding.** The **embedding dimension**, sequence window, pretraining objective,
   model hyperparameters, and the discriminator threshold are **governed-config proposals**
   (CLAUDE.md §10) — held in versioned config when built, not in code and not in this ADR.

## Ensemble / layering — the completed fraud engine (defense-in-depth)

The three ML layers **compose** into one fraud engine — **baseline → graph → sequence** — exactly as
the LLM-safety perimeter (cluster-1: #64 mapping → #65 rails → #104 validators) layered distinct
controls rather than choosing one:

| Layer | ADR | Dimension seen | Role |
|-------|-----|----------------|------|
| **Tabular GBM** (LightGBM, #111) | `ADR-FRAUD-03` | per-transaction features | interpretable **floor + fallback**; fast/explainable score |
| **Heterogeneous GNN** (#49) | `ADR-FRAUD-04` | cross-entity **relationships** | graph-context escalation (mule rings, shared-device, collusion) |
| **Tx-embedding transformer** (nuformer, #46) | `ADR-FRAUD-05` (this) | **temporal/sequence** behaviour | sequence discriminator **+ embedding features** for the other two |

- **Not competing — composing.** The embedding is also an **input feature** to GBM/HGNN, so the layers
  reinforce each other (ensemble), not merely vote in parallel.
- **Graceful degradation.** If the HGNN or transformer is unavailable, the interpretable GBM floor
  still scores every transaction — the engine never hard-depends on the highest-AC layer.
- **Uniform governance.** All three feed **HITL** (I-27), carry **MLRO attribution rationale** (#66,
  `ADR-046`), and register under **MRM** — one governance envelope over three models.

This completes the cluster-2 fraud engine: no single model is authoritative; defense-in-depth across
tabular, relational, and temporal views.

## Consequences

**Positive**
- Adds the **temporal/sequence** fraud dimension the tabular and graph layers under-use.
- Completes a **defense-in-depth** fraud engine (baseline → graph → sequence); embeddings enrich the
  other two layers (ensemble), with the GBM floor as fallback.

**Negative / constraints**
- **Highest adoption-cost:** self-supervised pretraining (compute + tx-sequence corpus),
  embedding-serving infra, weaker intrinsic explainability (mitigated by attribution rationale + HITL).
- **No model code in this PR.** Pretraining, embedding-serving, the feature pipeline into GBM/HGNN, and
  the trained-model **model-card** (MRM registration) are **follow-up** under GAP-FRAUD-ENGINE.

## Alternatives Considered
- **GBM + HGNN only (skip the sequence layer)** — REJECTED: leaves the temporal/behavioural dimension
  under-modelled; the transformer is the deliberate sequence layer.
- **Replace GBM/HGNN with the transformer** — REJECTED: the layers see different dimensions and
  compose; replacing loses the interpretable floor and the relational view (defense-in-depth intent).
- **Fold tx-embedding into the HGNN as node features only** — PARTIALLY DEFERRED: embeddings *are* fed
  as features (point 1b), but the transformer also stands as an independent sequence discriminator;
  collapsing it entirely into the GNN would lose the standalone temporal score.

## References
- `governance/ADOPTION-FINALIZATION-SP41.md` §1.1 (ADOPT #46), §4 (cluster-2 roadmap — last item).
- `adrs/ADR-FRAUD-03-lightgbm-gbm-baseline.md` (#111, GBM floor), `adrs/ADR-FRAUD-04-heterogeneous-gnn.md` (#49, HGNN) — the two layers this completes (KEEP).
- `adrs/ADR-FRAUD-01-device-fingerprinting.md`, `adrs/ADR-FRAUD-02-ato-prevention.md` — existing fraud stack (KEEP).
- `docs/adr/ADR-111-crypto-aml-graph-analytics.md` — distinct crypto-AML graph layer (KEEP; cross-ref only).
- `docs/governance/model-cards/fraud-classifier-evo2.md` — T1 fraud-classifier role (DRAFT, AWAITS OPERATOR) this model complements.
- ADR-102 (additive / pointer-first), ADR-046 (decision-lineage XAI), #66 LIME/SHAP, `docs/governance/MODEL-RISK-MANAGEMENT.md` (MRM), I-24/I-27.
