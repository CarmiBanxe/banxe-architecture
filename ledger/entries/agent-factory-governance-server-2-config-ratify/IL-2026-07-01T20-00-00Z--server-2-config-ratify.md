---
il_ts: 2026-07-01T20:00:00Z
session_id: agent-factory-governance-server-2-config-ratify
source: CEO
status: DONE
---
### [OWNER: A] Ratify server-2 borrow-policy config — operator (CEO) accepted proposed defaults as-is
- **Decision:** Per operator "принял предложенные дефолты как есть", ratified `config/compute/server-2-borrow-policy.yaml` (#932/IL-778). Changed ONLY the config + this paired shard. `status: proposed → ratified`; added a `ratification:` block (ratified_by `operator (CEO)`, ratified_at `2026-07-01`, basis, outstanding); cleared the `[RATIFY]` markers off the accepted borrow thresholds and recorded them as ratified in the `ratify:` ledger. **PREPARE-ONLY**, Draft PR. Owner A.
- **Ratified values (pinned as-is, no numeric change):** concurrent_ceiling=1, idle_grace_s=90, drain_deadline_s=120, max_runtime_s=900, daily_budget_tokens=2000000, runaway_kill_after_s=1200, factory_borrow.max_duty_cycle=0.30, project_batch.max_duty_cycle=0.60.
- **Still [RATIFY] (NOT invented):** `workload_classes.project_critical.runtime_cap_s` / project_critical SLO — project-owned, awaits project SLO; left as `null` placeholder + `status: RATIFY`. Operator gave no number → not fabricated.
- **Verified:** YAML valid (yaml.safe_load); `status==ratified`; ratification block present; every borrow value equals the accepted value (asserted); project_critical runtime_cap_s still `None`; exactly one `ratify` entry remains `status: RATIFY` (the SLO). Policy STRUCTURE unchanged (only status/metadata/markers); values byte-equal.
- **Boundaries:** governance document `SERVER-2-BORROWABLE-COMPUTE-ORCHESTRATION.md` NOT touched; NO code/runtime-enforcer/scheduler; LiteLLM gateway configs NOT touched; hardware/machines NOT touched; banxe-ui NOT touched; uiux-pipeline.sh NOT touched. Only the config YAML + this shard. 0 off-scope.
- **Anti-dup (ADR-102) pointer-first:** in-place ratification of the single existing config; references the policy doc (#932) — no duplication, no parallel config, no structure fork.
- **Scope/flow:** authored per #900 — config + paired shard ATOMIC; NO hand-edit of generated ledger; NO hardcoded IL (build_ledger mints, ADR-119 Rule 8).
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 779) via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). #932/IL-778 + crt2planes IL-778/779 landed mid-session → re-seeded ledger + regenerated per "a duplicate is a rebase signal, not a question"; 779 retained, append-only, 0 renumber. Append-only: ONE tail shard, il_ts `2026-07-01T20:00:00Z` > main max. Rebased onto current origin/main `325cefc` (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — config ratified + shard. **DRAFT PR; DO NOT MERGE — operator HITL. Next: project SLO for project_critical (project-owned, when available); then runtime-enforcer slice (project/infra-side, downstream).**
- **Refs:** `config/compute/server-2-borrow-policy.yaml`; `docs/governance/SERVER-2-BORROWABLE-COMPUTE-ORCHESTRATION.md` (#932/IL-778); ADR-102/119/143/143-A/144; CLAUDE.md §10; #900. Operator directive 2026-07-01 (ratify defaults as-is).
