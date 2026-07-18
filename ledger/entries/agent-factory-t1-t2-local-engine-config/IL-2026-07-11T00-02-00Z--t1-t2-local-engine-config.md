---
il_ts: 2026-07-11T00:02:00Z
session_id: agent-factory-t1-t2-local-engine-config
source: factory
status: DONE (edits applied — operator pull + commit pending)
---
### T1+T2: Local Engine Config — OI-LOCAL-1 gate resolved; config.toml + Sprint L-1 revised for autonomous local Tier 1
- **Decision:** OI-LOCAL-1 G-1 and G-6 resolved from full-audit.sh run (2026-07-11T02:04:14Z): `qwen3:30b-a3b` confirmed on evo1+evo2 (18.6 GB), Ollama backend confirmed. Factory applied T1 and T2 edits. NOT committed — operator commits/pushes per I-71.
- **Key facts established by audit:**
  - G-1 RESOLVED: Ollama tag = `qwen3:30b-a3b` (18.6 GB, confirmed evo1 100.68.102.48 + evo2 192.168.0.15)
  - G-6 RESOLVED: Ollama backend (not llama-server)
  - G-2 RESOLVED: no explicit quant suffix in tag (Ollama default quantization)
  - LiteLLM 20 aliases confirmed (full list in SESSION-STATE.md)
  - Legion local Ollama: only `qwen2.5-coder:7b` present; `qwen3:30b-a3b` NOT yet pulled
  - Ports :8000 (OpenManus), :8080 (llama-server) NOT listening
  - banxe-architecture: 4 behind origin/main, 3 dirty files
  - evo1 :8090/health → HTTP 404
- **Artifacts revised (NOT committed — operator action required):**
  - `docs/ops/legion-private-engine/config.toml` — [llm] and [llm.vision] switched to `qwen3:30b-a3b` via `127.0.0.1:11434`; api_key = "none"; evo :4000 is commented-out fallback; ENGINE PROFILE + VRAM CONSTRAINT comments updated; TIER 1 is now local autonomous
  - `docs/architecture/SPRINT-PLAN-TWO-ENGINES.md` (bdsl-act-prep worktree) — Sprint L-1 rewritten: Tier 1 LOCAL primary (`qwen3:30b-a3b` via :11434); ollama pull pre-flight; `nvidia-smi` VRAM < 85% in Done criteria; "Engine is AUTONOMOUS" statement; evo :4000 fallback-only; Sprint L-0 Done criteria updated; L-7 tier-switch test updated; Cross-Engine table updated
  - `docs/ops/legion-private-engine/OI-LOCAL-1-FINDINGS.md` — STATUS UPDATE section updated: G-1/G-2/G-6 RESOLVED; G-3/G-4/G-5 pending; config.toml + Sprint L-1 revision DONE; next steps listed
  - `docs/governance/SESSION-STATE.md` — PARALLEL TRACKS + OPEN ITEMS + ARTIFACT STATUS + TRACK BOARD updated; full LiteLLM 20-alias list added; audit findings recorded; HARDWARE note corrected
- **Operator action required (before T1 goes live):**
  1. `ollama pull qwen3:30b-a3b` on Legion (18.6 GB — I-71)
  2. After pull: verify `ollama list` shows `qwen3:30b-a3b`
  3. `OLLAMA_NUM_GPU=20 ollama run qwen3:30b-a3b "hello"` — confirm GPU offload
  4. `nvidia-smi` — VRAM < 85% (< 6.96 GB of 8188 MiB)
  5. Copy `docs/ops/legion-private-engine/config.toml` → `~/OpenManus/config/config.toml`
  6. `git add + git commit + git push` in both worktrees (I-71)
- **Tracks after this block:**
  - T1: REVISED (not committed); blocker = operator pull
  - T2: REVISED (not committed); blocker = operator pull
  - T3 (Watchdog): RUNNING independently
  - T-MEM: DONE (previous block)
- **Append-only (ADR-059-A):** il_ts 2026-07-11T00:02:00Z strictly > 2026-07-11T00:01:00Z.
- **Refs:** `docs/ops/legion-private-engine/config.toml`, `docs/architecture/SPRINT-PLAN-TWO-ENGINES.md` (bdsl-act-prep), `docs/ops/legion-private-engine/OI-LOCAL-1-FINDINGS.md`, `docs/governance/SESSION-STATE.md`, `tools/audit/full-audit.sh` output 2026-07-11T020414Z.
