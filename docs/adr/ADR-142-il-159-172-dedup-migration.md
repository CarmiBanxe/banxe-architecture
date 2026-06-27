---
id: ADR-142
title: IL-159 / IL-172 duplicate de-duplication migration — append-only corrective re-assignment (amends ADR-133)
status: PROPOSED
date: 2026-06-27
amends: ADR-133
supersedes: []
relates:
  - "ADR-133 (IL global-uniqueness gate + allowlist — this ADR is the migration-ADR its re-assignment clause requires)"
  - "ADR-057 / ADR-059 / ADR-059-A (append-only shard ledger; FROZEN-ARCHIVE frozen — never edited)"
  - "ADR-119 (stable/frozen IL numbering — renumber of an existing entry only via migration-ADR + operator)"
  - "LEDGER-KNOWN-DEBT-IL-DUPLICATES (sibling record for {032,033,034,052}; IL-159/172 are the two NOT covered there)"
il_anchor: IL-611
il_anchor_note: "Provisional per ADR-119 Rule 8 — NOT hardcoded; build_ledger mints max+1 over current origin/main (159B→611, 172B→612 by il_ts order). Frozen at rebase-before-merge."
scope: BANXE-ledger-governance
concept_only: true
---

# ADR-142 — IL-159 / IL-172 de-duplication migration (append-only corrective re-assignment)

> **Migration-ADR (amends ADR-133).** Authorizes the canonical re-assignment of two duplicate IL
> references via **append-only corrective records** — **no edit, no renumber, no delete** of any
> historical entry, FROZEN-ARCHIVE shard, or prior minted number. Final merge is **operator HITL**.

## Context

Two IL numbers appear **twice** as `### IL-NNN` body references, **outside** the ADR-133 allowlist
`{540:2}` and **outside** the recorded known-debt set `{032,033,034,052}`
(`LEDGER-KNOWN-DEBT-IL-DUPLICATES.md`):

| IL | Variant (A) — retains the number | Variant (B) — re-assigned |
|----|----------------------------------|---------------------------|
| **IL-159** | `S3 Milestone — Business Process Repository RESOLVABLE (audit gap #3 CLOSED)` (FROZEN-ARCHIVE) | `ADR-059 append-serialization (Sprint 0: фиксация концепции)` (FROZEN-ARCHIVE; no shard) → **IL-611** |
| **IL-172** | `ADR-060 multi-actor orchestration stack — merge_group + branch namespace + concurrency + shard bridge` (FROZEN-ARCHIVE) | `Sprint-46 CFO Treasury & Forecast (TreasuryAgent + ForecastAgent + ADR-078 ports)` (shard `ledger/entries/agent-factory-e-treasury/IL-2026-06-25T18-30-00Z--b50da6.md`, minted **IL-519**; `### IL-172` is a legacy body heading) → **IL-612** |

These are **rendered-text heading duplicates**, not duplicate `IL-SEQUENCE.json` minted values
(the only minted-value duplicate remains the ADR-133-allowlisted `{540:2}`).

## Decision

1. **Variant (A) retains the original number** (IL-159, IL-172) — unchanged.
2. **Variant (B) is re-assigned a new canonical IL from the allocator**: **IL-159(B) → IL-611**,
   **IL-172(B) → IL-612** (`build_ledger` mints `max+1` over current `origin/main`; numbers provisional
   per ADR-119 Rule 8, frozen at rebase-before-merge).
3. **The re-assignment is recorded ONLY as append-only corrective records** in the active ledger (two
   new shards minting IL-611 and IL-612). **FROZEN-ARCHIVE stays exactly as-is** (ADR-059-A): its
   `### IL-159(B)` / `### IL-172(B)` headings are **not edited** — they remain the historical record,
   now disambiguated by the corrective records.
4. **The old IL-172(B) shard `b50da6` is NOT modified** (ADR-059-A forbids editing a frozen shard body):
   its minted **IL-519** and its `### IL-172` body heading remain untouched. The **supersede-for-numbering
   reference** (IL-172(B) → canonical **IL-612**) is recorded **only in the new IL-612 corrective record**.
5. **ADR-133 amendment:** a body-reference duplicate **outside** the allowlist may be resolved by this
   append-only corrective pattern (migration-ADR + operator approval) — re-assign variant (B) to a fresh
   allocator number, leave (A) and all frozen history intact. **No `IL-SEQUENCE.json` value is mutated;
   no number is renumbered in place.** The allowlist `{540}` and the gate are unchanged.

## Append-only & fail-closed guarantees

- **mutated = ∅, removed = ∅** — only two new shards + the two regenerated artifacts
  (`INSTRUCTION-LEDGER.md`, `IL-SEQUENCE.json`) change; no prior key/value is altered.
- **FROZEN-ARCHIVE.md `git diff --quiet` = UNCHANGED**; the `b50da6` shard `git diff --quiet` = UNCHANGED.
- **Uniqueness gate (ADR-133)** still passes: the only minted-value duplicate stays `{540:2}`; this
  migration adds **zero** new minted-value duplicates and introduces IL-611/612 as **unique** values.
- **No auto-merge.** This PR is the migration-ADR; the **operator performs the final merge (HITL)**.

## Consequences

- IL-159(B) and IL-172(B) gain unique canonical numbers (611/612) without touching frozen history.
- The two un-recorded duplicates are now governed (this ADR) and cross-referenced (the corrective
  records); the remaining body-heading duplicate set is exactly the recorded known-debt `{032,033,034,052}`
  plus the allowlisted minted-value `{540:2}`.
- A future optional cleanup (annotating FROZEN-ARCHIVE headings) remains a separate, gated migration — not
  required by this ADR.

## Anchors

- ADR-133 (uniqueness gate / allowlist — amended), ADR-057/059/059-A (append-only; FROZEN-ARCHIVE frozen),
  ADR-119 (no in-place renumber), `LEDGER-KNOWN-DEBT-IL-DUPLICATES.md` (sibling record).
  Corrective records: `IL-611` (159B), `IL-612` (172B). FROZEN-ARCHIVE + `b50da6` shard UNCHANGED.
  No runtime/secret. Operator HITL merge.
