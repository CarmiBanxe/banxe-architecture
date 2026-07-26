# Context & purpose

Consolidation deliverable for **S-FAC-R2**. This document merges the findings of
`docs/audit/FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md` (S-FAC-R1) with a
fresh read of the currently-active canon/roadmap layer and states, in one place, how a
reader should interpret factory-governance documents going forward.

**This is not a rewrite.** No source document's classification, wording, or historical
record is altered by this file. Every statement below either (a) repeats a finding already
evidenced in the S-FAC-R1 audit, citing it, or (b) is drawn from a fresh read this sprint,
cited by path + commit/status. Where the repo does not support a clean answer, this
document says so as an OPEN POINT rather than inventing one.

# Scope of the consolidated master

Fed by, in order of weight:

1. `docs/audit/FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md` — the 14-document
   status/supersession audit (S-FAC-R1).
2. Live canon: `AGENTS.md`, `AGENT-ORG-STRUCTURE.md`, `docs/canon/software-factory-canon-v1.md`.
3. Live indices: `docs/governance/MASTER-ROADMAP.md`, `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-25.md`.
4. Passport directories: `docs/canon/passports/` (10 files), `agents/passports/` (59 files) —
   sampled directly this sprint (`schema.yaml`, `planner.yaml`, `guardian-factory.yaml`;
   `adverse_media_governor.yaml`).
5. `docs/roadmap/BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` — read in full
   this sprint; **not** part of the S-FAC-R1 14-document set, but directly relevant because it
   introduces a fifth sprint-ID namespace (see below) that S-FAC-R1 did not have visibility into.

Out of scope: this document governs *how to read* existing factory-governance artifacts. It
does not rule on BANK product-launch content (workstreams, operator decisions, external
dependencies in the BANK-MASTER-ROADMAP draft) — that document is cited here only for its
naming-collision evidence, not adjudicated on its launch-readiness merits.

Repo: `architecture-bank-operating-model-20260718`, HEAD `1475d92cf7883ff9802a78e498db5ba109ea0431`.

# Sprint namespace model

**Correction to this document's own prior plan:** the S-FAC-R2 plan (previous turn) assumed
"S-A-*" meant a Floor-2 install-audit chain. Reading `BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md`
in full this sprint shows that assumption does not hold **inside this repo** — see row 5
below. The corrected model has **five**, not three, non-communicating namespaces:

| Namespace | Example IDs | Scope | Defining artifact | Status |
|---|---|---|---|---|
| `Sprint N` (bare) | Sprint 1, 3, 7, 8 | Software-Factory-Canon ratification (Guardian F1-F10, Canon Judge, `docs/canon/passports/`, P1-P5 packs) | `docs/audit/sprint{1,3,7,8}-*-2026-05-14.md` | HISTORICAL namespace (per S-FAC-R1) |
| `S1`-`S6` | S1 (MRM), S2 (DevSecOps), S3 (KPI/DORA), S4 (UI/UX), S5 (Open Banking), S6 (Merge-queue/Org) | Governance-canon artifacts under `docs/governance/*.md` | referenced only inside `TARGET-MODEL-CONFORMANCE-2026-06-{24,25}.md` — no dedicated sprint-tracking doc of its own | HISTORICAL/absorbed — the artifacts it produced are ACTIVE, the sprint labels themselves are not reused going forward |
| `S-FAC-NN` | S-FAC-60..69 | Factory infra build-out (env stabilization, traffic-light agent, training runner, skills adoption, DORA binding, 100%-adoption gate) | `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` | UNCLEAR/COLLIDING per S-FAC-R1 (doc header PROPOSED vs. treated as live elsewhere) |
| `S-FAC-RN` | S-FAC-R1, R2, R3... | Factory-canon **repair/consolidation** meta-line (this sprint sequence) | `docs/audit/FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md`, this document | ACTIVE (current) |
| `S-A0`-`S-A13` | S-A1 (Governance & roles), S-A4 (Intent substrate), S-A7 (Rails activation), S-A13 (Launch governance) | **BANK product launch-readiness** workstream sprints — explicitly excludes the factory roadmap ("фабричный roadmap (R0–R5) исключён") | `docs/roadmap/BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` (own header: `DRAFT / NOT FOR MERGE`) | DRAFT — newly discovered this sprint, not yet cross-referenced against any other namespace anywhere in the repo |

**Consolidated rule for future factory-governance writing:** bare `"Sprint N"` or bare
`"S-A-N"` must never be used alone. Always qualify with the defining artifact or a
namespace tag, e.g. `"Sprint 3 (2026-05-14 Software-Factory-Canon)"`,
`"S-A4 (BANK launch-readiness)"`, `"S-FAC-64 (factory roadmap)"`. This document is the
canonical place to look up which namespace a bare ID belongs to.

**Not addressed here (see OPEN POINTS):** whether `S-A0..S-A13` (BANK launch line) and the
`S-A6..S-A9` install-audit IDs used in *this session's own prior work* (D-GL/B-EMI/M2.5-BIF/
M-GATEWAY/I-api install-audits, a different repo checkout: `banxe-architecture`) are the same
namespace, a coincidental prefix reuse, or something in between — no document inside this
repo cross-references that other repo's `S-A6..S-A9` IDs, and both use "S-A" independently.

# Document status model

Single 5-state model for all factory-governance documents going forward:

| Status | Meaning | How to recognize it |
|---|---|---|
| **ACTIVE** | Currently governs behaviour; cited as live evidence by the most recent conformance/index artifact | Undated evergreen doc still being touched, or a dated doc explicitly named "latest"/"live audit" with no later supersession found |
| **PROPOSED** | Drafted, not yet operator-ratified; may be *treated* as live by other docs pending ratification | Explicit `DRAFT`/`PROPOSED`/`awaits operator merge` header |
| **DEPRECATED** | Superseded by a specific newer document; retained for history, not deleted | Explicit "supersedes"/"superseded by" language in either direction |
| **HISTORICAL** | Closed process record (a sprint that shipped, a point-in-time snapshot); nothing currently treats it as an open task | No later document depends on it remaining open; its own exit criteria were met (or it was never meant to be re-opened) |
| **UNCLEAR / COLLIDING** | Two or more documents disagree on its status, or it names/depends on something the repo cannot resolve | A contradiction exists between the document's own header and how at least one other live document treats it |

**Reconciling `FACTORY-ROADMAP-2026-06-23.md`:** per S-FAC-R1 (Gap 4 / UNCLEAR-COLLIDING
finding), this document's own header reads `Status: PROPOSED (awaits operator merge)`, while
`docs/governance/MASTER-ROADMAP.md` (line 21/38) already lists it **AGGREGATED** (a live
indexed source for the "Factory build-out" phase) and `TARGET-MODEL-CONFORMANCE-2026-06-25.md`
cites its `S-FAC-68` sprint ID as a going concern. **This document does not edit that file
or flip its header.** The reading rule for anyone consulting it today:

> Treat `FACTORY-ROADMAP-2026-06-23.md` as **ACTIVE-in-practice / PROPOSED-in-name** — its
> content is already being relied on by two independent later artifacts, but it has not
> received the explicit operator ratification its own header still awaits. Do not cite its
> `PROPOSED` header as grounds to disregard its content; do not cite its de-facto use
> elsewhere as grounds to claim it was formally ratified. Both facts are true at once until
> an operator resolves the contradiction (S-FAC-R1 Next-steps item 4).

# Dependency & override model

**Plain-language rule (new, defined here per S-FAC-R2's mandate):**

> **DONE** means the sprint's own stated exit criteria were met, in full, at time of
> closure. If a downstream sprint proceeds and is marked DONE while an upstream
> dependency's exit criteria were **not** met, that downstream sprint must be labelled
> **DONE-WITH-OVERRIDE**, not clean DONE — and the override, and what specifically was
> skipped, must be named in the same breath as the DONE marker. Silence on an unmet
> dependency is not permitted going forward.

**Worked example — the Sprint 3/7/8 chain (per S-FAC-R1 finding 5):**

- Sprint 3 (`docs/audit/sprint3-routing-canon-enforcement-2026-05-14.md`), status `OPEN`,
  exit criteria = Guardian rules **F9** (route-alias validation) and **F10** (role-action
  validation) implemented and tested. Confirmed unmet: `docs/canon/passports/guardian-factory.yaml`
  itself states its role is "Enforces 8 factory rules (F1-F8)" — F9/F10 are absent from the
  live rule count, matching S-FAC-R1's independent finding via `TARGET-MODEL-CONFORMANCE-2026-06-24.md`'s
  "16 rules" total (F1-F8 + P1-P8).
- Sprint 7 (`sprint7-pilot-factory-pack-2026-05-14.md`, `Depends on: ... Sprint 3`) and
  Sprint 8 (`sprint8-full-factory-adoption-2026-05-14.md`, `Depends on: Sprint 7`) both
  declared **DONE** without ever recording that Sprint 3's exit criteria were unmet.
- **Under this document's rule, both must be read retroactively as `DONE-WITH-OVERRIDE`**:
  the underlying work they describe did ship, but they proceeded past an unmet upstream
  gate without saying so. This consolidated master is the annotation of record for that
  override; it does not rewrite either sprint document (S-FAC-R3 scope, not R2).

**Checklist for future sprints (self-tagging):**

| Tag | When to use |
|---|---|
| `DONE` | All own + all depended-upon sprints' exit criteria met at closure |
| `DONE-WITH-OVERRIDE (skips: <dependency>, <criterion>)` | Proceeded despite a named unmet upstream criterion — must name it |
| `BLOCKED-ON-<ID>` | Not proceeding until a specific upstream item closes |
| `DEFERRED (<items>)` | Explicitly not attempting a subset of own exit criteria this cycle (matches `sprint8`'s existing "S8-03..08 DEFERRED" pattern — this pattern is already good practice, keep using it) |

# Passport model

Two distinct, non-overlapping passport layers coexist. Neither is a stub or superseded by
the other — they answer different questions:

| | `docs/canon/passports/` | `agents/passports/` |
|---|---|---|
| Count | 10 files | 59 files |
| Answers | "Who governs this **step of the factory loop**, and with what authority?" | "What is this **individual domain/skill agent** allowed to do, and under whose HITL gate?" |
| Layer | **Role layer** — fixed functional roles: `planner`, `executor`, `reviewer`, `operator`, `mlro`, `ctio`, `canon-judge`, `guardian-factory`, `guardian-project`, plus `schema.yaml` (the shared schema both role files validate against) | **Agent-execution layer** — per-domain-agent identity cards: e.g. `adverse_media_governor.yaml`, `aml_orchestrator.yaml`, `board_reporting_agent.yaml` (matches the 20-domain-agent roster in `AGENT-ORG-STRUCTURE.md`) |
| Key fields (sampled) | `gate_authority` (none/auto/operator/mlro/ctio), `risk_ceiling`, `invariants_enforced`, `litellm_routes` | `agent_id`, `status` (PROPOSED/ACTIVE — I-27 gated), `trust_zone`, `bounded_context`, `ports` (inbound/outbound Protocol contracts), `hitl.gate`, `compliance` mapping, `allowed_skills`/`prohibited_skills` |
| Activation state | Role passports describe standing factory-loop roles, not individually activated per-agent (they describe *positions*, e.g. `planner` = "claude-code" always) | Explicitly lifecycle-gated: sampled file shows `status: PROPOSED` with an inline note "STATUS STAYS PROPOSED — NOT activated (I-27)" — matches `TARGET-MODEL-CONFORMANCE-2026-06-25.md`'s "57/57 bound... passports remain PROPOSED/bound, not activated" |
| Shared vocabulary | Both reference **SKILLS-MATRIX skill IDs** via `allowed_skills` (role passports) and `allowed_skills`/`prohibited_skills`/`mandatory_skill_triggers` (agent passports) — this is the one point of contact between the two layers, not a merge |

**Authoritative conceptual mapping:** the role layer (`docs/canon/passports/`) defines *who
is allowed to approve/gate a step* in the factory loop (Plan→Route→Execute→Evaluate→Review→
Approve→Promote/Defer→Evidence). The agent-execution layer (`agents/passports/`) defines
*what a specific domain agent may do at runtime* once dispatched, and under which human
double's HITL gate. A single factory-loop execution can involve one role passport (e.g.
`executor`) dispatching work that is actually carried out under one or more agent passports
(e.g. `adverse_media_governor`). **This sprint does not rewrite, merge, or rename either
set** — this table is the reconciliation, not a proposal to change the directories.

# Audit integration model

- **`docs/audit/*`** = point-in-time evidence and findings. Two sub-types exist in the
  14-document set:
  - **Findings snapshots** (`factory-laws-vs-reality-2026-05-13.md`,
    `factory-orchestration-and-training-2026-05-13.md`) — explicitly time-boxed (one even
    self-declares `AUTHORITATIVE for 2026-05-13 22:55 CEST`). Read as historical fact about
    that day, never as current state.
  - **Status/supersession or install audits** (this sprint's own
    `FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md`) — evidence-graded
    re-assessments of other documents' current standing. These are the audit type that
    should be treated as part of the **official factory evidence picture** going forward,
    because their entire purpose is to stay accurate about *current* status, not to record
    one moment.
- **`docs/roadmap/*`** = living plans and status, actively indexed by
  `docs/governance/MASTER-ROADMAP.md` (self-described "consolidation index... points to
  every existing **roadmap** fragment, classifying each as AGGREGATED or SUPERSEDED").
- **The relationship is one-directional: audits feed roadmap, roadmap does not feed back
  into audit docs.** A roadmap document may cite an audit as evidence (as
  `TARGET-MODEL-CONFORMANCE-2026-06-24.md` cites `AGENT-ORG-STRUCTURE.md`), but an audit
  document's own findings are not retroactively altered by later roadmap decisions — only a
  *newer audit* can update an older audit's verdict.
- **Confirmed gap (per S-FAC-R1 Gap 1, restated here because it directly shapes this
  model):** `MASTER-ROADMAP.md`'s consolidation scope is `docs/roadmap/*` only. It does not
  index `docs/audit/*` at all. This means the "official factory evidence picture" today
  has a structural blind spot: audit-plane documents that shaped canon still in force
  (`FACTORY-CANON-ROLLOUT-v1.6.1`, `factory-laws-vs-reality`) have no discoverability path
  from the roadmap layer. (S-FAC-R2 does not close this gap — see Next repair steps.)

# Authoritative pointers

Minimum reading list for an operator or agent orienting to current factory governance,
in recommended reading order:

1. `AGENTS.md` — current Four-Partner Swarm canon (most recently touched of any document
   in this audit's scope, 2026-06-30).
2. `AGENT-ORG-STRUCTURE.md` — current org/trust-zone structure (reconciled 2026-06-21).
3. `docs/canon/software-factory-canon-v1.md` — the ratified operating canon (RATIFIED
   2026-05-14, amended 2026-05-21).
4. `docs/governance/MASTER-ROADMAP.md` — the roadmap-plane consolidation index.
5. `docs/roadmap/TARGET-MODEL-CONFORMANCE-2026-06-25.md` — latest conformance recompute
   (~86%).
6. `docs/audit/FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md` — S-FAC-R1, the
   status/supersession ground truth for the 14-document historical corpus.
7. This document — the interpretation layer tying 1-6 together, plus the sprint-namespace
   and passport-model reconciliations neither 1-6 states explicitly.

# OPEN POINTS

Carried forward from S-FAC-R1, or newly surfaced this sprint, because no honest reading of
the repo resolves them:

1. **Whether `S-A0..S-A13` (BANK launch-readiness, this sprint's own new finding) and any
   other "S-A" usage are related** is unresolved — no document in this repo cross-references
   an external "S-A" install-audit chain, so this consolidated master can only record that
   the prefix is used here for BANK launch sprints and flag that "S-A" is not a safe
   unqualified prefix.
2. **`docs/canon/passports/` vs. `agents/passports/` — whether they are intended to
   converge, stay permanently separate, or one is a predecessor of the other** is not
   stated anywhere in the repo. This document supplies a conceptual mapping (role vs.
   agent-execution layer) but that is this document's synthesis, not a repo-declared fact.
3. **`FACTORY-ROADMAP-2026-06-23.md`'s PROPOSED-vs-treated-as-live contradiction** (S-FAC-R1
   Gap 4) is annotated here with a reading rule but not resolved — only an operator
   ratification decision can resolve it.
4. **Sprint 3's F9/F10 gap itself** is unaffected by the DONE-WITH-OVERRIDE labelling
   convention this document introduces — the convention makes the override *visible*, it
   does not implement the missing rules.
5. **`docs/audit/*` still has no consolidation index** (S-FAC-R1 Gap 1) — the Audit
   integration model above describes how it *should* relate to `docs/roadmap/*`, but does
   not create the index itself.
6. **Whether the S1-S6 governance-sprint artifacts have any further amendments planned** —
   no document in scope states a review cadence for them (unlike
   `docs/canon/software-factory-canon-v1.md` §11's stated quarterly-review intent from
   Sprint 8).

# Next repair steps

Pointers only — no file besides this one is touched in S-FAC-R2:

- Add a lightweight cross-reference note in `docs/governance/MASTER-ROADMAP.md` pointing to
  this document, so the namespace/status model is discoverable from the roadmap layer
  (does not require editing the roadmap content itself, only adding a pointer).
- Add the `Status note (2026-07-20)` reading-rule text (already drafted above, under
  Document status model) into `FACTORY-ROADMAP-2026-06-23.md` as a short annotation,
  without changing its `Status: PROPOSED` header.
- Annotate `sprint7`/`sprint8` (or a shared index) with the `DONE-WITH-OVERRIDE` label
  worked out above, without rewriting either sprint's historical text.
- Create a lightweight `docs/audit/` index (or extend `MASTER-ROADMAP.md`'s scope) so the
  audit-plane blind spot (OPEN POINT 5) is closed structurally, not just described.
- Route `S-A0..S-A13` vs. any other "S-A" usage to whoever owns cross-repo naming
  conventions, so OPEN POINT 1 gets an actual answer instead of a caveat.
