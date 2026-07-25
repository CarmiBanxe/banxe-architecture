# COMPANY REGISTRY — FACTORY — 2026-07-22 (revised 2026-07-23)

**COMPANY OWNERSHIP / FACTORY / DOCS-ONLY / READ-ONLY RUNTIME**

Factory company = `/home/mmber/factory`. Function: **build + quality-gate + canon-enforcement of bank code (including re-checking Claude Code output)**. Workers are **Claude-agents (`.claude/agents/*.md`) + quality-core + line-scripts, NOT `*_agent.py` personas**. `wt/agent-factory-*` = working branches producing the 86 bank agents. Verified read-only against `/home/mmber/factory` and `/home/mmber/wt`; write only to the architecture repo.

## Workers

| worker_id | name | source_path | type | function | company | status |
|---|---|---|---|---|---|---|
| FAC-01 | CanonGuardian | /home/mmber/factory/.claude/agents/canon-guardian.md | claude-agent | canon enforcement; no-silent-rewrite; audit freshness on PR | FACTORY | active |
| FAC-02 | Reviewer | /home/mmber/factory/.claude/agents/reviewer.md | claude-agent | quality review; self-critique + falsification before PASS | FACTORY | active |
| FAC-03 | FactoryWatchdog | /home/mmber/factory/quality-core/.claude/agents/factory-watchdog.md | claude-agent | quality-core watchdog | FACTORY | active |
| FAC-04 | SpecBuilder | /home/mmber/factory/scripts/spec-build.sh | script | build from spec | FACTORY | active |
| FAC-05 | CanonRollout | /home/mmber/factory/scripts/rollout-canon-to-repo.sh | script | roll canon out to a repo | FACTORY | active |
| FAC-06 | RolloutV2 | /home/mmber/factory/rollout-v2.sh | script | rollout v2 | FACTORY | active |
| FAC-07 | GuardianSecrets | /home/mmber/factory/set-guardian-secrets.sh | script | security (guardian secrets) | FACTORY | active |
| FAC-08 | UISync | /home/mmber/factory/ui-sync-core/proto-sync.py | module | UI proto sync | FACTORY | active |
| FAC-09 | Factory constitution | /home/mmber/factory/CANON.md | module (constitution) | GREEN/YELLOW/RED verdicts; enforcement levels | FACTORY | active |

(No `human_double` column — factory workers are automation roles, not SM&CR-gated bank personas; not applicable. Where a role has no human double → `-`.)

## Working branches

- **`wt/agent-factory-*` total: 23 branches** (verified present).
- **Production waves (13):** the `wave1…wave7` series — `wave1-green`, `wave1amber-reporting-analytics`, `wave1green-audit-reporting`, `wave1obs-observability`, `wave1red-audit-trail`, `wave2amber`, `wave2red`, `wave3all`, `wave3red`, `wave4norm`, `wave5aml`, `wave6pass`, `wave7redo` — the by-wave production lines that collectively produce the 86 bank agents.
- **Engineering / canon branches (10):** `agenteng03…09` (notation / runtime / framework / unknowns / matrix), `b3cm-s12-16`, `canon-best-decision-boundary`, `canon-delivery-stdin-paste`, `redgate-runtime-gate`, `watchdog-mvp-config`.
- **Branches with a complete 86-agent output:** `[pending: confirm which waves carry the full 86]` — not asserted per-branch without deeper read; the 86 are produced across the wave series collectively.

## Verdict

- **Factory is a separate company, not 0.** Roster = **9 records** (8 workers/tools + 1 constitution); headcount is non-zero (≥ 3 Claude-agent roles + line-scripts + UISync module).
- Factory workers are **automation / build / QA roles**, implemented as Claude-agents + scripts + modules — **not `*_agent.py` bank personas**.
- Factory workers **do NOT sit in bank rooms** and are **NOT part of the 129 bank agents** (BANK-MASTER). They are also distinct from ENGINE-MANUS and REPAIR-BRIGADE.
- The 86 bank agents living in `wt/agent-factory-*` are the factory's **product** (bank-owned output), not factory workers themselves.
- Company/legal characterisation of factory ownership beyond in-repo evidence remains `[counsel]`.

---
**This does not replace legal advice.**

## S-B0 addition — 2026-07-23 (dev-tooling agents, not bank)

Append-only. S-B0 spot-check surfaced dev/verification tooling agents in developer-core / vibe-coding — **factory dev-tooling, NOT bank agents** (not in the 129/132).

| worker_id | name | source_path | type | function | company | status |
|---|---|---|---|---|---|---|
| FAC-10 | PolicyAgent | developer-core|vibe-coding: compliance/verification policy_agent | dev-tooling | dev policy verification (dup in 2 repos) | FACTORY | `[factory dev-tooling, not bank]` |
| FAC-11 | WorkflowAgent | developer-core|vibe-coding: compliance/verification workflow_agent | dev-tooling | dev workflow verification (dup in 2 repos) | FACTORY | `[factory dev-tooling, not bank]` |
| FAC-12 | ReviewAgent | vibe-coding: review_agent (G-15 Multi-Agent Review, I-21/I-22) | dev-tooling | code reviewer | FACTORY | `[factory dev-tooling, not bank]` |

- **vibe-coding** as a whole = factory **dev/training pipeline** (Perplexity→Legion sync, train-agent.sh) — factory-related, **not** the bank engine, **not** Legion, **not** Banksy.
- **MiroFish `report_agent`** (ReportLogger) = app-logger → **out-of-bank app**, not a bank agent and not factory.
