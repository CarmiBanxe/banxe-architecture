---
il_ts: 2026-06-27T10:00:00Z
session_id: agent-factory-emi-legacy-rationalization-pass1
source: CEO
status: DONE
---
### EMI legacy/v2 rationalization pass #1 — read-only audit dossier (docs-plane)

- **Objective:** Persist the EMI legacy/v2 rationalization audit (live/orphan matrix + migration streams + dedupe map) as a dossier. Read-only audit; NO code changed anywhere.
- **Live audit (evidence, not memory):** banxe-emi-stack origin/main @ eb09e9c — 24 legacy/v2 modules classified LIVE_KEEP / LIVE_MIGRATE_NEXT / PARKED_REVIEW via git grep/ls-tree consumer counts. Result: 0 new safe orphan deletions (legacy SCA/TOTP already removed EMI #248/39742b7). Surface "0-live" jwks_models/jwt_strategy/legacy_abs_payment are transitively live via kept anchors role_guard (security invariant) + bifrost (to_minor_units). v2 modules (reconciliation_engine_v2, fin060_generator_v2) are LIVE merge-pairs; models_v2 = rename-debt (sole impl). consumer_duty_v2 + crypto_legacy routers mounted. banxe-architecture origin/main @ e14d30f IL max=609; provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Deliverable:** docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md (matrix, ORPHAN_REMOVE_CANDIDATE=NONE, LIVE_MIGRATE_NEXT streams, dedupe map, protected list, recommended next batch=EMPTY deletion + scoped migration PRs).
- **Protected:** role_guard (security invariant), binancekyc/bkyc (I-27 + MLRO/HITL-L4); coupled chains migrate as units. Bittrex/NeuroNext 0 footprint (E9 guard active).
- **Perimeter / canon:** docs-plane only; NO code / no destructive purge; every fact from read-only EMI audit; no prior IL/ADR modified; additive doc; build_ledger re-mints append-only; sub-B/factory hands to MAIN per §71/§74.
- **Refs:** EMI eb09e9c; EMI #248 (39742b7); ADR-126/138/108/114; PLAN §1A E10; ADR-102; ADR-119/I-28; I-20/I-24/I-27.
