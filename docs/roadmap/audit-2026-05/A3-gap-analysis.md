# A3 — Gap Analysis (Factory vs Project)

| Field | Value |
|---|---|
| Sprint | IL-AUDIT-01 |
| Artefact | A3 (DESIGN phase per GSD) |
| Date | 2026-05-05 |
| Source data | A1 Legion baseline + A2 cluster baseline (evo1 + evo2) |
| Status | DRAFT for review |

## Inventory recap

### Legion (factory plane)

| Resource | Reality | Briefed expectation | Gap |
|---|---|---|---|
| RAM | 23 GiB (WSL2 cap) | 64 GiB | -41 GiB visible to Linux (WSL2 default = half of Windows RAM); physical Windows host likely has 64 GiB |
| Storage | /dev/sdd 1 TB ext4 + /mnt/d 3.7 TB + /mnt/c 952 GB = ~5.6 TB | 5 TB | covered (composite, not native ext4) |
| GPU | NVIDIA RTX 4070 Laptop, CUDA via WSL2 | not specified | bonus capability — heavy under-utilised on factory side |
| Local AI runtime | NO ollama; llama.cpp built locally | (not specified) | factory plane has no model serving layer |
| Local model cache | only ggml-vocab-* tokenizers (no weights) | (not specified) | zero local weights — full dependence on cluster for inference |
| AI agent CLIs | claude 2.1.128, aider 0.86.2, openclaw 2026.3.24, metaclaw, litellm, continue, cursor 2.6.20, codex-cli 0.106.0 | OpenClaw + Ruflo + others | Ruflo not detected on Legion (binary missing or different name) |
| Listening ports | :4000 (LiteLLM), :8180 (Keycloak), :8181 (Frankfurter local), :8765, :8096/:8098, :8080 | (not specified) | Legion runs prod-grade Keycloak realm — split-brain risk vs evo1 services |
| Guardian-shim | enforce/closed, scope=claude.bash, base_url=192.168.0.72:8195 | active | OK |

### evo1 (project plane primary)

| Resource | Reality | Note |
|---|---|---|
| CPU | AMD Ryzen AI MAX+ 395 (32T/16C, 5.2 GHz max) | gfx1151 Strix Halo APU |
| RAM | 30 GiB total / 22 available | TIGHT given 13 docker containers + 19 systemd services + ollama 8 models |
| Swap | 8 GiB / 3.6 used | already swapping under load |
| Storage | nvme1n1p4 root 913 GB (564 free) + nvme0n1p1 /data 1.9 TB (1.5 free) | 2.8 TB total, 2 TB free |
| GPU stack | rocminfo OK, gfx1151 detected, Vulkan ready | works (P4.2-ROCm BLOCKED per ADR-018, Vulkan is the active backend) |
| Models on disk | 8 models, 176 GB on /data/ollama-models + 95 GB ollama cache | llama3.3:70b, qwen3-coder-next:51GB, qwen3.5:35b, qwen3:30b-a3b, glm-4.7-flash, gpt-oss:20b, qwen3:4b, qwen3.5:latest |
| Active BANXE services | banxe-api, compliance-api, deep-search, screener, verify-api, watchman, guardian-factory:8195, guardian-project:8196, openclaw-gateway-{ctio,guiyon,moa}, soul-guard, hitl-dashboard, guiyon-dispatcher, n8n, ollama, pii-proxy, prometheus-node-exporter, clickhouse-server | 19 active |
| Active docker containers | workflow-service (Ballerine), banxe-mock-aspsp, frankfurter, midaz-{ledger,rabbitmq,mongodb}, mirofish, banxe-marble-{frontend,firebase,backend,postgres}, jube.{webapi,jobs} | 13 containers |
| Critical anomaly | midaz-ledger Restarting (1) 53s ago | P0 — primary CBS in crash loop |
| USB4 mesh | thunderbolt0 UP 10.0.0.1/30 | RPC link healthy |

### evo2 (project plane reasoning)

| Resource | Reality | Note |
|---|---|---|
| CPU | AMD Ryzen AI MAX+ 395 (same as evo1) | gfx1151 Strix Halo APU |
| RAM | 93 GiB total / 91 available | 3x evo1 |
| BIOS UMA | vram 32 GiB / system 96 GiB (P4.3-EVO2 done per ADR-018) | confirmed via mem_info_vram_total + MemTotal |
| Storage | nvme0n1p2 ext4 1.9 TB (915 GB free) | /data/ollama-models 739 GB |
| GPU stack | rocminfo EMPTY, vulkaninfo shows llvmpipe (software fallback only) | REGRESSION — userspace stack missing/broken; only CPU/llvmpipe available |
| Models on disk | 11 models, 870 GB total | qwen3:235b-a22b-fp16 (470 GB, downloaded 6h ago), qwen3:235b-a22b-banxe (142 GB), qwen3:235b-a22b (142 GB), llama3.3:70b mirror, qwen3-coder-next mirror, qwen3.5:35b mirror, qwen3:30b-a3b mirror, glm-4.7-flash mirror, gpt-oss:20b mirror, qwen3:4b mirror, qwen3.5:latest mirror |
| Active services | llama-rpc-worker:50052, ollama:11434, qwen3-235b-master:8082, prometheus-node-exporter:9100 | 4 systemd |
| Active docker | banxe-grafana:3000, banxe-blackbox:9115 | observability only |
| USB4 mesh | thunderbolt0 UP 10.0.0.2/30 | RPC link healthy |

## Gaps identified

### G-INFRA-02 — evo2 GPU userspace regression (P1)

- **Symptom:** rocminfo returns empty, vulkaninfo --summary reports only `llvmpipe` (software CPU fallback). gfx1151 hardware present (per BIOS UMA carveout 32 GiB vram visible) but no driver path.
- **Impact:** qwen3:235b-a22b-master on evo2:8082 currently runs CPU-only at 5.1 tok/s (per INS-2026-05-04-Q235-LIVE). Could be 2-4x faster with working ROCm/Vulkan driver path.
- **Root cause hypothesis:** kernel upgrade (6.17.0-23-generic vs evo1 6.17.0-22-generic) or driver/firmware desync after model upgrade session.
- **Action:** verify amdgpu/amdxdna driver state, mesa-vulkan-drivers package, ROCm runtime; reinstall if missing.
- **Anchors:** A2b output, ADR-018, INS-2026-05-04-P4.2-ROCM-BLOCKED.

### G-INFRA-03 — RAM imbalance evo1=30 vs evo2=93 GiB (P1)

- **Symptom:** evo1 has 30 GiB RAM serving 19 systemd + 13 docker containers (production-critical: Midaz, Marble, Ballerine, Jube, Frankfurter, OpenClaw gateways). evo2 has 93 GiB serving only 4 systemd + 2 docker (qwen3:235b-master, RPC worker, observability).
- **Impact:** evo1 swapping under load (3.6 GiB swap used), midaz-ledger restart loop possibly OOM-related. evo2 has 91 GiB headroom unused for serving heavy models that could relieve evo1.
- **Action options:**
  - (a) Move stateless heavy services from evo1 to evo2 (e.g., Frankfurter, Mirofish, parts of Marble stack) — requires service mesh reconfig.
  - (b) Add second instance of ollama/serving on evo1 sourced from evo2 RAM via RPC for in-memory model swapping.
  - (c) Hardware upgrade evo1 RAM to match evo2 (out of scope per A1 sprint constraints).
- **Recommendation:** (a) is fastest non-HW path; (b) requires deeper analysis.
- **Anchors:** A2a output, INS-2026-05-04-ORG-CLEANUP.

### G-OPS-03 — midaz-ledger restart loop on evo1 (P0)

- **Symptom:** `midaz-ledger | Restarting (1) 53 seconds ago` at audit time.
- **Impact:** primary CBS (per ADR-013) intermittently unavailable; LedgerPort calls likely fail-over to fallback (Fineract not yet active per IL-001..IL-011) — actual write path unverified.
- **Action:** read midaz-ledger logs, check connectivity to midaz-mongodb (Up 2 days healthy) and midaz-rabbitmq (Up 2 days healthy); check resource limits; check recent docker compose changes.
- **Priority:** P0 because it touches client-funds path (CASS 7 / I-28 LedgerPort invariant).
- **Anchors:** A2a docker output, ADR-013, IL-001 Midaz healthcheck fix.

### G-FACTORY-01 — Legion has no local model serving (P2)

- **Symptom:** Legion has llama.cpp built but no weights, no ollama. All inference happens on cluster.
- **Impact:** every coding-agent call (claude/aider/openclaw/cursor/codex/continue) goes either to cloud API or to evo1/evo2 via LiteLLM:4000. Legion RTX 4070 (CUDA-capable, 8 GB VRAM) sits idle for inference.
- **Action options:**
  - (a) Install ollama with Vulkan/CUDA backend on Legion + download 1-2 small fast models (qwen3:4b, qwen3-coder-7b, codellama) for offline factory work.
  - (b) Configure LiteLLM router on Legion to prefer local Legion model for fast hot-path (autocomplete, in-line edits) and fall back to evo1/evo2 for heavy reasoning.
  - (c) Use llama.cpp directly with a coding-tuned GGUF on Legion RTX 4070 — proves out the factory plane fork hypothesis.
- **Anchors:** A1 GPU/storage/CLIs sections; idea of factory↔project fork from sprint goal.

### G-FACTORY-02 — Keycloak realm split-brain risk Legion vs evo1 (P1)

- **Symptom:** Legion listens on :8180 (Keycloak banxe-emi realm host-installed dev-file backend, per session canon §infrastructure). evo1 also has :8180 reserved per ADR-016/017 for evo1-side Keycloak (per INS-2026-05-04-feat/keycloak-own-postgres-stack and IL-IAM-09 Postgres backend staging validated).
- **Impact:** two Keycloak instances on the same realm name are a classic split-brain risk for IAM. Service registration in EMI services may target wrong instance.
- **Action:** confirm canonical Keycloak location (per ADR-017), decommission Legion-side instance OR convert it to read-only mirror, document in `.claude/rules/infrastructure.md`.
- **Anchors:** A1 Listening ports section :8180; ADR-017 Keycloak cutover; G-IAM-01..09 (closed).

### G-FACTORY-03 — Ruflo not detected on Legion (P3)

- **Symptom:** Briefed CLI fleet includes Ruflo; A1 PATH probe found no `ruflo` binary.
- **Impact:** unclear whether Ruflo is a missing tool (gap) or a renamed/integrated capability.
- **Action:** clarify Ruflo identity (search by alternative names: ruff, ruflo-cli, ruflo-agent); install or reclassify.
- **Anchors:** A1 AI agent CLIs section.

### G-CLUSTER-01 — qwen3:235b inference path under-utilised (P2)

- **Symptom:** qwen3:235b-a22b-fp16 (470 GB, full precision) was downloaded 2026-05-05 ~6h before audit, but only Q3_K_S (5.1 tok/s) is currently routed via LiteLLM (per INS-2026-05-05 ledger entry).
- **Impact:** 470 GB of disk and 6h of download time invested but model not yet wired into a usable inference path. Even on UMA APU with 93 GiB RAM, fp16 won't fit (470 GB >> 93 GiB) — model needs RPC split or further quantization.
- **Action options:**
  - (a) Establish a planned schedule: when to use Q3_K_S (default, working) vs experimental fp16 (only for offline benchmarking, never live route).
  - (b) Quantize fp16 down to Q4_K_M or Q5_K_M offline once, store as banxe-custom variant, retire 470 GB fp16 if not used.
  - (c) Document in HW-MODEL-UPGRADE-matrix.md the reasoning for keeping fp16 as historical artefact.
- **Anchors:** A2b ollama list, INS-2026-05-04-P4.3-Q235-BLOCKED, INS-2026-05-05 reasoning-235b LIVE.

### G-CLUSTER-02 — model duplication evo1↔evo2 (P3)

- **Symptom:** llama3.3:70b (42 GB), qwen3.5:35b (23 GB), qwen3-coder-next (51 GB), qwen3:30b-a3b (18 GB), glm-4.7-flash (18 GB), gpt-oss:20b (15 GB), qwen3:4b (2.5 GB), qwen3.5:latest (6.6 GB) — present on BOTH evo1 and evo2.
- **Impact:** ~176 GB duplicated storage. Acceptable for HA / RPC parallelism but wasteful if one node always serves.
- **Action:** decide canonical "primary serves" per model (e.g., 70b on evo1, 235b on evo2, coder-next dual for RPC). Document in HW-MODEL-UPGRADE-matrix.md §"Model placement".
- **Anchors:** A2a + A2b ollama list sections.

## Quick wins (no PR required, operator decisions)

1. **G-OPS-03** — restart midaz-ledger with verbose logs, capture root cause; if OOM → bump RAM limit or move container to evo2 temporarily.
2. **G-INFRA-02** — `apt list --installed | grep -E 'rocm|mesa-vulkan|amdgpu'` on evo2; if empty → `apt install rocm-dev mesa-vulkan-drivers`; recheck vulkaninfo.
3. **G-FACTORY-01** — `ollama pull qwen3:4b` on Legion (2.5 GB, fits in 8 GB VRAM) as proof-of-concept; wire into LiteLLM :4000 as `factory-fast` route.
