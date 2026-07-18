# SESSION-STATE — BANXE EMI Factory Live Memory
# Worktree: /home/mmber/wt/private-engine-openmanus
# Branch: agent/factory/private-engine/openmanus-config
# Rule: update this file after every closed block. This IS the session memory.
# Last updated: 2026-07-11

---

## PROJECT

Two-engine architecture. Separate concerns, separate contours.

| Engine | Name | Host | Purpose |
|--------|------|------|---------|
| Private Legion Engine | OpenManus | Legion (local machine) | AUTONOMOUS dev/research — browser, bash, search, code |
| Banking Engine | Banksy | evo1 (primary) + evo2 (failover) | FCA-compliant banking orchestration (LangGraph) |

Source confirming separation and autonomous nature of Private Engine:
- `MetaClaw/docs/sources/S-18-consultant-answers.md` lines 13, 144, 181: Private Engine autonomous, isolated, NO routes to banking DBs or internal APIs.
- Correction 1 (2026-07-10): "Legion НЕ является fallback для banking-логики."
- ADR-103: DLP boundary — no banking credentials on Legion; no write to banking ledger.

---

## HARDWARE — Legion

| Component | Spec | Notes |
|-----------|------|-------|
| CPU | Intel i7-14700HX, 20 threads | High-performance laptop CPU |
| RAM | ~54Gi usable (~64GB physical) | Large RAM — enables model offload |
| GPU | NVIDIA RTX 4070 Laptop, 8188 MiB VRAM (~8GB), CUDA driver 560.94 | |
| Disk | 769G free | Sufficient for large model weights |

### KEY FACT — RAM Offload (AUTONOMOUS LOCAL RUN)

8GB VRAM + ~54GB RAM → GPU+RAM offload via llama.cpp / Ollama `num_gpu` layers.

**30B-class models are feasible locally on Legion with RAM offload.**
Sprint plan constraint "30B–235B MUST be remote" is SUPERSEDED for 30B-class.

Revised tiers:
- Pure GPU (VRAM only): ≤7B fully on GPU (e.g., qwen2.5-coder:7b = 4.7GB).
- GPU+RAM offload: 30B-class feasible locally (GPU layers = fast path; remainder on RAM).
- 235B-class: still requires evo2 — too large even with offload on Legion RAM.

**CONSEQUENCE FOR PRIVATE ENGINE:** The engine is AUTONOMOUS — it MUST run locally
by default, not defer to evo. config.toml REVISED 2026-07-11: Tier 1 LOCAL `qwen3:30b-a3b`
via Ollama :11434 is now the active config. Evo :4000 is commented-out fallback only.

---

## LITELLM GATEWAY

| Param | Value | Source |
|-------|-------|--------|
| Endpoint | `http://127.0.0.1:4000/v1` | IPv4 only; `::1:4000` refused |
| Master key | `sk-banxe-llm-gateway-2026` | `litellm-config.v2.yaml` general_settings |
| Aliases (total) | 20 confirmed | `litellm-config.v2.yaml` |
| Aliases (confirmed) | `banxe-general`, `qwen3-banxe`, `qwen3-30b`, `fast`, `glm-4-flash`, `coding`, `gpt-oss-20b`, `large`, `glm-4.5-air-distributed`, `glm-air`, `ai`, `ai-heavy`, `reasoning`, `reasoning-235b`, `factory-fast`, `factory-mid`, `factory-heavy`, `factory-coder`, `project-reason`, `project-mid` | Audited 2026-07-11 via `GET /v1/models` |
| `banxe-general` | BANNED from Private Engine — reserved for Banking Engine | ADR-103 |
| ADR-060 branch regex | `^agent/(central|right|factory|specproj)/[A-Za-z0-9]+/[a-z0-9._-]+$` | ADR-060 |

---

## PARALLEL TRACKS

| Track | ID | Current state | Blocker |
|-------|----|--------------|---------|
| Private Engine config | T1 | PR #1126 open; config.toml REVISED T1c (2026-07-11) — llama-server :8080 (HauhauCS-Aggressive-IQ2_M); [llm.vision] → llama-server :8081 (Gemma-4-12B abliterated IQ4_XS). Ollama :11434 SUPERSEDED for primary. NOT yet committed/pushed (I-71). | Operator: download GGUF files (HF), install llama-server CUDA build, run llama-server :8080, copy config.toml to ~/OpenManus/config/ |
| Sprint plan | T2 | SPRINT-PLAN-TWO-ENGINES.md REVISED (2026-07-11) — Sprint L-1 rewritten: Tier 1 LOCAL primary; ollama pull pre-flight + VRAM check in Done criteria. NOT yet committed/pushed (I-71). | Same — after operator pull confirms model present |
| Watchdog brigade | T3 | I-27 intact; operates independently | No blocker; do NOT couple to T1/T2 |
| Banking Engine B-0/B-1 | T-BANKSY | SCAFFOLD WRITTEN (2026-07-11) — B0-SANDBOX-DECLARATION.md + B1-LANGGRAPH-RUNBOOK.md + graph_sandbox.py + ledger event IL-2026-07-11T00-04-00Z. Staging at /tmp/banksy-staging (operator must mv + git worktree add + cp back). NOT committed (I-71). | Operator: mv staging → git worktree add → cp back → pip install on evo1 → smoke test → commit/push |

**Rule:** Never drop a track. All three tracks advance in parallel where possible.

---

## ARTIFACT STATUS

| Artifact | Path / Commit | Status |
|----------|--------------|--------|
| OpenManus config.toml | `docs/ops/legion-private-engine/config.toml` — base f9e5d7b; revised T1c 2026-07-11 | REVISED (not committed) — llama-server :8080 (HauhauCS-IQ2_M) + :8081 (Gemma abliterated IQ4_XS). Ollama :11434 SUPERSEDED. |
| Systemd unit | `docs/ops/legion-private-engine/banxe-private-engine.service` — commit f9e5d7b | COMMITTED |
| RUNBOOK.md | `docs/ops/legion-private-engine/RUNBOOK.md` — commit f9e5d7b | COMMITTED |
| GROSSBUCH addendum | `docs/architecture/GROSSBUCH-TWO-ENGINES-CAPABILITY-ADDENDUM.md` — commit b2ef6a6 (bdsl-act-prep) | COMMITTED |
| Sprint plan | `docs/architecture/SPRINT-PLAN-TWO-ENGINES.md` — base 5c41cb1 (bdsl-act-prep); revised 2026-07-11 | REVISED (not committed) — Sprint L-1 rewritten for Tier 1 local |
| CANON-MEMORY-FIRST-AUDIT-CONFIRMS.md | `docs/governance/` (this worktree) | WRITTEN (not committed) |
| CANON-PARALLEL-ORCHESTRATION.md | `docs/governance/` (this worktree) | WRITTEN (not committed) |
| SESSION-STATE.md | `docs/governance/` (this worktree) | WRITTEN (not committed) — you are here |
| OPEN-ITEMS-OFFLOAD.md | `docs/governance/` (this worktree) | WRITTEN (not committed) |

---

## OPEN ITEMS

| ID | Description | Source files | Action | Owner |
|----|-------------|-------------|--------|-------|
| OI-LOCAL-1 | ✅ RESOLVED (extraction + config edits done). G-1: `qwen3:30b-a3b` (confirmed evo1+evo2 audit). G-6: Ollama backend. G-2: no explicit quant suffix. G-3/G-4/G-5: pending operator pull + measurement. config.toml + Sprint L-1 REVISED. | — | Operator: `ollama pull qwen3:30b-a3b` on Legion (18.6 GB, I-71) | Operator |
| OI-5 | Web UI selection: Open WebUI vs LibreChat vs AnythingLLM | GROSSBUCH §B-3 | Operator decision | Operator |
| OI-6 | Auth method for mobile → Legion API | GROSSBUCH §B-4 | Operator decision | Operator |
| OI-7 | NeMo Guardrails + LlamaFirewall: confirmed deployed or designed only? | Correction 4 | Audit before install sprint | Factory |
| OI-8 | Temporal vs LangGraph ADR | Correction 7 | ADR to be written | Factory |

---

## RULES FOR THIS FILE

- Update after every closed block (new fact, new artifact, resolved OI).
- Never delete confirmed facts — mark superseded entries `[SUPERSEDED: reason]`.
- Flag stale entries: `[STALE? verify before action]`.
- This file is authoritative session memory per CANON-MEMORY-FIRST-AUDIT-CONFIRMS.md.

---

## TRACK BOARD
# Last updated: 2026-07-11 — T-MEM block
# WARNING: Audit is source of truth, NOT operator statements. "It's in the repo / running locally"
# must be verified by a live repo/process audit before acting on it.

| Track | Status | Last SHA / PR | Next action | Blocked-by |
|-------|--------|--------------|-------------|-----------|
| T1 — Private Legion Engine config | PR #1126 OPEN — config REVISED T1c | branch `agent/factory/private-engine/openmanus-config`; `config.toml` revised T1c 2026-07-11 (NOT committed): llama-server :8080/:8081, HauhauCS-IQ2_M + Gemma-abliterated-IQ4_XS | Operator: download GGUFs from HF → install llama-server CUDA → systemctl stop ollama → run llama-server :8080 → copy config.toml → commit/push | GGUF download + llama-server install |
| T2 — Sprint plan | REVISED — not committed | `SPRINT-PLAN-TWO-ENGINES.md` revised 2026-07-11 (bdsl-act-prep worktree, NOT committed) | Operator commits after pull confirms model present | Operator pull required |
| T3 — Watchdog brigade | RUNNING, I-27 intact | current branch `agent/factory/watchdog/sprint3-decision-core` | Monitor only; do NOT couple to T1/T2 | — |
| T-MEM — Memory infrastructure | DONE | 2026-07-11 | Ledger events written; HANDOFF-LIVE.md created | — |
| T-BANKSY — Banking Engine B-0/B-1 | SCAFFOLD DONE — operator action pending | branch `agent/factory/bankingengine/b0b1-sandbox`; staging at /home/mmber/wt/banking-engine-b0b1 (NOT yet a git worktree) | Operator: mv → git worktree add → cp → pip install on evo1 → smoke test → commit/push | Operator staging move required |

### System state (full-audit.sh run 2026-07-11T02:04:14Z)

**Legion ports active:** `:3000` (Open WebUI), `:4000` (LiteLLM), `:11434` (Ollama)
**Ports NOT listening:** `:8000` (OpenManus API — not running), `:8080` (llama-server — inactive), `:8081`

**Systemd services:**
- `litellm-lan-gateway` → ACTIVE ✅
- `ollama` → ACTIVE ✅
- `llama-qwen` → INACTIVE ❌

**Legion local Ollama models:** `qwen2.5-coder:7b-instruct-q4_K_M` (4.7 GB) only.
`qwen3:30b-a3b` NOT yet pulled on Legion. Operator must: `ollama pull qwen3:30b-a3b`

**evo2 (192.168.0.15) Ollama models (confirmed):** `qwen3:30b-a3b` ✅ (18.6 GB), plus others.
**evo1 (100.68.102.48) Ollama models (confirmed):** `qwen3:30b-a3b` ✅ (18.6 GB), plus others.
**evo1 API :8090/health:** HTTP 404 (not healthy at that path — may be wrong health endpoint or API not active).

**banxe-architecture repo:** 4 commits behind origin/main; 3 dirty files; PR #1126 OPEN.
**banxe-emi-stack:** on branch `agent/factory/watchdog/sprint3-decision-core`.

**LiteLLM aliases (20 confirmed):** `banxe-general`, `qwen3-banxe`, `qwen3-30b`, `fast`, `glm-4-flash`, `coding`, `gpt-oss-20b`, `large`, `glm-4.5-air-distributed`, `glm-air`, `ai`, `ai-heavy`, `reasoning`, `reasoning-235b`, `factory-fast`, `factory-mid`, `factory-heavy`, `factory-coder`, `project-reason`, `project-mid`.

**OI-LOCAL-1 gate status (updated 2026-07-11):**
- G-1: ✅ RESOLVED — `qwen3:30b-a3b` (from evo1+evo2 audit)
- G-2: ✅ RESOLVED — no explicit quant suffix (Ollama default)
- G-6: ✅ RESOLVED — Ollama backend confirmed
- G-3/G-4/G-5: ⏳ pending operator pull + measurement

### Artifact status — updated 2026-07-11

| Artifact | Path | Status |
|----------|------|--------|
| OI-LOCAL-1 findings | `docs/ops/legion-private-engine/OI-LOCAL-1-FINDINGS.md` | WRITTEN + STATUS UPDATED (not committed) |
| config.toml | `docs/ops/legion-private-engine/config.toml` | REVISED 2026-07-11 — Tier 1 local `qwen3:30b-a3b` (not committed) |
| SPRINT-PLAN-TWO-ENGINES.md | `docs/architecture/` (bdsl-act-prep worktree) | REVISED 2026-07-11 — Sprint L-1 rewritten (not committed) |
| CANON-PROMPT-REWRITE-ON-OUTPUT.md | `docs/governance/` | WRITTEN (not committed) |
| CANON-LEDGER-EVENT-AFTER-BLOCK.md | `docs/governance/` | WRITTEN (not committed) |
| HANDOFF-LIVE.md | `docs/governance/` | WRITTEN (not committed) |
| CANON-SINGLE-AUDIT-SCRIPT.md | `docs/governance/` | WRITTEN (not committed) |
| tools/audit/full-audit.sh | `tools/audit/` | WRITTEN (not committed; operator runs, I-71) |
