---
il_ts: 2026-07-11T00:01:00Z
session_id: agent-factory-oi-local-1-findings
source: factory
status: DONE (extraction) / BLOCKED (apply — awaiting operator G-1/G-6)
---
### OI-LOCAL-1: Local model + offload settings extraction — findings complete; config/sprint edits BLOCKED on operator gate
- **Decision:** Read 3 source files (manus-legion-private-engine.md, ai-efficiency-methodology-2026-07-09.md, S-18-consultant-answers.md). Extracted all explicit Legion-specific values. Marked all Ollama-specific values [SOURCE-SILENT] per extraction constraint (no invented values). Prepared draft proposals for T1 config.toml and T2 Sprint L-1 wording. Neither proposal applied yet — operator gate required.
- **Key findings:**
  - Primary source (manus-legion-private-engine.md) describes llama-server :8080 + uncensored model — ENTIRE SECTION SUPERSEDED per OPEN-ITEMS-OFFLOAD.md.
  - Technical references still valid: `-ngl 20` (GPU layers), `-c 131072` (context), `max_tokens 8192`, `temperature 0.6`, `top_p 0.95`.
  - Ollama model tag = [SOURCE-SILENT]. Ollama num_gpu = [SOURCE-SILENT]. Ollama quant = [SOURCE-SILENT].
  - G-6 (critical gap): source only documents llama-server; OPEN-ITEMS assumes Ollama. Operator must decide.
- **Artifacts:**
  - `docs/ops/legion-private-engine/OI-LOCAL-1-FINDINGS.md` — NEW: full extraction table, [SOURCE-SILENT] gap registry (G-1..G-6), draft T1 config.toml `[llm]` block, draft T2 Sprint L-1 wording change, operator pre-flight commands.
- **Operator action required (before factory can apply edits):**
  1. `ollama list` — confirm which Qwen3 30B+ model is pulled on Legion.
  2. G-6 decision: Ollama `:11434` OR llama-server `:8080` with censored Qwen3 model.
  3. Return confirmed Ollama tag + num_gpu value → factory updates config.toml + Sprint L-1.
- **Append-only (ADR-059-A):** il_ts 2026-07-11T00:01:00Z strictly > 2026-07-11T00:00:00Z.
- **Refs:** `docs/ops/legion-private-engine/OI-LOCAL-1-FINDINGS.md`, `docs/governance/OPEN-ITEMS-OFFLOAD.md`, `docs/governance/SESSION-STATE.md` §OPEN ITEMS, `docs/ops/legion-private-engine/config.toml` (f9e5d7b — current; needs revision), `docs/architecture/SPRINT-PLAN-TWO-ENGINES.md` (5c41cb1 bdsl-act-prep — Sprint L-1 needs revision).
