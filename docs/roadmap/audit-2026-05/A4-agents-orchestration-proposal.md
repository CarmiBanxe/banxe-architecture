# A4 — AI-agents fleet × Factory/Project fork orchestration proposal

| Field | Value |
|---|---|
| Sprint | IL-AUDIT-01 |
| Artefact | A4 (DESIGN phase per GSD) |
| Date | 2026-05-05 |
| Source data | A1 (Legion CLI inventory) + A2 (cluster services) + A3 (gap-analysis) |
| Status | DRAFT for review |

## Agent fleet inventory

### Coding agents (interactive, IDE-coupled, factory-side)

| Agent | Version (A1) | Backend | Strength | Recommended plane |
|---|---|---|---|---|
| Claude Code (claude) | 2.1.128 | Anthropic API | best at long-context refactor, multi-file plans, repo navigation, governance compliance via Guardian-shim | Factory primary |
| Aider | 0.86.2 | OpenAI/Anthropic/local via LiteLLM | git-aware diff-based editor, lightweight | Factory secondary |
| Cursor | 2.6.20 | mixed (Cursor cloud + local OpenAI compatible) | best inline-edits + chat in editor | Factory IDE companion |
| Continue | (?) | LiteLLM-compatible | open-source IDE plugin (VSCode/JetBrains), mirrors Cursor | Factory editor plugin |
| Codex CLI (codex) | 0.106.0 | OpenAI Codex API | terminal autocomplete + agent loops | Factory hot-path |

### Orchestration / agent frameworks (multi-agent / coordinator)

| Agent | Where (A2) | Role | Recommended plane |
|---|---|---|---|
| OpenClaw gateway-ctio | evo1 systemd active | CTIO scope orchestration (per ADR-019) | Project — architecture decisions |
| OpenClaw gateway-guiyon | evo1 systemd active | Guiyon (per ADR-024) — second-family coding agent | Project — autonomous coding |
| OpenClaw gateway-moa | evo1 systemd active | Mixture-of-Agents pattern | Project — heavy reasoning ensemble |
| OpenClaw soul-guard | evo1 systemd active (exited but active) | governance / canon enforcement layer | Project — guardrails |
| HITL dashboard | evo1 systemd active | Human-in-the-loop UI (per agent_passports) | Project — operator approval surface |
| guiyon-dispatcher | evo1 systemd active | task router for Guiyon agents | Project — coding queue |
| MetaClaw (metaclaw) | Legion (CLI) + repo (CarmiBanxe/MetaClaw) | meta-orchestrator (training, rollouts, RL, conversations) per repo structure | Factory — agent factory itself |

### Inference / serving layer

| Layer | Where | Role |
|---|---|---|
| Ollama (evo1:11434) | evo1 | 8 models, primary serving for general workloads |
| Ollama (evo2:11434) | evo2 | 11 models, mirror + heavy 235b variants |
| qwen3-235b-master :8082 | evo2 | reasoning route LIVE (Q3_K_S, 5.1 tok/s) |
| llama-rpc-worker :50052/50053 | evo1+evo2 | USB4 RPC mesh for multi-node inference |
| LiteLLM gateway :4000 | Legion + evo1 | API surface unifying providers |

### Compliance / observability agents (project)

| Agent | Where | Role |
|---|---|---|
| Guardian factory :8195 | evo1 | scope=factory.bash + claude.bash (third family per ADR-026) |
| Guardian project :8196 | evo1 | scope=project.bash, deterministic rules per ADR-019 §6.2 |
| compliance_canon_agent (banxe-compliance-api) | evo1 | runtime Inspector role per .claude/agents/inspector-agent.md |
| safeguarding-agent | evo1 | FCA CASS 15/7 per .claude/agents/safeguarding-agent.md |
| Watchman / Screener / Verify | evo1 systemd | sanctions + PEP screening |

### Factory governance agents (per banxe-architecture/.claude/agents/)

Existing agent passports:
- **CMS** Context Memory Sync
- **RSB** Rapid Spec Builder
- **ACG** API Contract Guardian
- **CAE** Clean Architecture Enforcer
- **EHS** Error Handling Standardizer
- **PS** Performance Scanner
- **DO** Dependency Optimizer
- **STG** Smart Test Generator
- **ARP** Auto Refactor Pro

Agent chains (per .claude/rules/agents.md):
- C. Safe refactor: CMS -> ARP -> CAE -> STG -> gate
- (others per agents.md)

## Factory plane orchestration

### Goal

Maximise Legion compute (RTX 4070 + 23 GiB WSL RAM + ~1 TB ext4 native) for software development workflow. Minimise round-trips to evo1/evo2 for routine work; reserve cluster for heavy reasoning.

### Recommended layered architecture

```
Operator (CEO)
│
▼
[Cursor / Continue / Codex / Claude Code]   <- IDE / terminal layer
│
▼
[LiteLLM router :4000 on Legion]            <- single API surface
│
├─ factory-fast   -> Legion local ollama (qwen3:4b / qwen3-coder-7b on RTX 4070)
├─ factory-mid    -> evo1 ollama qwen3.5:35b OR qwen3:30b-a3b
├─ factory-heavy  -> evo1 ollama llama3.3:70b
├─ factory-coder  -> evo1 ollama qwen3-coder-next:51b
├─ project-reason -> evo2 qwen3:235b-master :8082 (Q3_K_S)
└─ project-reason-rpc -> evo2 master + evo1 RPC worker (when MoE+RPC fixed)
│
▼
[Aider / Claude Code multi-file ops]        <- model-agnostic, follows router
│
▼
[MetaClaw orchestrator (Legion)]            <- factory-of-factory: agent training, rollouts, RL
```

### Rules (factory)

1. Routine tasks (autocomplete, single-line edits, lint fixes, small refactors) → `factory-fast` (Legion local, < 100 ms TTFT goal).
2. Multi-file refactor / spec writing → `factory-mid` or `factory-heavy` via LiteLLM, never direct cluster.
3. Architecture / cross-repo reasoning → `project-reason` qwen3:235b on evo2.
4. Coding-tuned heavy work → `factory-coder` qwen3-coder-next 51b on evo1.
5. Guardian-shim (claude.bash) MUST be active for every Claude Code session (already enforce/closed per A1).
6. MetaClaw = factory-of-factory: trains/evaluates other agents, OUT of production loop.
7. Forbidden on factory plane: any direct write to project services (Midaz, Marble, Keycloak prod realm, ClickHouse), any agent action without Guardian audit trail.

### Action items (factory)

| ID | Action | Source gap |
|---|---|---|
| FA-1 | Install ollama + 1 small model (qwen3:4b 2.5 GB) on Legion | G-FACTORY-01 |
| FA-2 | Define LiteLLM routes `factory-fast`/`factory-mid`/`factory-heavy`/`factory-coder`/`project-reason` | G-CLUSTER-01 |
| FA-3 | Resolve Ruflo identity (install or reclassify) | G-FACTORY-03 |
| FA-4 | Decommission Legion-side Keycloak OR convert to read-only mirror | G-FACTORY-02 |
| FA-5 | Document agent chain matrix in .claude/rules/agents.md (tie OpenClaw gateways to GSD phases) | A4 |

## Project plane orchestration

### Goal

Production EMI BANXE AI BANK runs on evo1 + evo2 cluster. Maximise reliability of customer-facing path (Midaz, Marble, Ballerine, Watchman, Jube, Frankfurter, Keycloak). Use evo2 RAM for heavy AI; let evo1 carry stateful CBS workloads.

### Recommended layered architecture

```
External clients
│
▼
[Cloudflare / public ingress]  (out of audit scope)
│
▼
[evo1 :443 / :80 / :8080]
│
├─ Keycloak banxe-emi :8180  (canonical per ADR-017)
├─ banxe-api / verify-api / compliance-api / screener / watchman
├─ Midaz primary CBS (ledger + rabbitmq + mongodb) ⚠ midaz-ledger restart loop (G-OPS-03)
├─ Marble (frontend + backend + postgres :15433 + firebase)
├─ Ballerine workflow-service
├─ Jube (webapi + jobs)
├─ Frankfurter (FX rates)
├─ n8n (automation)
├─ pii-proxy (PII tokenization)
├─ ClickHouse (audit + Guardian sink)
└─ MiroFish (per project canon)
│
▼  (USB4 RPC mesh 10.0.0.0/30)
│
[evo2]
├─ qwen3-235b-master :8082  (reasoning route LIVE)
├─ ollama :11434  (mirror + 235b variants)
├─ llama-rpc-worker :50052
├─ Grafana :3000  (observability)
└─ blackbox-exporter :9115

[Guardian factory :8195 + project :8196  (both on evo1)]
- audits all agent actions per ADR-019/020/026
```

### Rules (project)

1. Customer-funds path (Midaz, Marble, Watchman, safeguarding) — NO LLM-driven action without `hitl_service.require_approval()` per IL-PROT-01 / G-CASS-01..02.
2. Heavy reasoning (compliance review, MLRO escalation, fraud explanation) — route to evo2 qwen3:235b reasoning route via LiteLLM.
3. Any agent action — Guardian project:8196 audits (deterministic rules per ADR-019 §6.2).
4. RAM rebalance: candidates for migration evo1->evo2 = stateless (Frankfurter, MiroFish), pending HW assessment.
5. Restart loops on critical containers (midaz-ledger) — P0 operator response, not LLM-driven.

### Action items (project)

| ID | Action | Source gap |
|---|---|---|
| PA-1 | Diagnose midaz-ledger restart loop (logs + resource limits + connectivity) | G-OPS-03 |
| PA-2 | Restore evo2 GPU userspace stack (rocm + mesa-vulkan-drivers) | G-INFRA-02 |
| PA-3 | Decide and document model placement matrix (which model serves from which node) | G-CLUSTER-02 |
| PA-4 | Decide qwen3:235b-fp16 fate (keep / quantize-and-archive / delete) | G-CLUSTER-01 |
| PA-5 | Plan stateless service migration evo1->evo2 to relieve evo1 RAM (Frankfurter + MiroFish first) | G-INFRA-03 |
| PA-6 | Pin OpenClaw gateways (ctio/guiyon/moa) to LiteLLM model aliases (currently free-form per gateway) | A4 |

## Cross-plane governance

### Forking principle (per sprint goal)

The factory↔project fork is real and must be enforced at THREE layers:

1. **Compute fork** — Legion (RTX 4070, 1 TB ext4) for factory; evo1+evo2 cluster for project. Legion never writes to project DBs/Keycloak directly.
2. **Agent fork** — Claude Code, Aider, Cursor, Codex, Continue = factory side (developer-facing). OpenClaw gateways + Guardian project + HITL dashboard = project side (production-facing). MetaClaw spans both as agent-trainer (writes only to its own scope).
3. **Governance fork** — Guardian factory:8195 audits factory.bash + claude.bash scopes; Guardian project:8196 audits project.bash scope. Per ADR-019 / ADR-026.

### Approval rules (combined factory+project)

Already canonical per `.claude/rules/approval-rules.md`:
- Auto-run whitelist: read-only, git r/w, pytest/ruff/semgrep, rsync to dev hosts, file create/edit, docker compose in compose dir.
- Stop-barrier: file delete, repo delete, chmod/chown, financial ops, force-push, reset --hard main.
- Best-decision (IL-CANON-04): for ambiguous tasks Claude Code chooses optimal path autonomously.
- Production-state mutation gate (CLAUDE.md §11): never without explicit human approval + Promotion Gate B.11.N+1.9.

### Provenance (Guardian)

Every agent call must POST /audit to Guardian (factory or project depending on scope). audit log → ClickHouse.

### Cross-plane data flow rules

```
Factory plane                               Project plane
─────────────                               ─────────────
Legion code edits ──[git push]──> CarmiBanxe/* repos on GitHub
                                            │
                                            ▼
                               [evo1 cron pull-deploy per G-DEPLOY-01]
                                            │
                                            ▼
                                    /data/banxe/* on evo1
                                            │
                                            ▼
                               systemd reload (banxe-* services)

Project state ──[ClickHouse read-only]──> Legion analytics
              (via Tailscale, never write)
```

## Roadmap of follow-up sprints (post IL-AUDIT-01)

| Successor | Trigger | Scope |
|---|---|---|
| Sprint FA | A4 approved | Implement FA-1..FA-5 (factory orchestration setup) |
| Sprint PA | A4 approved | Implement PA-1..PA-6 (project rebalance + GPU restore) |
| ADR-027 | A4 approved | Formalise factory↔project fork as canonical architecture decision (3 layers above) |
| G-INFRA-02 | A4 approved | Open formal gap entry, link to PA-2 |
| G-INFRA-03 | A4 approved | Open formal gap entry, link to PA-5 |
| G-OPS-03 | A4 approved | Open formal gap entry, link to PA-1 |
| G-FACTORY-01..03 | A4 approved | Open formal gap entries, link to FA-1..FA-4 |
| G-CLUSTER-01..02 | A4 approved | Open formal gap entries, link to PA-3..PA-4 |
| A5 closure | All above tracked | Close IL-AUDIT-01 |

## Anchors

- A1 Legion baseline (PR #50 history)
- A2 evo1+evo2 baseline (PR #50 history)
- A3 gap-analysis (PR #52)
- ADR-018 (5-layer hybrid AI compute)
- ADR-019 (OpenClaw orchestration)
- ADR-026 (Guardian third-family scope)
- IL-CANON-04 (approval-rules + best-decision principle)
- MetaClaw org-cleanup/phase4-hw-matrix-roc-rpc @ 016dc26
- INS-2026-05-04-P4.3-EVO2 / P4.2-ROCM / P4.3-Q235 / ORG-CLEANUP
