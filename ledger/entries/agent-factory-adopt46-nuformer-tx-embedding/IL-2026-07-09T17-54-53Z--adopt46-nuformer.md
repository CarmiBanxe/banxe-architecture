---
il_ts: 2026-07-09T17:54:53Z
session_id: agent-factory-adopt46-nuformer-tx-embedding
source: CEO
status: PROPOSED
---
### ADOPT #46 — tx-embedding transformer (nuformer) → completes fraud engine (GBM+HGNN+embedding) — PROPOSED

LAST item of SP41 roadmap §4 cluster-2 (fraud engine): a transformer pre-trained (self-supervised) on
merchant transaction sequences, emitting tx embeddings as the temporal/sequence fraud discriminator.
Decision record only (`adrs/ADR-FRAUD-05-tx-embedding-transformer.md`) — handoff GAP-FRAUD-ENGINE.
**ADR-102 Duplication Audit:** repo-wide search found NO prior tx-embedding/transformer/nuformer fraud
ADR (hits are novelty/adoption/ledger + ADR-FRAUD-03/04 refs + emi-banxe-engine sources); next in
ADR-FRAUD series after 01/02/03/04. Verdict: `adrs/ADR-FRAUD-05-tx-embedding-transformer.md` = **ADD**
(new); `docs/governance/model-cards/fraud-classifier-evo2.md` = **EXTEND** (one-line §6 Refs pointer,
format-consistent); ADR-FRAUD-01/02/03/04 + ADR-111 (distinct crypto-AML graph, cross-ref) + fraud-
classifier-evo2 model-card = **KEEP** (referenced, NOT rewritten). Position: THIRD ML layer of the fraud
engine — tabular GBM (ADR-FRAUD-03, interpretable floor+fallback) + heterogeneous GNN (ADR-FRAUD-04,
cross-entity relational) + tx-embedding (ADR-FRAUD-05, temporal/sequence). Embedding used both as a
standalone sequence discriminator AND as embedding features into GBM/HGNN (ensemble, not competing).
Ensemble/layering section documents the completed fraud engine as defense-in-depth (baseline→graph→
sequence, analogous to the cluster-1 LLM-safety layering #64→#65→#104): layers compose + reinforce,
graceful degradation to the GBM floor, uniform HITL/MRM/XAI governance envelope. Explicit accuracy/AC
trade-off: highest-AC (self-supervised pretraining compute + tx-sequence corpus, embedding-serving,
weaker intrinsic explainability — mitigated by attribution rationale + HITL, I-27). Governance: feeds
HITL (no autonomous regulated action), attention/attribution for MLRO (#66 XAI, ADR-046), MRM tiering
when trained. CONSTRAINT: PROPOSED/doc only — NO model code, NO transformer/pretraining pipeline, NO
import, NO CI; pretraining + embedding-serving + feature-pipeline into GBM/HGNN + trained-model model-
card = FOLLOW-UP under GAP-FRAUD-ENGINE. Fraud-scope (no credit). Config-over-hardcoding: embedding dim,
sequence window, pretraining objective, hyperparams, threshold = governed-config proposals (CLAUDE.md
§10). Cluster-2 fraud engine (#111 GBM + #49 HGNN + #46 tx-embedding) COMPLETE after this merges. Refs:
ADOPTION-FINALIZATION-SP41 §1.1/§4, GAP-FRAUD-ENGINE, ADR-102, ADR-FRAUD-03, ADR-FRAUD-04, ADR-111
(distinct), ADR-046, MODEL-RISK-MANAGEMENT, #66 XAI, I-24/I-27.
