---
id: LEDGER-KNOWN-DEBT-IL-DUPLICATES
title: Known-debt — duplicate IL headers IL-032/033/034/052 in FROZEN-ARCHIVE (record only, no renumber)
status: PROPOSED
date: 2026-06-27
concept_only: true
relates:
  - "ADR-133 (IL global-uniqueness gate — checks IL-SEQUENCE.json VALUES; these four are FROZEN-ARCHIVE heading text, not minted values, so the gate does not flag them)"
  - "ADR-057 / ADR-059 / ADR-059-A (append-only shard ledger; FROZEN-ARCHIVE is the frozen pre-shard monolith)"
  - "ADR-119 (stable/frozen IL numbering — renumber of an existing/merged entry is forbidden)"
il_anchor: IL-616
il_anchor_note: "Provisional per ADR-119 Rule 8 — NOT hardcoded; build_ledger mints max+1 over current origin/main. Frozen at rebase-before-merge."
---

# Known-debt — duplicate IL headers IL-032/033/034/052 (record only)

> **Documentation / known-debt record ONLY.** This file does **not** alter, renumber, or de-duplicate
> the historical entries — that is a **separate, risky migration** (a future ADR + operator). No
> runtime, no code, no secret. Fail-closed: **no auto-renumber.**

## 1. Defect

`INSTRUCTION-LEDGER.md` (the generated monolith) renders **`ledger/FROZEN-ARCHIVE.md`** verbatim at its
head. Four IL numbers appear there as **duplicate `### IL-0NN — <title>` headings** (each twice):

| IL | Entry A (FROZEN-ARCHIVE) | Entry B (FROZEN-ARCHIVE) |
|----|--------------------------|--------------------------|
| **IL-032** | `S17-01/S17-09: CustomerLifecycleAgent service (dual entity + lifecycle state machine)` (line 683) | `CustomerLifecycleAgent service` (line 726) |
| **IL-033** | `S17-02: AgreementAgent service skeleton (T&C + e-sig stub)` (line 697) | `AgreementAgent service` (line 730) |
| **IL-034** | `S17-11: Event Bus domain events (RabbitMQ publisher pattern)` (line 711) | `Event Bus` (line 734) |
| **IL-052** | `Compliance Reporting Phase 3 (FIN060 API + SAR Auto-Filing)` (line 1011) | `phase4 org-cleanup branch recovery (post-mortem)` (line 2866) |

(Line numbers are vs `INSTRUCTION-LEDGER.md` / `FROZEN-ARCHIVE.md` at the audit commit; both copies of
each pair live in `ledger/FROZEN-ARCHIVE.md`.)

## 2. Classification — these are NOT minted-value collisions

These are **heading-text duplicates inside the frozen pre-shard archive**, **not** duplicate values in
`ledger/IL-SEQUENCE.json`. The minted IL-SEQUENCE values are **unique** (the only minted-value duplicate
is the separately-tracked, ADR-133-allowlisted `{540: 2}`). Therefore the **ADR-133 global-uniqueness
gate — which checks IL-SEQUENCE values — correctly does not flag IL-032/033/034/052**: they are not in
the minted sequence (low numbers in the FROZEN offset range), they are legacy rendered text.

## 3. Root cause

`FROZEN-ARCHIVE.md` is the **pre-shard, pre-ADR-059, pre-ADR-133** monolithic ledger. In that era,
`### IL-NNN — <title>` headings were authored by hand and an IL number was reused across:
- a **detailed work entry** and a **terse summary/passport entry** for the same work (IL-032/033/034), and
- **two unrelated work items** in different sprints (IL-052: a compliance-reporting build vs a phase-4
  org-cleanup post-mortem).
No append-only/uniqueness gate existed then; the duplicates were frozen into the archive.

## 4. Risk — LOW

- **Historical / frozen** — in `FROZEN-ARCHIVE.md`, not in live shards; no current process keys off these
  legacy headings.
- **Cosmetic** — heading text only; the **minted IL-SEQUENCE numbering is unique**, so build_ledger
  ordering, ADR-133, and the merge flow are unaffected.
- **No new dups** — the ADR-133 gate prevents new minted-value collisions; **this record adds zero**.

## 5. Proposed remediation path (SEPARATE future work — NOT done here)

A future **migration ADR + operator decision** (fail-closed; no auto-renumber) chooses one of:
1. **Annotate-in-place** — add a disambiguating note/suffix to the duplicate FROZEN-ARCHIVE headings
   (e.g. mark Entry B as a summary of the same IL), **without** changing any minted IL-SEQUENCE value.
2. **Accept as permanent documented known-debt** — leave the frozen archive untouched; this file is the
   canonical record.
3. **Reclassify (only if ever needed)** — if a heading is reinterpreted as a minted value, update the
   **ADR-133 allowlist** accordingly (as was done for `{540}`).

**Renumbering an existing/merged entry is forbidden (ADR-119, ADR-057).** Any change to
`FROZEN-ARCHIVE.md` is a deliberate, gated migration — never automatic.

## Anchors

- `ledger/FROZEN-ARCHIVE.md` (the four duplicate headings; UNCHANGED by this record),
  `INSTRUCTION-LEDGER.md` (generated monolith), `ledger/IL-SEQUENCE.json` (minted values — unique except
  allowlisted `{540}`). ADR-133 (uniqueness gate), ADR-057/059/059-A (append-only), ADR-119 (no renumber).
  Record-only; no runtime/secret; no edit to historical entries.
