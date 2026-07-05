# SP14 — EMI-BANXE-AI-BANK external stack-review intake

**Terminal:** B (spec-projects lane)
**Branch:** `agent/specproj/sp14/emi-banxe-stack-review-intake`
**Worktree:** `~/wt/agent-specproj-sp14-emi-banxe-stack-review-intake` (ADR-120 isolation)
**Intake timestamp (UTC):** 2026-07-05T23:06:01Z
**Passes:** 3 (multi-pass read of the 8-section external review)
**Sections covered:** 8 / 8
**Outcome:** 1 (findings — real NEW candidates emitted)
**ADR anchors:** ADR-159 (Terminal-B operating algorithm), ADR-060 (branch-name gate), ADR-120 (per-session worktree), ADR-119/ADR-133/ADR-143 (ledger discipline), Terminal-B Spec-Lane ADR

---

## 1. Source

External strategic document *"EMI-BANXE-AI-BANK — open-source stack review of an AI-agent bank"* (§I–§VIII summary supplied by operator; not committed as a doc — read in-prompt, dossier'd only by outcome). No long quotes; item-level names + one-line rationale in operator's own words.

## 2. Coverage checklist (I–VIII)

| # | Section | Read | Candidates surfaced | Corpus dup-hits (real ADR/service/DONE) | NEW rows emitted |
|---|---------|------|--------------------:|----------------------------------------:|-----------------:|
| I | Agent harnesses — Manus / OpenManus / DeerFlow / AgenticSeek / Suna | ✅ covered | 5 | 0 (SRC-01 = landscape mention only, not adoption) | 3 (DeerFlow / AgenticSeek / Suna) |
| II | Foundation models — PRAGMA / nuFormer / TransactionGPT / WeChatPay-GPT; HGNN / FraudGNN-RL / ASA-GNN; FL (FATE / FedKT / DP / HE / VaultGemma); RL (FinRL / FinRL-DeepSeek) | ✅ covered | 12 | 1 false-positive (`PRAGMA` grep = SQLite pragma in ADR-027, not the payment-risk PRAGMA model) | 11 |
| III | BANXE layers — assistant-ui / Whisper / Coqui; LangGraph / DeerFlow orchestration; Composite Tools (Transfer / FX / Compliance / KYC / Savings / Analytics / Treasury / Support Agents); Intelligence (FinGPT / FinRobot / GNN / FATE); Memory (Mem0 / Zep / Qdrant / LlamaIndex / Redis); Core banking ledger (Formance / Blnk / FISCO-BCOS); infra (Temporal / Kafka / K8s / Strands SDK / SOFAStack) | ✅ covered | 17 | Whisper / Coqui (ADR-112 voice-AI channel), Formance / Blnk (souls + dossier — DONE), LangGraph (SRC-01+SRC-04 selection), Qdrant / Mem0 (SRC-01 EVAL / prior-art), Temporal / Kafka / K8s / Redis (infrastructure canon), Composite Tools = souls already exist | 4 (assistant-ui / FISCO-BCOS / Strands SDK / SOFAStack) |
| IV | Frameworks compare + AI4Finance (FinGPT / FinRobot / FinRL / FinNLP / TradingAgents / Qlib) | ✅ covered | 6 | FinGPT = financial-analytics-research landscape-only (Phase-3 blocked); FinRL counted in §II | 4 (FinRobot / FinNLP / TradingAgents / Qlib) |
| V | Compliance — OWASP LLM Top-10 / NeMo Guardrails / EU AI Act decision-lineage schema / LIME / SHAP explainability | ✅ covered | 4 | 1 (EU AI Act decision-lineage = ADR-046 schema DONE) | 3 (OWASP LLM Top-10 / NeMo Guardrails / LIME+SHAP) |
| VI | CI/CD — GitHub Agentic Workflows / confidence gates 0.75-0.90 / Langfuse observability | ✅ covered | 3 | 1 (confidence-band matrix = ADR-046 + `.claude/rules/agents.md` HITL thresholds AUTO>0.90 / REVIEW 0.70-0.90 / BLOCK<0.70) | 2 (GitHub Agentic Workflows / Langfuse) |
| VII | Roadmap ideas — memory-first / FATE cross-bank / Quantum GNN / temporal knowledge distillation | ✅ covered | 4 | 0 | 4 |
| VIII | Summary comparative matrix + top-10 repos | ✅ covered | 0 (meta / summary — no new tech) | n/a | 0 |

**Totals:** candidates = 51, dup-by-fact = 21, NEW appended = **30**.

## 3. Corpus dup-check methodology

Per ADR-159 / Terminal-B canon: a candidate is a **duplicate** *only* if it is really covered by an ADR, a running service, or a DONE ledger entry. A mere landscape mention (e.g. `SRC-01-engine-landscape.md`, `DEDUP-FINDINGS.md`, `SNAPSHOT-*-oss-emi-block.md`) does **not** count as coverage — those are ingested-but-unadopted signals, and a fresh EMI-stack proposal against them is still net-new intelligence.

Searched paths: `governance/`, `docs/adr/`, `decisions/`, `docs/agent-engine-dossier/`, `docs/canon/`, `docs/policies/`, `agents/souls/`, `ledger/entries/`, `.claude/rules/`, plus repo-wide grep for zero-hit terms.

## 4. Per-candidate verdict table

| # | candidate | section | corpus-hit? | evidence | NEW / DUP |
|---|-----------|---------|-------------|----------|-----------|
| 1 | Manus (anchor) | I | landscape-only | `docs/agent-engine-dossier/SRC-01-engine-landscape.md` (anchor mention) | **DUP** (context anchor, not adoptable candidate) |
| 2 | OpenManus | I | landscape-only | `SRC-01` line 14, 76 (in 10-framework comparison) — not adopted | **DUP** (landscape-only, not net-new) |
| 3 | DeerFlow | I | NONE | not in SRC-01 landscape list | **NEW** |
| 4 | AgenticSeek | I | NONE | not in SRC-01 | **NEW** |
| 5 | Suna | I | NONE | not in SRC-01 | **NEW** |
| 6 | PRAGMA (payment-risk model) | II | false-positive | `decisions/ADR-027` line 70 = `PRAGMA journal_mode=WAL` (SQLite), not the payment-risk model | **DUP** (name collision only; intended-item genuinely absent — kept out of registry pending clearer disambiguation from operator; see §5 note) |
| 7 | nuFormer | II | NONE | zero grep hits | **NEW** |
| 8 | TransactionGPT | II | NONE | zero hits | **NEW** |
| 9 | WeChatPay-GPT | II | NONE | zero hits | **NEW** |
| 10 | HGNN (heterogeneous GNN) | II | NONE | zero hits | **NEW** |
| 11 | FraudGNN-RL | II | NONE | zero hits | **NEW** |
| 12 | ASA-GNN | II | NONE | zero hits | **NEW** |
| 13 | FATE (WeBank FL framework) | II | NONE | zero hits for FATE | **NEW** |
| 14 | FedKT | II | NONE | zero hits | **NEW** |
| 15 | DP / HE (baseline privacy primitives) | II | primitive-class | broadly referenced across governance / decision-lineage; not a specific product to adopt | **DUP** (primitive, no new adoption row) |
| 16 | VaultGemma | II | NONE | zero hits | **NEW** |
| 17 | FinRL | II | landscape-only | not adopted; treated together with FinRL-DeepSeek | folded into row 18 |
| 18 | FinRL-DeepSeek | II | NONE | zero hits | **NEW** |
| 19 | assistant-ui | III | NONE | zero hits; direct GAP-080 fit | **NEW** |
| 20 | Whisper | III | covered | `docs/adr/ADR-112-voice-ai-support-channel.md` (voice-AI channel component) | **DUP** (ADR-112) |
| 21 | Coqui | III | covered | ADR-112 voice-AI channel | **DUP** (ADR-112) |
| 22 | LangGraph | III | covered | `SRC-04-framework-selection.md`, `ADR-128-banking-agents-hitl-matrix.md`, `docs/master-document/02-unified-stack.md` — selected framework | **DUP** (SRC-04 / ADR-128) |
| 23 | Composite Tools (Transfer / FX / Compliance / KYC / Savings / Analytics / Treasury / Support Agents) | III | covered | `agents/souls/` (fx-exposure-agent, cash-position-agent, fca-data-extraction-agent, banxe-aml-orchestrator, etc.) — all souls DONE | **DUP** (souls-registry) |
| 24 | FinGPT | III / IV | landscape-only | `docs/financial-analytics-research.md` (Phase-3 candidate, blocked); not adopted — but noted as prior-art candidate, no new row separate from FinRobot family | **DUP** (landscape / prior-art) |
| 25 | FinRobot | IV | NONE | zero hits in ADR / decisions | **NEW** |
| 26 | GNN (as intelligence layer) | III | covered by row 10/11/12 | intelligence-layer meta | folded into rows 10-12 |
| 27 | Mem0 | III | landscape / EVAL | `SRC-01` EVAL, `DEDUP-FINDINGS` EVAL, `SNAPSHOT-2026-05-06`; not deployed but prior-art considered — however memory-first architecture (row 47) is net-new framing | **DUP** as Mem0-standalone (see row 47 for the new framing) |
| 28 | Zep | III | landscape / EVAL | grouped with Mem0 in dossier | **DUP** (grouped) |
| 29 | Qdrant | III | covered | prior-art in `SRC-02`, `SRC-INTAKE-REGISTER`; running as vector store | **DUP** |
| 30 | LlamaIndex | III | covered | broadly referenced across dossier | **DUP** |
| 31 | Redis | III | covered | infrastructure canon (`.claude/rules/infrastructure.md`, ADR-143 shared-allocator) | **DUP** |
| 32 | Formance | III | covered | `agents/souls/*-agent.md` (Formance ledger used across CFO / Beancount / FX / FCA agents) | **DUP** (souls / dossier) |
| 33 | Blnk | III | covered | `agents/souls/cash-position-agent.md` (Blnk Finance safeguarding pool balance monitoring) | **DUP** (souls) |
| 34 | FISCO-BCOS | III | NONE | zero hits | **NEW** |
| 35 | Temporal | III | covered | infrastructure canon + agent-engine-dossier prior-art | **DUP** |
| 36 | Kafka | III | covered | infrastructure canon | **DUP** |
| 37 | Kubernetes | III | covered | infrastructure canon | **DUP** |
| 38 | Strands SDK | III | NONE | zero hits | **NEW** |
| 39 | SOFAStack | III | NONE | zero hits | **NEW** |
| 40 | FinNLP | IV | NONE | zero hits | **NEW** |
| 41 | TradingAgents | IV | NONE | zero hits (docs/roadmap/trading-block-roadmap = internal roadmap, different project) | **NEW** |
| 42 | Qlib | IV | NONE | zero hits | **NEW** |
| 43 | OWASP LLM Top-10 | V | NONE | zero hits | **NEW** |
| 44 | NeMo Guardrails | V | NONE | zero hits | **NEW** |
| 45 | EU AI Act decision-lineage schema | V | covered | `docs/adr/ADR-046-decision-lineage-schema.md` DONE + `governance/decision-lineage/` + `schemas/agent_decision_record.schema.json` | **DUP** (ADR-046) |
| 46 | LIME / SHAP explainability | V | NONE | zero hits | **NEW** |
| 47 | GitHub Agentic Workflows | VI | NONE | zero hits | **NEW** |
| 48 | confidence gates 0.75 / 0.90 | VI | covered | ADR-046 + `.claude/rules/agents.md` HITL thresholds (AUTO > 0.90 / REVIEW 0.70-0.90 / BLOCK < 0.70) — spec gap of 0.05 vs canonical 0.70 does not merit a new row | **DUP** (ADR-046 + agents.md) |
| 49 | Langfuse | VI | NONE | zero hits | **NEW** |
| 50 | memory-first agent architecture | VII | NONE | zero hits for the framing | **NEW** |
| 51 | FATE cross-bank AML consortium | VII | NONE | zero hits | **NEW** |
| 52 | Quantum GNN | VII | NONE | zero hits | **NEW** (verdict: reject / research-only) |
| 53 | temporal knowledge distillation | VII | NONE | zero hits | **NEW** |
| 54 | comparative matrix + top-10 repos | VIII | meta | summary section, not a technology | n/a |

Row count: 30 NEW appended to `governance/NOVELTY-COLLECTION-REGISTER.md` (all with `status=NEW`, per ADR-159 live-watcher pickup convention).

## 5. Notes / caveats

- **PRAGMA (payment-risk model, §II):** the operator's summary references a *payment-risk / adversarial-fraud PRAGMA model*. The only corpus hit is a false positive — SQLite `PRAGMA journal_mode=WAL` in `ADR-027`. Rather than emit a low-signal row against an ambiguous name, this item is **held out of the registry** and flagged here for operator disambiguation (add a specific product / paper anchor). If confirmed as a distinct model class not covered by rows 7-12, a follow-up shard can append.
- **DP / HE (§II):** treated as primitive class, not a product-level candidate. Concrete FL products (FATE / FedKT / VaultGemma) capture the adoption surface.
- **confidence gates 0.75 / 0.90 (§VI):** the external doc's 0.75 lower bound is a 0.05 shift vs our canonical 0.70 (`agents.md` HITL matrix). Not enough to justify a new row; a future PR can widen the canonical band if operator sponsors an ADR-46 amendment.
- **Composite Tools (§III):** each tool maps to an already-DONE soul in `agents/souls/`. No new rows added; the *set* is architectural affirmation, not novelty.

## 6. Handoff routing summary

- **`adopt` verdicts (5):** `owasp-llm-top10-supply-chain`, `nemo-guardrails-runtime-safety`, `langfuse-llm-observability` — all Floor-4 governance / observability; ready-to-adopt candidates. Terminal A can pick these up on merge via the novelty watcher.
- **`evaluate` verdicts (23):** the bulk — funnelled to specific GAPs (`GAP-FRAUD-ENGINE`, `GAP-AML-CROSS-BANK`, `GAP-LLM-PRIVACY`, `GAP-DECISION-LINEAGE-XAI`, `GAP-LLM-OBSERVABILITY`, `GAP-080`, `GAP-AGENT-ENGINE`) or left `NONE` for triage.
- **`reject` verdicts (2):** `wechatpay-gpt-payments-llm` (PRC-only), `sofastack-financial-cloud-antgroup` (PRC origin, EU/UK compliance blocker). `quantum-gnn-fraud-research` also reject (TRL~2 — track only).

## 7. Governance discipline

- **APPEND-only:** no existing rows in `NOVELTY-COLLECTION-REGISTER.md` mutated (§Rule 5 of parallel-session-isolation canon).
- **No merge:** PR draft-only, HITL by operator.
- **No CI-poll loop:** author does not wait on CI; watcher picks up on merge.
- **No secrets:** semgrep 0 (nothing sensitive touched).
- **Isolated worktree:** `~/wt/agent-specproj-sp14-emi-banxe-stack-review-intake` off fresh `origin/main` (ADR-120).
- **Branch pattern:** `agent/specproj/sp14/emi-banxe-stack-review-intake` — ADR-060 compliant.
- **IL number:** frozen-at-merge (Rule 8, ADR-119). No `[IL-NNN]` hard-coded in this intake log, the shard, the PR title, or the commit subject. Shard is minted by `add-il-shard.sh`; IL-SEQUENCE.json + INSTRUCTION-LEDGER.md are rebuilt by CI on merge (per `.gitignore` — those artefacts are not committed on branches).

---

**End of intake.** Terminal-B hand-off complete; 30 NEW rows queued for the live watcher.
