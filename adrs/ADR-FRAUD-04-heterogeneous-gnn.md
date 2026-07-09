# ADR-FRAUD-04: Heterogeneous GNN over the Multi-Entity Transaction Graph — Fraud Detection

## Status
Proposed

> ADOPT #49 (`hgnn-heterogeneous-gnn-fraud`) from `governance/ADOPTION-FINALIZATION-SP41.md` §1.1
> (ADOPT, S=0.60) — SP41 roadmap §4 cluster-2 (fraud engine), **item 2**: the deep graph model that
> sits **above** the LightGBM baseline (`ADR-FRAUD-03`, #111). Handoff **GAP-FRAUD-ENGINE**. This is a
> **decision record only** — no model code, no graph pipeline, no import (ADR-102 pointer-first).

## Context

The fraud stack is rule/heuristic-led (`ADR-FRAUD-01` device fingerprinting, `ADR-FRAUD-02` ATO
velocity/session anomaly) with a **tabular GBM baseline** now proposed (`ADR-FRAUD-03` LightGBM, #111).
Tabular models score a transaction largely **in isolation** — they miss **cross-entity** fraud that
only appears in the *relationships* between accounts, devices, merchants, and counterparties (mule
rings, shared-device fraud, collusion, layering across accounts).

A **heterogeneous graph neural network (HGNN)** models exactly those relationships: a graph with
**typed nodes** (account / device / merchant / counterparty) and **typed edges** (transacts-with /
shares-device / same-beneficiary) lets message-passing surface fraud patterns that are invisible to a
per-row classifier. Heterogeneity matters — a homogeneous GNN collapses these distinct node/edge types
and loses the cross-type signal the register specifically calls out.

**Boundary vs the existing crypto-AML graph ADR (`docs/adr/ADR-111`).** `ADR-111`
(Crypto-AML Graph-Analytics — Collective Crystal) already applies graph ML (**GraphSAGE on Elliptic++**,
peel-chain Random Forest) to **crypto/blockchain-address** graphs for **money-laundering** detection
(GAP-021/022/025; MiCA VASP, FATF Travel Rule). **This ADR is a distinct domain:** the **fiat
payments/account** fraud graph (accounts/devices/merchants/counterparties) for **fraud** (not
laundering), under GAP-FRAUD-ENGINE. Different graph, different data, different regulatory frame, and a
**heterogeneous multi-entity** GNN rather than ADR-111's homogeneous GraphSAGE+RF. They are
**complementary graph-ML applications**, not duplicates — `ADR-111` is KEEP and cross-referenced, not
rebuilt or extended here.

## Decision

Adopt a **heterogeneous GNN** over the **multi-entity fiat transaction graph** as the higher-accuracy
fraud model **atop** the LightGBM baseline.

1. **Model & graph.** Typed-node / typed-edge graph (accounts, devices, merchants, counterparties;
   transacts / shares-device / same-beneficiary edges). Message-passing HGNN produces a fraud risk
   score capturing **cross-entity** patterns the tabular baseline cannot.
2. **Layering (baseline → deep).** `ADR-FRAUD-03` LightGBM stays the **interpretable, low-latency
   floor** and comparison point; the HGNN is the **higher-accuracy** layer for complex cross-entity
   cases. They **compose** — GBM for fast/explainable per-transaction scoring, HGNN for graph-context
   escalation — not replace. The GBM baseline remains the fallback if the HGNN is unavailable.
3. **Accuracy / adoption-cost trade-off (explicit).** The HGNN is **higher-AC**: graph construction +
   maintenance, GPU training/serving, and **lower intrinsic explainability** than the GBM. It is
   adopted *because* the cross-entity accuracy gain justifies the cost — but the GBM floor exists
   precisely so the deep model is an escalation, not a single point of dependence.
4. **#50 (fraudgnn-rl-adaptive) — evaluated follow-on, NOT a second adopt.**
   `#50 fraudgnn-rl-adaptive` (GNN + RL for online-adaptive fraud thresholds) is the **dedup sibling**
   of #49 (SP41 DUP `50→49`; same fraud-GNN capability-need). It is recorded here as a **deferred
   follow-on extension** — an RL adaptivity layer over *this* HGNN once it exists — and is **not** a
   separate ADOPT. Adding RL-adaptive thresholds later is a follow-up decision, not reachable from this
   ADR.
5. **Explainability & governance.** As a T1-adjacent fraud input, the HGNN score MUST feed **HITL**
   (no autonomous regulated fraud action — I-27), carry **graph-attribution** rationale for MLRO
   (attention / subgraph explanation; pairs with #66 LIME/SHAP XAI, `ADR-046` decision-lineage), and
   register under **MRM** tiering when a trained model exists
   (`docs/governance/MODEL-RISK-MANAGEMENT.md`; complements the evo2 fraud-classifier model-card).
6. **Config-over-hardcoding.** The **graph schema** (node/edge types, feature sets), model
   hyperparameters (layers, hidden dims, sampling fanout), and the decision threshold are
   **governed-config proposals** (CLAUDE.md §10) — held in versioned config when built, not in code and
   not in this ADR.

## Consequences

**Positive**
- Detects **cross-entity** fraud (mule rings, shared-device, collusion) invisible to tabular models.
- Layered defence: interpretable GBM floor + higher-accuracy HGNN escalation, with GBM as fallback.
- Clean domain boundary with the crypto-AML graph layer (`ADR-111`) — no capability overlap.

**Negative / constraints**
- **Higher adoption-cost:** graph build/maintenance, GPU train/serve, and weaker intrinsic
  explainability than the GBM (mitigated by graph-attribution rationale + HITL).
- **No model code in this PR.** Graph construction, feature spec, model training/serving, and the
  trained-model **model-card** (MRM registration) are **follow-up** under GAP-FRAUD-ENGINE.
- RL adaptivity (#50) remains deferred — this ADR does not pre-empt its design.

## Alternatives Considered
- **Homogeneous GNN (single node/edge type)** — REJECTED: collapses account/device/merchant/counterparty
  distinctions and loses the cross-type signal the finding requires (heterogeneous chosen).
- **GBM baseline alone (skip the deep GNN)** — REJECTED: the baseline (`ADR-FRAUD-03`) cannot see
  relational/graph fraud; the HGNN is the deliberate accuracy layer above it.
- **#50 GNN+RL as a separate adoption now** — REJECTED: dup-of-#49; RL-adaptive thresholds are a
  follow-on extension of this same model, not an independent adopt.
- **Fold into `ADR-111` crypto-AML graph layer** — REJECTED: different domain (fiat fraud vs crypto
  laundering), different graph and regulatory frame; kept as a distinct, cross-referenced ADR.

## References
- `governance/ADOPTION-FINALIZATION-SP41.md` §1.1 (ADOPT #49), §4 (cluster-2 roadmap).
- `adrs/ADR-FRAUD-03-lightgbm-gbm-baseline.md` (#111) — the GBM baseline this HGNN sits above (KEEP).
- `adrs/ADR-FRAUD-01-device-fingerprinting.md`, `adrs/ADR-FRAUD-02-ato-prevention.md` — existing fraud stack (KEEP; referenced, not rewritten).
- `docs/adr/ADR-111-crypto-aml-graph-analytics.md` — **distinct** crypto-AML graph layer (KEEP; cross-referenced, not duplicated).
- `docs/governance/model-cards/fraud-classifier-evo2.md` — T1 fraud-classifier role (DRAFT, AWAITS OPERATOR) this model complements.
- Follow-on: **#50** fraudgnn-rl-adaptive (DUP-of-#49; deferred RL-adaptivity extension). Sibling baseline: **#111**/**#112**. Later cluster-2: **#46** nuformer-tx-embedding-model.
- ADR-102 (additive / pointer-first), ADR-046 (decision-lineage XAI), #66 LIME/SHAP, `docs/governance/MODEL-RISK-MANAGEMENT.md` (MRM), I-24/I-27.
