---
il_ts: 2026-07-04T20:41:43Z
session_id: agent-factory-adr158-push-safety-guard
source: agent-factory
status: PROPOSED
---

# ADR-158 — push-safety versioned pre-push guard (force/protected-ref/shared-checkout)

## What

Close the push-safety gap surfaced by the 2026-07-04 orchestration audit: protection against direct
main/master push + shared-checkout push lived only in the LOCAL, non-git-tracked `~/.claude/settings.json`
deny-list (ADR-134) + server-side branch protection — with **no versioned client-side guard**. Extend
(not rewrite) the existing ADR-060 pre-push hook to fail-closed on those two violations.

## Artifacts

- **NEW** `docs/adr/ADR-158-push-safety-versioned-pre-push-guard.md` — the decision + Duplication Audit.
- **EDIT** `scripts/pre-push-branch-name.sh` (source of truth) — add pure `is_protected_ref()` +
  `_push_violation()` + shared-checkout guard in `_main`; `is_compliant()` untouched.
- **EDIT** `.githooks/pre-push` — byte-for-byte identical copy of the source (verified `diff` clean).
- **EDIT** `scripts/test-branch-name-gate.sh` — add 7 `is_protected_ref()` cases (16 name + 7 push-safety, all green).

## Verification

`bash scripts/test-branch-name-gate.sh` → ALL CASES GREEN (23), exit 0. `bash -n` clean on both hooks.
Functional: `HEAD:main` push → BLOCKED rc=1; feature→feature push → PASS rc=0.

## Boundaries

Prepare-only. Additive to ADR-060 (extend, not rewrite). No `settings.json` edit (LOCAL, ADR-134),
no server-side branch-protection change, no new standalone guard file (would duplicate — ADR-102).
`--force-with-lease` to feature branches deliberately still allowed (Rule 4). No merge/push to main.

## Anchors

`docs/adr/ADR-158-push-safety-versioned-pre-push-guard.md` · `scripts/pre-push-branch-name.sh` ·
`.githooks/pre-push` · `scripts/test-branch-name-gate.sh`. Co-cites ADR-060/102/120/134/ADR-TERMINAL-B-SPEC-LANE.
Operator orchestration audit 2026-07-04.
