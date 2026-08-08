---
id: ADR-135
title: Agent-skill evolution gate — held-out validation (propose-and-test) for SOUL/skill edits, SkillOpt pattern adapted
status: PROPOSED
date: 2026-06-26
accepted:
supersedes: []
relates:
  - "ADR-130 (SOUL.md persona layer — the editable skill-document this gate governs; KEEP, cross-link)"
  - "ADR-131 (souls-format standard — the 11-section format an evolved skill must still satisfy; KEEP, cross-link)"
  - "ADR-117 (factory/project perimeter — evolution runs factory-side only)"
  - "ADR-119 (IL numbering — this ADR's own IL is provisional per Rule 8)"
  - "ADR-126 (Hermes Tier-1 — 'self-improving skills' reference; bounded here, not activated)"
  - "ADR-128 (HITL L1/L2/L3 authority matrix — the gate's human-oversight ladder)"
  - "research artifact Hermes-Agent-Razbor-…-Software-Factory.md (self-improving skills — external reference)"
  - "SkillOpt (MIT, github.com/microsoft/SkillOpt) — external reference pattern (propose-and-test, textual learning rate); referenced, NOT imported"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
amended_by:
  - "ADR-135-A (MemoHarness harness-loop amendment, merged #1199, f9e90d42)"
il_anchor: IL-559
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
scope: BANXE-factory-only
concept_only: true
---

# ADR-135 — Agent-skill evolution gate (held-out validation, propose-and-test)

## Context

An agent's skill documents (`SOUL.md` per ADR-130; the `agents/souls/*` format per ADR-131) are the
**learnable state of an otherwise frozen agent** — they encode identity, boundaries, memory policy and
expertise that shape behaviour without retraining weights. Today there is **no safe mechanism to evolve
them**: an edit to a soul/skill can silently regress behaviour (drop a boundary, broaden authority,
degrade a workflow) with no objective check. The external **SkillOpt** pattern (MIT,
`github.com/microsoft/SkillOpt`) and the Hermes "self-improving skills" idea (ADR-126) both show a
disciplined shape — **propose a bounded edit, then accept it only if it measurably improves on a
held-out set** — that BANXE can adapt as a *gate*, without importing code and without activating any
runtime self-modification.

This ADR records the **gate as canon** so any future skill-evolution work is pre-bounded. It introduces
**no runtime code, no secrets, no `.env`** — activation (an actual evolution loop) is a separate, gated
work item.

## Decision

**A candidate skill/SOUL edit is accepted ONLY through a held-out validation gate (propose-and-test);
edits are bounded by an explicit budget; nothing self-modifies in production.** The cycle:

1. **Rollout** — run the current (frozen) skill on a representative task set; record behaviour/metrics.
2. **Reflect** — derive a *candidate* edit from observed failures/gaps (a proposal, not an applied change).
3. **Bounded edit** — apply the candidate within a **budget** (a "textual learning rate": a capped
   number/size of changed lines/sections per round) so a single round cannot rewrite the persona
   wholesale. The edit MUST still satisfy the ADR-131 11-section format and MUST NOT add authority
   (ADR-130: a soul may narrow/describe, never expand).
4. **HELD-OUT VALIDATION GATE** — evaluate the candidate on a **held-out** set disjoint from the
   reflect/rollout inputs. **Accept iff it strictly improves** the agreed metric on held-out (no
   regression on boundary/safety checks). Otherwise **reject** (fail-closed) and keep the frozen skill.

The gate is the binding rule: no skill edit reaches an agent without a held-out improvement.

## HITL / boundaries (fail-closed)

- **Autonomous skill evolution is an L2/L3 action** under the ADR-128 HITL authority matrix — it is
  **never L1/auto**. A candidate that passes held-out still requires the L2/L3 human disposition for
  its domain before it is adopted.
- **RED zone is forbidden by default.** For payment-core, KYC/AML, sanctions, or ledger skills,
  autonomous evolution is **prohibited without a separate ADR + operator approval + IronClaw
  (security-review) sign-off**. The held-out gate alone is insufficient there.
- **No authority expansion, ever** — an evolved skill cannot grant merge/deploy/payment/AML rights
  (subordinate to ADR-130/117/127); the format gate (ADR-131) and perimeter (ADR-117) still bind.
- **Fail-closed** — ambiguous held-out result, missing held-out set, or budget overflow ⇒ reject and
  escalate; never adopt on uncertainty. Held-out data is operator-curated; the agent does not author
  its own test set.

## Duplication Audit (ADR-102)

1. **Repo-wide search** — **NO_EXISTING_SKILL_EVOLUTION_CANON**: `docs/adr/` has no skill-evolution /
   SkillOpt / propose-and-test / held-out-gate ADR (grep over `origin/main docs/adr/` = none). Adjacent
   docs (`docs/audit/condition-c-evaluation-protocol-*`, `docs/canon/software-factory-canon-v1.md`)
   touch evaluation generally but define **no** skill-evolution gate — not duplicates.
2. **Source-of-truth + consumers.** Skill documents stay owned by ADR-130 (persona) + ADR-131 (format),
   unchanged; this ADR adds a *gate* over edits to them — a new governance layer, not a rewrite.
3. **No hidden dependencies / no import.** SkillOpt and Hermes are **external references only**; no code,
   plugin, or dataset is imported. No existing ADR/soul/skill is edited.
4. **Decision per match:** ADR-130/131 → **KEEP + cross-link**; ADR-135 → **ADD** (new canon, no prior
   skill-evolution ADR). No delete, no merge, no parallel duplicate.

## Consequences

- Skill/SOUL evolution gains a **pre-bounded, gated** mechanism: bounded edits + held-out acceptance +
  L2/L3 HITL + RED-zone prohibition — so any future "improve a skill" work starts inside canon.
- Regressions are structurally prevented: an edit that does not strictly improve held-out is rejected,
  fail-closed; authority can never widen via evolution.
- **No runtime change.** Activating an actual evolution loop (the rollout/reflect/edit machinery,
  held-out harness, metrics) is a **separate, gated work item** — out of scope here (concept-only).

## Anchors

- ADR-130 (SOUL persona layer), ADR-131 (souls-format) — KEEP, cross-linked; ADR-117 (perimeter),
  ADR-119 (provisional IL), ADR-126 (Hermes self-improving-skills ref), ADR-128 (HITL matrix),
  ADR-102 (Duplication Audit = NO_EXISTING_SKILL_EVOLUTION_CANON).
- External references (not imported): SkillOpt (MIT, `github.com/microsoft/SkillOpt`); Hermes research
  artifact (self-improving skills). Enforcement = the held-out gate + HITL; no runtime in this ADR.
