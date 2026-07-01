# Evaluation: Hyperbrowser CLI + `/harness` self-correcting plugin — adopt-vs-defer

> **Status:** governance **decision-doc** (evaluation under the ADR-135 evolution gate). **Date:** 2026-07-02.
> **Owner-terminal: A (factory).** **Pointer-first and additive (ADR-102).**
>
> **This document is a DECISION, not an installation.** It installs **zero**, downloads **zero**, creates no
> `.claude/skills/harness`, fetches no external `SKILL.md`, and **does not touch the ADR-117 perimeter or any
> tool**. It evaluates adoption of an external component under **ADR-135** (agent-skill evolution gate) +
> **CLAUDE.md §9** (external-component adoption = rules-based + mandatory human-in-the-loop) + **ADR-117**
> (regulated perimeter). It continues `HARNESS-INTEGRATION-ASSESSMENT.md` (#948, IL-796), which flagged this
> item **AWAITS-OPERATOR**. The **final adopt/defer is the operator's decision** — this doc recommends but does
> not decide it (§5), and does not fabricate it.

---

## 1. What is being evaluated
- **Hyperbrowser CLI** — an external browser-automation tool (`hb` / `hyperbrowser`, both **absent** on this
  host per #948).
- **`/harness`** — a Claude Code plugin implementing a **self-correcting harness**: the agent records its own
  failures (wrong paths, missing scripts, incorrect assumptions about repo structure) and **auto-assembles a
  `CLAUDE.md`** so the agent does not repeat the same mistakes.
- **Source of the `SKILL.md`:** an **external repository**, `github.com/hyperbrowserai/examples` — i.e. a
  third-party `SKILL.md` that would be placed into the harness.

## 2. Value (stated honestly, not inflated)
The self-correcting-harness pattern is **genuinely close to what the factory already does by hand**: the
corrective runbook (#900) was authored precisely because an autonomous terminal repeated the same class of
mistakes (hand-editing the generated ledger, hardcoding IL numbers), and lessons have been fixed manually into
canon throughout this programme. **Automating lesson-capture is a real, non-trivial benefit** — a mechanism
that records "this path was wrong / this script is missing / this assumption was false" and surfaces it to
future runs would reduce exactly the failure modes the factory keeps correcting reactively. The value is real;
it is the **delivery mechanism** (external tool + third-party code + auto-`CLAUDE.md`) that carries the risk.

## 3. Risks (assessed, not minimised)
- **Dual-use (security canon + ADR-117 perimeter).** Hyperbrowser is **browser automation** — it can reach
  external services and data. That crosses the security canon and the ADR-117 regulated perimeter (Factory is
  software-delivery-only; project data is separated). A browser-automation capability inside the harness is a
  new externally-facing surface that must be assessed as such.
- **Untrusted external code.** Pulling a third-party `SKILL.md` from an external repo is **execution of
  outside code in the harness without review** — a skill is instructions the agent follows; a blind download
  installs unreviewed behaviour into the trust boundary.
- **Auto-`CLAUDE.md` mutation.** `/harness` **auto-writes `CLAUDE.md`**. This conflicts directly with two
  canons: **Config-over-Hardcoding** (CLAUDE.md §10 — governance parameters live in config, authored, not
  machine-generated) and the standing treatment of **`CLAUDE.md` as governance, not an auto-generated
  artifact**. The concrete risk is an autogenerator **overwriting operator-authored rules** in a canonical,
  code-owner-protected file (`.github/CODEOWNERS` guards `/.claude/` and repo governance).
- **Supply-chain.** An external binary **plus** a plugin **plus** a third-party skill = a **new attack
  surface** (binary provenance, plugin update channel, skill drift) added to a regulated (FCA/EMI) governance
  repo.

## 4. Guardrails (REQUIRED if the operator ever decides to adopt — not enacted here)
These are conditions on a *possible future* adoption; **none is applied by this document**:
- **Install is operator / Terminal-A only, under the gate** — never a factory action. The factory does not
  install binaries or plugins.
- **External `SKILL.md` is reviewed before it enters `.claude/skills`** — no blind download; the third-party
  skill passes human review (and the `@mmber` code-owner) exactly like any governance change.
- **`/harness` MUST NOT auto-mutate the canonical `CLAUDE.md`.** Its output goes to a **separate, non-canon
  file under operator review**; **no auto-commit into governance**. Lesson-capture may *propose*; the operator
  *ratifies* — matching the prepare-only / HITL discipline used throughout.
- **Sandbox / read-only where possible; egress restrictions; never on live/customer data** (ADR-117
  separation; security canon).
- **Passes the same gates as any skill** — `quality-gate.sh`, invariants I-01..I-28, and the ADR-135 evolution
  gate; no skip flags.

## 5. Recommendation — **DEFER (default), final decision AWAITS-OPERATOR**
**Recommendation: DEFER adoption**, on the honest balance of §2 vs §3 — the value is real but the delivery
mechanism carries unaccepted dual-use, untrusted-code, auto-mutation, and supply-chain risk. Specifically,
**defer until all three preconditions hold:**
1. the **external `SKILL.md` is reviewed** (not blind-downloaded);
2. the **auto-`CLAUDE.md`-mutation is constrained by guardrail** (output to a non-canon file, operator
   ratifies — never auto-commit into canonical governance);
3. the **dual-use / perimeter risk is explicitly accepted by the operator** (ADR-117 + security canon).

Until (1)–(3) are satisfied, DEFER is the safe default. **This is a recommendation, not the decision:** the
**final adopt/defer is `AWAITS-OPERATOR`** — the operator's explicit choice under CLAUDE.md §9 human-in-the-loop
and the ADR-135 gate. This document does not fabricate that decision.

**Note on the value without the risk:** the lesson-capture benefit (§2) can be pursued **independently of
Hyperbrowser** — the factory already captures lessons into canon manually (#900), and a *factory-native*
lesson-capture-to-non-canon-file mechanism (proposing, operator-ratifying) would deliver much of the value with
none of the external-code/dual-use/auto-mutation risk. That is a separate, factory-authorable option if the
operator prefers it over the external tool. **`[НЕИЗВЕСТНО]` / AWAITS-OPERATOR:** whether the operator wants
(a) external Hyperbrowser adoption under the §4 guardrails, (b) a factory-native lesson-capture alternative, or
(c) neither — not decided here.

## 6. What this document did NOT do
Installed nothing (`hb`/`hyperbrowser` remain absent by observation, not by this doc). Downloaded no external
`SKILL.md`. Created no `.claude/skills/harness`. Touched no `.claude/skills`, no tool, and no ADR-117 perimeter.
Took no adopt/defer decision — that remains **AWAITS-OPERATOR**. This is a **governance decision-doc**,
prepare-only, authored governance-side.

## Anchors
`docs/governance/HARNESS-INTEGRATION-ASSESSMENT.md` (#948, IL-796 — the fact record that flagged this
AWAITS-OPERATOR; this doc continues it) · `docs/adr/ADR-135-agent-skill-evolution-gate.md` (the evolution gate
this evaluation runs under) · CLAUDE.md §9 (external-component adoption = rules-based + human-in-the-loop) +
§10 (Config-over-Hardcoding — the auto-`CLAUDE.md` conflict) · ADR-117 (regulated perimeter — install is
operator/infra-gated) · `.claude/rules/safety-rules.md` + security canon (dual-use assessment) · the corrective
runbook (#900 — the manual lesson-capture precedent this pattern would automate) · `.github/CODEOWNERS`
(`/.claude/` + governance code-owner protection) · ADR-102 (Duplication Audit — this restates none of the
above). **Basis:** #948 harness-integration audit + this evaluation, 2026-07-02. Operator directive 2026-07-02
(scope Hyperbrowser/harness adoption — decision-doc only; adopt/defer AWAITS-OPERATOR).
