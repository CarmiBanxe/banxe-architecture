# MIG-TEMPLATE — canonical structure for migration docs (docs-only)

**Status:** canonical template · **Date:** 2026-06-22
**Type:** docs-only · **NO code, NO scaffold, NO new ports/services, NO merge**
**Scope of this file:** structure only — it defines the skeleton every future
`MIG-*` doc for the **BANXE.RAR → EMI** migration MUST follow. It is itself
non-executing; copying it never changes repo/service state.

> **Purpose.** A single canonical skeleton so that every MIG doc stops re-stating
> the same boilerplate (mode, discipline, evidence, audit shape). Authors fill the
> sections below; reviewers check presence and consistency, not re-invented layout.
> This removes duplicated front-matter across `docs/migration/MIG-*.md` and makes
> mode/discipline machine-greppable ("Mode:", "Discipline:").

> **This template does NOT introduce or amend any ADR.** ADR-102 / ADR-103 / ADR-117
> are referenced as-is. A MIG doc adopting this template inherits, never overrides,
> the canon in `.claude/rules/*` and `docs/adr/*`.

---

## How to use this template

1. Copy this skeleton into `docs/migration/MIG-<id>-<slug>.md`.
2. Keep the same section numbers and headings (§1…§8) so docs stay greppable.
3. Fill each section; delete a section only if it is genuinely N/A and say so
   explicitly (`§6 Decision — N/A (read-only advisory, nothing to keep/merge/retire)`).
4. Drop the "How to use" and the per-section *guidance* (the italic prompts) when
   instantiating — keep only the headings and your filled content.
5. Pair every MIG doc with a ledger shard (see `ledger/SHARD-WORKFLOW.md`); the doc
   describes, the shard records (ADR-059-A append-only).

---

## §1 Summary

*Guidance:* one short paragraph — the goal of THIS MIG doc. What legacy surface
(BANXE.RAR side) is in question, what EMI-side target it maps to, and the single
outcome of this doc (audit / blocker / decision-brief / scaffold-plan / reconcile).
No history, no narration. If the doc only reports and changes nothing, say so here.

> Example: "Duplication audit of BANXE.RAR `open-banking` consents surface vs the
> existing EMI `banxe-platform/open-banking` service. Outcome: advisory-only audit;
> recommends RETIRE of the legacy copy (already covered). No code, no scaffold."

---

## §2 Scope

*Guidance:* name the exact repo / rail / service in focus, and what is explicitly
**out of scope**. Be concrete (`banxe-platform/packages/shared`, SEPA rail,
`gl-service`), not thematic. Call out compliance holds (e.g. KYC/KYB/AML = HOLD
under I-27) so the reader knows what this doc deliberately does NOT touch.

- **In focus:** `<repo / package / rail / service>`
- **Out of scope:** `<adjacent surfaces, downstream consumers, compliance HOLDs>`
- **Legacy ↔ EMI anchor:** `<BANXE.RAR path> → <EMI target path>`

---

## §3 Mode

*Guidance:* pick exactly one primary mode from the canonical set. The mode tells a
reviewer what the doc is allowed to do. Use the literal labels so they are greppable.

| Mode | Meaning |
|---|---|
| **advisory-only** | read-only, no code, no scaffold, no merge. Audit/analysis/recommendation only. |
| **BLOCKER** | a fail-closed STOP: the proposed target already exists / collides / mismatches. Records *why no work proceeds* and what must resolve first. |
| **AWAITS-OPERATOR** | decision-brief: options laid out, **no selection made**. Activation is an explicit operator go (Rule 11). |
| **scaffold** | a plan to create target homes / move code. Plan vs execution MUST be stated; execution only after its gate clears. |
| **reconcile** | align two already-existing surfaces (parity inventory, dedup, consumer re-point). |

State it as one line: `Mode: <label> (see MIG-TEMPLATE §3)`. A doc may note a
secondary mode (e.g. an advisory-only doc that ends in an AWAITS-OPERATOR item),
but the primary mode governs what is permitted.

---

## §4 Discipline

*Guidance:* list the ADR / invariant discipline this doc operates under. The
canonical set is below; each MIG selects the **subset** that actually applies and
says why. Do not invent new discipline here — reference existing ADRs only.

| Ref | Discipline | When it applies |
|---|---|---|
| **ADR-102** | Duplication Audit (repo-wide before any structural change) | any audit / dedup / retire / merge decision |
| **ADR-103** | Server-only refactor (evo1 / runner; Legion = thin client) | any actual move/edit/scaffold execution |
| **ADR-059-A** | Append-only ledger (sharded; never mutate prior entries) | every MIG doc (it pairs with a shard) |
| **ADR-060** | Branch namespace `agent/<actor>/<id>/<slug>` | every MIG doc's branch/PR |

State it as one line: `Discipline: ADR-102, ADR-103, ADR-059-A` (the actual subset).
A pure read-only advisory may carry only ADR-102 + ADR-059-A; a scaffold-execution
doc carries the full set including ADR-103.

---

## §5 Evidence & Preflight

*Guidance:* record the read-only facts that ground the doc, so the audit is
reproducible. Always pin where the evidence came from.

- **origin/main:** `<sha>` (re-fetched at authoring time)
- **HEAD:** `<sha>` (branch tip)
- **grep / search results:** the repo-wide search behind the duplication finding —
  paths matched, counts, source-of-truth candidate vs duplicates.
- **Provenance:** `verified-evo1` (server-side, authoritative) **vs** `verified-legion`
  (thin-client, local — **must be re-confirmed server-side** before any execution
  per ADR-103). State which one this doc's evidence is, explicitly.
- **Preflight gate(s):** the read-only checks that must pass before any later
  execution (ADR-102 re-audit at execution time, parity inventory before retire,
  evo1 availability re-confirm, guardian/ledger green).

---

## §6 Decision

*Guidance:* the keep/merge/retire table — one row per duplicate/surface found in the
audit. This is the actionable core of an ADR-102 Duplication Audit. If the doc is
read-only with nothing to decide, write `N/A` and say why.

| Surface / artifact | Source-of-truth | Consumers enumerated? | Decision | Risk / note |
|---|---|---|---|---|
| `<path-or-symbol>` | `<canonical home>` | yes / no (block if no) | **keep** / **merge** / **retire** | `<hidden-dep risk, parity caveat>` |

> Decisions are **keep / merge / retire** (ADR-102 vocabulary: keep / merge / delete →
> here "retire" = delete/deprecate the legacy copy). No retire/merge until every
> consumer is enumerated and hidden deps are positively confirmed absent — otherwise
> **fail-closed and escalate** (ADR-102 step 5).

---

## §7 What was / was NOT done

*Guidance:* an explicit done/not-done split so a reader never assumes more happened
than did. Standard bullets below — adapt the specifics, keep the shape.

**Done (this doc):**
- Read-only preflight (origin/main + HEAD pinned, repo-wide grep).
- Duplication audit per ADR-102 (matches, source-of-truth, consumers).
- Decision recorded (§6) and discipline declared (§4).

**NOT done (deliberately, fail-closed):**
- No scaffold, no code, no file moves, no merge.
- No new ports / services / runtime changes.
- No selection of operator-gated options (if any) — those stay AWAITS-OPERATOR.
- No mutation of prior ledger entries (append-only, ADR-059-A).
- No compliance surface touched if HOLD (e.g. KYC/KYB/AML under I-27).

---

## §8 Next steps / operator gates

*Guidance:* describe future scaffold-substeps and any AWAITS-OPERATOR items WITHOUT
performing them. Each future step is stated as `IF <gate clears> → <step>`
(fail-closed): nothing runs until its gate resolves.

- **AWAITS-OPERATOR items:** numbered decisions the operator must resolve, each with
  the options and the consequence of each — but **no recommendation that pre-empts a
  selection** beyond what §6 states.
- **Conditional scaffold-substeps:** `IF operator picks X → step(s)`; each paired with
  its artifacts (backend/frontend PR + arch IL shard) and its gate (ADR-102 re-audit,
  ADR-103 server-side, parity-before-retire).
- **Ordering:** state the dependency order (e.g. dedup → promotion) and that no
  substep runs before its decision.

---

## How to reference

When another doc, ledger shard, or PR needs to point at the conventions in this
template, use the one-line form:

```
Mode: advisory-only (see MIG-TEMPLATE §3), Discipline: ADR-102, ADR-103, ADR-059-A
```

- `Mode:` — one canonical label from §3.
- `Discipline:` — the actual ADR subset from §4 for that doc (not the full list
  unless all apply).
- Optionally append `Provenance: verified-evo1|verified-legion` (§5) when the
  reference is about executable evidence.

---

*Template only. Defines structure for future `docs/migration/MIG-*.md` docs; it
executes nothing, scaffolds nothing, and amends no ADR (ADR-102 / ADR-103 / ADR-117
referenced as-is). Discipline baseline: ADR-102, ADR-103, ADR-059-A, ADR-060, I-28.*
