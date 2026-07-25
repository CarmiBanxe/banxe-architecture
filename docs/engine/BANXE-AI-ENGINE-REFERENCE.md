# BANXE-AI-ENGINE-REFERENCE.md — 7-Layer Architecture + Agent Registry (canonical)

> **STATUS: PROPOSED / no activation.** ENGREF01, 2026-07-26.
> **Source-of-truth declaration (ADR-171 §Duplication Audit):** this file supersedes
> `~/banxe-dev/emi-banxe-engine.md` (non-repo location, uncommittable) as the canonical engine
> reference and the **single Agent Registry**. The banxe-dev copy is legacy input — do not evolve it.
> Companion: `BANXE-ENGINE-MATH.md`, `BANXE-SECURITY-OWASP.md`, `../../roadmap/BANXE-E0-E6.md`, ADR-171.

## 1. 7-layer target architecture (top→bottom)

| Layer | Components | Notes |
|---|---|---|
| **L7 UX/UI** | assistant-ui (React), Whisper STT, Coqui TTS, Rich Cards, SCA (FaceID/TouchID) | dovetails ADR-167 (intent-first) + BANXE-UI-* canon; Rich Card = UI form of propose-only |
| **L6 Orchestration** | LangGraph StateGraph (real-time <300ms) + DeerFlow 2.0 (long-horizon) + Strands SDK (MCP-native prod candidate) | routing rule: interactive→LangGraph; deep-research/report→DeerFlow |
| **L5 Agents** | Transfer, FX, Savings, Compliance, Analytics, KYC, Support, Treasury | composite tools > raw LLM (Nubank lesson); registry §2 |
| **L4 Intelligence** | PRAGMA-style encoder, FinGPT/FinRobot, GNN fraud (HGNN), FATE FL, VaultGemma | **hybrid engine: LLM for dialogue/reasoning, classical ML (LightGBM/XGBoost/GNN) for fraud/scoring** |
| **L3 Memory** | Mem0, Zep (temporal KG), Qdrant (Rust, sub-ms), LlamaIndex RAG, Redis | memory types episodic/semantic/working/procedural; PII-scoped |
| **L2 Ledger** | **canonical: Midaz PRIMARY / Fineract FALLBACK (ADR-013) behind LedgerPort (I-28)**; engine-reference candidates Formance (MIT, Go), Blnk, FISCO BCOS (~5000 TPS audit) — candidates ONLY via LedgerPort | no second ledger (ADR-102); no rewiring without dedicated ADR |
| **L1 Infra** | Temporal, Kafka, Kubernetes (GKE/EKS), Strands SDK (AWS), SOFAStack patterns (circuit-breaker / bulkhead / distributed-txn) | Temporal/Kafka already in FinDev P1 matrix |

Cross-cutting (not a layer): L0 policy/guardrails (NeMo Guardrails, policy-as-code) and L5-observability
(Langfuse + OpenTelemetry, ADR-168) wrap all layers.

## 2. Agent Registry (single registry — extended)

> Existing entries (Transfer + Compliance-gate) carried over from the legacy engine doc; six added per
> engine reference block B. **Model bindings are LiteLLM aliases ONLY** (OP-M2 resolved): the canonical
> alias set lives in `.claude/rules/agents.md` §Agent-to-LiteLLM-route mapping; hardcoded vendor model
> names from analytics are non-normative and MUST NOT enter code.

| Agent | Tools | LiteLLM route (proposed) | Notes |
|---|---|---|---|
| TransferAgent *(existing)* | validate_recipient, get_fx_rate, execute_transfer, send_receipt | `factory-heavy` (interactive) | execute_* = propose-only + SCA + HITL; E1 candidate |
| ComplianceAgent *(existing gate, extended)* | run_kyc_check, screen_aml, log_decision, explain_decision | `project-reason` | FATE federated model for scoring; mandatory Ruflo/ARL pipeline for payment/compliance/kyc stands |
| FXAgent *(new)* | get_live_rates, compare_rails, execute_fx, schedule_fx | `factory-mid` | WeLab Best-Rate pattern; execute/schedule gated as Transfer |
| SavingsAgent *(new)* | create_pocket, suggest_goal, calc_projection, auto_sweep | `factory-mid` | auto_sweep = state-changing → gated |
| AnalyticsAgent *(new)* | get_spending, categorize, generate_insight, create_chart | `factory-mid` | PRAGMA-style embeddings; advisory-only (wave-friendly) |
| TreasuryAgent *(new)* | get_positions, rebalance_portfolio, hedge_fx_exposure | `project-reason` | FinRL track; SME/B2B focus |
| KYCAgent *(new)* | doc pipeline via KYCProviderPort (startSession/getStatus/handleWebhook/changeLevel) | `factory-heavy` | does NOT reimplement the port (ADR-102 REUSE); long-horizon doc analysis → DeerFlow harness |
| SupportAgent *(new)* | episodic case memory, escalation ladder, human-handoff | `factory-fast` | human support ALWAYS visible (H10 rule) |

Registry rules (binding): every agent = passport + SOUL per existing governance (PASSPORT > SOUL);
least-privilege per tool (KYC agent never touches ledger postings and vice versa); all state-changing
tools are propose-only until Promotion Gate; per-case budget caps come from the ADR-030 runtime_gate
contour (foreign track — cross-ref only).

## 3. Engine mechanics adopted (summary — details in companion docs)

- Orchestration patterns: supervisor/hierarchical, planner→executor, blackboard/shared-state (append-only
  audit), router, reflection/critic, HITL checkpoints.
- Tool-use discipline: strict schemas + validation; idempotency + saga compensation; dry-run/propose-only
  default for ALL L5/L2-domain agents; least-privilege per tool.
- Guardrails: input/output/action, policy-as-code (see BANXE-SECURITY-OWASP.md).
- Observability: trace-driven eval, online scorecards, replay/time-travel (Langfuse, ADR-168);
  reproducibility: seed/temperature control where the runtime allows ("reproducible enough for audit").
- Evals-first: LLM-as-judge + golden datasets + simulation + canary/shadow; anchors 57%/80% (see MATH §10).
- Prompt-as-versioned-artifact: modules Tone/Tooling/Safety (Nubank PSV); tooling choice = OP-J2.

---
*ENGREF01 | 2026-07-26 | PROPOSED, no activation. Extraction 100% per rebuilt v2 block O.*
