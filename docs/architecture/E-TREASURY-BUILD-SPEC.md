# E-TREASURY — Treasury Management Build-Spec (liquidity, FX positions, ALM)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-25 · **Block:** E-treasury · **Priority:** P2 · **Sprint:** 12 · **Promotes:** the 0% (operationalises ADR-078 treasury/forecast ports).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines the treasury-management contract**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> ⚠️ **SCOPE/HITL FENCE (read §8 first).** E-treasury is **operational treasury management** (liquidity, FX
> positions, ALM) **for the firm only** — **NOT** investment advice, **NOT** financial advice, **NOT** a
> client-facing trading/dealing desk, **NOT** autonomous trading. **Specification only**: the factory runs no live
> treasury, executes no trades. Per ORG: **TreasuryAgent = L2 Review**; treasury decisions over a threshold
> (config-as-data; ADR-078 cites **≥ £100k → CFO sign-off**) require **CFO HITL**. **No autonomous treasury
> execution.** All treasury **ports are read-only** (ADR-078) — they observe and surface, they do not move money.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/adr/ADR-078-cfo-treasury-forecast-ports.md` (IL-172) | Defines **read-only** `FXExposurePort`, `NOSTROReconPort`, `LiquidityForecastPort`; `TreasuryAgent` (L2) + `ForecastAgent` (L2); **≥ £100k CFO sign-off** | **keep / OPERATIONALISE** — E-treasury **consumes** these ports + realises the TreasuryAgent/ForecastAgent contract. Ports/agents **not** reimplemented (ADR-102) |
| `docs/adr/ADR-106-execution-channel-selection-for-adr-078.md` | Execution-channel selection for ADR-078 | **keep / reference** — channel governance for the treasury agents; not duplicated |
| `docs/regulatory/E-CAPITAL-BUILD-SPEC.md` (IL-497) | FCA ICARA **capital adequacy** (own-funds, K-factor, wind-down) | **keep / reference + FENCE** — **treasury ≠ capital adequacy**. E-treasury supplies a **liquidity input** to E-capital; does NOT reimplement capital adequacy |
| `docs/architecture/D-FIN-BUILD-SPEC.md` (IL-485) | financial reporting (P&L, balance sheet) | **keep / reference** — E-treasury **feeds** position data; **D-fin reports**. Reporting **not** duplicated |
| `docs/payments/C-SWIFT/C-FPS/C-SEPA-BUILD-SPEC.md` | rails move funds; NOSTRO settlement | **keep / reference** — rails **move** funds + own NOSTRO settlement; E-treasury **observes/reconciles positions** (read-only). Rail logic **not** duplicated |
| `docs/D-RECON-BUILD-SPEC.md` | 3-leg reconciliation engine (NOSTRO recon) | **keep / reference** — D-recon **owns** recon; `NOSTROReconPort` supplies read-only recon **inputs** to treasury. Recon engine **not** duplicated |

No existing `E-TREASURY-BUILD-SPEC` / treasury-management artifact on main (live audit: `find docs -iname '*e-treasury*'`/`*treasury*BUILD*` ⇒ empty; no `docs/treasury/` dir; `ls docs/architecture` has A-*/B-EMI/D-*/G-*/I-API). New file is **non-duplicative**; it operationalises ADR-078 ports, it does not re-implement them or the capital/reporting/rail/recon layers. Placement = `docs/architecture/` (treasury management is architecture; E-capital regulatory-capital lives in `docs/regulatory/`).

## 1. Scope — treasury management (firm-internal)

E-treasury defines the **observe-and-surface** treasury layer over **read-only** ports; all thresholds are **config-as-data** (CLAUDE.md §10 — no hardcoded limits):

1. **Liquidity management** — current cash position, rolling liquidity **forecast** (opening balance + projected in/outflows over `horizon_days`), liquidity **buffers** vs minimum-buffer policy. Forecast **inputs** via `LiquidityForecastPort` (read-only; E-treasury surfaces the rolling forecast — it does **not** run ML/statistical models, ADR-078 D3).
2. **FX position / exposure monitoring** — multi-currency net positions + exposure per currency, derived from D-gl balances + NOSTRO balances. Exposure **inputs** via `FXExposurePort` (read-only).
3. **ALM (asset-liability management)** — asset-liability **matching**, **maturity ladders** (bucketed by tenor), interest-rate-risk + liquidity-risk indicators (gap analysis). Derived from D-gl balances by maturity/tenor; thresholds config-as-data.

**Out** of E-treasury: capital adequacy / ICARA (E-capital), financial reporting (D-fin), fund movement / settlement (payment rails), the reconciliation engine (D-recon), and any trading/dealing or advice.

## 2. Data model (LiquidityPosition / FXExposure / ALMLadder)

Declarative, config-as-data; **Decimal** for all money (I-01); read-only derivations.

### 2.1 `LiquidityPosition`
- `position_id`, `as_of`, `currency`, `cash_balance` (Decimal, from D-gl + NOSTRO), `available_liquidity`, `min_buffer_ref` (config policy), `buffer_breach` (bool), `forecast_horizon_days`, `projected_inflows`/`projected_outflows` (from `LiquidityForecastPort`), `forecast_closing_balance`.

### 2.2 `FXExposure`
- `exposure_id`, `as_of`, `currency`, `net_position` (Decimal), `nostro_balance`, `exposure_vs_base` (in reporting currency), `limit_ref` (config exposure limit), `limit_breach` (bool). Source: `FXExposurePort` (read-only).

### 2.3 `ALMLadder`
- `ladder_id`, `as_of`, `buckets[]`: `{ tenor_bucket (e.g. O/N, 1w, 1m, 3m, 1y, >1y), assets (Decimal), liabilities (Decimal), gap }`, `cumulative_gap`, `ir_risk_indicator`, `liquidity_risk_indicator`. Derived from D-gl balances by maturity.

### 2.4 `TreasuryDecision` (governance object)
- `decision_id`, `kind` (rebalance-proposal | buffer-action | fx-hedge-proposal | … — **proposals only**), `amount` (Decimal), `action` (`AUTO | REVIEW | HOLD`), `human_reviewed_by` (CFO for ≥ threshold), `decided_at`, `evidence_refs`.
- **No execution field** — a `TreasuryDecision` is a governed **recommendation/observation**, never an executed trade (§5/§8).

## 3. Derivation flow (read-only ports; surface, not execute)

```
D-gl balances + NOSTRO (rails) + forecast inputs
  1. FXExposurePort (read-only)        → FXExposure (net positions, limit checks)
  2. NOSTROReconPort (read-only)       → reconciled NOSTRO balances (recon owned by D-recon)
  3. LiquidityForecastPort (read-only) → forecast inputs → LiquidityPosition (buffer checks)
  4. D-gl balances by maturity         → ALMLadder (gap analysis, IR/liquidity risk)
  5. surface dashboards + TreasuryDecision proposals (AUTO/REVIEW/HOLD)
       amount ≥ threshold (config; ADR-078 ≥ £100k) → REVIEW + CFO sign-off (HITL)
  6. feed positions → D-fin (reporting) + liquidity input → E-capital; audit → ClickHouse
```

- All ports are **read-only** (ADR-078): E-treasury **observes** — it never mutates a source, moves funds, or trades.
- Below-AUTO forecast holds for Head-of-FP&A review (ForecastAgent HITL, ADR-078 D4); material treasury decisions force CFO sign-off.

## 4. Governance — TreasuryAgent L2 + CFO HITL (no autonomous execution)

- **TreasuryAgent = L2 Review** (ADR-078 §2.5.3): consumes `FXExposurePort` + `NOSTROReconPort`; produces observations/proposals.
- **≥ threshold → CFO sign-off (HITL):** any treasury decision at/above the configured material amount (config-as-data; ADR-078 cites **≥ £100k**) is forced to `REVIEW` and requires `human_reviewed_by` = CFO — regardless of confidence.
- **ForecastAgent = L2 Review** (ADR-078 §2.5.2): consumes `LiquidityForecastPort`; below-AUTO → Head-of-FP&A HITL hold.
- **No autonomous treasury execution / dealing** — the build produces governed recommendations + monitoring only; any actual rebalance/hedge/placement is an operator + CFO-authorised action (§10).
- Thresholds, buffers, exposure limits, maturity buckets = **config-as-data** (CLAUDE.md §10), not code.

## 5. Producer/consumer contracts (referenced, not duplicated)

- **Consumes ADR-078 read-only ports**: `FXExposurePort`, `NOSTROReconPort`, `LiquidityForecastPort` — supply read-only inputs; E-treasury operationalises, does **not** reimplement them.
- **Consumes D-gl + NOSTRO (rails)**: balances (by currency/maturity) + NOSTRO positions. D-gl owns the ledger; rails own settlement; E-treasury observes positions only.
- **Consumes D-recon (via NOSTROReconPort)**: reconciled NOSTRO inputs. D-recon owns the recon engine.
- **Feeds D-fin**: position/exposure/liquidity data for reporting. D-fin reports; E-treasury does not.
- **Feeds E-capital**: liquidity input to capital-adequacy assessment. **Treasury ≠ capital adequacy** — E-capital owns ICARA.

## 6. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_liquidity_position_from_ports` (cash + forecast via `LiquidityForecastPort` read-only; buffer-breach flag; Decimal I-01).
- [ ] `test_fx_exposure_via_port` (net positions + limit checks via `FXExposurePort` read-only; no source mutation).
- [ ] `test_alm_ladder_gap_analysis` (maturity buckets + gap + IR/liquidity-risk indicators from D-gl by tenor).
- [ ] `test_thresholds_config_as_data` (buffers/limits/buckets from config; no hardcode — CLAUDE.md §10).
- [ ] `test_treasury_decision_cfo_signoff_over_threshold` (amount ≥ config threshold ⇒ REVIEW + CFO `human_reviewed_by`; ADR-078 ≥ £100k).
- [ ] `test_no_autonomous_execution` (TreasuryDecision is a proposal; no trade/fund-move executed; boundary test).
- [ ] `test_ports_read_only` (no port mutates a source — ADR-078).
- [ ] `test_feeds_dfin_and_ecapital_not_reimplemented` (position/liquidity data handed off; reporting/capital owned elsewhere).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; E-capital/D-fin/rails/D-recon boundaries respected; audit rows per ADR-027.

## 7. Perimeter

- **In:** firm-internal treasury observation/management — liquidity position + forecast surfacing, FX exposure monitoring, ALM ladders/gap analysis, governed `TreasuryDecision` proposals, the consumer/producer contracts to ADR-078 ports / D-gl / D-fin / E-capital.
- **Out (fail-closed, §9):** capital adequacy (E-capital), financial reporting (D-fin), fund movement/settlement (rails), recon engine (D-recon), trading/dealing/advice, autonomous execution.
- **Plane:** spec only here; runtime in `banxe-emi-stack` is a separate operator-authorized action (§10).

## 8. SCOPE/HITL FENCE (treasury-management only — fail-closed)

- E-treasury (and this build-spec) defines **operational treasury management for the firm only** — **not** investment/financial advice, **not** a client-facing trading/dealing desk, **not** autonomous trading.
- **Specification only:** the factory runs no live treasury and executes no trades.
- **HITL:** TreasuryAgent L2 Review; decisions ≥ threshold (config-as-data; ADR-078 ≥ £100k) → CFO sign-off; ForecastAgent below-AUTO → Head-of-FP&A hold.
- **Read-only ports** (ADR-078) — observe/surface only; never move money or mutate sources.
- **Fail-closed:** if any requirement would have the factory trade autonomously, give investment/financial advice, or move client/firm funds → **STOP + operator brief**; do not implement.

## 9. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no live treasury / no trade execution** (spec only, §8 fence); **no autonomous treasury execution or dealing**; **no investment or financial advice**; **no client-facing trading desk**; **no capital-adequacy reimplementation** (E-capital owns ICARA); **no financial-reporting reimplementation** (D-fin); **no fund movement / settlement / rail logic** (payment rails); **no reconciliation-engine reimplementation** (D-recon; treasury consumes read-only NOSTRO recon inputs); no port mutation (ADR-078 ports are read-only); no decision ≥ threshold without CFO HITL.

## 10. Operator gates NOT crossed

- **Cross-repo runtime** — implementing E-treasury in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Treasury execution** (real rebalance / FX hedge / placement) = operator + **CFO sign-off (HITL)** — not done here.
- No passport activation (TreasuryAgent/ForecastAgent passports stay as-is); no DRAFT promotion; no operator-gated PR touched; Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 11. References

`docs/adr/ADR-078-cfo-treasury-forecast-ports.md` (IL-172 — FXExposurePort/NOSTROReconPort/LiquidityForecastPort, TreasuryAgent/ForecastAgent, ≥£100k CFO sign-off — operationalised);
`docs/adr/ADR-106-execution-channel-selection-for-adr-078.md` (execution-channel governance);
`docs/regulatory/E-CAPITAL-BUILD-SPEC.md` (IL-497 — capital adequacy, distinct; liquidity input consumer);
`docs/architecture/D-FIN-BUILD-SPEC.md` (IL-485 — reporting consumer);
`docs/payments/C-SWIFT/C-FPS/C-SEPA-BUILD-SPEC.md` (NOSTRO/settlement — rails move funds);
`docs/D-RECON-BUILD-SPEC.md` (NOSTRO recon engine);
ADR-027 (audit), ADR-049 (agent pattern), ADR-102/103/115/116/117/119; I-01 (Decimal); CLAUDE.md §9/§10/§11.
