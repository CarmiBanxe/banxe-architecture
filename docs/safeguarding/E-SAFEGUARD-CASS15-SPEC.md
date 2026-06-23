# E-Safeguard — CASS 15 Segregated Client-Funds Account Management Spec

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-23 · **Block:** E-safeguard · **Priority:** P0 · **Deadline:** 7 May 2026 (overdue)
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). No runtime code here.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119. Additive; mutates no prior artifact.

> The **account-management layer**: opens/designates and ring-fences the segregated client-money
> accounts that **D-recon** reconciles (Leg B) and **J-engine** orchestrates. Acceptance/handoff in
> `E-D-CROSS-REPO-HANDOFF.md`. KYC/KYB/AML are out of scope (safeguarding of *relevant funds* only).

---

## 0. Duplication Audit (ADR-102)
| Artifact | Role | Decision |
|---|---|---|
| `.claude/rules/cass15.md` | safeguarding account IDs + threshold + cron (config) | **keep** — config source |
| `ADR-013` (referenced) | Midaz safeguarding accounts (client_funds / operational UUIDs) | **keep** — account identities |
| `agents/passports/safeguarding_recon_governor.yaml` (GAP-005, PROPOSED) | daily segregated-accounts recon governor | **keep** — governs E-safeguard daily run |
| `docs/D-RECON-BUILD-SPEC.md` | the recon engine (3-leg) | **keep** — E-safeguard provides Leg B accounts to it |
| `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` §2.1 | segregated CASS 15 accounts (summary) | **keep** — this spec is the detailed account-management layer J references |
No existing E-safeguard spec doc → new file non-duplicative.

## 1. Regulatory basis (live-sourced)
- **CASS 15 + PS25/12** — FCA *Changes to the Safeguarding Regime for Payments and E-money Firms*:
  relevant client funds must be **fully segregated** and reconciled daily; annual safeguarding audit
  for relevant funds > £100k (`safeguarding_audit_agent`, PROPOSED).
- Passport invariants enforced: `relevant_funds_fully_segregated`, `daily_recon_completed_before_cutoff`.

## 2. Scope — segregated client-funds account management
### 2.1 Account model (config-as-data, ADR-013)
- **`client_funds`** (liability) — relevant client money held in trust, segregated.
- **`operational`** (asset) — BANXE's own funds; **must never commingle** with client_funds.
- Account UUIDs + `RECON_THRESHOLD_GBP` + cron live in config (`cass15.md`), never hardcoded (CLAUDE.md §10).
- A **segregated bank/safeguarding account** at a qualifying institution backs `client_funds` (CASS 7.13);
  it is **Leg B** of D-recon's 3-leg tie-out.

### 2.2 Ring-fencing controls (CASS 15)
1. **Segregation-at-write:** every client-money movement posts to `client_funds`; no operational
   debit may draw on client_funds (invariant `relevant_funds_fully_segregated`).
2. **Designation & title:** the external safeguarding account is held as a designated client/trust
   account, evidenced for FCA.
3. **Daily relevant-funds calculation:** total relevant client funds computed daily (Decimal, I-01),
   excluding blocked jurisdictions (I-02) and flagging large balances (I-04).
4. **Shortfall = top-up obligation:** if relevant funds > safeguarded balance ⇒ shortfall ⇒ HITL
   (I-27, MLRO/Head of Finance Ops); top-up required same day. Surplus ⇒ withdraw excess (flagged).

### 2.3 Daily safeguarding governor (PROPOSED — not activated)
- `safeguarding_recon_governor` (GAP-005, PROPOSED, human_double = Head of Finance Ops) governs the
  daily run: triggers D-recon before cut-off, asserts completion, escalates shortfall/excess.
- **Activation is a CLASS_B governance gate** (operator) — **NOT performed here**.

### 2.4 Evidence & audit
- Each daily relevant-funds calc + segregation check writes to the `safeguarding_events` ClickHouse
  table (owned by D-recon §3; TTL 5Y, I-24/I-28) — FCA-producible for supervision and the annual audit.

## 3. Interfaces consumed/provided
- **Provides:** `SafeguardingAccountPort` (Leg B balance) to D-recon; relevant-funds total to J-engine.
- **Consumes:** `LedgerPort` (Midaz client_funds balance); config (account IDs, threshold).

## 4. Out of scope (fail-closed)
No runtime code here; no cross-repo write; no KYC/KYB/AML; no activation of PROPOSED passports;
no bank-account opening (operational/legal action); no movement of real client funds.

## 5. References
`.claude/rules/cass15.md`; ADR-013; `docs/D-RECON-BUILD-SPEC.md`; `docs/safeguarding/{J-ENGINE-BUILD-SPEC,E-D-CROSS-REPO-HANDOFF}.md`;
`agents/passports/{safeguarding_recon_governor,safeguarding_audit_agent}.yaml`;
ADR-102/103/115/116/117/119; FCA PS25/12, CASS 15, CASS 7.13; I-01/02/04/24/27/28.
