# Sprint — Project (Cluster) Audit Implementation 2026-05

| Field | Value |
|---|---|
| Sprint ID | IL-PROJECT-AUDIT-01 |
| Branch | sprint/project-cluster-audit-2026-05 |
| Started | 2026-05-05 |
| Status | OPEN — реперная точка main@b2a598c |
| Owner | CEO (operator) + Perplexity supervisor + Claude Code |
| Predecessor | IL-AUDIT-01 (PRs #50, #52, #54, #55) + PR #57 (IL-FACTORY-AUDIT-01 kickoff) + PR #59 (G-INFRA-01/02 Track I, `8a89787`) + PR #63 (ADR-027 settings) |
| Successor | IL-FACTORY-AUDIT-01 (unblocks after PA-2/PA-4/PA-5/PA-1 done) |

## Goal

Стабилизировать production кластер (evo1 + evo2 + Legion). Закрыть PA-1..PA-6 в порядке Operator canon (Three-action corrective proposal). После этого — разблокировать IL-FACTORY-AUDIT-01 (FA-1..FA-5).

## Reperential snapshot (main@b2a598c, 2026-05-05)

### Cluster nodes

| Node | Role | LAN | Tailscale | RAM | GPU |
|---|---|---|---|---|---|
| evo1 | banxe-NucBox-EVO-X2 | 192.168.0.12 | 100.68.102.48 | 30 GiB | — |
| evo2 | banxe-nucbox-evo-x2-2 | 192.168.0.15 | 100.99.208.21 | 128 GiB LPDDR5X total / 93 GiB visible after UMA carveout (32 GiB vram + 96 GiB system) | Radeon 8060S 40 CU gfx1151 |
| Legion | mark-legion, WSL2 Ubuntu 24.04 | — | — | 23 GiB WSL2 cap | NVIDIA RTX 4070 Laptop |

### Open project gaps (from PR #55, IL-AUDIT-01)

- **PA-1 (P0)** — midaz-ledger restart loop on evo1 (OOM risk)
- **PA-2 (P1)** — evo2 GPU userspace stack not restored after OS install (rocm / mesa-vulkan-drivers missing)
- **PA-3 (P2)** — model placement matrix not documented
- **PA-4 (P2)** — qwen3:235b-fp16 (470 GB) fate undecided
- **PA-5 (P2)** — stateless services (Frankfurter, MiroFish) still on evo1
- **PA-6 (P3)** — OpenClaw gateways not aliased to LiteLLM routes

## Priority order — Three-action corrective proposal (Operator canon)

Per `docs/canon/operator-canon-2026-05.md` — binding priority:

| Order | PA-ID | Action | Why |
|---|---|---|---|
| **1** | PA-2 | Restore evo2 GPU userspace stack (rocm + mesa-vulkan-drivers) | Unlocks 2-4× speedup on qwen3:235b — full use of prior evo2 investment |
| **2** | PA-4 | Decide qwen3:235b-fp16 fate (keep / quantize Q4_K_M or Q5_K_M / delete) | Removes 470 GB disk harm |
| **3** | PA-5 | Migrate stateless services evo1→evo2 (Frankfurter + MiroFish first) | RAM relief without Principle 2 violation (stateful stays on evo1) |
| **4** | PA-1 | Diagnose & fix midaz-ledger restart loop (on relieved evo1) | Fix P0 on node with reduced OOM pressure |
| **5** | PA-3 | Document model placement matrix | Follows naturally after PA-4 outcome |
| **6** | PA-6 | OpenClaw gateways → LiteLLM aliases | Orchestration polish, finishing touch |

## Implementation roadmap

| ID | Action | Source | Phase (GSD) | Status | Mini-PR |
|---|---|---|---|---|---|
| PA-1 | Diagnose & fix midaz-ledger restart loop on evo1 | G-EVO1-01 | DEPLOY | PENDING | TBD |
| PA-2 | Restore evo2 GPU userspace stack (rocm + mesa-vulkan-drivers) | G-EVO2-01 | DEPLOY | PENDING | TBD |
| PA-3 | Document model placement matrix | A2/A3 | DESIGN | PENDING | TBD |
| PA-4 | Decide qwen3:235b-fp16 fate (470 GB) | G-EVO2-02 | SPEC+CLOSE | PENDING | TBD |
| PA-5 | Migrate stateless services evo1→evo2 (Frankfurter + MiroFish first) | G-EVO1-02 | DEPLOY | PENDING | TBD |
| PA-6 | OpenClaw gateways → LiteLLM aliases | G-CLUSTER-01 | DESIGN+DEPLOY | PENDING | TBD |

## Acceptance criteria for sprint closure

- [ ] PA-2 done: `rocminfo` on evo2 shows Radeon 8060S 40 CU; `ollama ps` on evo2 shows qwen3:235b-a22b using GPU.
- [ ] PA-4 done: qwen3:235b-fp16 either deleted, quantized, or explicitly retained with ADR-036 justification; disk state documented.
- [ ] PA-5 done: Frankfurter and MiroFish containers running on evo2; evo1 RAM usage reduced by ≥ 2 GiB.
- [ ] PA-1 done: midaz-ledger container on evo1 stable for ≥ 24h, no restart loop in `docker logs`.
- [ ] PA-3 done: `docs/architecture/model-placement-matrix.md` committed and covers evo1/evo2/Legion with current model assignments.
- [ ] PA-6 done: LiteLLM config on Legion routes `project-reason` via evo2 qwen3:235b-a22b; smoke test returns 200.
- [ ] All project gaps closed in `GAP-REGISTER.md` (G-EVO1-01, G-EVO1-02, G-EVO2-01, G-EVO2-02, G-CLUSTER-01 → DONE).
- [ ] IL-PROJECT-AUDIT-01 closed in `INSTRUCTION-LEDGER.md` with closure block.

## Out of scope

- Factory-side actions (FA-1..FA-5) — отдельный спринт IL-FACTORY-AUDIT-01 (BLOCKED-ON-CLUSTER).
- HW changes (RAM upgrade, SSD swap, BIOS edits).
- Decommission live evo1 production services (Midaz, Marble, Ballerine, Jube, Keycloak, etc.).
- G-INFRA-01 full closure — canonical evo2 registration done in Track I (`8a89787`); infrastructure orchestration (Consul/DNS integration) deferred to ADR-036 after PA-2.

## Anchors

- IL-AUDIT-01 (PRs #50, #52, #54, #55) — original audit
- IL-FACTORY-AUDIT-01 (PR #57) — factory sprint kickoff (BLOCKED-ON-CLUSTER until this sprint closes)
- G-INFRA-01/02 Track I — evo2 canonical registration PR #59, commit `8a89787`
- ADR-027 — Claude Code permissions reclassification (PR #63)
- A1 evo1/evo2/Legion baselines + A2 cluster baseline + A3 gap-analysis
- docs/canon/operator-canon-2026-05.md (binding Operator canon, Principles 1-4)
- IL-CANON-04 (best-decision rule)
- ADR-013 (Midaz primary CBS), ADR-018 (5-layer hybrid AI compute)
- Reperential point: main@b2a598c

## Status history

| Date | Status | Note |
|---|---|---|
| 2026-05-05 | OPEN | Sprint kickoff — реперная точка main@f20d607, branch created |
| 2026-05-05 | RE-ALIGNED v1 | Priority realigned to Operator canon PA-2→PA-4→PA-5→PA-1→PA-3→PA-6 per docs/canon/operator-canon-2026-05.md; combined into single kickoff commit `fcbc52b` |
| 2026-05-05 | RE-ALIGNED v2 | Rebased onto main@b2a598c (after PR #63 + Track I); evo2 hardware corrected (LAN 192.168.0.15, 128 GiB LPDDR5X / 93 GiB visible, Radeon 8060S 40 CU gfx1151); G-INFRA-01 scoped out; Anchors updated |
