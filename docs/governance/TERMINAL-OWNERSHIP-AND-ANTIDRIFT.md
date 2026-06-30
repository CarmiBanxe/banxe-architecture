# TERMINAL-OWNERSHIP & ANTI-DRIFT GOVERNANCE
# Date: 2026-06-30 | Owner: Central Terminal (governance, Intent-First P4)

## 1. Terminal model (canonical, 3 terminals)
- Terminal A (left) = Factory. Owns: agent-engine dossier, ENGINE-ROADMAP, GAP implementation, DRECON. Co-author: Claude Opus 4.8 (primary).
- Terminal B (right) = special tasks. Owns: legacy refactor, BANXE-TRADING-001, build-specs (IL-508..526).
- Central Terminal = governance + read-only diagnostics ONLY (Intent-First Canon P4: NO direct project mutations).
- Each terminal = Perplexity assistant (prepares shell/prompts) + Operator (manually enters into that terminal's Claude Code/shell).
- "Sub-Terminal-A" is NOT a separate terminal (legacy co-author tag of A).

## 2. Ownership & write-zones
- A writes: services/engine, docs/agent-engine-dossier.
- B writes: legacy/, trading/build-specs.
- Central writes: docs/governance only; read-only elsewhere.
- Every IL/PR tagged [OWNER: A|B|Central]. No two terminals mutate same file concurrently.

## 3. OPERATOR-DIRECTIVE SUPREMACY (anti-drift, binding)
- Active operator directive > factory GAP-queue.
- While an operator directive is active, Factory MUST NOT auto-start new GAP/PR/agents.
- Central never promotes factory output unrelated to the active directive; returns focus to directive.
- Each artifact declares: [relates to operator directive] OR [autonomous GAP].

## 4. DOC-SYNC GATE
- Any PR that changes runtime (removes NotImplementedError, deploys a service) MUST update EMI-IMPLEMENTATION-STATE + SPRINT-PLAN in the SAME PR.
- CI fails if code has 0 stubs but doc says SPEC-LOCKED.

## 5. LEDGER COUPLING (ADR-056/ADR-119)
- doc change + paired IL shard in SAME commit/PR (never split).
- IL number ONLY read back from IL-SEQUENCE.json after build_ledger.py (never hardcoded).
- Duplicate IL = rebase signal (parallel-session-isolation Rule 8).

## 6. MERGE DISCIPLINE
- All PRs target main (no feature-to-feature base) unless declared stacked.
- commit-log.jsonl via append-only mechanism, not feature branches (avoid dirty loops).

## 7. PRIVILEGED OPS REGISTRY (single owner = operator)
- Q-04, Q-08, B7 webhook, GitHub App, sudo: listed in CTIO-CARRY-FORWARD; terminals only PREPARE commands, operator executes.

## 8. MASTER-ROADMAP (single source, phases + owners)
- Phase 0: Intent-First Banking concept (INTENT-FIRST-CANON-2026-06-07) — DONE (canon) + runtime (safeguard/recon/aml = 0 stubs) — IMPLEMENTED.
- Phase 1: agent-engine adoption gate (5/5 L2) — finalize via regenerated PRs (A).
- Phase 2: doc-sync (SPRINT-PLAN §6/§7, EMI-IMPLEMENTATION-STATE) — close drift.
- Phase 3 (carry-forward): Q-AIO-03 migration (deadline 2026-07-24), B7/Q-08 (CTIO), Gap-018 Telegram.
