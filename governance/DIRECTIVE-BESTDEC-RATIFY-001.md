---
directive_id: DIRECTIVE-BESTDEC-RATIFY-001
title: "Ratification checklist — Best-Decision Q1–Q5 consultant convergence (operator + Central ack)"
status: OPEN
classification: governance directive (pointer-first per ADR-102)
issued: 2026-07-07
issuer: Terminal-B (specproj sp39; prepare-only)
ack_required: [operator, central]
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

> **STATUS: OPEN — ack-required from operator + Central.**
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

- [ ] APPROVE — direction endorsed; open follow-on ADR to activate Step 0.
- [ ] AMEND — direction endorsed with amendments (record below).
- [ ] REJECT — do not adopt Step 0 admissibility-gate; keep current single-stage flow.

Amendments / notes:

```
(operator/Central)
```

**Operator ack:** __________________________  date: __________  
**Central ack:** __________________________  date: __________

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

- [ ] APPROVE — direction endorsed; open follow-on ADR + governed-config PR to activate Level 0/1/2.
- [ ] AMEND — direction endorsed with amendments (record below).
- [ ] REJECT — do not adopt lexicographic aggregation; keep current aggregation.

Amendments / notes:

```
(operator/Central)
```

**Operator ack:** __________________________  date: __________  
**Central ack:** __________________________  date: __________

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

- [ ] APPROVE — Criterion A + B endorsed; ASSIGNATION stays external (reference-only).
- [ ] AMEND — endorse with amendments (record below).
- [ ] REJECT — do not adopt Criterion A + B as canonicity test.

Amendments / notes:

```
(operator/Central)
```

**Operator ack:** __________________________  date: __________  
**Central ack:** __________________________  date: __________

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

- [ ] APPROVE — direction endorsed; open governed-config PR + calibration IL.
- [ ] AMEND — direction endorsed with amendments (record below).
- [ ] REJECT — do not adopt the two-stage triage; keep current triage.

Amendments / notes:

```
(operator/Central)
```

**Operator ack:** __________________________  date: __________  
**Central ack:** __________________________  date: __________

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

- [ ] APPROVE — direction endorsed; open merge-queue-serialize IL + follow-ons per horizon.
- [ ] AMEND — direction endorsed with amendments (record below).
- [ ] REJECT — do not adopt this sequencing.

Amendments / notes:

```
(operator/Central)
```

**Operator ack:** __________________________  date: __________  
**Central ack:** __________________________  date: __________

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
