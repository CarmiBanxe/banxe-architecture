---
title: "Best-Decision Consultant Convergence — Ratification Synthesis (Q1–Q5)"
status: PROPOSED
classification: derived decision artefact (pointer-first per ADR-102)
intake_date: 2026-07-07
authors: Terminal-B (specproj sp38), synthesising two independent rulings
ratification: pending operator + Central
related:
  - "Escalation #1084 (Consultant Escalation & Best-Decision Consultation Protocol)"
  - "docs/sources/consultant-response-best-decision-2026-07-07.md (Perplexity Governance/Safety, SSOT)"
  - "docs/sources/consultant-escalation-protocol-2026-07-07.md"
  - "docs/adr/ADR-162-best-decision-principle.md"
  - "docs/adr/ADR-163-sync-canon.md"
  - "docs/adr/ADR-164-best-decision-agent-method.md"
  - "docs/design/BEST-DECISION-AGENT.md (PR #1080)"
  - "docs/canon/BEST-DECISION-BOUNDARY.md"
  - "docs/sources/best-decision-concept-2026-07-06-v2.md"
  - "docs/sources/best-decision-self-learning-loop-2026-07-07.md"
invariants: I-27 preserved (numbers = governed-config-proposal, human-gate); variant-2 preserved
---

# Best-Decision Consultant Convergence — Ratification Synthesis (Q1–Q5)

> **Status: PROPOSED — ratification pending operator + Central.** This is a *derived decision artefact*
> (ADR-102: pointer-first, no source restate). Two independent rulings on Escalation #1084 — the
> **Central inline ruling** (see docs/design/BEST-DECISION-AGENT.md and ADR-162/163/164) and the
> **Perplexity Governance/Safety ruling** archived at
> `docs/sources/consultant-response-best-decision-2026-07-07.md` — **converge on all five questions**.
> That convergence is what this file consolidates for a single ratification pass; the underlying
> reasoning stays in the sources.

## Convergence header

- Both rulings were issued **independently** and arrive at the same architectural choice on Q1–Q5.
- **High ratification confidence** (2/2 independent-source agreement). Divergences, if any surface
  in ratification review, are captured in the "Open items" section below and demoted to follow-on
  ADRs — they do **not** block acceptance of the consolidated verdict below.
- **Nothing here activates a threshold, weight, or gate.** All numeric parameters are
  **governed-config *proposals*** (Config-over-Hardcoding, CLAUDE.md §10) and only reach production
  through a human-gated PR touching `governance/novelty-pipeline-config.yaml` (or equivalent). I-27
  is preserved throughout.

## Consolidated verdicts

### Q1 — Deterministic admissibility gate BEFORE scoring

**Consolidated verdict.** Introduce a **Step 0 deterministic admissibility DAG** — static,
human-authored, append-only — that runs **before** any score is computed. Execution-class alone is
**necessary but not sufficient**: hard-admissibility is a **separate first stage**, then Step 1
executes score/execution-class, then Step 2 is the existing human-gate.

- **Legal grounding (from Perplexity SSOT):** CJEU *SCHUFA* (C-634/21, 2023), GDPR Art. 22
  (automated individual decision-making), EU AI Act Art. 6(3) (high-risk classification). See
  `docs/sources/consultant-response-best-decision-2026-07-07.md`.
- **Pipeline shape:**
  `Step0 admissibility-DAG (hard-gate {0,1}) → Step1 score + execution-class → Step2 human-gate`.
- **Operational rule:** any candidate that fails Step 0 is **rejected before scoring**; scoring
  is not a tie-breaker on inadmissible candidates.

### Q2 — Lexicographic architecture, NOT linear sum for high-risk

**Consolidated verdict.** For high-risk decisions the aggregation is **lexicographic**, not a
weighted linear sum:

- **Level 0** — hard admissibility `{0,1}` (Step 0 above).
- **Level 1** — **risk-satisfice**: prefer any candidate with risk `R < α`; if none satisfy, take
  `argmin R`.
- **Level 2** — **additive MAUT over admissible candidates**, with **R excluded from the additive
  layer** (already handled at Level 1).

- **Method anchors (from Perplexity SSOT):** LSF / LexiSafe / IJCAI-family lexicographic
  safety, plus **FCA PRA SS1/23** model validation (proportional evidence, decision-theoretic
  robustness). See archived body.
- **Weights** for Level 2 stay a **governed-config proposal** — no live weight is set here.

### Q3 — Scope ownership: BANXE canonicity vs. external legal, and the concept-v7..v9 backlog

**Consolidated verdict.** **Scope-owner decision** rests with **operator + Central**. The
canonicity criterion is joint:

- **Criterion A — functional origin:** the artefact must derive from BANXE-specific context —
  architectural rule, business rule, or a ratified ADR. External legal templates fail A.
- **Criterion B — traceability lineage:** unambiguous provenance back to a BANXE decision
  artefact or SSOT.

Consequences:

- **ASSIGNATION-of-EACH.-1-4** — external legal instrument. **NOT canonical** to the BANXE
  decision fabric; retained as a **reference source**, never activated as canon.
- **concept-v7 / v8 / v9 backlog** — treated as **mislabel** at scope level; belongs to a
  **separate `concept-consolidation` audit** (own ADR / IL sprint), not the Best-Decision fabric.

### Q4 — Two-stage triage of the 88 findings

**Consolidated verdict.** Adopt a **two-stage triage**:

1. **Hard-gate** — EMI scope, sanctions surface, and I-27 invariant checks. Findings that fail the
   hard-gate are rejected regardless of downstream score.
2. **Dedup-by-need** — collapse duplicates that reduce to the same operational need.
3. **Score-triage** on the survivors, using metric family **HGC / FCR / AC / CGR** (weights =
   governed-config *proposal*) with the following **decision-gate proposal**:
   - **ADOPT** ≥ 0.60
   - **DEFER** 0.30 ≤ score < 0.60
   - **REJECT** < 0.30
   - **Lexicographic override — FCR ≥ 0.80** promotes to ADOPT irrespective of composite score
     (single-dimension safety dominance).
4. **Calibration** — run against a **10–15 sample** with human-validation before any live use.

All numbers above are **proposals** (I-27 preserved).

### Q5 — Sequencing: merge-queue serialize, index-decouple, commit-index redesign

**Consolidated verdict.** Three concurrent workstreams with staggered horizons:

- **NOW (auto):** **merge-queue serialize** — end concurrent-merge race; single ordering.
- **MEDIUM:** **index-decouple** — the index becomes a **derived CI artefact** (rebuild on
  `main`), not a source-of-truth committed by branches.
- **TRACKED DEBT (separate ADR):** **commit-index redesign** — full redesign lands via its own
  ADR + IL, not folded into this synthesis.
- **Emergency-fallback only:** the "quiet-window" strategy (no-concurrent-activity release) is
  retained **solely as fallback** if merge-queue serialize fails; not the primary posture.

## Footer — invariants, boundaries, ratification pathway

- **Numbers policy.** All thresholds/weights/gates named above (`α`, ADOPT/DEFER/REJECT bands,
  FCR override, HGC/FCR/AC/CGR weights, `10–15 sample`, and the Q2 lexicographic ordering
  parameters) are **governed-config *proposals*** per **CLAUDE.md §10** (Config-over-Hardcoding).
  Adoption requires a human-gated PR against `governance/novelty-pipeline-config.yaml`
  (or the equivalent config file). **This synthesis does not activate them.**
- **Invariants preserved.** **I-27** (no autonomous production-state mutation) is preserved end-to-end.
  **Variant-2** ("advisory-only until ratified") is preserved: this file is advisory until
  operator + Central ratify.
- **Ratification pathway.** Consolidated verdicts above are **PROPOSED**. Ratification is the joint
  responsibility of **operator + Central**. On ratification, follow-on artefacts are:
  1. An ADR that binds the Step 0 admissibility DAG (Q1) and the lexicographic Level 0–2 model (Q2)
     into the Best-Decision method (extension of ADR-162 / ADR-164).
  2. A governed-config PR that lands the numeric proposals for Q4 triage on
     `governance/novelty-pipeline-config.yaml` (or equivalent).
  3. A merge-queue serialize IL for Q5 (NOW), an index-decouple IL (MEDIUM), and a separate ADR
     for commit-index redesign (tracked debt).
- **Open item.** Activation of Step 0 (admissibility DAG) and Level 0/1/2 (lexicographic
  aggregation) requires a **human-ratified ADR** — nothing here activates them. Until ratified,
  the current single-stage flow remains in force.

## Cross-references

- `docs/sources/consultant-response-best-decision-2026-07-07.md` — Perplexity Governance/Safety
  ruling (SSOT, verbatim, zero-loss).
- `docs/sources/consultant-escalation-protocol-2026-07-07.md` — escalation & consultation
  protocol (in-session factory authoring).
- `docs/adr/ADR-162-best-decision-principle.md`, `docs/adr/ADR-163-sync-canon.md`,
  `docs/adr/ADR-164-best-decision-agent-method.md` — Best-Decision canon.
- `docs/design/BEST-DECISION-AGENT.md` — per-agent advisory method (PR #1080).
- `docs/canon/BEST-DECISION-BOUNDARY.md` — Best-Decision boundary (I-27 anchor).
- `.claude/rules/agents.md` (BUG-007) — HITL confidence tiers.
- ADR-102 — no restate / pointer-first duplication canon (this file adheres).
- ADR-161 — SSOT intake persistence policy (source archive companion to this synthesis).
