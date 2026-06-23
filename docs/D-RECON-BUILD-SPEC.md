# D-Recon — Reconciliation Engine Build-Spec (promotes D-RECON-DESIGN)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-23 · **Block:** D-recon · **Priority:** P1 (critical-path dependency of P0 J-engine) · **Deadline:** 7 May 2026 (J dependency)
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc specifies; ships no runtime code.
**Promotes:** `docs/D-RECON-DESIGN.md` (DESIGN, IL-006 Step 5) → actionable build-spec.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-side build), ADR-059-A/ADR-119 (append-only frozen ledger). Additive.

> Companion to `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` (safeguarding orchestration) and
> `docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md` (segregated-account management). **D-recon is the
> reconciliation ENGINE** that J-engine §2.2 invokes; this doc owns the engine internals +
> `safeguarding_events` ClickHouse schema. Acceptance/handoff in `E-D-CROSS-REPO-HANDOFF.md`.

---

## 0. Duplication Audit (ADR-102)
| Artifact | Role | Decision |
|---|---|---|
| `docs/D-RECON-DESIGN.md` | DESIGN (CASS 7.15 daily recon, ClickHouse `safeguarding_events`, alert pipeline) | **keep** — this build-spec promotes it; design retained as source |
| `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` §2.2 | 3-leg recon **orchestration** (Midaz↔safeguarding↔rails) | **keep** — J orchestrates, D-recon is the engine it calls; cross-ref, no duplication |
| `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` §2.3 / J-audit | ClickHouse audit trail | **keep** — J-audit **consumes** the `safeguarding_events` table this spec owns |
| `.claude/rules/cass15.md` | P0 stack map (Midaz/recon/ClickHouse/n8n) | **keep** — infra reference |
| `instruction-ledger/sprint-44/IL-SAF-01` | v1 recon engine in stack (#24) | **keep** — D-recon extends |
No existing `D-RECON-BUILD-SPEC` → new file non-duplicative.

## 1. Scope reconciliation — 2-leg → 3-leg (drift fix, live-sourced)
- `D-RECON-DESIGN.md` specifies a **2-leg** recon (Midaz *internal* ↔ bank *external* statement, CASS 7.15).
- The ROADMAP D-recon row + `J-ENGINE-BUILD-SPEC §2.2` specify **3-leg** (Midaz ledger ↔ **safeguarding accounts** ↔ payment rails).
- **This build-spec adopts the 3-leg model:** the design's "external bank statement" leg is the **rail leg (Leg C)**; the new middle **safeguarding-account leg (Leg B)** ties the segregated client-money account (E-safeguard) between internal ledger and rails. The design's ClickHouse schema, alert pipeline, and daily flow are inherited and extended for the third leg.
- Regulatory framing harmonized: CASS 7.15 daily-recon **mechanics** + **PS25/12 + CASS 15** safeguarding regime (per the safeguarding spec set; "PS10/15" matrix label superseded — see J-ENGINE-BUILD-SPEC §1).

## 2. Three-leg reconciliation (engine contract)
| Leg | Source | Port |
|---|---|---|
| **A — internal ledger** | Midaz balances (client_funds + operational) | `LedgerPort.get_balance()` (I-28, no direct HTTP) |
| **B — safeguarding account** | segregated client-money account balance (E-safeguard) | `SafeguardingAccountPort` |
| **C — payment rail / bank** | CAMT.053 / CSV via SFTP; adorsys PSD2 (Phase 2) | `RailBalancePort` (StatementFetcher) |
- **Tie-out:** A == B == C per account/currency within tolerance.
- **Tolerance:** config `RECON_THRESHOLD_GBP` (design default £1.00; Q3 operator-decidable £1.00 vs £0.01 — see §6). Decimal only (I-01).
- **Jurisdiction exclusion** (I-02): blocked-jurisdiction accounts excluded from totals.
- **Large-value flag** (I-04): balance ≥ £50k.
- **Shortfall → HITL** (I-27): client funds > safeguarding ⇒ `HITLEscalation` (MLRO). Surplus flagged, no HITL.
- **Before cut-off** invariant (`daily_recon_completed_before_cutoff`); cron `0 7 * * 1-5` (config).

## 3. `safeguarding_events` ClickHouse schema (OWNED here; J-audit consumes)
Inherits `D-RECON-DESIGN.md` table verbatim (append-only MergeTree, `PARTITION BY toYYYYMM(recon_date)`,
`ORDER BY (recon_date, account_id)`, **TTL event_time + 5 YEAR** per I-24). **Extension for 3-leg:** add
`leg` enum context where a row may record A↔B, B↔C, or A↔C; `discrepancy` = signed delta; immutable (I-28,
no UPDATE/DELETE). This is the single source of truth for safeguarding recon evidence; **J-audit (J-A1..A4)
writes audit entries into this same table** — no second table.

## 4. Alert + breach pipeline
- **MLRO alert** (design): discrepancy > threshold → n8n :5678 webhook → MLRO Telegram (within 1h, CASS 7.15).
- **Breach hook (ties to J):** a confirmed shortfall additionally emits `safeguarding.breach.detected`
  via `BreachNotifyPort` to the **K-gabriel** workflow — **interface contract only** (per
  J-ENGINE-BUILD-SPEC §2.4); D-recon raises the event, K-gabriel/FCA submission is out of scope + HITL-gated.

## 5. Ports (hexagonal)
`LedgerPort` (Midaz adapter / InMemory), `SafeguardingAccountPort`, `RailBalancePort` (StatementFetcher:
CSV/CAMT.053/PSD2), `AuditPort` (→ `safeguarding_events`, 5Y TTL), `BreachNotifyPort` (n8n, K-gabriel iface),
`HITLPort` (MLRO escalation).

## 6. Open operator questions (carried from D-RECON-DESIGN — NOT decided here)
Q1 bank (Barclays default) · Q2 statement delivery (SFTP CSV default) · Q3 threshold (£1.00 default) ·
Q4 frequency (daily default) · Q5 MLRO channel (Telegram default). Build-spec encodes defaults as
config-as-data; final values are operator/CEO calls (config, not code; CLAUDE.md §10).

## 7. Out of scope (fail-closed)
No runtime code here; no cross-repo write into banxe-emi-stack; no KYC/KYB/AML; no Midaz prod credentials;
PROPOSED passports not activated; bank-account-dependent CAMT.053 format remains a Phase-2 adapter.

## 8. References
`docs/D-RECON-DESIGN.md`; `docs/safeguarding/{J-ENGINE-BUILD-SPEC,E-SAFEGUARD-CASS15-SPEC,E-D-CROSS-REPO-HANDOFF}.md`;
ADR-013 (safeguarding accounts), ADR-SAF-01, IL-SAF-01 (#24); `.claude/rules/cass15.md`;
ADR-102/103/115/116/117/119; FCA CASS 7.13/7.14/7.15, PS25/12, CASS 15; I-01/02/04/24/27/28; CTX-06.
