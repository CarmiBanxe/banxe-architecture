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

## HW Baseline (canonical hardware; OS readings are NOT authoritative)

- **Legion (Developer Factory Layer)**
  - Physical: 64 GB RAM, 4+ TB SSD, NVIDIA RTX 4070 Laptop (8 GB VRAM).
  - Constraint: WSL2 currently exposes ~23 GiB to Linux; coding model selection MUST
    be driven by physical 64 GB + 8 GB VRAM, not by WSL2-visible memory.
  - Canonical action: raise WSL2 memory cap (e.g. `memory=56GB` in `.wslconfig`),
    use SSD as model/blob cache, host a larger coding model than 7B-class.

- **evo1 (Infrastructure / Services Layer)**
  - Physical: 128 GB RAM, large SSD.
  - Constraint: `free -h` currently reports ~30 GiB; this is a BIOS/UMA/firmware mismatch,
    NOT a real physical limit. All capacity planning MUST treat 128 GB as authoritative.
  - Canonical action: full hardware audit (BIOS/UEFI, dmidecode, DIMM slots,
    UMA Frame Buffer / Memory Remap) and reconcile OS-visible RAM with physical 128 GB
    before further service/model rebalancing.

- **evo2 (Heavy Model / Project Reasoning Layer)**
  - Physical: 128 GB RAM, 1.9 TB SSD, AMD GPU.
  - Constraint: `free -h` reports ~93 GiB (UMA/firmware), and GPU stack (ROCm/Vulkan)
    is not functional → qwen3:235b currently runs on CPU only.
  - Canonical action: restore GPU stack (ROCm/Vulkan/drivers), then re-select the
    maximum feasible model under full 128 GB + GPU-offload, not under CPU-only 93 GiB.

- **Decision rule (binding):** any model selection, service placement, or capacity
  plan MUST cite the physical HW baseline above and explicitly note any current
  OS-visible deviation (WSL2 cap, BIOS/UMA mismatch, broken GPU stack).

## §1.bis Factory ↔ Project layers (binding extension, 2026-05-07)

Дополнение к §1 «Stack canon». Зафиксировано по operator-instruction
2026-05-07 02:00 CEST.

### Принцип

1. **Factory layer = Legion (mark-legion)**
   - HW: 64 GB physical RAM, ~5 TB SSD (1 TB internal + ~3.7 TB /mnt/d),
     NVIDIA RTX 4070 Laptop 8 GB VRAM.
   - Назначение: build/refactor/CI инфраструктуры BANXE-стека, локальная
     coding-модель факторного класса (Qwen2.5-Coder-32B Q4_K_M или
     эквивалент по VRAM-budget RTX 4070).
   - Агенты (factory-agents): работают на Legion для Legion. Обслуживают
     сам репозиторий-канон, devops, локальные тесты, autoformatting,
     spec-first-auditor.

2. **Project layer = evo1 + evo2 (banxe-NucBox-EVO-X2 + banxe-NucBox-EVO-X2-2)**
   - HW: 2 × 128 GB physical RAM = 256 GB unified, 2 × Strix Halo iGPU
     (RADV GFX1151), ~4.7 TB SSD суммарно.
   - Связаны в единый «проектный» layer для одного проекта BANXE EMI.
   - Назначение: heavy-model reasoning, compliance/KYC/AML/EMI/FCA
     pipeline, payment rails, project-knowledge retrieval.
   - Агенты (project-agents): работают на evo1/evo2 для проекта.

3. **Принцип разделения (binding):**
   - Factory-агент НЕ ходит на project-узел и НЕ использует project-модели.
   - Project-агент НЕ ходит на Legion и НЕ использует factory-coder.
   - Единственный шов — LiteLLM gateway litellm-v2.service на Legion
     0.0.0.0:4000. Ruflo обязателен для regulated-маршрутов в project layer.

4. **Размещение моделей (binding):**
   - factory-fast → Legion local Ollama (RTX 4070): coder-модель.
   - project-mid → evo1 local Ollama (Vulkan): qwen3.5:35b,
     qwen3-coder-next:51GB, llama3.3:70b.
   - project-heavy / project-reason → evo2: qwen3:235b-a22b
     (через llama-server :8082 или Ollama).
   - infrastructure services (Keycloak, Postgres, Guardian, OpenClaw,
     ClickHouse) → evo1.

5. **HW Baseline binding (live-shell verified, 2026-05-07):**
   - Legion: WSL2-cap currently 24 GiB, target 56 GiB (G-FACTORY-WSL2-RAM-CAP).
   - evo1: 123 GiB visible / 126 G online (BIOS UMA=2G, Шаг 1 PASS, PR #122).
   - evo2: 123 GiB visible / 126 G online (BIOS UMA=2G, Шаг 2 PASS, PR #123).

6. **Agent placement rule (binding):**
   - Factory-agents → OpenClaw/Guardian config с layer=factory,
     host=mark-legion (Tailscale 100.101.218.26).
   - Project-agents → layer=project, host=banxe-nucbox-evo-x2 или
     banxe-nucbox-evo-x2-2.
   - Cross-layer работа агента — только через LiteLLM HTTP API.

7. **Применение:**
   - Расширяет §1 (не отменяет).
   - Не отменяет HW Baseline §4 и Ruflo §3.
   - Шаг 4 HANDOFF-2026-05-06 = factory layer; Шаг 5 = project layer +
     cross-layer LiteLLM.
