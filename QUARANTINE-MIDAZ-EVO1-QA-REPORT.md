# QA Report — ADR-QUARANTINE-MIDAZ-EVO1 + LEDGER-QUARANTINE-MIDAZ-EVO1 drafts

**Status:** QA only. No files changed by this report. No merges/activations. No
`build_ledger.py`, no `IL-SEQUENCE.json` touch, no git add/commit/push.
**Date:** 2026-07-19. **Scope:** read-only verification of two untracked draft files
against their source docs.

## 0. File-identity checks

- `docs/adr/ADR-QUARANTINE-MIDAZ-EVO1.md` and `ledger/entries/LEDGER-QUARANTINE-MIDAZ-EVO1.md`
  read from disk **match the fragments quoted in the operator's audit exactly** (headings,
  status lines, per-service tables/records, all present verbatim).
- **Neither filename matches the `IL-*.md` pattern** that `ledger/build_ledger.py` scans
  (`ledger/entries/**/IL-*.md`) — confirmed via `basename` on both paths. Cannot be
  accidentally minted.
- `ledger/entries/traffic-light-verdicts/IL-2026-07-18T23-25-34Z--verdict-yellow.md` is a
  **real, separate, pre-existing** verdict shard from an actual `traffic-light.sh` run —
  unrelated to these two drafts, not modified or referenced by them.

## 1. FACT summary (verified against source docs, not memory)

| Claim in drafts | Source | Verified |
|---|---|---|
| Scope boundary: this roadmap = factory infra, not project/EMI | `FACTORY-ROADMAP-2026-06-23.md` line 8 (`Scope boundary (ADR-102):`) | ✅ verbatim match |
| A6: `midaz-ledger`/`mongodb`/`workflow-service` RESTARTING (RED); `keycloak` unhealthy (YELLOW) | same file, §0 line 21 | ✅ verbatim match |
| R0 exit: "GREEN or explicitly quarantined with a reason" | same file, §1 line 28-30 | ✅ verbatim match |
| S-FAC-60 DoD: root-cause documented + runbook + GREEN≥30min-or-quarantined | same file, §2 line 48 | ✅ verbatim match |
| S-FAC-61 DoD: redis-cli + keycloak YELLOW→GREEN + healthcheck contract | same file, §2 line 49 | ✅ verbatim match |
| S-FAC-60 runbook: root-cause = 4 ranked hypotheses, none confirmed | `docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md` §2 heading + 4 numbered items | ✅ exact count (4), heading literally says "NONE confirmed without console access" |
| `workflow-service` exact container identity unconfirmed | same runbook, §3 Step E comment + §6 | ✅ verbatim: *"not found by name in any file read for this runbook"* |
| keycloak: independently re-verified GREEN 2026-07-18, `Up 30 hours (healthy)`, `:8180/realms/master` HTTP 200 | `docs/runbooks/S-FAC-61-health-contract-2026-07-18.md` §1 table, §3 | ✅ matches exactly |
| keycloak root cause: healthcheck lacked `Connection: close` → keep-alive hang → false "unhealthy"; fix = `docker-compose.override.yml` → `9000/health/ready` | `INSTRUCTION-LEDGER.md` IL-487 | ✅ verbatim match |
| `"evo1 midaz+ballerine Up/healthy (S-FAC-61)"` under a conflicting sprint label | `INSTRUCTION-LEDGER.md` IL-487 (title says "S-FAC-62", body references a different "S-FAC-61") | ✅ verbatim match — sprint-numbering mismatch is real, not invented |

**Conclusion: no factual error found in either draft.** Every quoted or paraphrased claim
traces to an exact line in the cited source.

## 2. UNKNOWN / OPEN POINTS (carried from the drafts, not resolved here)

1. **evo1 `midaz-ledger` vs project/EMI scope** — the roadmap's own scope-boundary note
   places A6/R0/S-FAC-60 in "factory infra," but does not state whether this specific
   `evo1` instance is a factory-only dev/test copy or has any bearing on the production
   EMI ledger of the same name. Not resolvable from local docs.
2. **"Root-cause documented" DoD requirement** — S-FAC-60 DoD text is ambiguous on whether
   documenting 4 *unconfirmed* hypotheses satisfies "root-cause... documented," or whether
   a confirmed cause is required before quarantine is DoD-valid. Roadmap text does not
   disambiguate.
3. **`workflow-service` identity gap** — which container/service this label actually
   refers to on evo1 is not established in any file read for either the runbook or these
   drafts.
4. (Secondary, already flagged in-draft) IL-487 vs. roadmap-table sprint-numbering
   mismatch (S-FAC-61 vs S-FAC-62), and whether the keycloak healthcheck fix persists
   across host reboot — both correctly carried as open items, not resolved.

None of these are guessed at or silently resolved in either draft — confirmed on
re-reading.

## 3. ADR draft quality

**OK — no factual or structural defects found.** Standard ADR shape present: Status →
Context → Evidence (dated table) → Decision → ties to other sprints (§4: S-FAC-65/68) →
Open points → Consequences → References. UNKNOWN/OPEN POINT are explicitly labeled
throughout (§1, §3, §6); facts are evidence-table-dated so stale vs. current snapshots
aren't conflated.

Minor, non-blocking suggestions (listed, **not applied**):
- Evidence-table rows read as implicit fact statements; an explicit `[FACT]` tag prefix
  (matching the FACT/UNKNOWN/OPEN-POINT discipline used elsewhere in this session's
  outputs) would make scanning slightly faster, but the dated-table format already
  achieves the same disambiguation.
- §1's citation label "(§ header, lines 8–10)" could instead cite the roadmap's own label
  `"Scope boundary (ADR-102):"` verbatim for a tighter citation — cosmetic only, the quoted
  text itself is already exact.
- No placeholder ADR number or numbering-process note (e.g. "candidate: ADR-17x, pending
  allocation") — not required, but would make the eventual promotion path clearer at a
  glance.

## 4. Ledger draft quality

**OK — no compliance defects found.** Append-only and pointer-first discipline explicitly
stated (top HTML comment + closing "Append-only / pointer-first compliance" section);
restates only short verbatim quotes needed for each decision line, points to the ADR and
source docs for everything else. Filename correctly avoids the `IL-*.md` mint pattern.

Minor, non-blocking suggestions (listed, **not applied**):
- Per-service records duplicate some phrasing already in the ADR's evidence table — normal
  and expected for a self-contained decision record (matches the pattern of other shards
  minted this session), not a defect, but could be tightened slightly if the operator
  wants a leaner shard once ratified.
- No placeholder `session_id`/`il_ts` — this is **correct as-is** (intentional, to avoid
  resembling a real shard); flagging only so the operator doesn't mistake the absence for
  an oversight.

## 5. Recommendation

**Not yet safe to ratify as final** — safe to **promote to a real, isolated-worktree
`build_ledger` mint only after** the operator/CTIO explicitly acknowledges (does not need
to resolve, only acknowledge) open points #1 and #2 above, since both bear directly on
whether "provisional quarantine" is the correct call for `midaz-ledger`/`mongodb`/
`workflow-service`:
- If evo1 `midaz-ledger` turns out to have EMI/production relevance, quarantining it
  under a "factory infra, low risk" framing would understate real risk.
- If S-FAC-60 DoD is read to require a *confirmed* (not hypothesized) root cause before
  quarantine is valid, these three services are not yet DoD-eligible for quarantine at
  all, and the ADR's "provisional" framing should be the operator's explicit, recorded
  choice, not a default.

`keycloak`'s "no quarantine, already repaired" call **is** safe to ratify as-is — it rests
on an independent, live, dated re-verification (2026-07-18) with a confirmed root cause
and fix (IL-487), no open points bear on that specific decision.

**No blocking edits required to either draft's content or format** — both are internally
consistent, evidence-accurate, and correctly hedged. The gate to ratification is an
operator judgment call on open points #1/#2, not a drafting defect.

## 6. Next steps

Record the operator/CTIO judgment on open points #1 and #2 in
`docs/governance/QUARANTINE-MIDAZ-EVO1-JUDGMENT-NOTE.md` — a standalone judgment note that
does not edit either draft. That note also carries the step-by-step guidance for
promoting the existing ADR/ledger drafts (real ADR number + real ledger mint via
`build_ledger.py` in an isolated worktree) once both points are answered.
