# gitleaks env-indirection allowlist — prepared patch for `banxe-emi-stack`

**Not applied.** Sprint-0 is consolidation only, so this ships as a patch fragment for the donor's
owner rather than as a commit to the donor.

## The defect

Five ADR-032 rules in emi-stack's `.gitleaks.toml` share one regex shape:

```
<NAME>\s*=\s*['"]?([A-Za-z0-9_\-=+/.]{8,})['"]?
```

The character class accepts **dots**, so `os.environ.get(...)` satisfies it. Each rule therefore
fires on the very pattern that proves there is no secret — an environment read. On emi-stack `main`
this yields **4 permanent findings on the repository's own source**, forever.

A detector that is always wrong in the same place is one people learn to scroll past. That is how a
real finding gets waved through, which makes this a security problem rather than a tidiness one.

## Why not a negative lookahead

gitleaks compiles rules with Go's `regexp` package (**RE2**), which has no lookahead or lookbehind.
`(?!os\.environ)` does not merely fail to match — **gitleaks panics on config load**. Verified
against gitleaks 8.18.4.

The RE2-safe equivalent is a rule-level allowlist.

## Affected rules — five, not one

`banxe-clickhouse-password`, `banxe-postgres-password`, `banxe-auth-secret-key`,
`banxe-github-pat`, `banxe-marble-api-key`.

## Verification

`regression_test.sh` — **10/10**, one negative and one positive fixture per rule. The positives are
the point: an allowlist that hides real secrets would pass a negatives-only suite.

End-to-end against real emi-stack `main` history: **4 findings → 0**, with literal detection intact.
