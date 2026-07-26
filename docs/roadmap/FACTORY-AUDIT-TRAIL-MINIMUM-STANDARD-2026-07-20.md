# Context & purpose

**S-FAC-R4** defines a forward-looking minimum standard for what must be logged for every
significant factory execution and every consequential decision inside it. This is a
**design document, not a backfill**: nothing already recorded (no sprint doc, no ledger
entry, no ClickHouse row) is changed, and no claim below is retroactively applied to past
work. Where this repo already has a real, evidenced mechanism for part of this standard,
this document points to it and extends it rather than inventing a parallel one. Where no
such mechanism exists yet, this document says so explicitly as an OPEN POINT.

Builds on, in this order: `docs/roadmap/FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md`
(S-FAC-R2 — sprint-namespace, status, dependency/override, and passport models),
`docs/audit/FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md` (S-FAC-R1 — the
Sprint 3/7/8 override finding used below as a worked example), and
`docs/roadmap/FACTORY-AUDIT-INDEX-2026-07-20.md` (S-FAC-R3 — the audit-plane index this
document should eventually join).

Repo: `architecture-bank-operating-model-20260718`, HEAD `b5e05dd06f4f7ab86b88ca853eb7149e6a16d71b`.

**What already exists here, confirmed by direct read this sprint (grounding, not invention):**

| Existing mechanism | Where | Status |
|---|---|---|
| `correlation_id` as cross-node/cross-message vocabulary | `AGENTS.md` §"Three-node execution fabric" (ADR-104); `docs/canon/intent-layer-masks.md` (ADR-150 A2A envelope) | real, already-used term — this standard reuses it, does not rename it |
| Five Mandatory Packs (P1-P5) incl. **P4: Audit Pack** | `docs/canon/software-factory-canon-v1.md` §6, §9 | ratified canon (Sprint 1, 2026-05-14) |
| **P5 Evidence Pack schema v1.0** (`pack_id`, `guardian_audit_id`, `ruflo_checkpoint_id`, `final_verdict`, etc.) | `docs/canon/evidence-pack-schema.md` | ratified schema; storage path `docs/evidence-packs/YYYY-MM-DD-<pack_id>.md` **does not exist yet in this worktree** (`docs/evidence-packs/` — confirmed absent) |
| ClickHouse audit tables `guardian_audit_factory` / `guardian_audit_project`, 5-year TTL | `docs/canon/software-factory-canon-v1.md` §9, Appendix A | cited as evidenced by `guardian/src/storage/clickhouse.py` — **that file does not exist in this worktree** (confirmed absent); treat as canon-defined but unconfirmed-present here |
| `HITL-MATRIX.yaml` | repo root | confirmed present |
| `amendment_type=EMERGENCY` logging convention | `docs/canon/software-factory-canon-v1.md` §11.3 | ratified — this standard reuses it for the "overrides & exceptions" section below rather than inventing new emergency vocabulary |
| Role passports (`docs/canon/passports/*.yaml`) / agent passports (`agents/passports/*.yaml`) | sampled `schema.yaml`, `planner.yaml`, `guardian-factory.yaml`, `mlro.yaml`, `operator.yaml`, `adverse_media_governor.yaml`, `front_office_agent.yaml` | confirmed present; agent-passport schema shows minor field drift between sampled files (noted in OPEN POINTS, not treated as blocking) |

# Scope of the audit trail standard

**In scope** — any execution that changes state, makes a governance-relevant decision, or
produces an artefact someone else will rely on:

- Factory sprints of any namespace (Sprint N, S-FAC-NN, S-FAC-RN, S-A0..S-A13, S1-S6 —
  per the namespace model in the consolidated master).
- Agent-driven runs that invoke a domain/skill agent (i.e. anything dispatched under an
  `agents/passports/*.yaml` identity).
- Governance decisions: HITL approvals/rejections, canon amendments, status
  reclassifications, overrides.
- Any execution that itself creates or edits a document later cited as evidence by another
  document (which, per the audit-integration model, is most of what `docs/audit/*` and
  `docs/roadmap/*` contain).

**Out of scope** — this minimum standard does not require a trail entry for:

- Read-only exploration/browsing that produces no artefact and no decision (e.g. an agent
  reading five files to answer a question, then stating the answer inline in chat with
  nothing written to disk).
- Tooling smoke-tests / health checks with no state change (e.g. a `curl` against a health
  endpoint).
- Purely mechanical, reversible edits below the threshold of "consequential decision"
  (e.g. a typo fix) — unless bundled inside an in-scope execution, in which case it
  inherits that execution's trail entry rather than needing its own.

**Boundary rule:** if in doubt, log it. The cost of an unnecessary trail entry is far lower
than the cost of a silent gap — this mirrors the "no silent caps" discipline already used
in this repair line's own audits.

# Minimum fields per execution

For every in-scope execution (session/sprint/task), the trail must capture, at minimum:

| Field | Requirement | Grounding in this repo |
|---|---|---|
| **Correlation/execution ID** | one ID for the whole execution, propagated to every sub-record | reuse `correlation_id` (ADR-104, ADR-150 A2A envelope) — do not invent a second ID scheme |
| **Timestamp(s)** | start + end (or start + "still open") | ISO8601, matching `evidence-pack-schema.md`'s `timestamp` field |
| **Identity** | who ran it — human name or agent_id | human: name as it appears in a role passport's `actor` field (e.g. `mlro.yaml` → "Moriel Carmi (interim)"); agent: `agent_id` from `agents/passports/*.yaml` (e.g. `adverse_media_governor`) |
| **Role context** | which `docs/canon/passports/*.yaml` role_id governed this execution | e.g. `planner`, `executor`, `reviewer`, `guardian-factory` — see Linkage section below |
| **Intent/task description** | one sentence: what was supposed to happen | matches P1 Instruction Pack's role (`docs/canon/software-factory-canon-v1.md` §6) |
| **Canon/policy context** | which canon document + version/commit governs this execution | e.g. "software-factory-canon-v1.md, amended 005936d" or "FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md, dependency/override model" |
| **Input artefacts** | files read, prompts issued, configs consulted | high-level list, not a full read-log |
| **Tool/command actions** | high-level actions taken (e.g. "wrote 1 file," "ran grep sweep") — **not** every keystroke or every tool call | matches this repair line's own existing style of self-reporting ("show all changed files inline") |
| **Decisions/approvals** | any HITL gate crossed, with outcome | see Minimum fields per decision, below |
| **Outputs** | files created/edited, primary effects | matches P2 Execution Pack |
| **Side effects** | any change to roadmap/audit-layer documents (index entries, status notes, pointers added) | this repair line's own edits are a direct example — e.g. S-FAC-R3 added a pointer row to `MASTER-ROADMAP.md` as a side effect of creating `FACTORY-AUDIT-INDEX-2026-07-20.md` |
| **Status** | one of: `DONE`, `DONE-WITH-OVERRIDE (skips: ...)`, `BLOCKED`, `CANCELLED` | reuses the exact status vocabulary defined in the consolidated master's dependency/override model — no new status terms |

**Worked example (illustrative only — not a retroactive log entry):** had this standard
existed during S-FAC-R3, its execution-level trail entry would have read approximately:
correlation ID = `S-FAC-R3`; identity = Claude Code (agent), role = `executor`+`reviewer`
context (per `docs/canon/passports/planner.yaml`/`executor.yaml` — Claude Code spans
planner/reviewer functions per the ratified canon's role matrix); intent = "implement the
5 repair tasks S-FAC-R2 called for"; canon context = `FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md`;
inputs = the 5 read-only context files listed in that sprint's own plan; outputs = 2 files
edited, 1 file created; side effect = pointer row added to `MASTER-ROADMAP.md` §2.1; status
= `DONE` (all 5 tasks completed, one deliberate scope deviation — the path correction — was
itself disclosed inline, which is exactly the behaviour this standard is trying to make
routine rather than exceptional).

# Minimum fields per decision

For each consequential decision *within* an execution (not every execution needs more than
one; some need several), the trail must capture:

| Field | Requirement |
|---|---|
| **Decision ID** | unique within the execution (e.g. `S-FAC-R3-D1`) |
| **Who decided** | human or agent identity, **plus** the role passport (`docs/canon/passports/*.yaml`) whose `gate_authority` covers this decision class |
| **Rule(s)/canon section referenced** | exact section, e.g. "consolidated master §Dependency & override model" |
| **Evidence consulted** | which audit doc(s)/source file(s) — path-level, matching this repair line's own citation discipline |
| **Outcome + justification** | what was decided and why, in one or two sentences |

**Worked example — the Sprint 3→7/8 override (illustrative, reconstructing a decision
already made and already documented in prose form by S-FAC-R1/R3, not a new decision):**

| Field | Value |
|---|---|
| Decision ID | `S-FAC-R1-D1` (illustrative numbering) |
| Who decided | Claude Code (agent), role = `reviewer`/`executor` per `docs/canon/passports/` — the original Sprint 7/8 proceed-despite-gap choice was made by whoever ran those 2026-05-14 sprints, not reconstructible from the documents alone; what *is* reconstructible is S-FAC-R1's classification decision to name it an override |
| Rule/canon section | consolidated master §"Dependency & override model" |
| Evidence consulted | `docs/audit/sprint3-routing-canon-enforcement-2026-05-14.md` (OPEN, F9/F10 unmet); `docs/canon/passports/guardian-factory.yaml` ("Enforces 8 factory rules F1-F8"); `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-24.md` trait #14 ("16 rules" = F1-F8+P1-P8) |
| Outcome + justification | classify Sprint 7/8 as `DONE-WITH-OVERRIDE (skips: Sprint 3 F9/F10)` — three independent pieces of evidence converge on F9/F10 never landing, so silent clean-DONE would misstate what actually shipped |

This table format — decision ID, who, rule, evidence, outcome — is the minimum; richer
detail (e.g. dissenting views, alternatives considered) is encouraged but not required.

# Linkage to passports (roles & agents)

Every trail entry (execution-level or decision-level) that names an identity **must** cite
that identity by its passport, not just a free-text name:

- **Role passport citation:** `docs/canon/passports/<role_id>.yaml` — e.g. an execution run
  under Planner authority cites `planner.yaml`; one requiring MLRO sign-off cites
  `mlro.yaml`. The `gate_authority` field on the cited passport must be consistent with the
  decision being made (e.g. a decision requiring `gate_authority: mlro` cannot be
  self-approved by a `gate_authority: none` role).
- **Agent passport citation:** `agents/passports/<agent_id>.yaml` — required whenever a
  specific domain/skill agent (not a generic factory-loop role) acted, e.g.
  `adverse_media_governor`, `front_office_agent`. Cite the agent's `status` field
  (`PROPOSED`/`active`) as recorded in its passport at the time of the trail entry — per
  `TARGET-MODEL-CONFORMANCE-2026-06-25.md`, most agent passports remain PROPOSED/bound but
  not activated (I-27), so a trail entry citing an agent passport should not imply
  activation it doesn't have.
- **Both together, when applicable:** a factory-loop step executed by Claude Code acting as
  `executor` that dispatches work to a specific domain agent should cite **both** —
  `executor.yaml` for who is allowed to dispatch, and the domain agent's own passport for
  what was dispatched to. This mirrors the role-layer/agent-execution-layer split defined
  in the consolidated master's Passport model section exactly; this document does not
  redefine that split, only requires the trail to reference it.
- **Non-goal, restated:** this document does not add, remove, or modify any field in either
  passport directory. If an execution needs a passport field that doesn't exist yet (e.g. a
  trail-entry pointer field), that is a passport-schema change and belongs to a separate,
  explicitly-scoped repair sprint.

# Linkage to factory canon & roadmap

- **Canon reference:** every execution-level trail entry cites the canon document + version
  it operated under — for factory-governance work, this is normally
  `docs/canon/software-factory-canon-v1.md` (current: RATIFIED 2026-05-14, amended
  `005936d`/2026-05-21) and/or `docs/roadmap/FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md`
  for anything touching the namespace/status/dependency/passport models this repair line
  defined.
- **Roadmap reference:** where an execution reads, is constrained by, or edits a
  roadmap-plane document, cite it by path and, if relevant, by its current status per the
  document status model — e.g. "constrained by `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md`,
  read as ACTIVE-in-practice/PROPOSED-in-name per its 2026-07-20 status note" or "informed
  by `docs/roadmap/BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` §5 (S-A
  sprint map), status DRAFT/NOT FOR MERGE." Do not cite a roadmap document without its
  current status qualifier — an unqualified citation is exactly the kind of ambiguity
  S-FAC-R1 found and S-FAC-R3 started correcting.
- **This standard's own place in the canon/roadmap graph:** this document is itself a
  roadmap-plane artefact (`docs/roadmap/*`), produced by the S-FAC-R (repair) namespace,
  status ACTIVE as of creation (a forward-looking standard has no "supersession" concept
  until a v2 of this same standard appears).

# Applicability, overrides & exceptions

| Case | Minimum logging requirement |
|---|---|
| Normal in-scope execution | full execution-level field set (above) |
| Consequential decision inside an execution | full decision-level field set (above), one row per decision |
| **Override** (proceeding despite an unmet upstream dependency) | must set `status: DONE-WITH-OVERRIDE (skips: <named dependency/criterion>)` — reuses the exact convention from the consolidated master; silence on an unmet dependency is not permitted, matching the plain-language rule already ratified there |
| **Emergency/exception action** (e.g. security incident, regulatory deadline) | at minimum: correlation ID, who acted, what canon rule was bypassed and why, expiry/ratification window — this reuses the existing ratified `amendment_type=EMERGENCY` / 72-hour-expiry convention from `docs/canon/software-factory-canon-v1.md` §11.3 rather than inventing new emergency vocabulary; an emergency action with no trail entry at all is a canon violation under the existing §11.3 text, not just under this new document |
| Trivial/out-of-scope activity | no trail entry required (see Scope, above) |

# Integration into FACTORY-AUDIT-INDEX

This document is **not** added to `docs/roadmap/FACTORY-AUDIT-INDEX-2026-07-20.md` in this
sprint — S-FAC-R4's single-artefact scope is this file only, and that index is out of
scope here exactly as `BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` was
out of scope for S-FAC-R3. Recorded here as the integration point a future repair sprint
should complete:

- Add a row to `FACTORY-AUDIT-INDEX-2026-07-20.md`'s "Key factory audit artefacts" table:
  this document, type = **standard** (a new type, distinct from "findings snapshot" and
  "status/supersession or install audit" — this is the first meta-audit-standard artefact
  in the index, not an audit of a document but a specification for future audit trails).
  This document does not create that new "type" row itself.
- Once added, this becomes the pointer a future execution's trail entry can cite for "which
  standard governs this trail entry's own shape" — closing the self-referential loop.

# OPEN POINTS

1. **No confirmed audit-log storage sink exists in this worktree.** `docs/canon/software-factory-canon-v1.md`
   cites `guardian/src/storage/clickhouse.py` as evidence for ClickHouse audit persistence,
   and `docs/canon/evidence-pack-schema.md` specifies a `docs/evidence-packs/YYYY-MM-DD-<pack_id>.md`
   storage path — **neither the code file nor the directory exists in this worktree**
   (confirmed by direct check). This standard specifies *what* must be logged; it cannot
   specify *where* with certainty until this gap is resolved. Until then, the practical
   fallback is the same one this entire repair line has already been using: a dated
   Markdown document under `docs/audit/` or `docs/roadmap/`, git-tracked, cited by path.
2. **No enforcement mechanism is defined.** This document states a standard; it does not
   say who checks compliance with it, or what happens if a sprint ships with no trail
   entry. That is a governance-design question for a future sprint, not resolved here.
3. **Agent-passport schema shows minor field drift** between sampled files (e.g.
   `adverse_media_governor.yaml`'s `hitl.gate`/`ports` structure vs.
   `front_office_agent.yaml`'s `autonomy`/`line_of_defence`/`smf_function` structure) — a
   trail entry citing an agent passport should quote whichever fields that specific
   passport actually has, not assume a single uniform shape across all 59 files.
4. **Retroactive backfill is explicitly out of scope** and remains open — no existing
   sprint or execution gets a trail entry under this standard by virtue of this document
   existing. Whether backfill is ever attempted for the most consequential historical
   decisions (e.g. the Sprint 3/7/8 override) is a separate, future decision.
5. **Whether this standard itself needs CTIO/Operator ratification** (per
   `docs/canon/software-factory-canon-v1.md` §11.2's amendment-constraint rule, since
   "new packs" / structural changes require CTIO approval) is unresolved — this document
   proposes an addition to *how* the existing P4/P5 packs get evidenced, arguably not a new
   pack itself, but that line is not self-evidently clear and is left for operator judgment
   rather than asserted here.
