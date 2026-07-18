# Factory session-state handoff — 2026-07-18 (evo1 blocker pause)

<!-- Source: docs/runbooks/FACTORY-SESSION-STATE-2026-07-18.md | Date: 2026-07-18 | Status: DRAFT (docs-only) | IL: pending-shard (allocator down, see §3) -->

> **Status: DRAFT.** Handoff only — nothing pushed, nothing merged, no ledger shard minted.
> Written from the isolated worktree `agent/factory/govops/s-fac-60-evo1-remediation`, held
> locally, per I-71 single-writer discipline while the evo1 Redis IL-allocator is down.

## 1. Blocker

**evo1 (`100.68.102.48`) has been down 12h+ (SSH: 22 refused, Redis: 6379 refused), last
re-checked 2026-07-18T23:14:23+02:00** (ICMP OK — 0% loss, ~4ms RTT; both TCP ports refused).
Root cause tracked as **S-FAC-60 / S-FAC-61 (R0)**. This is **not fixable from Legion** — SSH to
evo1 is itself down, so remediation requires **physical/console access to evo1**, not a remote
command from this session.

**Repair procedure:** `docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md` §3, command
blocks **A–G** (bring up sshd → docker → redis (`banxe-redis`) → `midaz-ledger`/`mongodb`/
`workflow-service` → reconcile the `:9108`/`:9207` control-plane port → firewall check if still
needed). Hand that command block to the operator/repair crew.

**Downstream effect:** Redis IL-allocator down ⇒ `build_ledger.py` fails loud (per this
session's explicit no-fallback discipline: **no local `max+1` substitute is used**) ⇒ no ledger
shard can be minted right now ⇒ all factory ledger-writing work is paused (I-71), and PR #1126
(`banxe-architecture`, Legion private-engine config) stays blocked on its `guardian-ledger` check
for the same reason.

## 2. Work completed this session — all local, unpushed

**Branch:** `agent/factory/govops/s-fac-60-evo1-remediation`, **3 commits ahead of
`origin/main`**, confirmed not on `origin` (`git ls-remote` empty). Worktree:
`/home/mmber/wt/s-fac-60-evo1-remediation`.

| Commit | File | Summary |
|---|---|---|
| `848862b` | `docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md` | evo1 remediation runbook — incident summary, ranked root-cause hypotheses, operator/repair-crew console command blocks A–G, verification-from-Legion block, quarantine fallback, `[UNKNOWN]` section, post-recovery TODO. |
| `038437c` | `docs/runbooks/S-FAC-61-health-contract-2026-07-18.md` | Health-contract runbook — de-facto contract table derived from `config/traffic-light.env`/`scripts/traffic-light.sh`. **Finding:** keycloak root-cause+fix and legion `redis-cli` install were already **DONE** per `INSTRUCTION-LEDGER.md` IL-487 (2026-06-23), independently re-verified live today (keycloak container healthy 30h+, `redis-cli 7.0.15` present) — the new work is the contract table itself, which didn't exist as an artifact before. Flags an **S-FAC-61 vs S-FAC-62 sprint-numbering discrepancy** between IL-487 and the current roadmap table (not resolved). |
| `d5166e4` | `docs/runbooks/S-FAC-67-orchestration-enforcement-2026-07-18.md` | Orchestration-enforcement spec (design only, no code). **Verdict:** skill-sequence ordering (CMS→RSB→ACG→…) is **not** mechanically enforced anywhere — the 6 hooks the specs name (`il_gate.py` etc.) don't exist as files in either repo; `quality-gate.sh` **is** genuinely enforced, verified live via GitHub branch-protection required-status-checks on both `banxe-architecture` and `banxe-emi-stack`. Flags **3 unreconciled scenario→sequence sources** (`.claude/rules/agents.md`'s compact table + FA-5 chain, `docs/SKILLS-ORCHESTRATION.md`'s full table). |

## 3. Resume sequence — exact steps for when the allocator returns (`redis-cli ... ping` → `PONG`)

```
(a) Mint the ledger shard for each of the 3 runbooks above via build_ledger.py (evo1 allocator,
    append-only) — confirm added=+3 / mutated=0 / removed=0 across the 3 shards, and
    `build_ledger.py --check == OK` after each.

(b) Unblock PR #1126 (agent/factory/privateengine/openmanus-config, banxe-architecture) — mint
    its own required shard the same way; re-poll `gh pr view 1126` and confirm `guardian-ledger`
    flips from FAILURE to SUCCESS.

(c) Push this branch (agent/factory/govops/s-fac-60-evo1-remediation) and open PRs for the 3
    runbooks — operator merges per §5 (no --admin/--force/--no-verify).

(d) Re-run scripts/traffic-light.sh once evo1's services are confirmed up (per the S-FAC-60
    runbook §4 verification block) — expect GREEN on the evo1-control-plane and any newly
    reachable probes.

(e) Resume the roadmap sequence proper: R3 skill-adoption work (S-FAC-66 binding, S-FAC-67
    implementation PR built against whichever scenario-source decision the operator makes —
    see §4) → R5 100%-adoption-gate close-out.
```

## 4. Open operator decisions carried forward (not resolved by this session — do not resolve silently)

1. **`:9108` vs `:9207`** — which port is the real evo1 control-plane health endpoint
   (`docs/runbooks/evo1-control-plane-bringup-2026-06-17.md` says `:9108`; `config/traffic-light.env` probes `:9207`). Flagged in both the S-FAC-60 and S-FAC-61 runbooks.
2. **Which scenario→sequence table is canonical** for S-FAC-67 — `docs/SKILLS-ORCHESTRATION.md` (named canonical by `SKILLS-OPERATING-MODEL.md` §8) vs. the later, unreferenced "FA-5" agent-chain table in `.claude/rules/agents.md` (different actors: Ruflo, OpenClaw gateway-*, mlro_agent). Flagged in the S-FAC-67 spec.
3. **S-FAC-61 vs S-FAC-62 sprint numbering** — `INSTRUCTION-LEDGER.md` IL-487 labels the legion keycloak/redis-cli work "S-FAC-62"; the current roadmap table labels it "S-FAC-61". Flagged in the S-FAC-61 runbook.
4. **`enforce_admins: false` on `banxe-emi-stack` main** (verified live via `gh api .../branches/main/protection`) — a narrow admin-override bypass path that predates and is independent of anything this session added; `banxe-architecture` main already has `enforce_admins: true`. Flagged in the S-FAC-67 spec as a standalone governance decision to raise, not a recommendation to flip.

## 5. Bank-memo pointer for the Central terminal

The separate four-floor bank-building architecture memo produced earlier this session is not a
file in this repo — it exists only as this session's chat transcript and a published HTML
artifact. Pointers, not duplicated here:

- Transcript: `/home/mmber/.claude/projects/-home-mmber-banxe-emi-stack/350981a0-*.jsonl`
- Artifact: `agent-fleet-audit.html`

**Recommend:** save both to a permanent DRAFT location (e.g. `docs/architecture/` in
`banxe-architecture`, or wherever the operator keeps cross-session memos) — right now they only
exist as session-local artifacts and would be lost to a future session without an explicit save.
Not done here (out of scope for this handoff; flagged only).

## Duplication Audit (ADR-102)

Reused, not duplicated: the 3 runbooks already on this branch (summarized in §2, not restated in
full), `INSTRUCTION-LEDGER.md` IL-487 (referenced, not re-quoted), branch-protection API results
already gathered for the S-FAC-67 spec (referenced, not re-fetched). No existing session-state
handoff doc was found for this specific pause — new, non-duplicate artifact.

**Refs:** `docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md`,
`docs/runbooks/S-FAC-61-health-contract-2026-07-18.md`,
`docs/runbooks/S-FAC-67-orchestration-enforcement-2026-07-18.md`,
`docs/roadmap/FACTORY-ROADMAP-2026-06-23.md`, PR #1126 (`banxe-architecture`), ADR-102.
