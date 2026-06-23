# J-Engine + J-Audit — Safeguarding Engine Build-Spec (promotes ADR-SAF-01)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-23 · **Sprint:** J · **Priority:** P0 · **Deadline:** 7 May 2026 (overdue — single largest regulatory risk)
**Plane:** banxe-architecture = **docs/architecture/spec** only. Runtime code lives in `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117 factory mandate; ADR-SAF-01 / IL-SAF-01 precedent). This doc **specifies**; it ships **no** runtime code here.
**Promotes:** `adrs/ADR-SAF-01-safeguarding-reconciliation.md` (Accepted) from spec → actionable build-spec for ROADMAP blocks **J-engine** + **J-audit**.
**Discipline:** ADR-102 (Duplication Audit — done, §0), ADR-103 (server-side build in stack repo), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> This is the actionable build-spec the stack repo executes. Acceptance/exit criteria and the
> cross-repo handoff contract are in the companion `J-CROSS-REPO-HANDOFF.md`.

---

## 0. Duplication Audit (ADR-102)
Repo-wide search performed before authoring (all in-scope safeguarding artifacts):
| Artifact | Role | Decision |
|---|---|---|
| `adrs/ADR-SAF-01-safeguarding-reconciliation.md` | Accepted ADR — CASS 7.15 daily aggregate recon (delivered) | **keep** (source of truth; this doc promotes, does not overwrite) |
| `instruction-ledger/sprint-44/IL-SAF-01-...` | Sprint-44 closure of the v1 recon engine (banxe-emi-stack#24) | **keep** (precedent; J extends, not re-implements) |
| `.claude/rules/cass15.md` | P0 CASS 15 stack map (Midaz/recon/reporting/audit/FX) | **keep** (infra reference) |
| `agents/passports/safeguarding_recon_governor.yaml` (GAP-005, PROPOSED) | daily segregated-accounts recon governor | **keep** (governs J-engine recon) |
| `agents/passports/safeguarding_audit_agent.yaml` (PS25/12, PROPOSED) | annual safeguarding audit evidence | **keep** (governs J-audit) |
| `ledger/.../sp23-safeguard-gap005` shard | GAP-005 OPEN→IN PROGRESS | **keep** |
No existing J-engine/J-audit build-spec, handoff, or `docs/safeguarding/` doc → **new files are non-duplicative.**

## 1. Regulatory drift reconciliation (verbatim-sourced, not memory)
- The ROADMAP J-engine row labels this **"FCA PS10/15 + CASS 15"**. The authoritative safeguarding
  spec set (both passports + the GAP-005 shard + audit agent) consistently cites **PS25/12** (FCA
  *Changes to the Safeguarding Regime for Payments and E-money Firms*; 35 repo refs vs 2 for
  PS10/15). **This build-spec uses PS25/12 + CASS 15** as the governing references and treats
  "PS10/15" in the matrix as a label to be harmonized (flagged, matrix description cell left
  unmodified per additive-only rule; see ROADMAP update).
- Daily-recon **mechanics** are inherited from ADR-SAF-01 (CASS 7.15-style aggregate recon:
  penny tolerance, jurisdiction exclusion, large-value flag, HITL on shortfall).

## 2. Scope — what J builds (beyond the IL-SAF-01 v1 recon at S6 ~35%)
**J-engine** = full segregated client-funds safeguarding + daily reconciliation across the three
legs; **J-audit** = immutable FCA-producible evidence trail. KYC/KYB/AML are **out of scope** (I-27
HOLD elsewhere); this is safeguarding of *relevant funds* only.

### 2.1 Segregated client-funds accounts (CASS 15)
- Relevant client funds held in **segregated safeguarding accounts**, fully ring-fenced from
  operational funds (passport invariant `relevant_funds_fully_segregated`).
- Account identities are config-as-data (per `cass15.md`): `client_funds` + `operational`
  safeguarding accounts (ADR-013); no hardcoding (CLAUDE.md §10).

### 2.2 Daily reconciliation — three-leg tie-out (extends ADR-SAF-01; ties to D-recon)
Reconcile **Midaz ledger ↔ safeguarding accounts ↔ payment rails**, daily before cut-off:
1. **Leg A — Midaz ledger balances** via `LedgerPort` (I-28: LedgerPort only, no direct HTTP).
2. **Leg B — safeguarding account balances** (segregated client_funds account).
3. **Leg C — payment-rail / bank balances** (CAMT.053 via bankstatementparser; adorsys PSD2 in Phase 2).
- **Tolerance:** penny-exact (£0.01, ADR-SAF-01) — config `RECON_THRESHOLD_GBP`.
- **Jurisdiction exclusion** (I-02): blocked-jurisdiction accounts excluded from totals.
- **Large-value flag** (I-04): balance ≥ £50k flagged.
- **Decimal only** (I-01) — never float for money.
- **Shortfall → HITL** (I-27): client funds > safeguarding ⇒ `HITLEscalation`, MLRO/Head-of-Finance-Ops
  sign-off; surplus flagged, no HITL. `daily_recon_completed_before_cutoff` invariant.
- **Governor:** `safeguarding_recon_governor` passport (GAP-005) governs the run; remains PROPOSED
  until activated via governance gate (not activated here).

### 2.3 J-audit — immutable trail to ClickHouse (TTL 5Y)
- Every recon run + every shortfall/HITL decision emits an append-only `ReconAuditEntry` /
  `safeguarding_events` row to **ClickHouse :9000** (per `cass15.md`), **retention TTL = 5 years**
  (I-24), append-only (I-28) — no update/delete.
- Evidence is **FCA-producible**: structured export (JSON now; PDF/FIN060 via WeasyPrint per stack)
  with compliance metadata, queryable by date-range for an FCA request or the annual safeguarding
  audit (PS25/12, relevant funds > £100k) supported by `safeguarding_audit_agent` (PROPOSED).

### 2.4 FCA breach-reporting hook (K-gabriel via n8n) — interface contract ONLY
- On a confirmed safeguarding **shortfall/breach**, J-engine emits a breach event to the
  **K-gabriel** FCA breach-reporting workflow over **n8n :5678**. This spec defines **only the
  interface contract** (event schema + trigger condition + idempotency key); the K-gabriel workflow
  and any FCA submission are out of J scope and HITL-gated.
- **Contract (interface):** event `safeguarding.breach.detected` { `recon_run_id`, `il_ts`,
  `shortfall_gbp` (Decimal string), `account_id`, `severity`, `hitl_decision_ref`,
  `idempotency_key` }. Direction: J-engine → n8n inbound webhook. No auto-submission to FCA
  (human_double sign-off required).

## 3. Invariants enforced
I-01 (Decimal money), I-02 (jurisdiction exclusion), I-04 (large value), I-24 (5Y audit retention),
I-27 (HITL on shortfall — agents PROPOSE only), I-28 (append-only audit + LedgerPort-only).
Plus passport invariants: `relevant_funds_fully_segregated`, `daily_recon_completed_before_cutoff`.

## 4. Architecture interfaces (ports, hexagonal)
- `LedgerPort` (ABC) — Midaz adapter (prod) / InMemory (test); `get_balance()` only (I-28).
- `SafeguardingAccountPort` — segregated account balances.
- `RailBalancePort` — CAMT.053 / PSD2 bank balances.
- `AuditPort` — append-only ClickHouse sink (5Y TTL).
- `BreachNotifyPort` — n8n webhook (K-gabriel interface contract §2.4).
- `HITLPort` — shortfall escalation to human_double.

## 5. Out of scope (fail-closed)
No runtime code in this repo; no KYC/KYB/AML; no K-gabriel workflow implementation (interface only);
no activation of PROPOSED passports; no Midaz prod credentials; no cross-repo write into
banxe-emi-stack (handoff is a spec, §`J-CROSS-REPO-HANDOFF.md`).

## 6. References
ADR-SAF-01; IL-SAF-01 (Sprint 44, banxe-emi-stack#24, SHA cb49885); `.claude/rules/cass15.md`;
`agents/passports/safeguarding_recon_governor.yaml` (GAP-005); `agents/passports/safeguarding_audit_agent.yaml` (PS25/12);
GAP-005 shard; ADR-013 (safeguarding accounts); ADR-102/103; ADR-115/116/117 (factory perimeter);
FCA PS25/12, CASS 15, CASS 7.13/7.14/7.15; I-01/I-02/I-04/I-24/I-27/I-28.
