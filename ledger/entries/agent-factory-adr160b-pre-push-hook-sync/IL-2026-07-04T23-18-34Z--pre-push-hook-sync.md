---
il_ts: 2026-07-04T23:18:34Z
session_id: agent-factory-adr160b-pre-push-hook-sync
source: agent-factory
status: PROPOSED
---

# pre-push hook/source desync fix + ADR-158→160 write-gate relabel (follow-up to #1018/#1019)

## What

#1018 landed the v2 union hook in `.githooks/pre-push` (G-1..G-4 write-gate + G-5 branch-name + G-5+
push-safety) but did NOT update its source mirror `scripts/pre-push-branch-name.sh` (push-safety only).
`scripts/install-hooks.sh` copies source→installed (line 53), so any bootstrap **silently reverted** the
four write-gate guards, breaking the #1016 byte-identical invariant (reproduced live: a fresh worktree's
installed hook had 0 write-gate guards until restored from HEAD).

## Fix (behaviour-preserving)

- Synced `scripts/pre-push-branch-name.sh` **up** to the committed v2 union → **byte-identical** to
  `.githooks/pre-push` again (verified `diff` clean). install-hooks now installs the full guard stack.
- Relabelled the **write-gate** guard comments G-1..G-4 + header + source line: ADR-158 → **ADR-160**
  (the bilateral write-gate was renumbered in #1019). **Kept** G-5+ `is_protected_ref` + shared-checkout
  as **ADR-158** (push-safety, #1016). Comment/label only — no guard logic changed.

## Verify

`bash -n` clean (both). `scripts/test-branch-name-gate.sh` → ALL GREEN (16 name + 7 push-safety).
Functional: main-push BLOCKED (G-5+ intact), feature push allowed. G-1 `+refspec` detection is env-based
(unchanged from #1018).

## Boundaries

Prepare-only. No guard behaviour change; only source-sync + comment relabel. IL minted redis-serialized at
ratification (REDIS_HOST=100.68.102.48). Closes the desync flagged in ADR-160's status note.

## Anchors

`.githooks/pre-push` · `scripts/pre-push-branch-name.sh` · `scripts/install-hooks.sh` (the copy mechanism) ·
`scripts/test-branch-name-gate.sh` · ADR-160 (renumbered write-gate) · ADR-158 push-safety (#1016) · ADR-119.
