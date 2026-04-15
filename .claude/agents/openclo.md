---
name: openclo-moa
description: OpenClaw Mixture of Agents gateway — 10 Banxe agents on GMKtec
---

# OpenClo MOA — Consensus Protocol

## Architecture
- Gateway: port 18789, @mycarmi_moa_bot
- Config: /opt/openclaw/.openclaw/openclaw.json
- 10 parallel Banxe agents

## Consensus Mechanism (MANDATORY)
1. All 10 agents vote on each decision
2. Consensus = weighted majority (not simple majority)
3. Credibility scoring: agents with higher historical accuracy get higher weight
4. Minimum threshold: consensus ≥70% required for AUTO action
5. If consensus <70% → ESCALATE to human (MLRO or CEO)
6. Tie-breaking (5:5): ALWAYS escalate, never auto-decide

## Credibility Scoring
- New agent: weight = 1.0 (default)
- After 100 decisions: weight adjusted by accuracy rate
- Agent with <60% accuracy: weight reduced to 0.5
- Agent with >90% accuracy: weight increased to 1.5
- Recalibrate weights monthly

## Logging
All votes logged to ClickHouse banxe.agent_consensus with:
- agent_id, decision, confidence, weight, timestamp, consensus_result
