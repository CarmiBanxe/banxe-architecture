---
il_ts: 2026-06-27T13:00:00Z
session_id: agent-factory-governance-il-dup-migration-159-172
source: CEO
status: DONE
---
### Corrective (ADR-142) — IL-172(B) "Sprint-46 CFO Treasury & Forecast" re-assigned to canonical IL-612
- **Decision:** Per **ADR-142** (migration-ADR amending ADR-133) + operator HITL: the duplicate IL-172 **variant (B)** — `Sprint-46 CFO Treasury & Forecast (TreasuryAgent + ForecastAgent + ADR-078 ports)` — is **canonically re-assigned to IL-612** (this record). Variant **(A)** `ADR-060 multi-actor orchestration stack — merge_group + branch namespace + concurrency + shard bridge` **retains IL-172**.
- **Old shard untouched (ADR-059-A):** variant (B) already has shard `ledger/entries/agent-factory-e-treasury/IL-2026-06-25T18-30-00Z--b50da6.md` (minted **IL-519**; its `### IL-172 —` line is a legacy body heading). That shard's **body and its minted IL-519 are NOT modified or deleted** — ADR-059-A forbids editing a frozen shard body. The **supersede-for-IL-172-reference** (IL-172(B) → canonical **IL-612**) is recorded **only here**, in this new corrective record.
- **Append-only / frozen:** `FROZEN-ARCHIVE.md` and shard `b50da6` are **NOT edited**. No prior `IL-SEQUENCE.json` value mutated; no in-place renumber (ADR-119). Pure append: one new shard.
- **Proof:** ledger-governance only; concept_only; **no runtime, no code, no config-stub, no secret**. IL **provisional, NOT hardcoded** (ADR-119 Rule 8) — `build_ledger` mints max+1 over current `origin/main` → IL-612 (later of the two corrective il_ts, after IL-611). Append-only (ADR-059-A): tail shard, il_ts `2026-06-27T13:00:00Z` strictly > IL-611 record `2026-06-27T12:45:00Z` > origin/main max. ADR-133 uniqueness gate: adds **zero** new minted-value duplicates (set stays `{540:2}`). Isolated worktree off origin/main `1073913` (ADR-120); namespace ADR-060.
- **Refs:** `docs/adr/ADR-142-il-159-172-dedup-migration.md` (authorizing migration-ADR); `ledger/entries/agent-factory-e-treasury/IL-2026-06-25T18-30-00Z--b50da6.md` (variant-B shard, minted IL-519 — UNCHANGED, superseded for IL-172 reference only); `ledger/FROZEN-ARCHIVE.md` (IL-172 A/B headings — UNCHANGED); sibling corrective IL-611 (IL-159B). Operator HITL merge.
