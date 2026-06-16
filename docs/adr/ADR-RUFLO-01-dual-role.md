---
id: ADR-RUFLO-01
title: Ruflo dual-role — Internal Review Agent + Regulated Route Checkpoint (FA-3 ↔ §0.5 reconciliation)
status: PROPOSED
date: 2026-06-16
accepted: null
supersedes: []
related:
  - "IL-FA-03-CLOSE (Ruflo identity reclassified as in-fleet Review Agent, not PATH binary)"
  - "IL-CANON-RUFLO-2026-05-06 (Ruflo Review Agent canonical placement in orchestration)"
  - ".claude/rules/agents.md (agent matrix + ARL pipeline canon — NOT edited by this ADR)"
  - "INVARIANTS.md I-32/I-33/I-37 (distribution discipline, regulated-route binding)"
  - "ROADMAP.md Phase F1 (Ruflo deployment — gated downstream)"
il_anchor: IL-252
numeric_alias: ADR-104 (reservable if WG prefers a numbered slot)
scope: BANXE-only
concept_only: true
---

# ADR-RUFLO-01: Ruflo dual-role (Internal Review Agent + Regulated Route Checkpoint)

**Status:** PROPOSED / DRAFT — **NOT ACCEPTED.**
Requires **WG confirmation + CEO ratification** (INVARIANTS:249 — §0.5/§1.bis binding is
"PROPOSED — требует явного утверждения CEO") **before** any `.claude/rules/agents.md` change,
before flipping the ledger reconciliation status to CONFIRMED, and before Phase F1.

## Context

A long-standing Phase-F1 blocker pits two canon statements against each other:

- **FA-3** (IL-FA-03-CLOSE, PR #83) reclassified Ruflo as an **in-fleet Review Agent** — a Claude
  Code subagent / role in the agent fleet, **not** a standalone on-PATH CLI binary. FA-3's own
  closure text states "no canon principle changed; pure clarification that Ruflo is in-fleet, not
  on-PATH."
- **§0.5 / §1.bis** (bootstrap canon v3): "Distribution discipline: cross-layer ONLY via LiteLLM
  gateway + **Ruflo for regulated**" — i.e. Ruflo is **MANDATORY middleware** on every regulated
  route (payment / compliance / kyc).

These were logged as CONFLICT (ROADMAP:510), blocking `G-FACTORY-RUFLO-NOT-DEPLOYED` (P0).

**Root cause = category error.** FA-3 governs Ruflo's **identity** (in-fleet vs on-PATH); §0.5
governs Ruflo's **placement** (mandatory vs optional on regulated routes). These are orthogonal
axes, so the two statements are **reconcilable, not contradictory**.

## Decision

Ruflo is a **dual-role** agent — one agent, two hats, non-contradictory:

1. **Internal Review Agent** (FA-3 identity): review/audit role across swarms; a Claude Code
   subagent, not a PATH binary. Produces review reports (evidence: `docs/reviews/IL-008-review.md`).
2. **Regulated Route Checkpoint** (§0.5/§1.bis placement): **MANDATORY** review/audit checkpoint
   on every regulated route, between the ARL and the target agent.

Canonical regulated chain:

```
client → LiteLLM v2 (Legion :4000) → ARL (Anti-Run-Loop check)
       → Ruflo (review/audit checkpoint, per FA-3 reclassification)
       → target agent (project-* aliases)
       → response (+ Ruflo audit metadata appended)
```

Both **FA-3** (identity preserved) and **§0.5/§1.bis** (mandatory placement preserved) are
satisfied. This mirrors the drafted reconciliation already in the ledger
(INSTRUCTION-LEDGER.md:6934-6935).

## Consequences

- Codifies the dual-role classification as a durable decision record (vs a ledger-only draft).
- The ledger reconciliation status flips `CONFLICT → RECONCILED` **only AFTER WG confirmation** —
  **this ADR does not flip it** (stays `RECONCILED-DUAL-ROLE-DRAFTED-PENDING-WG-CONFIRMATION`).
- On ratification, `.claude/rules/agents.md` would be updated to state the dual-role explicitly —
  **not done in this ADR** (out of scope; agents.md untouched here).
- Resolving the classification only **opens the decision gate** in front of Phase F1; it does not
  itself deploy or enable anything.

## Explicitly GATED / out of scope (NOT done by this ADR)

- **Enabling `AGENT_ROUTING_ENABLED`** — stays `false`; the four enable-conditions are unmet. **[GATED]**
- **Deploying Ruflo** (Phase F1: Legion infra, LiteLLM project-mid/heavy/reason proxy chain,
  end-to-end regulated-flow verify, close `G-FACTORY-RUFLO-NOT-DEPLOYED`). **[GATED — Terminal-A infra]**
- **Standing up `services/arl`** or the LiteLLM proxy chain. **[GATED — Terminal-A infra]**
- **Editing `.claude/rules/agents.md`.** **[GATED — post WG-confirm + CEO ratify]**

## References

- IL-FA-03-CLOSE (Ruflo identity); IL-CANON-RUFLO-2026-05-06 (placement)
- bootstrap canon v3 §0.5 / §1.bis; INVARIANTS I-32 / I-33 / I-37
- INSTRUCTION-LEDGER.md:6934-6935 (drafted dual-role); ROADMAP.md Phase F1
- `.claude/rules/agents.md` ARL pipeline canon + `AGENT_ROUTING_ENABLED` gate (agents.md:133)
