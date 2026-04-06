# ADR-014: Composable Financial Stack — EMI Core Architecture

**Status:** PROPOSED
**Date:** 2026-04-06
**Deciders:** CEO (Moriel Carmi), CTIO (Oleg)
**Trust Zone:** AMBER
**Change Class:** CLASS_B

---

## Context

Traditional monolithic core banking systems (Temenos, Mambu, Thought Machine Vault) are designed around retail/commercial banking workflows: branch teller operations, term deposit ladders, credit origination, and nostro/vostro correspondent networks. These systems carry significant licensing cost, long onboarding timelines (6–18 months), and architectural assumptions that do not map cleanly to an FCA-authorised EMI.

An FCA EMI has a fundamentally different operational profile:

1. **Safeguarding is the primary obligation** — not lending. Client funds must be segregated in a qualifying institution or covered by an insurance policy (CASS 15, FCA PS10/15). This is not a feature of any standard core banking product.
2. **Regulatory reporting surface is narrow but precise** — FIN-RPT (Gabriel/RegData), FSCS, NCA SARs. A monolithic CBS bundles dozens of report types irrelevant to EMI operations.
3. **Payment rail integration** — FPS, SEPA, SWIFT are the operational core, not a bolt-on. Traditional CBS vendors treat rail connectivity as a paid add-on module.
4. **Audit trail requirements** — FCA expects a complete, producible, tamper-evident audit trail for all financial events. This maps naturally to an append-only analytical store (ClickHouse), not a relational OLTP ledger.
5. **Speed to authorisation** — Banxe holds FCA EMI authorisation. Deploying a monolithic CBS (Geniusto, Oracle FLEXCUBE, Thought Machine) in a compliant, tested, FCA-auditable state would take 12–24 months. The composable approach can achieve regulatory readiness in Sprint 8–12 (approximately 8 weeks).

**The Geniusto replacement decision:** Geniusto was evaluated as a potential hosted core banking solution. It was rejected due to: (a) data residency concerns (FCA DORA-adjacent requirements), (b) inability to expose a segregated safeguarding view without custom integration, (c) vendor lock-in on regulatory reporting formats. The composable stack eliminates all three objections.

**Key architectural insight:** FCA EMI = safeguarding reconciliation + FIN-RPT + immutable audit trail + payment rails. This is a different problem from "run a bank." The composable stack solves exactly this problem without dragging in 200 irrelevant CBS modules.

---

## Decision

Banxe adopts a **composable financial stack** built from best-of-breed open-source and purpose-built components:

### Tier 1: General Ledger (Double-Entry)

| Component | Role | Rationale |
|-----------|------|-----------|
| **Midaz (LerianStudio)** | PRIMARY General Ledger + account management | Open-source, built for composable fintech, double-entry, multi-currency, REST API-first. Active development, FCA-friendly data model. |
| **Apache Fineract** | FALLBACK CBS | Battle-tested open-source CBS. Used by 100+ MFIs and EMIs globally. JVM-based, extensible. Activated only if Midaz proves insufficient for EMI account model. |

**LedgerPort adapter** (to be built Sprint 8–9): thin adapter layer that normalises Midaz and Fineract APIs into a single internal `LedgerPort` interface. All upstream services (reconciliation, fee engine, safeguarding) call `LedgerPort` exclusively. This enables PRIMARY/FALLBACK switching without upstream changes.

### Tier 2: Financial Analytics + Audit Trail

| Component | Role | Rationale |
|-----------|------|-----------|
| **ClickHouse** | Financial analytics + immutable audit trail | Columnar OLAP, append-only inserts, TTL 5Y (regulatory minimum), sub-second aggregation over millions of ledger events. FCA audit trail requirement = ClickHouse native strength. |

### Tier 3: Workflow Orchestration (Regulatory Reporting)

| Component | Role | Rationale |
|-----------|------|-----------|
| **n8n** | FIN-RPT, FSCS, Gabriel/RegData reporting workflows | Visual workflow automation, self-hosted, no data leaves the perimeter. Regulatory return schedules (monthly, quarterly) map directly to n8n cron triggers. |

### Tier 4: Regulatory Reporting Module (Conditional)

| Component | Role | Rationale |
|-----------|------|-----------|
| **Midaz Reporter** | Regulatory reporting module (if available from LerianStudio) | To be evaluated in Sprint 9. If Midaz provides a compliant reporting module, adopt. Otherwise, build FIN-RPT adapter as n8n workflow + ClickHouse query layer. |

### Stack Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    API Gateway (Block M)                  │
└────────────────────────┬────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    ┌────▼────┐    ┌─────▼────┐   ┌─────▼──────┐
    │ Payment  │    │Compliance│   │ Safeguarding│
    │ Rails    │    │ Stack    │   │ Engine (J)  │
    │ (C)      │    │ (F)      │   │ P0 DEADLINE │
    └────┬────┘    └─────┬────┘   └──────┬──────┘
         │               │               │
         └───────────────▼───────────────┘
                         │
              ┌──────────▼──────────┐
              │    LedgerPort        │
              │  (adapter interface) │
              └──────┬──────┬───────┘
                     │      │
            ┌────────▼──┐ ┌─▼───────────┐
            │   Midaz   │ │  Fineract   │
            │ (PRIMARY) │ │ (FALLBACK)  │
            └────────┬──┘ └─────────────┘
                     │
         ┌───────────▼───────────┐
         │      ClickHouse        │
         │  (audit trail, TTL 5Y) │
         └───────────┬───────────┘
                     │
         ┌───────────▼───────────┐
         │          n8n           │
         │  (regulatory workflows)│
         └───────────────────────┘
```

---

## Consequences

### Positive

1. **Speed to regulatory readiness** — composable stack can achieve FCA-auditable state in 8–12 weeks vs. 12–24 months for monolithic CBS onboarding.
2. **No vendor lock-in** — all components are open-source. Midaz can be replaced by Fineract via LedgerPort without upstream disruption.
3. **FCA audit trail is native** — ClickHouse append-only + TTL 5Y satisfies FCA record-keeping requirements (reg 19, EMR 2011) out of the box. No need to bolt on an audit layer.
4. **Data sovereignty** — all components self-hosted on GMKtec EVO-X2. No data leaves the regulated perimeter. Satisfies FCA DORA-adjacent outsourcing obligations.
5. **Cost** — zero licensing cost for GL tier. Midaz, Fineract, ClickHouse, n8n are all open-source or BSL-licensed with no per-transaction fees.
6. **Composability** — each block (D, E, F, J, K) is independently deployable. Block F (compliance) is already at 80% without waiting for Block D (GL).
7. **n8n regulatory workflows** — FCA reporting cadence (monthly FIN-RPT, quarterly Gabriel) maps directly to n8n cron-triggered workflows. Changes to FCA return formats require only workflow edits, not CBS upgrades.

### Negative / Risks

1. **Safeguarding engine is NOT covered by this ADR** — Block J (Safeguarding Engine, CASS 15, deadline 7 May 2026) requires separate, dedicated implementation. Midaz does not natively model FCA safeguarding segregation. This is the single largest remaining risk.
2. **FIN-RPT / FATCA/CRS require separate module** — regulatory reporting (Block K, sub-block F-fatca) is not a Midaz feature. Must be built as n8n workflows + ClickHouse query layer, or sourced from a specialist vendor (e.g. Regnology, Wolters Kluwer). Sprint 9 evaluation required.
3. **LedgerPort adapter build cost** — the normalisation adapter (Midaz ↔ Fineract) must be built in Sprint 8–9. Estimated: 3–5 developer-weeks.
4. **Midaz maturity** — Midaz (LerianStudio) is a relatively young project (2023–). Production battle-testing at EMI scale is limited. The FALLBACK (Fineract) mitigates this risk, but adds architectural complexity.
5. **Multi-currency complexity** — FPS (GBP), SEPA (EUR), SWIFT (multi) require Midaz multi-currency configuration. This must be validated against FCA EMR 2011 requirements for e-money denomination.
6. **n8n as regulatory infrastructure** — using a workflow automation tool for FCA-mandated reporting introduces risk if n8n is unavailable during a reporting window. Mitigation: systemd watchdog, ClickHouse-backed idempotent workflows, manual fallback runbook.

---

## Implementation Plan

| Sprint | Action |
|--------|--------|
| Sprint 8 | Midaz deploy on GMKtec, LedgerPort interface design, first account model |
| Sprint 9 | LedgerPort adapter v1, D-recon design, J-engine start (P0) |
| Sprint 9 | Safeguarding engine (Block J) — segregated account model in Midaz + ClickHouse |
| Sprint 10 | FIN-RPT n8n workflow v1, D-fin (P&L), FPS rail integration |
| Sprint 11 | Gabriel/RegData integration, FATCA/CRS evaluation, fraud scoring |

---

## Related

- ADR-012 — Compliance API port migration (port 8093)
- ADR-013 — Midaz CBS as primary general ledger (to be authored Sprint 8)
- `INVARIANTS.md` — I-20: Independent composable layers (no cross-layer coupling)
- `GAP-REGISTER.md` — GAP-20: Midaz GL deployment
- `docs/ROADMAP-MATRIX.md` — Full block/sub-block delivery matrix
- Block J safeguarding deadline: **7 May 2026** (FCA CASS 15 hard deadline)
- `DEFERRED-PROJECTS.md` — P0 Blockers section
