# ADR-044 — AI Pool Roadmap 2026-05-11

**Status:** Accepted (Steps 7–10 sanctioned by operator — see IL-135)
**Date:** 2026-05-11
**Accepted:** 2026-06-08
**Authors:** Banxe Sub-terminal A
**Invariants:** I-71, I-72, I-73, I-74
**Amendments:** amendment-30.N, amendment-B.11.N+2, amendment-2026-06-07 (ADR-051 hybrid coding-primary + ADR-052 enforcement runtime; see IL-131)

---

## Context

**Hardware pool — 256GB RAM total:**

| Node | RAM | Role |
|------|-----|------|
| Legion (WSL2) | 64GB | Dev workstation — Claude Code, LiteLLM router, OfficeCLI |
| evo1 | 128GB | On-prem AI master — Ollama `:11434`, Redis, business services |
| evo2 | 128GB | Production inference worker — RPC, large models, fraud classifier |

**EMI on-prem constraint:**
Banxe operates as an FCA-authorised EMI. All AI inference for regulated workloads
(KYC, AML, transaction screening, compliance reporting) MUST remain within the
on-prem perimeter (evo1/evo2). No regulated personal data may transit to external
API providers. This is binding under UK GDPR Art. 46 (data-residency) and FCA
PS25/12 (operational resilience / third-party risk).

**Current state (pre-roadmap):**
- evo1 Ollama running; Legion dev terminal active
- LiteLLM router not yet installed on Legion
- OfficeCLI not yet installed on Legion
- `docs/compliance/ai-data-flow.md` does not exist
- No normalised runbook for Legion LLM setup
- Qwen3:235b on evo2 runs at Q4_K_M; Q8_0 requantization not yet scheduled
- ZAYA1-8B and ZAYA1-74B evaluations pending

---

## Decision

Ten-step roadmap executed sequentially. Each step is a separate atomic action
(one branch, one PR, or one local-only operation per step).

| Step | Action | Scope | Target node |
|------|--------|-------|-------------|
| 1 | ADR fix — correct ADR number sequence collision | docs | banxe-architecture |
| 2 | AI pool audit — inventory models, VRAM, quantization state | audit | evo1, evo2 |
| 3 | Create `docs/compliance/ai-data-flow.md` | compliance | banxe-architecture |
| 4 | Redis cache integration in LiteLLM proxy on Legion | infra | Legion |
| 5 | OfficeCLI install on Legion under `~/banxe-dev/office-workspace` | infra | Legion |
| 6 | llm-router (LiteLLM proxy) install on Legion; evo1 priority-1, Anthropic fallback-only | infra | Legion |
| 7 | Controlled requantization of `qwen3:235b` Q4_K_M → Q8_0 on evo2 | model-ops | evo2 |
| 8 | `Qwen2.5-0.5B` fraud classifier deployment on evo2 | model-ops | evo2 |
| 9 | ZAYA1-8B Final — evaluation run and results logged | eval | evo1/evo2 |
| 10 | ZAYA1-74B Final — observation run under production conditions | eval | evo2 |

Steps 1–6 are safe (no production model mutation).
Steps 7–10 require explicit operator confirmation before execution.

---

## Consequences

### Compliance
- Steps 3 + 6 together close the gap on FCA PS25/12 data-residency documentation.
- Guardrail block (`/compliance/`, `/kyc/`, `/aml/` keywords) on LiteLLM proxy
  prevents regulated content from reaching Anthropic API under any fallback scenario.
- Steps 7–10 require pre-execution safety review: model mutation on evo2 production
  inference worker has direct impact on fraud classifier and live workloads.

### Performance
- Step 4 (Redis cache in LiteLLM) reduces repeated prompt latency on Legion by
  serving cached responses; does not affect evo1/evo2 load.
- Step 7 (Q8_0 requantization) increases model size ~2× but improves inference
  accuracy for compliance-sensitive tasks; evo2 128GB RAM is sufficient.
- Steps 9–10 (ZAYA1 evals) are read-only observations; no model weights modified.

### Ops risk
- Step 7 requires evo2 maintenance window: model swap is not hot-swappable in Ollama.
  Rolling back means re-pulling Q4_K_M. Estimated downtime: 15–30 min.
- Step 8 (fraud classifier) must not conflict with existing fraud scoring service
  on evo2. Requires port allocation review before deployment.
- All steps except 7–10 are reversible by uninstalling or reverting config.

---

## Invariants Referenced

| ID | Rule | Relevance |
|----|------|-----------|
| I-71 | Single-Writer Terminal Discipline | This ADR produced by sub-terminal; push/PR via main factory terminal only |
| I-72 | Parallel Session Halt Rule | Pre-flight check confirmed open PR #21 on `factory/ai-onboarding`; sub-terminal A is local-only |
| I-73 | Pre-flight Check Mandatory | Executed: `git fetch --all --prune`, HEAD verified at `1e8f8e9`, open PRs checked |
| I-74 | Atomic PR Lifecycle | Each roadmap step = one atomic PR; bypass-window for required-status-checks is main factory terminal only |

---

## Amendments Referenced

| Amendment | Clause | Effect on this ADR |
|-----------|--------|--------------------|
| amendment-30.N | Perplexity Relay Protocol §30.N.5 | Governance > operational; roadmap steps 7–10 require operator sign-off via relay |
| amendment-B.11.N+2 | Статья 2 (chain coordination) | Claude Code shell blocks coordinated through main factory terminal |
| amendment-B.11.N+2 | Статья 4 (T6 production-only restriction) | Steps 7–10 classified T6; require additional safeguards; not self-authorised by sub-terminal |

---

## Non-Goals (This ADR Cycle)

- **No push from sub-terminal A.** All commits in this worktree are handed off to main factory terminal for PR and merge.
- **No PR opened from sub-terminal A.** Violates I-71.
- **No production model mutation in this ADR cycle.** Steps 7–10 are roadmap items for future execution after operator confirmation.
- **No evo2 access from Legion.** Dev traffic must not reach `evo2:*` at any point during steps 1–6.
- **No scope expansion.** This ADR does not authorise any infrastructure change beyond what is listed in the 10-step table.


## Amendment 2026-06-07 (operator sanction; ADR-051 / ADR-052)

Per ADR-051 (Accepted, P0-A hybrid), the coding-primary policy is clarified: **local-first via LiteLLM for regulated workloads (KYC/AML/transactions)** to satisfy data-residency, with **Claude as fallback / non-regulated development only**. The local Legion/evo coder-stack is **retained** (not retired), consistent with this roadmap's hardware pool.

Per ADR-052 (Accepted), enforcement of this policy is bound by the Canon Enforcement Runtime: Canon Enforcer (I-76/I-77) + Enforcement Supervisor (I-78) as a dual-PASS, fail-closed CI gate, HITL override via I-27. `spec-build` routing through LiteLLM is mandatory; direct Anthropic calls bypassing the shim are a FAIL condition.

Ledger: IL-131.
