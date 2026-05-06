# Factory / Project Stack Canon — 2026-05-06

## Roles

- Legion = Developer Factory Layer
  - Hosts coding model (e.g. qwen2.5-coder or equivalent) on RTX 4070.
  - Runs dev agents: Claude Code, Aider, Cursor, Continue, MetaClaw, factory-side OpenClaw gateways.
  - Never writes directly to production DBs; may call evo1/evo2 via LiteLLM / HTTP.

- evo1 = Infrastructure / Services Layer
  - Hosts services (ClickHouse, RabbitMQ, Midaz, Marble, Jube, Guardian, etc.).
  - Hosts smaller / baseline models needed for services.
  - Maintains structure & monitoring; models here can be upgraded later.

- evo2 = Heavy Model / Project Reasoning Layer
  - Hosts the single heaviest feasible model (currently qwen3:235b quantized).
  - Exposed via LiteLLM / project-reason routes, integrated with evo1 services.

## Orchestration Canon

- All LLM access goes through canonical gateways (LiteLLM + OpenClaw + Guardian).
- Developer factory (Legion) sends:
  - fast coding queries to Legion coding model,
  - heavy reasoning to evo2,
  - service-bound calls via evo1/evo2 gateways.
- Production flows (project) use evo1/evo2 only; Legion factory never talks directly to production DBs.

## Upgrade / Efficiency Canon

- Agents monitor:
  - live CPU/RAM/disk/GPU metrics on Legion/evo1/evo2,
  - GAP-REGISTER and INSTRUCTION-LEDGER state,
  - external sources (GitHub / internet) for newer/better models.
- When a more efficient or higher quality model appears:
  - propose an upgrade path (which node, which model to replace),
  - align with HW constraints and HW-MODEL-UPGRADE matrix,
  - record decision in ADR + INSTRUCTION-LEDGER + GAP-REGISTER.

## Binding

- This stack layout (Legion = factory; evo1 = infra; evo2 = heavy model) is the canonical baseline
  for Perplexity supervision and all future sessions.


## Ruflo Review Agent in Orchestration

- Ruflo is the internal Banxe Review Agent / Claude Code subagent for regulatory boundary enforcement (payment, compliance, KYC, AML, EMI/FCA scope).
- Ruflo is NOT a PATH binary; it is invoked as part of the canonical agent pipeline: request -> ARL -> Ruflo -> target agent -> response.
- Mandatory placement:
  - All payment, compliance, KYC and high-risk fintech actions MUST pass through Ruflo before reaching execution agents.
  - Factory-side dev agents (Claude Code, Aider, Cursor, Continue, MetaClaw) MUST consult Ruflo for any change that touches regulated surfaces (Midaz ledger, KYC flows, Watchman/Yente/Jube logic, OpenClaw policies).
  - Project-side gateways (OpenClaw factory/project, Guardian factory:8195, Guardian project:8196) MUST delegate regulatory review decisions to Ruflo and log the result.
- Logging and audit:
  - Every Ruflo decision is captured via the canonical audit chain (Guardian -> INSTRUCTION-LEDGER references / decision events).
  - Ruflo verdicts feed into ExplanationBundle / DecisionEvent records (G-01, G-02 canon).
- Upgrade canon:
  - Improvements to Ruflo prompts, guardrails or rule sets MUST be tracked as ADR + IL entries, never as ad-hoc edits.
  - Operator and Perplexity supervision MUST treat Ruflo as a first-class agent in Legion (factory) and evo1/evo2 (project) orchestration.
