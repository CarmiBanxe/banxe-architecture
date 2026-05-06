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
