# Context & purpose

**S-FAC-R5** resolves, at the canon layer, the "S-A" naming collision that
`FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md` (S-FAC-R1) first flagged and
`FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md` (S-FAC-R2) carried forward as OPEN POINT 1
("whether S-A0..S-A13 and any other 'S-A' usage are related... no document in this repo
cross-references an external 'S-A' install-audit chain"). A fuller read this sprint shows
the collision is **more concrete and better-evidenced** than R2 could see at the time — see
below. **This document renames nothing.** It is a reading key for existing S-A usage plus a
forward constraint for new S-A usage; no historical artefact is edited, no verdict in any
cited audit is changed.

Repo: `architecture-bank-operating-model-20260718`, HEAD `15ee01d20eb9bfb3aa05a4e22e43fe8988a1fea3`.

# Existing S-A usages and collision

**What "S-A" stands for:** no document anywhere in this repo defines "S-A" as an acronym
(`rg "S-A stands for|S-A means|S-A\s*="` across `docs/` returns zero hits). It functions
purely as an ID prefix. This document does not invent an expansion — it describes usage
functionally rather than assert a meaning the repo doesn't state.

**Two real, distinct S-A lines exist, confirmed by direct read (not inferred):**

1. **Floor-2 install-audit spine** — `S-A5` (identity: A-IDV/A-KYC/A-KYB),
   `S-A6` (ledger/EMI: D-GL/B-EMI + M2.5-BIF verdict), `S-A7` (gateway/web:
   M-GATEWAY/BIF/web). Governed by `docs/audit/FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md`;
   each step pairs an `S-Ax-EXECUTION-PLAN-*-2026-07-19.md` (in `docs/roadmap/`) with
   install-audit output(s) in `docs/audit/spec-audits/*-INSTALL-AUDIT-<date>.md`. This is
   the **same** lineage this session's own prior work extended in a sibling worktree of
   this same repo (`banxe-architecture`, branch differs) — the D-GL/B-EMI/M2.5-BIF,
   M-GATEWAY-WEB, and I-api install-audits produced there, and the
   `S-GATE-REPAIR-EXECUTION-PLAN-UNIFIED-GATEWAY-AUTH-LEDGER-PAYMENTS-2026-07-20.md` in
   *this* worktree explicitly cites `I-API-INSTALL-AUDIT-2026-07-20.md` by name as an
   input, confirming the two worktrees' S-A-chain outputs are meant to feed one another,
   even though neither worktree's `docs/audit/spec-audits/` currently holds the other's
   full file set. **R2's framing of this as possibly "a coincidental prefix reuse across
   repos" is superseded by this finding** — it is one lineage, split across worktrees, not
   two unrelated ones.
2. **BANK launch-readiness track** — `S-A0` through `S-A13` (Governance & roles, Human
   Roles & HITL, Runtime prereqs, HITL live binding, Intent substrate, Compliance overlay +
   KYC, CASS closure, Rails activation, CFO stack, Crypto readiness, HII, API/BaaS/MCP,
   Security/observability, Launch governance). Governed by
   `docs/roadmap/BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` §5.

**The collision is a specific numeric overlap, not a vague one:** both lines use `S-A5`,
`S-A6`, and `S-A7` — and the two meanings are **thematically adjacent, not just
numerically coincidental**:

| Number | Floor-2 spine meaning | BANK track meaning | Adjacency |
|---|---|---|---|
| S-A5 | Identity install-audit (A-IDV/KYC/KYB) | "Compliance overlay + L2 supervised + KYC live" | both KYC/identity-themed |
| S-A6 | Ledger/EMI install-audit (D-GL/B-EMI/M2.5-BIF) | "CASS closure: daily recon, FIN060" | both ledger/CASS-themed |
| S-A7 | Gateway/web install-audit (M-GATEWAY/BIF/web) | "Rails activation" | both gateway/rails-themed |

This thematic adjacency means the collision is **not obviously a mistake to fix by
renaming one side** — it may reflect two people/agents independently numbering "the same
launch-critical phase" at two different levels of abstraction (BANK-level product sprint
vs. Floor-2-level code-install-audit), never explicitly declared as parent/child. No
document in this repo states that relationship either way — see OPEN POINTS.

**Adjacent, non-colliding but related schemes found in the same sweep** (listed for
context, not re-classified here — already partly covered by R1/R2 or out of this sprint's
S-A-specific scope):

- `S-GATE-REPAIR` — a named repair plan (not numeric), attached to the S-A7 end of the
  Floor-2 spine.
- `SPRINT-3` through `SPRINT-9` (suffixed "PHASE1" in their filenames, e.g.
  `SPRINT-7-PHASE1-AI-GOVERNANCE-...`) — governed by
  `docs/roadmap/PHASE1-MASTER-ROADMAP-SPRINTS-AND-REPAIR-LANES-OVERVIEW-2026-07-20.md`,
  which explicitly states these "attach as governance layers over the [Floor-2 A-chain]
  spine" (e.g. "Sprint 9 the tax/ledger/audit governance (S-A6 side)"). This is a **third**
  bare-`"Sprint N"`-shaped namespace beyond the two R1/R2 already found (2026-05-14
  Software-Factory-Canon Sprint 1/3/7/8; governance S1-S6) — confirming R1's warning that
  bare `"Sprint N"` is unsafe is, if anything, understated.

# S-A namespace axes (line, scope, type)

Any S-A-prefixed (or adjacent Sprint-N-shaped) identifier in this repo can be located on
three axes:

| Axis | Values found in this repo | How to read it |
|---|---|---|
| **Line** | `floor2-install-audit` (S-A5/6/7 spine) · `bank-launch` (S-A0-13) · `phase1-governance` (SPRINT-3..9) · `factory-buildout` (S-FAC-60-69) · `factory-canon-repair` (S-FAC-RN) · `software-factory-canon` (bare Sprint 1/3/7/8) · `governance-artifact` (bare S1-S6) | The program/workstream that minted the ID — never assume from the number alone |
| **Scope** | `audit` (produces install-audit/status findings) · `roadmap` (produces sprint plans/execution plans) · `install-plan` (umbrella plans like `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN`) · `sprint-tracking` (process records like `sprint7-pilot-factory-pack`) | What kind of artefact the ID's documents actually are |
| **Artefact type** | reuses the exact vocabulary already established in `FACTORY-AUDIT-INDEX-2026-07-20.md`: `findings snapshot` · `status/supersession` · `plan (DRAFT/NOT FOR MERGE)` · `process record` · `standard` — plus, newly needed here, **`execution plan`** (the `S-Ax-EXECUTION-PLAN-*.md` shape, not yet a type in that index) | Determines whether the document is re-verdictable evidence or a closed process record |

**Why numeric ranges collide:** each `Line` independently chose its own numeric range
starting near 0/1 with no cross-line registry consulted at authoring time — `S-A0-13`
(BANK) and `S-A5-7` (Floor-2) were evidently authored without either checking the other's
existing range. Nothing in this repo shows a shared numeric registry across lines; this
document is the first attempt at one, forward-only.

# Mapping table for existing S-A identifiers

**Reading aid only — not a new audit, not a status change.** Every "current status" cell
below is copied from an existing citable source, not re-derived.

| S-A ID | Line | Primary artefact(s) | Current status (per cited source) |
|---|---|---|---|
| S-A0 | bank-launch | `BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` §5 ("Planning baseline") | DRAFT/NOT FOR MERGE (document header) |
| S-A1 | bank-launch | same, §5 ("Governance & roles") | DRAFT/NOT FOR MERGE |
| S-A2 | bank-launch | same, §5 ("Runtime prereqs") | DRAFT/NOT FOR MERGE |
| S-A3 | bank-launch | same, §5 ("HITL live binding") | DRAFT/NOT FOR MERGE |
| S-A4 | bank-launch | same, §5 ("Intent substrate + L0/L1") | DRAFT/NOT FOR MERGE |
| **S-A5** | bank-launch | same, §5 ("Compliance overlay + L2 + KYC live") | DRAFT/NOT FOR MERGE |
| **S-A5** | floor2-install-audit | `docs/roadmap/S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md`; audits `A-IDV-INSTALL-AUDIT`, `A-KYB-INSTALL-AUDIT`, `A-KYC-INSTALL-AUDIT` (`docs/audit/spec-audits/`) | per `PHASE1-MASTER-ROADMAP-...-OVERVIEW-2026-07-20.md`: "execution-ongoing (audits done)" |
| **S-A6** | bank-launch | `BANK-MASTER-ROADMAP...`, §5 ("CASS closure") | DRAFT/NOT FOR MERGE |
| **S-A6** | floor2-install-audit | `docs/roadmap/S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` + `docs/roadmap/S-A6-VERIF-NO-DIRECT-MCP-LEDGER-WRITES-2026-07-20.md`; audit `LEDGER-EMI-INSTALL-AUDIT-2026-07-20.md` | per PHASE1 overview: "execution-ongoing (audit shell)"; in the sibling worktree, the same lineage produced `D-GL-INSTALL-AUDIT`/`B-EMI-INSTALL-AUDIT`/`M2.5-BIF-INSTALL-AUDIT` (separate files, not present in this worktree) |
| **S-A7** | bank-launch | `BANK-MASTER-ROADMAP...`, §5 ("Rails activation") | DRAFT/NOT FOR MERGE |
| **S-A7** | floor2-install-audit | `docs/roadmap/S-A7-EXECUTION-PLAN-M-GATEWAY-BIF-WEB-2026-07-19.md`; audit `M-GATEWAY-WEB-INSTALL-AUDIT-2026-07-20.md` | per PHASE1 overview: "execution-ongoing (audit shell)"; sibling worktree also produced an `S-A8-GATEWAY-SCOPE-RECONCILIATION` follow-up (not present in this worktree) |
| S-A8 | bank-launch | `BANK-MASTER-ROADMAP...`, §5 ("CFO stack") | DRAFT/NOT FOR MERGE |
| S-A9 | bank-launch | same, §5 ("Crypto readiness") | DRAFT/NOT FOR MERGE |
| S-A10 | bank-launch | same, §5 ("HII client surface") | DRAFT/NOT FOR MERGE |
| S-A11 | bank-launch | same, §5 ("API/BaaS/MCP exposure") | DRAFT/NOT FOR MERGE |
| S-A12 | bank-launch | same, §5 ("Security/observability closure"); also cited directly by `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` ("риск: экспозиция только после S-A12") | DRAFT/NOT FOR MERGE — but note the Floor-2 plan citing it directly is the **one confirmed cross-line reference** found in this sweep, suggesting the lines are not fully sealed from each other in practice |
| S-A13 | bank-launch | same, §5 ("Launch governance: dry-run, L3-gate, go-live") | DRAFT/NOT FOR MERGE |

**Bold rows (S-A5/6/7) are the confirmed collision set.** Rows S-A0-4 and S-A8-13 belong
to `bank-launch` only in this worktree's evidence — no Floor-2-line document was found
reusing those specific numbers.

# Forward S-A naming rules

Effective for any **new** S-A-shaped identifier from this point forward. Does not rename
any row in the mapping table above.

1. **Every new S-A ID must carry an explicit line prefix**, not bare `S-Ax`:
   - `FLR2-S-Ax` — Floor-2 install-audit spine.
   - `BANK-S-Ax` — BANK launch-readiness track.
   - Any future third line introducing an `S-A`-shaped ID must mint its own prefix here
     before first use, not reuse `FLR2-`/`BANK-` for a different scope.
2. **No numeric range may be reused across lines without an explicit cross-reference.** If
   a new ID would numerically collide with an existing ID in a *different* line (as S-A5/6/7
   already do), the authoring document must add a one-line note citing the other line's use
   of that number and stating whether it is intentional-adjacency (as with S-A5/6/7's
   thematic overlap) or coincidental.
3. **Required header fields for any new S-A-shaped document:** every new document using
   this pattern must state, in its own header/status block:
   - `Line:` (one of the registry values in the axes table, or a newly-minted one)
   - `Scope:` (audit / roadmap / install-plan / sprint-tracking)
   - `Type:` (reusing `FACTORY-AUDIT-INDEX-2026-07-20.md`'s type vocabulary, adding
     `execution plan` where needed)
   - `Date:`
   This mirrors the header discipline `BANK-MASTER-ROADMAP...` and the `S-Ax-EXECUTION-PLAN-*`
   documents already mostly follow (Status/Date/branch/producer) — this rule makes the
   line/scope/type fields mandatory rather than incidental.
4. **A cross-line registry check is required before minting a new ID.** Before assigning a
   new `S-Ax` (in any line), the author must grep the repo for that exact number under
   every known line prefix and record the result — even a "no collision found" result,
   logged per the Audit trail requirements below.

# Audit trail requirements for S-A decisions

Naming decisions (minting a new S-A ID, marking a collision, deprecating a numeric range)
are **consequential decisions** under `docs/roadmap/FACTORY-AUDIT-TRAIL-MINIMUM-STANDARD-2026-07-20.md`
and must be logged using its exact field sets — this document adds no competing fields.

**Execution-level fields** (per R4's table) apply to the whole naming-decision sprint:
correlation ID, timestamps, identity, role passport reference, agent passport reference (if
any), intent, canon/policy context, input artefacts, tool actions, decisions/approvals,
outputs, side effects, status.

**Decision-level fields** (per R4's table) apply to the specific naming call:

| Field | Requirement for an S-A naming decision |
|---|---|
| Decision ID | e.g. `<sprint-ID>-D<n>` |
| Who decided | human or agent + role passport (`docs/canon/passports/*.yaml`) |
| Rule/canon section referenced | this document's "Forward S-A naming rules" section, by rule number |
| Evidence consulted | the cross-line registry check output (rule 4, above) — must show the actual grep/search performed, not just an assertion of "no collision" |
| Outcome + justification | the ID minted (with line prefix), and whether a collision note was required/added |

**Worked example (illustrative — produced live during this sprint, not a retroactive log
entry, matching the discipline established in S-FAC-P1):** had this sprint needed to mint a
new ID rather than only document existing ones, its decision-level record would read:
Decision ID `S-FAC-R5-D1`; who = Claude Code under `executor` role authority; rule =
"Forward S-A naming rules" rule 1+4; evidence = the `rg "\bS-A[0-9]"` sweep run this sprint
across `docs/canon/`, `docs/governance/`, `docs/roadmap/`, `agents/passports/`, `docs/audit/`
(32 files matched); outcome = no new ID minted this sprint — this sprint only mapped
existing usage, so rule 1-4 apply to *future* sprints, not retroactively to this one.

# Applicability and non-goals

**Constrains:** any future document, in any line (`bank-launch`, `floor2-install-audit`,
`phase1-governance`, `factory-buildout`, `factory-canon-repair`, or a newly-minted line),
that would introduce a new `S-A`-shaped identifier or a bare `Sprint N` reference.

**Does not constrain / leaves as-is:**

- The existing `S-A0-13` table in `BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md`
  — read via this document's mapping table, not edited.
- The existing `S-A5-EXECUTION-PLAN`/`S-A6-EXECUTION-PLAN`/`S-A7-EXECUTION-PLAN` documents
  and their install-audit outputs — same.
- The sibling worktree's own S-A6-S-A9 install-audit chain (D-GL/B-EMI/M2.5-BIF,
  M-GATEWAY-WEB, S-A8 reconciliation, I-api) — out of this document's single-artefact scope
  entirely; referenced here only as evidence that the two lines are one lineage.
- `SPRINT-3` through `SPRINT-9` (PHASE1), `S-GATE-REPAIR`, and the pre-existing Sprint
  1/3/7/8 (2026-05-14) and S1-S6 namespaces — acknowledged as adjacent evidence, not
  re-classified here (already covered, where covered, by S-FAC-R1/R2).

**Explicit non-goals:**

- No file is renamed.
- No document's `Status:` header is changed.
- No audit verdict is re-derived or altered.
- This document does not decide whether Floor-2's S-A5/6/7 are formally sub-phases of
  BANK's S-A5/6/7 — that relationship is preserved as an open question (below), not
  resolved by assertion.

# OPEN POINTS

1. **Whether Floor-2's S-A5/6/7 are intentionally nested inside BANK's S-A5/6/7** (given
   the confirmed thematic adjacency) **or are a coincidental collision** is not resolved by
   any document found in this sweep. This is the single most consequential open question
   this document surfaces — an operator or the roadmap-governance room should decide which,
   since the answer changes whether future Floor-2 install-audits should explicitly cite
   themselves as "sub-phase of BANK-S-Ax" going forward.
2. **The one confirmed cross-line reference** (`FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md`
   citing `S-A12` directly) suggests the lines are not fully sealed in practice, even though
   no document declares them merged. Whether this is a deliberate shorthand or an
   unintentional leak between lines is unresolved.
3. **No acronym expansion for "S-A" exists anywhere** — this document deliberately did not
   invent one. If an operator wants a defined expansion, that is a naming decision under
   this document's own "Forward S-A naming rules," not something this document should
   pre-empt.
4. **`SPRINT-3..9` (PHASE1) and `S-GATE-REPAIR`** are documented here only as context; a
   full namespace treatment of the PHASE1 governance-sprint line (parallel to what this
   document did for S-A) remains a separate, un-scoped future repair item.
5. **No enforcement mechanism exists** for the "Forward S-A naming rules" — as with
   `FACTORY-AUDIT-TRAIL-MINIMUM-STANDARD-2026-07-20.md`'s own OPEN POINT 2, this document
   specifies a rule but not who checks compliance with it.
