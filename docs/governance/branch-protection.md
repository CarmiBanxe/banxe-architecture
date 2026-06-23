# Branch Protection Policy — banxe-architecture

**IL:** IL-457 (hardening) → IL-458 (unblock) → IL-459 (root-cause) → IL-463 (sandbox-minimal) → **IL-466 (explicit-minimal, current)** — see Related. IL-PROT-01 (Sprint 42) is historical/superseded.
**Effective:** 2026-06-23
**Configured via:** `gh api` (repo-admin), version-controlled + instruction-ledger-tracked.

> This document is the canonical description of branch protection rules; the authoritative
> enforcement is the live GitHub branch-protection settings on `main`.
> Configuration is applied through `gh api` (repo-admin) and audited in the instruction-ledger
> (IL-457..IL-466) — each change is an idempotent full-object PUT recorded as an append-only
> shard. Manual GitHub-UI edits are **not** canon; reconcile this doc from the live API snapshot.

---

## Change Procedure (operator-only, single-shard)

Protection changes in this single-principal sandbox follow a minimal, audit-preserving procedure.
They do **not** require a separate governance sprint-PR with per-change reconciliation: the
one-PR-per-tweak pattern (IL-457..IL-468 / PRs #705/#710/#711/#712/#713) was надуманное friction
for a single principal and is **closed by this record** — subsequent protection changes are
one-shard records, not PR cycles.

1. **Authority — operator-only.** Only the operator (`@mmber`, repo-admin) initiates a protection
   change. **Agents / the factory MUST NOT initiate protection changes** — they may only read and
   report the live settings. (Unchanged guardrail, now stated explicitly.)
2. **Mechanism — `gh api` allowed.** Changes are applied by the operator via `gh api` (idempotent
   full-object PUT/PATCH/DELETE). The earlier GitHub-UI-only mandate is retired: the audit trail is
   already provided by git history + the append-only instruction-ledger + `enforce_admins=true`.
3. **Record — ONE appended ledger shard, at change-time.** Each protection change is recorded by a
   **single** appended `ledger/entries/**` shard (one `### IL-NNN` block) at the time of the
   change — **not** a separate reconciliation / sprint PR per change. This document is reconciled
   from the live API snapshot within that same shard when values drift.
4. **Inviolable guardrails (unchanged).** Append-only ledger (I-28 / ADR-057 / ADR-059 / ADR-119),
   `enforce_admins=true`, `allow_force_pushes=false`, `allow_deletions=false`, and the auto-guardian
   required checks remain in force regardless of any protection-value tweak.

---

## Scope

| Branch | Protected |
|--------|-----------|
| `main` | ✅ Yes |
| `feat/*`, `fix/*`, `chore/*` | No (feature branches are ephemeral) |

---

## Required Pull Request Reviews

> **Review gates are removed** — this is a **single-principal sandbox**: there is no second
> principal who could approve (GitHub forbids self-approval), so a mandatory human review would
> only deadlock merges without adding protection. Correctness is gated by the auto-guardians
> (below) + the append-only ledger, not by a human reviewer.

| Setting | Value |
|---------|-------|
| Minimum approvals required | **0** |
| Dismiss stale reviews on new push | **No** |
| Require review from CODEOWNERS | **No** (a `.github/CODEOWNERS` file exists but is **not** an enforced gate — `require_code_owner_reviews=false`) |
| Require approval of the most recent push | **No** |
| Restrict who can dismiss reviews | No additional restriction |

---

## Required Status Checks

`strict = true` (branches must be up to date with `main` before merge). All of the following
**auto-guardian** checks must pass before merge is allowed:

| Check name | Purpose |
|------------|---------|
| `guardian-factory` | factory/agent-registry invariants |
| `guardian-project` | project invariants (BANXE) |
| `guardian-ledger` | ledger-coupling gate (ADR-056/060) — PR adds an IL shard / `### IL-NNN` |
| `ledger-append-only` | append-only immutability of `INSTRUCTION-LEDGER.md` (I-28, ADR-057) |

> These are repository governance/ledger gates, not code CI. (The earlier `Gitleaks` /
> `CodeRabbit` / `Pytest` / `Ruff` / `Semgrep` entries are obsolete and have been removed.)

---

## Branch Restrictions

| Setting | Value |
|---------|-------|
| Allow force pushes | ❌ No |
| Allow branch deletions | ❌ No |
| Require linear history (squash-only) | ✅ Yes |
| Require conversation resolution | ❌ No (advisory review threads do not block merge) |
| Include administrators | ✅ Yes (`enforce_admins=true` — guardians apply to everyone, no privileged bypass) |
| Push restrictions (who can push) | None (`restrictions=null`) |

---

## Commit Signing

| Setting | Value |
|---------|-------|
| Require signed commits | ❌ No (`required_signatures=false`) |

> In the sandbox, merge does **not** require signed commits. (The factory still signs its commits
> with an SSH signing key as good hygiene, and squash-merges are GitHub-signed — but this is not
> an enforced branch-protection gate.)

---

## CODEOWNERS

Defined in `.github/CODEOWNERS`. All paths owned by `@mmber`.

> **Not an enforced merge gate** — `require_code_owner_reviews=false`. The file documents intended
> ownership for reference; it does not block merges in the current sandbox profile.

| Path | Owner |
|------|-------|
| `*` (all files) | `@mmber` |
| `/instruction-ledger/` | `@mmber` |
| `/adrs/` | `@mmber` |
| `/compliance-experiments/` | `@mmber` |
| `/.claude/` | `@mmber` |
| `/CLAUDE.md` | `@mmber` |

---

## Rationale

This is a **single-principal sandbox-minimal** profile: maximum merge throughput with integrity
still protected automatically.

- **Protection rests on auto-guardians, not humans.** `guardian-factory`, `guardian-project`,
  `guardian-ledger`, and `ledger-append-only` (strict / up-to-date) gate every merge for repo +
  ledger correctness — no human reviewer is needed on the merge path.
- **Append-only ledger is inviolable.** I-28 / ADR-057 + ADR-059/ADR-119 frozen numbering keep the
  IL chain append-only; `ledger-append-only` enforces it at merge time.
- **History is protected.** `allow_force_pushes=false` + `allow_deletions=false` prevent a stray
  force-push or branch delete from destroying the ledger chain; linear history keeps `main`
  bisectable.
- **`enforce_admins=true`** means the guardians apply to everyone — no privileged bypass.
- **Human gates removed (review/last-push/conversation/signatures)** because, with a single
  principal, they are unreachable or pure friction and would stall project progress without adding
  protection — so merges proceed freely (`review_count=0`) while guardians still gate correctness.

Provenance of this profile: IL-457 (hardening) → IL-458 (single-principal unblock) →
IL-459 (revert root-cause: User account, no org layer) → IL-463 (sandbox-minimal first set) →
**IL-466 (explicit-minimal, durability-confirmed)**.

## Related

- **IL-457** branch-protection hardening · **IL-458** single-principal unblock · **IL-459**
  revert root-cause · **IL-463** sandbox-minimal · **IL-466** explicit-minimal (current profile).
- IL-PROT-01 (Sprint 42, `instruction-ledger/sprint-42/IL-PROT-01-branch-protection-main.md`) —
  **historical / superseded** by the IL-457..IL-466 chain.
- Counterpart: `banxe-emi-stack/docs/governance/branch-protection.md`
- `.github/CODEOWNERS` (this repo)
