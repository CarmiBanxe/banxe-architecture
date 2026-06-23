# D-Recon + E-Safeguard — Cross-Repo Handoff & Acceptance Contract

**Status:** Spec-Locked (handoff contract) · **Date:** 2026-06-23 · **Blocks:** D-recon (P1), E-safeguard (P0)
**From (spec plane):** `CarmiBanxe/banxe-architecture` — `D-RECON-BUILD-SPEC.md` + `E-SAFEGUARD-CASS15-SPEC.md`.
**To (implementation plane):** `CarmiBanxe/banxe-emi-stack` — the stack repo MUST implement the below.
**Perimeter (ADR-115/116/117):** specification of required work, **not** a write into the stack repo.
No cross-repo commit is made from here. Additive; overwrites no MIG/closure (ADR-102/103).

> Extends `docs/safeguarding/J-CROSS-REPO-HANDOFF.md` (J-E1..J-E6 / J-A1..J-A4) — **referenced, not
> duplicated.** D-recon supplies the recon engine J orchestrates; E-safeguard supplies its Leg-B accounts.

---

## 1. D-recon — what `banxe-emi-stack` MUST implement
| # | Deliverable | Extends |
|---|---|---|
| D-1 | 3-leg recon (A Midaz ↔ B safeguarding ↔ C rail) over existing `services/recon/` | IL-SAF-01 (#24), J-E1 |
| D-2 | `SafeguardingAccountPort` (Leg B) + `RailBalancePort`/StatementFetcher (CSV/CAMT.053; PSD2 Phase-2) | J-E2 |
| D-3 | `safeguarding_events` ClickHouse table (append-only MergeTree, TTL **5Y**, leg context) — single source of truth | D-RECON-DESIGN |
| D-4 | Penny/threshold tie-out (`RECON_THRESHOLD_GBP`), I-01 Decimal, I-02 exclusion, I-04 flag | ADR-SAF-01 |
| D-5 | Shortfall → `HITLEscalation` (I-27); before-cut-off invariant; cron `0 7 * * 1-5` (config) | J-E4 |
| D-6 | MLRO alert (n8n → Telegram, ≤1h) + `BreachNotifyPort` `safeguarding.breach.detected` (K-gabriel iface only) | J-E5 |

## 2. E-safeguard — what `banxe-emi-stack` MUST implement
| # | Deliverable |
|---|---|
| E-1 | Segregation-at-write: client-money posts to `client_funds`; operational debit cannot draw on it (`relevant_funds_fully_segregated`) |
| E-2 | Daily relevant-funds calc (Decimal, I-02 exclusion, I-04 flag) before cut-off (`daily_recon_completed_before_cutoff`) |
| E-3 | Shortfall ⇒ same-day top-up obligation + HITL (I-27); surplus ⇒ flagged withdrawal |
| E-4 | `SafeguardingAccountPort` exposes Leg-B balance to D-recon; config-as-data account IDs (ADR-013) |
| E-5 | Daily segregation evidence → `safeguarding_events` (TTL 5Y, I-24/I-28), FCA-producible |

## 3. Acceptance / exit criteria (Definition of Done for the stack PR)
- [ ] `test_three_leg_recon_balanced` (A==B==C, Decimal, I-01) and `test_three_leg_discrepancy_per_leg`.
- [ ] `test_shortfall_triggers_hitl` (I-27); `test_surplus_flagged_no_hitl`.
- [ ] `test_blocked_jurisdiction_excluded` (I-02); `test_large_value_flagged_50k` (I-04).
- [ ] `test_recon_completes_before_cutoff` (governor invariant).
- [ ] `test_safeguarding_events_immutable_5y` (append-only, TTL 5Y, no UPDATE/DELETE — I-24/I-28).
- [ ] `test_segregation_at_write` — operational debit cannot draw on `client_funds` (E-1).
- [ ] `test_relevant_funds_daily_calc` (E-2) and `test_mlro_alert_within_1h` + `test_breach_event_contract` (idempotency key; no FCA auto-submit).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; LedgerPort-only (I-28, no direct HTTP).
- [ ] No KYC/KYB/AML touched; PROPOSED passports NOT activated.

## 4. Interface contracts (stack must conform)
- **`SafeguardingAccountPort.get_balance(account_id, currency) -> Decimal`** (Leg B).
- **`safeguarding_events` row** (shared with J-audit): `{recon_date, account_id, account_type, currency, leg, internal_balance, external_balance, discrepancy, status, source_file}` — append-only, TTL 5Y.
- **Breach event** `safeguarding.breach.detected` `{recon_run_id, il_ts, shortfall_gbp(Decimal-str), account_id, severity, hitl_decision_ref, idempotency_key}` → n8n inbound (no FCA auto-submit).

## 5. Operator gates (NOT crossed here — STOP-if-hit)
- **Cross-repo write** to `banxe-emi-stack`: separate operator-authorized action; not done here.
- **PROPOSED passport activation** (`safeguarding_recon_governor` GAP-005, `safeguarding_audit_agent` PS25/12): CLASS_B governance gate — not activated.
- **D-RECON-DESIGN Q1–Q5** (bank, delivery, threshold, frequency, channel): operator/CEO decisions — defaults encoded as config only.
- If any is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 6. References
`docs/D-RECON-BUILD-SPEC.md`; `docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md`; `docs/safeguarding/J-CROSS-REPO-HANDOFF.md`;
`docs/D-RECON-DESIGN.md`; ADR-013/SAF-01/102/103/115/116/117; IL-SAF-01 (#24); FCA PS25/12, CASS 15, CASS 7.15; I-01/02/04/24/27/28.
