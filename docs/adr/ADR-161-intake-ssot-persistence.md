# ADR-161 — Intake SSOT-persistence (no intake without SSOT-persist)

**Date:** 2026-07-06
**Status:** PROPOSED
**Deciders:** Central (design owner), Terminal-B (Spec-Projects, intake owner), Operator (accept gate)
**Replaces:** N/A
**Superseded by:** N/A
**References:** ADR-159 (§"Terminal-B Operating Algorithm"), ADR-102 (no smart refactor / no restatement), ADR-103 (server-only), ADR-119 (stable IL numbering), ADR-120 (per-session worktree), ADR-121 (destructive-action protection), ADR-153 (terminal topology), ADR-156 (sandbox / operator-gated sign-off), `.claude/rules/parallel-session-isolation.md`, `docs/canon/TERMINAL-B-OPERATING-CANON.md`, `docs/sources/README.md`.

---

## Context

Terminal-B intake ("read incoming text/file → extract findings → append `NOVELTY-COLLECTION-REGISTER.md` row") was **losing the body of the source document**. A short finding row and (optionally) a pointer-doc landed in the repo; the verbatim source did not. The class defect was detected during a best-decision test run: an operator-supplied academic concept "Лучшее Решение" (VNM utility theory, Bellman-MDP, MAUT, AHP, TOPSIS, NSGA-II, Pareto, satisficing, minimax-regret, prospect theory, secretary problem — ~40 sources, 104 footnotes) was fully consumed by intake, yet the concept body existed **nowhere in the repo**. All downstream artefacts (findings, ADRs, coverage-log entries) referenced a source that had no persistent representation. This is a class-B defect — not a one-off omission — because the intake canon (before this ADR) did not require SSOT-persistence.

Consequences of the class defect:

1. **Audit hole.** A row `rationale=...` in the register cannot be cross-checked against the source it summarised.
2. **Fidelity loss.** Academic / regulatory nuance is compressed to bullets; later re-reads work from the compression, not the original.
3. **Reproducibility loss.** A second B-intake session cannot deterministically re-derive the same finding set from the source — because the source is gone.
4. **Cross-repo drift.** `banxe-emi-stack` (or Central) cannot verify that its downstream implementation of a finding matches the concept — because the concept lives in operator memory, not the repo.

The BANXE governance canon (CLAUDE.md §10 Config-over-Hardcoding, §4 no-hallucination) implies persistence-first for verifiable inputs; but this was never made explicit for **the source itself** (only for the finding).

---

## Decision

### D-1 — Introduce `docs/sources/` as the intake SSOT

A new tree `docs/sources/` becomes the canonical, verbatim store for every input document consumed by the Terminal-B intake pipeline (concept notes, academic papers, regulatory circulars, vendor whitepapers, operator briefings). The tree is:

- **Append-only** (I-24) — files are added, never mutated. A corrected source is a new file (`-v2` or new date suffix); the older file is preserved.
- **Verbatim** — bodies are stored as received, without editorial summarisation or reformatting beyond the minimal front-matter header (see `docs/sources/README.md`).
- **Referenced, not restated** — findings, pointer-docs, ADRs, coverage-log entries LINK to `docs/sources/<slug>-<date>.md`; they do not duplicate the body (ADR-102 §"no restatement of canon" applies transitively).
- **Terminal-B–owned** by default (matching the register), amendable via specproj PR under the shard + Redis-mint discipline (ADR-119).

### D-2 — Mandatory Step 0: SSOT-persist BEFORE extraction

The Terminal-B intake algorithm (ADR-159 §"Terminal-B Operating Algorithm", steps 0–7) is amended: **step 0 is renamed and extended** from "AUTOSTART" to "AUTOSTART + SSOT-PERSIST". Before any MULTI-PASS READ (step 1), before any candidate extraction (step 2), and before any duplication audit (step 3), Terminal-B MUST:

1. Compute the source `slug` (kebab-case), the `intake-date` (UTC yyyy-mm-dd), and the final path `docs/sources/<slug>-<intake-date>.md`.
2. Write the source body **verbatim** to that path, with the minimal front-matter header (slug, intake-date, source-type, provenance, sha256).
3. Compute the sha256 of the body (post-header) and pin it in the front-matter.
4. Only then proceed to MULTI-PASS READ / extraction. Every downstream artefact (register row, pointer-doc, ADR, coverage-log entry) MUST include an explicit reference to the SSOT path.

**Rationale for ordering:** placing SSOT-persist AFTER extraction risks the same class defect — the extraction may complete and the persist step be forgotten. Placing it AT step 0, before any interpretive work, makes the SSOT a precondition, not an afterthought.

### D-3 — Retro-fix for previously-lost sources

Sources consumed BEFORE this ADR is accepted, whose bodies are not in `docs/sources/`, are re-persisted retrospectively as they are re-encountered — the same specproj PR that references the source in a finding / ADR SHOULD carry the SSOT file. The "Лучшее Решение" concept is the first such retro-fix, delivered alongside this ADR (see `docs/sources/best-decision-concept-2026-07-06.md`).

A general retro-audit sweep (finding orphaned sources) is **out of scope** for this ADR — it is a follow-up task once the forward rule is in place. This ADR fixes the class defect; the retro-sweep addresses the historical instances.

### D-4 — What is NOT changed by this ADR

- **The finding schema in `NOVELTY-COLLECTION-REGISTER.md`** is unchanged; a new column is not introduced. The SSOT path is referenced in the `rationale` cell of the row (natural text, no schema breakage). If a future ADR wants a first-class column, that is out of scope here.
- **The A-side pipeline** (queue, watcher, semantic scoring, roadmap-hand-off) is untouched. A-side reads the finding, which now transitively references the SSOT via the register row; A does not need to change its interface.
- **CODEOWNERS** — `docs/sources/` inherits the default Terminal-B ownership rule (same as `NOVELTY-COLLECTION-REGISTER.md`). No new CODEOWNERS entry is required in this ADR; if a specialised owner is desired later, that is a follow-up.
- **Runtime agents (I-27)** — this ADR does not grant any runtime autonomy. SSOT-persist is a step in the human-orchestrated intake pipeline, not a runtime auto-adoption.

### D-5 — Enforcement (advisory in this ADR, hardening deferred)

This ADR ships as **PROPOSED** with an **advisory** enforcement stance: the rule is documented in `docs/canon/TERMINAL-B-OPERATING-CANON.md` (step-0 amendment) and in `docs/sources/README.md`, and is expected to be followed by Terminal-B and any factory dispatch operating in a Terminal-B role. Machine enforcement (a pre-commit / CI check that "a specproj PR touching `NOVELTY-COLLECTION-REGISTER.md` must also touch `docs/sources/`, OR carry a `no-source-body` label with operator sign-off") is **out of scope** for this ADR and scheduled as a follow-up task once the advisory rule has been exercised.

Rationale for advisory-first: hard-enforcement without a shakedown period risks blocking legitimate small updates (e.g., typo fix in a register row) with no offsetting safety gain. The class defect is addressed by the rule + retro-fix; the hardening is refinement.

---

## Consequences

**Positive**

- Every future intake preserves the source verbatim → audit-holes closed for the forward corpus.
- Downstream re-reads (Central multi-criteria adoption-audit, A-side semantic scoring, factory implementation) work from the original body, not from a summary.
- The class defect ("intake loses body") is closed at the canon level, not patched instance-by-instance.
- Cross-repo verification (banxe-emi-stack references banxe-architecture SSOT path) becomes deterministic.

**Negative / accepted trade-offs**

- `docs/sources/` grows over time (verbatim bodies of every input). Storage cost is negligible relative to the code / docs corpus; append-only semantics prevent runaway churn.
- Intake becomes slightly slower (one additional step). The step is mechanical (paste + front-matter + sha256) and does not require judgment.
- Retro-fix of historical sources is manual and best-effort — the register today does not carry enough metadata to auto-locate orphaned sources.

**Risks (mitigations noted)**

- **Body-fidelity risk.** An operator could paste a summary instead of the verbatim source. *Mitigation:* the intake log runbook prompts "verbatim body pasted?" as a checklist item; the front-matter `provenance` field records the origin.
- **Duplicate slugs.** Two different sources hashed to the same slug. *Mitigation:* naming rule includes intake-date; same-day duplicates use `-<n>` suffix (`docs/sources/README.md` §Naming).
- **Copyright / privacy.** External sources may have copyright constraints. *Mitigation:* SSOT is INTERNAL to the BANXE repo (per the operator-supplied brief: "source-документы оператора — внутренние, сохранять целиком РАЗРЕШЕНО"). Regulatory / vendor material that carries an external licence must be checked case-by-case; this is a governance judgment, not an automated rule. In doubt → escalate (fail-closed, `safety-rules.md`).

---

## Anchors

- ADR-159 §"Terminal-B Operating Algorithm" — the intake algorithm this ADR amends (step 0 extension).
- ADR-102 — no restatement of canon; SSOT is stored once, referenced everywhere else.
- ADR-119 / ADR-060 — the specproj PR discipline used to write SSOT files (shard + Redis-mint).
- ADR-120 / ADR-121 / `.claude/rules/parallel-session-isolation.md` — worktree isolation and destructive-action protection apply to SSOT files.
- ADR-156 — sandbox / operator-gated sign-off; SSOT files are staged in PR and merged via HITL.
- `docs/canon/TERMINAL-B-OPERATING-CANON.md` §"Intake step-0 SSOT-persist" (amendment shipped in the same PR as this ADR).
- `docs/sources/README.md` — the operational rules for `docs/sources/`.
- `docs/canon/BEST-DECISION-BOUNDARY.md` and `docs/adr/ADR-162-best-decision-principle.md` — sibling canon that operationalises the retro-fixed concept and references the SSOT.
