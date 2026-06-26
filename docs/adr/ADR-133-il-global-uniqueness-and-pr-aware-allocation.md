---
id: ADR-133
title: IL global-uniqueness gate + PR-aware allocation (CI/deterministic layer; runtime-lease stays out of scope)
status: ACCEPTED
date: 2026-06-26
accepted: 2026-06-26
supersedes: []
amends:
  - "ADR-119 (stable/frozen IL numbering — adds a global value-uniqueness invariant to --check)"
  - "ADR-060 (concurrency model — fills the 'lease when introduced' guidance with a CI/deterministic mint, NOT a runtime lease)"
refs:
  - "ledger/build_ledger.py (check_global_uniqueness + ALLOWED_DUP_VALUES — the implementation)"
  - "scripts/bx-session.sh (il_advisory — PR-aware candidate IL, read-only)"
  - ".github/workflows/ledger-build.yml + guardian.yml guardian-ledger (both run build_ledger.py --check → gate is required)"
relates:
  - "ADR-119 (Rule 8 — no hardcoded [IL-NNN]; mint at merge)"
  - "ADR-060 (§3 lease-when-introduced; §6 Temporal/runtime OUT OF SCOPE → banxe-ai-infrastructure)"
  - "ADR-125 (IL-540 duplicate precedent — the historical dup this gate allowlists)"
  - "PR #799 (known-debt record: IL-540 dup, souls↔matrix, uniqueness proposal)"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
il_anchor: IL-556
il_anchor_note: "Minted IL-556 by build_ledger as max+1 over origin/main (main max = 555 after #798/#796/#795/#799 merged) at rebase-before-merge (ADR-119 Rule 8; prior provisional 552)."
scope: BANXE-factory-only
concept_only: true
---

# ADR-133 — IL global-uniqueness gate + PR-aware allocation (CI / deterministic layer)

## Context

Two IL-value collisions (our in-flight `IL-550 ×2` across #795/#796 before reconcile; the historical
`IL-540 ×2` of ADR-125, #787+#797 merged) share one root cause: **`build_ledger.py` enforces shard
identity only by filesystem path** (`shard_key`, the path-hash at line ~77), **never by IL value**.
So two shards can hold the same IL number and `--check` does not notice — it verifies
`ledger==rebuild`, `seq==rebuild`, and append-only, but **not global value-uniqueness**. The
`IL-540` duplicate proves the gap slipped through to merged `main`.

The fix must NOT add a runtime dependency. **ADR-060 §3** promises runtime leases (Redis/etcd/Consul)
"when introduced", and **ADR-060 §6** explicitly places runtime orchestration (Temporal/saga) and the
like in **`banxe-ai-infrastructure` as OUT OF SCOPE for this architecture repo**. `banxe-redis` exists
but is not reachable from CI — a runtime-Redis lease here would be a fragile CI dependency and a
scope breach. Therefore the atomic-allocation root is closed at the **CI / deterministic layer only**.

## Decision

1. **(a) Global value-uniqueness invariant.** `ledger/IL-SEQUENCE.json` values MUST be globally
   unique. `build_ledger.py --check` (and the write path) now run `check_global_uniqueness()` —
   any value assigned to >1 shard FAILS (exit 1). This closes the path-only `shard_key` gap.
   - **Allowlist (renumber forbidden, ADR-119):** the pre-existing `IL-540` duplicate is accepted as
     known-debt via `ALLOWED_DUP_VALUES = {540}`. It is NOT renumbered (ADR-119). **New** duplicates
     are rejected. A future dedup of 540 (without renumber) removes it from the allowlist.
2. **(b) PR-aware allocation.** `scripts/bx-session.sh` computes, at session start, a **read-only
   advisory candidate IL = max(IL-SEQUENCE.json values, max IL-NNN across OPEN PR titles) + 1** — so a
   new session sees in-flight (unmerged) IL claims, not just `main`. It prints the candidate and a
   Rule-8 caution; it **writes nothing** and does not change the mint.
3. **(c) Runtime-lease stays out of scope.** This ADR adds **no** Redis/etcd/Consul/Temporal
   dependency. Per ADR-060 §6, any runtime (non-CI-writer) lease belongs in `banxe-ai-infrastructure`.
   Here we provide only the **CI gate + deterministic guidance**; minting remains `max+1` (unchanged).
4. **Required gate, no workflow churn.** Because the uniqueness check lives inside
   `build_ledger.py --check`, and that command already runs in **`ledger-build.yml`** and the
   **`guardian-ledger`** job (`guardian.yml`), the gate is **automatically required** — no new job and
   no YAML edit. The `540` allowlist prevents a false failure on the historical dup.

`build_ledger.py` mint logic (`assign`, `max+1`) is **unchanged**; this ADR adds validation +
guidance, not a new allocator.

## Duplication Audit (ADR-102)

1. **Repo-wide search** — no prior IL-uniqueness/PR-aware-allocation ADR; `check_global_uniqueness`,
   `ALLOWED_DUP_VALUES`, and the `bx-session.sh` advisory do not exist. #799 only *records* the debt;
   this ADR *implements* the (a)/(c) parts of that record (cross-linked).
2. **Source-of-truth + consumers.** Mint source-of-truth stays `build_ledger.assign` (untouched);
   this adds a validator + an advisory. No consumer relies on duplicate values.
3. **No runtime dependency / no scope breach** — ADR-060 §6 honored (no Temporal/Redis here).
4. **Decision per match:** build_ledger validator + bx-session advisory + ADR-133 → **ADD**; mint
   logic, existing ADRs, the 19 souls, and PRs #795/#796/#798/#799 → **KEEP / untouched**.

## Consequences

- A new IL value-duplicate can never reach `main` again — caught by a required CI gate; the historical
  `IL-540` is contained (allowlisted), not renumbered.
- Sessions get a PR-aware candidate that already accounts for in-flight claims, reducing accidental
  collisions at creation — while Rule 8 (mint-at-merge, no hardcode) remains the binding rule.
- **No runtime change, no new dependency**; runtime leases remain an `banxe-ai-infrastructure`
  concern (ADR-060 §6). Concept/CI-only.

## Anchors

- `ledger/build_ledger.py` (`check_global_uniqueness`, `ALLOWED_DUP_VALUES`; wired into `--check` +
  write path; `assign` unchanged), `scripts/bx-session.sh` (`il_advisory`).
- `.github/workflows/ledger-build.yml`, `.github/workflows/guardian.yml` (`guardian-ledger`) — already
  run `--check`, so the gate is required without edit.
- ADR-119 (Rule 8), ADR-060 (§3 lease-when-introduced, §6 runtime OUT OF SCOPE), ADR-125 (IL-540
  precedent), ADR-102; PR #799 (debt record). Enforcement = CI gate; runtime-lease = out of scope.
