# evo2 reasoning-node bring-up — status (F1.1, ADR-104)

<!-- Source: docs/runbooks/evo2-reasoning-node-bringup-2026-06-17.md | Date: 2026-06-17 | Implements: ADR-104 + three-node-fabric-bootstrap.md | IL: pending-shard -->

## Status

**REASONING NODE UP (degraded-mode legal, ADR-104 §5).** evo2 (`banxe-NucBox-EVO-X2-2`)
is brought up as the fabric **reasoning plane** per ADR-104 / `three-node-fabric-bootstrap.md`:
GPU-accelerated inference + a LiteLLM gateway + a health/heartbeat emitter. It **acts on
nothing** (no execution path — that is Legion `gate.exec`, F1.3/F1.5). Full fabric (gates,
queue/bus) is **not** activated here. Done server-side over ssh, **no sudo executed**.

## 1. GPU — already accelerated via Vulkan (GAP-G2 resolved by the Vulkan path)

| Item | Finding |
|---|---|
| GPU | AMD **Radeon 8060S Graphics (RADV GFX1151)** — Ryzen AI Max / Strix Halo iGPU (not NVIDIA; `nvidia-smi` correctly absent) |
| Kernel | `amdgpu` **loaded**; `/dev/kfd` + `/dev/dri/renderD128` present; service user in `render`+`video` groups |
| ROCm userspace | **MISSING** (`rocminfo`/`rocm-smi` absent) — **not required**: Vulkan path works |
| Vulkan | `vulkaninfo` → `Radeon 8060S (RADV GFX1151)` via `radv` |
| ollama | 0.22.1 on :11434, already configured `OLLAMA_VULKAN=1` / `OLLAMA_LLM_LIBRARY=vulkan` / `HSA_OVERRIDE_GFX_VERSION=11.5.1`; journal: `library=Vulkan … iGPU total=122.0 GiB` |
| **Verification** | `qwen3:4b` → `ollama ps` shows **`100% GPU`**; end-to-end gateway gen produced real tokens on GPU |

**Acceleration path chosen: Vulkan (RADV)** — already active, no sudo, no ROCm needed. ROCm
is an *optional* future enhancement (operator action), not a blocker.

## 2. LiteLLM gateway :4000 (factory-built, no sudo)

- Installed in a user venv (`~/litellm-evo2-venv`, LiteLLM 1.89.1) — no sudo.
- Config `~/banxe-fabric/evo2/litellm-config.yaml` fronts the **keyless local ollama :11434**
  (Vulkan-GPU). **No secrets in the config** (localhost `api_base` only).
- Aliases **reuse the canonical names** (`reasoning-model`, `project-reason`, `reasoning-235b`
  + a cheap `reasoning-fast` probe) → no new alias scheme.
- Running on `0.0.0.0:4000`; `GET /health/liveliness` → `"I'm alive!"`.
- **End-to-end verified:** `POST /v1/chat/completions` (`reasoning-fast`) → ollama :11434 →
  Vulkan GPU → real generation (`reasoning_content` populated, usage reported).

## 3. Health / heartbeat (reasoning-only, correlation_id-aware)

- `~/banxe-fabric/evo2/evo2_health.py` (stdlib-only) on `:9208`.
- `GET /health` → `{node:"evo2", role:"reasoning", status: up|degraded|down, ts, load,
  components:{ollama_11434, litellm_4000}, acts_on:"nothing (reasoning-only)", correlation_id}`;
  honours/echoes inbound `X-Correlation-Id`, else mints `fab-<utc-iso>-<6hex>` per the runtime
  contract. Status logic: both backends up ⇒ `up`; gateway down ⇒ `degraded`; ollama down ⇒ `down`.
- Heartbeat: appends `heartbeat.evo2` JSON to `heartbeat.log` every 15 s (local log until the
  shared bus exists — bus stand-up is an operator action). **Verified:** `/health` → `status: up`,
  heartbeat line emitting with a minted correlation_id.

## 4. OPERATOR ACTIONS (HITL / sudo / secret — NOT executed by the factory)

1. **Persist services across reboot** — install systemd units for the LiteLLM gateway and the
   health emitter (sudo, `/etc/systemd/system/`), e.g. `litellm-evo2.service`, `evo2-health.service`.
   (F1.1 runs them via `setsid nohup`; they survive logout but not a reboot.)
2. **(Optional) ROCm userspace** — if HIP/compute libs are wanted beyond Vulkan: install ROCm for
   gfx1151 (sudo, drivers/firmware/repos). Not required — Vulkan already accelerates inference.
3. **Auth-harden the :4000 gateway before fabric exposure** — add a LiteLLM master key (from the
   server vault, never in repo) + restrict to Tailscale/LAN ACL. Currently bound `0.0.0.0` with no
   master key (parity with the existing local ollama posture).
4. **Shared queue/bus** — stand up the bus (Redis/NATS) so heartbeats publish to `heartbeat.evo2`
   on the bus instead of a local log (this is the fabric infra sprint, F1.3+).
5. **`llama-server :8082`** (existing canonical `qwen3-235b-Q3_K_S` endpoint) is **API-key
   protected** with a key the factory did not extract (to avoid handling the secret). If the fabric
   should front :8082, the operator supplies its key via vault/env (`os.environ`), not in the repo.

## Duplication Audit (ADR-102)

**Coverage:** `docs/runbooks/` for LiteLLM/route/alias, evo2-GPU, and heartbeat/health docs —
`factory-routing-map.md`, `fa-02-litellm-canonical-aliases.md`, `fa-evo2-gpu-stack.md`,
`fa-evo2-gpu-stack`, `redis-evo1-setup.md`, `three-node-execution-fabric-contract.md`.

| Match | Decision | Rationale |
|---|---|---|
| `factory-routing-map.md` / `fa-02` (canonical LiteLLM aliases on the **Legion** :4000 router) | **keep / reuse** | evo2 :4000 is the **node-local reasoning gateway** (distinct host + role per ADR-104), not a second copy of the Legion meta-router. Alias **names reused** (`project-reason`, `reasoning-235b`) — no new scheme. |
| `fa-evo2-gpu-stack.md` (ROCm restore plan) | **keep / superseded-in-practice** | GPU is already accelerated via **Vulkan**, not ROCm; this status doc records the realized state. ROCm stays an optional enhancement. No duplication. |
| `redis-evo1-setup.md` | **keep / reference** | Bus backing-store candidate; not stood up here. |
| `three-node-execution-fabric-contract.md` | **keep — source-of-truth** | correlation_id / heartbeat / health contract honoured by `evo2_health.py`; not duplicated. |

**Verdict:** **no duplicate** — reuse canonical aliases, extend the GPU runbook with the realized
Vulkan state, honour the fabric contract. **Keep all, no merge/delete.**

## Confirmations

no sudo executed · secrets not leaked (gateway config localhost-only; the :8082 key was **not**
extracted; `OLLAMA_API_KEY` redacted) · full fabric **not** activated (no gates/execution path) ·
reasoning node **acts on nothing** · M0–M1.2 / `/srv/banxe-legacy` / prod / emi-stack untouched.

**Refs:** ADR-104, ADR-040, ADR-103, ADR-102; `docs/runbooks/three-node-fabric-bootstrap.md`,
`three-node-execution-fabric-contract.md`, `factory-routing-map.md`, `fa-02-litellm-canonical-aliases.md`,
`fa-evo2-gpu-stack.md`.
