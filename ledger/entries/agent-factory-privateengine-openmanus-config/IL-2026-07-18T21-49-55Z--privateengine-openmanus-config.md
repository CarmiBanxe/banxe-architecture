---
il_ts: 2026-07-18T21:49:55Z
session_id: agent-factory-privateengine-openmanus-config
source: CEO
status: DONE
---
### Legion Private Engine — OpenManus operational config (Phase 6 factory build-out, docs-only, PROPOSED)
- **Date:** 2026-07-18 · **Type:** ops-config docs shard (ledger-only; no runtime code in this
  repo — the artifacts describe host-side operational config for the Legion machine itself).
- **Decision:** Record the 3 docs-only files this PR adds under
  `docs/ops/legion-private-engine/` as Phase-6 Legion Private Engine operational tooling, per
  `docs/architecture/two-engines-master-analysis-and-roadmap-canonical-2026-07-10.md` (System B
  — Legion Private Engine, the operator/factory-internal tool-builder, distinct from the
  regulated System A Banking Engine).
- **Files added (docs-only, no activation):**
  1. `docs/ops/legion-private-engine/RUNBOOK.md` — operational runbook for the Legion-side
     OpenManus multi-layer config.
  2. `docs/ops/legion-private-engine/banxe-private-engine.service` — a systemd unit template
     for the Legion Private Engine process (template only — activation is an explicit,
     separate OPERATOR ACTION, matching the same pattern used by `fabric/legion/gate-exec.service`:
     the factory does not start prod services on Legion itself).
  3. `docs/ops/legion-private-engine/config.toml` — the multi-layer OpenManus model-routing
     config (Tier2 `qwen3-30b` default, 4-tier model map, VRAM constraint accounted for).
- **ADR-102/ADR-103 wall (explicitly noted, not re-litigated here):** this is factory-internal
  tooling for the Legion Private Engine (System B) — it is **not** the regulated Banking Engine
  (System A) and carries no FCA/regulatory surface of its own. Per the two-engines analysis,
  Legion's access to the banking zone remains **read-only, logged, no write** — this config
  addition does not change that boundary.
- **Basis (evidence, not memory):** the 3 files themselves (`git diff origin/main --stat`
  confirms exactly these 3, 345 insertions, 0 other changes); the sibling
  `fabric/legion/README.md` / `fabric/legion/gate-exec.service` pattern for "factory does not
  start prod services on Legion — operator activates" is reused as precedent, not duplicated.
- **DoD:** this shard exists solely to satisfy the ADR-056/060 guardian-ledger coupling gate —
  the PR previously carried governance-relevant content (`docs/ops/**`) with zero ledger shards
  (`ledger-files=0`), which is what the gate blocked on. No other change to the PR's content.
- **Canon compliance:** docs-only, no code, no activation of any service, no config/secret
  values touched (`config.toml` and the `.service` template were already present in the PR
  before this shard — this shard adds no new file changes beyond itself); authored in an
  ISOLATED worktree off `origin/main` (ADR-120); branch ADR-060-compliant
  (`agent/factory/privateengine/openmanus-config`); no S320; hooks enabled (no
  `--no-verify`/`--admin`/bypass); STOP before merge for operator.
- **Coupling/append-only:** branch already merged onto `origin/main@c66c198` (pre-existing
  merge commit `3c8ee66` on this branch, not created by this shard); single new shard added
  here; no prior entry modified.
- **Proof (ledger):** `build_ledger.py --check` exit 0 (confirmed after this mint); IL number
  assigned live via the evo1 Redis allocator (`banxe:il:counter`), not hand-picked.
- **Refs:** `docs/architecture/two-engines-master-analysis-and-roadmap-canonical-2026-07-10.md`;
  `fabric/legion/README.md`, `fabric/legion/gate-exec.service` (precedent pattern); ADR-102,
  ADR-103, ADR-119, ADR-120, ADR-060.
