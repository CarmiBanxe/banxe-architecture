---
il_ts: 2026-06-26T18:00:00Z
session_id: agent-factory-governance-hermes-stack-canon
source: CEO
status: DONE
---
### ADR-127 — Hermes Tier-1 delegation contract in the Software Factory pipeline (read-only observer, HITL-safe)
- **Decision:** Created `docs/adr/ADR-127-hermes-factory-delegation-contract.md` (PROPOSED, concept_only) detailing the delegation/handoff contract for the Hermes Tier-1 role within the exact bounds of ADR-126. Hermes participates in the Factory pipeline **only as a read-only observer + alert producer**: it may observe orchestration/spec/lock state and forward read-only signals (benchmark deltas, failing spec-to-code tasks, coverage regressions) as operator alerts, plus research-fetch assist via browser/SSH/cron gateways feeding human decisions. **OUT OF SCOPE (hard boundary, new ADR + operator HITL required):** task dispatch / orchestration (no `ruflo run`, no Lock-0 spec assignment, no NanoClaw trigger, no OpenClaw coding drive — does NOT replace Tier-0), merge / deploy authority, compliance authority. No runtime code, no agent passport / soul / config stub. Coupling shard per ADR-059 (build_ledger); append-only (ADR-059-A), il_ts strictly > origin/main max `2026-06-26T17:00:00Z`. Minted IL-547 (= max+1 over origin/main 546).
- **Refs:** `docs/adr/ADR-127-hermes-factory-delegation-contract.md` (NEW); ADR-126 (Hermes Tier-1 role, parent), ADR-117 §Hermes (perimeter), ADR-025 (agent-interaction/handoff canon), ADR-103 (server-only), ADR-102 (Duplication Audit); `.claude/rules/agents.md` (ARL/Ruflo BUG-005, HITL BUG-007); research artifact `Hermes-Agent-Razbor-i-primenenie-v-EMI-BANXE-AI-Bank-i-Software-Factory.md` (attached, referenced — not duplicated). PR #794.
