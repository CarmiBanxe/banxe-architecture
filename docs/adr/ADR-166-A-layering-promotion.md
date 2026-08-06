---
id: ADR-166-A
title: MemoHarness layer-promotion amendment to ADR-166 — case → observed pattern → validated pattern → decision-memory
status: DRAFT
date: 2026-08-06
amends: ADR-166
relates:
  - "ADR-102 (Duplication Audit — see section below; no restate)"
  - "ADR-135-A (harness-loop amendment — provides retrieval hook that this amendment feeds)"
  - "ADR-136-A (memory-fabric amendment — read-only access envelope; promotion writes flow through existing store owners (Ledger shard-flow / reasoning_bank project append-flow), NOT through the fabric)"
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
      → **eligibility filter** (I-01..I-04 compliance pre-check; cases involving sanctions,
         blocked jurisdictions, Category B without EDD, threshold breaches are tagged
         `ineligible_for_learning` and REMAIN in case-memory for audit only, never
         entering aggregate counters)
      → observed pattern   (working-memory, N ≥ threshold instances)
      → validated pattern  (reviewed promotion, held-out adversarial safety-gate PASS)
      → decision-memory record (reasoning_bank, immutable, Art.13 explainable)

**Cross-perimeter transfer (validated → decision-memory).** This transition crosses the
factory/project perimeter (ADR-117). Direct memory access across the boundary is
forbidden by ADR-166 §5. The promotion is materialized as a reviewer-signed artifact
that transits through the **Ledger contour** (shard-flow, ADR-059): the factory-side
reviewer emits an evidence-manifest shard; the project-side reasoning_bank consumes the
shard as an authoritative append. Evidence pointers into factory-memoir require an
operator-ratified rego-rule allowing project-side read of specific evidence hashes for
Art.13 explainability — implementation-level, out of scope for this concept ADR.

(b) **Every transition passes two gates: (i) the ADR-160 orchestration write-gate**
    (branch discipline, ACTION-LEDGER, force-refspec guards — mechanical write control),
    **and (ii) a domain-level semantic promotion-gate** (evidence quality, reviewer
    authority, atomicity, idempotency — concept-level contract to be specified in the
    post-merge design-docs; see Pre-ACCEPTED gaps). No promotion write is direct;
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
  validated — such candidates are rejected at the safety-gate. Additionally,
  blocked-jurisdiction cases are tagged `ineligible_for_learning` at the
  eligibility-filter (case→observed transition) and DO NOT contribute to
  observed-aggregate counters.
- **I-03 Category B → HOLD/EDD:** promotion cannot turn this into auto-allow.
- **I-04 amount thresholds:** never substituted by a validated pattern.
- **ADR-166 authority hierarchy:** Ledger > decision-memory > working-memory — a
  promoted record still defers upward; nothing overrides the Ledger.
- **PRECOND-04 XOR:** promotion moves content BETWEEN existing role-scoped substrates;
  it creates no new substrate.

## Out of scope

- **A1** ADR-135-A (merged ✓ #1199) — the retrieval hook feeds this pipeline but is not
  modified here.
- **A2** ADR-136-A (merged ✓ #1204) — the fabric envelope is READ-ONLY total (A2
  invariant); promotion writes flow through the canonical store owners (Ledger via
  shard-flow, reasoning_bank via project append-flow), not through the fabric. This
  amendment does NOT modify A2.
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
   probes is rejected fail-closed) + reviewed promotion + the ADR-160 orchestration
   write-gate (mechanical) + the semantic promotion-gate (domain-level, concept in this
   amendment, contract in post-merge design).
5. **Decision:** ADR-166-A, DRAFT; promotion pipeline concept-only.

## Pre-ACCEPTED gaps (fail-mode registry)

> Status per operator gate: APPROVE AS CONCEPT-DRAFT. The gaps below are ACKNOWLEDGED,
> not resolved. Each carries an explicit **fail-closed default** that holds until its
> contract is specified in the post-merge design-docs; a gap may be closed only by the
> design-doc that specifies its contract. Any new gap discovered before ACCEPT is
> appended here with a fail-closed default — never left implicit.

| # | Gap (deferred contract) | Fail-closed default until specified |
|---|---|---|
| G-1 | Semantic promotion-gate contract (evidence quality, reviewer authority, atomicity, idempotency) — Decision (b)(ii) | No promotion crosses a tier boundary on the orchestration gate alone; every candidate requires explicit reviewer sign-off |
| G-2 | Eligibility-filter mechanics (tagging, audit-retention of `ineligible_for_learning` cases) — Decision (a) | Filter unavailable ⇒ ALL new cases treated as ineligible; no case→observed aggregation until the filter is back |
| G-3 | Operator-ratified rego-rule for project-side read of specific factory-memoir evidence hashes — Cross-perimeter transfer | No rule ratified ⇒ project side consumes the evidence-manifest shard only; no dereference into factory-memoir |
| G-4 | `N ≥ threshold` value for observed patterns (Configuration-over-Hardcoding — lives in repo config, not in this ADR) | Threshold unset ⇒ no case→observed aggregation occurs |
| G-5 | Held-out adversarial probe set for the safety-gate (I-01..I-04 probes: ownership, versioning, refresh cadence) | Probe set unavailable or stale ⇒ observed→validated promotion halts (Decision (e) fail-closed) |
| G-6 | Evidence pointer integrity (dangling / hash-mismatch after retention/GDPR erasure of factory-memoir content) | Any promoted record whose evidence hash fails resolution → integrity-status QUARANTINE, retrieval disabled, audit event emitted; record NOT overwritten |
| G-7 | Pattern conflict resolution (two validated patterns disagree; or a promoted record contradicts a new Ledger policy version) | Conflicting patterns → both QUARANTINE + audit event; NO silent `defer upward`; retrieval blocked until an operator-ratified resolution shard is emitted |
| G-8 | Additive-scrutiny-only invariant (memory retrieval must never reduce screening/EDD/REJECT downstream — it may only add scrutiny/HOLD) | Consumer of a promoted record MUST run the deterministic compliance path first, then optionally add scrutiny from memory; any memory-driven relaxation of a control is a canon violation and fails closed |
| G-9 | ADR-160 hook enforcement drift (documented desync between installed pre-push hook v2 union G-1..G-5+ and `scripts/pre-push-branch-name.sh` mirror; `install-hooks.sh` bootstrap silently reverts four write-gate guards) | Until the hook-sync follow-up (ADR-160 open item) is closed, promotion-related writes require verified hook parity as a manual preflight; ANY missing guard on the running hook fails the promotion closed |

## Second opinion (required by canon)

ADR-181 (Codex, blind): the amendment plan (verdict A, including the layer-mapping
delta that validated patterns land in decision-memory via reviewed promotion) carries a
blind **AGREE** — see `docs/adr/ADR-181-fable5-second-opinion-codex.md` and
the consolidated MemoHarness advisory (Fable-5 + Codex blind, ADR-181, verdict A) —
referenced pointer-first per ADR-102, NOT restated. Cross-refs:
`docs/adr/ADR-181-fable5-second-opinion-codex.md`. For this amendment the consolidated formulation
is kept explicit: **"transfer evidence ≠ transferable authority"** — promotion into a
new domain requires that domain's own held-out pass.

## Ledger anchor

IL-anchor: TBD (mint-at-merge per ADR-119 Rule 8).

## Rollback

Delete `docs/adr/ADR-166-A-layering-promotion.md` + a rollback shard in the ledger
(append-only, no history rewrite). ADR-166 itself remains unchanged and fully in force.
