# Factory Orchestration & Training Block Audit — 2026-05-13

Document ID: AUDIT-FACTORY-ORCHESTRATION-2026-05-13
Trigger: operator request — audit factory AI orchestration and locate training block
Status: AUTHORITATIVE for 2026-05-13 22:55 CEST

## 1. Canonical LiteLLM :8080 (Legion)
18 model_name entries including project-reason / factory-heavy /
reasoning-235b (new today via PR #273), classifier-qwen2.5-0.5b
shadow tap, fallback-claude guardrail-gated. default + banxe/operations
+ ollama/glm-flash + ollama/llama3.3-70b + ollama/qwen3.5-35b each
load-balanced across evo1 and evo2.

## 2. MetaClaw LiteLLM :4000 (Legion)
35+ aliases (factory-fast, factory-mid, factory-heavy, factory-coder,
project-reason, project-mid, qwen3-banxe, glm-4.5-air-distributed,
reasoning x5, ai, ai-heavy, large, coding, fast, gpt-oss-20b).
Currently idle (only localhost health pings). Bound to 127.0.0.1
since A-8 mitigation (PR #269).

## 3. Coding agents (factory side)
- Claude Code 2.1.128 — primary factory agent, Anthropic API direct.
- Aider 0.86.2 — config ~/.aider.conf.yml uses ollama_chat/qwen3.5-abliterated:35b direct (bypasses LiteLLM).
- Cursor 2.6.20 — config ~/.cursor/config.json.
- Codex CLI 0.106.0 — config ~/.codex/auth.json.
- Continue plugin — present, no explicit config file found.

## 4. Custom Ollama models (prompt overlays, not gradient finetune)
- qwen2.5-coder:14b-banxe-factory on Legion (9 GB), num_ctx 16384, temp 0.1.
- qwen3:235b-a22b-banxe on evo2 (142 GB), tool-calling template.

## 5. Training block — FUNCTIONAL (verified by dry-run 2026-05-13)
Primary scripts: ~/vibe-coding/scripts/{train-agent.sh, apply-feedback.sh, protect-soul.sh}
Compliance set: ~/banxe/developer-core/compliance/training/{promptfoo.yaml, feedback_loop.py, adversarial_sim.py}
HITL feedback: ~/banxe-emi-stack/services/hitl/feedback_loop.py
Global promptfoo: ~/.promptfoo/promptfoo.yaml

Dry-run today: train-agent.sh --agent kyc-specialist-v2 --rounds 5
--categories A,B,C,D,E --dry-run produced 100 percent accuracy on
5 scenarios, 0 errors, 0 HITL triggers, auto-commit 502c02c.
WARNING: REFUTED recall = 0 percent — red line detection gap.

## 6. AMLGentex — independent research project
~/AMLGentex/scripts/train.py — graph-neural-network (LogReg, MLP, GCN,
GAT, GraphSAGE) for AML classification. Not part of LLM finetune.

## 7. Factory agent passports (.claude/agents/)
9 declared: CMS, RSB, ACG, CAE, EHS, PS, DO, STG, ARP.
Chained per .claude/rules/agents.md.

## Gaps vs canon (A4-orchestration-proposal)
- factory-fast / factory-mid / factory-coder absent from canonical :8080 (MetaClaw-only).
- Aider goes direct Ollama instead of LiteLLM (no guardrail / no audit).
- Claude Code uses Anthropic API direct (not factory-mid via LiteLLM).
- project-reason -> evo2 235B aligned (PR #273).
- Guardian-shim active per .claude/settings.json hook.
- MetaClaw remains out of production loop (canon compliant).

## Optimisation recommendations
1. Mirror factory-fast / factory-mid / factory-coder aliases into
   canonical :8080 model_list so all factory traffic uses one gateway.
2. Re-point Aider model to openai/factory-mid via
   http://127.0.0.1:8080/v1 with LITELLM_MASTER_KEY.
3. Schedule weekly promptfoo eval as systemd user timer; sink results
   into banxe_audit.training_runs (new ClickHouse table) or
   hitl_decisions.
4. Expand kyc_specialist.json with Cat-B / Cat-C adversarial scenarios
   to lift REFUTED recall above 90 percent.
5. Document Aider, Cursor, Codex, Continue endpoints in a single
   factory routing map (docs/runbooks/factory-routing-map.md).

Refs: PR #265, #267, #269, #271, #273, ADR-003, ADR-019, ADR-024,
ADR-026, factory-project-stack-2026-05.md, A4-orchestration-proposal,
SESSION-CANON Clauses 1..17.
