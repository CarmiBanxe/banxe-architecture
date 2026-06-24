---
il_ts: 2026-06-24T22:00:00Z
session_id: agent-factory-ledger-il-allocation-guard
source: CEO
status: DONE
---
### Race-proof IL allocation — merge-time freeze + guardian IL-collision gate (docs/governance plane)

- **Objective:** Eliminate the duplicate-IL defect where concurrent factory terminals double-claim a number (493/494/497/500/501), violating I-28 and forcing Claude Code to stop and ask. Make IL allocation race-proof so collisions are caught pre-merge and re-id is autonomous.
- **Live audit (source of truth, not memory):** origin/main@9be1662; `python ledger/build_ledger.py --check` OK FROM ROOT; IL-SEQUENCE max=506 → this = frozen max+1 = **IL-507** (ADR-119). Verified contiguous tail through 506, zero duplicate IL numbers on main after the three re-ids.
- **Root cause:** no atomic IL allocation across concurrent terminals. `build_ledger.py` assigns `max+1` correctly, and `--check` validates the branch against its OWN HEAD — but a behind-branch can pass `--check` while carrying a number already frozen on `main` for a different shard. The duplicate only fails to land because branch protection is `strict`; it still surfaces as an I-28 collision (the "factory keeps asking" regression).
- **Resolution of the three colliding PRs (no content change beyond the IL number; rebase + regenerate FROM ROOT; append-only verified each = 1 new key / 0 mutated / 0 removed):**
  - #744 M2.8 Roster-C gate-resolution: stale IL-497 (taken by e-capital #745) → re-id **IL-503** (also passed over 502 taken by a-kyb #752 mid-flight). MERGED → main@974955a.
  - #749 DUP-clone salvage manifest: stale IL-500 (taken by a-kyc #748) → re-id **IL-504**. MERGED → main@27da8b5.
  - #751 s-fac-65 traffic-light: stale IL-501 (taken by a-idv #750) → re-id **IL-505**. MERGED → main@9634eb3.
- **Guard mechanism (A + B, by engineering merit):**
  - **A — canon (merge-time freeze):** `.claude/rules/parallel-session-isolation.md` **Rule 8** + **ADR-119 Amendment 2026-06-24**: IL number is provisional until the branch is rebased onto current `origin/main` immediately before merge and `build_ledger.py` (FROM ROOT) re-assigns `max+1`; never hardcoded at creation; `strict` protection physically blocks a behind-branch from merging a stale number; concurrent ledger PRs serialized; a mismatch is an autonomous rebase signal, NOT an operator question.
  - **B — CI gate spec:** `docs/guardian/guardian-ledger-il-collision-gate.md` — `guardian-ledger` REJECTS any PR whose new `IL-SEQUENCE.json` value duplicates an existing-on-main number bound to a different shard key (C1), or whose asserted `[IL-NNN]` ≠ regenerated number (C2), emitting a deterministic rebase+regenerate remediation message.
- **Named-ordinal collision (same class):** this guard's own Rule was assigned **Rule 7** initially, but ADR-121 (PR #753) landed its Rule 7 (destructive-action protection) concurrently; per append-only canon the merged Rule 7 keeps the number and this guard re-id'd its rule **7 → 8** (and IL-506 → IL-507) — the same merge-time-freeze discipline applied to a named ordinal.
- **ADR-102 dedup:** searched ledger/canon for existing IL-allocation guard — none; Rule 1-7 cover branch/stash/commit isolation + destructive-op protection but not number-collision; this is the first merge-time-freeze rule. Companion to (not duplicate of) ADR-119 (numbering mechanism) and existing guardian-ledger jobs (history immutability). No file moved/deleted; all additive.
- **Perimeter / gates NOT crossed:** docs/governance plane only; no code execution path, no client funds, no production state, no process management (the race is fixed by merge-time freeze + guardian gate + strict protection, NOT by killing sessions); no cross-repo write; no renumber of any prior entry; signed commits; `--force-with-lease` only.
- **Coupling/append-only:** branch agent/factory/ledgerguard/il-allocation (off main@9be1662); frozen IL via ledger/IL-SEQUENCE.json (max+1); no prior key mutated (249..506 unchanged); `--check` exit 0 FROM ROOT.
- **Refs:** ADR-119 (+Amendment 2026-06-24); parallel-session-isolation.md Rule 8; docs/guardian/guardian-ledger-il-collision-gate.md; .github/workflows/guardian.yml (guardian-ledger / ledger-append-only / guardian-ledger-shards); ledger/build_ledger.py; I-28; ADR-056/057/059/060/121; PRs #744/#749/#751/#753.
