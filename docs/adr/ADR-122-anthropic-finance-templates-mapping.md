---
id: ADR-122
title: Mapping Anthropic finance agent templates → BANXE factory (skills/connectors/subagents)
status: ACCEPTED
date: 2026-06-26
accepted: 2026-06-26
supersedes: []
related:
  - "docs/SKILLS-MATRIX.md (10 skills bound to passports — the 'skills' layer)"
  - "agents/passports/*.yaml (57 passports — the 'subagents' layer)"
  - ".claude/rules/agents.md (orchestration tree + swarm types)"
  - "ADR-102 (no-duplication — basis for the no-fork decision)"
il_anchor: IL-539
scope: BANXE-only
concept_only: true
---

# ADR-122 — Mapping Anthropic finance agent templates → BANXE factory (skills/connectors/subagents)

## Context

On **2026-05-05** Anthropic published **10 finance agent templates** (reference architectures), each
structured as a **3-layer pattern: skills + connectors + subagents**, delivered as a Claude
Cowork/Claude Code **plugin** + a Managed-Agents cookbook (`github.com/anthropics/financial-services`,
`anthropic.com/news/finance-agents`):

> Pitch builder · Meeting preparer · Earnings reviewer · Model builder · Market researcher ·
> Valuation reviewer · General ledger reconciler · Month-end closer · Statement auditor · KYC screener.

The BANXE factory **already implements the same 3-layer pattern natively**, on its own canon:

| Anthropic layer | BANXE equivalent (already in repo) |
|---|---|
| **Skills** | `docs/SKILLS-MATRIX.md` — 10 skills bound to **57/57 passports** (`make skills-audit` unbound=0); `docs/SKILLS-OPERATING-MODEL.md` |
| **Connectors** | adapter passports + hexagonal ports: `jube_adapter`, `watchman_adapter`, `yente_adapter`, `midaz_mcp_agent`, `clickhouse_writer`, and `ports:` blocks in passports (PolicyPort/AuditPort/DecisionPort/…) |
| **Subagents** | orchestration tree (`.claude/rules/agents.md`): L1 orchestrator → L2 sub-agents, e.g. `banxe_aml_orchestrator` → `aml_orchestrator` / `sanctions_check` / `tx_monitor` / `crypto_aml`; `agents/souls/` (19), `agents/swarms/` (3) |

The question this ADR answers: **how do the 10 Anthropic templates map onto the existing BANXE agent
layer, and do we fork `anthropics/financial-services`?** (The repo has remote `origin` only; no fork/upstream.)

## Decision

**1. DO NOT fork `anthropics/financial-services`.** Borrow **only the 3-layer reference pattern**
(skills + connectors + subagents) as a conceptual checklist, **applied where a gap exists**. Rationale
(ADR-102, no-duplication): BANXE already implements the 3-layer pattern on its own governed canon
(passports/souls/swarms + SKILLS-MATRIX + ports/adapters); forking would duplicate an external,
differently-governed agent set, cross the perimeter (ADR-117), and bypass passport/skill governance
(I-27/I-28). No external code, plugin, or template is imported.

**2. Map each template to the existing BANXE agent(s); fill gaps only as future PROPOSED passports**
(I-27), not by import. The compliance/reconciliation/audit/KYC templates map **strongly** to existing
agents (BANXE is an EMI compliance-first factory); the front-office/finance-analyst templates are
**partial gaps** (BANXE has dept-head stubs, not analyst agents).

### Mapping table (10 templates → BANXE agent/passport → gap)

| # | Anthropic template | BANXE agent(s) / passport (existing) | Layer coverage | Gap |
|---|---|---|---|---|
| 1 | **Pitch builder** | `front_office_agent` (Front Office/Business, CCO — stub) | subagent stub only | **GAP** — no pitch/deck-generation skill; dept-head stub, no analyst capability |
| 2 | **Meeting preparer** | `board_reporting_agent`, `ceo_orchestration_agent` (stubs) | subagent stub | **GAP** — no dedicated meeting-prep/briefing agent |
| 3 | **Earnings reviewer** | `cfo_orchestration_agent` + `reporting_agent` (FCA reg reporting) + `board_reporting_agent` | subagents present | **PARTIAL** — management-accounts/reg reporting present; no earnings-review analyst (EMI ≠ listed) |
| 4 | **Model builder** | `treasury_alm_agent` (liquidity/FX/ALM modelling), `ml_pipeline_agent` | subagent + skills | **PARTIAL** — ALM/ML modelling present; no general financial-model-builder |
| 5 | **Market researcher** | **MiroFish** research swarm (`.claude/rules/agents.md`), `experiment_copilot_agent` | swarm + subagent | **PARTIAL** — research swarm exists; no market-research domain agent |
| 6 | **Valuation reviewer** | `risk_oversight_agent` (2nd line), `cfo_orchestration_agent` | subagent stub | **PARTIAL/GAP** — risk oversight present; no valuation-review agent |
| 7 | **General ledger reconciler** | `safeguarding_recon_governor` + `clickhouse_writer` + `midaz_mcp_agent` (Midaz ledger) + CASS-15 daily recon | **all 3 layers** | **PRESENT** — strong (safeguarding reconciliation is core CASS-15) |
| 8 | **Month-end closer** | `cfo_orchestration_agent` + `reporting_agent` + `safeguarding_recon_governor` | subagents present | **PARTIAL** — components present; no month-end-close orchestration flow |
| 9 | **Statement auditor** | `internal_audit_agent` (3rd line, Grant Thornton) + `safeguarding_audit_agent` + `reporting_agent` | **all 3 layers** | **PRESENT** — strong (independent audit chain) |
| 10 | **KYC screener** | `sanctions_check` + `watchman_adapter` + `yente_adapter` + `adverse_media_governor` + `aml_orchestrator` + `banxe_aml_orchestrator` + `tx_monitor` + `crypto_aml` + `jube_adapter` + `case_management_agent` | **all 3 layers** (skills + connectors + subagent tree) | **PRESENT** — strongest; full AML/KYC stack |

**Summary:** PRESENT 3 (GL reconciler, Statement auditor, KYC screener — BANXE's compliance core);
PARTIAL 5 (Earnings reviewer, Model builder, Market researcher, Valuation reviewer, Month-end closer);
GAP 2 (Pitch builder, Meeting preparer — front-office analyst agents BANXE does not have). The
3-layer pattern is **fully present** for the compliance templates and **partially** for the
finance-analyst templates.

**3. Gap-closure is future, PROPOSED-only, no import.** Where a gap is worth closing, author a new
**PROPOSED passport** (I-27) following the existing S-FAC-64 binding pattern (allowed_skills +
ports/connectors + subagent placement) — using the 3-layer pattern as a design checklist, **not** by
copying Anthropic templates. Any such passport stays PROPOSED until operator activation.

## AWAITS OPERATOR (open questions — not asserted here)

- **Connectors to live/production data.** The Anthropic templates connect to real financial data
  sources; BANXE connectors to **boevые/production data** are **AWAITS OPERATOR** (perimeter: ADR-117
  factory=Legion no customer data; regulated data on evo1/evo2; on-prem inference hard rule).
- **KYC/AML regulatory regulations.** Which screening lists, EDD rules, risk thresholds, and SAR
  workflow bind the KYC-screener mapping is an **operator/MLRO** decision (MLR 2017, FCA) — **AWAITS
  OPERATOR**; not inferred from the external templates.
- **Whether to build the GAP analyst agents** (Pitch builder, Meeting preparer, and the PARTIAL set)
  is an operator/product decision — these are front-office capabilities outside the current
  compliance-first scope.
- **Numeric thresholds / model classification** for any new finance agent remain operator/CRO (MRM §6).

## Consequences

- **Positive:** the external reference is captured as governance (a mapping + a design checklist)
  without forking, without crossing the perimeter, and without bypassing passport/skill governance.
  Confirms BANXE's compliance core (KYC/recon/audit) already matches the strongest external templates.
- **Cost:** the 2 GAP + 5 PARTIAL front-office/analyst templates are not delivered by this ADR (by
  design — they are PROPOSED future work, operator-gated).
- **No code / no fork:** this ADR is `concept_only` — it adds a decision + mapping, no agent code, no
  import, no plugin.

## Anchors

- `github.com/anthropics/financial-services`, `anthropic.com/news/finance-agents` (2026-05-05; external reference only).
- `docs/SKILLS-MATRIX.md`, `docs/SKILLS-OPERATING-MODEL.md` (skills layer); `agents/passports/` (57), `agents/souls/` (19), `agents/swarms/` (3); `.claude/rules/agents.md` (orchestration + swarm types); `banxe-subagent-context.md`.
- ADR-102 (no-duplication — basis for no-fork); ADR-117 (perimeter); I-27 (PROPOSED-only); I-28 (ledger).
- Ledger: IL-539 (this ADR's instruction record).
