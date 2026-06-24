# Guardian-ledger — pre-merge IL-collision gate (spec)

> **Status:** SPEC (ADR-119 Amendment 2026-06-24; `.claude/rules/parallel-session-isolation.md` Rule 8).
> **Owner job:** `guardian-ledger` (existing CI job in `.github/workflows/guardian.yml`).
> **Plane:** docs/CI governance. No client funds, no production state.

## Problem

The existing ledger guardians enforce that `INSTRUCTION-LEDGER.md` and `ledger/entries/**`
are append-only (`ledger-append-only`, `guardian-ledger-shards`) and that the generated
artefact equals a rebuild on the **branch's own HEAD** (`build_ledger.py --check`). None of
them compare the branch's **newly-assigned IL numbers against what is already merged on
`main`** when the branch is behind. Consequently a behind-branch can pass `--check` while its
new shard carries an IL number **already bound to a different shard on `main`** (a duplicate).
The duplicate only fails to *land* because branch protection is `strict` (up-to-date required)
— but it still surfaces to Claude Code as an I-28 collision and triggers a stop-and-ask. This
gate closes that gap by **detecting the collision at PR time** and emitting a deterministic
rebase+regenerate instruction instead of a question.

## Rule

For every `pull_request` whose diff touches `ledger/entries/**` or `ledger/IL-SEQUENCE.json`,
`guardian-ledger` MUST **REJECT** the PR when **either** holds:

- **(C1) Duplicate-number-on-main.** The PR's `ledger/IL-SEQUENCE.json` contains a value `N`
  (IL number) that already exists on `origin/<base>`'s `IL-SEQUENCE.json` bound to a
  **different key** (different `session_id__sha1(path)`). I.e. the PR re-uses an IL number
  that main has already frozen for another shard/path.
- **(C2) Asserted ≠ regenerated.** After reconstructing the PR's own new shard(s) on top of
  the **current base tip** and running `python ledger/build_ledger.py` (FROM ROOT), the number
  assigned to a new shard differs from the `[IL-NNN]` asserted in the PR title, the head
  commit subject, or that shard's body. (The asserted number is stale.)

A PR that trips C1 or C2 is **incomplete**; the job fails with a fixed remediation message
(below) and exit 1. A PR that adds shards but trips neither passes.

> C1 is the precise form of the briefed requirement: *reject any PR whose shard sequence key
> duplicates an existing-on-main key on a different path.* C2 additionally catches the
> human-facing stale assertion that makes Claude Code ask.

## Remediation message (emitted on failure — deterministic, no operator escalation)

```
FAIL: IL-collision (ADR-119 Rule 8). This PR asserts/assigns an IL number already
frozen on main for a different shard. Rebase + regenerate + re-id (autonomous):
  git fetch origin
  git switch -C <work> origin/<base>
  git checkout <pr-head> -- <this PR's own new files>
  python ledger/build_ledger.py        # FROM ROOT — assigns true max+1
  # read assigned number from ledger/IL-SEQUENCE.json; correct every [IL-NNN]
  python ledger/build_ledger.py --check # exit 0
  git commit -S ; git push --force-with-lease
This is a rebase signal, NOT a question. Do not escalate to the operator.
```

## Reference implementation (gate logic)

To be added as a step in the `guardian-ledger` job. Append-only, read-only against history.

```bash
set -e
BASE_SHA="${PR_BASE:-$(git merge-base origin/${GITHUB_BASE_REF:-main} HEAD)}"
# C1: any new IL number duplicated against a *different* key already on base
python3 - "$BASE_SHA" <<'PY'
import json, subprocess, sys
base = sys.argv[1]
head = json.load(open("ledger/IL-SEQUENCE.json"))
try:
    base_seq = json.loads(subprocess.run(
        ["git","show",f"{base}:ledger/IL-SEQUENCE.json"],
        capture_output=True, text=True).stdout)
except Exception:
    base_seq = {}
base_num_to_key = {v: k for k, v in base_seq.items()}
violations = []
for k, v in head.items():
    if k in base_seq:            # existing key — append-only handled elsewhere
        continue
    if v in base_num_to_key and base_num_to_key[v] != k:
        violations.append((v, k, base_num_to_key[v]))
if violations:
    print("FAIL: IL-collision (ADR-119 Rule 8) — number reused for a different shard:")
    for v, newk, oldk in violations:
        print(f"  IL-{v:03d}: new key {newk}  collides with on-base key {oldk}")
    sys.exit(1)
print("guardian-ledger IL-collision gate OK")
PY
```

(C2 is checked by the same job's existing `build_ledger.py --check` plus a grep that the
asserted `[IL-NNN]` in title/commit/shard equals the regenerated number; when behind, the
mismatch is reported with the same remediation message.)

## Relationship to other guards

- **`strict` branch protection** is the hard backstop: a behind-branch cannot merge a stale
  number. This gate makes the failure *legible at PR time* and gives the exact fix.
- **`ledger-append-only` / `guardian-ledger-shards`** enforce immutability of prior history;
  this gate enforces **non-collision of the new number against main**. Complementary, not
  overlapping.
- **ADR-119 Amendment 2026-06-24** and **Rule 8** are the canonical sources; this file is the
  executable spec.

## Anchors

- `docs/adr/ADR-119-stable-frozen-il-numbering.md` (Amendment 2026-06-24)
- `.claude/rules/parallel-session-isolation.md` Rule 8
- `.github/workflows/guardian.yml` (`guardian-ledger`, `ledger-append-only`, `guardian-ledger-shards`)
- `ledger/build_ledger.py` (`assign()`, `check_append_only()`)
- PRs #744 / #749 / #751 (2026-06-24) — duplicate-IL re-id incident → IL-503 / IL-504 / IL-505
