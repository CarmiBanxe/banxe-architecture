# Context & purpose

The factory repair canon (S-FAC-R1 through R5) is in place: sprint namespaces are
clarified (`docs/roadmap/FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md`), status and
supersession are audited (`docs/audit/FACTORY-CANON-STATUS-AND-SUPERSESSION-AUDIT-2026-07-20.md`),
key artefacts are indexed (`docs/roadmap/FACTORY-AUDIT-INDEX-2026-07-20.md`), a minimum
audit-trail standard exists and has been piloted
(`docs/roadmap/FACTORY-AUDIT-TRAIL-MINIMUM-STANDARD-2026-07-20.md`, `S-FAC-P1`), and the
S-A namespace collision is named and constrained
(`docs/canon/S-A-NAMESPACE-MODEL-2026-07-20.md`). This guide adds one more dimension on
top of that stack: **how much internal reasoning effort to spend before acting**, so the
factory balances quality against cost/latency deliberately rather than defaulting to
either extreme.

**This document does not change any of the above.** It does not redefine audit-trail
fields or S-A naming — it only recommends, as an additional (optional) piece of execution
context, which effort level a given task type should default to.

**Sourcing note, stated plainly:** this guide draws on general, publicly-known concepts
about reasoning/thinking-budget controls in LLMs (more internal reasoning tokens before an
answer tends to help on hard, ambiguous, or high-stakes problems, at higher latency/cost;
shallow effort is adequate for narrow, low-stakes, easily-reversible problems). It was
written without fetching or verifying the specific external articles named in this
sprint's brief (Raschka's piece, Claude's effort/thinking documentation) — it should not be
read as a verified summary or quotation of those sources, only as conceptually-aligned
guidance grounded in this repo's own real task history.

# Reasoning effort as a factory tool

- **What "effort" means here:** the amount of internal reasoning an agent spends —
  investigating evidence, weighing alternatives, checking cross-references — before
  committing to an answer or an edit. This repo's own sprints already vary this
  implicitly (compare a one-bullet annotation to a multi-file grep-and-read
  investigation); this guide makes that variation an explicit, named choice instead of an
  implicit one.
- **Four levels, used consistently with this repo's own recent practice:**
  - **LOW** — minimal deliberation; the answer is close to mechanical.
  - **MEDIUM** — some investigation and cross-checking, but the shape of the task is
    already well-defined.
  - **HIGH** — substantial evidence-gathering, multiple sources cross-checked, real
    judgment calls made and justified.
  - **MAX** — exhaustive investigation reserved for the rare case where both the stakes
    and the ambiguity are at their highest simultaneously.
- **Trade-off:** higher effort generally improves correctness on hard, ambiguous, or
  high-stakes tasks — it catches contradictions, finds the right file before asserting a
  fact, avoids the kind of silent invention this whole repair line has deliberately
  avoided. It costs more tokens and time. Lower effort is faster and cheaper, and is the
  right choice when the task genuinely doesn't need more — spending HIGH effort on a
  trivial, pre-scoped edit is waste, not rigor.
- Effort level is **not** a substitute for the evidence-only discipline already binding in
  this repo (citing real paths, not inventing facts) — that discipline applies at every
  effort level; effort only changes how much investigation happens before the discipline is
  applied.

# Risk and complexity rule

**Core rule:** use higher effort when **(a)** the cost of a wrong answer is high, **and/or**
**(b)** the space of possible solutions is large or non-obvious. Use lower effort when
errors are cheap and easily corrected, and the solution is narrow and close to obvious.

Grounded in this repo's own recent history:

- **High cost of error, large solution space → HIGH/MAX.** S-FAC-R1's finding that Sprint
  3's exit criteria (Guardian rules F9/F10) were never met, yet Sprint 7/8 both declared
  DONE, required cross-checking three independent sources
  (`sprint3-routing-canon-enforcement-2026-05-14.md`, `guardian-factory.yaml`,
  `TARGET-MODEL-CONFORMANCE-2026-06-24.md`'s "16 rules" count) before it could be stated as
  fact rather than guessed — a wrong call here would have either hidden a real governance
  gap or falsely accused a closed sprint of failure. That's a HIGH-effort task by this
  rule.
- **Low cost of error, narrow solution space → LOW/MEDIUM.** `S-FAC-P1`'s single new row
  in `FACTORY-AUDIT-INDEX-2026-07-20.md` had its wording, placement, and type
  (`standard`) already specified by the immediately-preceding sprint (`S-FAC-R4`'s own
  "Integration into FACTORY-AUDIT-INDEX" section) — executing a pre-agreed instruction with
  a narrow, reversible edit. That's LOW-to-MEDIUM by this rule, even though it happened
  inside a governance-adjacent repair line.
- **The same logic applies mid-scale.** `FLR2-S-A7-P1`'s annotation (citing
  `I-API-INSTALL-AUDIT-2026-07-20.md` to close one specific OPEN POINT) needed one
  confirmation grep and one cross-reference read, but the annotation itself had to be
  worded carefully enough not to overclaim Block 2 as complete — a MEDIUM task with one
  HIGH-effort-shaped constraint (don't overstate the verdict) embedded in it. Effort level
  is a default, not a rigid single label per whole sprint.

# Recommended effort per task type

| Task type | Examples (this repo) | Recommended effort | Rationale |
|---|---|---|---|
| Quick textual clarifications / small annotations | `S-FAC-P1` (one index row, wording pre-specified); `FLR2-S-A7-P1` (one OPEN POINT note) | LOW–MEDIUM | Narrow, reversible, often executing an instruction already agreed in a prior sprint |
| Applying already-ratified canon (e.g. producing audit-trail exemplars) | `S-FAC-P1`'s execution-level/decision-level exemplar tables; `FLR2-S-A7-P1`'s exemplar tables | MEDIUM | The field set and format are fixed by `FACTORY-AUDIT-TRAIL-MINIMUM-STANDARD-2026-07-20.md`; the work is filling it accurately, not designing it |
| New governance decisions (overrides, namespace rules, new canon principles) | `S-FAC-R1`'s override finding; `S-FAC-R5`'s S-A collision mapping; this repo's own `FEATURE-EVALUATION-AND-PLACEMENT-CANON-2026-07-20.md` | HIGH | Wrong or poorly-evidenced calls here propagate — future sprints read these as settled fact; multiple independent sources typically need cross-checking |
| Product-level design decisions (gateway, ledger, KYC/identity) | `S-A5/6/7-EXECUTION-PLAN-*` authoring; `S-GATE-REPAIR`-shaped design work | HIGH–MAX | Errors are expensive here in a literal sense (compliance, payment-rail, or ledger-adjacent surfaces) and the solution space is genuinely large (multiple services, multiple invariants, real regulatory framing) |
| Deep code/architecture analysis (multi-file install audits) | the I-API install-audit conducted earlier this session (orphaned `src/api/gateway.py` vs. wired `services/api_gateway/`/`require_auth`, cross-checked against the build-spec) | HIGH | Requires reading real code across several files and reconciling it against a spec before any verdict can be stated as fact, not guessed |

No entry here is a hard rule — it is this guide's default baseline, per the Factory usage
rules below.

# Linkage to audit trail and passports

- Effort level is additional **execution context**, not a new mandatory field.
  `FACTORY-AUDIT-TRAIL-MINIMUM-STANDARD-2026-07-20.md`'s execution-level record already has
  a `canon/policy context` field — for serious decisions (governance, overrides, new
  canon), the chosen effort level and a one-line rationale **SHOULD** be included as part of
  that field's content, not as a separate required column this guide is not scoped to add.
- This is explicitly a *should*, not a *must*: this sprint does not amend the audit-trail
  standard's required-field list (out of this sprint's single-artefact scope), it only
  recommends how existing fields get used for effort-relevant decisions.
- **Passports still govern who decides; this guide governs how deeply that same decider
  thinks before deciding.** A role passport's `gate_authority` (e.g. `mlro`, `ctio`,
  `none`) is unaffected by effort level — an MLRO-gated decision stays MLRO-gated whether
  it was reached at MEDIUM or MAX effort. The two are independent axes: authority answers
  "who may approve this," effort answers "how much was invested in getting the answer
  right before it reached that gate."

# Factory usage rules

1. **Do not default to MAX effort for everything.** Most of this repo's own repair-line
   sprints (R1-R5, S-FAC-P1) ran well below MAX and were still correct and well-evidenced
   — reserving MAX for genuinely rare, maximally-ambiguous-and-high-stakes cases keeps the
   factory fast where it can be.
2. **Use HIGH or MAX for new canon, governance overrides, or namespace decisions.** These
   propagate forward and are read as settled fact by future sprints — under-investing here
   is the single highest-leverage mistake this guide exists to prevent.
3. **Use MEDIUM as the default for most factory repair/annotation sprints** — applying an
   already-specified structure (a pre-agreed index row, an audit-trail exemplar, a
   cross-reference note) rarely needs more.
4. **Use LOW or MEDIUM for trivial, easily-reversible edits** — a wording fix, a single
   pre-agreed pointer, anything a `git revert` would cleanly undo with no downstream
   consequence.
5. **This guide sets a default baseline; it never overrides operator judgment.** The
   operator may explicitly request a different effort level for any task at any time (as
   already demonstrated in this session — the operator's own "REASONING EFFORT (MANDATORY)"
   instruction is exactly this kind of override in practice, applied ahead of this
   document's own existence), and that instruction always wins.

# OPEN POINTS

1. **Effort usage is not yet tracked as a metric.** No mechanism exists to record, across
   sprints, which effort level was actually used and whether outcomes correlated with that
   choice — a future improvement could add per-sprint effort-profile reporting, but this
   guide does not build that reporting itself.
2. **This guide assumes Claude-like effort/thinking controls specifically.** Applying it to
   other models or tools that expose reasoning effort differently (or not at all) is left
   open — no claim is made here about portability beyond this session's actual tool.
3. **Sourcing caveat, restated for clarity:** the external articles named in this sprint's
   brief were used as conceptual background only, not fetched or quoted verbatim — if a
   future sprint wants this guide grounded more precisely in those specific sources, that
   is a follow-up task, not something this document already claims to have done.
