# Repo-Manifest Notes — config-as-data registry complementing #985

> **Status:** governance notes for the config-as-data repo manifest. **Additive, pointer-first (ADR-102).**
> It **complements** `CONSOLIDATION-PLAN-PHASE-2.md` (#985, prose plan) with a machine-readable registry —
> **it does NOT duplicate #985** (verified read-only: #985 is a 436-line prose plan with no data-manifest).
> It **moves/deletes/rewrites NO repo, touches no dirty checkout (Rule 6 — report only), touches no
> legal/ss1/GUYON, and bypasses no auth.**

## 1. Purpose
`config/consolidation/repo-manifest.yaml` is the **machine-readable canonical registry** for the Phase-2
consolidation — the data-file analogue of how `config/fleet/server-inventory.yaml` complements the fleet
policy prose. It records, per repo: `canonical_remote`, `role` (canonical | mirror | archive | external),
`local_paths` / `archive_paths`, `perimeter_class` (banxe | external | EXCLUDED), `dirty_uncommitted`, and
`last_commit_date`. **Derived from the operator consolidation-recon (2026-07-03), read-only; a point-in-time
snapshot.**

- **Extends, not duplicates:** `docs/governance/CONSOLIDATION-PLAN-PHASE-2.md` (#985) is the prose plan /
  execution contract; this manifest is its **data layer**. Verified (Step 0): #985 carries no machine-readable
  canonical list — so the manifest is complementary.
- **Cleanup is #987's:** the `~/banxe/*`, `/tmp/banxe-arch-temp`, `~/wt/temp-clone` duplicates are labelled
  `role=archive` here — **a label, not a delete.** The actual stale-clone cleanup is owned by
  `#987 (stale-clone cleanup plan for Legion)`; this manifest only *records* them.

## 2. Rule-6 PRECONDITION — commit/stash dirty repos BEFORE any move
> **Hard precondition for #985's Sprint-1 execution. Nothing in this PR moves any repo; this is the gate that
> must clear first, operator-side.**

Six canonical/external checkouts carry **uncommitted work** that a consolidation move would destroy. The
operator MUST commit or stash each **before** any relocation — **nothing is moved blind:**

| Repo | Uncommitted | Class |
|---|---|---|
| `banxe-emi-stack` | **59** | banxe |
| `AMLGentex` | **54** | external (3rd-party checkout — review, don't just commit) |
| `MiroFish` | **37** | banxe |
| `banxe-ui` | **29** | banxe |
| `MetaClaw` | **10** | banxe |
| `banxe-architecture` | **5** | banxe (operator-owned local; incl. `.gitignore` — Rule 6, not touched) |

These are **operator-owned local states** — this PR reports them (Rule 6), it does not commit, stash, or
resolve them.

## 3. ORCHESTRATION-NOTICE (to Central + Right terminals)
- **Canonical = `CarmiBanxe/*` remotes** (per the recon). The `~/` root checkouts are the working canonical
  copies; `~/banxe/*`, `/tmp/*`, `~/wt/temp-clone` are **archive duplicates** (label only).
- **External repos** (`AMLGentex`=aidotse, `AMLSim`=IBM, `OpenRLHF`, `llama.cpp`=ggml-org, `claude-code`=
  instructkr) are **`perimeter_class: external`, `consolidate: false`** — vendor/reference, not ours to merge.
- **EXCLUDED contour** — `legal-canon`, `legal-case-guyon-laval`, `ss1`, `legal-reference-fr` =
  **`perimeter_class: EXCLUDED` (I-18/I-20)**, `consolidate: false`, **never read or consolidated with Banxe.**
- **Coordination with #985:** this manifest is the data layer of #985's plan; **no conflict** — #985 owns the
  execution contract, #987 owns cleanup, this owns the registry data. No terminal's work is overwritten.

## 4. Boundaries
- **0 repos moved / deleted / rewritten.** Mirrors are `role=archive` labels; cleanup is #987's.
- **No dirty checkout touched** (Rule 6 — report only). **No legal/ss1/GUYON read or consolidated** (EXCLUDED).
- **#985 not duplicated** (Step 0 verified prose-only); **no auth bypassed**; data derived from the operator's
  read-only recon.

## 5. Changelog
- **v1.0.0 (2026-07-03):** initial manifest — canonical CarmiBanxe/* + external + EXCLUDED (I-18/I-20);
  Rule-6 dirty precondition (6 repos); ORCHESTRATION-NOTICE. Point-in-time snapshot of the 2026-07-03 recon.
  *(Append future revisions below; do not rewrite prior entries — append-only, per ledger discipline.)*

## Anchors
`docs/governance/CONSOLIDATION-PLAN-PHASE-2.md` (#985 — the prose plan this manifest is the data layer of;
**extended, not duplicated**) · `#987` (stale-clone cleanup — executes the archive-dedup this only labels) ·
`config/fleet/server-inventory.yaml` (#959 — the config-as-data precedent this mirrors) · CLAUDE.md §10
(Config-over-Hardcoding) · `.claude/rules/parallel-session-isolation.md` Rule 6 (dirty-state report-not-resolve)
· CLAUDE.md I-18/I-20 (legal/ss1/GUYON separation — EXCLUDED) · ADR-102 (Duplication Audit — Step 0 read of
#985 confirms no duplication). Operator directive 2026-07-03 (config-as-data repo manifest complementing #985;
move/delete nothing; Rule-6 report; I-18/I-20 exclude; notify terminals).
