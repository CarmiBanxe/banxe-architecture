---
title: "ADOPTION-FINALIZATION SP41 — self-contained finalization (supersedes closed #1098) — PROPOSED"
status: PROPOSED
classification: central_finalization (self-contained authoritative record; ADR-102 compliant)
supersedes: "PR #1098 (governance/ADOPTION-AUDIT-88.md) — CLOSED/superseded; its verdicts are EMBEDDED here as the authoritative record (the closed file does not land on main)"
register: "governance/NOVELTY-COLLECTION-REGISTER.md — UNCHANGED (append-only, I-24; remains the SSOT of the 88 raw findings)"
date: 2026-07-09
author: Terminal-A (Factory) — Central-finalization pass
operator_rulings:
  - "CREDIT/LENDING = NOT an EMI function → REJECT-out-of-scope (permanent; not DEFER-to-licence)"
  - "TRADING/treasury/quant = PAYBIS-DISTRIBUTION-TRACK (PAYBIS licensed; BANXE distributor, not own-licence)"
  - "44 DEFER (0.30–0.60) = formulate as standalone consultant questions"
invariants: I-27 preserved; EMI scope preserved; numbers = governed-config *proposal*; register append-only (I-24)
activation_note: NOTHING activated — each ADOPT lands as its own sprint/IL with ADR-102 Duplication Audit
---

# ADOPTION-FINALIZATION SP41 — self-contained finalization (supersedes closed #1098) — PROPOSED

> **Status: PROPOSED.** This is the **self-contained, authoritative finalization** of the 88-findings
> adoption triage. It **supersedes PR #1098** (`governance/ADOPTION-AUDIT-88.md`), which is **CLOSED**
> and does **not** land on `main`; the audit's essential verdict data is therefore **embedded inline
> here** (buckets, per-item lists, ESCALATE set — see the *Embedded verdict record* below) so this
> file stands alone with **no dependency on the closed artefact**. It does **NOT** touch
> `governance/NOVELTY-COLLECTION-REGISTER.md` (the SSOT register of the 88 raw findings — unchanged,
> append-only, I-24).
>
> **Nothing here activates a decision.** All numeric parameters remain **governed-config
> proposals** (CLAUDE.md §10). **I-27 preserved** end-to-end. Each surviving ADOPT lands as its
> **own sprint / IL** with a fresh **ADR-102 Duplication Audit** — this finalization adopts nothing
> itself.

## Provenance and precedence

- **Supersedes #1098 (closed).** The scoring/triage was produced by the now-closed
  `ADOPTION-AUDIT-88.md`. Because that file does not land on `main`, its verdicts are **embedded
  here as the authoritative record** — this finalization is the single source of the disposition,
  not a pointer to a non-landing file.
- **SSOT of raw findings = the register.** `governance/NOVELTY-COLLECTION-REGISTER.md` (on `main`,
  rows 43–130) remains the unchanged SSOT of the 88 raw findings; every item below cites its
  register `name` / `source-repo` / capability verbatim.
- **Precedence:** operator ruling > audit proposal. Where an operator ruling reclassifies an audit
  verdict (credit → REJECT-OOS §2; trading → PAYBIS §3), the operator ruling is the finalized record.

## Embedded verdict record (self-contained — method + triage buckets)

**Triage method (from the closed audit; embedded for standalone reference).** Two-stage triage over
the 88 findings, canonical in `docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md` §Q4 (on `main`):

- **Stage 1 — Hard-gate** (deterministic): EMI-scope / sanctions / I-27 admissibility. Credit /
  lending / investment / trading outside the EMI licence → held (now finalized by operator rulings
  §2/§3); PRC-state-affiliated fintech → REJECT-hard, no score.
- **Stage 2 — Dedup-by-need:** collapse duplicates to the same capability-need → keep-best; rest
  recorded `dup-of:<item>`.
- **Stage 3 — Score-triage** on survivors, metric family **HGC / FCR / AC / CGR** (all `[0,1]`,
  governed-config *proposal*):
  `S = 0.35·FCR + 0.15·CGR − 0.30·HGC − 0.20·AC` (normalised via +0.50 shift).
  `ADOPT S ≥ 0.60 · DEFER 0.30 ≤ S < 0.60 · REJECT S < 0.30`.
  Lexicographic override: **FCR ≥ 0.80 → ESCALATE-IMMEDIATE** (single-dimension safety dominance).

**Triage buckets (embedded — the authoritative disposition of all 88 findings, rows 43–130):**

| Bucket | Count | Items |
|--------|------:|-------|
| ADOPT (S ≥ 0.60) | 9 | 46, 49, 56, 64\*, 65\*, 66, 68, 104\*, 111 (\* = FCR ≥ 0.80 ESCALATE: 64, 65, 104) |
| DUP (dedup-by-need) | 8 | 50→49, 53→52, 70→52, 105→68, 112→111, 117→116, 120→119, 121→119 |
| REJECT-hard (Stage-1, sanctions/posture) | 2 | 48, 59 |
| REJECT (Stage-3, S < 0.30) | 17 | 71, 78, 80, 85, 86, 87, 90, 92, 94, 95, 99, 102, 106, 110, 122, 123, 124 |
| Stage-1 credit/trading held → **finalized by operator** | 8 | credit: 113, 129, 130 (+ #111 credit-portion) → **REJECT-OOS §2**; trading: 55, 60, 62, 63, 81 → **PAYBIS §3** |
| DEFER (0.30 ≤ S < 0.60) → **consultant questions** | 44 | §5.A–5.J |

> The per-item scores and rationale are embedded in §1 (ADOPT) and enumerated by id in §1.4 (REJECT)
> and §5 (DEFER). No lookup of the closed `ADOPTION-AUDIT-88.md` is required to read this file.

---

## §1 — CONFIRMED (embedded from the superseded #1098 audit)

The following verdicts were produced by the now-closed #1098 audit and are **confirmed and embedded
here as the authoritative record** (no change to the scoring; the closed file is not relied upon).

### 1.1 ADOPT — 9 (3 ESCALATE-IMMEDIATE listed first)

| # | item | S | verdict |
|---|------|---|---------|
| 64 | owasp-llm-top10-supply-chain | 0.7875 | **ADOPT + ESCALATE-IMMEDIATE** (FCR 0.85) |
| 65 | nemo-guardrails-runtime-safety | 0.685 | **ADOPT + ESCALATE-IMMEDIATE** (FCR 0.80) |
| 104 | guardrails-ai-validators | 0.695 | **ADOPT + ESCALATE-IMMEDIATE** (FCR 0.80) |
| 46 | nuformer-tx-embedding-model | 0.625 | ADOPT (fraud engine — tx embedding) |
| 49 | hgnn-heterogeneous-gnn-fraud | 0.60 | ADOPT (fraud engine — heterogeneous GNN) |
| 56 | assistant-ui-agent-frontend | 0.6125 | ADOPT (GAP-080 floor-1 intent-first UI) |
| 66 | lime-shap-hitl-explainability | 0.6275 | ADOPT (ADR-046 decision-lineage XAI) |
| 68 | langfuse-llm-observability | 0.6575 | ADOPT (LLM prompt/trace/cost observability) |
| 111 | lightgbm-fraud-credit-gbm | 0.695 | **ADOPT — FRAUD-USE ONLY** (credit-use → REJECTED-OOS, see §2) |

> **#111 note:** confirmed ADOPT **for fraud only**. Its former credit-use holding behind
> `B-EMI-CREDIT-GATE-001` is **removed and permanently rejected** per operator ruling 1 (§2).
> The GBM baseline is adopted strictly as an EMI-scope **fraud** discriminator.

### 1.2 DUP — 8 (dedup-by-need; each folds into its keep-best twin)

50 → dup-of 49 (fraud-GNN); 53 → dup-of 52 (FATE); 70 → dup-of 52 (FATE);
105 → dup-of 68 (LLM-observability); 112 → dup-of 111 (GBM);
117 → dup-of 116 (Tor OSINT); 120 → dup-of 119 (card-issuing); 121 → dup-of 119 (card-issuing).

### 1.3 Stage-1 hard REJECT — 2 (sanctions / regulator-posture; permanent, reference-only)

- **48 wechatpay-gpt-payments-llm** — PRC state-affiliated (Tencent WeChatPay); non-adoptable
  under UK/EEA regulator posture.
- **59 sofastack-financial-cloud-antgroup** — Ant Group PRC-origin fin-cloud; not EU/UK-adoptable.

### 1.4 Score-based REJECT — 17 (S < 0.30; confirmed)

71 (0.27), 78 (0.26), 80 (0.29), 85 (0.26), 86 (0.24), 87 (0.25), 90 (0.29), 92 (0.27),
94 (0.28), 95 (0.28), 99 (0.26), 102 (0.27), 106 (0.27), 110 (0.27), 122 (0.275), 123 (0.24),
124 (0.24). Central may reclassify only if operational context changes.

---

## §2 — OPERATOR-OVERRIDE — CREDIT/LENDING = REJECTED-OUT-OF-SCOPE (permanent)

> **Operator ruling 1 (verbatim intent):** *Credit / lending is NOT an EMI function → REJECT-out-of-scope
> permanently (not DEFER-to-licence).* This is a **permanent scope exclusion**, not a licence-gate
> holding. The `B-EMI-CREDIT-GATE-001` holding pen is **removed** for these items — they are not
> "parked pending a licence extension"; they are out of BANXE's EMI remit and rejected.

| # | item | prior (#1098) | **finalized verdict** |
|---|------|---------------|-----------------------|
| 113 | credit-scoring-oss-pipeline | DEFER-to-licence | **REJECT-OOS (permanent)** |
| 129 | lending-2027-consumer-credit-roadmap | DEFER-to-licence | **REJECT-OOS (permanent)** |
| 130 | sme-alternative-credit-scoring-2027 | DEFER-to-licence | **REJECT-OOS (permanent)** |
| 111 (credit-portion) | lightgbm — credit-use | credit gated by `B-EMI-CREDIT-GATE-001` | **REJECT-OOS (permanent)**; #111 remains ADOPT for **fraud** only (§1.1) |

**Effect:** `B-EMI-CREDIT-GATE-001` no longer holds any credit/lending finding for a future
licence extension — credit/lending is excluded from BANXE's EMI scope. The gate anchor remains
referenced only for historical traceability; it holds **zero** open credit items after this
overlay. No consultant question is raised for the credit family (the ruling is definitive).

---

## §3 — OPERATOR-OVERRIDE — TRADING/TREASURY/QUANT via PAYBIS-DISTRIBUTION-TRACK

> **Operator ruling 2 (verbatim intent):** *Trading / treasury / quant is delivered via **PAYBIS
> distribution** — PAYBIS is the licensed entity; BANXE acts as **distributor, NOT own-licence**.*
> These five items are **reclassified from DEFER-to-licence to PAYBIS-DISTRIBUTION-TRACK**:
> evaluate each as a **PAYBIS-distributed capability**, never as a BANXE own-trading licence.
> Each becomes a **consultant question** — *which, if any, to actually distribute* (see §5.K).

| # | item | source | prior (#1098) | **finalized track** |
|---|------|--------|---------------|---------------------|
| 55 | finrl-deepseek-rl-treasury | emi-banxe-stack-review | DEFER-to-licence | **PAYBIS-DISTRIBUTION-TRACK** — consultant Q |
| 60 | finrobot-fintech-multi-agent | emi-banxe-stack-review | DEFER-to-licence | **PAYBIS-DISTRIBUTION-TRACK** — consultant Q |
| 62 | tradingagents-llm-multi-agent | emi-banxe-stack-review | DEFER-to-licence | **PAYBIS-DISTRIBUTION-TRACK** — consultant Q |
| 63 | qlib-quant-research-platform | emi-banxe-stack-review | DEFER-to-licence | **PAYBIS-DISTRIBUTION-TRACK** — consultant Q |
| 81 | fingpt-ai4finance-financial-llm | banxe-oss-solutions | DEFER-to-licence | **PAYBIS-DISTRIBUTION-TRACK** — consultant Q |

**Framing for each:** the capability is only ever considered as *distributed under PAYBIS's
licence* (BANXE = distribution channel per ADR-138 crypto-custody precedent). The consultant
decision is binary per item: **adopt-as-PAYBIS-distribution? (yes/no)** with rationale (§5.K).

---

## §4 — ROADMAP (ADOPT items, best-decision sequencing)

Best-decision order for the 9 confirmed ADOPT items. **Each becomes its own sprint / IL** with a
fresh **ADR-102 Duplication Audit** (repo-wide search → source-of-truth + every consumer → keep/
merge/delete + risks → fail-closed on doubt) and, where code lands on a server, the **ADR-103**
server-only gate. This overlay adopts **nothing** itself.

1. **ESCALATE-IMMEDIATE — LLM-safety perimeter (FCR ≥ 0.80):** **#64** owasp-llm-top10-supply-chain,
   **#65** nemo-guardrails-runtime-safety, **#104** guardrails-ai-validators. Sequence first —
   single-dimension safety dominance. Integrate #64 into `ai-cost-policy` + OSS-supply-chain
   review; #65 runtime guardrails + #104 LLM-input validators complement the prompt canon.
2. **Fraud engine:** **#46** nuformer-tx-embedding-model, **#49** hgnn-heterogeneous-gnn-fraud,
   **#111 (fraud-use)** lightgbm baseline. GBM baseline (#111) before deep GNN (#49) + tx-embedding
   discriminator (#46), all under GAP-FRAUD-ENGINE.
3. **UI / observability / XAI:** **#56** assistant-ui-agent-frontend (GAP-080 floor-1),
   **#68** langfuse-llm-observability (LiteLLM :4000 fleet), **#66** lime-shap-hitl-explainability
   (ADR-046 decision-lineage).

> Sequencing is a **best-decision proposal** for Central + operator; it activates nothing. The
> FCR ≥ 0.80 lexicographic override is the only hard ordering constraint (cluster 1 first).

---

## §5 — CONSULTANT QUESTIONS (44 DEFER + 5 PAYBIS-trading = 49)

Each question is **self-contained** so an external consultant can answer standalone: `finding-id`,
`name`, `source-repo`, `capability`, **BANXE context** (EMI-scope / existing-stack overlap /
regulatory note), and **the decision asked** (ADOPT / DEFER / REJECT + rationale). Names, sources,
and capability text are pulled **verbatim** from `NOVELTY-COLLECTION-REGISTER.md` rows 43–130
(register unchanged). Grouped by capability-family for review efficiency only — each is finalized
on its own merit.

### 5.A Agent frameworks / orchestration (13)

- **#43 deerflow-banking-orchestrator** (emi-banxe-stack-review) — *ByteDance DeerFlow multi-agent
  orchestrator; not in SRC-01 landscape of 10 frameworks.* **BANXE context:** GAP-AGENT-ENGINE;
  overlaps the existing LangGraph/OWL agent-engine choice. **Decision asked:** adopt as an
  alternative agent-engine, defer behind the SRC-01 landscape decision, or reject as duplicative?
- **#44 agenticseek-privacy-first-agent** (emi-banxe-stack-review) — *fully-local autonomous agent
  framework; privacy-first alt for on-prem MLRO tooling.* **BANXE context:** no GAP handoff; low
  estimated value; potential on-prem MLRO use. **Decision asked:** adopt for on-prem MLRO tooling,
  defer, or reject?
- **#45 suna-self-hosted-manus-clone** (emi-banxe-stack-review) — *Kortix Suna self-hosted general
  agent; competes with existing OWL/CAMEL choice.* **BANXE context:** overlaps OWL/CAMEL.
  **Decision asked:** adopt as a general-agent substrate, defer, or reject as duplicative of OWL/CAMEL?
- **#58 strands-sdk-aws-agent-framework** (emi-banxe-stack-review) — *AWS Strands agent SDK;
  opinionated agent-native runtime, alt to LangGraph for cloud-native flows.* **BANXE context:**
  AWS/cloud-native lean vs BANXE on-prem posture. **Decision asked:** adopt for a cloud-native
  surface, defer, or reject on on-prem-posture grounds?
- **#69 memory-first-agent-architecture** (emi-banxe-stack-review) — *memory-first agent architecture
  — Mem0 / Zep persistent memory as the primary reasoning substrate.* **BANXE context:** relates to
  the memoir pilot (ADR-165) memory work; no compelling need vs current stack. **Decision asked:**
  adopt Mem0/Zep as memory substrate, defer pending memoir-pilot outcome, or reject?
- **#73 agno-multimodal-agent-framework** (banxe-oss-solutions) — *Pythonic multi-modal agent
  framework; not in SRC-01 landscape of 10 frameworks.* **BANXE context:** GAP-AGENT-ENGINE;
  overlaps existing choices. **Decision asked:** adopt, defer, or reject as duplicative?
- **#74 smolagents-hf-micro-agent** (banxe-oss-solutions) — *Hugging Face micro-agent library;
  lightweight code-first agents, alt to CrewAI for small footprints.* **BANXE context:**
  GAP-AGENT-ENGINE; small-footprint niche. **Decision asked:** adopt for lightweight agents,
  defer, or reject?
- **#75 goose-block-dev-loop-agent** (banxe-oss-solutions) — *Block/Square Goose dev-loop coding
  agent; local-only, developer-facing not customer-facing.* **BANXE context:** factory-plane
  developer tooling, not banking runtime. **Decision asked:** adopt as factory-plane dev tooling,
  defer, or reject as out-of-runtime-scope?
- **#76 mastra-typescript-agent-framework** (banxe-oss-solutions) — *TypeScript-first agent
  framework; possible fit for frontend intent-first surface alongside assistant-ui.* **BANXE
  context:** GAP-080; pairs with confirmed-ADOPT #56 assistant-ui. **Decision asked:** adopt for
  the floor-1 intent-first surface, defer pending #56 integration, or reject?
- **#77 langchain-js-agent-sdk** (banxe-oss-solutions) — *JS/TS LangChain SDK for browser/edge
  agent surface; complements floor-1 intent-first.* **BANXE context:** GAP-080 frontend.
  **Decision asked:** adopt for the browser/edge surface, defer, or reject?
- **#79 openhands-swe-general-agent** (banxe-oss-solutions) — *formerly OpenDevin; general-purpose
  SWE agent; possible factory-plane coding assist alt to Goose.* **BANXE context:** factory-plane,
  not banking runtime. **Decision asked:** adopt as factory-plane assist, defer, or reject?
- **#91 dify-llm-app-orchestration** (banxe-oss-solutions) — *LLM-app orchestration platform;
  alt to LangGraph/n8n for internal ops tooling.* **BANXE context:** overlaps LangGraph/n8n.
  **Decision asked:** adopt for internal ops, defer, or reject as duplicative?
- **#93 airflow-workflow-orchestrator** (banxe-oss-solutions) — *Apache Airflow; alt/complement to
  Temporal for data-pipeline schedules, not saga workflows.* **BANXE context:** Temporal already
  covers sagas; Airflow would be data-pipeline scheduling only. **Decision asked:** adopt for
  data-pipeline scheduling, defer, or reject (Temporal sufficient)?
- **#126 bmad-agentic-dev-method** (banxe-concept-v7v9) — *BMAD-method agent-orchestrated dev
  workflow; complements factory-plane skills orchestration — not a runtime component.* **BANXE
  context:** factory-plane methodology, not runtime. **Decision asked:** adopt as a factory-plane
  method, defer, or reject?

### 5.B Fraud detection (4)

- **#47 transactiongpt-payments-llm** (emi-banxe-stack-review) — *payments-domain LLM for tx
  annotation / anomaly explanation.* **BANXE context:** GAP-FRAUD-ENGINE; high value, moderate
  LLM-safety overhead (pairs with the §4 LLM-safety perimeter). **Decision asked:** adopt as a
  fraud-annotation LLM (gated by the LLM-safety ADOPTs), defer, or reject?
- **#51 asa-gnn-adversarial-safe** (emi-banxe-stack-review) — *adversarial-safe GNN; hardens fraud
  model against poisoning attacks — regulator-relevant.* **BANXE context:** GAP-FRAUD-ENGINE;
  distinct adversarial-safe capability atop the confirmed-ADOPT GNN (#49). **Decision asked:**
  adopt as an adversarial-hardening layer over #49, defer, or reject?
- **#72 temporal-knowledge-distillation-fraud** (emi-banxe-stack-review) — *temporal knowledge
  distillation for streaming fraud model refresh without catastrophic forgetting.* **BANXE
  context:** GAP-FRAUD-ENGINE; complementary to the primary GNN. **Decision asked:** adopt for
  streaming model refresh, defer, or reject as complementary-only?
- **#84 agentic-fraud-detection-pattern** (banxe-oss-solutions) — *reference agentic fraud-detection
  pattern / OSS bundle; distinct from GNN family.* **BANXE context:** GAP-FRAUD-ENGINE; a pattern
  bundle, not decisive vs the GNN engine. **Decision asked:** adopt the pattern bundle, defer, or
  reject?

### 5.C AML / cross-bank privacy / DP LLM (2)

- **#52 fate-federated-learning-webank** (emi-banxe-stack-review) — *WeBank FATE federated learning
  framework; enables cross-bank AML consortium without raw-data sharing.* **BANXE context:**
  GAP-AML-CROSS-BANK; **regulatory note** — WeBank-origin HGC (0.65); not Stage-1 sanctions-rejected
  but weigh origin vs alt FL substrates. **Decision asked:** adopt as the cross-bank AML consortium
  substrate, defer pending an origin/governance review, or reject on origin grounds?
- **#54 vaultgemma-dp-private-llm** (emi-banxe-stack-review) — *Google differentially-private Gemma;
  production-safe LLM under strong GDPR / customer-data constraints.* **BANXE context:**
  GAP-LLM-PRIVACY; borderline-ADOPT (S 0.57). **Decision asked:** adopt as the DP LLM for
  customer-data flows, defer, or reject?

### 5.D KYC / identity (2)

- **#82 openkyc-agentic-verification** (banxe-oss-solutions) — *OSS KYC verification framework;
  alt/complement to commercial identity providers.* **BANXE context:** GAP-KYC-ENGINE; needs a
  pilot vs a commercial-provider baseline. **Decision asked:** adopt (pilot), defer pending the
  commercial baseline, or reject?
- **#83 verifiable-agent-kit-zk-proof** (banxe-oss-solutions) — *ZK-proof KYC / verifiable
  credentials; privacy-preserving identity attestation for GDPR-heavy flows.* **BANXE context:**
  GAP-KYC-ENGINE; strongest privacy-preserving KYC candidate (FCR 0.75) but heavy AC (0.65).
  **Decision asked:** adopt if a ZK-proof KYC pilot is on the roadmap, defer, or reject on
  integration-cost grounds?

### 5.E NLP / RAG / eval (5)

- **#61 finnlp-domain-nlp-toolkit** (emi-banxe-stack-review) — *AI4Finance FinNLP toolkit for
  financial NLP; sentiment / relation extraction from filings / news.* **BANXE context:**
  AML-adjacent (entity/sentiment extraction). **Decision asked:** adopt for AML-adjacent NLP,
  defer, or reject?
- **#89 llamaindex-rag-orchestration** (banxe-oss-solutions) — *RAG-orchestration framework; not in
  SRC-01/04; adjacent to Haystack for compliance-KB retrieval.* **BANXE context:** GAP-COMPLIANCE-KB;
  overlaps Haystack. **Decision asked:** adopt for compliance-KB RAG, defer, or reject as
  duplicative of Haystack?
- **#107 deepeval-llm-eval-framework** (banxe-oss-solutions) — *Confident-AI OSS LLM eval framework;
  direct fit for ADR-141 self-healing eval harness.* **BANXE context:** GAP-LLM-EVAL; direct
  ADR-141 fit. **Decision asked:** adopt for the ADR-141 harness, defer, or reject?
- **#108 ragas-rag-evaluation** (banxe-oss-solutions) — *RAG-specific evaluation lib; fits
  compliance_kb RAG quality gate.* **BANXE context:** GAP-COMPLIANCE-KB quality gate. **Decision
  asked:** adopt for the RAG quality gate, defer, or reject?
- **#109 mlflow-ml-lifecycle-tracking** (banxe-oss-solutions) — *Databricks OSS ML/LLM lifecycle
  tracking; fits fraud/credit model registry and self-healing loop.* **BANXE context:**
  GAP-FRAUD-ENGINE model registry (credit-use excluded per §2 — fraud registry only). **Decision
  asked:** adopt for the fraud model registry, defer, or reject?

### 5.F Web / browser automation (4)

- **#98 browser-use-python-web-agent** (banxe-oss-solutions) — *Python browser automation for LLM
  agents; direct fit for OpenManus-like browser-agent surface.* **BANXE context:** no GAP handoff.
  **Decision asked:** adopt for browser-agent automation, defer, or reject?
- **#100 skyvern-vision-web-automation** (banxe-oss-solutions) — *vision-based web automation;
  possible fit for regulatory-portal automation, e.g. FCA Connect uploads.* **BANXE context:**
  GAP-REG-PORTAL-AUTOMATION; regulator-portal use. **Decision asked:** adopt for reg-portal
  automation, defer, or reject?
- **#101 playwright-microsoft-browser-automation** (banxe-oss-solutions) — *Microsoft Playwright;
  browser automation lib for both agents and test surface.* **BANXE context:** dual agent + test
  use. **Decision asked:** adopt as the browser-automation lib, defer, or reject?
- **#103 open-webui-selfhosted-chat-ui** (banxe-oss-solutions) — *self-hosted chat UI over Ollama;
  possible operator-side console alt to Telegram OpenClaw bot.* **BANXE context:** operator-console
  alt. **Decision asked:** adopt as an operator console, defer, or reject?

### 5.G OSINT / adverse-media / Tor (4) — #116 / #118 legal-sensitive, sandbox-only

- **#114 spiderfoot-osint-adverse-media** (banxe-concept-v7v9) — *open-source OSINT reconnaissance;
  complements adverse-media governor with automated web-source enumeration for MLRO / EDD packs.*
  **BANXE context:** GAP-ADVERSE-MEDIA-OSINT. **Decision asked:** adopt for MLRO/EDD adverse-media
  enrichment, defer, or reject?
- **#115 gdelt-global-events-knowledge-graph** (banxe-concept-v7v9) — *GDELT Project; global events /
  tone / mentions dataset for real-time PEP / adverse-media signal enrichment.* **BANXE context:**
  GAP-ADVERSE-MEDIA-OSINT. **Decision asked:** adopt for PEP/adverse-media enrichment, defer, or
  reject?
- **#116 onionsearch-tor-index-scanner** (banxe-concept-v7v9) — *Tor .onion search index enumerator;
  dark-web AML signal source — **legally sensitive, sandboxed evaluation only**.* **BANXE context:**
  GAP-DARKWEB-OSINT; **regulatory flag** — HGC 0.75; if pursued, **sandboxed-eval-only** with a
  bespoke governance wrapper/ADR (do NOT fold into general adverse-media flow). **Decision asked:**
  adopt **as sandboxed-eval-only** under a bespoke ADR, defer, or reject on legal-sensitivity grounds?
- **#118 reputell-onion-reputation-signal** (banxe-concept-v7v9) — *Tor reputation signal aggregator;
  sanctions / fraud reputational context for VASP counterparties.* **BANXE context:**
  GAP-DARKWEB-OSINT; **regulatory flag** — HGC 0.70, **sandboxed-eval-only**, bespoke governance
  wrapper. **Decision asked:** adopt **as sandboxed-eval-only** under a bespoke ADR, defer, or
  reject?

### 5.H Ledger / blockchain (2)

- **#57 fisco-bcos-permissioned-ledger** (emi-banxe-stack-review) — *WeBank FISCO-BCOS permissioned
  blockchain; alt for interbank recon / settlement consortium substrate.* **BANXE context:** high
  AC/HGC; regulator-preferred alt (#88 Hyperledger) exists; WeBank-origin. **Decision asked:**
  adopt as the consortium ledger substrate, defer in favour of #88, or reject on origin/cost grounds?
- **#88 hyperledger-fabric-permissioned-ledger** (banxe-oss-solutions) — *Linux Foundation
  permissioned blockchain; alt/complement to FISCO-BCOS with LF governance origin — regulator-preferred.*
  **BANXE context:** better regulator posture than #57 but heavy AC; note ADR-013 selects Midaz
  PRIMARY / Fineract FALLBACK for the core ledger (this is a consortium-substrate question, not core).
  **Decision asked:** adopt as the consortium substrate, defer, or reject?

### 5.I Payments / MCP / card issuing (3) — #119 closest-to-ADOPT (resolves 119/120/121)

- **#96 bank-mcp-banking-server-family** (banxe-oss-solutions) — *banking-specific MCP server family;
  adjacent to banxe_mcp/server.py 34 tools but with external-bank connector focus.* **BANXE context:**
  GAP-MCP-EXTERNAL-BANK; external-bank connectors. **Decision asked:** adopt for external-bank
  connectors, defer, or reject as adjacent to the existing MCP server?
- **#97 stripe-ai-sdk-payments-mcp** (banxe-oss-solutions) — *Stripe AI SDK / MCP for payments-agent
  surface; alt to bespoke card-scheme tools.* **BANXE context:** payments-agent MCP. **Decision
  asked:** adopt as a payments-agent MCP, defer, or reject?
- **#119 paynetics-bin-sponsor-emi** (banxe-concept-v7v9) — *Paynetics EEA/UK BIN sponsor + issuing
  partner; alt/complement to Paymentology for card issuance under EMI.* **BANXE context:** GAP-074
  (card issuing); **closest DEFER to ADOPT (S 0.5625)**; finalizing #119 also **resolves the
  card-issuing 3-overlap** (dedups #120 transact-pay, #121 tribe-payments). **Decision asked:**
  adopt #119 as the EMI BIN-sponsor/issuing partner (resolving the family), defer, or reject?

### 5.J Compliance / regulator surface (3)

- **#125 tremor-react-dashboard-components** (banxe-concept-v7v9) — *Tremor React charts / KPI blocks;
  MIT; fit for internal ops / MLRO dashboards alongside GAP-080 intent-first surface.* **BANXE
  context:** GAP-080-adjacent; MIT-licensed UI components. **Decision asked:** adopt for internal
  ops/MLRO dashboards, defer, or reject?
- **#127 dutymark-consumer-duty-tracker** (banxe-concept-v7v9) — *Consumer Duty outcome-tracking tool;
  complements ADR-054 analytics/reporting mask and Consumer Duty S9-06 line.* **BANXE context:**
  GAP-CONSUMER-DUTY-TRACKING; ADR-054 + S9-06 fit. **Decision asked:** adopt for Consumer Duty
  outcome-tracking, defer, or reject?
- **#128 omp-fca-obligations-mapping-tool** (banxe-concept-v7v9) — *FCA obligations / rulebook mapping
  tool; complements COMPLIANCE-MATRIX 200+ req and regulatory horizon-scan.* **BANXE context:**
  GAP-FCA-OBLIGATIONS-MAPPING; COMPLIANCE-MATRIX fit. **Decision asked:** adopt for FCA obligations
  mapping, defer, or reject?

### 5.K PAYBIS-distribution track — trading / treasury / quant (5)

> Per operator ruling 2 (§3): evaluate each **only** as a PAYBIS-distributed capability (PAYBIS
> licensed; BANXE distributor). The decision is binary: **adopt-as-PAYBIS-distribution? (yes/no)**.

- **#55 finrl-deepseek-rl-treasury** (emi-banxe-stack-review) — *FinRL + DeepSeek reasoning for
  treasury / FX policy learning; RL agent for hedging decisions.* **BANXE context:** trading/treasury
  — **NOT own-licence**; only via PAYBIS distribution. **Decision asked:** adopt-as-PAYBIS-distribution
  (yes/no) + rationale?
- **#60 finrobot-fintech-multi-agent** (emi-banxe-stack-review) — *AI4Finance FinRobot LLM-powered
  financial multi-agent framework; adjacent to trading / treasury agents.* **BANXE context:**
  trading-adjacent; PAYBIS-distribution only. **Decision asked:** adopt-as-PAYBIS-distribution (yes/no)?
- **#62 tradingagents-llm-multi-agent** (emi-banxe-stack-review) — *AI4Finance TradingAgents
  multi-agent LLM trading system; reference for treasury-desk agent design.* **BANXE context:**
  explicit trading system; PAYBIS-distribution only. **Decision asked:** adopt-as-PAYBIS-distribution
  (yes/no)?
- **#63 qlib-quant-research-platform** (emi-banxe-stack-review) — *Microsoft Qlib quant AI platform;
  reference for FX / treasury back-testing pipeline.* **BANXE context:** quant back-testing;
  PAYBIS-distribution only. **Decision asked:** adopt-as-PAYBIS-distribution (yes/no)?
- **#81 fingpt-ai4finance-financial-llm** (banxe-oss-solutions) — *AI4Finance FinGPT LLM fine-tuned on
  financial text; trading / portfolio adjacencies.* **BANXE context:** trading-family LLM;
  PAYBIS-distribution only. **Decision asked:** adopt-as-PAYBIS-distribution (yes/no)?

---

## §6 — Invariants, boundaries, and finalization pathway

- **Register UNCHANGED.** `governance/NOVELTY-COLLECTION-REGISTER.md` is **not** touched by this
  finalization — no row edits, no verdict mutation (append-only, I-24; it stays the SSOT of the 88
  raw findings). Finalization is recorded here; the register changes only via **new appended rows**,
  if at all.
- **Self-contained — supersedes closed #1098.** `governance/ADOPTION-AUDIT-88.md` is **CLOSED** and
  does not land on `main`; this file does not depend on it (its verdicts are embedded above, see
  *Embedded verdict record*). ADR-102 is satisfied by embedding the authoritative record rather than
  pointing to a non-landing file.
- **I-27 preserved.** No autonomous production-state mutation. Advisory-only until Central +
  operator ratify.
- **EMI scope enforced.** Credit / lending → **REJECT-OOS permanent** (§2); trading / treasury /
  quant → **PAYBIS-distribution only, not own-licence** (§3). The TOMPAY-EMI boundary is respected.
- **Numbers = governed-config proposal.** All HGC/FCR/AC/CGR values, weights `(0.35,0.15,0.30,0.20)`,
  thresholds `(0.60/0.30)`, and the FCR ≥ 0.80 override remain **proposals** (CLAUDE.md §10). Live
  activation requires a human-gated PR against `governance/novelty-pipeline-config.yaml`.
- **ADR-102 per ADOPT.** Each surviving ADOPT lands as its own sprint / IL with a fresh repo-wide
  Duplication Audit — not folded into this finalization.
- **Nothing activated.** This overlay is PROPOSED. Central + operator ratify; each ADOPT then gets
  its own IL sprint (with DA and, if applicable, ADR); numeric proposals activate only via the
  governed-config PR.

### Finalized counts (this finalization)

| Bucket | Count | Notes |
|--------|------:|-------|
| ADOPT (confirmed) | **9** | incl. #111 fraud-use only; 3 ESCALATE-IMMEDIATE (64, 65, 104) |
| REJECT-OOS — credit/lending (operator ruling 1) | **3** | 113, 129, 130 (+ #111 credit-portion, partial) |
| REJECT (confirmed, embedded) | **19** | 2 Stage-1 hard (48, 59) + 17 score-REJECT |
| PAYBIS-DISTRIBUTION-TRACK (operator ruling 2) | **5** | 55, 60, 62, 63, 81 — consultant Q (§5.K) |
| DEFER → consultant questions | **44** | §5.A–5.J |
| **Consultant questions total** | **49** | 44 DEFER + 5 PAYBIS-trading |
| DUP (folded) | **8** | 50, 53, 70, 105, 112, 117, 120, 121 |

## Cross-references

- **PR #1098 / `ADOPTION-AUDIT-88.md`** — **CLOSED/superseded** (did not land on `main`); its
  scoring/triage is **embedded above** as the authoritative record. Historical pointer only.
- `governance/NOVELTY-COLLECTION-REGISTER.md` — SSOT register of the 88 raw findings (rows 43–130
  quoted verbatim); **not mutated** (append-only, I-24).
- `docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md` §Q4 — two-stage triage method canon (on
  `main`; summarised inline in *Embedded verdict record* so this file stands alone).
- `governance/DIRECTIVE-BESTDEC-RATIFY-001.md` — Q1–Q5 APPROVED by operator + Central.
- `governance/novelty-pipeline-config.yaml` — activation pathway for numeric proposals.
- ADR-102 (Duplication Audit) — this finalization adheres (authoritative record embedded, not a
  pointer to a non-landing file); per-ADOPT DA required.
- ADR-103 (server-only refactoring) — each downstream ADOPT sprint gates through this.
- ADR-138 — PAYBIS white-label / distribution precedent (crypto custody) — model for §3 trading track.
- Handoff anchor `B-EMI-CREDIT-GATE-001` — **holds zero open credit items** after §2 (credit
  permanently out-of-scope, not licence-gated).
