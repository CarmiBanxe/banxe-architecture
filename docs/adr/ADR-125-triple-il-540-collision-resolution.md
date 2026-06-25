---
id: ADR-125
title: Resolve triple IL-540 collision across PR #787/#788/#789 via sequential rebase-at-merge
status: ACCEPTED
date: 2026-06-25
accepted: 2026-06-25
supersedes: []
related:
  - "ADR-119 (stable/frozen IL numbering — merge-time freeze, append-only sequence)"
  - ".claude/rules/parallel-session-isolation.md Rule 8 (IL number frozen at merge, never asserted at creation)"
  - ".claude/rules/parallel-session-isolation.md Rule 5 (cross-session ledger conflicts — both append-blocks remain)"
  - "ADR-123 (Claude permissions hardening — PR #787, the GATE for this resolution)"
  - "ADR-124 (claude-code-setup plugin eval — PR #789, gated on ADR-123)"
  - "ADR-103 (server-only refactoring; operator ~/.claude apply is out-of-repo, factory does NOT perform it)"
il_anchor: IL-545
il_anchor_note: "Frozen at this PR's rebase-before-merge (ADR-119 Rule 8) to IL-545 = max+1 over resolved origin/main (max 544). The original plan projected IL-543, but two unrelated PRs interleaved (#791→IL-541, #792→IL-543), shifting actuals to #787=540, #788=542, #789=544, this=545 — see Amendment 2026-06-25."
scope: BANXE-only
concept_only: true
---

# ADR-125 — Resolve triple IL-540 collision across PR #787/#788/#789 via sequential rebase-at-merge

## Context

Audit on **2026-06-25** (HEAD = `ec95496`, current `origin/main` max = **IL-539**, ADR max in
`docs/adr/` = **ADR-122**) found a **triple IL-540 collision**: three independent open PRs each
hardcoded the same `[IL-540]`:

| PR | Branch | ADR | Role |
|---|---|---|---|
| **#787** | `agent/factory/governance/claude-permissions-hardening` | **ADR-123** — Claude permissions hardening; protect `main` from a global `git push:*` allow | **primary** (the others depend on it) |
| **#788** | `agent/factory/governance/adr-123-operator-apply-runbook` | (runbook for ADR-123) | depends on ADR-123 |
| **#789** | `agent/factory/governance/adr-092-claude-code-setup-plugin-eval` | **ADR-124** — eval `claude-code-setup` plugin (read-only), gated on ADR-123 | depends on ADR-123 |

All three branched from `main@ec95496` (max IL-539) and **each independently took `max+1 = IL-540`**.
This is the exact failure ADR-119 + parallel-session-isolation **Rule 8** describe: with no atomic
IL allocation across concurrent worktrees cut from one base, every branch's `build_ledger.py` run
deterministically assigns the same `max+1`. (See the prior precedent: PRs #744/#749/#751, IL-503/504/505.)

This ADR does **not** merge anything. It fixes the **deterministic resolution order** and the
**verify contract** so the three PRs serialize onto unique, strictly-increasing IL numbers, and it
records the root cause + a preventive follow-up.

### Hard dependency — the verify GATE (ADR-123 / PR #787)

ADR-123's runtime verify is **GREEN** as of **2026-06-25** — the operator has applied
`~/.claude/settings.json` and the factory verified it **read-only**: gate-1 `skipDangerous`
**absent**; gate-2 push-**deny** for `main` **present** (`Bash(git push origin main)` and variants);
gate-3 push-**allow** carries **no bare `git push:*`** (only scoped `Bash(git push origin *)`, with
`main` explicitly denied → deny wins). The apply itself is an **operator, out-of-repo step**
(ADR-103: server-only / operator-owned `~/.claude`) — **the factory does NOT perform it**, it only
verifies the reported result. The GATE below is therefore **satisfied**; Steps A–C have merged and
this PR (Step D) is unblocked (still DO NOT MERGE until operator dispositions it).

## Decision

### GATE (must hold before Step A)

ADR-123 verify is **GREEN**, i.e. all of:

1. `skipDangerous` **absent** (not `true`) in `~/.claude/settings.json`;
2. push-**deny** for `main` **present** (a deny rule that blocks pushing to `main`);
3. push-**allow** contains **no bare `git push:*`** (no unrestricted push allow).

Until GREEN: **do not start**. This is a real stop-barrier (governance gate), not a best-decision
auto-continue. The operator performs the `~/.claude` apply; the factory only verifies the reported
result read-only.

### Deterministic resolution order (fail-closed, serialized — ADR-119 Rule 3)

> Each step merges **one at a time**; the next PR re-rebases onto the new `main` and regenerates,
> so it deterministically receives the next `max+1`. `main` branch protection is `strict`
> (must-be-up-to-date), which enforces this at the platform level.

**Step A — merge #787 (ADR-123).** With the GATE GREEN, rebase #787 onto `origin/main`, run
`python3 ledger/build_ledger.py` **FROM ROOT** → IL-540 is confirmed as `max+1` over current `main`
→ merge. **Outcome:** `main` max = **IL-540**, IL-540 frozen to ADR-123.

**Step B — rebase #788 → re-mint to IL-541.** `git fetch origin && git switch -C <work>
origin/main && git checkout <pr-788> -- <own files> && python3 ledger/build_ledger.py` (FROM ROOT).
Because `main` max is now 540, #788's shard is re-assigned **IL-541** (strictly > main max). Correct
every human-facing `[IL-NNN]` (PR title, commit subject, shard body, companion doc) to **IL-541** →
merge. **Outcome:** `main` max = **IL-541**.

**Step C — rebase #789 → re-mint to IL-542.** Same rebase-regenerate cycle onto the new `main`
(max 541). #789's shard (ADR-124) is re-assigned **IL-542**. Correct every human-facing `[IL-NNN]`
to **IL-542** → merge. **Outcome:** `main` max = **IL-542**.

**Step D (this ADR, last) — IL-545 (actual; plan said 543).** This ADR-125 PR is itself gated
**DO-NOT-MERGE** until the above completes. At its own rebase-before-merge onto the resolved `main`
(actual max **544**, not the planned 542 — `#791`/`#792` interleaved), `build_ledger.py` assigns
this shard **IL-545** (strictly > main max). Its working-branch rendered number is **provisional**
(see "ADR-119 self-honoring" below) and is **never** asserted as one of the others' final numbers in
merged `main`. See **Amendment 2026-06-25** for the full actual ledger.

### Per-step verify contract (ADR-119 Rule 2/4)

After **every** Step A/B/C/D rebase-regenerate, before merge, assert all:

1. `python3 ledger/build_ledger.py --check` → **exit 0** (ledger + IL-SEQUENCE.json in sync).
2. **No duplicate IL numbers** — `IL-SEQUENCE.json` values are a strictly-unique set; the new
   shard's value is strictly greater than the prior `main` max.
3. **Append-only preserved** — vs `git HEAD:ledger/IL-SEQUENCE.json`: added = exactly the one new
   key; mutated = ∅; removed = ∅ (the generator's own `check_append_only` enforces this and exits
   non-zero on any mutation/removal).
4. **CI gates green** — `guardian-ledger` IL-collision gate + `strict` branch protection both pass.

A step whose verify is not fully green **does not merge**; it re-rebases and regenerates (a
duplicate is a rebase signal, **not** an operator question — ADR-119 Rule 8.5, best-decision canon).

### ADR-119 self-honoring (this PR eats its own dogfood)

Per **Rule 8**, the IL number is a pure function of `IL-SEQUENCE.json` + the shard set on the
up-to-date base, and **MUST NOT be hardcoded at creation**. On this branch's base (`ec95496`,
max 539) `build_ledger.py` necessarily renders this shard as **IL-540** — itself a 4th provisional
claim on 540, which is precisely why it is marked **PROVISIONAL** and **frozen only at merge**.
Because this PR merges **last** (Step D, after the others are frozen), its rebase-before-merge
re-mints it to **IL-545** (= max+1 over resolved `main` max 544). No PR title, commit subject, ADR
`il_anchor`, or companion doc asserts a **final** number belonging to another shard — they carry
IL-545, the value the generator deterministically assigns on the resolved base.

## Root cause

**No atomic IL allocation across concurrent worktrees cut from one base.** `build_ledger.py`
assigns `max+1` deterministically from `IL-SEQUENCE.json` over the branch's *base*; when N sessions
branch from the same `main` commit and never see each other's in-flight shard, all N compute the
identical `max+1`. Numbering only reconciles at **rebase-before-merge** under `strict` protection —
which serializes merges but does **not** prevent N branches from *carrying* the same provisional
number simultaneously. The collision is therefore structural, not a per-author mistake.

## Preventive follow-up (separate IL — NOT implemented here)

Propose (as its own future IL/ADR, not actioned in this PR): **atomic IL reservation at
session start** — a lightweight lease (e.g. an append-only `ledger/IL-RESERVATIONS.json` claimed via
an atomic compare-and-swap / a short-lived `origin` ref under `refs/il-locks/*`, or a
`build_ledger.py reserve` subcommand that pushes a reservation row before work begins) so a session
obtains a **unique** prospective IL *before* it writes its shard, instead of all sessions converging
on `max+1` at build time. This converts the current *merge-time* reconciliation into *start-time*
allocation and eliminates the carried-collision window. Scope, atomicity guarantees, and CI
enforcement to be specified in the follow-up; this ADR only records the requirement.

## Observation (recorded, NOT fixed here)

The three PRs' generated sets were observed to **skip IL-509**. On current `origin/main`'s
`IL-SEQUENCE.json`, **IL-509 is present** (value 509 exists). This is logged here as an
**observation only** — no renumber, no edit, no fix is performed (ADR-119 forbids renumbering an
existing entry; any genuine gap is investigated under a separate IL if warranted).

## Consequences

- The three in-flight PRs land on **unique, strictly-increasing** IL numbers, and this resolution
  ADR after them, with full per-step verify — no merged-`main` duplicate. **Actuals** (plan integers
  shifted by interleaving): #787=**540**, #788=**542**, #789=**544**, this ADR-125=**545** (see
  Amendment 2026-06-25).
- The resolution is **gated** on an operator out-of-repo step (ADR-123 apply); the factory neither
  performs nor merges it (ADR-103, governance gate). **DO NOT MERGE this PR until ADR-123 verify is
  GREEN** and Steps A–C are complete.
- A structural root cause is named with a concrete preventive direction, deferred to a separate IL
  so this PR stays governance/concept-only.

## Amendment 2026-06-25 — gate GREEN + actual outcome (Step D executed)

The resolution ran to Step D. Two facts updated the plan, **without changing the mechanism**:

1. **GATE satisfied — ADR-123 verify GREEN (factory-verified read-only).** `~/.claude/settings.json`:
   `skipDangerous` absent · `main` push-deny present · no bare `git push:*` (scoped
   `git push origin *` only, `main` denied). All three gate conditions GREEN on 2026-06-25.
2. **Interleaving shifted the integers (this ADR's own root cause, observed live).** Between the
   serialized merges, two unrelated PRs merged and consumed numbers: **#791 → IL-541**
   (safeguarding-coverage-dedup) and **#792 → IL-543** (finrpt-content-core). Net **actual** frozen
   numbers:

   | Step | PR | ADR | planned IL | **actual IL** |
   |---|---|---|---|---|
   | A | #787 | ADR-123 | 540 | **540** |
   | B | #788 | (ADR-123 runbook) | 541 | **542** |
   | C | #789 | ADR-124 | 542 | **544** |
   | D | #790 | ADR-125 (this) | 543 | **545** |

   Each shard still received `max+1` over the *then-current* `main` (strictly increasing, unique,
   append-only); `finrpt` (543) and `adr-092` (544) were **not** renumbered. The plan's specific
   integers were provisional; ADR-119's invariant (number = `f(IL-SEQUENCE + base)` at merge) held
   exactly — the shift **is** the carried-collision phenomenon this ADR documents, now seen end-to-end.
3. **Lesson captured for the per-step rebase:** resolve the ledger conflict by taking
   **origin/main's** generated files (`git checkout origin/main -- INSTRUCTION-LEDGER.md
   ledger/IL-SEQUENCE.json`), then regenerate — **not** `git checkout --theirs`, which during a
   *rebase* selects the replayed branch commit (inverted) and renumbers an already-merged shard
   (caught fail-closed by `check_append_only` during Step C).

## Anchors

- ADR-119 (stable/frozen IL numbering; "Amendment 2026-06-24"); `.claude/rules/parallel-session-isolation.md`
  Rule 8 (merge-time freeze) + Rule 5 (cross-session ledger conflict strategy) + Rule 3 (serialize).
- `ledger/build_ledger.py` — `assign()` (`max+1`), `check_append_only()` (append-only gate), `--check`.
- `docs/guardian/guardian-ledger-il-collision-gate.md` — pre-merge IL-collision CI gate.
- Precedent: PRs #744/#749/#751 (IL-503/504/505 duplicate-IL re-id incident, guard = IL-507).
- ADR-123 / PR #787 (the GATE); ADR-124 / PR #789; ADR-103 (operator `~/.claude` is out-of-repo).
- This resolution is recorded as a tail shard; INSTRUCTION-LEDGER.md + IL-SEQUENCE.json regenerated
  via `python3 ledger/build_ledger.py` (`--check` exit 0). DO NOT MERGE pending ADR-123 GREEN.
