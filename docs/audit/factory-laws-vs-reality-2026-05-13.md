# Factory Laws vs Reality — Finding 2026-05-13

Document ID: FINDING-FACTORY-LAWS-VS-REALITY-2026-05-13
Trigger: operator request to audit factory orchestration and identify
its development laws separate from banking functions.

## Sources read

1. ~/.claude/rules/agents.md (6 chains A-F, agent-to-LiteLLM mapping)
2. ~/developer/AGENTS.md (Four-Partner Swarm v2.0 canon)
3. ~/banxe-architecture/COMPOSABLE-ARCH.md (6 contours, Contour 6 = training)
4. ~/banxe-architecture/docs/SKILLS-MATRIX.md (10 skills x 3 planes)
5. ~/banxe-architecture/docs/SKILLS-OPERATING-MODEL.md (invocation, precedence, hooks)
6. ~/.claude/rules/COLLABORATION.md (Claude Code vs Aider roles)

## The Four-Partner Swarm (canon v2.0)

1. Claude Code = architect, reviewer, orchestrator. Does NOT write code.
2. Ruflo = multi-step flow orchestrator, regulatory boundary enforcer.
3. Aider CLI = SOLE code executor, via LiteLLM (4 modes: fast/full/banxe/unrestricted).
4. MiroFish = behavioural + regulatory simulator for ALL projects.
LiteLLM = infrastructure (routing), NOT a partner.

## 10 Factory Skills with enforcement

Skills 1-10 per SKILLS-MATRIX.md. Key mandatory ones:
- Context Memory Sync (MANDATORY on Dev+Prod planes)
- Rapid Spec Builder (MANDATORY — IL entry before any code)
- Clean Architecture Enforcer (MANDATORY where semgrep rule exists)

## 6 Canonical Chains (from agents.md)

A. New feature: CMS -> RSB -> ACG -> STG -> gate
B. Bug fix: CMS -> EHS -> STG -> gate
C. Safe refactor: CMS -> ARP -> CAE -> STG -> gate
D. Deploy: STG review -> factory-fast (Legion) + factory-coder (evo1)
E. LiteLLM wiring: config -> smoke -> verify
F. Heavy reasoning: LiteLLM reasoning-235b -> Ruflo -> mlro-agent

## Precedence order (highest wins)

1. FCA regulations
2. Invariants I-01..I-28
3. ADRs
4. Quality gate (quality-gate.sh + semgrep + ruff + tests)
5. IL discipline (I-28)
6. Skill MANDATORY rules
7. Skill ADVISORY outputs

## Reality gaps (verified 2026-05-13)

| Canon requirement | Actual state |
|---|---|
| Aider = sole code executor | Claude Code writes code directly (--dangerously-skip-permissions) |
| Ruflo = mandatory flow orchestrator | Config exists, not running as subagent |
| MiroFish = simulator for all projects | Running on evo1 docker, not called automatically |
| parallel-verify.sh 3-model consensus | Script exists, never runs (no journal trace 7 days) |
| Drift monitoring every 6h | No systemd timer configured |
| Adversarial sim weekly | No systemd timer configured |
| promptfoo eval weekly | JUST configured by Sub-A (timer active, baseline 4%) |
| 10 skills enforcement via hooks | Skills documented but not auto-enforced |
| 6 chains A-F formalized | Documented in agents.md, not runtime-enforced |

## 3 Priority actions to align factory with its own laws

1. Return Aider as sole code executor (configure Claude Code to
   delegate via aider-banxe.sh, not Edit/Write directly).
2. Create systemd timers for adversarial_sim (weekly) and drift
   monitor (every 6h) using existing scripts.
3. Wire parallel-verify.sh as pre-commit hook for compliance files
   in banxe-emi-stack.

## What Sub-A already closed today

- promptfoo eval timer (Sunday 04:00 CEST) - DONE, baseline 1/25 passed
- wrapper script patched for canonical :4000 with correct auth
- First real eval through Four-Partner infrastructure end-to-end

Refs: AGENTS.md v4.0, SKILLS-MATRIX.md v1.0, SKILLS-OPERATING-MODEL.md v1.0,
COMPOSABLE-ARCH.md v1.0, .claude/rules/agents.md, .claude/rules/COLLABORATION.md,
ADR-003, ADR-019, ADR-024, ADR-026, SESSION-CANON Clauses 1..17.
