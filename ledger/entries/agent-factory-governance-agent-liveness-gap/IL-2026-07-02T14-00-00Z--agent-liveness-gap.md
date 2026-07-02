---
il_ts: 2026-07-02T14:00:00Z
session_id: agent-factory-governance-agent-liveness-gap
source: CEO
status: DONE
---
### [OWNER: A] Agent-Liveness Gap record — verified absence of agent-level 24/7 liveness; node heartbeat is orthogonal; design deferred
- **Decision:** Per operator execute-go (narrow gap-record only), authored `docs/governance/AGENT-LIVENESS-GAP.md` (new) recording the measured absence of any agent-level liveness/24-7 contract at `origin/main @ 69889e8`. Read-only gap record; designs/activates nothing. Changed ONLY this doc + paired shard. NO passport/soul/swarm/.claude-agent edited; NO ADR/config-fleet/project-code/perimeter touched; NO activation; NO mechanism invented; NO runtime asserted. **PREPARE-ONLY**, Draft PR. Owner A.
- **F1:** 0/70 passports declare any liveness/heartbeat/idle/uptime/schedule/run_mode/always_on field (top-level keys, per L-10).
- **F2:** existing fleet heartbeat (`config/fleet/heartbeat-policy.yaml`) is NODE-level only — probes hosts (Legion/evo1/evo2) via host.expected_state; HEALTHY→SUSPECT→UNHEALTHY host transitions. Not agents.
- **F3:** Hermes/ADR-126 = Tier-1 CI/CD Watchdog, read-only/alerting-first, factory-only; names "24/7 specialized agents" as FUTURE work item, not current runtime capability.
- **F4:** therefore NO agent-level liveness mechanism exists (no passport contract, no agent-scoped runtime layer).
- **F5:** measurable CAPABILITY gap, NOT a runtime-incident report — absent by design (F3 parks it), not was-up-then-fell.
- **Node-vs-agent (§3):** node heartbeat answers "is the machine alive"; agent liveness would answer "is the agent meeting its run/idle/uptime contract" — orthogonal; present mechanism covers only the former. Design/impl choice = **[BLOCKING: operator / ADR-gated]**.
- **Boundaries:** ONLY AGENT-LIVENESS-GAP.md (new) + this shard. NO passport/soul/swarm/agent/ADR/config-fleet/project/perimeter change; NO activation; NO runtime claim; NO mechanism designed; NO repo invented. 0 off-scope.
- **Anti-dup (ADR-102) pointer-first:** cites ADR-126, config/fleet heartbeat + SERVER-CONTROL-ORCHESTRATION, FLEET-CONFORMANCE-AUDIT (#972/#973, runtime-out-of-scope), SELF-IMPROVEMENT-MANDATE §4 (agent-harness locus), L-10 — restates none; creates no parallel policy, no mechanism. This record is the dedicated home for the liveness item the fleet audit fenced out-of-scope.
- **Scope/flow:** authored per #900 — doc + paired shard ATOMIC; NO hand-edit of generated ledger; NO hardcoded IL (build_ledger mints, ADR-119 Rule 8). Re-mint if collision: reset onto origin/main + regenerate; recreate shard AFTER reset (L-05); duplicate IL = rebase signal (L-06).
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 817) via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-07-02T14:00:00Z` > main max. Fresh worktree off origin/main (ADR-120/060). FROZEN/.canon untouched. Pinned to 69889e8 (point-in-time).
- **Status:** DONE — gap record + shard. **DRAFT PR; DO NOT MERGE — operator HITL. Next (AWAITS-OPERATOR / ADR-gated): whether/how to close the gap — passport liveness-contract schema, agent-scoped runtime watcher, or ADR-126 future-item extension — a design+governance decision, NOT authored here.**
- **Refs:** `docs/governance/AGENT-LIVENESS-GAP.md` (new); ADR-126; `config/fleet/heartbeat-policy.yaml`; `docs/governance/SERVER-CONTROL-ORCHESTRATION.md`; `docs/governance/FLEET-CONFORMANCE-AUDIT.md` (#972/#973); `docs/governance/SELF-IMPROVEMENT-MANDATE.md` §4; L-10; ADR-102/119/143/144; #900. Operator execute-go 2026-07-02 (agent-liveness capability gap; design deferred).
