# J-Engine + J-Audit — Cross-Repo Handoff & Acceptance Contract

**Status:** Spec-Locked (handoff contract) · **Date:** 2026-06-23 · **Sprint:** J · **P0**
**From (spec plane):** `CarmiBanxe/banxe-architecture` — this doc + `J-ENGINE-BUILD-SPEC.md`.
**To (implementation plane):** `CarmiBanxe/banxe-emi-stack` — the stack repo MUST implement the below.
**Perimeter (ADR-115/116/117):** this is a **specification of required work**, not a write into the
stack repo. No cross-repo commit is made from here. Additive; overwrites no MIG/closure (ADR-102/103).

> Companion to `J-ENGINE-BUILD-SPEC.md`. This file is the contract the stack repo is accepted against.

---

## 1. What `banxe-emi-stack` MUST implement (J-engine)
| # | Deliverable (stack repo) | Extends |
|---|---|---|
| J-E1 | Three-leg daily recon (Midaz ledger ↔ safeguarding accounts ↔ rails) over the existing `services/recon/` engine | IL-SAF-01 v1 (#24) |
| J-E2 | `SafeguardingAccountPort` + `RailBalancePort` adapters (CAMT.053 now; PSD2/adorsys Phase 2) | new |
| J-E3 | Penny-tolerance tie-out, I-02 jurisdiction exclusion, I-04 large-value flag, I-01 Decimal | ADR-SAF-01 |
| J-E4 | Shortfall → `HITLEscalation` (I-27), before-cut-off completion invariant | ADR-SAF-01 |
| J-E5 | `BreachNotifyPort` → n8n webhook emitting `safeguarding.breach.detected` (interface per build-spec §2.4) | new (interface only) |
| J-E6 | Config-as-data: safeguarding account IDs + `RECON_THRESHOLD_GBP` + cron `0 7 * * 1-5` (no hardcoding) | cass15.md |

## 2. What `banxe-emi-stack` MUST implement (J-audit)
| # | Deliverable (stack repo) |
|---|---|
| J-A1 | `AuditPort` append-only sink → ClickHouse `safeguarding_events` (:9000) |
| J-A2 | **Retention TTL = 5 years** (I-24); rows immutable, no UPDATE/DELETE (I-28) |
| J-A3 | FCA-producible evidence export: date-range query → structured JSON (+ FIN060 PDF via WeasyPrint) with compliance metadata |
| J-A4 | Audit entry per recon run AND per shortfall/HITL decision (`recon_run_id`, `il_ts`, balances, decision_ref) |

## 3. Acceptance / exit criteria (Definition of Done for the stack PR)
A stack-repo PR closes J-engine/J-audit only when ALL hold (mirrors IL-SAF-01 acceptance style):
- [ ] `test_three_leg_recon_balanced` (Decimal, I-01) — Midaz=safeguarding=rail within £0.01.
- [ ] `test_recon_shortfall_triggers_hitl` (I-27) — client>safeguarding ⇒ HITLEscalation; surplus no HITL.
- [ ] `test_blocked_jurisdiction_excluded` (I-02) and `test_large_value_flagged_50k` (I-04).
- [ ] `test_recon_completes_before_cutoff` (governor invariant).
- [ ] `test_audit_entry_immutable_clickhouse_5y` (I-24/I-28) — write, assert no update/delete, TTL=5Y.
- [ ] `test_fca_evidence_export` — date-range export produces FCA-producible structured report.
- [ ] `test_breach_event_contract` — `safeguarding.breach.detected` matches interface schema (idempotency key present); **no** auto-submission to FCA.
- [ ] Coverage ≥ 90%, Ruff clean, semgrep clean; LedgerPort-only (I-28, no direct HTTP).
- [ ] No KYC/KYB/AML surface touched; PROPOSED passports NOT activated (governance gate separate).

## 4. Interface contracts (exact, stack must conform)
- **Breach event** (`BreachNotifyPort` → n8n :5678 inbound): `safeguarding.breach.detected`
  `{ recon_run_id: str, il_ts: str(UTC), shortfall_gbp: Decimal-as-str, account_id: str, severity: enum, hitl_decision_ref: str, idempotency_key: str }`.
- **Audit row** (`AuditPort` → ClickHouse `safeguarding_events`): append-only; `{ recon_run_id, il_ts, leg_a_midaz, leg_b_safeguarding, leg_c_rail, status, discrepancy_gbp, hitl_decision_ref? }`; TTL 5Y.
- **Recon run** ties to **D-recon**; consumes `LedgerPort.get_balance()` (Midaz adapter).

## 5. Operator gates (NOT crossed here — STOP-if-hit)
- **Cross-repo write authorization:** producing the stack code is a separate, operator-authorized
  action in `banxe-emi-stack`. This sprint does **not** write there.
- **PROPOSED passport activation** (`safeguarding_recon_governor`, `safeguarding_audit_agent`):
  governance gate (CLASS_B, Head of Internal Audit / CRO) — not activated here.
- If either is needed to proceed → emit a one-line operator decision-brief, do not proceed.

## 6. References
`docs/safeguarding/J-ENGINE-BUILD-SPEC.md`; ADR-SAF-01; IL-SAF-01 (#24, cb49885);
`.claude/rules/cass15.md`; GAP-005 + audit-agent passports; ADR-013/102/103/115/116/117;
FCA PS25/12, CASS 15; I-01/02/04/24/27/28.
