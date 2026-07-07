---
directive_id: DIRECTIVE-BESTDEC-RATIFY-001
title: "Ratification checklist — Best-Decision Q1–Q5 consultant convergence (operator + Central ack)"
status: RATIFIED-OPERATOR
classification: governance directive (pointer-first per ADR-102)
issued: 2026-07-07
issuer: Terminal-B (specproj sp39; prepare-only)
ack_required: [operator, central]
ack_state:
  operator: RATIFIED (Moriel Carmi, 2026-07-07, chat-authorized "я всё одобряю" — sp40 ack)
  central: PENDING (co-sign required to reach CLOSED)
q_verdicts: {Q1: APPROVE, Q2: APPROVE, Q3: APPROVE, Q4: APPROVE, Q5: APPROVE}
activation_policy: deferred-to-approved-ADR
invariants_preserved: [I-27, variant-2]
related:
  - "docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md (synthesis, PR #1091)"
  - "docs/sources/consultant-response-best-decision-2026-07-07.md (Perplexity SSOT)"
  - "docs/adr/ADR-162-best-decision-principle.md"
  - "docs/adr/ADR-163-sync-canon.md"
  - "docs/adr/ADR-164-best-decision-agent-method.md"
  - "docs/design/BEST-DECISION-AGENT.md (PR #1080)"
  - "docs/canon/BEST-DECISION-BOUNDARY.md"
  - "CLAUDE.md §10 (Configuration-over-Hardcoding)"
---

# DIRECTIVE-BESTDEC-RATIFY-001 — Q1–Q5 ratification checklist

> **STATUS: RATIFIED-OPERATOR — Central co-sign PENDING (moves to CLOSED once received).**
>
> **Operator ratification (2026-07-07, sp40):** Moriel Carmi approved ALL Q1..Q5 in chat
> ("я всё одобряю"). This ack is append-only and is recorded per-Q below. It endorses
> ARCHITECTURAL DIRECTION only — **activation of each Q remains deferred to its own
> human-ratified ADR / governed-config PR** (see per-Q "Next action" blocks). I-27 and
> variant-2 remain preserved; numeric parameters remain governed-config *proposals* per
> CLAUDE.md §10; the Best-Decision method is **not** activated by this ack.
> This directive is a **decision artefact** (ADR-102: pointer-first, no source restate). The
> substantive verdicts under review live in
> `docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md` (PR #1091), which itself consolidates two
> independent rulings (Central inline + Perplexity Governance/Safety) that converge on all five
> questions.
>
> **While this directive remains OPEN, the Best-Decision method stays ADVISORY / PROPOSED and is
> NOT activated.** Activation of each ratified Q requires a **separate governed ADR** (extending
> ADR-162 / ADR-164) and, where applicable, a governed-config PR against
> `governance/novelty-pipeline-config.yaml` (or equivalent). No threshold, weight, DAG, or gate is
> live by virtue of this directive alone.

## Preservation clauses (STOP-critical)

- **I-27 preserved.** No autonomous production-state mutation is enabled by this directive.
- **Variant-2 preserved.** Advisory-only until ratified; the current single-stage flow remains in
  force until an activation ADR is merged.
- **Config-over-Hardcoding (CLAUDE.md §10).** Every numeric parameter named in the synthesis is a
  **governed-config *proposal***; ratification here authorises *drafting* the config-PR, not
  landing values inline.
- **ADR-102.** This directive references the synthesis by pointer; it does not restate the
  underlying reasoning, evidence, or consultant sources.
- **HITL.** No auto-merge is armed for the follow-on ADR/config PRs. Ratification, activation, and
  each downstream landing are human-gated at every step.

## Ratification items (per Q — check EXACTLY ONE per Q)

### Q1 — Step 0 deterministic admissibility-gate BEFORE scoring

**Question ratified:** Do we ratify the introduction of a Step 0 deterministic admissibility DAG
(static, human-authored, append-only) that runs **before** any scoring, so hard-admissibility is a
separate first stage and execution-class alone is treated as necessary-but-not-sufficient?

**Scope reminder:** this ratification records ARCHITECTURAL DIRECTION only. **Activation of Step 0
(the DAG itself and its rules) requires a separate human-ratified ADR** extending ADR-162 /
ADR-164; nothing goes live via this checkbox.

- [x] APPROVE — direction endorsed; open follow-on ADR to activate Step 0.
- [ ] AMEND — direction endorsed with amendments (record below).
- [ ] REJECT — do not adopt Step 0 admissibility-gate; keep current single-stage flow.

Amendments / notes:

```
(operator/Central)
```

**Operator ack:** RATIFIED by: Operator (Moriel Carmi), 2026-07-07, chat-authorized "я всё одобряю". Central co-sign: PENDING.  
**Central ack:** PENDING — Central co-sign required to move Q1 to CLOSED.

**Next action (activation, human-gated):** Activation via separate governed ADR/config-PR,
human-gated (I-27). NOT activated by this ack. Q1 activation opens the ADR for the Step 0
deterministic admissibility-gate DAG (static, human-authored, append-only), which in turn
unblocks safe activation of the AML orchestrator Decision Method (PR #1094 — currently
PROPOSED and gated on Q1 Step-0-gate ADR).

---

### Q2 — Level 0 / 1 / 2 lexicographic aggregation (NOT weighted linear sum for high-risk)

**Question ratified:** Do we ratify the lexicographic aggregation model for high-risk decisions —
Level 0 hard admissibility `{0,1}` (Step 0), Level 1 risk-satisfice (prefer `R < α`; else
`argmin R`), Level 2 additive MAUT over admissible candidates with `R` excluded from the additive
layer — replacing any weighted linear sum for the high-risk case?

**Scope reminder:** ARCHITECTURAL DIRECTION only. **Activation of Level 0/1/2 (including any
numeric α, weights, or thresholds) requires a separate human-ratified ADR** and a governed-config
PR against `governance/novelty-pipeline-config.yaml` (or equivalent). Weights and thresholds
proposed in the synthesis remain *proposals* until that PR lands.

- [x] APPROVE — direction endorsed; open follow-on ADR + governed-config PR to activate Level 0/1/2.
- [ ] AMEND — direction endorsed with amendments (record below).
- [ ] REJECT — do not adopt lexicographic aggregation; keep current aggregation.

Amendments / notes:

```
(operator/Central)
```

**Operator ack:** RATIFIED by: Operator (Moriel Carmi), 2026-07-07, chat-authorized "я всё одобряю". Central co-sign: PENDING.  
**Central ack:** PENDING — Central co-sign required to move Q2 to CLOSED.

**Next action (activation, human-gated):** Activation via separate governed ADR/config-PR,
human-gated (I-27). NOT activated by this ack. Q2 activation lands via an ADR extending
ADR-162 / ADR-164 for Level 0/1/2 lexicographic aggregation, plus a governed-config PR
against `governance/novelty-pipeline-config.yaml` carrying the α threshold, MAUT weights,
and any Level-boundary numerics as governed-config *proposals* per CLAUDE.md §10.

---

### Q3 — Canonicity criterion A + B (functional origin + traceability lineage)

**Question ratified:** Do we ratify the joint canonicity criterion for the BANXE decision fabric —
**Criterion A** (functional origin: derives from BANXE-specific context — architectural rule,
business rule, or ratified ADR) **and Criterion B** (traceability lineage: unambiguous provenance
back to a BANXE decision artefact or SSOT)?

**Consequence recorded (not ratified here):** **ASSIGNATION-of-EACH.-1-4** is an **external legal
instrument** — outside the scope of this directive. It is retained as a **reference source** and
is **NOT canonical** to the BANXE decision fabric. The concept-v7/v8/v9 backlog is treated as a
scope-level mislabel and belongs to a separate `concept-consolidation` audit (own ADR / IL
sprint), not this fabric.

- [x] APPROVE — Criterion A + B endorsed; ASSIGNATION stays external (reference-only).
- [ ] AMEND — endorse with amendments (record below).
- [ ] REJECT — do not adopt Criterion A + B as canonicity test.

Amendments / notes:

```
(operator/Central)
```

**Operator ack:** RATIFIED by: Operator (Moriel Carmi), 2026-07-07, chat-authorized "я всё одобряю". Central co-sign: PENDING.  
**Central ack:** PENDING — Central co-sign required to move Q3 to CLOSED.

**Next action (activation, human-gated):** Activation via separate governed ADR/config-PR,
human-gated (I-27). NOT activated by this ack. Q3 activation records the canonicity
criterion (A + B) in a dedicated ADR (or as an amendment to ADR-102/ADR-162/ADR-164 as
scope dictates). ASSIGNATION-of-EACH-1..4 stays external / reference-only; the
concept-v7/v8/v9 backlog is deferred to a separate `concept-consolidation` audit ADR + IL
sprint — not this fabric.

---

### Q4 — Two-stage triage of the 88 findings + FCR ≥ 0.80 override

**Question ratified:** Do we ratify the two-stage triage architecture for the 88 findings —
(1) hard-gate (EMI scope, sanctions surface, I-27 invariant checks), (2) dedup-by-need,
(3) score-triage on survivors using metric family **HGC / FCR / AC / CGR** with decision bands
(ADOPT ≥ 0.60, DEFER 0.30 ≤ score < 0.60, REJECT < 0.30) and a **lexicographic
FCR ≥ 0.80 override** promoting to ADOPT irrespective of composite score, followed by a
10–15 sample calibration before any live use?

**Scope reminder:** ARCHITECTURAL DIRECTION only. **All numeric parameters** (weights, band
thresholds, FCR override threshold, sample size) are governed-config *proposals* per CLAUDE.md §10
and require a **separate governed-config PR** against `governance/novelty-pipeline-config.yaml`
(or equivalent) before any live use. The calibration run itself must be human-gated.

- [x] APPROVE — direction endorsed; open governed-config PR + calibration IL.
- [ ] AMEND — direction endorsed with amendments (record below).
- [ ] REJECT — do not adopt the two-stage triage; keep current triage.

Amendments / notes:

```
(operator/Central)
```

**Operator ack:** RATIFIED by: Operator (Moriel Carmi), 2026-07-07, chat-authorized "я всё одобряю". Central co-sign: PENDING.  
**Central ack:** PENDING — Central co-sign required to move Q4 to CLOSED.

**Next action (activation, human-gated):** Activation via separate governed ADR/config-PR,
human-gated (I-27). NOT activated by this ack. Q4 activation opens the adoption-audit of
the 88 findings under the ratified two-stage triage (hard-gate → dedup-by-need →
score-triage on HGC/FCR/AC/CGR with bands ADOPT ≥ 0.60 / DEFER / REJECT, plus the
lexicographic FCR ≥ 0.80 override), plus a governed-config PR against
`governance/novelty-pipeline-config.yaml` carrying weights, band thresholds, FCR override
threshold, and calibration sample size as governed-config *proposals* per CLAUDE.md §10.
The 10–15 sample calibration run is itself human-gated.

---

### Q5 — Sequencing: merge-queue serialize (NOW) → index-decouple (MEDIUM) → commit-index redesign (tracked debt)

**Question ratified:** Do we ratify the three-workstream sequencing — **NOW** merge-queue serialize
(end concurrent-merge race; single ordering), **MEDIUM** index-decouple (index becomes a derived
CI artefact rebuilt on `main`, not a source-of-truth committed by branches), **TRACKED DEBT**
commit-index redesign via its own separate ADR + IL, with the "quiet-window" strategy retained
**only** as emergency fallback?

**Scope reminder:** ARCHITECTURAL DIRECTION only. Each workstream lands via its own IL / ADR:
merge-queue-serialize IL for NOW; index-decouple IL for MEDIUM; a dedicated ADR for the tracked
commit-index redesign debt. Nothing is armed by this checkbox.

- [x] APPROVE — direction endorsed; open merge-queue-serialize IL + follow-ons per horizon.
- [ ] AMEND — direction endorsed with amendments (record below).
- [ ] REJECT — do not adopt this sequencing.

Amendments / notes:

```
(operator/Central)
```

**Operator ack:** RATIFIED by: Operator (Moriel Carmi), 2026-07-07, chat-authorized "я всё одобряю". Central co-sign: PENDING.  
**Central ack:** PENDING — Central co-sign required to move Q5 to CLOSED.

**Next action (activation, human-gated):** Activation via separate governed ADR/config-PR,
human-gated (I-27). NOT activated by this ack. Q5 activation opens the **NOW**
merge-queue-serialize IL (end concurrent-merge race; single ordering) and records the
**MEDIUM** index-decouple IL (index becomes a derived CI artefact rebuilt on `main`, not
a source-of-truth committed by branches) and the **TRACKED DEBT** commit-index redesign
ADR as its own separate debt-item. The "quiet-window" strategy is retained ONLY as
emergency fallback.

---

## Closure protocol

1. On APPROVE / AMEND of a Q, open the corresponding **follow-on ADR** (Q1, Q2 extend ADR-162 /
   ADR-164; Q3 records the canonicity criterion; Q5 opens the merge-queue-serialize IL and
   subsequent horizon artefacts) **and**, where applicable, the governed-config PR against
   `governance/novelty-pipeline-config.yaml` (Q2 numeric parameters; Q4 triage weights, bands,
   FCR override, calibration sample size).
2. On REJECT of a Q, record rationale in the "Amendments / notes" block; no follow-on artefact is
   opened for that Q.
3. This directive moves to `status: CLOSED` **only** when every Q has an ack line filled by
   **both** operator and Central. Partial ratification leaves the directive OPEN with the ratified
   Qs annotated inline.
4. Until CLOSED, the Best-Decision method stays **ADVISORY / PROPOSED** and the current single-stage
   flow remains in force.

## Anchors

- `docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md` — the synthesis under ratification (PR #1091).
- `docs/sources/consultant-response-best-decision-2026-07-07.md` — Perplexity SSOT (verbatim, zero-loss).
- `docs/adr/ADR-162-best-decision-principle.md`, `docs/adr/ADR-164-best-decision-agent-method.md` — Best-Decision canon extended by Q1 / Q2 activation ADRs.
- `docs/canon/BEST-DECISION-BOUNDARY.md` — I-27 anchor + variant-2.
- `CLAUDE.md §10` — Configuration-over-Hardcoding (numbers = governed-config proposal).
- ADR-102 — pointer-first, no source restate (this directive adheres).

## Ratification-ack log (append-only)

### Operator ratification — 2026-07-07 (specproj sp40)

- **Actor:** Operator (Moriel Carmi).
- **Channel:** Terminal-B chat, verbatim "я всё одобряю" (chat-authorized).
- **Verdicts:** Q1 APPROVE, Q2 APPROVE, Q3 APPROVE, Q4 APPROVE, Q5 APPROVE (5/5).
- **Status transition:** `OPEN → RATIFIED-OPERATOR` (Central co-sign PENDING; moves to
  `CLOSED` only when Central ack lines are filled per Closure protocol §3).
- **Activation:** DEFERRED per-Q to separate governed ADR/config-PR (see per-Q "Next
  action" blocks). NOTHING activated by this ack.
- **Invariants preserved:** I-27 (no autonomous production-state mutation enabled),
  variant-2 (advisory-only current single-stage flow remains in force), CLAUDE.md §10
  (all numeric parameters remain governed-config *proposals*), ADR-102 (pointer-first, no
  source restate), HITL (no auto-merge armed; each downstream landing human-gated).
- **AML-method note:** the `banxe_aml_orchestrator` Decision Method (PR #1094) remains
  **PROPOSED** and NOT activated. Safe activation is gated on the Q1 Step-0 admissibility
  ADR landing first (per Q1 "Next action").
- **Central co-sign:** PENDING. Fill Central ack lines per-Q above to progress toward
  CLOSED.
