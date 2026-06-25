---
il_ts: 2026-06-26T16:00:00Z
session_id: agent-factory-sub-b-finrpt-content-core
source: CEO
status: DONE
---
### F-finrpt (GAP-007) FIN-RPT content-core implemented + GAP-006 submission fence (banxe-emi-stack)

- **Objective:** Implement the F-finrpt regulatory-returns CONTENT CORE in banxe-emi-stack services/reporting (the producer behind K-gabriel's FinRepSourcePort), Decimal-only, content-versioned/immutable, derived read-only from ledger/recon/safeguarding; FENCE submission to K-gabriel (GAP-006), zero gabriel/* duplication. Per F-FINRPT-BUILD-SPEC (IL-481).
- **Live audit (source of truth, not memory):** banxe-emi-stack origin/main@a7596d1; branch agent/factory/finrpt/content-core (pushed, SSH-signed). banxe-architecture origin/main@f96771d IL max=541 → this provisional max+1=IL-542 (Rule 8 frozen-at-merge; MAIN regenerates). Read F-FINRPT-BUILD-SPEC §0-§9 + services/gabriel/* (returns_governor/regdata_gabriel_adapter/gabriel_models) + services/recon/fca_regdata_client to confirm the submission boundary.
- **ADR-102 dup-check (CRITICAL here):** grep confirmed NO pre-existing FinRepContentProvider / ReturnContentSet / get_return_content in services/api/src → content-core is non-duplicative. K-gabriel references FinRepSourcePort (gabriel_models.py:8 comment) but defines no producer; F-finrpt supplies it. services/gabriel/* submission/breach/governance NOT touched/duplicated. Existing fin060_generator_v2 (BT-006 stub, has its own test) + regdata_return (separate FIN060 RegData pipeline) left untouched.
- **Implemented (new file services/reporting/finrep_content_core.py):**
  - Model (§3): LineItem (Decimal-only, I-01 enforced in __post_init__), ReturnContentSet (frozen/immutable, version, content_hash, source_refs, status DRAFT|VALIDATED|FINAL).
  - Ports (§5): LedgerPort / ReconSourcePort / SafeguardingTotalsPort / ReturnContentStore (Protocols) + in-memory adapters (InMemoryReturnContentStore append-only, _DictSource). Read-only derivation; no write-back.
  - FinRepContentProvider (§4, producer of FinRepSourcePort): assemble → validate (cross-foot: client_funds_total − safeguarded_total == recon_difference; period continuity) → finalize (versioned, immutable, hashed); get_return_content returns FINAL only (raises LookupError on draft — K-gabriel must not submit draft); list_available(period). compute_content_hash deterministic (pin/idempotent submit).
  - Config-as-data: DEFAULT_ITEM_REGISTRY (item-code → line-item derivation; injectable), aligned to K-gabriel fca_item_code "FIN060-MONTHLY".
- **FENCED (NOT implemented — GAP-006/K-gabriel):** submission/breach-reporting/deadline-tracking/sign-off. provider.submit() raises SubmissionFencedError referencing K-gabriel/GAP-006. Test asserts the content-core imports no RegData/gabriel/http transport.
- **Tests (tests/test_finrep_content_core.py, 10 real tests = all 7 DoD §6 + 2 defensive + sanity):** decimal-only, derived-read-only (source dict unchanged), validation rules (cross-foot/period/unknown-code/unknown-source), immutable-after-final (FrozenInstanceError + append-only store), content_hash stable-per-version, FINAL-only producer, no-submission-fence. **Coverage of content-core module = 100%** (131 stmts, 0 missing); ruff + semgrep (banxe-rules + p/default) exit 0. No padding; gate not weakened.
- **STOP-CONDITION check:** content-core implementable without any submission/breach logic; spec boundary clear; did NOT cross into K-gabriel GAP-006; zero gabriel/* duplication.
- **Perimeter / canon:** read-only derivation (no ledger/recon write-back, I-28); Decimal-only (I-01); no KYC/KYB/AML; no GAP-018 governance; additive 2 new files only (no existing file edited); isolated branch off emi origin/main; signed; sub-B hands to MAIN per §71/§74 (does NOT open emi PR).
- **Deliverable:** banxe-emi-stack branch agent/factory/finrpt/content-core (services/reporting/finrep_content_core.py + tests/test_finrep_content_core.py).
- **Refs:** docs/regulatory/F-FINRPT-BUILD-SPEC.md (IL-481); K-GABRIEL-BUILD-SPEC §3 FinRepSourcePort; services/gabriel/*; ADR-102/103/013/115-119; I-01/I-24/I-28.
