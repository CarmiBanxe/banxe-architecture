# EMI Strategic Value Signal — Terminal-B → Central (directive-proposal)

- **DIRECTIVE-ID:** B-STRATEGIC-SIGNAL-001
- **From:** Terminal-B (Spec-Projects lane)
- **To:** Central (idea-owner / EMI-core direction)
- **Status:** OPEN
- **Ack-required:** Central
- **Date:** 2026-07-06
- **Merge policy:** HITL — do NOT auto-merge; Central ack precedes any adoption path.

> **B proposes, Central decides.** Scope = strategic direction of EMI BANXE
> across time / space; technical dimension (the 30 candidate findings) already
> lives in `governance/NOVELTY-COLLECTION-REGISTER.md` (source: EMI-BANXE
> open-source-stack review intake, PR #1051 / sp14, merged 2026-07-05).
> **This doc is a strategic overlay only** — it references item-slugs, it does
> **not** restate their content (ADR-102, no second source-of-truth). Central
> may accept any subset, re-sequence, or reject; B's role ends at the signal.

## Anchor to the technical layer (do not restate)

- Register: `governance/NOVELTY-COLLECTION-REGISTER.md` (30 rows appended by
  sp14 with `status=NEW`, `source-repo=emi-banxe-stack-review`).
- Intake log (evidence, dup-check, section trace): `governance/intake/SP14-EMI-STACK-INTAKE-2026-07-05T230601Z.md`.
- Terminal-B operating algorithm: `decisions/ADR-TERMINAL-B-SPEC-LANE.md` (ADR-159).
- Author-canon of no-restate: `docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md`.

Any deviation from a candidate's register row (dedup verdict, floor,
handoff-GAP) is authoritative at the register, not here. This document lifts
each item-slug only as a **placement signal** in four strategic dimensions.

---

## Dimension 1 — TIME (roadmap phasing: fast wins vs long foundation)

**Fast wins (0–3 months, low-integration risk, immediate ROI):**

- `langfuse-llm-observability` — value: fleet-wide prompt/cost/trace visibility
  becomes the measurement floor for everything after. Timing: standalone,
  ready. Dependency: none (unlocks the rest of TIME dim).
- `nemo-guardrails-runtime-safety` + `owasp-llm-top10-supply-chain` — value:
  runtime policy + supply-chain checklist close the LLM-boundary regulatory
  attack-surface Central will otherwise carry into every downstream item.
  Timing: fast. Dependency: pairs with observability for evidence trail.
- `assistant-ui-agent-frontend` — value: direct fit to open GAP-080
  (intent-first floor-1 UI). Timing: fast. Dependency: none in this doc.
- `deerflow-banking-orchestrator`, `strands-sdk-aws-agent-framework` — value:
  orchestration substrates evaluable in parallel; not a fast **adopt**, but a
  fast **choose**. Timing: pick-one within a quarter.

**Long foundation (6–18 months, high strategic ceiling):**

- `nuformer-tx-embedding-model`, `transactiongpt-payments-llm` — value:
  own-data foundation-model class; require labeled tx corpus + training
  cadence, therefore start data-side early. Timing: foundation, not fast-win.
- `fate-federated-learning-webank`, `vaultgemma-dp-private-llm`,
  `fate-cross-bank-aml-consortium` — value: cross-bank privacy stack;
  requires legal + counterparty alignment, therefore multi-quarter.
- `fraudgnn-rl-adaptive` (mature GNN+RL) — value: only meaningful after a
  stable graph substrate exists; long horizon.

## Dimension 2 — SPACE (market / compliance geography positioning)

**EU-GDPR + EU-AI-Act positioning (defensible EMI regulatory posture):**

- `vaultgemma-dp-private-llm` (DP), `fate-federated-learning-webank` (no
  raw-data sharing), `lime-shap-hitl-explainability` (Art. 14 decision-lineage
  fields), `nemo-guardrails-runtime-safety` (runtime policy proof),
  `owasp-llm-top10-supply-chain` (LLM Top-10 audit). Value: each one shortens
  the "how do you evidence X to a regulator" story that scales with EMI size.

**Offline-first / on-prem MLRO-lane:**

- `agenticseek-privacy-first-agent` — value: full-local alt for internal
  MLRO/audit tooling where cloud egress is a hard-no.

**Cross-bank networks (federation-space):**

- `fate-cross-bank-aml-consortium`, `fedkt-federated-knowledge-transfer`,
  `fisco-bcos-permissioned-ledger` (substrate reference). Value: a
  future EMI-consortium play needs the FL/permissioned-ledger primitives
  chosen up-front.

**Reference-only, non-adoptable in current geography** (kept as benchmarks,
not adoption targets): `sofastack-financial-cloud-antgroup`,
`wechatpay-gpt-payments-llm`, `quantum-gnn-fraud-research` (TRL-2).

## Dimension 3 — MOAT (competitive advantage, hard-to-copy layers)

**Fraud-GNN stack (deepest moat, floor 3 — hardest to replicate):**

- `fraudgnn-rl-adaptive`, `asa-gnn-adversarial-safe`,
  `hgnn-heterogeneous-gnn-fraud`, `temporal-knowledge-distillation-fraud`.
  Value: each contributes a distinct property (adaptivity, adversarial
  robustness, heterogeneity, streaming refresh); combined they form a
  fraud-GNN stack that own-EMI data trains uniquely well.

**Foundation-model own-data (proprietary tx corpus advantage):**

- `nuformer-tx-embedding-model`, `transactiongpt-payments-llm`,
  `finnlp-domain-nlp-toolkit`. Value: the moat here is the tx corpus, not the
  architecture — Central-owned data becomes the durable advantage.

**Treasury-RL (adjacent product surface):**

- `finrl-deepseek-rl-treasury`, `tradingagents-llm-multi-agent`,
  `qlib-quant-research-platform`. Value: optional lane extending EMI into
  treasury/FX policy learning; independent of fraud stack.

## Dimension 4 — SEQUENCING (proposed order — B's opinion, Central rules)

Foundation-before-dependents. Each phase unlocks the next; a later item
without its predecessor is measurably weaker.

- **Phase 0 — measurement + safety floor:** `langfuse-llm-observability` →
  `owasp-llm-top10-supply-chain` → `nemo-guardrails-runtime-safety`.
  Rationale: nothing after can be evidenced or bounded without this floor.
- **Phase 1 — governance UX + orchestration choice:** `assistant-ui-agent-frontend`
  + `lime-shap-hitl-explainability`, then choose ONE of
  `deerflow-banking-orchestrator` / `strands-sdk-aws-agent-framework` /
  `memory-first-agent-architecture` (Central call).
- **Phase 2 — fraud-graph foundation:** `hgnn-heterogeneous-gnn-fraud` first
  (heterogeneous graph = data model that every later fraud item depends on)
  → `nuformer-tx-embedding-model` (own-data embedding starts in parallel).
- **Phase 3 — adaptive + adversarial fraud:** `fraudgnn-rl-adaptive` +
  `asa-gnn-adversarial-safe` + `temporal-knowledge-distillation-fraud`.
  Rationale: all three depend on Phase-2 graph substrate.
- **Phase 4 — payments-LLM + treasury lane:** `transactiongpt-payments-llm`
  (needs Phase-2 corpus) + `finrl-deepseek-rl-treasury` /
  `tradingagents-llm-multi-agent` (independent, if Central pursues treasury).
- **Phase 5 — cross-bank privacy + FL:** `vaultgemma-dp-private-llm` →
  `fate-federated-learning-webank` → `fedkt-federated-knowledge-transfer` →
  `fate-cross-bank-aml-consortium`. Rationale: DP baseline first, then FL,
  then consortium — each is a precondition of the next.

**Not in the sequence** (reference-only, Central may drop entirely):
`suna-self-hosted-manus-clone`, `finrobot-fintech-multi-agent`,
`github-agentic-workflows-ci`, `fisco-bcos-permissioned-ledger`,
`sofastack-financial-cloud-antgroup`, `wechatpay-gpt-payments-llm`,
`quantum-gnn-fraud-research`.

Phase numbering here is **B's proposal**, not authoritative roadmap. The
external EMI-BANXE review's own Phase 0–6 vocabulary is orthogonal — Central
reconciles.

---

## Ack contract (Central → B)

Central acknowledges by any of:

1. Merging this PR after edits accepting/rejecting/re-sequencing items.
2. Filing an ADR that supersedes or scopes phases.
3. Writing a Central directive back to B that closes DIRECTIVE
   B-STRATEGIC-SIGNAL-001.

Until then: status remains **OPEN**; B does NOT act on any adoption; the
register's per-row `handoff` fields remain the operator's routing surface.
