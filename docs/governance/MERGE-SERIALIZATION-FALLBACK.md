---
id: MERGE-SERIALIZATION-FALLBACK
title: Software merge serialization for a user-owned repo (Variant B — concurrency-group + base-drift guard)
status: PROPOSED
date: 2026-06-27
relates:
  - "LEDGER-MERGE-QUEUE.md / OPERATOR-ENABLE-MERGE-QUEUE.md / merge-queue-ruleset.json (the native queue — UNAVAILABLE on a user repo)"
  - "ADR-143 / ADR-143-A (Redis central IL allocator — closes the ID-collision root; this closes the merge/base-drift root)"
  - "ADR-119 (frozen IL numbering), ADR-057/059-A (append-only ledger)"
il_anchor: IL-617
il_anchor_note: "Provisional per ADR-119 Rule 8 — minted by the central allocator (ADR-143/143-A) over current origin/main. Frozen at rebase-before-merge."
---

# Merge serialization fallback (Variant B)

> **Why this exists.** The native **GitHub merge queue** — the clean way to serialize merges into
> `main` — is an **organization-only** feature. This repo is **user-owned**, so the queue cannot be
> enabled (REST returns 422; the Settings UI does not persist it), and **transfer to an org is blocked**
> (the account has no organization). This document + the `main-serialize.yml` workflow are the **durable
> software substitute**.

## The two roots of the IL-duplicate / DIRTY-PR problem

1. **ID collision** — two terminals minting `max+1` against a local counter. **Closed** by the Redis
   central allocator (ADR-143 / ADR-143-A): one atomic `INCR` on the shared evo1 counter.
2. **Merge race / base-drift** — `main` advances while a PR is in flight, so the PR's base goes stale →
   the PR turns **DIRTY/CONFLICTING** (e.g. #832, #825 needed manual rebase). **Closed here.**

## Mechanism — `.github/workflows/main-serialize.yml`

- **Soft serialization via a concurrency group.** `concurrency: { group: "main-merge-serialize",
  cancel-in-progress: false }` — runs **queue in the Actions runner** instead of cancelling each other,
  so base-drift is evaluated one PR at a time.
- **Base-drift guard.** The job checks out the PR head, fetches `origin/main`, and computes
  `behind = git rev-list --count HEAD..origin/main`. If **`behind > 0`** the job **fails** with:
  `BASE DRIFT: PR is N commits behind origin/main — rebase via hard-reset recipe before merge (prevents
  stale-base revert / DIRTY).` It also logs `origin/main` SHA, PR head/merge-base SHAs, and behind/ahead
  counts for the audit trail. `behind == 0` ⇒ exit 0.
- **Net effect:** a PR cannot be merged while behind `main`; the author rebases (hard-reset recipe) so
  the merge always applies to the current tip — no stale-base revert, no surprise DIRTY at merge time.

## Operator action — make it enforcing (Settings, NOT code)

After this PR merges, the operator adds the new check to branch protection so it actually gates merges:

> **Settings → Branches → `main` → Edit → Require status checks to pass before merging →** add the
> context **`main-merge-serialize`** (alongside `guardian-factory`, `guardian-project`, `guardian-ledger`,
> `ledger-append-only`). Keep **Require branches to be up to date (strict)** ON — together they make the
> base-drift guard a hard merge gate.

The workflow ships green-on-merge; it only **blocks** merges once added to required checks. This is a
**settings action**, deliberately not encoded in the repo.

## Upgrade path (remove this fallback later)

If the repo is ever **transferred to an organization**, enable the native merge queue
(`OPERATOR-ENABLE-MERGE-QUEUE.md` + `merge-queue-ruleset.json` are ready). The native queue auto-rebases
and serializes builds, fully superseding this workflow — at which point `main-serialize.yml` and the
required-check entry can be removed.

## Anchors
- `.github/workflows/main-serialize.yml` (this mechanism), `LEDGER-MERGE-QUEUE.md` /
  `OPERATOR-ENABLE-MERGE-QUEUE.md` / `merge-queue-ruleset.json` (native queue, unavailable),
  ADR-143/143-A (allocator), ADR-119/057/059-A. No secrets; CI-only; no ledger mutation beyond this
  record's append shard.
