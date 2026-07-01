# Harness Integration Assessment — factual state record

> **Status:** governance assessment (fact record). **Date:** 2026-07-02. **Owner-terminal: A (factory).**
> **Pointer-first and additive (ADR-102).**
>
> This document is a **read-only-derived fixation of fact**: it records the current gap between the **documented**
> skills/tooling governance and what is **actually installed in the Claude Code harness**, as observed by a
> harness-integration audit. **It is a record, not an action.** It **installs nothing**, **converts nothing**,
> **touches no `.claude/skills`**, and **does not touch the ADR-117 perimeter**. It restates none of the canon
> it references — it points to it. Every adoption/conversion decision it surfaces **AWAITS OPERATOR**.

---

## 0. Method & scope
State observed via a **read-only** harness-integration audit (skill-directory enumeration, `SKILL.md` presence
grep, harness/tooling reference grep, `command -v` install probes). This assessment fixes those observations
as canon; it makes no change to skills, tools, or the perimeter. **Noise excluded:** the many repo `sandbox`
references are overwhelmingly the unrelated trading-DSE `sandbox-mock` work (IL-210…IL-228) and are **not**
harness state.

## 1. Skills = governance, NOT harness-installed
- **`.claude/skills/**/SKILL.md` (the current invokable Claude Code skill format): ZERO found.** No skill is
  installed in the harness-invokable `<name>/SKILL.md` form.
- **A governance/policy layer exists — but it is procedures, not invokable plugins:**
  `docs/SKILLS-MATRIX.md`, `docs/SKILLS-OPERATING-MODEL.md`, `docs/SKILLS-ORCHESTRATION.md` (the "10 project
  skills", planes, and A–J orchestration sequences from IL-042 / IL-044). These describe **operational
  procedures Claude Code should follow** — with the **hard rule that no skill bypasses `quality-gate.sh` or
  invariants I-01..I-28**, a fixed priority order (`FCA > I-01..I-28 > ADRs > quality-gate.sh > IL > Skill
  MANDATORY > Skill ADVISORY`), and passport-level `allowed_skills` permissions. They are **policy, not
  harness-installed skills**.
- **Three legacy flat files exist in the old format:** `.claude/skills/github-navigation.md`,
  `.claude/skills/spec-writing.md`, `.claude/skills/testing.md` — flat `.md`, **not** the current
  `<name>/SKILL.md` subdirectory structure, therefore **not harness-invokable** as skills.
- **Consequence (fact, not recommendation):** the documented "skills layer" is a **governance/procedure layer
  consumed by convention**, not a set of harness-registered invokable skills. Whether to converge the two is an
  operator decision (§3), not asserted here.

## 2. Tooling / local install readiness
Observed via `command -v` (install-presence only; no version/behaviour claim):
- **`claude` — present** (the CLI harness itself is installed).
- **`hb` — absent.**
- **`hyperbrowser` — absent.** No browser-automation harness tool is installed.

The factory canon itself (left-terminal / Best-Single-Artifact / Duplication-Audit / ADR-117 perimeter) is
documented and CI-enforced (guardian-factory, ADR-060 branch-namespace gate, ADR-132 traceability) — that is
**present and healthy**; the gap is specifically in **harness-registered skills and external tooling**, not in
the governance canon.

## 3. Decisions that AWAIT OPERATOR (surfaced, NOT taken here)
This record **does not decide, adopt, convert, or install** any of the following. Each is governance-gated and
operator/infra-owned:
- **Skill-format convergence** — converting the three legacy flat files (and/or scoping the 10 matrix
  procedures) into `.claude/skills/<name>/SKILL.md` invokable form. Factory-authorable **if authorized** as a
  separate task; not done here (this record does not touch `.claude/skills`).
- **External-tool adoption (e.g. Hyperbrowser)** — an **external component**, so adoption is gated by
  **CLAUDE.md §9** (rules-based + mandatory human-in-the-loop) and **ADR-135** (agent-skill evolution gate),
  and touches the **ADR-117 perimeter** and the security canon (browser automation is dual-use). The *install*
  is **operator / Terminal-A infra**, not a factory action; only a *governance adopt-vs-defer decision* would
  be factory-authorable, and only **if authorized** — not taken here.

## 4. What this document did NOT do
No skill installed. No skill converted. `.claude/skills` **not touched**. No tool installed (`hb` /
`hyperbrowser` remain absent by observation, not by this doc's action). ADR-117 perimeter **not touched**. No
adoption/evolution-gate decision taken. This is a **fact record**, prepare-only, authored governance-side.

## Anchors
`docs/SKILLS-MATRIX.md` · `docs/SKILLS-OPERATING-MODEL.md` · `docs/SKILLS-ORCHESTRATION.md` (IL-042 / IL-044 —
the skills governance layer this record surfaces) · `.claude/rules/agents.md` §"SKILLS GOVERNANCE" /
§"SKILLS ORCHESTRATION RULES" (hard rules, priority order) · `docs/adr/ADR-135-agent-skill-evolution-gate.md`
(external-skill/tool evolution gate) · ADR-117 (regulated perimeter — external-tool install is
operator/infra-gated) · CLAUDE.md §9 (external-component adoption = rules-based + human-in-the-loop) · ADR-102
(Duplication Audit — this restates none of the above). **Basis:** harness-integration audit (read-only),
2026-07-02. Operator directive 2026-07-02 (document the harness state as a canonical assessment; fact record
only — no install, no conversion, no perimeter touch).
