# AI Agent Full Inventory — 2026-05-13

Document ID: AUDIT-AI-AGENT-INVENTORY-2026-05-13
Trigger: operator question — what AI groups are in production?
Status: AUTHORITATIVE for 2026-05-13 17:30 CEST snapshot

## Agent groups LIVE in production

| Group | Location | Notes |
|-------|----------|-------|
| LiteLLM canonical | Legion 127.0.0.1:8080 | 17 models, shadow tap, guardrail, master_key in .env |
| LiteLLM MetaClaw | Legion 127.0.0.1:4000 (was 0.0.0.0, fixed PR #269) | LAN-Gateway, master_key sk-banxe-llm-gateway-2026 |
| OpenClaw CTIO bot | evo1 :18791 | Telegram bot Oleg |
| OpenClaw GUIYON Legal | evo1 :18794 | Legal advisor |
| OpenClaw MOA | evo1 :18789 | @mycarmi_moa_bot |
| OpenClaw SOUL Guard | evo1 (oneshot) | Restores SOUL.md after OpenClaw restart |
| GUIYON Dispatcher | evo1 | Task dispatcher via Ollama |
| Banxe Guardian factory | evo1 | Compliance auditor Layer 6 (ADR-019) |
| Banxe Guardian project | evo1 | Compliance auditor Layer 6 (ADR-019) |
| Ollama pool evo1 | evo1 :11434 | 9 models |
| Ollama pool evo2 | evo2 :11434 | 11 models inc. qwen2.5:0.5b classifier |
| llama-server evo1 :8081 | evo1 | C++ tier inference |
| llama-server evo2 :8082 | evo2 | qwen3-235b-Q3_K_S |
| Shadow Classifier Tap | Legion litellm callback | 5+ rows in banxe_audit.hitl_decisions |
| ClickHouse audit sink | evo1 + ssh tunnel | banxe_audit.hitl_decisions, 7y TTL |
| MiroFish | evo1 docker (Up 6 days) | backend 100.68.102.48:5004, UI :3001 |
| Aider CLI | Legion | 0.86.2 |
| Central Claude Code | Legion | --dangerously-skip-permissions, S14.3 |
| Sub-terminal A | Legion shell layer | Sandbox + audits (Perplexity Comet) |

## Ruflo — not a daemon

Location: ~/vibe-coding/ruflo/start-ruflo.sh
One-shot health script. Self-exits after 5 checks.
Known false negatives:
- LiteLLM check has no auth header; canonical :8080 returns 401.
- OpenClaw checks hit localhost on Legion; bots live on evo1.
- MiroFish check hits localhost:5004; engine on evo1.
Patched local copy used for this audit; original untouched.

## MiroFish details

- Container running since 2026-05-06 23:03 UTC, no restart.
- Health: GET http://100.68.102.48:5004/health -> HTTP 200, 116 ms.
- Frontend UI: http://100.68.102.48:3001
- run-simulation.sh default MIROFISH_API=http://localhost:3000/api is wrong for evo1 setup; needs override.

## evo1 crash-loop containers — NOT AI scope

| Container | Symptom |
|-----------|---------|
| workflow-service | cannot reach ballerine-postgres:5432 |
| midaz-ledger | cannot reach Redis 172.22.0.1:6379 (stale network) |
| midaz-mongodb | /etc/mongo/keyfile bad permissions |

Recorded as evidence. Outside Sub-A authority. Recommend separate
incident ticket for CTIO/DevOps.

## Recommendations (operator decision)

1. Patch Ruflo to take HOST + KEY from env vars and probe evo1
   directly via Tailscale.
2. Patch run-simulation.sh MIROFISH_API default to
   http://100.68.102.48:5004.
3. Open incident for ballerine-postgres / midaz-redis / midaz-mongodb.
4. Add MiroFish + Ruflo health to tools/sandbox/smoke-pilot-readiness.

Refs: PR #265 #267 #269, ADR-035, ADR-036, SESSION-CANON Clauses 1..17
