# Canonical GitHub Account — factory git/gh operations run as CarmiBanxe

**Status:** ACTIVE · **Added:** 2026-07-11 · **ADR:** ADR-170 · **Cross-ref:** ADR-120.

> Pointer-first, additive (ADR-102). Declares the canonical account and the guard that enforces it.

## Rule

**The canonical GitHub account for ALL factory git/gh operations is `CarmiBanxe`.**
Every factory commit, push, PR, and `gh` API call runs as `CarmiBanxe`, which owns every factory
remote (`CarmiBanxe/*`).

**`Carmi61` is retained INTENTIONALLY — for occasional operator confirmations / approvals only.**
It must **NOT**:
- own any factory remote, and
- be the **active** `gh` account during factory work.

Operating factory git/gh from `Carmi61` is a mistake (wrong-account commits/PRs), not an approved mode.

## Enforcement

- `tools/factory/factory-preflight.sh` — the **`active-gh-account`** HARD check: `gh api user -q .login`
  must equal `CarmiBanxe`. If it is `Carmi61` (or any other), preflight **hard-fails** with the remedy
  `gh auth switch --user CarmiBanxe`. If gh is unauthenticated/offline it warns (does not block offline
  work). This check was added alongside the fix for the #1124 `ledger-writer-lock` `set -e` regression
  (which had been hard-failing preflight on every clean branch — see that commit).

## Anchors
- `tools/factory/factory-preflight.sh` (`active-gh-account` check).
- **ADR-170** (cross-terminal registration sync), **ADR-120** (session-worktree isolation),
  ADR-102 (pointer-first). PR #1124 (the regression the same commit fixes).
