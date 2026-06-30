---
id: ADR-154
title: Shared-space orchestration — the factory (left terminal) as single arbiter of shared-space boundaries
status: PROPOSED
date: 2026-06-30
concept_only: false
relates:
  - "ADR-060 (multi-actor branch namespace)"
  - "ADR-143 / ADR-143-A / ADR-125 (central Redis IL allocator + collision resolution)"
  - "ADR-120 / ADR-121 (per-session worktree isolation / destructive-action protection); parallel-session-isolation Rules 1–7"
  - "ADR-056 / ADR-057 / ADR-059 / ADR-119 (append-only ledger + stable IL numbering); #900 corrective ledger-flow runbook"
  - "ADR-153 (terminal-topology canon — complementary); docs/governance/TERMINAL-OWNERSHIP.md (ownership/zone registry, line 1/7)"
  - "AGENTS.md §Central Terminal (single-writer authority); §CANON — Best Single Artifact"
il_anchor: IL-749
il_anchor_note: "Provisional per ADR-119 Rule 8 — minted by the central allocator (ADR-143/143-A) over current origin/main; frozen at rebase-before-merge."
scope: BANXE-factory-governance
---

# ADR-154 — Shared-space orchestration: the factory (left terminal) as single arbiter of shared-space boundaries

## Status
PROPOSED — 2026-06-30. Prepare-only Draft; operator HITL. Line 2 of the 7-document governance sequence.

## Context
Three terminals operate over shared repository state: **A** (the factory / left terminal), **B** (right), and
**Central**. Two adjacent documents already exist. `docs/governance/TERMINAL-OWNERSHIP.md` (line 1/7) registers
*who owns which write-zone*, and **ADR-153** defines the terminal *topology* (what the terminals are). What is
still missing is a single, authoritative statement of **who arbitrates the shared-space boundaries** when
terminals operate concurrently — so that conflicts on IL numbers, branches, foreign-session state, and the
ledger cannot occur. The *mechanisms* for each boundary already exist across several ADRs; what this ADR adds is
the canon that **names the arbiter** and binds those mechanisms into one boundary-arbitration model. Per ADR-102
it references those mechanisms and does not restate them.

## Decision
**The LEFT terminal (the factory) is the single arbiter of shared-space boundaries.** It arbitrates four
boundaries — each governed by existing canon, referenced and not restated — and two supremacy rules bind the
model. Together these resolve **Terminal-B recommendations 1, 3, 4, 5, 6** and **Central recommendations 3, 4**.

### Four arbitrated boundaries (mechanism is canon — pointer only)
1. **Atomic IL allocation before work.** The IL number is allocated from the **central Redis allocator at TASK
   START**, not at commit, so two terminals can never receive the same number. Mechanism: **ADR-143 /
   ADR-143-A** (central single-writer allocator) + **ADR-125** (collision resolution). Not re-specified here.
2. **Branch-namespace per terminal.** Each terminal works only within its own `agent/<actor>/<id>/<slug>`
   namespace (`actor ∈ {central, right, factory}`); cross-namespace writes are out of bounds. Mechanism:
   **ADR-060**.
3. **Foreign-session & destructive-action protection.** No terminal writes to, or destroys, another session's
   state; `--force-with-lease`, verify-branch-before-stage, and per-session worktree isolation apply.
   Mechanism: `parallel-session-isolation` **Rules 1–7** + **ADR-120** (worktree isolation) + **ADR-121**
   (destructive-action protection).
4. **Append-only ledger.** The ledger is append-only: each terminal appends ONLY its own session shard, the
   generated `INSTRUCTION-LEDGER.md` is never hand-edited, and IL numbers are never hardcoded. Mechanism:
   **ADR-056 / ADR-057 / ADR-059 / ADR-119** + the **#900** corrective ledger-flow runbook.

### Two supremacy rules
- **S-1 — Factory-arbiter supremacy (Central rec 3).** On any shared-space boundary conflict (IL, branch,
  foreign-session, ledger), the factory's arbitration is **authoritative and final**. Central orchestrates
  *through* the factory and does not write shared state directly (single-writer authority, `AGENTS.md`);
  Terminal B writes only within its declared zone (`TERMINAL-OWNERSHIP.md`). No terminal overrides the factory's
  boundary arbitration.
- **S-2 — No unarbitrated autonomous write (Central rec 4).** No autonomous runtime or terminal may write shared
  space without first passing the factory's arbitration (atomic allocation + namespace + lease). An
  **un-arbitrated concurrent write to shared space is blocked, not merged.** This is consistent with the NO-WAIT
  rule: Central files feedback to Terminal A and keeps working *through* the factory, which arbitrates.

## Consequences
- **(+)** A single, named arbiter for shared-space conflicts; the existing mechanisms are unified under one
  model without being restated or duplicated.
- **(+)** Resolves Terminal-B recommendations 1, 3, 4, 5, 6 and Central 3, 4.
- **(+)** Complements its two neighbours cleanly: **ADR-153** says what the terminals are (topology),
  `TERMINAL-OWNERSHIP.md` says who owns which zone, and **this ADR** says who arbitrates the boundaries between
  them.
- **(−/risk)** The factory becomes a single point of arbitration. This is mitigated because the *mechanisms*
  (allocator, namespace, lease, append-only) are already redundant and CI-enforced — the arbiter names and binds
  them, it does not replace them, so a factory outage degrades to the existing per-mechanism gates.
- **[НЕИЗВЕСТНО]** The exact one-to-one mapping of the four boundaries to the internal Terminal-B recommendation
  numbers (1/3/4/5/6) is stated **by substance**, not asserted as a precise index, because the line-2
  specification was partially truncated in transmission. Operator to confirm the mapping on this Draft.

## Anchors
ADR-060 · ADR-143 / ADR-143-A / ADR-125 · ADR-120 / ADR-121 + `parallel-session-isolation` Rules 1–7 ·
ADR-056 / ADR-057 / ADR-059 / ADR-119 · ADR-153 (topology) · `docs/governance/TERMINAL-OWNERSHIP.md` (line 1/7) ·
`AGENTS.md` §Central Terminal · **#900** corrective ledger-flow runbook. Operator directive 2026-06-30 (line 2 of 7).
