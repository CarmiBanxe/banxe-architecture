# Context & scope

Sprint S-FAC-R1 — a repair-roadmap audit, not an implementation sprint. Scope: determine
current governing status (ACTIVE / DEPRECATED / HISTORICAL / UNCLEAR-COLLIDING) for 14
named factory-governance/canon/roadmap documents, and record explicit-vs-implicit
supersession relationships between them. No code or canon file is edited, moved, or
deleted here; no git operation performed. Evidence-only, read-only commands
(`ls`/`find`/`rg`/`grep`/`cat`/`git log`/`git rev-parse`).

Repo: `architecture-bank-operating-model-20260718`, HEAD `249cfa61abdb546769661fac3f2f7879713f5d22`.

# Documents assessed

| Path | Last commit (date) | Self-declared status |
|---|---|---|
| `AGENT-ORG-STRUCTURE.md` | 2026-06-21 | none (undated evergreen doc; contains an internal "RECONCILED 2026-06-21" note re: ADR-117) |
| `AGENTS.md` | 2026-06-30 | none (undated evergreen doc, "v4.0") |
| `docs/audit/FACTORY-CANON-ROLLOUT-v1.6.1-BATCH-2026-06-06.md` | 2026-06-06 | `Status: REFERENCE (rollout audit; not binding by itself)` |
| `docs/audit/factory-laws-vs-reality-2026-05-13.md` | 2026-05-14 | none (a findings/audit doc, no status field) |
| `docs/audit/factory-orchestration-and-training-2026-05-13.md` | 2026-05-13 | `Status: AUTHORITATIVE for 2026-05-13 22:55 CEST` (explicitly time-boxed) |
| `docs/audit/sprint1-software-factory-canon-2026-05-14.md` | 2026-05-14 | `Status: DONE` |
| `docs/audit/sprint3-routing-canon-enforcement-2026-05-14.md` | 2026-05-14 | `Status: OPEN` |
| `docs/audit/sprint7-pilot-factory-pack-2026-05-14.md` | 2026-05-14 | `Status: DONE` |
| `docs/audit/sprint8-full-factory-adoption-2026-05-14.md` | 2026-05-14 | `Status: DONE (core items; S8-03..08 DEFERRED)` |
| `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` | 2026-06-23 | `Status: PROPOSED (awaits operator merge)` |
| `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-24.md` | 2026-06-25 | self-banner: `⚠ SUPERSEDED (ADR-102) by ...2026-06-25.md` |
| `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-25.md` | 2026-06-25 | `Status: LIVE AUDIT (supersedes ...2026-06-24.md)` |
| `docs/roadmap/sprint-factory-developer-audit-2026-05.md` | 2026-05-05 | `Status: BLOCKED-ON-CLUSTER` |
| `docs/roadmap/sprint-project-cluster-audit-2026-05.md` | 2026-05-05 | `Status: OPEN` |

Two additional artefacts, not in the original 14 but load-bearing evidence for their
classification, were read as part of this audit:

- `docs/governance/MASTER-ROADMAP.md` (last commit 2026-06-30) — the repo's own
  self-described "consolidation index" for `docs/roadmap/*` fragments, classifying each as
  **AGGREGATED** or **SUPERSEDED**.
- `docs/canon/software-factory-canon-v1.md` (last commit 2026-05-21, `005936d`) — the actual
  ratified canon that Sprint 1 exists to produce; still cited as live evidence by
  `TARGET-MODEL-CONFORMANCE-2026-06-24.md` §2 (trait #3).

# Status classification (ACTIVE / DEPRECATED / HISTORICAL / UNCLEAR)

**ACTIVE**

- `AGENT-ORG-STRUCTURE.md` — undated/evergreen, actively reconciled as recently as
  2026-06-21 per its own inline note, and is the document `TARGET-MODEL-CONFORMANCE-2026-06-24.md`
  §1 (traits #4, #6, #11) cites as current evidence for org structure/trust zones.
- `AGENTS.md` — undated/evergreen, last touched 2026-06-30 (most recent commit of any
  document in this audit), defines the Four-Partner Swarm + ADR-102/103/104/153 canon
  currently in force.
- `docs/canon/software-factory-canon-v1.md` — RATIFIED 2026-05-14, amended once
  (`005936d`, 2026-05-21, "INV-01 amendment — Aider PREFERRED, Claude Code permitted"),
  still cited as live evidence by the most recent conformance audit (2026-06-24, §2 trait #3).
  Not in the original 14, but its status directly determines Sprint 1's classification below.
- `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-25.md` — current, explicitly the "latest"
  per `MASTER-ROADMAP.md` line 41 (`target-model conformance (latest)`), and per
  `MASTER-ROADMAP.md` line 23 is the pointer target for the "Governance / target-model
  conformance" phase row.

**DEPRECATED**

- `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-24.md` — explicitly superseded (see
  Supersession findings). Retained deliberately, not deleted (both its own banner and
  `MASTER-ROADMAP.md` line 48 say so).

**HISTORICAL**

- `docs/audit/sprint1-software-factory-canon-2026-05-14.md` — status DONE; its sole
  deliverable (`docs/canon/software-factory-canon-v1.md`) shipped and is still live — the
  sprint doc itself is a closed process record, not something anyone reads for current
  governing rules.
- `docs/audit/sprint7-pilot-factory-pack-2026-05-14.md` — status DONE; a one-time pilot
  validation record. (Note: every checkbox under its own "Deliverables" section is
  unticked `[ ]` despite the header and all Work Items reading DONE — an internal
  documentation-hygiene inconsistency, not a status ambiguity, since Sprint 8's own
  "Depends on: Sprint 7 (pilot complete with acceptable results)" line confirms Sprint 8
  proceeded on the basis that Sprint 7 was in fact accepted.)
- `docs/audit/sprint8-full-factory-adoption-2026-05-14.md` — a closed process record for
  the items it actually finished (S8-01/S8-02); see Gaps & risks for why its DEFERRED tail
  (S8-03..S8-08 — enforcement mode, cross-repo loop activation, dashboard) is a live gap,
  not a closed one, even though the sprint doc itself is historical.
- `docs/audit/factory-laws-vs-reality-2026-05-13.md` — a point-in-time findings snapshot
  (2026-05-13), explicitly comparing canon-as-written to a specific day's operational
  reality; superseded in effect (not in name) by the later, broader conformance audits.
- `docs/audit/factory-orchestration-and-training-2026-05-13.md` — self-declared
  `AUTHORITATIVE for 2026-05-13 22:55 CEST` only; the timestamp is itself the document's
  own expiry marker.
- `docs/audit/FACTORY-CANON-ROLLOUT-v1.6.1-BATCH-2026-06-06.md` — self-declared
  `REFERENCE (rollout audit; not binding by itself)`; records a completed one-time batch
  rollout (7 repos pinned to canon v1.6.1); nothing in this audit found a later document
  that references or continues this rollout log, so it stands as closed history for that
  batch, not live canon.
- `docs/roadmap/sprint-factory-developer-audit-2026-05.md` — **externally confirmed**
  historical: `MASTER-ROADMAP.md` line 53 explicitly lists it (paired with the cluster
  sprint) as `historical sprint audits`.
- `docs/roadmap/sprint-project-cluster-audit-2026-05.md` — same external confirmation,
  `MASTER-ROADMAP.md` line 53. See Gaps & risks — "historical" here means "no longer the
  active tracking artefact," not "problem resolved" (evidence below).

**UNCLEAR / COLLIDING**

- `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` — its own header status is `PROPOSED
  (awaits operator merge)`, yet `MASTER-ROADMAP.md` line 21/38 already lists it as
  **AGGREGATED** (a live indexed source) for the "Factory build-out" phase, and
  `TARGET-MODEL-CONFORMANCE-2026-06-25.md` cites its `S-FAC-68` sprint ID as a going-concern
  reference. The document is simultaneously "not yet merged/approved" by its own header and
  "already a live source of truth" by two independent later artefacts. Classified UNCLEAR
  rather than ACTIVE/DEPRECATED because the repo itself has not resolved which is true.
- `docs/audit/sprint3-routing-canon-enforcement-2026-05-14.md` — status OPEN, all seven work
  items PENDING, and this audit found no F9/F10 rule implementation anywhere in the repo
  (`rg "\bF9\b|\bF10\b"` matches only this sprint doc, `sprint7`'s own text, two runbooks
  discussing the *concept*, and `ledger/FROZEN-ARCHIVE.md` — no rule-engine code or
  passport-routing implementation). Yet Sprint 7 (DONE) and Sprint 8 (DONE core) both list
  Sprint 3 as a hard dependency and proceeded anyway. This is neither cleanly HISTORICAL
  (its own exit criteria were never met) nor ACTIVE (nothing currently treats it as an open
  task to finish) — it is a stalled dependency that later "DONE" sprints silently walked
  past.

# Supersession findings

| Newer | Supersedes (older) | Basis |
|---|---|---|
| `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-25.md` | `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-24.md` | **explicit** — both documents state it directly (06-25 §6 "This assessment supersedes..."; 06-24's own inserted banner "⚠ SUPERSEDED... by ...2026-06-25.md"); further confirmed externally by `MASTER-ROADMAP.md` line 48. |
| `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-24.md` | `docs/master-document/04-audit-v2.md` (not in the 14, referenced only) | **explicit** — 06-24 §6 states this directly. Recorded for completeness of the chain; that older document was out of this audit's assigned scope. |
| `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` | `docs/roadmap/sprint-factory-developer-audit-2026-05.md` (and the May "audit v2" lineage generally) | **explicit** — FACTORY-ROADMAP §5 Duplication Audit table states this file is "superseded by audit v2 for current state; historical." It does **not** name `sprint-project-cluster-audit-2026-05.md`, `sprint1/3/7/8-2026-05-14.md`, or either `factory-laws-vs-reality`/`factory-orchestration-and-training` doc — those relationships (if any) are not declared anywhere. |
| `docs/canon/software-factory-canon-v1.md` (commit `005936d`) | its own earlier self (Sprint 1 ratified text) | **explicit, self-amendment** — "INV-01 amendment: Aider PREFERRED, Claude Code permitted" directly reconciles the gap `factory-laws-vs-reality-2026-05-13.md` had flagged ("canon says Aider = sole executor; reality is Claude Code writes code directly"). Not a document-level supersession, but recorded here because it resolves a cross-document finding. |
| *(inferred only)* `docs/audit/factory-laws-vs-reality-2026-05-13.md` + `docs/audit/factory-orchestration-and-training-2026-05-13.md` | — | **implicit/unclear** — both are single-day findings snapshots that later governance docs (software-factory-canon-v1, TARGET-MODEL-CONFORMANCE series) build past without ever citing either by name. No document declares them superseded; their content (Four-Partner Swarm reality gaps, LiteLLM/Aider routing state) is simply not carried forward by name. Treated as HISTORICAL above on inferred, not confirmed, grounds. |

# Gaps & risks

1. **`docs/audit/*` has no consolidation index at all.** `MASTER-ROADMAP.md` explicitly
   scopes itself to `docs/roadmap/*` fragments only (its own header: "points to every
   existing **roadmap** fragment"). None of the six `docs/audit/*` documents in this audit's
   list — including the two (`FACTORY-CANON-ROLLOUT-v1.6.1`, `factory-laws-vs-reality`)
   that materially shaped canon still in force — appear in any repo-level classification
   index. Their status here rests entirely on this audit's inference, not on repo-declared
   fact.
2. **Three non-communicating "Sprint N" numbering schemes coexist with zero
   cross-reference between any two of them**, confirmed by direct grep (each scheme's own
   documents cite only their own series):
   - Sprint 1/3/7/8 (2026-05-14, `docs/audit/`) — Guardian F1-F10, Canon Judge, role
     passports (`docs/canon/passports/`), P1-P5 packs.
   - S1–S6 (referenced only inside the two `TARGET-MODEL-CONFORMANCE` docs) — MRM,
     DevSecOps, KPI/DORA, UI/UX, Open Banking, Merge-queue/Org; entirely separate artefact
     set (`docs/governance/*.md`).
   - S-FAC-60–69 (`docs/roadmap/FACTORY-ROADMAP-2026-06-23.md`) — env stabilization,
     traffic-light agent, training runner, skills adoption, DORA binding, 100%-gate.
   Anyone reading "Sprint 3" or "S3" without the surrounding document has no way to know
   which of three unrelated scopes is meant.
3. **Two distinct, identically-named "passport" systems exist with no cross-reference or
   disambiguation found anywhere:** `docs/canon/passports/` (10 files — role passports:
   `planner`, `executor`, `reviewer`, `operator`, `mlro`, `ctio`, `canon-judge`,
   `guardian-factory`, `guardian-project`, `schema` — the Sprint-1/3 lineage) vs.
   `agents/passports/` (59 files — per-agent skill-binding passports, the lineage
   `SKILLS-MATRIX`/`FACTORY-ROADMAP-2026-06-23`/`TARGET-MODEL-CONFORMANCE` all cite as
   "57/70 bound"). No document in this audit's set explains the relationship between the
   two directories, or whether one is meant to replace the other.
4. **`FACTORY-ROADMAP-2026-06-23.md` is simultaneously "PROPOSED, awaits operator merge"
   (its own header) and already treated as a live, cited source** by both
   `MASTER-ROADMAP.md` (AGGREGATED) and `TARGET-MODEL-CONFORMANCE-2026-06-25.md` (cites its
   `S-FAC-68` sprint ID as a going concern). This is a direct status contradiction between
   three documents, unresolved anywhere in the repo.
5. **Sprint 3's exit criteria (Guardian rules F9/F10) were never met, but Sprints 7 and 8
   both declared completion despite listing Sprint 3 as a hard dependency.** Corroborating
   evidence: `TARGET-MODEL-CONFORMANCE-2026-06-24.md` trait #14 cites Guardian as having "16
   rules" total — exactly F1-F8 + P1-P8, with no F9/F10 — meaning the routing-enforcement
   rules Sprint 3 exists to deliver are absent from the rule count a full six weeks later.
6. **Sprint 8's "Full Factory Adoption" is not actually full.** Its own status line reads
   "DONE (core items; S8-03..08 DEFERRED)" — but S8-03 through S8-08 are precisely: Canon
   Judge enforcement-mode transition, factory-loop enablement for `banxe-emi-stack` and
   MetaClaw, CLAUDE.md/COLLAB.md canon references, and the operational dashboard. The
   sprint that is supposed to make the factory "the default operating mode for all
   CarmiBanxe work" left every mechanism that would actually enforce that deferred.
7. **`sprint-project-cluster-audit-2026-05.md`'s P0 item (PA-1, midaz-ledger restart loop
   on evo1) shows no confirmed closure, and a near-identical symptom recurs 49 days later.**
   `FACTORY-ROADMAP-2026-06-23.md` §0 row A6 (dated 2026-06-23) lists "evo1
   `midaz-ledger`/`mongodb`/`workflow-service` RESTARTING (RED)" as a live audited fact —
   the same service, same symptom, as PA-1's original P0 description (2026-05-05). Whether
   this is the same unresolved incident or a recurrence could not be determined from the
   documents in scope; either reading means the sprint's own acceptance criterion
   ("midaz-ledger container stable ≥24h") was not durably met. `MASTER-ROADMAP.md` calling
   this sprint "historical" reflects that the tracking artefact is no longer live — it does
   not certify the underlying infrastructure problem was fixed.
8. **`docs/audit/factory-laws-vs-reality-2026-05-13.md`'s "3 priority actions" have no
   confirmed disposition.** Action 1 (Aider as sole executor) was **effectively reversed**,
   not completed, by the later `software-factory-canon-v1.md` INV-01 amendment (Claude Code
   explicitly permitted). Actions 2 (systemd timers for adversarial-sim/drift monitoring)
   and 3 (parallel-verify.sh as pre-commit hook) have no later document in this set
   confirming or denying completion.

# Next steps for repair

- Route to the governance/roadmap room: decide whether `docs/audit/*` should be folded into
  `MASTER-ROADMAP.md`'s consolidation scope (or given a sibling audit-plane index), since it
  currently has zero authoritative status tracking (Gap 1).
- Route to whoever owns Sprint-numbering conventions: assign each of the three "Sprint N"
  lineages a disambiguating prefix in future references (e.g. always write
  "Sprint N (Canon-2026-05)" / "S-N (Governance)" / "S-FAC-NN") — this is a documentation
  fix, not a rewrite, and directly addresses Gap 2.
- Route to the same room: reconcile or explicitly disambiguate `docs/canon/passports/` vs
  `agents/passports/` (Gap 3) — confirm whether both are intended to coexist permanently or
  one is meant to subsume the other.
- Route to the operator: resolve `FACTORY-ROADMAP-2026-06-23.md`'s PROPOSED-vs-AGGREGATED
  contradiction (Gap 4) — either formally merge/ratify it (matching how it is already being
  treated) or correct the two documents that cite it as live.
- Route to the factory/ledger room: reopen or formally close Sprint 3 (Gap 5) and Sprint 8's
  deferred tail S8-03..S8-08 (Gap 6) — both are currently silent gaps between "sprint says
  DONE" and "the thing the sprint was for is running."
- Route to the infra/cluster room: confirm live status of the evo1 midaz-ledger service
  (Gap 7) — this is a factual question a live health check can resolve directly, independent
  of any document.
- No content in this repair sprint proposes editing any of the 14 source documents — all
  of the above are pointers for a later, separate repair sprint to act on.

# Roadmap linkage (added 2026-07-20, S-FAC-R3)

This audit is now indexed from the roadmap layer: `docs/roadmap/FACTORY-AUDIT-INDEX-2026-07-20.md`
lists it under "Key factory audit artefacts," and `docs/governance/MASTER-ROADMAP.md` §2.1
points to that index in turn — closing part of Gap 1 above (a discoverability path now
exists; the audit-plane still has no full classification index of its own). For
interpretation of this audit's findings — the sprint-namespace model, the document-status
model, and the dependency/override model referenced throughout the findings above — see
`docs/roadmap/FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md`, the main interpretation
guide. No classification or finding in this document is changed by this addition.
