# Agent-Status Normalization — spec + canon-role-passport acknowledgment (Sprint A)

> **Status:** governance normalization spec + acknowledgment (Sprint A of the master-plan #978). **Additive,
> pointer-first (ADR-102).** It **defines** the status-normalization rule and **acknowledges** the canon-role
> passport class — it is **SPEC-ONLY.** It **does NOT edit any passport file, activates no agent, and touches
> no ADR / config / perimeter / legal / ss1.** The actual mass edit of passport files and any
> `PROPOSED→ACTIVE` activation are **separate, operator-gated steps (§4)** — deliberately not in this PR.

## 1. Problem (from #972 / #973 / #982)
Passport status metadata is **inconsistent**, and one passport class is **unacknowledged**:
- **Casing split:** `active` (10) vs `ACTIVE` (3) — the same state written two ways.
- **Distribution (strict top-level `^status:`, per L-10):** **39 `PROPOSED` / 10 `active` / 3 `ACTIVE` / 18
  without top-level status.**
- **2 indented (non-top-level) status:** `agents/passports/data_lake_elt_agent.yaml`,
  `agents/passports/treasury_alm_agent.yaml` carry `status: PROPOSED` **indented**, not as a top-level key.
- **16 with no `status:` at all.**
- **+10 canon-role passports** (`docs/canon/passports/`) are **not acknowledged** in the fleet inventory (a
  completeness gap, like swarms in #973).

## 2. Normalization rule (governance-spec; config-as-data)
The canonical status contract for `agents/passports/**`:
- **Canonical enum (uppercase):** `status` ∈ **`{PROPOSED | ACTIVE | DEPRECATED}`**. `active` → `ACTIVE`
  (casing normalized to one form).
- **Top-level required:** `status:` MUST be a **top-level `^status:` key** (un-indented). An **indented**
  `status:` is a **format error** → **raise it to top-level** (the 2 indented files).
- **No-status default:** a passport with no `status:` → **`PROPOSED`** by default, **flagged** (not silently
  assumed active — an unstated status is a proposal, never a live claim; honesty boundary, per L-10).
- **Measurement rule (L-10):** all status tallies anchor to **top-level `^status:`**, case-normalized; nested
  status is reported separately, never folded into the top-level count.

*These are the normalization **rules**. The 70+ file edits that apply them are §4 (operator-gated).*

## 3. Canon-role-passport acknowledgment
The `docs/canon/passports/` class is **explicitly acknowledged** as a **distinct governance-topology class**,
separate from the 70 bank-agent passports:
- **10 canon-role passports:** `operator`, `ctio`, `planner`, `reviewer`, `canon-judge`, `executor`,
  `guardian-factory`, `guardian-project`, `mlro`, `schema` — these are **governance/terminal-topology roles +
  CI guardians + the passport schema**, NOT bank agents.
- **Acknowledged inventory (pointer to master-plan #978 F-ARCH; not re-tallied there):**
  **70 bank-passports + 10 canon-role passports + 20 souls + 3 swarms + 4 factory agents.**
- **Not reclassified:** whether the 10 belong *inside* the "fleet" is a scoping judgment reserved to the
  operator; this spec **acknowledges the class exists and is distinct**, nothing more.

## 4. Scope discipline — what is NOT in this PR (operator-gated, separate)
> **This PR is the normalization SPEC + acknowledgment (a governance doc). It edits no passport.** Applying the
> rule touches 70+ files under `agents/passports/` — a mass change that must not be done blind.

- **`[AWAITS-OPERATOR]` — apply normalization to passports:** the actual edits (casing `active→ACTIVE`, raise
  the 2 indented status to top-level, add `PROPOSED` to the 16 no-status) are a **separate, operator-confirmed
  step** — a bounded, reviewable PR of its own, **not this one** (so 70 files are never touched blind).
- **`[AWAITS-OPERATOR]` — activation:** any `PROPOSED→ACTIVE` promotion is a **separate ADR-135 per-agent
  gate**, operator-driven — **not here.** Normalizing the *casing* of an existing `ACTIVE` is metadata hygiene;
  **making** an agent `ACTIVE` is activation and is out of scope.
- **Ordering:** normalize (rule ratified) → apply-to-passports (operator-gated bulk PR) → activate (ADR-135 per
  agent). Each is its own gated step.

## 5. Boundaries
- **Spec-only** — this doc defines the rule + acknowledges the class; **no passport file is edited here.**
- **No agent activated** — casing normalization ≠ activation; activation is a separate ADR-135 gate.
- **No ADR / config / perimeter / project-code / legal / ss1 touched.** No enum config file is created here
  (the enum is stated in-spec; a ratifiable config is part of the apply step if the operator wants one).
- The 2 indented files and the 16 no-status files are **named as targets for the future apply step**, **not
  edited** in this PR.

## Anchors
`docs/governance/FLEET-CONFORMANCE-AUDIT.md` (#972) + erratum (#973 — the strict `^status:` split 39/10/3/18,
the 2 indented + 16 none, casing finding) · `docs/governance/AGENT-FLEET-MASTER-PLAN.md` (#978 — Sprint A;
F-ARCH the 10 canon-role passports; §7 runtime) · `docs/governance/FACTORY-LESSON-CAPTURE.md` L-10 (measurement
rule — top-level `^status:`, nested reported separately) · `docs/adr/ADR-135-agent-skill-evolution-gate.md`
(activation gate — separate, per-agent) · CLAUDE.md §10 (Config-over-Hardcoding) · ADR-102 (Duplication Audit —
restates none). Operator directive 2026-07-02 (Sprint A: normalize status/casing + acknowledge canon-role
passports; spec-only; passport edits + activation are separate operator-gated steps).
