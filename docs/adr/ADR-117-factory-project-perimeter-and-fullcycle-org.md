# ADR-117 — Factory / Project Perimeter & Full-Cycle Org Model

- Status: ACCEPTED
- Date: 2026-06-20 (ACCEPTED 2026-06-21 by operator decision; see docs/governance/CANON-RECONCILIATION-ADR117.md)
- Relates: ADR-116, ADR-115, ADR-053, ADR-RUFLO-01
- Supersedes: the hardware/perimeter parts of DEPLOYMENT-ARCHITECTURE (2026-04-06) and AGENT-ORG-STRUCTURE

## Supremacy

Operator concept is supreme over canon. Where repo docs conflict with this ADR, the repo docs are stale and are corrected here.

## Perimeter — FACTORY (software-delivery only)

- Hardware: Legion (64 GB) + its coding model `qwen2.5-coder:14b-banxe-factory` (verified live on localhost). The factory owns ONLY this node.
- Cluster evo1/evo2 (128 GB each) belong to the PROJECT; they LEND compute to the factory during the code-design phase only.

## Perimeter — PROJECT (out of factory scope)

- Cluster evo1/evo2 + all heavy/domain models: `qwen3-banxe-v2`, `qwen3:235b-a22b[-banxe]`, `llama3.3:70b`, `qwen3-coder-next`, `glm-4.7-flash`, `gpt-oss-derestricted`, `qwen3.5/30b/4b`.
- Domain/banking agents: compliance swarm (9, RED zone), routing layer (5), periodic workflows, all 47 domain passports.

## Factory org — full-cycle software company roles (Operator concept)

- Architect (Claude Code: design / review / orchestration).
- Programmers — DOUBLED developer headcount (was a single Aider CLI → at least 2× dev capacity).
- Testers / QA (MiroFish + automated quality-gates).
- Controllers — MANDATORY heightened code-quality control (multi-level review: pre-commit, SAST/SCA/secrets, 2-reviewer peer, chapter-lead for payment-core/KYC, architecture review for ADR; AI-assisted multi-model review).
- UI/UX factory — code→UI/UX generation mechanism: Design System (`docs/BANXE-UI-UX-SYSTEM.md`) + parallel UI build; existing features (frontend FSD scaffold, sandbox portal, Execution-Preview UI, DSE terminal-UI) are factory UI/UX deliverables.
- Process orchestrator (Ruflo / Channel C).

## Quality-gate KPIs (factory mandate)

- Coverage ≥85% critical.
- Tech-debt <5%.
- 0 blocker/critical on merge.
- Security-hotspot ≥95%.
- MTTD vuln <24h.

## Hermes

Hermes = ARCHITECTURAL AGENT PATTERN (SOUL.md identity layer, 3-tier memory, self-improving skills, 24/7 specialized agents) — a FUTURE factory work item, NOT an installed feature. No Hermes agent exists in the repo.

> Role detail (refinement): **ADR-126** bounds this future role as a **Tier-1, read-only / alerting-first, HITL-safe** companion — CI/CD Watchdog + Telegram DevOps assistant + infra/alerting/research — and marks it **out of scope** for merge, deploy, payment-core write, AML/SAR decisions, or replacing Claude Code/OpenClaw orchestration. See `docs/adr/ADR-126-hermes-tier1-cicd-watchdog-role.md`.

## Spec-build pipeline & governance

Spec → ADR → Architecture → API-contract → parallel impl → quality-gates → deploy. ADR append-only; Architecture Review Board.

## Consequences

- DEPLOYMENT-ARCHITECTURE + AGENT-ORG-STRUCTURE must be reconciled to this ADR in a follow-up.
- Persistent canon across sessions.
