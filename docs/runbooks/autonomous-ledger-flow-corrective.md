# Corrective Runbook — Autonomous GAP-terminal ledger flow

> **Status:** corrective runbook (operational). **Date:** 2026-06-30. **Trigger:** PRs #894–899 (autonomous
> GAP-closure terminal) all failed CI on ledger gates. This runbook is **pointer-first** — it does not restate
> the canon; it points to it and adds the operational recipe + the specific anti-patterns observed.

## 1. Problem (confirmed on `main`, IL max 742)
The autonomous GAP-closure terminal emitted 6 PRs that all fail CI in **two classes**:

| Class | PRs | Failing check | Root |
|---|---|---|---|
| 1 | #894 / #895 / #896 | `guardian-ledger` | doc changed (GAP-REGISTER / COMPLIANCE-MATRIX / ENGINE-ROADMAP / SPRINT-PLAN) with **no paired IL shard** → ADR-056 coupling fail |
| 2 | #897 / #898 / #899 | `guardian-ledger-shards` + `ledger-build` | shard present but **IL number hardcoded / stale** (`IL-743/744/745`, malformed `IL-CBS` / `IL-2026`) → generated ≠ rebuild |

**Structural:** GAP-042 was split across **#896 (doc, no shard) + #897 (shard)** — these must be **one** PR.

## 2. Root cause
The loop **hardcodes `[IL-NNN]`** and/or **skips or splits the shard**, instead of running the authoritative
minter. **ADR-119 forbids hardcoded IL numbers** — the number is a pure function of `IL-SEQUENCE.json` + the
shard set on the up-to-date base (see [parallel-session-isolation Rule 8] and ADR-119).

## 3. Correct flow — apply per PR, every time
1. **Reset onto CURRENT `origin/main`** (never a stale base): `git switch -C <work> origin/main`.
2. **Change the doc AND create its paired IL shard in the SAME PR** (atomic — ADR-056 coupling). **One doc +
   one shard per PR.** Never split doc and shard across two PRs.
   - Shard path: `ledger/entries/<session_id>/IL-<ISO8601Z>--<slug>.md` with frontmatter
     `il_ts` (strictly **>** current `origin/main` max `il_ts`), `session_id`, `source`, `status`.
3. **Do NOT write any IL number by hand.** Run the authoritative minter **FROM ROOT**:
   `python ledger/build_ledger.py` — it assigns `max+1` over current `origin/main` into `ledger/IL-SEQUENCE.json`
   (ADR-119, append-only) and regenerates `INSTRUCTION-LEDGER.md`. There is **no `make il-mint` / `make ledger`
   target and no `il-allocate.sh`** — those do not exist; do not call them.
4. **Read the assigned number back** from `ledger/IL-SEQUENCE.json`; correct every human-facing `[IL-NNN]` (PR
   title, commit subject, doc body) to match the minted value.
5. **Verify before push:** `python ledger/build_ledger.py --check` exit **0** (generated == rebuild + sequence
   append-only); shard↔key **1:1**; **no duplicate** IL values; `ledger/FROZEN-ARCHIVE.md` untouched.
6. **Push lease-protected** (`--force-with-lease`). If the PR goes **behind** before merge: rebase onto the new
   `origin/main` + re-run `build_ledger.py` (it re-mints the next free number). **A duplicate is a rebase
   signal, not a question** (ADR-119 Rule 8) — performed autonomously, never escalated.

## 4. Forbidden (the observed anti-patterns)
- Hardcoded `[IL-NNN]`, or malformed `[IL-CBS]` / `[IL-2026]`-style refs.
- A doc change **without** a paired shard (→ `guardian-ledger` ADR-056 fail).
- **Splitting** a doc and its shard across separate PRs (e.g. GAP-042 #896/#897).
- `make il-mint` / `il-allocate.sh` / any non-`build_ledger` minter (they do not exist).
- Building against a **stale base** (always reset onto current `origin/main` first).

## 5. Result
`guardian-ledger`, `guardian-ledger-shards`, `ledger-build` all green; no more broken GAP PRs.

## 6. Remediation of the existing 6 (separate, operator-gated)
#894–899 are NOT fixed by this runbook — each must be **regenerated per §3** (Class-1 gets a paired shard;
Class-2 keeps its shard with `build_ledger` re-minting; **#896+#897 consolidated** into one GAP-042 PR) **or
closed and re-cut**. This is operator/owning-terminal action (foreign-session — parallel-session-isolation
Rule 6/7).

## Anchors
- `.claude/rules/parallel-session-isolation.md` **Rule 8** (IL frozen at merge-time; never hardcoded; duplicate = rebase signal)
- **ADR-056** (ledger coupling merge gate) · **ADR-057 / ADR-059 / ADR-059-A** (append-only shards) · **ADR-119** (stable/frozen IL numbering, Rule 8)
- `ledger/build_ledger.py` (authoritative minter) · `docs/guardian/guardian-ledger-il-collision-gate.md` (pre-merge collision gate)
- Incident: PRs #894–899 (2026-06-30), guardian-ledger / ledger-build failures.
