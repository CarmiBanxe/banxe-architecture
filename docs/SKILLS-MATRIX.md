# SKILLS-MATRIX.md — Project Skills × Plane Distribution
**Version:** 1.0 | **Date:** 2026-04-08 | **Owner:** CTIO + Claude Code
**Governed by:** SKILLS-OPERATING-MODEL.md | **Invariant refs:** I-18, I-20, I-28

---

## Plane Legend

| Symbol | Plane | Repos |
|--------|-------|-------|
| **D** | Developer Plane | `vibe-coding`, `banxe-architecture` |
| **P** | Product Plane | `banxe-emi-stack` |
| **S** | Standby Plane | `guiyon`, `ss1` |

## Enforcement Legend

| Tag | Meaning |
|-----|---------|
| `MANDATORY` | Must run before qualifying action; blocks if failed |
| `ADVISORY` | Runs, produces report; does not block commit/deploy |
| `PROHIBITED` | Must not run in this plane |
| `CONTROLLED` | Allowed under explicit approval or restricted conditions |

---

## Skill 1 — Context Memory Sync

**Purpose:** Ensure IL continuity, session handoff, and architecture decision capture across all sessions. Prevents decision drift between Claude Code instances.

| Attribute | Value |
|-----------|-------|
| Allowed repos | `banxe-architecture`, `vibe-coding`, `banxe-emi-stack` |
| Standby applicability | Local-only; no Banxe memory artifacts in `guiyon`/`ss1` repos |
| Developer Plane | `MANDATORY` |
| Product Plane | `MANDATORY` |
| Standby Plane | `ADVISORY` (isolated; cannot reference Banxe IL or decisions) |
| Trigger conditions | Session start; after any IL state change; before handoff to Aider/subagent |
| Output artifacts | Updated `MEMORY.md`, updated IL status in `INSTRUCTION-LEDGER.md` |
| Safety constraints | Must not sync Standby plane context into Banxe memory files (I-18, I-20) |
| Invariant refs | I-28 (IL discipline), I-18 (GUIYON isolation), I-20 (independent contours) |
| Quality gate relation | Does not block gate; gate runs after sync completes |

---

## Skill 2 — CI/CD Quick Setup

**Purpose:** Bootstrap or update CI/CD pipelines (GitHub Actions, quality-gate.sh, hooks, systemd timers).

| Attribute | Value |
|-----------|-------|
| Allowed repos | `vibe-coding`, `banxe-architecture` |
| Standby applicability | Allowed locally within `guiyon`/`ss1` if isolated; no shared pipelines |
| Developer Plane | `MANDATORY` (setup must pass quality-gate.sh) |
| Product Plane | `CONTROLLED` — only with explicit CEO approval; all pipeline changes → QRAA |
| Standby Plane | `CONTROLLED` — local CI only; no connection to Banxe infra |
| Trigger conditions | New repo setup; new hook added; systemd timer change; `.github/workflows/` modification |
| Output artifacts | `.github/workflows/*.yml`, `scripts/quality-gate.sh`, `.claude/hooks/`, systemd unit files |
| Safety constraints | Cannot remove or weaken existing hooks or quality-gate checks; QRAA required for GMKtec changes |
| Invariant refs | I-28 (IL discipline for infra changes), I-06 (no secrets in pipeline files) |
| Quality gate relation | All pipeline changes must themselves pass quality-gate before commit |

---

## Skill 3 — Rapid Spec Builder

**Purpose:** Generate structured IL entries, ADRs, agent passports, or feature specs before implementation begins. Default for any multi-file or multi-repo initiative.

| Attribute | Value |
|-----------|-------|
| Allowed repos | `banxe-architecture`, `vibe-coding`, `banxe-emi-stack` |
| Standby applicability | Allowed for local spec work in `guiyon`/`ss1`; output stays in that plane |
| Developer Plane | `MANDATORY` for new IL proposals and ADRs |
| Product Plane | `MANDATORY` before any new service, port, or adapter is implemented |
| Standby Plane | `ADVISORY` |
| Trigger conditions | New IL requested; new service or port introduced; multi-repo change; ADR needed |
| Output artifacts | IL entry in `INSTRUCTION-LEDGER.md`, ADR in `docs/`, agent passport in `agents/passports/` |
| Safety constraints | Spec output must reference existing invariants; must not propose weakening any I-NN |
| Invariant refs | I-28 (IL required before action), I-20 (contour independence must be stated) |
| Quality gate relation | Spec itself is documentation; does not trigger quality gate; implementing the spec does |

---

## Skill 4 — Error Handling Standardizer

**Purpose:** Enforce consistent exception patterns across services: typed exceptions with `__str__`, no bare `except`, structured error codes for all ports and adapters.

| Attribute | Value |
|-----------|-------|
| Allowed repos | `banxe-emi-stack`, `vibe-coding` |
| Standby applicability | `ADVISORY` — apply local conventions only |
| Developer Plane | `ADVISORY` |
| Product Plane | `MANDATORY` — all service ports must use typed exceptions; quality gate blocks bare-except |
| Standby Plane | `ADVISORY` |
| Trigger conditions | New service file created; new port or adapter added; ruff reports bare-except |
| Output artifacts | Typed exception dataclasses with `__str__`, structured error codes, updated tests |
| Safety constraints | Must not suppress or swallow exceptions in audit paths (I-24); errors in financial context must log before raising |
| Invariant refs | I-24 (audit-trail append-only — error must not skip audit write), I-05 (Decimal only — no float in exception amount fields) |
| Quality gate relation | Ruff catches bare-except; typed exception patterns enforced by semgrep `banxe-rules.yml` |

---

## Skill 5 — Performance Scanner

**Purpose:** Profile latency, memory, and throughput bottlenecks before performance-sensitive changes ship.

| Attribute | Value |
|-----------|-------|
| Allowed repos | `banxe-emi-stack`, `vibe-coding` |
| Standby applicability | `ADVISORY` — local use only |
| Developer Plane | `ADVISORY` |
| Product Plane | `MANDATORY` before any change to payment path, AML scoring, or reconciliation engine |
| Standby Plane | `ADVISORY` |
| Trigger conditions | Change to `services/payment/`, `services/aml/`, `services/recon/`; SLA regression detected; fraud scoring latency >100ms |
| Output artifacts | Performance report (timing, memory), `tests/test_performance_*.py`, SLA assertion |
| Safety constraints | Profiling must not run against live GMKtec production data; use InMemory/mock fixtures only |
| Invariant refs | I-05 (FPS SLA <15s), fraud scoring SLA <100ms (S5-22) |
| Quality gate relation | Advisory report only; SLA tests added to pytest suite → gate enforces them |

---

## Skill 6 — API Contract Guardian

**Purpose:** Detect and prevent breaking changes to service ports, REST endpoints, and external integration contracts (Modulr, Sumsub, Keycloak).

| Attribute | Value |
|-----------|-------|
| Allowed repos | `banxe-emi-stack`, `banxe-architecture` |
| Standby applicability | `ADVISORY` — apply to local APIs only |
| Developer Plane | `ADVISORY` |
| Product Plane | `MANDATORY` — any change to a `*Port` Protocol, REST router, or webhook schema triggers contract check |
| Standby Plane | `ADVISORY` |
| Trigger conditions | Edit to any `*_port.py`, `api/routers/*.py`, `services/webhooks/webhook_router.py`, `config/providers.yaml` |
| Output artifacts | Contract diff report, `openapi.json` snapshot diff, breaking change flag |
| Safety constraints | Breaking changes to external provider contracts (Modulr, Sumsub) require QRAA before proceeding; internal port breaks require IL update |
| Invariant refs | I-10 (no fake capabilities claimed), I-20 (contour independence — port changes must not couple contours) |
| Quality gate relation | Contract snapshot stored in `docs/contracts/`; gate compares on each build; diff → ADVISORY block |

---

## Skill 7 — Dependency Optimizer

**Purpose:** Audit and trim Python/YAML/Docker dependencies. Detect unused packages, version conflicts, and licence risks.

| Attribute | Value |
|-----------|-------|
| Allowed repos | `banxe-emi-stack`, `vibe-coding`, `banxe-architecture` |
| Standby applicability | `ADVISORY` — local use; do not install shared dependencies |
| Developer Plane | `ADVISORY` |
| Product Plane | `CONTROLLED` — dependency changes require IL entry; licence audit mandatory |
| Standby Plane | `ADVISORY` |
| Trigger conditions | New `pip install` or `requirements.txt` change; Docker base image update; licence audit request |
| Output artifacts | Dependency diff, licence scan report, `requirements.txt` / `pyproject.toml` update |
| Safety constraints | Must not introduce AGPLv3 or ELv2 dependencies to external-facing services (I-15 Jube, I-19 Marble); no dependencies from sanctioned jurisdictions (I-02) |
| Invariant refs | I-15 (Jube internal only), I-19 (Marble internal only), I-06 (no secrets in dependency files) |
| Quality gate relation | Ruff detects unused imports; licence scan advisory only; semgrep checks for known-bad packages |

---

## Skill 8 — Smart Test Generator

**Purpose:** Auto-generate pytest test stubs for new services, ports, and adapters. Output must pass quality gate before being treated as real coverage.

| Attribute | Value |
|-----------|-------|
| Allowed repos | `banxe-emi-stack`, `vibe-coding` |
| Standby applicability | `ADVISORY` — allowed locally; no Banxe test fixtures |
| Developer Plane | `ADVISORY` |
| Product Plane | `CONTROLLED` — generated tests must be reviewed before merge; cannot count toward coverage gate until human-reviewed |
| Standby Plane | `ADVISORY` |
| Trigger conditions | New service file created; new port defined; coverage drops below 75% threshold |
| Output artifacts | `tests/test_*.py` stubs, fixture files |
| Safety constraints | Generated tests must not use `float` in financial assertions (I-05); must not include hardcoded credentials (I-06); must not mock audit trail writes (I-24) |
| Invariant refs | I-05, I-06, I-24, I-28 (tests must have real proof before IL marked DONE) |
| Quality gate relation | Generated tests run through full quality-gate.sh; coverage gate applies; ruff applies |

---

## Skill 9 — Auto Refactor Pro

**Purpose:** Safe, non-breaking refactors: rename, extract method, consolidate duplicates. Not for business-logic changes.

| Attribute | Value |
|-----------|-------|
| Allowed repos | `banxe-emi-stack`, `vibe-coding` |
| Standby applicability | `ADVISORY` — isolated use only |
| Developer Plane | `ADVISORY` |
| Product Plane | `CONTROLLED` — prohibited on: `services/recon/`, `services/payment/payment_service.py`, `services/aml/`, any file in compliance contours (I-20); allowed only on non-business-logic paths; requires IL entry |
| Standby Plane | `ADVISORY` |
| Trigger conditions | Duplication detected by ruff; explicit CEO/CTIO request; post-feature cleanup sprint |
| Output artifacts | Refactored files, updated tests, ruff PASS |
| Safety constraints | Must not change observable behaviour (all existing tests must pass unchanged); must not touch invariant-enforced logic without QRAA; must not rename public port interfaces without IL and contract check |
| Invariant refs | I-20 (contour independence must be preserved), I-24 (audit writes must survive refactor), I-28 (IL if touching business-critical files) |
| Quality gate relation | Full quality-gate.sh must pass; any test regression = refactor rejected |

---

## Skill 10 — Clean Architecture Enforcer

**Purpose:** Detect architectural violations: missing ports, direct HTTP calls bypassing LedgerPort, missing hexagonal boundaries, mixed concerns.

| Attribute | Value |
|-----------|-------|
| Allowed repos | `banxe-emi-stack`, `banxe-architecture`, `vibe-coding` |
| Standby applicability | `ADVISORY` — apply local architecture conventions only |
| Developer Plane | `MANDATORY` advisory |
| Product Plane | `MANDATORY` blocking where semgrep rule already exists; `ADVISORY` for new patterns pending rule creation |
| Standby Plane | `ADVISORY` |
| Trigger conditions | New service file; new external integration; direct HTTP call detected outside adapter; `import requests` in non-adapter file |
| Output artifacts | Architecture violation report, semgrep rule proposals for `banxe-rules.yml` |
| Safety constraints | Cannot propose removal of existing semgrep rules (only additions); blocking decisions require semgrep rule, not just advisory flag |
| Invariant refs | I-28 (LedgerPort — no direct HTTP to CBS), I-20 (contour independence — no cross-contour imports), I-13 (orchestrator delegates, does not duplicate) |
| Quality gate relation | Semgrep enforces architectural rules; Clean Architecture Enforcer proposes new rules to add to `.semgrep/banxe-rules.yml`; until rule exists it is advisory only |

---

## Summary Matrix

| Skill | Developer | Product | Standby | Invariants |
|-------|-----------|---------|---------|------------|
| 1 Context Memory Sync | MANDATORY | MANDATORY | ADVISORY (isolated) | I-18, I-20, I-28 |
| 2 CI/CD Quick Setup | MANDATORY | CONTROLLED | CONTROLLED | I-06, I-28 |
| 3 Rapid Spec Builder | MANDATORY | MANDATORY | ADVISORY | I-20, I-28 |
| 4 Error Handling Standardizer | ADVISORY | MANDATORY | ADVISORY | I-24, I-05 |
| 5 Performance Scanner | ADVISORY | MANDATORY (payment/AML/recon) | ADVISORY | I-05 (SLA) |
| 6 API Contract Guardian | ADVISORY | MANDATORY | ADVISORY | I-10, I-20 |
| 7 Dependency Optimizer | ADVISORY | CONTROLLED | ADVISORY | I-15, I-19 |
| 8 Smart Test Generator | ADVISORY | CONTROLLED | ADVISORY | I-05, I-06, I-24 |
| 9 Auto Refactor Pro | ADVISORY | CONTROLLED | ADVISORY | I-20, I-24, I-28 |
| 10 Clean Architecture Enforcer | MANDATORY (advisory) | MANDATORY (blocking if rule exists) | ADVISORY | I-13, I-20, I-28 |

---

*Document maintained: Claude Code (Developer Plane architect)*
*Update when: new skill added, plane assignment changes, new invariant created.*
