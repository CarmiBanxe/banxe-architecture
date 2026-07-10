# BEST-DECISION-SELF-LEARNING-LOOP — Pointer-First Canon
# Status: CANON | Date: 2026-07-10 | ADR-161 pointer-first rule
# This file contains NO thresholds, NO weights, NO YAML gate specs.
# All numerical parameters live in governance/novelty-pipeline-config.yaml.

---

## INTEGRITY GATE

```
PINNED SOURCE
  path:      docs/sources/best-decision-self-learning-loop-2026-07-07.md
  file-sha256: e8c65d1f804548e1829618d6db2d4d91e9688f426a6c331aab70f5c993ae40fe
  body-sha256 (tail -c 34974):
               c4f71e729f3791e97429f5482c405c201cee395b4d8daff6d9828ed53c30553f
  STATUS:    SOURCE, PROPOSED, reference-only
  NOTE:      "No canon is derived here." (verbatim from source header)
```

Verify before any update:
```bash
sha256sum docs/sources/best-decision-self-learning-loop-2026-07-07.md
tail -c 34974 docs/sources/best-decision-self-learning-loop-2026-07-07.md | sha256sum
```

Both digests must match the values above. If either differs, halt and escalate.

---

## Source of Truth

The single canonical version of the Best-Decision Self-Learning Loop specification
is the **pinned source at the 2026-07-07 revision** identified above.

No other revision constitutes the canon. All other versions are superseded.

### Superseded Revisions (body NOT reproduced)

| File | sha256 | Status |
|------|--------|--------|
| `docs/sources/bdsl-self-learning-loop-2026-07-09.md` | `58089f2d1a070d643d203c0b3fb206a41718b6fef37ceeca8fe6720a0a7e7dce` | SUPERSEDED — duplicate of pinned source |
| `docs/sources/bdsl-self-learning-loop-v2-2026-07-10.md` | `20f9d65da6bc417fc219f8cdd93094ccedaf0bbc14f73d1f31bcfdcc5b709f3a` | SUPERSEDED — unnested revision, not canonised |

Bodies of superseded revisions are NOT reproduced here. Reference pinned source only.

A broader deduplication audit (14 identified copies of file-sha `e8c65d1f...`)
is tracked as a separate task and is out of scope for this canon.

---

## Principles (Reference Only)

Three invariants extracted from the pinned source. No numerical thresholds
or MAUT weights are stated here; those live in
`governance/novelty-pipeline-config.yaml`.

**I-BDSL-1 — Append-Only Immutability**
Every learning signal, decision record, and feedback event is append-only.
No UPDATE or DELETE on audit-trail tables. Implementation anchor: `schemas/agent_decision_record.schema.json`.

**I-BDSL-2 — Human-Gated Activation**
Autonomous execution upgrades (threshold relaxation, new autonomy tier activation)
require explicit human approval before taking effect.
The gate mechanics are defined in the governance config, not in this file.
Implementation anchor: `.claude/rules/agents.md#BUG-007`.

**I-BDSL-3 — Explainability by Construction**
Every decision emitted by the loop must carry a machine-readable explanation
traceable to the input signals and the active policy version.
Record schema: `schemas/agent_decision_record.schema.json`.
Test coverage: `tests/best-decision/`.

---

## Anchors

Pointer targets. Resolve these to their canonical locations; do not inline their content.

- **BUG-007** → `.claude/rules/agents.md` § "HITL Confidence Thresholds (BUG-007 — MANDATORY for every L2+ agent)"
- **Decision record schema** → `schemas/agent_decision_record.schema.json`
- **ADR-162** → `docs/adr/ADR-162-best-decision-principle.md`
- **ADR-164** → `docs/adr/ADR-164-best-decision-agent-method.md`
- **BEST-DECISION-BOUNDARY** → `docs/canon/BEST-DECISION-BOUNDARY.md`
- **PR #1080** → `docs/design/BEST-DECISION-AGENT.md` (pending merge, human-gated)
- **Governance config** → `governance/novelty-pipeline-config.yaml` (all numerical parameters)
- **Test cases** → `tests/best-decision/` (case-a through case-d YAML fixtures)
- **Concept v2** → `docs/sources/best-decision-concept-2026-07-06-v2.md`
- **Engine context** → `docs/sources/emi-banxe-engine-2026-07-06.md`

---

## Activation Readiness (2026-07-10)

> **Status:** 13 PROPOSED passports are ready for operator sign-off.
> No activation has occurred. Never-Autonomous preserved (I-BDSL-2).

### Coverage Gate — CLEARED

| Gate | Status | Source |
|------|--------|--------|
| Domain coverage | **CLEARED — 91/91 (100%)** | ORG-CODE-RECONCILIATION-v2 (sha b84a4bab…) |
| True orphans | **CLEARED — 0** | ORG-CODE-RECONCILIATION-v2 Matrix C |
| Total passports | 47 (34 existing + 13 PROPOSED) | ORG-CODE-RECONCILIATION-v2 §Summary |
| Decision Record schema | **CONFIRMED — ADR-046** (`schemas/agent_decision_record.schema.json`, sha a95d8e95…) | ADR-046 |
| BDSL MAUT schema duplicate | **SUPERSEDED** — `schemas/agent/decisionrecord.schema.json` marked superseded | feat/bdsl-activation-prep |

### 13 PROPOSED Passports — Awaiting Operator PR

All 13 are `status: PROPOSED, autonomy: L2_REVIEW`. None are activated.
Full list with SMCR owner and trust-zone: `docs/audit/bdsl-fleet-classification-2026-07-10.md`.

BDSL ENROL candidates from this batch: 1 (`case_management_agent`, RED/MLRO).
Remaining 12: passport activation for audit coverage; BDSL DecisionRecord not required.

### Never-Autonomous Preserved

- `autonomy: L2_REVIEW` is the ceiling for all 13 PROPOSED passports.
- Status change `PROPOSED → ACTIVE` requires human-gated PR, MLRO sign-off for RED agents.
- I-BDSL-2 (Human-Gated Activation) applies to every subsequent autonomy tier upgrade.
- I-27 (KYC HOLD, HITL-L4) applies additionally for `case_management_agent`. See `docs/audit/bdsl-i27-clarification.md`.

### Operator Action Required

To activate the 13 PROPOSED passports:
1. Open PR from `feat/bdsl-activation-prep` with human sign-off as PR body
2. MLRO written sign-off on `case_management_agent` (RED / CTX-01 AML/Compliance)
3. Merge only after all reviewers approved — no merge without operator sign-off

No threshold changes, no weight changes, no autonomy tier upgrade in this PR.
Activation = `status: PROPOSED → ACTIVE` in passport YAML only.

---

## Change Protocol (ADR-161)

1. Re-verify both SHA digests in the INTEGRITY GATE section before any edit.
2. Any change to this file is a canon change — requires PR with human approval.
3. Numerical thresholds and MAUT weights MUST NOT be added here; update `governance/novelty-pipeline-config.yaml` instead.
4. If the pinned source is superseded, update the INTEGRITY GATE block and move the old entry to the Superseded Revisions table.
5. Never commit directly to `main`. Feature branch → PR → human-gated merge.
