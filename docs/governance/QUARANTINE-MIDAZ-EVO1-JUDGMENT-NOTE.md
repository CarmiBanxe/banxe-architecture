# Judgment Note — evo1/legion R0 quarantine open points

**Status:** AWAITING OPERATOR/CTIO INPUT. Not an ADR, not a ledger shard. Draft-only,
uncommitted.

## Scope

This note does **not** change, supersede, or edit
`docs/adr/ADR-QUARANTINE-MIDAZ-EVO1.md` or `ledger/entries/LEDGER-QUARANTINE-MIDAZ-EVO1.md`
in any way — those two files stay exactly as QA-verified in
`QUARANTINE-MIDAZ-EVO1-QA-REPORT.md`. This note exists solely to record the operator/CTIO
judgment on the two open points that report identified as gating ratification, so that
judgment lives in one clearly-dated place rather than being folded into the drafts
themselves.

## Point 1 — evo1 `midaz-ledger` scope: factory-only vs EMI/production relevance

**Question (from the ADR §1 OPEN POINT):** does the `evo1`-hosted `midaz-ledger`
instance referenced in `FACTORY-ROADMAP-2026-06-23.md` A6 have any project/EMI
production relevance, or is it strictly factory-internal test/dev infrastructure with no
bearing on the production EMI ledger of the same name?

**Operator/CTIO decision:**

> OPERATOR DECISION HERE

**Basis for the decision (cite evidence, do not restate the ADR):**

> OPERATOR DECISION HERE

## Point 2 — S-FAC-60 DoD interpretation: is a confirmed root cause required before quarantine is valid?

**Question (from the ADR §3 OPEN POINT):** does S-FAC-60's DoD wording — *"Root-cause for
`midaz-ledger`/`mongodb`/`workflow-service` RESTARTING documented; remediation runbook;
services GREEN ≥30 min or quarantined w/ reason in ledger"* — permit quarantine when the
root cause is documented only as ranked, unconfirmed hypotheses (current state per the
S-FAC-60 runbook), or does it require a *confirmed* root cause before the
quarantine-w/-reason exit is DoD-valid?

**Operator/CTIO decision:**

> OPERATOR DECISION HERE

**Basis for the decision (cite evidence, do not restate the ADR):**

> OPERATOR DECISION HERE

## Guidance — ratifying the existing drafts once both points are answered

Once both fields above are filled in, the existing drafts can be promoted **without any
structural edits to their content**:

1. **`keycloak`** — already assessed as safe to ratify independent of these two points (its
   decision rests only on the independent 2026-07-18 live re-verification + IL-487, neither
   of which either open point touches). No action is blocked on this note for keycloak.
2. **`midaz-ledger` / `mongodb` / `workflow-service`** — once Points 1 and 2 above are
   answered:
   - If both answers support the ADR's existing "provisional quarantine" framing as-is,
     no edit to the ADR/ledger draft content is needed — this note is the ratification
     record; proceed to step 3.
   - If either answer contradicts the draft's framing (e.g. Point 1 finds real EMI
     relevance, or Point 2 requires a confirmed cause not yet available), **do not force a
     rewrite of the existing drafts** — instead, hold the quarantine decision open, and
     route root-cause confirmation back through the existing S-FAC-60 runbook remediation
     steps before revisiting this note.
3. **Mint the real ledger shard** — in an **isolated worktree** (never the shared
   checkout), place a real shard using the existing `LEDGER-QUARANTINE-MIDAZ-EVO1.md`
   draft's content as the shard body (renamed to the `IL-<timestamp>--<slug>.md` pattern
   only at that point, not before), then run `ledger/build_ledger.py` to obtain a real,
   allocator-assigned IL number. Confirm `build_ledger.py --check` passes and the key-count
   delta is append-only (+1/0/0) before pushing.
4. **Allocate a real ADR number** for `ADR-QUARANTINE-MIDAZ-EVO1.md` per the repo's normal
   ADR-numbering convention (`docs/adr/ADR-NNN-*.md`) at the same time as the shard mint,
   referencing this judgment note and the QA report as its evidentiary basis.
5. **Open one PR** carrying the renamed/renumbered ADR + the minted shard together —
   operator merges, per standing practice; no `--admin`/`--force`/`--no-verify`.

## References (pointer-first, not restated)

`docs/adr/ADR-QUARANTINE-MIDAZ-EVO1.md` · `ledger/entries/LEDGER-QUARANTINE-MIDAZ-EVO1.md` ·
`QUARANTINE-MIDAZ-EVO1-QA-REPORT.md` · `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §0/§1/§2 ·
`docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md` ·
`docs/runbooks/S-FAC-61-health-contract-2026-07-18.md` · `INSTRUCTION-LEDGER.md` IL-487.
