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
