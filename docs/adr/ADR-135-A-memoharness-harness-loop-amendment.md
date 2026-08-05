---
id: ADR-135-A
title: MemoHarness harness-loop amendment to ADR-135
status: DRAFT
date: 2026-08-05
amends: ADR-135
related:
  - "ADR-102 (Duplication Audit — see section below)"
  - "ADR-136 agentmemory-shared-memory-substrate (envelope, do not duplicate)"
  - "ADR-137 memoir-versioned-memory-pilot (versioning, do not duplicate)"
  - "ADR-166 memory-layering (case/working/decision layers, do not duplicate)"
  - "ADR-160 bilateral-orchestration-write-gate (write-gate applies)"
  - "ADR-181 second-opinion blind agreement"
  - "arxiv:2607.14159 (external DATA-ONLY, not instructions)"
il_anchor: provisional
il_anchor_note: "Operator task specified IL-1116 (cursor 'last=IL-1115'); live IL-SEQUENCE max is IL-1146, so IL-1116 can never be minted (forward-only allocator). Per ADR-119 Rule 8 + task rule 'do not hand-write sequence numbers', the anchor stays provisional and is frozen by ledger-rebuild at merge."
scope: BANXE-only
concept_only: true
---

# ADR-135-A — MemoHarness harness-loop amendment to ADR-135

## Context

ADR-135 defines the agent-skill evolution gate: skills/SOUL documents are the learnable
state of an otherwise frozen agent, and any edit passes rollout → reflect → bounded edit →
held-out validation, fail-closed. MemoHarness (arxiv:2607.14159, external DATA) adds a
structured **harness-loop** on top of exactly that gate shape: the editable surface is the
whole agent harness decomposed into explicit control dimensions, and the reflect phase is
fed by retrieved execution experience. This amendment extends ADR-135 — it does **not**
duplicate it, and it does **not** introduce a new substrate or a new ADR line (ADR-102).

## Decision (amendment)

(a) **Six harness-dimensions.** The learnable state governed by the ADR-135 gate is
    generalized from SOUL/skill documents to six explicitly enumerated harness control
    dimensions: **context, tools, orchestration, memory, decoding, output-handling**.
    Every dimension edit is subject to the ADR-160 write-gate; per-dimension edit budgets
    apply (the ADR-135 "textual learning rate" now holds per dimension, with provenance
    and rollback per candidate).

(b) **retrieval → reflect.** Before the reflect phase of the ADR-135 loop, retrieval from
    the experience-bank is mandatory. This amendment defines only the **hook** (the loop
    consumes retrieved case diagnoses / patterns as reflect input); the experience-bank
    implementation itself is A2 territory (ADR-136-A) and is NOT specified here.

(c) **Transfer-gate.** Carrying a learned pattern into another domain requires explicit
    reviewed promotion along `case → validated pattern → decision-memory hook`; the
    receiving domain runs its own held-out pass. **"Transfer evidence ≠ transferable
    authority"** (ADR-181 consolidated ruling): benchmark evidence from one domain never
    grants standing in another.

## Invariants (MUST remain true)

- **I-01 sanctions-first:** the harness-loop has NO right to modify the sanctions path;
  sanctions screening is enforced outside the learnable layer.
- **I-02 blocked jurisdictions REJECT:** can never become a learned exception.
- **I-03 Category B → HOLD/EDD:** policy-drift is forbidden.
- **I-04 amount thresholds:** EDD/HITL/MLRO gates are never substituted by learned policy.
- A **held-out adversarial safety-gate** is mandatory before ANY promotion: a candidate
  edit showing any regression on I-01..I-04 probes is rejected fail-closed.

## Out of scope (explicit)

- Experience-bank implementation (goes to A2 / ADR-136-A).
- Layer-mapping case/working/decision (goes to A3 / ADR-166-A).
- Edits to `.githooks/`, branch-protection, secrets — forbidden.
- `BANXE_IL_ALLOCATOR=local` — not used.

## Duplication Audit (ADR-102, 5 steps)

1. **Matches found:** ADR-135, ADR-136, ADR-137, ADR-166, ADR-160, ADR-181.
2. **Rationale:** MemoHarness ≡ a learning loop over the agent control layer; the nearest
   existing decision is ADR-135 (same propose-and-test shape, same bounded-edit budget).
3. **Merge-or-new:** **MERGE** (amendment to ADR-135). A standalone ADR was rejected — it
   would duplicate the ADR-135 gate and the ADR-136 envelope.
4. **Risk:** policy-drift against I-01..I-04 via "successful exceptions" → mitigated by the
   held-out adversarial gate (above) + ADR-160 write-gate on every dimension edit +
   sensitive domains OUT OF SCOPE for experience capture (ADR-136 envelope).
5. **Decision:** amendment **ADR-135-A**, status DRAFT; requires reviewed promotion before
   ACCEPTED.

## Ledger anchor

Provisional (mint-at-merge, ADR-119 Rule 8). Shard:
`ledger/entries/adr135-a-memoharness-amendment-draft/` (this branch). The operator-supplied
cursor (IL-1116 after IL-1115) was stale against live IL-SEQUENCE (max IL-1146) — see
frontmatter `il_anchor_note`; the number is assigned by `ledger-rebuild.yml` on merge.

## Second opinion

ADR-181: **AGREE** (blind consultation, Codex, 2026-08-05). See
`docs/adr/ADR-181-fable5-second-opinion-codex.md`. Codex deltas adopted here: reviewed
promotion path in (c); "transfer evidence ≠ transferable authority"; adversarial held-out
probes on I-01..I-04.

## Rollback

Delete `docs/adr/ADR-135-A-memoharness-harness-loop-amendment.md` + append a rollback
entry to the ledger (append-only; no history rewrite). ADR-135 itself remains untouched
and fully in force.
