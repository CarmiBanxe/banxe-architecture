# Banksy Memory Integration Map — MemoHarness feature → engine modules — 2026-08-09

**BANK CORE / MEMORY INTEGRATION MAP / DOCS-ONLY / READ-ONLY RUNTIME / NO CODE ASSEMBLED HERE**

Reciprocal Banksy-side artifact to **ADR-182** (factory side). ADR-182 bound the merged MemoHarness
amendments to the Banksy engine as a second consumer and promised a Banksy-side map plus a GL-line
entry; this document and `docs/audit/GL-POST20-MEMOHARNESS-INTEGRATION-2026-08-09.md` are that
reciprocation. **Concept only** — nothing is wired, no module is modified, no gate is added.

## Purpose

Record which Banksy engine module would consume each factory-side MemoHarness concept, so that a
future activation has a written target instead of an improvised one. The factory owns the feature;
Banksy is the second consumer. Naming the consumer now is what keeps a later activation reviewable.

## Mapping

| MemoHarness concept (factory ADR) | Banksy consumer (verified present) | Status |
|---|---|---|
| Harness-loop, 6 dimensions — ADR-135-A | `runtime/banksy/main.py` — engine entrypoint / orchestration surface | conceptual — not wired |
| Memory-fabric read-only envelope — ADR-136-A | `runtime/banksy/harvest/memory.py` — read consumer only; the store itself stays factory-owned and is reached through the envelope, never directly | conceptual — not wired |
| Layer-promotion pipeline (case → observed → validated → decision) — ADR-166-A | Banksy implements its **own** pipeline inside its own zone | conceptual — A3 supplies the *shape*, not the code; see the invariant below |
| Integration adapter contract — ADR-182 | Banksy-side gating via the existing GL-\* sequence + HITL-L4 (I-27) | conceptual — this map + the GL-POST20 entry |

Every module named above was verified present on `main` at `a9bc00d6`; this table points at real
files, not planned ones.

## Gate placement

No new gate is introduced on the Banksy side. Any future activation of a MemoHarness pattern runs
through the sequence already defined in `runtime/BANKSY-BUILD-MANIFEST.md` §Gate order:

> Reviewer (per module) → Canon-Guardian (no forbidden, compiled_over_legion=false,
> no-silent-rewrite) → Factory-Watchdog (0 secrets, process live, port 8200 listening) →
> install-audit → HITL-L4 (I-27).

MemoHarness maps onto those existing gates rather than adding to them — the promotion transitions
become things the current gates already have authority to refuse.

## Cross-perimeter invariants

These come from the factory-side ADRs and are restated here only as constraints on the Banksy
consumer; the ADRs remain the normative source.

- **Separate substrates.** ADR-166 §Decision: *"there is **no cross-perimeter memory**. Coexistence
  is *across perimeters*, never a shared substrate."* Factory memoir and project reasoning_bank stay
  apart, and Banksy's own memory is a third independent contour. The pipeline shape is shared; the
  data is not.
- **Read-only envelope.** The ADR-136-A fabric is read-only in total. Writes flow through the
  canonical store owners (Ledger shard-flow, reasoning_bank append-flow) — never through the fabric.
- **Own inference.** Banksy calls `${BANKSY_INFERENCE_URL}` via the bank gateway, never Legion's
  private `:8080`; `direct_legion_infer = false` in `runtime/banksy-engine.config.toml` stays as is.
  MemoHarness does not change this.

## What this document is not

It is not an activation, not a schedule, and not a claim that any integration exists. ADR-182 is
`status: DRAFT` with `concept_only: true`, and this map inherits that standing. Activation requires
a separate ADR after the fabric implementation exists, plus the gate sequence above.

## Related documents

- `docs/adr/ADR-182-memoharness-banksy-binding.md` — the factory-side anchor this reciprocates
- `docs/adr/ADR-135-A-memoharness-harness-loop-amendment.md` — harness-loop concept
- `docs/adr/ADR-136-A-memory-fabric.md` — read-only access envelope
- `docs/adr/ADR-166-A-layering-promotion.md` — promotion pipeline + activation blockers G-1..G-9
- `docs/audit/GL-POST20-MEMOHARNESS-INTEGRATION-2026-08-09.md` — GL-line entry for this reciprocation
- `bank-rooms/F0-engine-manus-room/runtime/BANKSY-BUILD-MANIFEST.md` — gate order quoted above
- `bank-rooms/F0-engine-manus-room/BANKSY-ENGINE-INTEGRATION-PLAN.md` — Banksy zone plan

---
**This does not replace legal advice.**
