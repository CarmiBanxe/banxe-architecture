# Context & purpose

This canon establishes a repeatable, two-step gate for evaluating and placing every future
feature the operator loads into this ecosystem (via repo link, task, or spec): **Step 1 —
Value Assessment** must complete, with an explicit ACCEPT/REJECT and placement decision,
before **Step 2 — Installation** may begin. It does not itself evaluate or install any
named feature — it defines the method only, per this sprint's own scope.

**Builds on, and does not override:**

- `docs/canon/software-factory-canon-v1.md` — the ratified factory operating canon (roles,
  five mandatory packs, amendment rules). This document is a **new canon artefact**, not an
  amendment to that one; see OPEN POINTS on whether it needs the same CTIO/Operator
  ratification path software-factory-canon-v1 §11 defines for its own changes.
- `docs/roadmap/FACTORY-CANON-CONSOLIDATED-MASTER-2026-07-20.md` — sprint-namespace and
  passport-model conventions this canon's own installation sprints must follow.
- `docs/roadmap/FACTORY-AUDIT-TRAIL-MINIMUM-STANDARD-2026-07-20.md` — the execution-level
  and decision-level field sets every Step 2 installation sprint must fill (reused
  verbatim below, not redefined).
- `docs/canon/S-A-NAMESPACE-MODEL-2026-07-20.md` — the line-prefix and registry-check rules
  every installation sprint's correlation ID must follow.

**A naming discrepancy found and flagged, not silently resolved:** this sprint's task
uses "Banksy" as the product/consumer side of the factory→product relationship. A repo
sweep (`rg -il "banksy"`) found exactly 3 files using that term, and its one detailed usage
— `docs/roadmap/PHASE2-PHASE-A-AND-S-A6-VERIFICATION-EXECUTION-CHECKLIST-2026-07-20.md` —
defines "Banksy sandbox" explicitly as **synthetic, fictional demo components with "no
connection to any real bank, EMI, customer, or endpoint," to be deleted before real
inventory begins.** This is a different meaning than "a real product fork of the factory."
This canon proceeds using "Banksy" exactly as the operator's task used it (the operator's
own naming is authoritative for what they mean), but does **not** assert that "Banksy" and
"BANXE"/`banxe-emi-stack` are the same thing, or that a real Banksy fork currently exists —
that is recorded as OPEN POINT 1, for the operator to resolve, not invented here.

# Feature value assessment (factory vs Banksy)

Every feature gets scored on two independent axes before any installation decision:

| Axis | HIGH | MEDIUM | LOW |
|---|---|---|---|
| **Factory value** | Directly strengthens factory core or governance — e.g. improves audit trails, passports, sprint/workflow ergonomics, agent tracing/orchestration/safety, reduces friction for *future* features | Improves factory ergonomics or observability without touching core governance | Mostly product-specific; little or no effect on how the factory itself operates |
| **Banksy value** | Directly supports key product outcomes — e.g. real user-facing flows, compliance hardening, gateway/ledger/KYC/UX for real users | Useful to the product but not critical to a key outcome | Mostly technical/internal; small or no visible product impact |

**Scoring discipline:**

- Score both axes independently — a feature can be HIGH/HIGH, HIGH/LOW, LOW/HIGH, or
  LOW/LOW; one axis's score must never be inferred from the other.
- Cite concrete evidence for each score (what the feature does, which factory or product
  surface it touches) — a bare "HIGH" with no reasoning is not an acceptable assessment
  under this canon, matching this repo's existing evidence-only discipline.
- Where the feature's actual behavior is unclear from the operator's link/spec, score
  conservatively (MEDIUM, not HIGH) and record the uncertainty rather than guessing HIGH.

**Worked pattern (generic, no feature named):** a feature that adds a new audit-trail field
type used only by one product screen scores factory=MEDIUM (touches the audit-trail
surface, but narrowly) / Banksy=HIGH (directly visible to real users) → placement leans
BANKSY ONLY or SHARED depending on how reusable the field type is elsewhere (see next
section's decision table).

# Placement decisions (factory-only, Banksy-only, shared, reject)

| Factory value | Banksy value | Placement |
|---|---|---|
| HIGH | HIGH | **SHARED** — install in factory first (upstream), then propagate to Banksy |
| HIGH | MEDIUM/LOW | **FACTORY ONLY** — Banksy may consume later via fork if it turns out relevant, but is not the reason to install now |
| MEDIUM/LOW | HIGH | **BANKSY ONLY** — install directly in the Banksy fork; do not add factory-layer complexity for a feature the factory itself gets little from |
| LOW | LOW/MEDIUM | **REJECT** (or defer) — see reject criteria below |
| Any other combination where a genuine duplicate of existing factory or product capability is found | — | **REJECT** — duplication, per ADR-102's Duplication Audit discipline (already binding elsewhere in this repo; this canon does not introduce a second duplication-check mechanism, it applies the existing one) |

**ACCEPT requires**, explicitly recorded:

1. The two axis scores with evidence.
2. The placement (FACTORY ONLY / BANKSY ONLY / SHARED).
3. A one-line rationale connecting the scores to the placement (not just restating the table).

**REJECT requires**, explicitly recorded (never silent):

- One of: **poor value** (both axes LOW/LOW with no mitigating factor), **risk** (security,
  compliance, or invariant risk outweighing the value), **misfit** (doesn't fit either the
  factory's or Banksy's actual architecture), or **duplication** (an ADR-102 Duplication
  Audit finds an existing equivalent).
- A feature is REJECT until an ACCEPT decision is explicitly recorded — there is no default
  install path.

# Installation sequencing and forks

**FACTORY ONLY:**
- Plan changes only in factory-layer repos/files (this repo's `docs/canon/`,
  `docs/roadmap/`, `agents/passports/`, `docs/canon/passports/`, or equivalent factory
  tooling).
- State explicitly how the feature improves factory behavior and how a future project
  (Banksy or otherwise) could reuse it later via fork, even though this installation does
  not do that propagation.

**BANKSY ONLY:**
- Plan changes only in the Banksy repo/fork.
- Treat the factory as **read-only** for this installation sprint — no factory-layer file
  is touched.

**SHARED — two-phase model:**
- **Phase A (factory, upstream):** install the feature in the factory layer first. The
  factory is the source of truth for anything reused across projects.
- **Phase B (fork/adapt for Banksy):** propagate into the Banksy fork. Phase B must
  explicitly separate:
  - **Identical across factory and Banksy** — copied or referenced as-is.
  - **Project-specific to Banksy** — adapted, not blindly copied; the adaptation and why
    it diverges from the factory version must be stated.
- Phase B never starts before Phase A completes and is recorded ACCEPT/ACTIVE-in-factory
  (see next section's terminal states) — this mirrors the "factory as upstream" relationship
  the operator's task describes.

# Audit trail and S-A naming for feature work

Every Step 2 installation sprint reuses `FACTORY-AUDIT-TRAIL-MINIMUM-STANDARD-2026-07-20.md`'s
exact field sets — this canon does not redefine or duplicate them:

**Execution-level record** (per that standard's table): correlation ID, timestamps,
identity, role passport reference, agent passport reference (if any), intent, canon/policy
context, input artefacts, tool actions, decisions/approvals, outputs, side effects, status.

**Decision-level record, minimum one per feature — for the ACCEPT/placement decision
itself:** decision ID, who decided (+ role passport), rule/canon section referenced (this
document's Placement decisions table), evidence consulted (the feature's own spec/link plus
the two axis scores), outcome (placement) + justification.

**Correlation ID naming** follows `docs/canon/S-A-NAMESPACE-MODEL-2026-07-20.md`'s Forward
Naming Rules exactly:
- A line-prefixed ID, e.g. `FAC-FEAT-<name>-P1` (factory-only), `BNK-FEAT-<name>-P1`
  (Banksy-only), or a paired `FAC-FEAT-<name>-A` / `BNK-FEAT-<name>-B` for SHARED's two
  phases.
- A cross-line registry check (grep for the chosen ID before use) is required before
  minting, exactly as that model's Rule 4 requires — logged as evidence in the
  decision-level record.
- No feature installation may mint a bare, unprefixed ID.

**Terminal states** — every feature this canon processes must end recorded as exactly one
of:

| State | Meaning |
|---|---|
| **ACTIVE in factory** | installed FACTORY ONLY, or SHARED Phase A complete, Phase B not yet done |
| **ACTIVE in Banksy** | installed BANKSY ONLY |
| **ACTIVE in both** | SHARED, both Phase A and Phase B complete |
| **REJECTED** | Step 1 concluded REJECT; reason recorded per the criteria above |

# Applicability to future operator tasks

- Any future operator message that loads a feature — a repo link, a task description, a
  spec file — triggers this canon **automatically**. It does not need to be re-cited by
  name each time, the same way this repo's factory-repair canon (sprint-namespace model,
  audit-trail standard, S-A naming) has governed behavior in this repo without re-invocation
  every turn.
- **Step 1 always precedes Step 2.** If asked to install something without a stated
  placement decision first, that is the signal to stop and complete Step 1 before touching
  any file — not an implicit exception to this canon.
- Every ACCEPT decision states its placement in plain text (FACTORY ONLY / BANKSY ONLY /
  SHARED) before any installation edit is made; every REJECT states its reason before the
  conversation moves on.
- This canon does not evaluate itself against its own gate — it is a methodology document,
  not a feature.

# OPEN POINTS

1. **What "Banksy" actually refers to is unresolved.** The only detailed in-repo usage
   defines it as a synthetic sandbox naming convention for fictional demo components with
   explicitly "no connection to any real bank" — not necessarily the same thing as a real
   product fork of this factory. This canon uses "Banksy" as the operator's task used it,
   but the operator should confirm: is "Banksy" the same as BANXE/`banxe-emi-stack`, a
   distinct real fork, or something not yet built? The SHARED/Phase-B mechanism in this
   canon works the same regardless of the answer, but the answer changes which actual repo
   Phase B installs into.
2. **Whether this canon itself requires CTIO/Operator ratification** under
   `software-factory-canon-v1.md` §11's amendment-constraint rules is not resolved here —
   the same open question `FACTORY-AUDIT-TRAIL-MINIMUM-STANDARD-2026-07-20.md` left for
   itself (OPEN POINT 5 there). This canon is arguably a new process layer, not a structural
   amendment to an existing pack/role/invariant, but that line is for operator judgment.
3. **No enforcement mechanism exists** beyond this document stating the rule and future
   turns following it — there is no automated check that a feature installation actually
   completed Step 1 first.
4. **No worked example with a real, named feature exists yet** — by this sprint's own
   style constraint, no feature is named here. The first real feature the operator loads
   will be this canon's first live test.
