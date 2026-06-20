# Implementation Roadmap — L1→L3 for ADR-without-code features (2026-06-20)

> Track: `agent/factory/arch-stack-002` · per ADR-106 ACCEPTED · ADR-052 governance.
> Source: `docs/audit/FEATURE-INSTALLATION-AUDIT-METHODOLOGY-2026-06-20.md` (Audit Verdicts 2026-06-20).
> Scope of **this** document: roadmap only. The 4 implementation sprints are NOT executed here.

## Context

The 2026-06-20 read-only audit found **4 implementation-delta features**: an ADR (and in one case a passport)
exists, but there is **no code** in `banxe-emi-stack`. This roadmap drives each from **L1 (governance only)**
to **L2 (code)** / **L3 (wired & live)**. All code lands in `banxe-emi-stack`; each sprint references its GAP
via an IL shard in `banxe-architecture`.

| Level | Meaning |
|-------|---------|
| L1 | Governance only — ADR / passport / decision, no code |
| L2 | Code present in repo (services/src), tests pass |
| L3 | Wired into the app and live (bootstrap/router/integration reachable) |

## Priority (regulatory-driven)

1. **IMPL-1 / GAP-064 adverse-media** — MLR 2017 Reg.28 EDD, **mandatory** → FIRST.
2. **IMPL-2 / GAP-068 crypto-AML graph** — GAP-021 fraud reduction.
3. **IMPL-3 / GAP-069 voice-AI** — support automation.
4. **IMPL-4 / GAP-070 quant advisory** — advisory-only (MiCA), lowest regulatory urgency.

## Method (per sprint)

`spec → code in banxe-emi-stack → tests (ruff/mypy/pytest) green → PR in banxe-emi-stack`
`→ IL shard in banxe-architecture ref its GAP → guardian green → sign-on-merge (operator approves each merge).`

Guardrails: ADR-052; **HITL on every compliance decision**; no secrets; **advisory-only** for quant (no live execution).

## Sprints

### IMPL-1 / GAP-064 — adverse-media  *(L1 → L2/L3)*
- **ADR/passport:** `adverse_media_governor` (PROPOSED).
- **Build** `banxe-emi-stack/services/adverse_media/`:
  - feed adapter (news/sanctions adverse-media source) — **reuse existing screening** (watchman / yente);
  - NLP entity-match (name/alias/entity resolution against customer records);
  - EDD integration via **Ballerine** flow;
  - **Marble** case opened on hit;
  - **ClickHouse** audit trail of every screen + decision.
- **Compliance:** MLRO **HITL** gate before any EDD/offboard action.
- **Tests:** unit (entity-match, feed parse) + integration (hit→Marble case) + HITL gate.
- **Exit:** L3 — adverse-media screen reachable in app, hit path wired to Marble + ClickHouse.

### IMPL-2 / GAP-068 — crypto-AML graph  *(L1 → L2)*
- **ADR-111.** Extends existing **Marble / Jube**.
- **Build** `banxe-emi-stack/services/crypto_aml_graph/`:
  - **GraphSense** client;
  - **Neo4j** adapter (address/tx graph store);
  - **CIOH** (common-input-ownership-heuristic) clustering;
  - **GraphSAGE** inference **stub** (interface + deterministic stub; model wiring later);
  - ensemble **blacklist feed** output into the existing AML decisioning.
- **Tests:** clustering correctness + blacklist feed contract + Neo4j adapter (testcontainer/stub).
- **Exit:** L2 — code + tests; L3 (live Neo4j) tracked as follow-up.

### IMPL-3 / GAP-069 — voice-AI support  *(L1 → L2)*
- **ADR-112.**
- **Build** `banxe-emi-stack/services/voice_support/`:
  - **LiveKit / Pipecat** gateway (telephony/RTC seam);
  - **Faster-Whisper** ASR + TTS;
  - transcript → **Presidio** PII redaction;
  - **Chatwoot** integration (ticket/conversation);
  - recording / retention compliance + **consent gate** before capture.
- **Tests:** ASR pipeline contract + PII redaction + consent-gate enforcement.
- **Exit:** L2 — code + tests; live telephony L3 follow-up.

### IMPL-4 / GAP-070 — quant advisory  *(L1 → L2, advisory-seam only)*
- **ADR-113.** **MiCA: advisory-only — NO live execution.**
- **Build** `banxe-emi-stack/services/quant_advisory/`:
  - **Heston** ADI pricer;
  - **SABR / SVI** volatility surface;
  - **Avellaneda-Stoikov** optimal spread;
  - **Greeks / VaR** API (read-only advisory seam) — **QuantLib**.
- **Tests:** pricer numerics + surface calibration + advisory-seam (asserts no execution path).
- **Exit:** L2 — code + tests; advisory endpoints only.

## Tracking

- New gap: **GAP-076** (this roadmap).
- Each IMPL sprint files its own IL shard in `banxe-architecture` referencing its GAP (064/068/069/070) on merge.
- Verdict deltas close as each feature reaches L2/L3 in the next audit pass.
