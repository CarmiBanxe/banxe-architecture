# Coordination Notes (append-only)

> Append-only tracker for OPEN governance directives that cut across Terminal-A / Terminal-B /
> Central. Directives are recorded here for operator visibility; **resolution is operator-owned**.
> This file does **not** encode decisions — it enumerates open questions and their canonical
> reference-points. See `docs/canon/BEST-DECISION-BOUNDARY.md` and the referenced ADR for the
> normative treatment of each directive.
>
> **Append-only (I-24).** Directives are added with `status=OPEN`; state transitions are recorded
> as new entries below the original (never in-place mutation). Closure = a new entry with
> `status=CLOSED-ACCEPT-<variant>` (or `CLOSED-REJECT`) and a pointer to the ADR that ratified.

## Directives

### DIRECTIVE B-BESTDEC-SCOPE-001 — runtime-agent best-decide scope (OPEN)

- **status:** OPEN
- **ack-required:** operator
- **owner:** Central + operator (Terminal-B raised; ratification is operator-owned)
- **opened:** 2026-07-06
- **anchor:** `docs/canon/BEST-DECISION-BOUNDARY.md` §7; `docs/adr/ADR-162-best-decision-principle.md`
- **question:** what is the scope of best-decision INSIDE the running fabric (L2+ runtime agents)?
- **variants (unchanged text — normative reference is BOUNDARY §7):**
  - **(в-1)** best-decision only by the orchestrator (Terminal-B / Central / factory); runtime
    stays fail-closed (I-27 preserved) — **current default posture until operator ratifies**.
  - **(в-2)** runtime agent may enumerate → score → satisfice → escalate INSIDE a bounded HITL
    envelope; **no autonomy granted** even under this variant (still HITL-bounded).
- **default (until ratification):** (в-1) — fail-closed. **No runtime autonomy is introduced.**
- **guardrails (any variant):**
  - irreversibility, invariant-touching, and cross-scope drift remain **stop-barriers** — never
    "best-decided" past.
  - every runtime decision logs `correlation_id | agent_id | confidence | method | rationale`.
  - operator can revoke at any time; canon change requires a new ADR.

### DIRECTIVE B-EMI-CREDIT-GATE-001 — EMI-scope credit exclusion (pointer)

- **status:** ACTIVE (pointer only; the canonical rule lives elsewhere)
- **anchor:** the EMI-scope constraint is documented in the EMI-scope canon; this entry exists so
  the test-suite (`tests/best-decision/`) can cite a stable directive-id. See also
  `docs/canon/BEST-DECISION-BOUNDARY.md` §8 CASE-C.
- **rule (operational):** items that touch credit issuance (as opposed to EMI custody / rails /
  reporting) are **out-of-scope for BANXE adoption**. Adoption-audit hard-fails on this criterion
  regardless of the other criteria's score.

---

## Append-log conventions

- New directive → new `### DIRECTIVE <ID> — ...` block at the tail.
- State change → new block below the original (same `<ID>` in the heading, updated `status`).
- No in-place edits (I-24). No renumber (ADR-119).
- Every directive MUST anchor a canon file or ADR for the normative content — this file is an
  index, not a normative source (ADR-102).

---
## B6 — ENGINE SRC MISSING → CLOSED-ACCEPT-DRIFT-RESOLVED (2026-07-29)

status: CLOSED-ACCEPT-DRIFT-RESOLVED (was: OPEN — BLOCKED)
resolves: B6 (ROADMAP-MATRIX.md; BACKLOG-DOSSIER-2026-07-06.md §B6)

- **Drift, not loss.** B6 asserted the engine source `~/banxe-dev/emi-banxe-engine.md` is absent.
  That path is dead, but the canonical source WAS persisted per ADR-161:
  `docs/sources/emi-banxe-engine-2026-07-06.md` (49979 bytes), archived byte-for-byte.
- **Evidence:** IL archival shard
  `ledger/entries/agent-factory-knowledge-emi-banxe-engine-archival/IL-2026-07-06T20-59-00Z--emi-banxe-engine-archival.md`;
  sha256 = `9ef1b0308d9602a795b408111b1bddb3e127a9728f15b0cc4b3aea4a2257ef34` (verified).
- **Operator input no longer required** to unblock Line B: the source is in-repo (SSOT), not on a
  local absent path. B6 downgrades from Operator-blocked to Central docs-hygiene (retarget refs).
- **Follow-up (non-normative):** retarget stale pointers → `docs/ROADMAP-MATRIX.md` B6 row;
  `governance/BACKLOG-DOSSIER-2026-07-06.md` §B6. Pointer-fix only (ADR-102), append-discipline (I-24).
- This block is an index entry (ADR-102); normative source = the archived doc + its IL shard above.
