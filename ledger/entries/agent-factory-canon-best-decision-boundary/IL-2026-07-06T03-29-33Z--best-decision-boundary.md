---
il_ts: 2026-07-06T03:29:33Z
session_id: agent-factory-canon-best-decision-boundary
source: CEO
status: PROPOSED
---
### BEST-DECISION-BOUNDARY.md — pointer-first canon drawing the orchestrator-vs-runtime decision boundary

- **Objective:** Author `docs/canon/BEST-DECISION-BOUNDARY.md` — a short, strict, additive canon doc that closes the audit finding: best-decision is already canon but scattered, runtime SOULs already encode fail-closed method, and the missing piece is one place that draws the boundary between (1) orchestrator/Factory best-decision and (2) runtime-agent fail-closed escalation.
- **The distinction (decisive):** best-decision (act on the best next step, no counter-question) is an **orchestrator/Factory** discipline for non-production, non-stop-barrier work; it is **NOT** a runtime-agent discipline. Every runtime L2+ agent on payment/compliance/KYC/AML must **fail-closed and escalate** — never best-decide to clear a sanctions hit, release a payment, self-escalate a level, or bypass a gate. On the compliance/payment contour, fail-closed **takes precedence** over best-decide. Conflating the two would be dangerous; this doc prevents that conflation.
- **Pointer-first (ADR-102):** repo-wide dedup ran (`git grep -il 'best.?decision|Best Single Artifact|Правило неоднозначности'`) — the principle already lives in CLAUDE.md §12, .claude/rules/approval-rules.md (§«Правило неоднозначности»), .claude/rules/agents.md (§"Best Single Artifact"; Ruflo/ARL; BUG-007), AGENTS.md, canon/rules/DIALOGUE.md. No pre-existing BEST-DECISION-BOUNDARY doc. **Decision: add net-new; reference, do NOT restate.** No merge/delete; no hidden consumer.
- **Additive only — nothing else touched:** does NOT modify `agents/souls/_TEMPLATE.md`, ADR-131, any SOUL, or any passport (a per-SOUL "decision-method" section is deliberately NOT added — the fail-closed method is already correctly encoded in Constraints/Escalation/HITL Workflow/Core Truths, and a dedicated best-decision section would wrongly imply runtime agents may best-decide on the compliance/payment contour). Any template-format change is separately, ratification-gated.
- **Precedence stated:** FCA/regulatory > Invariants I-01..I-28 > ADRs > quality gates > IL; best-decision never overrides a stop-barrier or a HITL gate — additive only.
- **Doc shape:** 6 sections (Purpose · Orchestrator scope · Runtime-agent scope · Where SOULs already encode it · Precedence · Anchors), 61 lines, concise/strict, no philosophy/TODOs/placeholders.
- **Perimeter / canon:** banxe-architecture only; isolated worktree off origin/main (ADR-120), not shared checkout; no TRADING-001 / agent/specproj/* (Rule 6); no secrets; no code/runtime change; NO passport/soul/template diff; signed; `--force-with-lease` only.
- **Deliverable:** `docs/canon/BEST-DECISION-BOUNDARY.md` + this IL shard. ONE Draft PR, prepare-only. IL frozen-at-merge (Rule 8); churn-resilient atomic mint.
- **Refs:** CLAUDE.md §12; .claude/rules/approval-rules.md; .claude/rules/agents.md (Best Single Artifact, Ruflo/ARL, BUG-007); AGENTS.md; canon/rules/DIALOGUE.md; .claude/rules/safety-rules.md (stop-barriers); I-27 (HITL-L4); ADR-102 (pointer-first / dup-audit); ADR-131 (SOUL format — unchanged); FACTORY-CANON.md (#1047, IL-932).
