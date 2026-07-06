# SP25 — Intake SSOT-persist fix log

**Date (UTC):** 2026-07-06T03:53:18Z
**Sprint:** sp25
**Branch:** `agent/specproj/sp25/intake-ssot-persist-fix`
**Author (agent):** Terminal-B (Spec-Projects), factory dispatch on evo1
**Scope:** class-defect fix — B-intake was losing the source body.

---

## What was persisted (retro-fix)

Per ADR-161 §D-3, the "Лучшее Решение" concept — consumed by intake earlier without a SSOT-persist
step — was retro-saved into the new `docs/sources/` tree as canonical SSOT.

| Field | Value |
|-------|-------|
| SSOT file | `docs/sources/best-decision-concept-2026-07-06.md` |
| Slug | `best-decision-concept` |
| Intake-date (UTC) | 2026-07-06 |
| Source-type | concept |
| Provenance | operator-supplied academic concept paper on "Лучшее Решение" |
| Size (bytes) | 26 306 |
| Lines | 278 |
| SHA-256 (body incl. front-matter) | `38a34d39c20476356af4b42bd8880b130ebccb9cde75480c3c86cacd2902da21` |
| Formal source citations | 40 (numbered §17) |
| Concept-footnote compress | 10 clusters covering ~104 originals (§18) |
| Methods covered | VNM/EU, Bellman-MDP, POMDP, MAUT, AHP, TOPSIS, PROMETHEE, ELECTRE, Pareto, NSGA-II, NSGA-III, MOEA/D, maximin, maximax, Hurwicz-α, Laplace, minimax-regret, satisficing, secretary problem, Prospect Theory / CPT, ambiguity-aversion (Gilboa–Schmeidler, α-maxmin), real options (defer / expand / abandon), VoI, entropy / SWING / ROC weighting, Arrow, Borda, Condorcet, robust ranking |

**Verification:** downstream artefacts (BEST-DECISION-BOUNDARY.md, ADR-162, test cases) reference
the SSOT path; body is not restated (ADR-102).

---

## What was created

| Artefact | Path | Status | Notes |
|----------|------|--------|-------|
| SSOT tree README | `docs/sources/README.md` | new | operational rules (naming, front-matter, append-only). |
| Retro-saved concept | `docs/sources/best-decision-concept-2026-07-06.md` | new | canonical body of the concept as understood at intake. |
| ADR-161 | `docs/adr/ADR-161-intake-ssot-persistence.md` | PROPOSED | class-defect fix; mandatory step-0 persist. |
| TERMINAL-B canon amend | `docs/canon/TERMINAL-B-OPERATING-CANON.md` §9 | edit | pointer-only amendment to step-0 (ADR-102). |
| BEST-DECISION-BOUNDARY canon | `docs/canon/BEST-DECISION-BOUNDARY.md` | new | operational canon for the gate; references SSOT + ADR-159. |
| ADR-162 | `docs/adr/ADR-162-best-decision-principle.md` | PROPOSED | formal ADR for the best-decision adoption-audit gate. |
| Coordination directive tracker | `governance/COORDINATION-NOTES.md` | new | tracks OPEN directive B-BESTDEC-SCOPE-001 (operator-owned ratification). |
| Test cases | `tests/best-decision/case-{a,b,c,d}-*.yaml` | new | 4 canonical cases (accept, reject, blocked, defer). |
| Validator | `tests/best-decision/validator.py` | new | deterministic reference evaluator; PyYAML-only stdlib+yaml. |
| Test README | `tests/best-decision/README.md` | new | run instructions + cross-refs. |

---

## Verification

- **Validator run:** `python3 tests/best-decision/validator.py` → exit 0; 4/4 passed
  (CASE-A accept, CASE-B reject-as-not-worth, CASE-C blocked-out-of-scope, CASE-D defer).
- **Semgrep:** `semgrep --error --config auto --no-git-ignore --timeout 60 <new files>` →
  0 findings.
- **SSOT persistence:** `docs/sources/best-decision-concept-2026-07-06.md` present, non-empty,
  front-matter parses.

---

## Invariants preserved (no runtime autonomy)

- **I-27 fail-closed** preserved. Runtime L2+ agents remain fail-closed per
  `.claude/rules/agents.md` §"HITL Confidence Thresholds" (BUG-007). This PR grants **no** runtime
  autonomy.
- **DIRECTIVE B-BESTDEC-SCOPE-001** is opened as OPEN, ack-required=operator, default=fail-closed
  (в-1). Ratification of (в-2) is deferred to the operator; even under (в-2) the runtime posture
  stays HITL-bounded (no autonomy).
- **CLAUDE.md §71** HITL merge preserved; no auto-merge introduced.
- **ADR-102** — SSOT is stored once (in `docs/sources/`), referenced elsewhere; no restatement.
- **ADR-119** ledger discipline followed — shard-only add via `scripts/add-il-shard.sh`; branch
  name matches ADR-060 pattern `agent/specproj/sp25/intake-ssot-persist-fix`.

---

## Cross-refs

- ADR-159 (pipeline; step-0 amendment lands here)
- ADR-161 (intake SSOT-persistence)
- ADR-162 (best-decision adoption-audit gate)
- `docs/canon/BEST-DECISION-BOUNDARY.md`
- `docs/canon/TERMINAL-B-OPERATING-CANON.md` §9
- `docs/sources/README.md` + `docs/sources/best-decision-concept-2026-07-06.md`
- `governance/COORDINATION-NOTES.md`
- `tests/best-decision/`
