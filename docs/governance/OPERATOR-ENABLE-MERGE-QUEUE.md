# OPERATOR RUNBOOK — Enable GitHub Merge Queue on `main`

**Repo:** `CarmiBanxe/banxe-architecture`
**Status:** Operator action required (durable fix for the ledger-renumber race) · **Date:** 2026-06-22
**Refs:** `docs/governance/LEDGER-MERGE-QUEUE.md`, `docs/governance/branch-protection.md`, ADR-057 (append-only), ADR-059/059-A (shard ledger), ADR-060 (branch namespace); learning from the PR #637 / #638 / `ledger-merge-queue` race.

> ⚠️ **This runbook is materials ONLY.** Claude Code did **not** apply any of it. Enabling a merge queue
> changes the protection policy on `main`, which is an **operator-privileged change** (repo-admin scope).
> The operator executes ONE of the three paths below under their own credentials and own change-control.

## Why this is needed (one paragraph)

`INSTRUCTION-LEDGER.md` is **generated** from `ledger/entries/**` shards with sequential `IL-NNN` numbering. With
branch protection **strict = true** (require up-to-date) and concurrent ledger PRs, whichever shard sorts earlier
forces a **renumber** of the generated monolith → `ledger-append-only` sees modified lines → the PR flips **DIRTY**.
Manually re-minting `il_ts` only wins until the next concurrent ledger PR lands — a Sisyphus loop. A **merge queue**
auto-rebases each PR onto the latest `main` and runs the required checks **one PR at a time** (build concurrency 1),
so sequential `IL-NNN` numbering never collides.

## Current state (do NOT lose these)

- **Required checks on `main`:** `guardian-factory`, `guardian-project`, `ledger-append-only`, `guardian-ledger`
- **Strict (require branches up to date):** `true`
- **Goal:** ADD `Require merge queue` while **keeping** the 4 required checks + strict.

---

## Path A — GitHub UI (browser)

1. Open `https://github.com/CarmiBanxe/banxe-architecture` and click **Settings** (top nav, repo-admin only).
2. In the left sidebar choose **Rules → Rulesets**.
3. Click **New ruleset → New branch ruleset** (or open the existing `main` ruleset to edit it in place).
4. **Ruleset Name:** `main-merge-queue`. **Enforcement status:** `Active`.
5. Under **Target branches** click **Add target → Include by pattern**, enter `main`, confirm. (The target must
   resolve to `refs/heads/main` only.)
6. In the **Rules** (Branch rules) list, tick ☑ **Require merge queue**. Click its settings/gear and set:
   - **Merge method:** `Squash`
   - **Build concurrency** (Maximum pull requests to build): `1`
   - **Maximum pull requests to merge:** `1`
   - **Minimum pull requests to merge:** `1`
   - **Wait time to merge (minutes):** `0`
   - **Status check timeout (minutes):** `60`
   - **Grouping strategy / merge condition:** require **all** queued PRs green (`ALLGREEN`).
7. Still in **Rules**, tick ☑ **Require status checks to pass**, then:
   - Enable ☑ **Require branches to be up to date before merging** (this is the `strict` flag).
   - Click **Add checks** and add **all four** by exact context name:
     - `guardian-factory`
     - `guardian-project`
     - `ledger-append-only`
     - `guardian-ledger`
8. Review the summary, then click **Create** (or **Save changes** if editing the existing ruleset).
9. Verify: **Settings → Rules → Rulesets → `main-merge-queue`** shows `Active`, target `main`, and both rules
   (merge queue + required status checks) present with the 4 contexts and "up to date" enabled.

---

## Path B — `gh` CLI / REST API (operator runs this themselves)

> The operator runs this under **their own** token with **repo-admin** scope. Claude Code does **not** run any
> `POST`/`PUT` to `/rulesets`. The validated payload lives next to this file:
> `docs/governance/merge-queue-ruleset.json`.

**Create the ruleset:**

```bash
# Run from a checkout that contains docs/governance/merge-queue-ruleset.json
gh api -X POST repos/CarmiBanxe/banxe-architecture/rulesets \
  --input docs/governance/merge-queue-ruleset.json
```

**If a `main` ruleset already exists** and you want to update it instead of creating a new one:

```bash
# 1) find the ruleset id
gh api repos/CarmiBanxe/banxe-architecture/rulesets

# 2) update in place (replace <RULESET_ID>)
gh api -X PUT repos/CarmiBanxe/banxe-architecture/rulesets/<RULESET_ID> \
  --input docs/governance/merge-queue-ruleset.json
```

**Payload — `docs/governance/merge-queue-ruleset.json`** (already validated locally with `jq .`):

```json
{
  "name": "main-merge-queue",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/main"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "merge_queue",
      "parameters": {
        "merge_method": "SQUASH",
        "max_entries_to_merge": 1,
        "max_entries_to_build": 1,
        "min_entries_to_merge": 1,
        "min_entries_to_merge_wait_minutes": 0,
        "check_response_timeout_minutes": 60,
        "grouping_strategy": "ALLGREEN"
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "do_not_enforce_on_create": false,
        "required_status_checks": [
          { "context": "guardian-factory" },
          { "context": "guardian-project" },
          { "context": "ledger-append-only" },
          { "context": "guardian-ledger" }
        ]
      }
    }
  ]
}
```

**Post-apply verification (read-only):**

```bash
gh api repos/CarmiBanxe/banxe-architecture/rulesets \
  --jq '.[] | select(.name=="main-merge-queue") | {id, enforcement, target}'
```

> Note: the `merge_queue` rule and `required_status_checks` rule are kept in a **single ruleset** so strict +
> the 4 contexts are preserved alongside the queue. If your existing branch protection / older ruleset already
> carries those 4 checks, ensure they are **not duplicated or dropped** — the queue must run the same 4 contexts.

---

## Path C — Terraform / change-control warning

> ⚠️ If `main` protection is managed declaratively (e.g. Terraform `github_repository_ruleset`), do **NOT** click-ops
> this: a UI/API change will drift from state and be reverted on next `apply`. Land the equivalent `merge_queue` +
> `required_status_checks` block as a **reviewed Terraform PR** through the operator's normal change-control. Either
> way, enabling the merge queue **modifies the protection policy on `main`** and must go through the operator's
> standard change-control (review + approval), not an ad-hoc apply.

---

## After enabling

- The watcher **`bq7o8d7hx`** picks up the ruleset activation (merge queue now `Active` on `main`).
- **Comet** then finalizes the blocked ledger PRs **sequentially through the queue**: `#637 → #638 → ledger-merge-queue`.
- From this point, **ledger-touching PRs merge ONLY through the merge queue** — no `--admin` force-merge over a DIRTY
  ledger conflict (per `docs/governance/LEDGER-MERGE-QUEUE.md`).

---

## Safety attestation

- Claude Code generated **only** this document and `merge-queue-ruleset.json`.
- **No** `POST`/`PUT`/`DELETE` to `/rulesets` was issued; **no** repository settings were changed.
- The JSON was validated locally with `jq .` (read-only) — syntax OK.
- Nothing was pushed; files exist only in the worktree on branch `agent/factory/governance/ledger-merge-queue`.
