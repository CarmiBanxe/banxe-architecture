# UI-UX-DESIGN-SYSTEM-CANON.md — Design System Governance Canon

**Plane:** Architecture (Governance) | **Status:** CANON | **Created:** 2026-06-22
**Sprint:** S4 (UI/UX Factory — Design System canonicalization)
**Authority:** This document is **governance canon** over the BANXE UI/UX design-system
artifacts. It does **not** restate their content — it **elevates** the existing research
and system specifications into canonical, governed source-of-truth and binds the UI/UX
Factory delivery process to it.

---

## 0. Purpose & Scope

### Purpose
Canonicalize the BANXE Design System. Prior to this document the design system was
**PARTIAL**: research and a system specification existed as Architecture-plane docs but
were **not** governance canon (no ownership, contribution, versioning, deprecation, or
accessibility governance attached). This canon closes that gap by:

1. Naming the two existing artifacts as **canonical source-of-truth** (pointers, §2).
2. Attaching **governance rules** around design tokens (§3), the component library (§4),
   accessibility (§5), and the delivery process (§6) — **without duplicating** the
   substantive content, which remains in the referenced docs.
3. Declaring open items that require an operator decision (§8).

### Scope
- **In scope:** governance of design tokens, component-library lifecycle, accessibility
  standard, the 5-stage UI/UX delivery process, and role/RACI assignment.
- **Out of scope (governed elsewhere, referenced only):** concrete token values and
  component patterns (`docs/BANXE-UI-UX-SYSTEM.md`); tool classification & plane safety
  (`docs/BANXE-UI-UX-RESEARCH.md`); plane assignment / promotion mechanics
  (`docs/UI-PLANE-OPERATING-MODEL.md`); factory mandate & quality-gate KPIs (ADR-117).
- **Anti-duplication (ADR-102):** this canon references and points to existing artifacts;
  it MUST NOT copy their token tables, component specs, or tool matrices. Substantive
  edits to those facts happen in the source artifacts, not here.

### Relation to existing canon
Additive only. Does not override ADR-102 (Duplication Audit), ADR-103 (server-only
refactoring), ADR-056/057/059/060 (ledger), ADR-117 (factory/project perimeter), or the
invariants I-01..I-28. Where this canon and a higher artifact conflict, the higher
artifact wins.

---

## 1. Canonical Status Declaration

| Artifact | Path | Canonical role |
|----------|------|----------------|
| UX/Tool research base | `docs/BANXE-UI-UX-RESEARCH.md` | **Source-of-truth** for tool landscape, plane-safety classification, reference/prototype tooling |
| Design system specification | `docs/BANXE-UI-UX-SYSTEM.md` | **Source-of-truth** for design tokens, component patterns, UX rules, accessibility rules |
| UI plane operating model | `docs/UI-PLANE-OPERATING-MODEL.md` | **Source-of-truth** for plane assignment, token-source location, promotion path |

Effective with this document, the three artifacts above are **canonical and governed**.
Changes to them follow the contribution/review governance in §4 and the relevant ADRs.

---

## 2. Canonical Pointers (no duplication)

> These pointers are the binding references. Detail lives in the target doc; do not copy here.

- **Design philosophy & anti-patterns** → `docs/BANXE-UI-UX-SYSTEM.md` §"Design Philosophy".
- **Design tokens (color, typography, spacing, radius, elevation, iconography, data-viz)**
  → `docs/BANXE-UI-UX-SYSTEM.md` §"UI System".
- **Component patterns (Balance Widget, Transaction Row, Financial Card, AI Assistant
  Panel, Action Bar, Navigation)** → `docs/BANXE-UI-UX-SYSTEM.md` §"UI Component Patterns".
- **UX rules (journeys, trust & clarity, progressive disclosure, cognitive-load,
  accessibility rules)** → `docs/BANXE-UI-UX-SYSTEM.md` §"UX System".
- **Shared vs platform-specific split** → `docs/BANXE-UI-UX-SYSTEM.md` §"Shared vs
  Platform-Specific".
- **Tool classification & plane safety (Mobbin as primary reference; Claude Code as
  primary build tool; v0.dev/bolt.new prototype-only)** → `docs/BANXE-UI-UX-RESEARCH.md`.
- **Plane assignment & promotion (Developer → Product gate)** →
  `docs/UI-PLANE-OPERATING-MODEL.md` §"Plane Assignment".
- **Factory mandate & quality-gate KPIs** → `docs/adr/ADR-117-factory-project-perimeter-and-fullcycle-org.md`.
- **Taste Rubric (advisory bands)** → `docs/BANXE-UI-UX-SYSTEM.md` §"Taste Rubric (advisory)" (governed by §5A below; substance lives there, not here).

---

## 3. Design Token Governance

> Governance rules only. Token **values** are canonical in `docs/BANXE-UI-UX-SYSTEM.md`
> §"UI System" — not restated here.

### 3.1 Single source of truth
- The **authoritative token definitions** (semantics & values) live in
  `docs/BANXE-UI-UX-SYSTEM.md` (Architecture plane).
- The **machine source** for tokens is `banxe-ui/packages/design-tokens/` (Developer
  plane), per `docs/UI-PLANE-OPERATING-MODEL.md`. The package MUST stay derived from the
  spec; divergence between spec and package is a defect.
- No component, app, or service may hardcode raw color/spacing/type values that duplicate
  a token (Config-over-Hardcoding, CLAUDE.md §10). Consume tokens, never literals.

### 3.2 Naming convention (asserted in the spec)
- Tokens are CSS custom properties, kebab-case, **category-prefixed**:
  `--color-*`, `--font-*`, `--text-*`, `--space-*`, `--radius-*`, `--shadow-*`,
  `--weight-*` (see `docs/BANXE-UI-UX-SYSTEM.md`). New tokens MUST follow this scheme.
- Semantic naming over raw naming (e.g. `--color-success`, not a hex alias) is canonical:
  status/intent tokens carry meaning, enabling theme swaps.

### 3.3 Theme scope (asserted)
- **Dark mode ships first** (premium fintech context); **light mode is v2** per the spec.
  Token sets MUST be structured so a light theme can be added without renaming semantic
  tokens.

### 3.4 Versioning rule
- Token changes are **versioned and additive-preferred**. Renaming or removing a token in
  use is a **breaking change** and follows the deprecation path (§4.3).
- Every token change records: rationale, affected components, and migration note. Color
  changes that affect contrast MUST be re-checked against the accessibility canon (§5).

---

## 4. Component Library Governance

> Lifecycle governance for the shared component library. Component **specs** are canonical
> in `docs/BANXE-UI-UX-SYSTEM.md`; prototype/promotion mechanics in
> `docs/UI-PLANE-OPERATING-MODEL.md`.

### 4.1 Contribution
- New or changed components originate in the Developer plane
  (`banxe-ui/packages/ui/`, documented in Storybook) and MUST: consume tokens (§3),
  satisfy the accessibility canon (§5), and map to a pattern in
  `docs/BANXE-UI-UX-SYSTEM.md` (or extend it via a spec change first).
- v0.dev / bolt.new / lovable output is **structural reference only** and MUST be
  rewritten before entering the library (per `docs/BANXE-UI-UX-RESEARCH.md` and
  `docs/UI-PLANE-OPERATING-MODEL.md`). No generated code is promoted verbatim.

### 4.2 Review & promotion (Developer → Product)
- Promotion from prototype (`banxe-ui/`) to Product (`banxe-emi-stack/ui/`,
  `banxe-emi-stack/mobile/`) happens **only after review**, per
  `docs/UI-PLANE-OPERATING-MODEL.md`.
- Any structural refactor/dedup of components obeys the **Duplication Audit (ADR-102)** and
  **server-only refactoring (ADR-103)** — repo-wide duplicate search, source-of-truth +
  every consumer enumerated, fail-closed on doubt.
- Promotion PRs are subject to the factory quality-gate KPIs (ADR-117): coverage ≥85%
  critical, 0 blocker/critical on merge, security-hotspot ≥95%.

### 4.3 Deprecation
- Components/tokens are deprecated, never silently deleted: mark **deprecated** with a
  replacement pointer and a removal window; enumerate consumers (ADR-102 step 2/3) before
  removal; remove only after all consumers migrate. Standby/GUIYON/SS1 isolation (I-18,
  I-20) is preserved — no BANXE UI asset crosses into Standby.

---

## 5. Accessibility Canon

> **Asserted in `docs/BANXE-UI-UX-SYSTEM.md` §"Accessibility Rules" — NOT AWAITS OPERATOR.**

- **Standard:** **WCAG 2.1 AA minimum** is canonical and binding for all BANXE UI
  (web + mobile).
- Binding rules carried from the spec (referenced, not exhaustively restated): all
  interactive elements keyboard-navigable & focusable; status conveyed by **icon + text,
  never color alone**; amounts announced to screen readers with currency; charts provide a
  data-table fallback; minimum **44×44px** touch targets on mobile; visible focus ring;
  skip-to-content on web.
- **Governance:** any new component or token change MUST be verified against WCAG 2.1 AA
  before promotion (§4.2). Contrast-affecting token changes (§3.4) re-run the contrast
  check. A change that cannot meet AA is fail-closed and escalated (§8).
- **Open item:** whether BANXE targets a higher level (e.g. WCAG 2.2, or AAA for specific
  flows) beyond the asserted 2.1 AA floor is **AWAITS OPERATOR** (§8).

---

## 5A. Taste & Polish Governance

> **Pointer governance — substance lives in `docs/BANXE-UI-UX-SYSTEM.md` §"Taste Rubric (advisory)" (§2 pointer); not restated here.** Parallels §5 (Accessibility) in shape, but with the opposite enforcement posture: accessibility is a hard gate; taste is advisory.

- **Advisory, never a gate.** The Taste Rubric yields advisory bands (on-canon / drifting / off-canon) only — no numeric score, no pass/fail. Taste output **MUST NOT** block promotion and **MUST NOT** become a merge/governance gate (binding correction: an agent grading its own output ≠ a governance gate).
- **WCAG 2.1 AA (§5) remains the hard floor.** A taste band can never waive an accessibility failure; §5 is verified independently and blocks — taste does not.
- **Promotion gate unchanged (taste = advisory input only).** Promotion stays governed by the **Duplication Audit (ADR-102, §4.2)** + the **factory quality-gate KPIs (ADR-117, §4.2)** + §4.1 no-verbatim-promotion. The taste band is advisory input to those gates, never a substitute.
- **ADR bindings.** Promotion of any taste/polish artifact is **operator HITL via ADR-135** (held-out adoption gate). Authority is **factory-only, non-delegable**; advisory-review execution is **project-side (`banxe-ui`)** per **ADR-145**. Any bounded polish loop (the "impeccable" capability) **instantiates ADR-149** closed-loop completion-criteria (declarative stop-condition + hard max-iteration cap; STOP-at-any-mutation = HITL) — governed here, **declared** in the agent/validator layer (a separate step), not in this canon.
- **θ threshold (config-as-data).** Any future polish-loop taste-score threshold (θ) lives as **config-as-data** (location parallel to the token machine-source, §3.1), **not** in this canon. Its **value is AWAITS OPERATOR** (§8 OI-5) — this canon sets no θ.
- **Accountability.** Rubric owner = **Design System Lead / Head of Design — AWAITS OPERATOR** (§7.1 row; §7.2 ownership gap). Until assigned, taste-governance decisions (θ value, taste sign-off) **escalate to the operator** (§7.2). This canon does not invent an owner or a threshold.

---

## 6. UI/UX Delivery Process (5 stages)

Per the target operating model **§5.3 UI/UX Factory**, the canonical delivery process has
five stages. Each stage is bound to the canonical artifacts above.

| # | Stage | Canonical inputs / outputs |
|---|-------|----------------------------|
| 1 | **Design Discovery** | UX research base (`docs/BANXE-UI-UX-RESEARCH.md`); user types & journeys (`docs/BANXE-UI-UX-SYSTEM.md` §"UX System"). Output: discovery findings / personas. |
| 2 | **Wireframing** | Journeys & dashboard logic (`docs/BANXE-UI-UX-SYSTEM.md`). Tooling per plane-safety (`docs/BANXE-UI-UX-RESEARCH.md`). Output: low-fi flows. |
| 3 | **Design System** | Tokens & component patterns (`docs/BANXE-UI-UX-SYSTEM.md`); token source `banxe-ui/packages/design-tokens/`. Governed by §3–§4 of this canon. |
| 4 | **Front-end** | Component library + apps in Developer plane; promotion to Product per `docs/UI-PLANE-OPERATING-MODEL.md` and §4.2. Quality-gate KPIs (ADR-117). |
| 5 | **Usability** | Trust/clarity, cognitive-load, accessibility rules (`docs/BANXE-UI-UX-SYSTEM.md`). Accessibility verified per §5. |

Stages 3–5 are gated by this canon; stages 1–2 are governed by the research/spec
artifacts. No stage may bypass `quality-gate.sh` or the invariants (CLAUDE.md, agents.md).

---

## 7. Roles & RACI

The target operating model **§5.3 UI/UX Factory** names these roles:
**UX Researcher, UX Designer, UI Designer, Design System Lead, Motion (Designer),
Accessibility Engineer**.

### 7.1 Indicative RACI (role-level, per §5.3 stage mapping)

| Activity | Responsible | Accountable | Consulted |
|----------|-------------|-------------|-----------|
| Design Discovery (1) | UX Researcher | **CTO (SMF26)** *(interim Head of Design)* | UX Designer |
| Wireframing (2) | UX Designer | **CTO (SMF26)** *(interim Head of Design)* | UI Designer, UX Researcher |
| Design System (3) | **Design System Lead** | **CTO (SMF26)** *(interim Head of Design)* | UI Designer, Accessibility Engineer |
| Front-end (4) | Front-end (Developer plane) | **Design System Lead** | Motion, Accessibility Engineer |
| Usability (5) | Accessibility Engineer | **CTO (SMF26)** *(interim Head of Design)* | UX Researcher |
| Taste & Polish governance (§5A) | **CTO (SMF26)** *(interim)* | **CTO (SMF26)** *(interim Head of Design)* | UI Designer, Accessibility Engineer |

### 7.2 Ownership — INTERIM (CTO / SMF26), dedicated hire pending
- **Interim accountable owner = CTO (SMF26, Oleg)** — operator-assigned 2026-06-29 as the interim
  design-system accountable (Head-of-Design function), recorded in `docs/ORG-STRUCTURE.md` §2.7 +
  `docs/JOB-DESCRIPTIONS.md` §1.6. The CTO holds design-system accountability until a dedicated
  role is hired.
- **Still AWAITS OPERATOR:** a **dedicated `Head of Design` / `Design System Lead`** (a named person
  beyond the interim CTO holder) remains a future operator hire — the interim assignment does not
  create the standalone role.
- Design-system governance decisions (token breaking changes, accessibility target above the AA
  floor, promotion sign-off, taste sign-off) are **accountable to the interim CTO owner**; anything
  beyond interim scope escalates to the operator. This canon assigns no owner of its own accord — it
  records the operator's interim assignment.

---

## 8. Open-Items Register (AWAITS OPERATOR)

| # | Item | State | Resolution path |
|---|------|-------|-----------------|
| OI-1 | Design function ownership — `Head of Design` / `Design System Lead` (named person, reporting line, SMF/dept) | **INTERIM: CTO (SMF26)** accountable (2026-06-29); dedicated hire **AWAITS OPERATOR** | Interim recorded in `docs/ORG-STRUCTURE.md` §2.7 + `docs/JOB-DESCRIPTIONS.md` §1.6; dedicated Head-of-Design / Design-System-Lead hire pending |
| OI-2 | Accessibility target above the asserted **WCAG 2.1 AA** floor (e.g. 2.2 AA, or AAA for specific flows) | **AWAITS OPERATOR** | Operator decision; if raised, update `docs/BANXE-UI-UX-SYSTEM.md` §"Accessibility Rules" then this canon |
| OI-3 | Token versioning scheme (semver of `banxe-ui/packages/design-tokens/`, release cadence) | **AWAITS OPERATOR** | Define version policy in token package; reference here |
| OI-4 | Component-library KPIs specific to UI/UX (beyond ADR-117 factory KPIs) | **AWAITS OPERATOR** | Confirm whether UI-specific KPIs are needed; if so, add to `docs/governance/CANON-RECONCILIATION-ADR117.md` |
| OI-5 | Taste-score threshold **θ** for the polish loop (config-as-data location + value) + named **Taste & Polish owner** (Design System Lead / Head of Design) | **θ: AWAITS OPERATOR** · **owner: INTERIM CTO (SMF26)** (2026-06-29) | Owner = interim CTO (§7.2); **θ value still AWAITS OPERATOR** — operator sets θ as config-as-data (parallel to token machine-source, §3.1); this canon sets no θ |

> Per operator canon: unknowns are recorded as **AWAITS OPERATOR**, never invented.

---

## 9. Provenance

- **Authored:** S4 (UI/UX Factory — Design System canonicalization), 2026-06-22.
- **Branch:** `agent/factory/uiux/s4-design-system-canon`.
- **Ledger:** session `agent-factory-uiux-s4-design-system-canon`, il_ts
  `2026-06-22T08:45:00Z` (append-only tail shard; ADR-056/059/060).
- **Canon sources (referenced, not duplicated):** `docs/BANXE-UI-UX-RESEARCH.md`;
  `docs/BANXE-UI-UX-SYSTEM.md`; `docs/UI-PLANE-OPERATING-MODEL.md`;
  `docs/adr/ADR-117-factory-project-perimeter-and-fullcycle-org.md`; target operating
  model §5.3 UI/UX Factory.
- **Anti-duplication:** ADR-102 (Duplication Audit) — this canon references and elevates;
  it does not copy token/component/tool content. ADR-103 (server-only) applies to any
  resulting refactor.
- **DO NOT MERGE** without operator review of the AWAITS-OPERATOR open items (§8).
