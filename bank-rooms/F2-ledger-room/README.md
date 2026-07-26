> ⚠ TRAINING DATA — SANDBOX — NOT FOR PRODUCTION

# F2 / ledger-room

**Floor 2 — Banking core · Ledger / EMI cluster (D-GL + B-EMI)**
Room kit hardened per FLOOR2-LEDGER-ROOM-HARDENING (S-A6 cabinet layer). Docs-only; no runtime code lives here and no runtime code was modified.

## Purpose / coverage
GL/double-entry core, reconciliation, statements, fees, period-close swarm, MCP access to ledger; tax/RegData line (Sprint 5). Room perimeter = **D-GL** (General Ledger core) **+ B-EMI** (EMI product catalogue) as one Floor-2 ledger/EMI cabinet.

## Basement split (where the code actually lives)
- **Runtime (basement):** `~/banxe-emi-stack` — ledger entrypoints identified by shell audit (FABRIKA-FLOOR2-LEDGER-CABINET-AND-RUNTIME-AUDIT-R1): `services/ledger/` (incl. `ledger_port.py`, `midaz_adapter.py`, `midaz_agent.py`), `api/routers/ledger.py`, `api/models/ledger.py`, and `services/midaz_mcp/`. **This hardening step does not modify any of them.**
- **Architecture / cabinet (this repo):** `~/wt/architecture-bank-operating-model-20260718/bank-rooms/F2-ledger-room/` — build specs, roadmap/audit anchors, room kit (README, agents YAML, HITL summary, diagram). Documentation/governance/navigation layer **above** runtime, not a runtime refactor.
- **Discipline:** reuse-not-rebuild (**ADR-102**); compliance-source / Tier-A governance (**ADR-173**); HITL (**I-27**: AI proposes, human decides).

## Room perimeter — D-GL + B-EMI
- **D-GL** (`../../docs/architecture/D-GL-BUILD-SPEC.md`) — double-entry GL core, **single source-of-truth for balances**. Midaz (Lerian) = **PRIMARY**; Apache Fineract = **FALLBACK via the same `LedgerPort`** (swap/failover, not concurrent). Consolidates the existing `services/ledger/` (IL-FIN-01); ships no runtime code, no cross-repo write.
- **B-EMI** (`../../docs/architecture/B-EMI-BUILD-SPEC.md`) — EMI product catalogue (e-money accounts, cards, IBAN). Product accounts **map to** GL accounts; B-EMI defines products, **D-GL posts them**. No posting logic in B-EMI (ADR-102).

## Ledger narrative (control posture)
- **No second ledger / no dual-write:** all posting + balance derivation go through `LedgerPort` → `midaz_adapter`. Fineract is a failover swap, never a concurrent second active ledger (D-GL §2, ADR-102 / MIG-ABS covered-note).
- **Append-only / auditability:** ledger is append-only (ADR-056/057, ADR-059-A/ADR-119, **I-24**); money is Decimal-only (**I-01**). No in-place mutation of posted entries.
- **Close-control & adjustment sign-off:** period-close and adjustments are gated — **adj > £10k → CFO**; financial-materiality and RegData submission carry human sign-off (see `hitl-summary.md`).
- **Human doubles / SMF / HITL ownership:** CFO (SMF2) owns financial control + RegData submission; COO (SMF24) safeguarding; MLRO (SMF17) AML escalation. AI proposes; the accountable human decides (I-27).
- **Failover boundary:** Midaz-unavailable surfaces an infra failure (no silent skip); promotion to Fineract is an **operator-authorized** runtime switch, not autonomous.

## Midaz / MCP / ledger-port coupling — gated control topic
- `midaz_agent` (`services/midaz_mcp/`) and the MCP path are a **control topic**, not a settled finding here. Room canon expects **all writes via `LedgerPort`** under append-only + sign-off constraints.
- **Direct MCP→ledger mutation is NOT assumed as fact** in this room. Any suspicion of a direct MCP→ledger write path remains a **gated architecture-control question for `[external reviewer]`** (register **#6 midaz MCP→ledger, AMBER**) until proven by documented evidence elsewhere; it is not closed here.

## Regulatory Status Notes
- Register areas: **#1 Tax (AMBER)** · **#6 midaz MCP→ledger (AMBER)**.
- Canonical source: `../../docs/governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md`.
- Freeze: "Room status must not appear more GREEN than the worst register entry that affects it." · "No GREEN without evidence artefact linked in the register."
- Room invariants: append-only ledger (ADR-056/057, I-24) · Decimal-only money (I-01) · no second ledger (ADR-102) · adj>£10k → CFO.

### Sprint 5 (Tax / RegData)
Artefacts: `../../docs/sprints/sprint-5-tax-agent-autonomy-adr-draft.md` (L2 propose-only, human-submit — ratification pending) · `../../docs/sprints/sprint-5-regdata-cycle-runbook.md` (FIN060→CFO dry-run; **no automated submission, CFO-only** per HITL-010). #1 AMBER→GREEN only after ADR ratification + counsel answer, with evidence links in the register.

## Room kit index
- `agents-ledger-room.yaml` — roster (canonical stack/capability form), SMF mapping, control notes.
- `hitl-summary.md` — ledger HITL gates + sign-off authority (real gate IDs from `../../HITL-MATRIX.yaml`).
- `diagrams/ledger-room-overview.svg` — basement→cabinet, D-GL/B-EMI, LedgerPort/Midaz/MCP coupling, HITL layer.

## Anchors
- Build specs: `../../docs/architecture/D-GL-BUILD-SPEC.md` · `B-EMI-BUILD-SPEC.md`
- S-A6: `../../docs/roadmap/S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md`
- Roadmap: `../../docs/roadmap/S2-FLOOR2-SPRINT-PLAN-UPDATE-PLAN-2026-07-19.md` · `R2-FLOOR2-MASTER-ROADMAP-UPDATE-PLAN-2026-07-19.md`
- Audit: `../../docs/audit/FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md`
- ADR / invariants: `../../docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md` · `../../docs/adr/ADR-173-compliance-source-governance.md` · `../../INVARIANTS.md` (I-01, I-24, I-27)
- Brief: `../../docs/briefs/FLOOR2-A-CHAIN-CONTEXT-FOR-CONSULTANTS.md` · SMF roles: `../../docs/ORG-STRUCTURE.md`
