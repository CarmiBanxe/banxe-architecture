# EMI-stack implementation-state — authoritative decision doc

> **Type:** authoritative implementation-state truth for `banxe-emi-stack` + the strategic
> consequence for the right-terminal (quality/L2) track. **Docs-plane only** — no runtime, no
> secrets, nothing implemented here.
> **Canon:** factory-only; shell = read-only audit; ADR-102; ADR-119/I-28 append-only;
> live-verified (no memory). Aggregator — references IL-516 / IL-522 / IL-535; overwrites nothing.

---

## 0. Live-audit baseline (re-verified, not memory)

| Item | Value (live) |
|---|---|
| `banxe-emi-stack` origin/main | `ebfeac6` (audited 2026-06-26) |
| `banxe-architecture` origin/main | `02d3cc3` (IL max 535) |
| Method | per-service `git grep NotImplementedError` + `def`/`def test_` counts on origin/main (read-only) |
| Migration phase | **CLOSED** — residual legacy-derived genuine-gap = 0 (IL-516); 4 SAR modules resolved (IL-522) |
| safeguarding-engine test-green | **STOP** (IL-535): runtime unimplemented; test-green needs Phase-3.6 build |

---

## 1. Stub-density truth (services carrying `NotImplementedError`, origin/main)

19 services carry runtime stubs. Counts are mechanical (`git grep NotImplementedError`).

| Service | py | stubs | test funcs | Reality verdict |
|---|---|---|---|---|
| `safeguarding-engine` (P0 CASS 15) | 52 | **40** | 34 | **SPEC-LOCKED-STUB** (tests-ahead-of-runtime; IL-535) |
| `fx_engine` | 9 | 15 | 0 | SPEC-LOCKED-STUB |
| `ledger` | 20 | 12 | 0 | SPEC-LOCKED-STUB |
| `complaints` | 8 | 8 | 0 | SPEC-LOCKED-STUB |
| `compliance` | 9 | 7 | 0 | PARTIAL (real defs + stubs) |
| `payment` | 19 | 4 | 0 | SPEC-LOCKED-STUB (scaffold) |
| `kyb_onboarding` | 8 | 4 | 0 | SPEC-LOCKED-STUB |
| `fraud_tracer` | 5 | 4 | 0 | SPEC-LOCKED-STUB |
| `backup` | 8 | 4 | 0 | SPEC-LOCKED-STUB |
| `fatca_crs` (F-fatca) | 6 | 3 | 0 | SPEC-LOCKED-STUB |
| `consumer_duty` | 10 | 3 | 0 | SPEC-LOCKED-STUB |
| `client_statements` | 6 | 3 | 10 | **PARTIAL** (stubs + real tests) |
| `auth` | 30 | 3 | 0 | PARTIAL (mostly real, few stubs) |
| `reporting` | 6 | 2 | 0 | SPEC-LOCKED-STUB |
| `observability` | 5 | 2 | 0 | SPEC-LOCKED-STUB |
| `fraud` | 6 | 2 | 0 | SPEC-LOCKED-STUB |
| `transaction_monitor` | 20 | 1 | 0 | PARTIAL (mostly real) |
| `psd2_gateway` | 5 | 1 | 0 | PARTIAL |
| `agreement` | 3 | 1 | 0 | PARTIAL |

## 2. REAL + TESTED surfaces (0 stubs, substantive logic + tests) — do NOT overstate stub-ness

| Service(s) | py | stubs | Evidence | Verdict |
|---|---|---|---|---|
| **F-aml**: `aml` (44 defs), `sanctions_screening` (60), `compliance_automation` (83), `adverse_media` (8), `crypto_aml_graph` (17) | 37 | **0** | real logic (`requires_edd`, `requires_sar_consideration`, velocity-breach checks, Decimal thresholds); **203 AML/compliance test functions** at repo-level `tests/` (test_aml_thresholds, test_compliance_automation/*, test_sanctions_screener, e2e_compliance_flow) | **REAL + TESTED** — corroborates ROADMAP "F-aml ~80% DONE" |
| `reporting_analytics` | 10 | 0 | 11 test functions | **REAL + TESTED** |

> **STOP-CONDITION honoured:** F-aml is genuinely real+tested (0 stubs, 203 tests) — recorded as
> REAL, not stub. Stub-density is reported only where `NotImplementedError` is actually present.

## 3. ROADMAP claim vs reality (verified rows)

| ROADMAP claim | Reality (live) |
|---|---|
| **F-aml ~80% DONE** | **Corroborated** — core AML services 0 stubs + 203 tests |
| safeguarding (E-safeguard / D-recon) Spec-Locked — In Progress | **Spec done, runtime STUB** (40 NotImplementedError; IL-535) |
| Most P0/P1 "Spec-Locked — In Progress" | **Accurate** — specs exist; runtime predominantly Phase-3.6 stubs (19 services) |

---

## 4. Consequence (strategic decision)

1. **Migration is done** (IL-516 genuine-gap=0; IL-522 SAR resolved). There is no remaining
   legacy-port work.
2. **The right-terminal "quality / L2" track is now a per-service RUNTIME feature-build** —
   Phase-3.6 business logic — **not** tests-only remediation. The safeguarding-engine STOP
   (IL-535) is the canonical proof: fixing test-authoring defects only moves tests to a
   `NotImplementedError` wall; green requires implementing the service.
3. **Regulatory P0 surfaces are operator-gated runtime features**, not factory-autonomous:
   - `safeguarding-engine` (CASS 15), `fatca_crs` (F-fatca), `consumer_duty`, `ledger`/`payment`
     core — implementing these is governance/**I-27**-gated and requires **operator
     prioritization** (client-funds / production-state impact; CLAUDE.md §11).
   - F-aml is already REAL+TESTED → its track is hardening/coverage, not greenfield build.
4. **Recommended sequencing (operator decides):** prioritise P0 CASS-15 `safeguarding-engine`
   runtime (E-safeguard/D-recon) + `fatca_crs` + `ledger`/`payment` core; each as a scoped,
   I-27-gated runtime build with its own IL, followed by aligning the already-authored tests to
   the implemented API.

> **Not implemented here.** This doc is the decision artifact only; no runtime is built, no
> service is prioritised without operator sign-off.

### Refs
IL-516 (residual genuine-gap=0), IL-522 (SAR modules resolved), IL-535 (safeguarding test-green STOP);
`banxe-emi-stack` origin/main `ebfeac6` (`services/*`); ADR-102, ADR-119; I-27, CLAUDE.md §11.
