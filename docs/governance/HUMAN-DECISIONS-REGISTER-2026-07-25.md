# HUMAN DECISIONS REGISTER — 2026-07-25

**GOVERNANCE / HUMAN & LEGAL DECISIONS / DOCS-ONLY / NO COMMIT**

Single register of everything the General Line hands to **humans / lawyers** — decisions no automated code
may make (I-27: AI proposes, human decides; SM&CR). Consolidated from existing registers, not invented.
Sources: `FABLE5-IDEAL-BANK-TECHMAP-GAP-2026-07-25.md`, `GOVERNANCE-GAP-CLOSURE-2026-07-25.md`,
`FABLE5-CONSULTATION-RESPONSE-2026-07-25.md` (CODE-PLACEMENT-MATRIX),
`GL13-EXEC-BATCH-REPORT-2026-07-25.md`, `OPEN-GOVERNANCE-APPOINTMENTS-2026-07-25.md`,
`BANK-GOVERNANCE-COMMITTEES-2026-07-25.md`.

## §1 Purpose

The General Line has closed **100% of what is automatable** (build, placement, docs, committee charters,
three-lines overlay). What remains is the **human/legal residue** — regulated appointments, gated code
decisions, placement ratifications, and optional/deferred cutovers. This is one place to see all of it.
Nothing here can be actioned by an agent (I-27 / SM&CR).

## §2 REGULATED APPOINTMENTS `[counsel + FCA/HR]`

| ID | role | why a human (not code) | decision owner |
|---|---|---|---|
| A-01 | **CCO / SMF16** (distinct from MLRO) | Regulated senior-manager function — person must be fit-and-proper-assessed & FCA-registered | Board + FCA `[counsel]` |
| A-02 | **DPO** (GDPR Art.37) | Statutory role (internal or external), formal designation/registration | Board + `[counsel]` |
| A-03 | **Head of Legal** (independent of HR) | Org/HR structural decision + GC independence | CEO/Board `[pending ratification]` + `[counsel]` |
| A-04 | **NED chairs — 8 committees** (Board Risk, Audit, ALCO, Credit, Product-Gov, Consumer-Duty, Op-Risk, SMCR) | Committees are chartered on paper; live operation needs appointed (often non-executive) chairs & first meetings | Board `[pending ratification]` |

Charters exist (`BANK-GOVERNANCE-COMMITTEES`); **charters ≠ operating committees** until A-04 is done.

## §3 GATED CODE DECISIONS `[counsel]`

| ID | item | what needs a legal/counsel decision |
|---|---|---|
| GC-01 | domain `ledger` | live ledger read/write (Midaz CBS) — CASS 15.3 exposure |
| GC-02 | domain `midaz_mcp` | live MCP→Midaz ledger calls |
| GC-03 | domain `crypto_custody` | wallet/custody ledger-write; crypto exposure |
| GC-04 | domain `regulatory_reporting` | live RegData/FIN060 submission to FCA |
| GC-05 | domain `banking-engine` | Banksy CBS integration / Midaz adapter (balance + write) |
| GC-06 | domain `compliance_kb` | regulatory-guidance KB (RAG) — advice liability |
| GC-07 | 3 `[counsel-ref]` files | `reporting/fin060_generator_v2.py`, `reporting/reporting_agent.py`, `gabriel/regdata_gabriel_adapter.py` — placed read-side; **live submission** under counsel |
| GC-08 | **write-path tools** | `initiate_payment` / Midaz→ledger MCP write — declared live but **never auto-executed**; each live write needs counsel + HITL-L4 |

All above located by placement but **never authorized for live execution** by placement (placement ≠ authorization).

## §4 PLACEMENT RATIFICATIONS `[pending human ratification]`

**7 batch-deferred domains** (from BATCH-REPORT) — placement options + recommendation:

| ID | domain | options | recommendation |
|---|---|---|---|
| PR-01 | `incident_response` | F4-security vs F4-audit-cell | F4-security (1st-line ops) + Op-Risk Committee oversight |
| PR-02 | `insurance` | F1 (product) vs F2 (banking) | new product line — Product-Gov Committee scope |
| PR-03 | `lending` | F2-payments vs new credit room | under Credit Committee (C4); dormant until lending ratified |
| PR-04 | `producers` | F4-devops (infra) vs F4-ai-platform | F4-devops (event producers) |
| PR-05 | `runtime_gate` | F4-security vs F4-devops | F4-security (runtime policy gate) |
| PR-06 | `sandbox` | F4-devops vs F4-ai-platform | F4-devops (test/isolation infra) |
| PR-07 | `savings` | F2-payments vs F1 (product) | F2-payments (banking product) |

**Other ratifications:**
| ID | item | question |
|---|---|---|
| PR-08 | client-mask placement | F2-payments vs F0 engine client-PM layer (ADR-049 6 masks) |
| PR-09 | AML-passport dedup | consolidate duplicate AML agent passports |
| PR-10 | Legal/HR separation | split F1-hr-legal into Head-of-Legal (→CEO) + Head-of-HR (→COO) |

## §5 OPTIONAL / DEFERRED (non-blocking)

| ID | item | status |
|---|---|---|
| OD-01 | prod-inference wiring (GL-post-20) | PENDING `[prod-inference]` — real LLM/MCP/ledger live |
| OD-02 | live MCP **write**-cutover | read-path LIVE; write-cutover deferred `[counsel]` |
| OD-03 | GL-canon items | descriptive canon, non-blocking |
| OD-04 | 3 room-mapping | already RESOLVED (compliance* → F3-aml) — no action |

## §6 SUMMARY

| category | count | addressee |
|---|---|---|
| Regulated appointments (§2) | 4 | `[counsel]` + FCA/HR + Board |
| Gated code decisions (§3) | 8 | `[counsel]` |
| Placement ratifications (§4) | 10 | `[operator / human ratification]` |
| Optional / deferred (§5) | 4 | operator (non-blocking) |
| **Total human/legal decisions** | **26** | humans only |
| **Decisions left to auto-code** | **0** | — |

**Verdict:** the General Line has closed 100% of the automatable scope. The remaining **26 items are
human/legal decisions** (I-27 / SM&CR) — none can be actioned by an agent. This register is the single
hand-off to people/lawyers.

---
**This does not replace legal advice.**
