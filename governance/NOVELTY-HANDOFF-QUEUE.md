# NOVELTY-HANDOFF-QUEUE — Terminal A (Factory) Event Log

**Status:** PROPOSED (scaffolding — pipeline NOT activated)
**Owner:** Terminal A (Factory) — factory-watcher single-writer
**Consumer:** Central + operator (HITL merge gate)
**Append-only (I-24 / I-28).** No row edits. No row deletes. New event rows
appended at the bottom of the `## Entries` table by the factory-watcher only.
**ADR:** `docs/adr/ADR-159-ba-novelty-auto-handoff-pipeline.md` (Outcome-1
hand-off channel, D-1)
**Created:** 2026-07-05

---

## Purpose

A-owned append-only event log that records the **lifecycle of Terminal-B
findings** (Outcome-1 of the Terminal-B algorithm — a `status=NEW` row appended
to `governance/NOVELTY-COLLECTION-REGISTER.md`). Kept **separate** from:

- `governance/NOVELTY-COLLECTION-REGISTER.md` (B-owned finding registry —
  system-of-record for **what B has seen**);
- `governance/NOVELTY-COVERAGE-LOG.md` (B-owned coverage-confirmation log —
  Outcome-2 of the Terminal-B algorithm, proof-of-completeness).

The two-file split preserves append-only on **both** sides and the
ownership boundary (parallel-session-isolation Rules 1–7): B never writes
here; A never back-writes into B's register / coverage-log.

Per ADR-159 D-1: the **current state** of any given `finding-item` is the
**latest event row for that item** (state is derived from the log, not stored
as a mutable column elsewhere).

---

## Schema

Each row is one event. Columns:

| Column | Values | Notes |
|--------|--------|-------|
| `event` | monotonic integer | 1-based; increments per appended row across all items. |
| `finding-item` | slug | matches `item` column of `NOVELTY-COLLECTION-REGISTER.md`. |
| `status` | `picked` \| `planned` \| `sprint` \| `processed` | lifecycle stage (see below). |
| `roadmap-ref` | roadmap anchor \| `-` | link/anchor into `docs/ROADMAP-MATRIX.md` (added at `planned`). |
| `sprint-ref` | `Sprint <N>` / `IL-<NNN>` \| `-` | sprint/IL anchor (added at `sprint`). |
| `timestamp` | ISO8601Z UTC | append-time. |

**Lifecycle (per finding-item):**

```
NEW (register)
  -> picked   (factory-watcher picked up NEW row from register)
  -> planned  (roadmap update appended for the finding)
  -> sprint   (sprint-task entered; sprint-ref recorded)
  -> processed (draft-PR opened OR verdict=duplicate/failed — terminal for A)
```

`processed` is the **terminal** event for a finding-item on A-side.
Merge = HITL (operator) per CLAUDE.md §71 / ADR-156 — never appended here as
an event.

---

## Entries

| event | finding-item | status | roadmap-ref | sprint-ref | timestamp |
|-------|--------------|--------|-------------|------------|-----------|

<!-- APPEND-ONLY: rows appended below by scripts/novelty-watcher.sh only. -->
<!-- No rows yet — pipeline scaffolding is PROPOSED and not activated. -->

---

## Append Instructions (factory-watcher — single-writer)

**Only `scripts/novelty-watcher.sh` appends rows to this file.** No other
agent, workflow, or human process writes here. The pipeline-scaffolding
GitHub Actions workflow (`.github/workflows/novelty-handoff.yml`) is
**validator + detector only** — it never commits to this file.

Append discipline:

1. **Append at the bottom** of the `## Entries` table (never insert, never
   edit, never delete).
2. **Idempotent** — if the latest event for a given `finding-item` already
   matches the event about to be appended, skip.
3. **One event per row.** Never batch multiple events into a single row.
4. **Timestamp** — ISO8601Z UTC at append time.
5. **Ownership enforcement** — `.github/CODEOWNERS` restricts writes to
   `@mmber` (operator/HITL); the factory-watcher runs in a session that
   proposes changes via a PR, never direct-writes to `main`.

Cross-refs: ADR-159 §D-1 (channel), §D-5 (safety), `.claude/rules/parallel-session-isolation.md`
(Rules 1–7), CLAUDE.md §71 (operator-gated merge).
| 1 | deerflow-banking-orchestrator | picked | - | - | 2026-07-06T01:06:59Z |
| 2 | deerflow-banking-orchestrator | planned | roadmap:deerflow-banking-orchestrator | - | 2026-07-06T01:06:59Z |
| 3 | deerflow-banking-orchestrator | processed | roadmap:deerflow-banking-orchestrator | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 4 | agenticseek-privacy-first-agent | picked | - | - | 2026-07-06T01:06:59Z |
| 5 | agenticseek-privacy-first-agent | planned | roadmap:agenticseek-privacy-first-agent | - | 2026-07-06T01:06:59Z |
| 6 | agenticseek-privacy-first-agent | processed | roadmap:agenticseek-privacy-first-agent | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 7 | suna-self-hosted-manus-clone | picked | - | - | 2026-07-06T01:06:59Z |
| 8 | suna-self-hosted-manus-clone | planned | roadmap:suna-self-hosted-manus-clone | - | 2026-07-06T01:06:59Z |
| 9 | suna-self-hosted-manus-clone | processed | roadmap:suna-self-hosted-manus-clone | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 10 | nuformer-tx-embedding-model | picked | - | - | 2026-07-06T01:06:59Z |
| 11 | nuformer-tx-embedding-model | planned | roadmap:nuformer-tx-embedding-model | - | 2026-07-06T01:06:59Z |
| 12 | nuformer-tx-embedding-model | processed | roadmap:nuformer-tx-embedding-model | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 13 | transactiongpt-payments-llm | picked | - | - | 2026-07-06T01:06:59Z |
| 14 | transactiongpt-payments-llm | planned | roadmap:transactiongpt-payments-llm | - | 2026-07-06T01:06:59Z |
| 15 | transactiongpt-payments-llm | processed | roadmap:transactiongpt-payments-llm | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 16 | wechatpay-gpt-payments-llm | picked | - | - | 2026-07-06T01:06:59Z |
| 17 | wechatpay-gpt-payments-llm | planned | roadmap:wechatpay-gpt-payments-llm | - | 2026-07-06T01:06:59Z |
| 18 | wechatpay-gpt-payments-llm | processed | roadmap:wechatpay-gpt-payments-llm | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 19 | hgnn-heterogeneous-gnn-fraud | picked | - | - | 2026-07-06T01:06:59Z |
| 20 | hgnn-heterogeneous-gnn-fraud | planned | roadmap:hgnn-heterogeneous-gnn-fraud | - | 2026-07-06T01:06:59Z |
| 21 | hgnn-heterogeneous-gnn-fraud | processed | roadmap:hgnn-heterogeneous-gnn-fraud | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 22 | fraudgnn-rl-adaptive | picked | - | - | 2026-07-06T01:06:59Z |
| 23 | fraudgnn-rl-adaptive | planned | roadmap:fraudgnn-rl-adaptive | - | 2026-07-06T01:06:59Z |
| 24 | fraudgnn-rl-adaptive | processed | roadmap:fraudgnn-rl-adaptive | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 25 | asa-gnn-adversarial-safe | picked | - | - | 2026-07-06T01:06:59Z |
| 26 | asa-gnn-adversarial-safe | planned | roadmap:asa-gnn-adversarial-safe | - | 2026-07-06T01:06:59Z |
| 27 | asa-gnn-adversarial-safe | processed | roadmap:asa-gnn-adversarial-safe | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 28 | fate-federated-learning-webank | picked | - | - | 2026-07-06T01:06:59Z |
| 29 | fate-federated-learning-webank | planned | roadmap:fate-federated-learning-webank | - | 2026-07-06T01:06:59Z |
| 30 | fate-federated-learning-webank | processed | roadmap:fate-federated-learning-webank | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 31 | fedkt-federated-knowledge-transfer | picked | - | - | 2026-07-06T01:06:59Z |
| 32 | fedkt-federated-knowledge-transfer | planned | roadmap:fedkt-federated-knowledge-transfer | - | 2026-07-06T01:06:59Z |
| 33 | fedkt-federated-knowledge-transfer | processed | roadmap:fedkt-federated-knowledge-transfer | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 34 | vaultgemma-dp-private-llm | picked | - | - | 2026-07-06T01:06:59Z |
| 35 | vaultgemma-dp-private-llm | planned | roadmap:vaultgemma-dp-private-llm | - | 2026-07-06T01:06:59Z |
| 36 | vaultgemma-dp-private-llm | processed | roadmap:vaultgemma-dp-private-llm | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 37 | finrl-deepseek-rl-treasury | picked | - | - | 2026-07-06T01:06:59Z |
| 38 | finrl-deepseek-rl-treasury | planned | roadmap:finrl-deepseek-rl-treasury | - | 2026-07-06T01:06:59Z |
| 39 | finrl-deepseek-rl-treasury | processed | roadmap:finrl-deepseek-rl-treasury | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 40 | assistant-ui-agent-frontend | picked | - | - | 2026-07-06T01:06:59Z |
| 41 | assistant-ui-agent-frontend | planned | roadmap:assistant-ui-agent-frontend | - | 2026-07-06T01:06:59Z |
| 42 | assistant-ui-agent-frontend | processed | roadmap:assistant-ui-agent-frontend | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 43 | fisco-bcos-permissioned-ledger | picked | - | - | 2026-07-06T01:06:59Z |
| 44 | fisco-bcos-permissioned-ledger | planned | roadmap:fisco-bcos-permissioned-ledger | - | 2026-07-06T01:06:59Z |
| 45 | fisco-bcos-permissioned-ledger | processed | roadmap:fisco-bcos-permissioned-ledger | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 46 | strands-sdk-aws-agent-framework | picked | - | - | 2026-07-06T01:06:59Z |
| 47 | strands-sdk-aws-agent-framework | planned | roadmap:strands-sdk-aws-agent-framework | - | 2026-07-06T01:06:59Z |
| 48 | strands-sdk-aws-agent-framework | processed | roadmap:strands-sdk-aws-agent-framework | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 49 | sofastack-financial-cloud-antgroup | picked | - | - | 2026-07-06T01:06:59Z |
| 50 | sofastack-financial-cloud-antgroup | planned | roadmap:sofastack-financial-cloud-antgroup | - | 2026-07-06T01:06:59Z |
| 51 | sofastack-financial-cloud-antgroup | processed | roadmap:sofastack-financial-cloud-antgroup | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 52 | finrobot-fintech-multi-agent | picked | - | - | 2026-07-06T01:06:59Z |
| 53 | finrobot-fintech-multi-agent | planned | roadmap:finrobot-fintech-multi-agent | - | 2026-07-06T01:06:59Z |
| 54 | finrobot-fintech-multi-agent | processed | roadmap:finrobot-fintech-multi-agent | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 55 | finnlp-domain-nlp-toolkit | picked | - | - | 2026-07-06T01:06:59Z |
| 56 | finnlp-domain-nlp-toolkit | planned | roadmap:finnlp-domain-nlp-toolkit | - | 2026-07-06T01:06:59Z |
| 57 | finnlp-domain-nlp-toolkit | processed | roadmap:finnlp-domain-nlp-toolkit | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 58 | tradingagents-llm-multi-agent | picked | - | - | 2026-07-06T01:06:59Z |
| 59 | tradingagents-llm-multi-agent | planned | roadmap:tradingagents-llm-multi-agent | - | 2026-07-06T01:06:59Z |
| 60 | tradingagents-llm-multi-agent | processed | roadmap:tradingagents-llm-multi-agent | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 61 | qlib-quant-research-platform | picked | - | - | 2026-07-06T01:06:59Z |
| 62 | qlib-quant-research-platform | planned | roadmap:qlib-quant-research-platform | - | 2026-07-06T01:06:59Z |
| 63 | qlib-quant-research-platform | processed | roadmap:qlib-quant-research-platform | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 64 | owasp-llm-top10-supply-chain | picked | - | - | 2026-07-06T01:06:59Z |
| 65 | owasp-llm-top10-supply-chain | planned | roadmap:owasp-llm-top10-supply-chain | - | 2026-07-06T01:06:59Z |
| 66 | owasp-llm-top10-supply-chain | processed | roadmap:owasp-llm-top10-supply-chain | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 67 | nemo-guardrails-runtime-safety | picked | - | - | 2026-07-06T01:06:59Z |
| 68 | nemo-guardrails-runtime-safety | planned | roadmap:nemo-guardrails-runtime-safety | - | 2026-07-06T01:06:59Z |
| 69 | nemo-guardrails-runtime-safety | processed | roadmap:nemo-guardrails-runtime-safety | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 70 | lime-shap-hitl-explainability | picked | - | - | 2026-07-06T01:06:59Z |
| 71 | lime-shap-hitl-explainability | planned | roadmap:lime-shap-hitl-explainability | - | 2026-07-06T01:06:59Z |
| 72 | lime-shap-hitl-explainability | processed | roadmap:lime-shap-hitl-explainability | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 73 | github-agentic-workflows-ci | picked | - | - | 2026-07-06T01:06:59Z |
| 74 | github-agentic-workflows-ci | planned | roadmap:github-agentic-workflows-ci | - | 2026-07-06T01:06:59Z |
| 75 | github-agentic-workflows-ci | processed | roadmap:github-agentic-workflows-ci | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 76 | langfuse-llm-observability | picked | - | - | 2026-07-06T01:06:59Z |
| 77 | langfuse-llm-observability | planned | roadmap:langfuse-llm-observability | - | 2026-07-06T01:06:59Z |
| 78 | langfuse-llm-observability | processed | roadmap:langfuse-llm-observability | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 79 | memory-first-agent-architecture | picked | - | - | 2026-07-06T01:06:59Z |
| 80 | memory-first-agent-architecture | planned | roadmap:memory-first-agent-architecture | - | 2026-07-06T01:06:59Z |
| 81 | memory-first-agent-architecture | processed | roadmap:memory-first-agent-architecture | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 82 | fate-cross-bank-aml-consortium | picked | - | - | 2026-07-06T01:06:59Z |
| 83 | fate-cross-bank-aml-consortium | planned | roadmap:fate-cross-bank-aml-consortium | - | 2026-07-06T01:06:59Z |
| 84 | fate-cross-bank-aml-consortium | processed | roadmap:fate-cross-bank-aml-consortium | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 85 | quantum-gnn-fraud-research | picked | - | - | 2026-07-06T01:06:59Z |
| 86 | quantum-gnn-fraud-research | planned | roadmap:quantum-gnn-fraud-research | - | 2026-07-06T01:06:59Z |
| 87 | quantum-gnn-fraud-research | processed | roadmap:quantum-gnn-fraud-research | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
| 88 | temporal-knowledge-distillation-fraud | picked | - | - | 2026-07-06T01:06:59Z |
| 89 | temporal-knowledge-distillation-fraud | planned | roadmap:temporal-knowledge-distillation-fraud | - | 2026-07-06T01:06:59Z |
| 90 | temporal-knowledge-distillation-fraud | processed | roadmap:temporal-knowledge-distillation-fraud | TODO-sprint-v2 | 2026-07-06T01:06:59Z |
