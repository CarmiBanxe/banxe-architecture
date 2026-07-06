# BEST-DECISION-BOUNDARY — where best-decision applies, and where it must not

> Additive canon. It **references** the existing best-decision sources and does **not** restate them (ADR-102,
> pointer-first). It changes no SOUL, no passport, and not `agents/souls/_TEMPLATE.md` / ADR-131. It never
> overrides a stop-barrier or a HITL gate — additive only.

## 1. Purpose

Best-decision (act on the best next step without a counter-question) applies to the **orchestrator / Factory**
on non-production, non-stop-barrier work. It does **NOT** apply to **runtime agents** on the compliance/payment
contour, which **fail-closed and escalate**. This doc draws that one boundary; the mechanics live in the anchors.

## 2. Orchestrator scope (best-decide)

The Orchestrating Terminal / Factory chooses the best next step **autonomously** for work **outside** the auto-run
whitelist and **outside** stop-barriers, and continues **without a counter-question**. A counter-question is
permitted **only** at a real stop-barrier — data loss, irreversible action, invariant breach, or governance/HITL
risk — and then it **replaces** the action (no option-menus / "вариант 1 / вариант 2").

- Anchors: `CLAUDE.md` §12 · `.claude/rules/approval-rules.md` §«Правило неоднозначности» · `.claude/rules/agents.md` §"Best Single Artifact".

## 3. Runtime-agent scope (fail-closed, NOT best-decide)

Every **runtime L2+ agent** on **payment / compliance / KYC / AML** MUST **fail-closed and escalate** on
ambiguity. A runtime agent **NEVER**:

- best-decides to **clear a sanctions/PEP hit**,
- **releases a payment**,
- **self-escalates a level** (or lowers a confidence band), or
- **bypasses a gate** (`--no-verify`, skip-flag, silent retry).

This runtime rule is the **inverse** of §2 and **takes precedence on the compliance/payment contour**: where a
payment/compliance/KYC/AML decision is in doubt, fail-closed wins over best-decide.

- Anchors: **I-27** (HITL-L4) · **BUG-007** thresholds (AUTO >90 / REVIEW 70–90 / BLOCK <70) · **Ruflo / ARL**
  regulatory pre-gate (`.claude/rules/agents.md`).

## 4. Where SOULs already encode the method

Runtime SOULs already carry the fail-closed method — no dedicated "decision-method" section is added:

- **Constraints** — fail-closed on ambiguity; never bypass a gate.
- **Escalation** — trigger → named human/agent.
- **HITL Workflow** — agent proposes; the named human disposes.
- **Core Truths** — customer-fund / compliance decisions are human-gated; the agent never self-escalates a level.

`agents/souls/_TEMPLATE.md` and **ADR-131** remain **unchanged**; any template-format change is separately gated.

## 5. Precedence

FCA / regulatory obligations > Invariants **I-01..I-28** > **ADRs** > **quality gates** > **IL**.
**Best-decision never overrides a stop-barrier or a HITL gate — it is additive only.**

## 6. Anchors

- `CLAUDE.md` §12 (best-decision canon)
- `.claude/rules/approval-rules.md` (§«Правило неоднозначности»)
- `.claude/rules/agents.md` (§"Best Single Artifact"; Ruflo / ARL; BUG-007 HITL thresholds)
- `AGENTS.md` (§"CANON — Best Single Artifact")
- `canon/rules/DIALOGUE.md`
- `.claude/rules/safety-rules.md` (stop-barriers) · I-27 (HITL-L4)
