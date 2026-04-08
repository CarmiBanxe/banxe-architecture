# SKILLS-ORCHESTRATION.md — Execution Order and Trigger Model for Banxe Agents
**Version:** 1.0 | **Date:** 2026-04-08 | **Owner:** CTIO + Claude Code
**Governed by:** SKILLS-OPERATING-MODEL.md | **Invariant refs:** I-18, I-20, I-28
**Reference:** SKILLS-MATRIX.md, PLANES.md, INVARIANTS.md, quality-gate.sh

---

## Core Rule

`allowed_skills` and `prohibited_skills` in agent passports define **policy boundaries** — they are not automatic orchestration.

Mandatory execution order, trigger conditions, artifact handoffs, and blocking points are defined **by this document**.

Final enforcement layer for Product Plane remains `quality-gate.sh`, hooks, semgrep, tests, and invariants.

---

## Status Levels

| Tag | Meaning |
|-----|---------|
| `MUST` | Mandatory step — cannot be skipped |
| `SHOULD` | Recommended by default — skip only with documented reason |
| `MAY` | Optional — apply if situationally relevant |
| `MUST NOT` | Prohibited — violates invariant, plane isolation, or governance rule |

---

## Global Precedence

```
1. Invariants I-01..I-28
2. Plane isolation rules (I-18, I-20)
3. Agent passport restrictions (allowed_skills / prohibited_skills)
4. Skills orchestration rules (this document)
5. Local agent discretion
```

If a skill conflicts with an invariant — **invariant wins**.
If a skill is permitted in the passport but orchestration requires a different order — **orchestration applies**.
If a task is in Product Plane — **`quality-gate.sh` is the final blocker before commit/push**, regardless of skill output.

---

## Scenario Matrix

| Scenario | Trigger | Sequence | Plane | Final Blocker |
|----------|---------|----------|-------|---------------|
| A. New feature / new IL / architecture change | New capability request, IL proposal, multi-repo design change | Context Memory Sync MUST → Rapid Spec Builder MUST → API Contract Guardian SHOULD (MUST if interface exists) → Clean Architecture Enforcer MUST → Smart Test Generator SHOULD → quality-gate.sh MUST | Developer, Product | quality-gate.sh |
| B. Product code modification | Code change in `banxe-emi-stack` affecting behavior or controls | Context Memory Sync MUST → Clean Architecture Enforcer MUST → Error Handling Standardizer MUST → API Contract Guardian MUST if schema/contract touched → Smart Test Generator MUST → quality-gate.sh MUST | Product | quality-gate.sh |
| C. Safe refactor | Readability / structure improvement without intended business logic change | Context Memory Sync MUST → Auto Refactor Pro MUST → Clean Architecture Enforcer MUST → Smart Test Generator SHOULD → quality-gate.sh MUST | Developer, Product | quality-gate.sh |
| D. Performance-sensitive change | Query tuning, hot path optimization, heavy job review, SLA claim | Context Memory Sync MUST → Performance Scanner MUST → Dependency Optimizer MAY if dependency root cause identified → Smart Test Generator SHOULD → quality-gate.sh MUST | Product, Developer | quality-gate.sh |
| E. API / integration work | New adapter, contract, request/response shape, external API change | Context Memory Sync MUST → Rapid Spec Builder MUST → API Contract Guardian MUST → Error Handling Standardizer MUST → Smart Test Generator MUST → quality-gate.sh MUST | Developer, Product | quality-gate.sh |
| F. Error model hardening | Exception handling, retries, structured logging, domain errors | Context Memory Sync MUST → Error Handling Standardizer MUST → Clean Architecture Enforcer SHOULD → Smart Test Generator SHOULD → quality-gate.sh MUST | Product, Developer | quality-gate.sh |
| G. Dependency cleanup | Package bloat, duplicate libs, risky dependency review | Context Memory Sync SHOULD → Dependency Optimizer MUST → Clean Architecture Enforcer SHOULD → Smart Test Generator SHOULD → quality-gate.sh MUST if code/runtime affected | Developer, Product | quality-gate.sh when applicable |
| H. Test coverage expansion | Existing code lacks unit/integration tests | Context Memory Sync SHOULD → Smart Test Generator MUST → quality-gate.sh MUST | Developer, Product | quality-gate.sh |
| I. Cross-repo governance update | Changes to IL, CLAUDE.md, PLANES.md, COMPLIANCE-MATRIX, passports | Context Memory Sync MUST → Rapid Spec Builder SHOULD → Clean Architecture Enforcer SHOULD → quality-gate.sh SHOULD if executable code touched | Developer | Repo governance review |
| J. Standby legal/research workflow | GUIYON / SS1 legal text, local sensitive reasoning, isolated work | Context Memory Sync MUST → Rapid Spec Builder SHOULD → local-first execution MUST → Smart Test Generator MAY if code exists | Standby | Plane isolation rules (I-18, I-20) |

---

## Scenario Detail

### A. New Feature / New IL / Architecture Change

**Trigger:** New capability request, IL proposal, multi-repo design change, new ADR.

**Sequence:**

| Step | Skill | Mode | Output artifact |
|------|-------|------|-----------------|
| 1 | Context Memory Sync | MUST | Decision summary, prior constraints, affected repos |
| 2 | Rapid Spec Builder | MUST | Structured spec, IL entry, acceptance criteria, boundary notes |
| 3 | API Contract Guardian | MUST if interface exists, SHOULD otherwise | Contract diff, schema diff, compatibility notes |
| 4 | Clean Architecture Enforcer | MUST | Boundary validation, dependency rule note |
| 5 | Smart Test Generator | SHOULD | Test stubs, coverage targets |
| 6 | quality-gate.sh | MUST | Gate pass required before commit |

**Rules:**
- MUST run in Developer Plane before implementation expands
- Product Plane changes MUST NOT skip steps 3–6 if service boundaries are touched

---

### B. Product Code Modification

**Trigger:** Code change in `banxe-emi-stack` affecting behavior, controls, or domain logic.

**Sequence:**

| Step | Skill | Mode | Output artifact |
|------|-------|------|-----------------|
| 1 | Context Memory Sync | MUST | Prior constraints, affected invariants |
| 2 | Clean Architecture Enforcer | MUST | Placement validation, dependency check |
| 3 | Error Handling Standardizer | MUST | Typed exceptions, structured error codes |
| 4 | API Contract Guardian | MUST if schema/contract touched | Contract diff report |
| 5 | Smart Test Generator | MUST | Tests added/updated |
| 6 | quality-gate.sh | MUST | Final gate — no bypass |

**Rules:**
- No direct commit path around quality gate
- Auto Refactor Pro MUST NOT be primary driver for behavior-changing work

---

### C. Safe Refactor

**Trigger:** Readability/modularity/duplication reduction. No intended business logic change.

**Sequence:**

| Step | Skill | Mode | Output artifact |
|------|-------|------|-----------------|
| 1 | Context Memory Sync | MUST | Refactor scope, non-behavioral change statement |
| 2 | Auto Refactor Pro | MUST | Refactor plan, non-behavioral change note |
| 3 | Clean Architecture Enforcer | MUST | Boundary check after refactor |
| 4 | Smart Test Generator | SHOULD | Regression test stubs |
| 5 | quality-gate.sh | MUST | All existing tests MUST pass unchanged |

**Rules:**
- If any existing test breaks → refactor rejected
- MUST NOT touch invariant-enforced logic without QRAA
- MUST NOT apply to: `services/payment/payment_service.py`, `services/aml/`, `services/recon/`, compliance contours

---

### D. Performance-Sensitive Change

**Trigger:** Performance claim, SLA regression detected, hot path / heavy job optimization.

**Sequence:**

| Step | Skill | Mode | Output artifact |
|------|-------|------|-----------------|
| 1 | Context Memory Sync | MUST | Affected SLA rules (I-05 FPS <15s, S5-22 AML <100ms) |
| 2 | Performance Scanner | MUST | Hotspot summary, measurement target, SLA assertion |
| 3 | Dependency Optimizer | MAY if dependency root cause | Dependency audit |
| 4 | Smart Test Generator | SHOULD | SLA test added to pytest suite |
| 5 | quality-gate.sh | MUST | SLA test failure blocks commit |

**Rules:**
- ADVISORY in Developer Plane; MANDATORY in Product Plane before optimization claims
- Profiling MUST NOT run against live GMKtec production data (InMemory/mock fixtures only)

---

### E. API / Integration Work

**Trigger:** New adapter, contract change, request/response shape, external API integration.

**Sequence:**

| Step | Skill | Mode | Output artifact |
|------|-------|------|-----------------|
| 1 | Context Memory Sync | MUST | Prior API constraints, provider docs |
| 2 | Rapid Spec Builder | MUST | Contract spec, IL entry |
| 3 | API Contract Guardian | MUST | Schema diff, breaking change flag, QRAA flag if breaking |
| 4 | Error Handling Standardizer | MUST | Error taxonomy for new integration |
| 5 | Smart Test Generator | MUST | Contract tests, adapter tests |
| 6 | quality-gate.sh | MUST | Final gate |

**Rules:**
- Breaking changes to external provider contracts (Modulr, Sumsub) require QRAA before proceeding
- Internal port breaks require IL update

---

### F. Error Model Hardening

**Trigger:** Exception patterns added/modified, retry logic, structured logging, domain errors.

**Sequence:**

| Step | Skill | Mode | Output artifact |
|------|-------|------|-----------------|
| 1 | Context Memory Sync | MUST | Affected audit paths (I-24) |
| 2 | Error Handling Standardizer | MUST | Typed exceptions, error codes, logging/retry rules |
| 3 | Clean Architecture Enforcer | SHOULD | Boundary check |
| 4 | Smart Test Generator | SHOULD | Exception path tests |
| 5 | quality-gate.sh | MUST | Ruff + semgrep block bare-except |

**Rules:**
- MUST NOT suppress or swallow exceptions in audit paths (I-24)
- Errors in financial context MUST log before raising

---

### G. Dependency Cleanup

**Trigger:** Package bloat, duplicate libs, licence risk review, Docker base image update.

**Sequence:**

| Step | Skill | Mode | Output artifact |
|------|-------|------|-----------------|
| 1 | Context Memory Sync | SHOULD | Affected service boundaries |
| 2 | Dependency Optimizer | MUST | Dependency diff, licence scan report |
| 3 | Clean Architecture Enforcer | SHOULD | Boundary check after removal |
| 4 | Smart Test Generator | SHOULD | Regression stubs |
| 5 | quality-gate.sh | MUST if runtime code affected | Gate pass |

**Rules:**
- MUST NOT introduce AGPLv3 or ELv2 to external-facing services (I-15, I-19)
- MUST NOT add packages from sanctioned jurisdictions (I-02)

---

### H. Test Coverage Expansion

**Trigger:** Coverage below 75% threshold; new service/port with no test coverage.

**Sequence:**

| Step | Skill | Mode | Output artifact |
|------|-------|------|-----------------|
| 1 | Context Memory Sync | SHOULD | Gap in coverage, affected files |
| 2 | Smart Test Generator | MUST | Test stubs, fixture files |
| 3 | quality-gate.sh | MUST | Coverage gate (75% threshold) |

**Rules:**
- Generated tests MUST NOT use `float` in financial assertions (I-05)
- Generated tests MUST NOT include hardcoded credentials (I-06)
- Generated tests MUST NOT mock audit trail writes (I-24)
- Generated tests are ADVISORY until human-reviewed (Product Plane)

---

### I. Cross-Repo Governance Update

**Trigger:** Changes to IL, CLAUDE.md, PLANES.md, COMPLIANCE-MATRIX, agent passports, INVARIANTS.md.

**Sequence:**

| Step | Skill | Mode | Output artifact |
|------|-------|------|-----------------|
| 1 | Context Memory Sync | MUST | Affected docs, prior decisions |
| 2 | Rapid Spec Builder | SHOULD | Draft diff, change rationale |
| 3 | Clean Architecture Enforcer | SHOULD | Consistency check with invariants |
| 4 | quality-gate.sh | SHOULD if executable code touched | Gate pass |

**Rules:**
- No skill may remove or weaken existing semgrep rules (only additions)
- Governance docs are documentation — do not trigger quality gate unless code is modified

---

### J. Standby Plane Workflow (GUIYON / SS1)

**Trigger:** Legal text generation, court document analysis, investigative reasoning — fully local to Standby repos.

**Sequence:**

| Step | Skill | Mode | Output artifact |
|------|-------|------|-----------------|
| 1 | Context Memory Sync | MUST | Local Standby context only — no Banxe IL IDs |
| 2 | Rapid Spec Builder | SHOULD | Spec stays in Standby repo |
| 3 | Local-first execution | MUST | Output stays within repo |
| 4 | Smart Test Generator | MAY if code exists | Local tests only |

**Rules:**
- Product Plane data, Banxe client context, or operational state MUST NOT flow into Standby tasks
- Standby outputs MUST NOT be reused in Banxe Product Plane without explicit human review
- No Banxe ClickHouse, Midaz, Redis, or `.env` access
- No shared MiroFish context between planes

---

## Trigger Rules

### When Context Memory Sync MUST trigger

- Session continues prior architectural work
- An IL/ADR/invariant/compliance rule is referenced
- Work spans multiple repos or agents
- A handoff or resume occurs
- Before any agent delegation

### When Rapid Spec Builder MUST trigger

- Task starts from a rough idea or incomplete requirements
- A new IL/proposal/architecture change is being formed
- More than one repo or agent is involved

### When API Contract Guardian MUST trigger

- Request/response shape changes
- DTO/schema/OpenAPI/JSON contract changes
- Adapter/integration boundary introduced or modified
- Producer/consumer ownership spans services or repos

### When Error Handling Standardizer MUST trigger

- Domain/service exceptions added or modified
- Retries/timeouts/fallbacks introduced
- Logging/error envelopes/status mapping changes
- Workflow crosses service boundaries

### When Smart Test Generator MUST trigger

- Product behavior changes
- Interface contracts change
- Bugfix or regression-sensitive path modified

### When Auto Refactor Pro MUST NOT trigger as primary driver

- Business logic is changing
- Regulatory behavior is altered without explicit approval
- Task involves compliance contours (AML, payments, safeguarding, reporting)

### When Performance Scanner MUST trigger

- Change justified by a performance claim
- Slow queries/hot paths/heavy jobs are part of acceptance criteria
- SLA regression detected

---

## Artifact Handoffs

| Skill | Required output artifact |
|-------|--------------------------|
| Context Memory Sync | Decision summary, prior constraints, affected repos/agents |
| Rapid Spec Builder | Structured spec, task list, acceptance criteria, boundary notes |
| API Contract Guardian | Schema diff, contract rules, compatibility notes, breaking-change flag |
| Error Handling Standardizer | Error taxonomy, logging/retry rules, exception map |
| Smart Test Generator | Tests added/updated, scenario coverage list |
| Auto Refactor Pro | Refactor plan, non-behavioral change statement, all tests green |
| Clean Architecture Enforcer | Placement/boundary validation, dependency rule note |
| Performance Scanner | Hotspot summary, measurement target, SLA assertion |
| Dependency Optimizer | Dependency audit result, licence scan, safe-removal proposal |

---

## Enforcement Points

| Layer | What it enforces | When it runs |
|-------|-----------------|--------------|
| `quality-gate.sh` | semgrep + ruff + pytest + coverage | Before every commit in Product Plane |
| `il_gate.py` hook | IL entry exists before action | On every qualifying Claude Code action |
| `invariant_check.py` hook | I-01..I-28 | On every qualifying action |
| `policy_guard.py` hook | CLASS_B/C changes | On every qualifying action |
| `bounded_context_check.py` hook | Cross-contour imports | On every qualifying action |
| `quality_gate_hook.py` hook | Intercepts `git commit` → runs gate | On git commit in Product Plane |
| Agent passport `prohibited_skills` | Per-agent skill restriction | Checked by orchestrator before skill invocation |
| Plane isolation rules | I-18, I-20 cross-plane data | Applied to every Standby session |

---

## Product Plane Rules

- Product Plane agents MUST NOT skip `quality-gate.sh`.
- Skills MAY assist but MUST NOT override tests, semgrep, hooks, invariants, or repo isolation.
- Any Product Plane change touching contracts, errors, or behavior MUST include the relevant scenario sequence from this document.
- "Skill available in passport" does NOT mean "skill determines release readiness."

---

## Standby Plane Rules

- GUIYON and SS1 workflows are local-first (Scenario J).
- Product Plane data, Banxe client context, or repo-private operational state MUST NOT flow into Standby tasks.
- Standby outputs MUST NOT be reused in Banxe Product Plane without explicit human review and repo-appropriate validation.

---

## Passport Binding Rules

Agent passports MAY include:

```yaml
allowed_skills: [...]          # permission list
prohibited_skills: [...]       # hard restrictions
preferred_skill_sequences:     # orchestration hints (scenario name → steps)
  scenario_new_feature: [...]
mandatory_skill_triggers:      # conditions that make a skill MUST
  api_contract_guardian: ["any *Port contract change"]
```

Passports MUST NOT:
- Imply hidden automation that does not exist
- Grant cross-plane data access
- Bypass repo-level governance or invariants

---

## Consistency Validation

Before each commit touching orchestration docs or passports, verify:

1. Every `preferred_skill_sequence` step references a skill in the agent's `allowed_skills`
2. No `preferred_skill_sequence` includes a skill from `prohibited_skills`
3. Every `mandatory_skill_trigger` references an invariant or FCA rule
4. No Standby passport references Banxe IL IDs or Product Plane data
5. quality-gate.sh is always the last step in Product Plane sequences

---

*Document maintained: Claude Code (Developer Plane architect)*
*Update when: new scenario identified, sequence changes, enforcement point changes, new invariant added.*
