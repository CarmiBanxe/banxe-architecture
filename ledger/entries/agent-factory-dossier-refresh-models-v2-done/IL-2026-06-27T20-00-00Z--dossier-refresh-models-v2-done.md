---
il_ts: 2026-06-27T20:00:00Z
session_id: agent-factory-dossier-refresh-models-v2-done
source: CEO
status: DONE
---
### Dossier refresh — mark consumer_duty models_v2→models rename DONE (docs-plane)

- **Objective:** Update EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md to record that LIVE_MIGRATE_NEXT stream #1 (consumer_duty models_v2→models rename) landed. Additive status-only edit; original audit facts preserved verbatim. NO code changed.
- **Evidence (not memory):** EMI rename landed PR #255 / merge 78207c0 (models.py present, models_v2.py gone, 0 repo-wide refs); companion ruff-debt unblock EMI #257 / 36418d9 (pre-existing I001 fixed, repo-wide Ruff gate green). banxe-architecture origin/main @ 4f3886e IL max=613; provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Edits:** matrix row (models_v2 → DONE), stream row (DONE + #257 ref), dedupe-map (models_v2↔models unified), recommended-next item 1 (✅ DONE), new Pass-1 update log line. Remaining streams (to_minor_units, recon_v2/fin060_v2 merge-pairs, otp/sepa) stay OPEN.
- **Perimeter / canon:** docs-plane only; NO code / no prior IL or merged ADR modified; additive; build_ledger re-mints append-only; sub-B/factory → MAIN per §71/§74.
- **Refs:** dossier IL-610; EMI #255 (78207c0); EMI #257 (36418d9); ADR-119/I-28; PLAN §1A E10.
