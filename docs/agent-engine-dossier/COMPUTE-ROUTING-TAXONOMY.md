# Compute Routing Taxonomy — BANXE-CORE-ENGINE

**Document type:** Canonical alias registry + task-routing guide + activation-gap register  
**Date:** 2026-06-28  
**Source:** FA-02 runbook + ADR-018 + ADR-016 + ADR-FUSION-01 + HW-MODEL-UPGRADE-matrix  
**Basis:** VERIFIED-RUNTIME-SNAPSHOT.md (2026-06-28)

---

## §1 — Canonical Alias → Model → Hardware Table

All production AI inference on BANXE flows through **LiteLLM proxy :4000** (I-32/I-33/ADR-016). This table defines the five canonical aliases and their hardware targets.

| Alias | Routes to (legacy name) | Hardware | Model | Params | Speed | Use tier |
|-------|------------------------|----------|-------|--------|-------|----------|
| `factory-fast` | `factory-fast` (FA-1 ✅) | Legion RTX 4070 | qwen3:4b | 4B | fastest | autocomplete, lint, single-line edits, shard-ledger ops |
| `factory-mid` | `qwen3:30b-a3b` (evo1+evo2 LB) | Strix Halo iGPU (Vulkan) | qwen3:30b-a3b | 30B MoE | fast | multi-file refactor, spec writing, dossier enrichment, sprint-plan updates |
| `factory-heavy` | `ai-heavy` (evo1+evo2 LB) | Strix Halo iGPU | llama3.3:70b | 70B | medium | architecture reasoning, cross-repo plans, mid-size decisions |
| `factory-coder` | `coding` (evo1) | Strix Halo iGPU | qwen3-coder-next (Q4_K_M) | 51B | medium | code-specialised multi-file implementation, refactor, review |
| `project-reason` | `reasoning-235b` (evo2 :8082 standalone) | evo2 RPC + USB4 | qwen3:235b-a22b (Q3_K_S) | 235B | slowest | compliance review (MLRO/AML/FCA), ADR design, fraud explanation, reasoning-heavy tasks |

**Critical distinction:** `factory-heavy` ≠ `project-reason`.
- **factory-heavy**: mid-size load-balanced model (llama3.3:70b) on Strix Halo iGPU; fast enough for mid-tier reasoning.
- **project-reason**: qwen3-235b (142 GB) on evo2 standalone; reserved for highest-reasoning tasks and compliance sign-off.

**Routing:** All aliases resolve through LiteLLM :4000 (I-32). No direct model bypass in production.

---

## §2 — Task-Routing Guide

| Task type | Recommended alias | Reason |
|-----------|------------------|--------|
| ADR authorship (architecture decisions) | `project-reason` | Deep reasoning required; novel architecture; high-stakes regulatory/design decisions; human-reviewed output |
| Architecture design verification / review | `project-reason` | Correctness stakes; when ADR-FUSION-01 MoA judge is active, judge layer adds quality ranking over candidates |
| Compliance review (MLRO/AML/FCA sign-off) | `project-reason` | 235B required for regulatory nuance and FCA terminology precision; I-27 HITL supervised decisions |
| Multi-file code implementation (≥3 files) | `factory-coder` | Coding-tuned model; strong context window; refactoring and multi-module consistency |
| Single-file code fix / lint / test | `factory-fast` | Latency-sensitive, low reasoning required; deterministic fixes |
| Dossier enrichment (SRC-*, CANAL-*, documentation) | `factory-mid` | Structured spec writing; document generation; content synthesis |
| Sprint-plan status updates, COMPLIANCE-MATRIX edits | `factory-mid` | Structured doc maintenance; moderate reasoning; markdown / table formatting |
| Shard-model rebase (IL ledger operations, SEQUENCE.json) | `factory-fast` | Deterministic protocol (no reasoning required); low latency |
| MoA ensemble critical path (ADR-FUSION-01 active) | Candidates: `factory-mid` + `factory-heavy` + `project-reason`; judge: `project-reason` | Quality-ranked synthesis; judge layer scores candidate outputs and produces fused answer (only when ADR-FUSION-01 acceptance gates cleared) |

**Note:** All production routing MUST use LiteLLM :4000 (I-32). Direct model access in code is a violation of ADR-016.

---

## §3 — ACTIVATION-GAP Register

The following gaps prevent immediate production use of this taxonomy. Each gap has a documented operator-go path.

### GAP-COMPUTE-01: FA-02 canonical aliases not deployed to Legion LiteLLM

| Field | Value |
|-------|-------|
| **Status** | DRAFT (awaiting operator go) |
| **Impact** | `factory-mid`, `factory-heavy`, `factory-coder`, `project-reason` aliases do not exist in Legion's LiteLLM config (`/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml`); only legacy route names are active |
| **Blocking scope** | All routing taxonomy references return 404 until Phase C completed |
| **Operator-go steps** | **Phase A** (read-only verify): check current routes via `python3 -c "import yaml; c=yaml.safe_load(open('/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml').read()); print(sorted({m['model_name'] for m in c['model_list']}))"` — must NOT contain factory-mid/heavy/coder/project-reason. **Phase B** (backup): `cp -v /home/mmber/MetaClaw/litellm/litellm-config.v2.yaml /home/mmber/MetaClaw/litellm/litellm-config.v2.yaml.bak-fa-02-$(date +%Y%m%d-%H%M%S)`. **Phase C** (append aliases): add 4 new model entries per FA-02 runbook (factory-mid → qwen3:30b-a3b LB, factory-heavy → llama3.3:70b LB, factory-coder → qwen3-coder-next, project-reason → qwen3-235b evo2:8082). **Verification**: restart LiteLLM, confirm `curl http://localhost:4000/v1/models` returns all 5 aliases. |
| **Unblocks** | All downstream task-routing table usage; ADR-FUSION-01 ensemble preparation |
| **Ref** | `docs/runbooks/fa-02-litellm-canonical-aliases.md` |

### GAP-COMPUTE-02: AGENT_ROUTING_ENABLED=false (intentional gate)

| Field | Value |
|-------|-------|
| **Status** | Intentional compliance gate (NOT a bug) |
| **Impact** | No production AI agent traffic routes through :4000 automatic routing logic; routing taxonomy is inactive in BANXE compliance/orchestration system (agents still work, but do not use ARL tier selection) |
| **Blocking scope** | ADR-FUSION-01 MoA judge+synthesizer, ARL routing decisions, agent swarm fault classification |
| **Why it exists** | `.claude/rules/agents.md` defines 4 enable-conditions that must all pass before `AGENT_ROUTING_ENABLED=true`: (1) LiteLLM canonical aliases deployed (GAP-COMPUTE-01 Phase C), (2) Ruflo mandatory post-step wired (ADR-RUFLO-01 integration), (3) cost/lineage schemas finalized (ADR-047 + ADR-046), (4) WG acceptance of orchestration strategy |
| **Operator-go steps** | Meet all 4 enable-conditions in `.claude/rules/agents.md` (check agents.md for exact list and status). When all conditions pass, flip env var `AGENT_ROUTING_ENABLED=true` in `deploy/.env` and redeploy. |
| **Unblocks** | Production agent swarm traffic; auto-tier selection; MoA ensemble (when ADR-FUSION-01 accepted) |
| **Ref** | `.claude/rules/agents.md` enable-conditions section |

### GAP-COMPUTE-03: ADR-FUSION-01 concept_only / PROPOSED (not accepted)

| Field | Value |
|-------|-------|
| **Status** | PROPOSED (not yet WG/CEO accepted); concept-only; no production code/infra built |
| **Impact** | No MoA judge+synthesizer layer active; qwen3-235b not used as quality-ranking judge for ensemble output; fusion call produces majority-vote, not ranked synthesis |
| **Blocking scope** | Task-routing table §2 MoA row (skip this row until ADR-FUSION-01 acceptance); no divergence-rate risk tracking |
| **Why it exists** | ADR-FUSION-01 proposes post-ensemble judge (scores quality) + synthesizer (fused answer) as extension to openclo-moa. Design is sound, but requires: (1) WG review of MoA judge design, (2) CEO acceptance of cost overhead (N candidates + judge call), (3) Terminal-A activation of Ruflo mandatory post-step on synthesized output, (4) divergence-rate monitoring infra (ADR-047 cost-cap integration). Until all gates clear, feature is PROPOSED only. |
| **Operator-go steps** | Submit ADR-FUSION-01 to WG for review + discussion. Upon WG consensus, escalate to CEO for cost/risk acceptance. Once CEO approves, Terminal-A infra activation: wire judge+synthesizer into `services/arl/` and enable Ruflo post-step (ADR-RUFLO-01). Prototype first on Innovation Sandbox :8080 (PR #277), then promote to :4000. |
| **Unblocks** | High-stakes compliance/architecture decisions via MoA ensemble; quality-ranked synthesis |
| **Ref** | `docs/adr/ADR-FUSION-01-moa-judge-synthesizer.md` (Decision section §(a)–§(f)) |

### GAP-COMPUTE-04: banxe-ai-infrastructure config.yaml alias mismatch

| Field | Value |
|-------|-------|
| **Status** | Open (non-blocking, but alignment recommended) |
| **Impact** | `banxe-ai-infrastructure` repository (`deploy/config.yaml`) uses different canonical alias class names (`chat-fast`, `code-deep`, `reasoning-heavy`) vs BANXE-CORE-ENGINE canonical scheme (`factory-fast`, `factory-mid`, `factory-heavy`, `factory-coder`, `project-reason`). Causes confusion when tracing request flows across repos. |
| **Blocking scope** | Cross-repo tracing and documentation; no functional impact (both schemas work, but naming diverges) |
| **Operator-go steps** | (Follow-up PR, not blocking this merge) Audit `banxe-ai-infrastructure/deploy/config.yaml` alias names; propose PR that aligns class names to BANXE-CORE canonical scheme (`factory-*`, `project-reason`). Coordinate with banxe-ai-infrastructure maintainers. |
| **Unblocks** | Unified alias naming across BANXE monorepository; cleaner onboarding docs |
| **Ref** | `docs/runbooks/factory-routing-map.md` (cross-repo tracing section) |

---

## §4 — References

### Runbooks & Activation
- **FA-02 runbook:** `docs/runbooks/fa-02-litellm-canonical-aliases.md` — Phase A/B/C deployment steps for Legion LiteLLM
- **Factory routing map:** `docs/runbooks/factory-routing-map.md` — canonical alias → model mapping and cross-repo trace guide

### Architecture Decisions (ADRs)
- **ADR-043:** `decisions/ADR-043-aider-routes.md` — LiteLLM routes specification (no new routes added by this taxonomy)
- **ADR-016:** `decisions/ADR-016-litellm-single-entrypoint.md` — LiteLLM :4000 as single AI entrypoint (I-32/I-33)
- **ADR-018:** `decisions/ADR-018-hybrid-5-layer-ai-compute.md` — 5-layer hybrid compute (evo1 + evo2 + Legion + Vulkan + USB4); evo2:8082 qwen3-235b placement
- **ADR-FUSION-01:** `docs/adr/ADR-FUSION-01-moa-judge-synthesizer.md` — MoA judge + synthesizer layer (PROPOSED, gated by WG/CEO acceptance + Terminal-A infra)
- **ADR-RUFLO-01:** `docs/adr/ADR-RUFLO-01-dual-role.md` — Regulated Route Checkpoint (mandatory post-step on compliance/payment output)
- **ADR-047:** `docs/adr/ADR-047-ai-cost-governance-policy.md` — per-request token caps
- **ADR-046:** `docs/adr/ADR-046-decision-lineage-schema.md` — AgentDecisionRecord (one per fusion call)
- **ADR-048:** `docs/adr/ADR-048-business-process-repository.md` — process_ref binding

### Model Cards & Hardware
- **Model card: project-reason (alias):** `docs/governance/model-cards/project-reason.md` — 235B reasoning alias card (DRAFT, operator CRO approval pending)
- **Model card: qwen3-235b-a22b:** `docs/governance/model-cards/qwen3-235b-a22b.md` — 235B base model (Q3_K_S, 142 GB, evo2 only, IL-CANON-OPERATOR-2026-05 #3)
- **HW-MODEL-UPGRADE matrix:** `docs/canon/HW-MODEL-UPGRADE-matrix.md` — quantization decisions (Q3_K_S canonical max) and placement matrix (evo1/evo2)
- **VERIFIED-RUNTIME-SNAPSHOT.md:** `docs/agent-engine-dossier/VERIFIED-RUNTIME-SNAPSHOT.md` — runtime verification of listening services, models, ports (basis: 2026-06-28)

### Invariants & Policies
- **I-32 / I-33:** All production AI calls via LiteLLM :4000 (no direct model bypass)
- **I-27:** HITL — AI proposes, human decides (supervised decision gates)
- **I-24:** Append-only audit trails (no deletion of agent decision records)
- **Security policy:** `.claude/rules/security-policy.md` — hardcoded secrets forbidden; secrets via `.env`

### Governance
- **MODEL-RISK-MANAGEMENT.md:** `docs/governance/MODEL-RISK-MANAGEMENT.md` — MRM tiers (T1/T2/T3), validation mechanisms, lifecycle controls
- **Agent authority matrix:** `.claude/rules/agent-authority.md` — autonomy levels (L1-L4), HITL gates, timeout/escalation rules

---

## Notes

1. **Snapshot basis:** This taxonomy is grounded in VERIFIED-RUNTIME-SNAPSHOT.md (2026-06-28). Hardware placements (Legion RTX 4070, Strix Halo iGPU, evo2 RPC) are current as of that date. Do not extrapolate beyond 2026-06-28 without re-running shell audit (S5/S6/S7).

2. **Ruflo mandatory:** Any output from ADR-FUSION-01 MoA ensemble (when active) MUST pass Ruflo regulatory check post-synthesis (ADR-RUFLO-01). Skipping Ruflo on compliance/payment output is a potential FCA violation.

3. **Cost tracking:** Per ADR-047, one per-request token cap covers all N ensemble candidates + judge + synthesizer as a single budgeted unit. Enforced at LiteLLM seam (no double-billing).

4. **Lineage:** Per ADR-046, exactly one `AgentDecisionRecord` per fusion call (candidates, judge scores, chosen synthesis, Ruflo verdict, total cost). Carries `process_ref` to resolved business process.

5. **Activation sequence:** GAP-COMPUTE-01 (deploy aliases) → GAP-COMPUTE-02 (meet agents.md enable-conditions) → ADR-FUSION-01 (WG/CEO accept + Terminal-A infra).

---

## §5 — Two compute planes (amendment 2026-07-01)

Additive amendment. Does NOT restate §1/§2. Names the second plane the earlier taxonomy did
not cover (Claude-Code build-dispatch) and records the live activation-gaps that make the
existing Plan-2 aliases only partially usable today. Framing is factory-side (Terminal A
orchestrates); this section MUST NOT be read as mutating runtime — see safety canon.

### §5.1 — Plan 1: Claude-Code build-dispatch (NOT covered by §1)

- `claude -p` (headless Claude-Code) is inference against the **Anthropic API (Claude)**. It
  is **not** ollama/LiteLLM and does not resolve through :4000. The §1 alias table
  (`factory-*`, `project-reason`) is scoped to local ollama models and does **NOT** apply to
  Claude-Code build-dispatch.
- Routing a Claude build "to the 235b on evo2" is a **category error**: `qwen3:235b-a22b` is a
  local ollama model on evo2, unrelated to Claude-API inference. `factory-heavy` /
  `project-reason` cannot be used to steer a Claude-Code build.
- **evo1 / evo2 are ADR-103 checkout VENUES**, not model targets. Selecting a host for a
  Claude-Code build is **venue-routing** (which secured server holds the checkout, secrets,
  and CLI login), not model-routing. Conflating the two produces the category error above.
- The real parallelism lever for Plan 1 is **Claude-Code CLI + a durable `/login` on each
  intended host**, not any local-model swap. Verified 2026-07-01: `evo1` has
  `/usr/bin/claude`; `evo2` returns `claude: command not found`. Consequence: **parallel
  Claude-Code builds across evo1 and evo2 are BLOCKED** until Claude-Code CLI is installed
  and a durable `/login` is completed on evo2.

### §5.2 — Plan 2: LiteLLM / local-ollama (existing §1/§2, activation status)

> §5 correction 2026-07-01: prior §5.2 "235b idle" + §5.5 Redis-precondition were
> wrong-stack/overstated — corrected per verified read-only audit.

Do not restate the §1 table. Net-new today (2026-07-01):

- Heavy routes are **live, not on paper**. `project-reason → qwen3:235b-a22b` is served on
  evo2 by **`llama-server` at `192.168.0.15:8082`** (`curl :8082/v1/models` returns
  `qwen3-235b-Q3_K_S.gguf`); LiteLLM `reasoning-235b` targets that backend (see §5.3), so
  the alias is **functional today**, not idle. `factory-heavy → llama3.3:70b` LB is
  likewise live per §1.
- The earlier "`ollama ps` empty ⇒ 235b not served" reading measured the **wrong stack** —
  a separate, unused ollama copy of 235b on evo2 `:11434`, irrelevant to `reasoning-235b`.
  It is **not** a precondition on `project-reason`.

### §5.3 — RPC mesh (verified 2026-07-01, up-but-idle)

Scaffolding is **up but idle**: `evo2` runs `rpc-server` on `:50052` and `llama-server` on
`:8082`; `evo1` runs LiteLLM on `:4000`. Confirm that `project-reason` (a.k.a.
`reasoning-235b`) resolves to the **distributed RPC master** — and not to a dead standalone
process — before relying on the alias for production routing.

### §5.4 — Verified cluster facts (2026-07-01, read-only)

| Host   | CPU / RAM         | GPU / accel            | Claude-Code CLI     | Local ollama models present         |
|--------|-------------------|------------------------|---------------------|-------------------------------------|
| Legion | 20 cpu / 54 GB    | RTX 4070 8 GB (~2 % util) | present            | (per §1: `qwen3:4b` `factory-fast`) |
| evo1   | 32 cpu / 123 GB   | Strix Halo iGPU        | **present** (`/usr/bin/claude`) | (per §1: iGPU-hosted 30b/70b/coder) |
| evo2   | 32 cpu / 123 GB   | Strix Halo iGPU        | **ABSENT** (`command not found`) | `qwen3:235b-a22b` + `llama3.3:70b` |

### §5.5 — Preconditions (AWAITS-OPERATOR / factory; NOT actioned by this doc)

**Only one genuine open precondition remains** — the earlier list overstated two items
(see §5.2 correction above and the root-cause note below):

1. Install **Node.js + Claude-Code CLI on `evo2`** and complete a **durable `/login`** —
   unblocks Plan-1 parallelism (concurrent Claude builds on evo1 and evo2). Verified
   read-only 2026-07-01 on evo2: `node` = NONE, `npm` = NONE, `claude` = ABSENT.

**Root-cause note (2026-07-01).** The ledger merge-conflict churn observed across recent
PRs is caused by **concurrent regeneration of `INSTRUCTION-LEDGER.md` / `IL-SEQUENCE.json`
between parallel PRs**, not by Redis. The durable serializer is the **GitHub Merge Queue
(ADR-060 §1)**; the Redis IL-allocator (`banxe-redis`, `netmode=host`,
`restart=unless-stopped`, tailscale `100.68.102.48:6379` + vault AUTH pass-file) mitigates
number collisions but does not serialize regeneration order. The mid-session
`WARN unreachable` was a **transient blip**, not a durability gap. (The separate `redis`
container with `restart=no` on `:16379` belongs to the **jube stack** — a different
service — not the allocator.) Prior framings that treated "Redis down" or "warm 235b" as
gating preconditions were **overstated / wrong-stack**.

### §5.6 — Cross-references

- **ADR-103** — server-only refactoring / venue policy (evo1 / evo2 as checkout venues).
- **ADR-018 / FA-02** — canonical LiteLLM aliases (Plan-2 basis; see §1).
- **ADR-153** — terminal topology canon (Terminal-A orchestrates; runtime not mutated here).
