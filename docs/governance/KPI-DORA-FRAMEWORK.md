# KPI / DORA Metrics Governance Framework

**Sprint:** S3 · **Date:** 2026-06-22 · **Status:** GOVERNANCE-ONLY (no live metric collection)
**Driver:** KPI/DORA governance is currently **PARTIAL** — KPI *targets* are declared in ADR-117, but **no metric collection** exists in the repo.
**Principle:** Operator = canon, supreme over docs. No facts are invented. Every value not asserted by a repo source is marked **AWAITS OPERATOR**.

---

## 1. Purpose & Scope

This document establishes the **governance frame** for two metric families used to measure delivery
and engineering health of the BANXE AI Bank platform:

1. **DORA metrics (4)** — software delivery performance (per target model §10 "KPI Dashboard").
2. **ADR-117 KPIs (5)** — code-quality / merge-gate targets (per ADR-117, recorded verbatim in
   `docs/governance/CANON-RECONCILIATION-ADR117.md` line 26).

**In scope:** metric definitions, target bands (only where asserted by a repo source), the structural
dashboard model, on-prem residency constraint, and RACI ownership.

**Out of scope (this sprint):** any metric **collection** implementation (exporters, scrapers,
pipelines), dashboard data-source wiring, and numeric targets not asserted in the repo. These are
enumerated in the **Open-Items Register (§7)** as **AWAITS OPERATOR**.

This is a normative pointer document. It does **not** duplicate ADR-079 (the existing read-only
risk-metrics port) or the target-model definitions — it **references** them.

---

## 2. DORA Metrics (4)

Source: **target model §10 "KPI Dashboard"** (operator-held reference — the 4 metric names below are
the operator-asserted set for this sprint). DORA = the four standard DevOps Research & Assessment
delivery metrics. **Numeric target bands are NOT asserted in any repo source → AWAITS OPERATOR.**

| # | Metric | Definition (standard DORA) | Target band |
|---|--------|----------------------------|-------------|
| D-1 | **Deployment Frequency** | How often the platform successfully releases to production. | AWAITS OPERATOR |
| D-2 | **Lead Time for Changes** | Time from code commit to that code running in production. | AWAITS OPERATOR |
| D-3 | **Change Failure Rate** | % of deployments causing a failure requiring remediation (rollback/hotfix). | AWAITS OPERATOR |
| D-4 | **MTTR — Mean Time to Restore** | Time to restore service after a production incident/failure. | AWAITS OPERATOR |

> No numeric DORA target (e.g. "elite/high band" thresholds) is asserted in the repo. The operator
> must supply target bands before these become enforceable. Until then they are **definitional only**.

---

## 3. ADR-117 KPIs (5)

Source: **ADR-117**, recorded verbatim in `docs/governance/CANON-RECONCILIATION-ADR117.md` (line 26).
These five carry **repo-asserted numeric targets** (unlike the DORA bands above).

| # | KPI | Target (verbatim, ADR-117) |
|---|-----|----------------------------|
| K-1 | Test coverage | **≥ 85%** |
| K-2 | Tech-debt ratio | **< 5%** |
| K-3 | Blocker / critical issues on merge | **0** |
| K-4 | Security-hotspot review | **≥ 95%** |
| K-5 | MTTD — Mean Time To Detect | **< 24h** |

> Per `CANON-RECONCILIATION-ADR117.md` line 26, these KPIs are "recorded for reference; **enforcement
> is a follow-up factory work item**." This framework is that follow-up's governance anchor; the
> enforcement/collection mechanism itself remains **AWAITS OPERATOR** (§7).

---

## 4. Metric Collection Architecture

**Status: NO asserted collection implementation exists in the repo for KPI/DORA metrics.**

### 4.1 Existing reference — do NOT duplicate

- **ADR-079 — CRO RiskMetricsPort** (`docs/adr/ADR-079-cro-risk-metrics-port.md`): an existing
  **read-only hexagonal port** (`services/risk/risk_metrics_port.py`, abc.ABC + InMemory impl +
  `RiskMetricsPortError`) for **risk** metrics (aggregate exposure, fraud/AML monitoring). It is the
  established read-only-port-first pattern in this codebase.
  - **This framework POINTS to ADR-079 as the architectural precedent** for a read-only metrics port.
    A KPI/DORA collection port, if/when built, SHOULD mirror that shape (read-only contract,
    abc.ABC + impl, dedicated error type). ADR-079 is **risk-scoped**, not delivery-scoped — KPI/DORA
    collection is a **distinct, not-yet-existing** surface and MUST NOT overload the risk port
    (ADR-102 anti-duplication).

### 4.2 Collection pipeline / tooling — AWAITS OPERATOR

The concrete collection stack (e.g. Prometheus / Grafana / OpenTelemetry / CI-event ingestion, or any
alternative) is **NOT asserted anywhere in the repo**. Tooling selection, exporters, retention, and
scrape/ingest cadence are all **AWAITS OPERATOR** (§7). No tool is named normatively here to avoid
inventing facts.

### 4.3 On-prem residency constraint (asserted)

Any future KPI/DORA collection MUST respect the on-prem perimeter:

- `docs/compliance/ai-data-flow.md` (line 19): *"All AI inference for regulated workloads MUST run
  on-prem (evo1/evo2)."* Total pool 256 GB RAM, **fully on-prem**.
- `docs/DEPLOYMENT-ARCHITECTURE.md` + ADR-117: Project = cluster evo1/evo2; Factory = Legion.

**Constraint:** metric data (and any inference over it) MUST remain on the **Project cluster
(evo1/evo2)** — no metric export to off-prem/SaaS observability backends. This is a hard residency
boundary, not a preference.

---

## 5. Dashboard Model (structural)

Structural panel→metric mapping only. **Data-source wiring for every panel is AWAITS OPERATOR**
(no collection exists yet, §4.2).

| Panel | Metric(s) | Source family | Data wiring |
|-------|-----------|---------------|-------------|
| P-1 Delivery Velocity | D-1 Deployment Frequency, D-2 Lead Time | DORA (§2) | AWAITS OPERATOR |
| P-2 Delivery Stability | D-3 Change Failure Rate, D-4 MTTR | DORA (§2) | AWAITS OPERATOR |
| P-3 Code Quality Gate | K-1 coverage, K-2 tech-debt, K-3 blocker/critical | ADR-117 (§3) | AWAITS OPERATOR |
| P-4 Security Posture | K-4 security-hotspot | ADR-117 (§3) | AWAITS OPERATOR |
| P-5 Detection | K-5 MTTD | ADR-117 (§3) | AWAITS OPERATOR |

> The dashboard surface itself — if implemented as a read-only aggregation agent — would parallel the
> ADR-079 `RiskOversightAgent` posture (**L1-Auto, read-only, decides nothing**). That agent design is
> **not in scope here** and is **AWAITS OPERATOR**.

---

## 6. Roles & RACI

Ownership per `docs/JOB-DESCRIPTIONS.md` and `docs/ORG-STRUCTURE.md`. Only roles asserted in the repo
are bound; others are **AWAITS OPERATOR** (the task names "COO / VP Platform Eng / SRE", but only the
COO function is asserted in the repo today).

| Function | Repo status | RACI (proposed) |
|----------|-------------|-----------------|
| **COO (SMF24)** | **Asserted** — `ORG-STRUCTURE.md` §2.6, `JOB-DESCRIPTIONS.md` §1.5 | **A** — Accountable for operational KPI/DORA oversight |
| **VP Platform Engineering** | **NOT asserted** in repo | AWAITS OPERATOR (intended **R** — owns metric pipeline) |
| **SRE / Site Reliability** | **NOT asserted** in repo | AWAITS OPERATOR (intended **R** — owns DORA stability metrics D-3/D-4, MTTD) |

> The RACI letters above for COO are a **proposed** governance allocation, not an ADR-117 assertion.
> VP Platform Eng and SRE roles do **not** exist in `ORG-STRUCTURE.md`/`JOB-DESCRIPTIONS.md` as of this
> sprint — their creation and exact KPI/DORA ownership are **AWAITS OPERATOR**.

---

## 7. Open-Items Register (AWAITS OPERATOR)

| ID | Open item | Blocking |
|----|-----------|----------|
| OI-1 | DORA numeric target bands (D-1..D-4) — none asserted in repo | Makes DORA metrics enforceable |
| OI-2 | Collection pipeline / tooling selection (exporters, scrape/ingest, retention) | Any actual metric collection |
| OI-3 | Dashboard data-source wiring for panels P-1..P-5 | Live dashboard |
| OI-4 | KPI/DORA collection port — build mirroring ADR-079 shape? (delivery-scoped, separate from risk port) | Architectural decision (likely new ADR) |
| OI-5 | VP Platform Engineering role creation + RACI binding | Pipeline ownership (R) |
| OI-6 | SRE role creation + RACI binding | Stability-metric ownership (R) |
| OI-7 | ADR-117 KPI enforcement mechanism (the "follow-up factory work item" per CANON-RECONCILIATION-ADR117 line 26) | Gate enforcement of K-1..K-5 |
| OI-8 | Confirmation of on-prem observability backend on Project cluster (evo1/evo2) | Residency-compliant collection |

---

## 8. Provenance Footer

- **Sprint:** S3 · **Branch:** `agent/factory/kpidora/s3-kpi-dora-framework` · **Base:** `origin/main`
  (id segment `kpidora` — alphanumeric per ADR-060 `guardian-branch-naming`; the hyphenated `kpi-dora` would fail the `[A-Za-z0-9]+` id rule)
- **Authored:** 2026-06-22 (governance-only; no live metric collection; DO NOT MERGE without operator review).
- **Cited sources (not duplicated):**
  - `docs/governance/CANON-RECONCILIATION-ADR117.md` (line 26 — 5 ADR-117 KPIs verbatim)
  - `docs/adr/ADR-079-cro-risk-metrics-port.md` (existing read-only risk-metrics port — referenced, not duplicated)
  - target model §10 "KPI Dashboard" (operator-held reference — 4 DORA metric names)
  - `docs/JOB-DESCRIPTIONS.md` §1.5, `docs/ORG-STRUCTURE.md` §2.6 (COO SMF24 ownership)
  - `docs/DEPLOYMENT-ARCHITECTURE.md` + `docs/compliance/ai-data-flow.md` (on-prem perimeter; metrics stay on Project cluster evo1/evo2)
- **Invented facts:** NONE. All non-asserted values marked AWAITS OPERATOR (§7).
- **Canon:** ADR-056/059/060 (ledger), ADR-102 (anti-duplication), ADR-117 (perimeter/KPIs). Append-only ledger shard couples this file.
