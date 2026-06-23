# S-PROD-1 — Safeguarding Engine: Execution Gate (DECLARE-COVERED, reference-only)

**Date:** 2026-06-23 · **Priority:** P0 · **Status:** ⚠ OVERDUE (deadline 2026-05-07 — single largest regulatory risk).
**Nature:** governance **execution-gate / coverage-map** — **NOT** a re-spec.
**ADR-102 (anti-dup):** the S-PROD-1 execution specification is **already COVERED on `main`** by
Sprint J (#718 / IL-472): `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` + `docs/safeguarding/J-CROSS-REPO-HANDOFF.md`.
This document **references, does not duplicate or re-spec** them; it only (a) maps the roadmap
S-PROD-1 row to the existing artifacts, (b) records the one genuine harmonization residual, and
(c) consolidates the operator gates. No engine internals are restated here.

---

## §1. Scope & deadline — COVERED
P0, OVERDUE (2026-05-07), CASS 15 client-money segregation. → **Covered** by
`J-ENGINE-BUILD-SPEC.md` header + §2.1. This gate only **flags the OVERDUE P0 status** at roadmap
level; the scope itself is spec-locked there.

## §2. Coverage map (requested brief § → existing artifact on `main`)

| Requested § | Where it is already on `main` (cite) |
|---|---|
| §1 Scope & P0/OVERDUE/CASS 15 | `J-ENGINE-BUILD-SPEC.md` header + §2.1 |
| §2 J-engine (recon) | `J-ENGINE-BUILD-SPEC.md` §2.2 (three-leg tie-out) — extends `adrs/ADR-SAF-01-...md`, `instruction-ledger/sprint-44/IL-SAF-01-safeguarding-recon.md` |
| §2 J-audit (immutable ClickHouse trail, 5Y) | `J-ENGINE-BUILD-SPEC.md` §2.3 — governed by `agents/passports/safeguarding_audit_agent.yaml` |
| §2 E-safeguard (segregated accounts) | `J-ENGINE-BUILD-SPEC.md` §2.1 — `relevant_funds_fully_segregated`; ADR-013 |
| §3 Target repo + ports (LedgerPort/Midaz, I-28, recon↔rails) | `J-ENGINE-BUILD-SPEC.md` §4 (ports) + `J-CROSS-REPO-HANDOFF.md` §1/§2 (banxe-emi-stack MUST implement) |
| §4 Inviolable: shortfall→FCA breach path, no auto-submission, fail-closed | `J-ENGINE-BUILD-SPEC.md` §2.4 + §3 invariants + §5; `.claude/rules/cass15.md` (shortfall auto-FCA-alert, no AI suppression — immutable) |
| §5 Acceptance (FCA-producible, recon-green, breach path) | `J-CROSS-REPO-HANDOFF.md` §3 (Definition of Done checklist) |
| §6 AWAITS-OPERATOR | `J-CROSS-REPO-HANDOFF.md` §5 (operator gates) — consolidated in §4 below |
| §7 Dependency (code in product repos; this = arch/governance gate) | `J-ENGINE-BUILD-SPEC.md` plane note + `J-CROSS-REPO-HANDOFF.md` (spec→implementation plane, ADR-115/116/117) |

→ **All seven requested sections are already covered.** This gate adds no new spec.

## §3. Inviolable rules (re-affirmed, not re-specified)
Per `.claude/rules/cass15.md` + `J-ENGINE-BUILD-SPEC.md` §3: **safeguarding shortfall → automatic
FCA-alert path is IMMUTABLE; no AI may suppress it**; daily recon before cut-off
(`daily_recon_completed_before_cutoff`); shortfall → HITL (I-27, agents PROPOSE only); append-only
5Y audit (I-24/I-28); LedgerPort-only (I-28, no direct HTTP); Decimal money (I-01); fail-closed.
These are cited, not redefined.

## §4. AWAITS-OPERATOR (Rule 11 — nothing decided here)
From `J-CROSS-REPO-HANDOFF.md` §5 + repo canon; binding values NOT asserted in repo → operator decides:
| Item | Gate |
|---|---|
| Cross-repo write authorization (produce stack code in `banxe-emi-stack`) | operator-authorized action; not done here |
| PROPOSED passport activation (`safeguarding_recon_governor` GAP-005, `safeguarding_audit_agent` PS25/12) | governance gate (CLASS_B, Head of Internal Audit / CRO) |
| Binding `RECON_THRESHOLD_GBP` / cut-off cron / segregated account IDs | config-as-data values — **AWAITS OPERATOR** (build-spec marks config-as-data; no figures invented) |

## §5. Genuine residual — regulatory-reference harmonization (the one real delta)
`J-ENGINE-BUILD-SPEC.md` §1 flagged that the roadmap S-PROD-1 row labels this **"PS10/15"**, while
the authoritative safeguarding spec set (passports + GAP-005 + audit agent) consistently cites
**PS25/12** (FCA *Changes to the Safeguarding Regime for Payments and E-money Firms*). The build-spec
governs on PS25/12 + CASS 15 and left the matrix cell unmodified (additive-only). **Open item:**
operator/roadmap-owner to harmonize the S-PROD-1 matrix label PS10/15 → **PS25/12** (governance
decision; not changed here to avoid mutating the product registry).

## §6. Net
S-PROD-1 execution **spec is COVERED** (Sprint J #718 / IL-472). No re-spec produced (ADR-102).
The **code phase executes cross-repo** in `banxe-emi-stack` per `J-CROSS-REPO-HANDOFF.md`, gated by
the §4 operator gates. This gate's only forward asks: (1) close the §4 operator gates to unblock the
stack PR; (2) harmonize the PS10/15→PS25/12 label (§5).

---

### Refs
`docs/safeguarding/J-ENGINE-BUILD-SPEC.md`, `docs/safeguarding/J-CROSS-REPO-HANDOFF.md` (#718/IL-472);
`adrs/ADR-SAF-01-safeguarding-reconciliation.md`; `instruction-ledger/sprint-44/IL-SAF-01-safeguarding-recon.md`;
`.claude/rules/cass15.md`; `.claude/agents/safeguarding-agent.md`; `agents/passports/{safeguarding_recon_governor,safeguarding_audit_agent}.yaml`;
`docs/canon/g-cass-01-audit-2026-05-05.md`; `docs/ROADMAP-STATUS-2026-06-23.md` (S-PROD-1 row);
ADR-013/102/103/115/116/117; FCA PS25/12, CASS 15 / 7.13-7.15; I-01/02/04/24/27/28.
