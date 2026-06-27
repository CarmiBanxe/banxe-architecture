# Ledger Merge Queue — serialization rule for ledger-touching PRs

**Status:** Operational rule (2026-06-22) · **Refs:** ADR-059 / ADR-059-A (shard ledger), ADR-057 (append-only), ADR-060 (branch namespace); learning from PR #637 / #638 race.

## Problem
`INSTRUCTION-LEDGER.md` is a **generated** artifact: `python3 ledger/build_ledger.py` composes it from `ledger/entries/**` shards, assigning **sequential IL-NNN** numbers ordered by `(il_ts, session_id, path)`. With branch protection **strict = true** (require up-to-date) and **concurrent** ledger PRs landing on `main`, any PR whose shard sorts before another's causes a **renumber** of the generated monolith → `ledger-append-only` (I-28 / ADR-057) sees removed/modified lines → PR goes **DIRTY**.

## Why manual chasing does not work
Re-minting our shard with `il_ts > main-max` only wins until the **next** concurrent ledger PR lands (main moved 8+ times in one window: `684e5f9→bce00a8→3132ad6→8a3ff08→cc52784→d819937…`). It is a Sisyphus loop — by the time CI is green, `main` has moved and the PR is DIRTY again.

## Durable fix — GitHub merge queue (operator-enabled)
Settings → **Rules → Rulesets → `main`**:
- **Require merge queue** = ON
- **Merge method = Squash**
- **Build concurrency = 1** (serialize: one PR built/merged at a time)
- **Keep** `Require status checks to pass` + **strict (up-to-date)** + current required checks (`guardian-factory`, `guardian-project`, `guardian-ledger`, `ledger-append-only`, …).

The queue **auto-rebases** each PR onto the latest `main` and runs checks **one at a time**, so sequential IL-NNN numbering never collides.

## Operational rule
- **Ledger-touching PRs merge ONLY through the merge queue.** Do not force `--admin` merge over a DIRTY ledger conflict.
- Shard authoring stays append-only: new shard, `il_ts` > current main-max, regenerate, never hand-edit `INSTRUCTION-LEDGER.md`.

## Serialization operating procedure — until the merge queue is operator-enabled (2026-06-27)

> Added per the IL-601→602→603→604 collision streak (Memoir precond series + ADR-141): multiple
> terminals minting `max+1` against a fast-moving `main` with **no active single-writer mechanism**.
> **Audit (2026-06-27):** the GitHub merge queue documented above is **NOT active** — `gh api
> repos/.../rulesets` is empty, `branches/main/protection` shows `required_merge_queue: absent`
> (only `strict=true`), and ledger PRs have been merging via direct `gh pr merge --squash`. So the
> durable single-writer fix is **not yet in place**.

### STOP-and-report (operator action required — the durable fix)
**Operator MUST bring up the GitHub merge queue** on `main` (Settings → Rules → Rulesets → `main`:
Require merge queue = ON, Merge method = Squash, **Build concurrency = 1**), per
`OPERATOR-ENABLE-MERGE-QUEUE.md` + `merge-queue-ruleset.json`. Once active, the queue **auto-rebases and
serializes** each ledger PR, and `max+1` IL numbering can never collide — manual re-minting becomes
unnecessary. **Manual re-minting without the queue is Sisyphean** (see "Why manual chasing does not
work" above).

### Interim single-writer procedure (until the queue is on)
While the queue is off, ledger-touching PRs are merged under a **manual single-writer discipline**:
1. **One ledger PR minted + in flight + merged at a time** — never two fresh mints in parallel.
2. **Re-mint immediately before merge** — rebase the PR onto current `main`, `build_ledger` assigns
   `max+1`, `il_ts` strictly `> current main-max` (+15 min step), single clean commit, `--check` exit 0.
3. **Fixed merge order**, each step waiting for the previous to land on `main` before the next is
   re-minted/merged. No parallelism.

### Current required merge order (stuck PRs to drain, in order)
1. **this note** (serialization procedure) — land first.
2. **#817** — MEMOIR-PILOT-PRECOND-07 (no-authority-expansion).
3. **#818** — MEMOIR-PILOT-PRECOND-08 (expansion-requires-gate, FINAL).
4. **#821** — ADR-141 (self-healing continuous-learning loop).

Each is re-minted under §"Interim single-writer procedure" only when it is its turn. This is
governance-only: **no runtime, no cron, no runner, no secret** is added here — only the operating rule
and the order. The real fix remains: **operator enables the merge queue.**
