---
il_ts: 2026-07-01T22:00:00Z
session_id: agent-factory-crts5fix-correct-235b-and-redis
source: factory
status: DONE
---

### IL — COMPUTE-ROUTING §5.2/§5.5 substantive correction (docs-only, 2026-07-01)

**Date:** 2026-07-01
**Branch:** `agent/factory/crts5fix/correct-235b-and-redis`
**Scope:** docs-only, in-place amendment of the EXISTING merged `docs/agent-engine-dossier/COMPUTE-ROUTING-TAXONOMY.md` (§5 landed as PR #927 / IL-779). Fixes verified factual errors in §5.2 + §5.5 identified by read-only audit 2026-07-01. §1/§5.1/§5.3 untouched (correct as merged). ADR-102 reconcile-not-duplicate.

- **Instrukciya:** Correct two factual errors in §5 introduced by the earlier amendment — the §5.2 "heavy routes exist on paper / 235b idle" framing and the §5.5 preconditions list (over-listed "warm 235b" + implicit "Redis-down" overstatement). Do NOT restate §1 / §5.1 / §5.3. Do NOT touch runtime / LiteLLM / ollama config. Docs-only + one paired shard.

- **Ground truth (verified read-only, 2026-07-01):**
  1. **235b is LIVE, not idle.** `reasoning-235b` backend is the `llama-server` at `192.168.0.15:8082`; `curl :8082/v1/models` returns `qwen3-235b-Q3_K_S.gguf`. The prior "`ollama ps` empty" observation measured the **wrong stack** — a separate, unused ollama copy on evo2 `:11434`, irrelevant to `reasoning-235b`. `project-reason` routing is therefore **functional today**, not "on paper".
  2. **Redis IL-allocator is durable.** `banxe-redis` runs `netmode=host`, `restart=unless-stopped`, binds tailscale `100.68.102.48:6379` with vault AUTH pass-file. The mid-session `WARN unreachable` was a **transient blip**, not a durability gap. (The separate `redis` container on `:16379` with `restart=no` belongs to the **jube stack** — a different service, not the allocator.)
  3. **Only one genuine open precondition remains:** install **Node.js + Claude-Code CLI on evo2** and complete a **durable `/login`** — unblocks Plan-1 parallelism (concurrent Claude builds on evo1 and evo2). Verified 2026-07-01 on evo2: `node` = NONE, `npm` = NONE, `claude` = ABSENT.

- **Root-cause clarification (added to §5.5):** the ledger merge-conflict churn observed across recent PRs is caused by **concurrent regeneration of `INSTRUCTION-LEDGER.md` / `IL-SEQUENCE.json` between parallel PRs**, not by Redis. The durable serializer is the **GitHub Merge Queue (ADR-060 §1)**; the Redis allocator mitigates number collisions but does not serialize regeneration order. Prior framings that treated "Redis down" as the churn root cause were **overstated**.

- **Edits (docs-only, 1 file, ~29 insertions / ~14 deletions):**
  - `docs/agent-engine-dossier/COMPUTE-ROUTING-TAXONOMY.md` §5.2: reframe "on paper / idle" → "live, not on paper", cite the evo2 `llama-server :8082` endpoint + `curl :8082/v1/models` proof, name the wrong-stack (`:11434` ollama copy) as the source of the earlier misread; remove the "warm 235b" precondition.
  - Same file §5.5: reduce preconditions from three items to ONE (evo2 Node.js + Claude-Code CLI + durable `/login`); drop the "warm 235b" item and the "confirm resolves to RPC master / dead standalone" item (superseded by corrected §5.2). Add the root-cause note above.
  - Added the dated correction breadcrumb inline at the head of §5.2: `§5 correction 2026-07-01: prior §5.2 "235b idle" + §5.5 Redis-precondition were wrong-stack/overstated — corrected per verified read-only audit.`

- **Boundaries (0 off-scope):**
  - **NOT touched:** §1 canonical alias table, §5.1 Plan-1 (Claude-Code build-dispatch), §5.3 RPC-mesh, §5.4 verified cluster facts, §5.6 cross-refs. §2/§3/§4 unchanged.
  - **NO runtime, NO LiteLLM/ollama config edit, NO secret, NO shell mutation, NO foreign shard/branch touched** (Rules 6/7). One tail shard, append-only (ADR-059-A / I-24).

- **Anti-dup (ADR-102) pointer-first:** in-place amendment of the merged §5; no parallel doc, no duplicated section, no fork. Prior §5 shard (`agent-factory-crt2planes-plan1-plan2-amendment__…` → IL-779 on `main`) referenced; this correction supersedes only the §5.2/§5.5 wording it named.

- **Proof:** IL provisional (ADR-119 Rule 8) — `python3 ledger/build_ledger.py` FROM ROOT mints `max+1` over current `origin/main` (minted IL-790 after re-rebase onto main post-#940 IL-789; ADR-119 Rule 2 — never hardcoded). Append-only: ONE tail shard, `il_ts=2026-07-01T22:00:00Z` > `origin/main` max (`21:00:00Z`). Fresh worktree off `origin/main` (ADR-120/060). FROZEN/`.canon` untouched. `--check` MUST exit 0.

- **Gates target:** `guardian-ledger`, `append-only`, `shards`, `branch-naming` (ADR-060 `agent/<actor>/<slug>/<sub>` shape), `Secrets-Scan`, `adr-traceability` — all green.

- **Status:** DONE — doc correction + shard authored. **Draft PR; DO NOT MERGE — operator HITL per task contract.**

- **Refs:** `docs/agent-engine-dossier/COMPUTE-ROUTING-TAXONOMY.md` §5.2/§5.5; prior §5 shard (IL-779, PR #927 / agent-factory-crt2planes-plan1-plan2-amendment); ADR-102 (reconcile-not-duplicate); ADR-103 (server-only refactor); ADR-060 (branch actor namespace + Merge Queue §1); ADR-119 Rule 8 (IL frozen at merge-time); ADR-059-A (append-only shards); ADR-120 (per-session worktree); I-24 (append-only audit); I-32/I-33 (LiteLLM :4000 single entrypoint — not mutated).
