---
id: ADR-FUSION-01
title: MoA Judge + Synthesizer layer over openclo-moa (OpenRouter-Fusion-style)
status: PROPOSED
date: 2026-06-16
accepted: null
supersedes: []
extends:
  - ".claude/agents/openclo.md (openclo-moa subagent — NOT edited by this ADR)"
  - ".claude/rules/agents.md (gateway-moa MoA canon — NOT edited by this ADR)"
related:
  - "ADR-046-decision-lineage-schema.md (AgentDecisionRecord — one per fusion call)"
  - "ADR-047-ai-cost-governance-policy.md (per-request token caps across N calls + judge + synth)"
  - "ADR-048-business-process-repository.md (process_ref on the lineage record)"
  - "ADR-043-aider-routes.md (LiteLLM routes — no new route added)"
  - "ADR-RUFLO-01-dual-role.md (Ruflo mandatory post-step on regulated routes)"
  - "INVARIANTS.md I-37 (production traffic via :4000 only)"
  - ".claude/rules/agents.md AGENT_ROUTING_ENABLED gate"
il_anchor: IL-252
numeric_alias: ADR-105 (reservable; ADR-104 reserved for ADR-RUFLO-01)
scope: BANXE-only
concept_only: true
---

# ADR-FUSION-01: MoA Judge + Synthesizer layer over openclo-moa

**Status:** PROPOSED / DRAFT — **NOT ACCEPTED.** All build/activation steps are **GATED**
(WG/CEO acceptance + Terminal-A infra). This ADR is the F-MOA-1 spec artifact only.

## Context

`openclo-moa` (`.claude/agents/openclo.md`) already fans out an ensemble — `project-mid` +
`project-heavy` + `project-reason` — with a **majority vote** (design-draft, pending WG). It has
**no quality-ranking judge** and produces **no single synthesized answer**. An
OpenRouter-Fusion-style "MoA judge + synthesizer" adds exactly those two missing stages.

This is an **EXTENSION of existing canon, NOT a greenfield system and NOT a new agent.** A
repo-wide check (ADR-102 duplication audit, below) confirms the routing aliases, cost/lineage
schemas, and the Ruflo pipeline rule all already exist and are reused, not duplicated.

> **External claims are non-load-bearing.** Any OpenRouter-Fusion / MoA accuracy-uplift,
> benchmark, or divergence-rate figures from external sources are **[НЕИЗВЕСТНО] /
> needs-independent-verification** and are NOT used to justify this decision. The decision rests
> only on the in-repo gap (no judge, no fused answer) and existing canon.

## Decision

Add two **post-ensemble stages on `openclo-moa`** (not a new subagent):

**(a) Judge + Synthesizer.**
- **Judge** — scores the N candidate ensemble outputs (quality ranking).
- **Synthesizer** — emits one fused answer from the ranked candidates.

**(b) Production on `:4000` only (I-37).** Candidates reuse existing aliases
`factory-mid` + `factory-heavy` + `project-reason`; **judge = `project-reason`** (heaviest). All
production inference stays on factory LiteLLM **:4000** per I-37. **No new LiteLLM route is added**
(ADR-043 unchanged).

**(c) Ruflo MANDATORY post-step.** Any payment/compliance/kyc-adjacent fused output passes Ruflo
**after** synthesis and **before** return, per ADR-RUFLO-01 (Regulated Route Checkpoint):

```
client → LiteLLM v2 (:4000) → ARL → ensemble → judge → synthesizer
       → Ruflo (regulatory check) → response (+ audit metadata)
```

Plus HITL bands (BUG-007): **>90% AUTO / 70–90% REVIEW / <70% BLOCK** on the fused confidence.
Skipping Ruflo on regulated output = potential FCA violation.

**(d) Cost + lineage binding (no new schema).**
- **ADR-047:** one **per-request token cap** covers all **N candidate calls + judge + synthesizer**
  as a single budgeted unit, enforced at the LiteLLM (ADR-043) seam.
- **ADR-046:** exactly **one `AgentDecisionRecord` per fusion call** (candidates, judge scores,
  chosen synthesis, Ruflo verdict, total cost).
- **ADR-048:** that record carries `process_ref` to the resolved business process.

**(e) Activation gate.** Stays **`AGENT_ROUTING_ENABLED=false`** and Terminal-A-infra gated like
every L2 agent. No production traffic until all four `agents.md` enable-conditions pass.

**(f) Sandbox-first.** Prototype only on the **Innovation Sandbox `:8080` (PR #277)** contour
first; promote to `:4000` only after WG sign-off.

## Sprints (all build steps GATED)

- **F-MOA-1 — ADR + spec (this document).** Output = docs only. **[GATED: WG/CEO accept]**
- **F-MOA-2 — judge/synth sandbox prototype.** Build judge + synthesizer on `:8080` (PR #277),
  reusing aliases; measure divergence-rate. **[GATED: sandbox-only, no :4000, no prod data]**
- **F-MOA-3 — spec-build pipeline integration.** Wire into spec-build + **mandatory Ruflo post-step**
  + **divergence-rate risk metric** as a release gate. **[GATED: AGENT_ROUTING_ENABLED conditions +
  MLRO/HITL + I-37 :4000 promotion]**

## Consequences

- Gives openclo-moa a quality-ranking judge and a single fused answer it currently lacks.
- No new agent, no new LiteLLM route, no new lineage/cost schema — pure extension.
- Risks: judge-vs-ensemble **divergence-rate** (tracked metric); cost blow-up across N+judge+synth
  (capped by ADR-047); Ruflo-bypass on synthesized output (forbidden — mandatory post-step).
  External benchmark claims unverified **[НЕИЗВЕСТНО]**.

## Explicitly GATED / out of scope (NOT done by this ADR)

- **Enabling `AGENT_ROUTING_ENABLED`** — stays `false`. **[GATED]**
- **Editing `.claude/agents/openclo.md` or `.claude/rules/agents.md`.** **[GATED — post WG accept]**
- **Creating `services/arl` or any LiteLLM route.** **[GATED — Terminal-A infra]**
- **Opening any port / deploying anything.** **[GATED]**

## Duplication Audit (ADR-102)

Repo-wide search of the targets:

| Target | Source of truth | Decision |
|---|---|---|
| MoA agent | `.claude/agents/openclo.md` (openclo-moa), `agents.md` gateway-moa | **keep/extend** (add stages, no new agent) |
| Routing aliases | `factory-mid`/`factory-heavy`/`project-reason` (agents.md, ADR-043) | **keep** (reuse, no new route) |
| Lineage | ADR-046 `AgentDecisionRecord` | **keep** (one record per fusion call) |
| Cost caps | ADR-047 | **keep** (one cap across N+judge+synth) |
| process_ref | ADR-048 | **keep** |
| Ruflo pipeline | ADR-RUFLO-01 / agents.md mandatory-middleware | **keep** (mandatory post-step) |

No merge/delete required; all matches resolve to **keep/extend**. No hidden consumer touched.

## References

- `.claude/agents/openclo.md`; `.claude/rules/agents.md` (gateway-moa, ARL pipeline, AGENT_ROUTING_ENABLED gate)
- ADR-046 / ADR-047 / ADR-048 / ADR-043 / ADR-RUFLO-01; INVARIANTS I-37
- INSTRUCTION-LEDGER.md (openclo-moa design-draft, majority-vote ensemble); PR #277 (Innovation Sandbox :8080)
