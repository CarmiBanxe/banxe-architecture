# GitNexus Freshness + Two-Terminal Protocol

**Date:** 2026-08-02 | **Status:** Protocol (operator-ratified design; source: Fable-5 design §B/§C/§D)
**Canon:** ADR-176 (analytical red line — freshness may label/warn, NEVER block; org joins the
code graph at REPORT TIME only), ADR-102 (dedup — one graph, one producer), ADR-143-A (allocator),
PolyForm-NC sandbox (GITNEXUS_ENV=sandbox).
**Companion script:** `scripts/gitnexus-freshen.sh` (the graph's ONLY writer).

## §B — Freshness model

Mechanism (three layers, all FAIL-SOFT — stale is a label, never a block):

1. **git post-merge hook** — runs `gitnexus-freshen.sh`; re-index only when
   `indexed_commit != HEAD` (~25 s). Hook is **documented, operator-installed**
   (worktree-safe snippet in the script header; uses `git rev-parse --git-path hooks`).
2. **Staleness-guard stamp** — `.gitnexus/graph-stamp.json`:
   `{indexed_commit, indexed_at (ISO UTC), main_head, commits_behind, verdict FRESH|STALE}`.
   Consumers of impact reports (detect_impact / emit_org_overlay readers) MUST read the
   stamp and label output produced from a STALE graph. (Stamp-reading inside
   detect_impact.py = separate small follow-up PR; this PR is docs+script only.)
3. **Daily cron backstop** — documented in the script header, operator-installed.

Parameters:

| Param | Value | Note |
|---|---|---|
| Graph location | `.gitnexus/` (repo-local) | gitignored; keep-1; cache NOT record |
| Re-index cost | ~25 s | full regenerable at any time |
| Stamp file | `.gitnexus/graph-stamp.json` | written ONLY by gitnexus-freshen.sh |
| Verdict | FRESH ⇔ commits_behind==0 vs origin/main | anything else = STALE |
| Failure mode | FAIL-SOFT | any error → stderr warning + exit 0, never block |
| Lock | `/tmp/gitnexus-freshen.<repo>.lock` (atomic mkdir) | serialises WRITERS only; readers never wait |
| Env | `GITNEXUS_ENV=sandbox` | PolyForm-NC boundary |

## §C — Two-terminal protocol (ADR-102 rules)

**Shared invariants:**
- ONE graph per repo; `scripts/gitnexus-freshen.sh` is the ONLY writer (lockfile vs
  concurrent writes; `analyze`-readers are unaffected).
- `build_org_contour.py` is the ONLY producer of the org overlay; org data joins the code
  graph at REPORT TIME only and is NEVER written into `.gitnexus` (ADR-176 red line).

**Central (dispatcher/arbiter) — consumes:**
1. Reads impact reports (risk/blast_radius/files + org overlay) and the graph stamp.
2. **ARBITER RULE (binding):** NEVER act on a report whose stamp verdict = STALE or whose
   `indexed_commit != origin/main` — demand a freshen first, then a re-run.
3. Never edits passports/owner_line/map — consumption only.

**Right (factory/executor) — produces:**
1. Edits passports / `owner_line` map rows / rosters (the org sources) via normal
   PR+shard flow; never touches `.gitnexus` by hand.
2. Runs `gitnexus-freshen.sh` (directly or via the operator-installed hook) after merges.
3. Owns the **`unowned_paths` → 0** tail: every path the overlay reports as unowned is a
   census task (real owner from registry — never invented), worked down BEFORE refactors.

## §D — Sequencing

1. **Blockers-before-refactor:** freshness mechanism (this PR) and `unowned_paths → 0`
   census come FIRST — refactors ride on a fresh graph with full ownership coverage.
2. Later (each operator-gated, per the ADR-176 bounded surface set): detect_impact
   stamp-reading follow-up → freshness SLO → contract registry → CI promotion
   (post-#1166).

## Operator switch-on checklist (nothing auto-installed by this PR)

- [ ] Install post-merge hook (snippet in `scripts/gitnexus-freshen.sh` header).
- [ ] Install daily cron backstop (same header).
- [ ] Ensure `.gitnexus/` is gitignored in each indexed repo (cache, never committed).
- [ ] Assign Right the `unowned_paths → 0` census tail.
