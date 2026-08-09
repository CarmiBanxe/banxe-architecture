# GL-post-20 — MemoHarness Reciprocal Binding Report — 2026-08-09

**BANK CORE / GL-post-20 MEMOHARNESS BINDING / DOCS-ONLY / CONCEPT-ONLY / NO CODE / NO ACTIVATION**

## Status: **RECIPROCATED — docs-only; no wiring, no gate change**

ADR-182 bound the merged MemoHarness amendments to the Banksy engine as a second consumer and
promised a Banksy-side artifact in return. That promise is now discharged: the map exists, it names
real modules, and this GL entry records the fact on the GL-20 line. **Nothing was activated.** The
engine on `:8200` was not touched, no module was modified, no gate was added or altered.

## What was reciprocated

| Factory side (merged) | Banksy side (this entry) |
|---|---|
| ADR-135-A harness-loop — #1199 `f9e90d42`, IL-1148 | mapped → `runtime/banksy/main.py` |
| ADR-136-A memory-fabric — #1204 `8ce6376c`, IL-1147 | mapped → `runtime/banksy/harvest/memory.py` (read consumer) |
| ADR-166-A layer-promotion — #1212 `ed99da5c`, IL-1151 | Banksy implements its own pipeline; shape only |
| ADR-182 binding — #1217 `40942d25`, IL-1152 | this GL entry + `MEMORY-INTEGRATION-MAP.md` |
| Bidirectional cross-refs — #1218 `1474372c`, IL-1153 | already landed in the three BANKSY-\* docs |

## ШАГ 0 — snapshot

- Base: `origin/main` = `a9bc00d6` (after the T-G9-CI merge).
- Isolated worktree off that base; the main checkout and its uncommitted Sprint-0 state untouched.

## ШАГ 1 — module verification (measured, not assumed)

Every module named in the map was confirmed present on `main` before being written down:

- `runtime/banksy/main.py` — present
- `runtime/banksy/engine.py` — present
- `runtime/banksy/harvest/memory.py` — present

`BANKSY_INFERENCE_URL` was confirmed as the actual variable in `runtime/banksy-engine.config.toml`,
alongside `direct_legion_infer = false`. A map that points at modules which do not exist is worse
than no map, so this step preceded any writing.

## ШАГ 2 — map authored (docs-only)

`bank-rooms/F0-engine-manus-room/MEMORY-INTEGRATION-MAP.md` — consumer mapping, gate placement,
cross-perimeter invariants, and an explicit "what this is not" section so the document cannot be
read as an activation.

## Gates

- **No new gate.** The map places MemoHarness onto the existing sequence from
  `BANKSY-BUILD-MANIFEST.md` §Gate order: Reviewer → Canon-Guardian → Factory-Watchdog →
  install-audit → HITL-L4 (I-27).
- **I-27 preserved.** Nothing here grants autonomous write authority; the engine remains
  proposes-only, exactly as recorded in the 2026-07-25 prod-inference entry on this same line.
- **No cross-perimeter memory.** ADR-166 §Decision holds: factory memoir, project reasoning_bank and
  Banksy's own memory stay three separate substrates. Only the pipeline *shape* is shared.

## Rollback

Two new documents and one ledger shard. Reverting the merge commit removes all of it; no runtime
state, configuration, or gate depends on this entry.

## Gated / open

- **Activation** remains gated behind a separate ADR after the fabric implementation exists — ADR-182
  is `status: DRAFT`, `concept_only: true`, and this entry does not change that standing.
- **Banksy's own promotion pipeline** is not written. ADR-166-A supplies the shape; the code is a
  Banksy engineering step inside its own zone, subject to the gate order above.
- **ADR-166-A activation blockers G-1..G-9** stay open on the factory side; G-9 (hook-parity) now has
  CI visibility via `guardian-hook-parity` (#1220, `a9bc00d6`) but is still advisory, not enforced.

---
**This does not replace legal advice.**
