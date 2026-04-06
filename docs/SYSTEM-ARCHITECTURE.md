# System Architecture Document (SAD) — Banxe AI Bank EMI

**Version:** 1.0
**Date:** 2026-04-06
**Status:** LIVING DOCUMENT — updated each sprint
**Author:** Architecture Team (CEO + CTIO)
**Scope:** UK FCA-authorised EMI (Electronic Money Institution)

---

## 1. Purpose and Scope

This document describes the technical architecture of the BANXE AI Bank platform at C4 Level 1 (System Context) and C4 Level 2 (Containers). It is the primary reference for:

- FCA regulatory submissions requiring technical architecture evidence
- Onboarding new developers and partners
- Evaluating architectural changes against the 27 invariants (INVARIANTS.md)
- Understanding service boundaries and trust zones (governance/trust-zones.yaml)

---

## 2. C4 Level 1 — System Context

```
                          ┌──────────────────────────────────────────────────────────────┐
                          │              BANXE AI Bank Platform                           │
                          │              (FCA-authorised EMI)                             │
                          │                                                                │
  ┌──────────┐            │   ┌──────────────┐   ┌───────────────┐   ┌──────────────┐   │
  │  Bank     │  KYC/AML   │   │   AI Layer   │   │  Compliance   │   │  Core Banking │   │
  │ Customers │────────────►  │  (Ollama +   │   │  Stack        │   │  Engine       │   │
  │(Individuals│  payments  │   │  OpenClaw)   │   │  (FastAPI +   │   │  (Midaz +     │   │
  │ Business) │            │   └──────────────┘   │  Screener +   │   │  ClickHouse)  │   │
  └──────────┘            │                       │  Marble)      │   └──────────────┘   │
                          │                       └───────────────┘                       │
  ┌──────────┐            │                                                                │
  │ CEO/MLRO  │  approve   │   ┌──────────────────────────────────────────────────────┐   │
  │(M. Carmi) │────────────►  │  HITL Oversight (Marble UI :5003 + Telegram bots)     │   │
  └──────────┘            │   └──────────────────────────────────────────────────────┘   │
                          │                                                                │
  ┌──────────┐            └───────────────────────────────────────────────────────────────┘
  │  CTIO    │  deploy/                    │                 │               │
  │  (Oleg)  │──configure                  │                 │               │
  └──────────┘                             │                 │               │
                                           │                 │               │
  ┌──────────┐  audit/               ┌─────▼──────┐  ┌──────▼──────┐  ┌────▼────────┐
  │  FCA     │  reporting            │  Watchman  │  │    Jube TM  │  │  Marble     │
  │(Regulator)│◄──────────────────── │  :8084     │  │  :5001      │  │  :5002/5003 │
  └──────────┘                      │ (Sanctions) │  │  (Tx Mon.)  │  │  (Cases)    │
                                    └────────────┘  └─────────────┘  └─────────────┘
                                           │
                          ┌────────────────┼────────────────────────────────┐
                          │                │                                │
                   ┌──────▼──────┐  ┌──────▼──────┐  ┌──────────────────┐
                   │  Companies  │  │  Chainalysis │  │  OpenSanctions   │
                   │  House API  │  │  (Crypto AML)│  │  /Yente :8086    │
                   │  (KYB)      │  │              │  │  (Phase 3)       │
                   └────────────┘  └─────────────┘  └──────────────────┘
```

### Actors

| Actor | Type | Role | Access |
|-------|------|------|--------|
| CEO / MLRO (Mark Carmi) | Internal human | Final approver for HOLD/SAR decisions, FCA contact, SOUL.md governance | Marble UI, Telegram @mycarmi_moa_bot, SSH |
| CTIO (Oleg) | Internal human | Technical owner, GMKtec operations, training pipeline, deployment | SSH, all services, sudo NOPASSWD |
| FCA (Regulator) | External regulator | EMI authorisation, audit rights, FIN-RPT consumer | FCA Gabriel/RegData (n8n workflow output) |
| Bank Customers — Individuals | External | e-money accounts, payments, KYC subjects | Onboarding UI (planned), payment APIs |
| Bank Customers — Businesses | External | KYB subjects, business accounts, bulk payments | KYB API (planned), Marble CM |
| Watchman | External system | OFAC/UN/EU/UK sanctions list screening | REST API :8084 |
| Jube TM | External system (internal deploy) | Probabilistic transaction monitoring (AGPLv3, reference only) | REST API :5001 |
| Marble | External system (internal deploy) | Case management, MLRO triage (ELv2, internal only) | REST API :5002, UI :5003 |
| Companies House | External API | KYB — UK company verification, director/UBO lookup | HTTPS API |
| Chainalysis | External API (planned) | Crypto wallet sanctions screening | HTTPS API (Phase 3) |
| OpenSanctions / Yente | External system | Primary sanctions + PEP database (200K+ entities) | REST API :8086 (Phase 3) |

---

## 3. C4 Level 2 — Containers

### 3.1 AI Layer

```
┌────────────────────────────────────────────────────────────┐
│                        AI Layer                             │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Ollama :11434                                       │  │
│  │  Models: qwen3-banxe-v2 (supervisor/kyc/compliance) │  │
│  │          glm-4.7-flash (client-service/ops)          │  │
│  │          gpt-oss-derestricted:20b (analytics)        │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌───────────────────┐  ┌───────────────────┐             │
│  │ OpenClaw moa-bot  │  │ OpenClaw ctio-bot  │             │
│  │ :18789            │  │ :18791             │             │
│  │ @mycarmi_moa_bot  │  │ Oleg's bot         │             │
│  │ MLRO operator     │  │ CTIO operator      │             │
│  └───────────────────┘  └───────────────────┘             │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Auto-Verify API :8094                               │  │
│  │  Agent response verification (I-09)                  │  │
│  └─────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

| Container | Port | Tech | Purpose |
|-----------|------|------|---------|
| Ollama | 11434 | MIT | LLM inference engine, 3 active models |
| OpenClaw moa-bot | 18789 | Commercial | Telegram gateway, @mycarmi_moa_bot, MLRO assistant |
| OpenClaw ctio-bot | 18791 | Commercial | Telegram gateway, CTIO (Oleg) assistant |
| OpenClaw @mycarmibot | 18793 | Commercial | Separate project (do not modify) |
| Auto-Verify API | 8094 | FastAPI | Validates compliance/AML agent responses (I-09) |

### 3.2 Compliance Layer

```
┌────────────────────────────────────────────────────────────┐
│                    Compliance Layer                         │
│                                                            │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │  FastAPI :8093  │  │  PII Proxy :8089 │                 │
│  │  AML/KYC/       │  │  Presidio        │                 │
│  │  Sanctions API  │  │  GDPR anonymiser │                 │
│  └────────┬────────┘  └─────────────────┘                 │
│           │                                                │
│  ┌────────▼────────────────────────────────────────────┐  │
│  │  banxe_aml_orchestrator.py (Layer 1)                 │  │
│  │  Calls: Contour 1-5 via developer-core validators    │  │
│  └────┬──────────┬──────────┬─────────────────┬────────┘  │
│       │          │          │                 │           │
│  ┌────▼───┐ ┌────▼───┐ ┌───▼────┐      ┌─────▼──────┐   │
│  │Sanctions│ │Watchman│ │  Jube  │      │ Screener   │   │
│  │Check   │ │:8084   │ │  :5001 │      │ :8085      │   │
│  │(local) │ │(OFAC/  │ │  (TM   │      │ (Watchman+ │   │
│  │        │ │UN/EU)  │ │  ML)   │      │  PEP wrap) │   │
│  └────────┘ └────────┘ └────────┘      └────────────┘   │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Deep Search :8088                                   │  │
│  │  Compliance research assistant                       │  │
│  └─────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

| Container | Port | License | Purpose |
|-----------|------|---------|---------|
| FastAPI compliance | 8093 | Proprietary | AML/KYC/Sanctions REST API (Contours 1-5) |
| PII Proxy (Presidio) | 8089 | MIT | GDPR-compliant PII anonymisation before logging |
| Moov Watchman | 8084 | Apache 2.0 | OFAC/UN/EU/UK sanctions list screening |
| Banxe Screener | 8085 | Proprietary | Watchman + PEP wrapper service |
| Jube TM | 5001 | AGPLv3 | Probabilistic TM (I-15: reference only, internal) |
| Deep Search | 8088 | Proprietary | Compliance research and adverse media |
| Yente (OpenSanctions) | 8086 | MIT | Primary sanctions/PEP — 200K+ entities (Phase 3) |

### 3.3 Core Banking / CBS Layer

```
┌────────────────────────────────────────────────────────────┐
│                   Core Banking Layer                        │
│                    (Deploying Sprint 8-9)                   │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  LedgerPort Interface (adapter — to be built)        │  │
│  └──────────────┬──────────────────┬───────────────────┘  │
│                 │                  │                       │
│        ┌────────▼─────┐  ┌─────────▼──────┐              │
│        │  Midaz :8095  │  │ Apache Fineract │              │
│        │  (PRIMARY GL) │  │ (FALLBACK CBS)  │              │
│        │  LerianStudio │  │                 │              │
│        └────────┬──────┘  └─────────────────┘             │
│                 │                                          │
│        ┌────────▼──────────────────────────────────┐      │
│        │  PostgreSQL (compliance) :5432             │      │
│        │  PostgreSQL (Jube) :15432                  │      │
│        │  PostgreSQL (Marble) :15433                │      │
│        └───────────────────────────────────────────┘      │
│                                                            │
│        ┌──────────────────────────────────────────┐       │
│        │  RabbitMQ (planned — payment event bus)   │       │
│        └──────────────────────────────────────────┘       │
└────────────────────────────────────────────────────────────┘
```

| Container | Port | License | Status | Purpose |
|-----------|------|---------|--------|---------|
| Midaz (LerianStudio) | 8095 | Apache 2.0 | Deploying | PRIMARY General Ledger (ADR-014) |
| Apache Fineract | — | Apache 2.0 | FALLBACK | CBS fallback if Midaz insufficient |
| PostgreSQL (compliance) | 5432 | PostgreSQL | Active | PEP (14,491 entities), KYB entities |
| PostgreSQL (Jube) | 15432 | PostgreSQL | Active | Jube TM internal storage |
| PostgreSQL (Marble) | 15433 | PostgreSQL | Active | Marble case storage |
| RabbitMQ | — | MPL 2.0 | Planned | Payment event bus (Phase 3) |

### 3.4 Case Management — HITL Layer

```
┌────────────────────────────────────────────────────────────┐
│               Case Management / HITL Layer                  │
│                                                            │
│  ┌──────────────────────┐  ┌────────────────────────────┐ │
│  │  Marble API :5002     │  │  Marble UI :5003            │ │
│  │  Case management      │  │  MLRO Dashboard             │ │
│  │  backend              │  │  (mark@banxe.com)           │ │
│  └──────────┬────────────┘  └────────────────────────────┘ │
│             │                                              │
│  ┌──────────▼────────────────────────────────────────┐    │
│  │  HITL Bridge (scripts/hitl-bridge.sh)              │    │
│  │  AMLResult → Marble case + Telegram MLRO alert     │    │
│  └────────────────────────────────────────────────────┘    │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Firebase Emulator :9099/:4000                       │  │
│  │  Marble auth — local mode                            │  │
│  └─────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

| Container | Port | License | Purpose |
|-----------|------|---------|---------|
| Marble API | 5002 | ELv2 | Case management backend (I-19: internal only) |
| Marble UI | 5003 | ELv2 | MLRO triage dashboard |
| Firebase Emulator | 9099/4000 | Apache 2.0 | Marble authentication (local mode) |

### 3.5 Customer Onboarding

| Container | Port | License | Status | Purpose |
|-----------|------|---------|--------|---------|
| Ballerine | 3000 | MIT | Planned Sprint 10 | KYC orchestration workflow |
| KYB App | 5201 | Proprietary | Planned Sprint 11 | Business onboarding frontend |

### 3.6 Infrastructure / Data Layer

```
┌────────────────────────────────────────────────────────────┐
│                   Infrastructure Layer                      │
│                                                            │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  ClickHouse :9000 (TCP) / :8123 (HTTP)                 │ │
│  │  Apache 2.0 | FCA Audit Trail (TTL 5Y, I-08)           │ │
│  │  Tables: compliance_screenings, decision_events (+4)    │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌─────────────────┐  ┌─────────────────────────────────┐ │
│  │  Redis :6379     │  │  Redis (Jube) :16379             │ │
│  │  Velocity        │  │  Jube internal cache             │ │
│  │  monitoring 24h  │  │                                  │ │
│  └─────────────────┘  └─────────────────────────────────┘ │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  n8n :5678                                           │  │
│  │  Workflow automation — FIN-RPT, FSCS, Gabriel cron   │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  nginx :443/:80                                      │  │
│  │  Reverse proxy + TLS termination + Web UI           │  │
│  └─────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

| Container | Port | License | Purpose |
|-----------|------|---------|---------|
| ClickHouse | 9000/8123 | Apache 2.0 | FCA audit trail, analytics, TTL 5Y (I-08) |
| Redis | 6379 | BSD | Velocity monitoring, 24h TTL |
| Redis (Jube) | 16379 | BSD | Jube TM internal cache |
| n8n | 5678 | Fair-code | Workflow automation, regulatory reporting pipelines |
| nginx | 443/80 | MIT | Reverse proxy, TLS, Web UI |

---

## 4. Architecture Principles

### 4.1 Composable Compliance Architecture

The platform is structured around **6 independent compliance contours** (COMPOSABLE-ARCH.md), each replaceable without affecting the others. The shared contract between contours is `models.py` (RiskSignal, AMLResult, EvidenceBundle).

| Contour | Input → Output | Current Implementation | Status |
|---------|---------------|----------------------|--------|
| 1 — Onboarding / KYC | Documents → CustomerProfile | Manual KYC workflow | Active (Phase 3: PassportEye + DeepFace) |
| 2 — Screening | SanctionsSubject → RiskSignal | Watchman :8084 + Screener :8085 | Active (Yente Phase 3) |
| 3 — Transaction Monitoring | TransactionInput → RiskSignal[] | tx_monitor.py (9 deterministic rules) + Jube ref | Active |
| 4 — Case Management / Triage | AMLResult → Marble case | Marble :5002/:5003 + HITL bridge | Active |
| 5 — Audit / Reporting | AMLResult → ClickHouse | audit_trail.py + sar_generator.py | Active |
| 6 — Training / Feedback Loop | REFUTED corpus → policy patches | feedback_loop.py (supervised, human-applied) | Active |

### 4.2 Orchestration Flow

```
Customer Request
  → Contour 1 (KYC) → CustomerProfile
  → Contour 2 (Screening) → RiskSignal[]
  → Contour 3 (TM) → RiskSignal[]
  → banxe_aml_orchestrator.py → AMLResult + EvidenceBundle
      │
      ├─ HOLD/SAR → Contour 4 (Marble case + MLRO alert)
      │
      └─ Always → Contour 5 (ClickHouse audit, TTL 5Y)

Offline:
  Contour 6 (Training) → human-reviewed patches → Contours 1-3 improve
```

### 4.3 Composable Financial Stack (ADR-014)

The core banking tier follows the same composable principle:

```
Payment Rails / Compliance / Safeguarding Engine
  → LedgerPort (adapter interface)
      ├─ Midaz (PRIMARY general ledger)
      └─ Apache Fineract (FALLBACK)
  → ClickHouse (audit trail + analytics)
  → n8n (regulatory reporting workflows)
```

### 4.4 Trust Zone Model

All files and services are classified into three trust zones (governance/trust-zones.yaml):

| Zone | Trust Level | AI Generation | Approval Required |
|------|-------------|---------------|-------------------|
| RED — Governance Core | 1 (highest) | FORBIDDEN | MLRO + CEO (CLASS_B/C) |
| AMBER — Compliance Decision Engine | 2 | Claude Code only | DEVELOPER + CTIO review |
| GREEN — Operations & Tests | 3 | PERMITTED | No (CLASS_A) |

### 4.5 The 27 Invariants

The architecture enforces 27 invariants (INVARIANTS.md) that cannot be violated. Key invariants:

- **I-01**: Sanctions screening first, always
- **I-02**: Category A jurisdictions → REJECT (no exceptions)
- **I-05**: Decision thresholds immutable without ADR + MLRO + CEO
- **I-08**: ClickHouse TTL = 5 years (FCA MLR 2017)
- **I-09**: Auto-verify API mandatory for all compliance responses
- **I-15**: Jube AGPLv3 — internal reference only, never B2B
- **I-20**: All 6 compliance contours independently replaceable
- **I-23**: Emergency stop checked before every automated decision
- **I-24**: Decision Event Log append-only — no UPDATE/DELETE
- **I-27**: feedback_loop.py = supervised loop, not autonomous self-improvement

Full list: see INVARIANTS.md (27 invariants, I-01 through I-27).

---

## 5. Key Architectural Decisions

| ADR | Title | Status |
|-----|-------|--------|
| ADR-004 | Jube AGPLv3 boundary — reference only | ACCEPTED |
| ADR-005 | Marble ELv2 — internal compliance workflow only | ACCEPTED |
| ADR-009 | OpenSanctions/Yente as primary screening (Phase 3) | ACCEPTED |
| ADR-011 | Reference vs. dependency model | ACCEPTED |
| ADR-012 | Compliance API port migration to :8093 | ACCEPTED |
| ADR-014 | Composable financial stack (Midaz + ClickHouse + n8n) | PROPOSED |

Full ADR catalogue: decisions/ADR-*.md

---

## 6. Regulatory Compliance Mapping

| FCA Requirement | Implementation | Invariant |
|----------------|----------------|-----------|
| MLR 2017 — record-keeping 5Y | ClickHouse TTL 5Y | I-08 |
| EMR 2011 — sanctions screening | Watchman + Screener (Yente Phase 3) | I-01, I-07 |
| CASS 15 — safeguarding | Block J (Safeguarding Engine) — P0 Sprint 9 | — |
| FIN-RPT reporting | n8n workflows (Block K) | — |
| EU AI Act Art. 14(4)(e) | Emergency stop (I-23) | I-23 |
| UK GDPR / FCA PS7/24 | ExplanationBundle ≥ £10k (I-25) | I-25 |
| FCA DORA — audit trail | Decision Event Log append-only (I-24) | I-24 |
| FCA SS1/23 transparency | Auto-verify API (I-09) + no fake integrations (I-10) | I-09, I-10 |

---

## 7. Related Documents

- `INVARIANTS.md` — 27 architectural invariants
- `COMPOSABLE-ARCH.md` — 6 compliance contours detail
- `SERVICE-MAP.md` — full service port registry
- `governance/trust-zones.yaml` — machine-readable trust zone definitions
- `docs/DEPLOYMENT-ARCHITECTURE.md` — infrastructure detail
- `docs/ROADMAP-MATRIX.md` — delivery block/sprint matrix
- `decisions/ADR-014-composable-financial-stack.md` — CBS architecture decision
