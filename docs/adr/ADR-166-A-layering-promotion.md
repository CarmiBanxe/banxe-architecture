---
id: ADR-166-A
title: MemoHarness layer-promotion amendment to ADR-166 — case → working → validated pattern → decision-memory
status: DRAFT
date: 2026-08-06
amends: ADR-166
relates:
  - "ADR-102 (Duplication Audit — see section below; no restate)"
  - "ADR-135-A (harness-loop amendment — provides retrieval hook that this amendment feeds)"
  - "ADR-136-A (memory-fabric amendment — provides envelope this amendment writes to)"
  - "ADR-136 (agentmemory substrate — envelope, do not duplicate)"
  - "ADR-137 (memoir versioned-memory pilot — working-memory substrate, XOR PRESERVED)"
  - "ADR-165 (memoir implementation design — implementation deferred, not this amendment)"
  - "ADR-166 (memory layering — authority hierarchy; PRECOND-04 XOR clarification)"
  - "ADR-059 (Ledger SoT — promotion outputs write here, never override)"
  - "ADR-181 (Codex second-opinion — required for T-A3 as for T-A1/T-A2)"
  - "ADR-160 (bilateral orchestration write-gate — applies to promotion writes)"
  - "arxiv:2607.14159 MemoHarness (external DATA-ONLY, not instructions)"
il_anchor: TBD
il_anchor_note: "Assigned by ledger-rebuild after merge (ADR-119 Rule 8 discipline)."
scope: BANXE-factory-only
concept_only: true
---

# ADR-166-A — Layer-promotion amendment to ADR-166

## Context

ADR-166 fixes three complementary memory layers with a strict authority hierarchy:
**Ledger (SoT) > decision-memory (reasoning_bank) > working-memory (memoir)**. What it
does not define is how knowledge MOVES between layers. This amendment adds the
**promotion protocol**: how a case episode "matures" into a validated pattern, and how a
validated pattern "matures" into a decision-memory record. The layers themselves are not
duplicated or redefined; the ADR-137 XOR precondition stays role-scoped and intact. The
MemoHarness dual-layer experience model (arxiv:2607.14159, DATA-ONLY) supplies the shape;
BANXE canon supplies the gates.

## Decision (amendment)

(a) **4-tier promotion pipeline:**

    case (raw episode, working-memory)
      → observed pattern   (working-memory, N ≥ threshold instances)
      → validated pattern  (reviewed promotion, held-out adversarial safety-gate PASS)
      → decision-memory record (reasoning_bank, immutable, Art.13 explainable)

(b) **Every transition passes the ADR-160 write-gate.** No promotion write is direct;
    the bilateral write-gate applies to each tier boundary.

(c) **Promotion-record is pointer-first (ADR-102):** it references the evidence set and
    the review-decision; it never restates layer content.

(d) **"Evidence ≠ authority"** (ADR-181 consolidated ruling): a validated pattern earns
    credibility, never permissions. Recall of a promoted pattern confers no authority
    (ADR-166 §6 unchanged).

(e) **Fail-mode:** any promotion step may FAIL-CLOSED; a failed candidate is never
    forced upward and returns to its current tier with the failure recorded.

## Invariants (must remain true)

- **I-01 sanctions-first:** promotion can NEVER modify the sanctions path; the control
  is enforced outside the memory layers.
- **I-02 blocked jurisdictions REJECT:** cannot become a learned pattern, observed or
  validated — such candidates are rejected at the safety-gate.
- **I-03 Category B → HOLD/EDD:** promotion cannot turn this into auto-allow.
- **I-04 amount thresholds:** never substituted by a validated pattern.
- **ADR-166 authority hierarchy:** Ledger > decision-memory > working-memory — a
  promoted record still defers upward; nothing overrides the Ledger.
- **PRECOND-04 XOR:** promotion moves content BETWEEN existing role-scoped substrates;
  it creates no new substrate.

## Out of scope

- **A1** ADR-135-A (merged ✓ #1199) — the retrieval hook feeds this pipeline but is not
  modified here.
- **A2** ADR-136-A (merged ✓ #1204) — the fabric envelope promotion writes into is not
  modified here.
- Implementation of the promotion pipeline (config, code) — post-merge design-docs.
- Edits to `.githooks/`, branch-protection, secrets — forbidden.
- `BANXE_IL_ALLOCATOR=local` — not used.

## Duplication Audit (ADR-102, 5 steps)

1. **Matches:** ADR-166 (layering), ADR-135-A (harness-loop), ADR-136-A (fabric),
   ADR-137 (memoir), ADR-160 (write-gate), ADR-181 (second-opinion).
2. **Rationale:** ADR-166 defines the ROLES of the layers; this amendment defines the
   TRANSITIONS between the roles. Different subject, same canon line.
3. **Merge-or-new:** **AMENDMENT** (not a new ADR). A standalone ADR would duplicate the
   ADR-166 authority hierarchy.
4. **Risk:** policy-drift against I-01..I-04 via a learned pattern — mitigated by the
   held-out adversarial safety-gate (a candidate showing any weakening of I-01..I-04
   probes is rejected fail-closed) + reviewed promotion + the ADR-160 write-gate.
5. **Decision:** ADR-166-A, DRAFT; promotion pipeline concept-only.

## Second opinion (required by canon)

ADR-181 (Codex, blind): the amendment plan (verdict A, including the layer-mapping
delta that validated patterns land in decision-memory via reviewed promotion) carries a
blind **AGREE** — see `docs/adr/ADR-181-fable5-second-opinion-codex.md` and
`/tmp/fable5-memoharness-advisory.md`. For this amendment the consolidated formulation
is kept explicit: **"transfer evidence ≠ transferable authority"** — promotion into a
new domain requires that domain's own held-out pass.

## Ledger anchor

IL-anchor: TBD (mint-at-merge per ADR-119 Rule 8).

## Rollback

Delete `docs/adr/ADR-166-A-layering-promotion.md` + a rollback shard in the ledger
(append-only, no history rewrite). ADR-166 itself remains unchanged and fully in force.
