# Test Strategy — Banxe AI Bank EMI

**Version:** 1.0
**Date:** 2026-04-06
**Status:** LIVING DOCUMENT — updated each sprint
**Scope:** All testing layers across vibe-coding + banxe-architecture repositories

---

## 1. Overview

### Test Count Baseline

| Repository | Test Type | Count | Sprint |
|------------|-----------|-------|--------|
| vibe-coding | pytest unit/integration | 520 | Sprint 6 baseline |
| banxe-architecture | Architectural tests | 663 | Sprint 5 baseline |
| **Full suite (Sprint 6+)** | **Combined** | **747** | **Sprint 6** |

The 747-test baseline is the canonical reference for sprint health reporting. Any sprint that reduces this count is a regression.

### Quality Gate Summary

| Gate | Tool | Target | Current | Blocking? |
|------|------|--------|---------|-----------|
| Unit/Integration | pytest | 100% pass | 100% pass (39/39 phase15, 18/18 suite) | YES |
| Static analysis | Semgrep | 0 critical findings | 8 rules active | YES (pre-commit) |
| Vulnerability scan | Snyk | 0 critical CVE | Active | YES (pre-commit) |
| Static analysis | CodeQL | 0 critical | Active (GitHub Actions) | YES (PR gate) |
| Quality eval | promptfoo | ≥ 95% pass | ~28% (DEF-003) | No (target Sprint 9) |
| Adversarial sim | custom | 0 unexpected bypasses | Weekly cron | No (informational) |

---

## 2. Test Layers

### 2.1 Layer 1 — Unit Tests (pytest)

**Location:** `vibe-coding/src/compliance/test_*.py`
**Runner:** `pytest` from `/data/vibe-coding/`
**Count:** 22 test files

Key test files:

| File | Scope | Notes |
|------|-------|-------|
| test_phase15.py | Core compliance pipeline | 39 functions, all must pass |
| test_suite.py | Integration smoke suite | 18 pass, 2 warn (acceptable) |
| test_sanctions.py | Sanctions screening | Watchman + jurisdiction logic |
| test_tx_monitor.py | Transaction monitoring | 9 deterministic rules |
| test_pep_check.py | PEP screening | PostgreSQL 14,491 entities |
| test_kyb_check.py | KYB verification | Companies House integration |
| test_crypto_aml.py | Crypto sanctions | OFAC crypto addresses |
| test_aml_orchestrator.py | Orchestration | Full pipeline integration |
| test_emergency_stop.py | Emergency stop | 17 tests T-01..T-17 |
| test_auto_verify.py | Auto-verify API | I-09 enforcement |

**Execution:**
```bash
cd /data/vibe-coding
pytest src/compliance/ -v --tb=short
```

**Pass criteria:** 100% — any failure is a blocking regression.

### 2.2 Layer 2 — Integration Tests

**Key integration test files:**

| File | What It Tests | Dependencies |
|------|--------------|-------------|
| test_api_integration.py | FastAPI :8093 end-to-end | All compliance services running |
| test_phase15.py | 39 functions, full AML pipeline | ClickHouse, PostgreSQL, Redis |
| test_suite.py | 18 integration scenarios | Watchman, Jube, Marble |

**Phase 15 test coverage** (critical — these are the FCA-relevant tests):

| Function Range | Scope |
|----------------|-------|
| T-01..T-10 | KYC flow, PEP screening, document verification |
| T-11..T-20 | Sanctions screening, jurisdiction blocking (I-02) |
| T-21..T-30 | Transaction monitoring, velocity rules, structuring detection |
| T-31..T-39 | AML orchestration, threshold decisions (I-05), SAR generation |

### 2.3 Layer 3 — Safety Tests

**File:** `vibe-coding/src/compliance/test_emergency_stop.py`
**Count:** 17 tests — T-01 through T-17

These tests verify invariants I-23 and I-24:

| Test ID | Invariant | What It Tests |
|---------|-----------|--------------|
| T-01..T-05 | I-23 | Emergency stop activates correctly |
| T-06..T-10 | I-23 | All screening endpoints return HTTP 503 when stop is active |
| T-11..T-14 | I-23 | Stop state check happens BEFORE compliance decision |
| T-15..T-17 | I-24 | Audit log is append-only — no UPDATE/DELETE succeeds |

Additional safety invariant tests referenced as I-23 and I-24 in test suite (2 tests). These cover:
- Emergency stop broadcasting to all compliance endpoints
- ClickHouse append-only enforcement

### 2.4 Layer 4 — Architectural Tests

**Location:** `banxe-architecture/tests/` (663 tests baseline, Sprint 5)

| Test File | What It Tests |
|-----------|--------------|
| test_bounded_contexts.py | No cross-context imports violating I-20 |
| test_ports.py | All service ports match SERVICE-MAP.md |
| test_trust_zones.py | File zone assignments match trust-zones.yaml |
| test_invariants.py | Invariant rule assertions |
| test_agent_passports.py | Agent passport schema validity |
| test_context_map.py | domain/context-map.yaml consistency |

**Execution:**
```bash
cd /data/banxe-architecture
pytest tests/ -v
```

### 2.5 Layer 5 — Eval Quality (promptfoo)

**Tool:** promptfoo
**Config:** `vibe-coding/promptfoo/config.yaml`
**Scenarios:** 25 evaluation scenarios covering KYC specialist response quality

| Scenario Group | Count | What It Evaluates |
|----------------|-------|-------------------|
| KYC accuracy | 8 | Correct KYC outcome for document types |
| Sanctions hit handling | 6 | Correct REJECT/HOLD for sanctions hits |
| PEP disclosure | 4 | Correct PEP identification and EDD trigger |
| Jurisdiction logic | 4 | Category A/B jurisdiction handling |
| Explanation quality | 3 | ExplanationBundle completeness (I-25) |

**Current status:** ~28% pass rate (DEF-003)
**Target:** ≥ 95% pass rate
**Deadline:** Sprint 9 (April 2026)
**Cron:** Every Sunday 04:00 — `run-promptfoo-eval.sh`

The low current pass rate (28%) is a known deficit tracked as DEF-003. Sprint 9 objective is to close the gap to ≥ 95% via targeted training corpus additions.

### 2.6 Layer 6 — Adversarial Simulation

**Script:** `vibe-coding/scripts/run-adversarial-sim.sh`
**Frequency:** Weekly cron, Sunday 02:00
**Purpose:** Attempt to bypass compliance rules via prompt injection, jurisdiction circumvention, and structuring patterns

**Scenario types:**
- Prompt injection → policy modification attempts (I-21, I-22)
- Jurisdiction bypass attempts (I-02, I-06)
- Transaction structuring to avoid £10,000 threshold (I-04)
- Fake integration invocation (I-10)
- Emergency stop circumvention (I-23)

**Pass criteria:** Zero unexpected bypasses. Any successful bypass triggers immediate MLRO alert + incident response.

---

## 3. CI/CD Pipeline

### 3.1 GitHub Actions Workflows

**Location:** `vibe-coding/.github/workflows/`
**Count:** 6 active workflows

| Workflow | File | Trigger | What It Runs |
|---------|------|---------|--------------|
| compliance-ci | compliance-ci.yml | Push to main + PR | pytest + Semgrep + Snyk |
| codeql-analysis | codeql.yml | Push + weekly schedule | CodeQL static analysis |
| pre-commit-check | pre-commit.yml | PR | Pre-commit hooks validation |
| adversarial-sim | adversarial.yml | Weekly cron | run-adversarial-sim.sh |
| promptfoo-eval | promptfoo.yml | Weekly cron | run-promptfoo-eval.sh |
| architecture-tests | arch-tests.yml | Push to main | banxe-architecture pytest |

### 3.2 Pre-commit Hooks

Configured in `.pre-commit-config.yaml` — runs on every `git commit`:

| Hook | Tool | What It Checks |
|------|------|----------------|
| semgrep-banxe | Semgrep | 8 custom Banxe rules (see below) |
| secrets-scan | detect-secrets | API keys, tokens, passwords |
| snyk-check | Snyk | Known CVE in dependencies |
| python-lint | ruff | Python code quality |

### 3.3 Semgrep Rules (8 Custom Rules)

**Location:** `vibe-coding/.semgrep/`

| Rule ID | What It Detects |
|---------|----------------|
| BANXE-001 | Direct ClickHouse UPDATE/DELETE (I-24 violation) |
| BANXE-002 | Sanctions check bypass patterns |
| BANXE-003 | Hardcoded API keys or secrets |
| BANXE-004 | Missing emergency stop check in compliance endpoints |
| BANXE-005 | Jube external exposure (I-15 violation) |
| BANXE-006 | Threshold modification without ADR comment (I-05) |
| BANXE-007 | GUIYON cross-reference (I-18 violation) |
| BANXE-008 | feedback_loop auto-apply to SOUL.md (I-21 violation) |

---

## 4. Quality Gates

### 4.1 Blocking Gates (must pass before merge)

| Gate | Threshold | Tooling | Blocks |
|------|-----------|---------|--------|
| pytest | 100% pass, 0 failures | pytest | Pre-commit + PR |
| Semgrep | 0 critical findings | Semgrep (8 rules) | Pre-commit |
| Snyk | 0 critical CVE | Snyk | Pre-commit |
| CodeQL | 0 critical | CodeQL | PR merge |
| Secret scan | 0 secrets | detect-secrets | Pre-commit |

### 4.2 Non-blocking Targets (tracked, informational)

| Target | Current | Goal | Sprint |
|--------|---------|------|--------|
| promptfoo quality | ~28% | ≥ 95% | Sprint 9 |
| Adversarial bypass rate | 0% (expected) | 0% | Ongoing |
| Test coverage % | TBD | ≥ 80% | Sprint 10 |

### 4.3 FCA Audit Evidence

Test results are stored in ClickHouse as part of the compliance audit trail. For FCA review, the following is producible:

- pytest XML reports (GitHub Actions artifacts)
- Semgrep findings history (Git blame on .semgrep/ rules)
- adversarial simulation reports (ClickHouse table: `banxe.adversarial_results`)
- promptfoo eval history (ClickHouse table: `banxe.eval_results`)

---

## 5. Test Data Management

### 5.1 Synthetic Test Data

All test data is synthetic — no real customer PII in test suites. Synthetic profiles are generated by `vibe-coding/tests/fixtures/generate_fixtures.py`.

### 5.2 Sanctions Test Cases

The sanctions test suite includes synthetic entries for all Category A jurisdictions (I-02) and a representative sample of Category B (I-03). Watchman minMatch=0.80 tested with known-alias variants.

### 5.3 Threshold Verification

Decision threshold tests verify I-05 immutability:

| Test | What it verifies |
|------|-----------------|
| test_thresholds_immutable | SAR ≥ 85, REJECT ≥ 70, HOLD ≥ 40 unchanged |
| test_no_vip_override | VIP/known customers get same threshold treatment |
| test_operator_cannot_change | Operator UI cannot modify thresholds |

---

## 6. Test Coverage by Invariant

| Invariant | Test File(s) | Status |
|-----------|-------------|--------|
| I-01 (Sanctions first) | test_aml_orchestrator.py | Covered |
| I-02 (Category A → REJECT) | test_sanctions.py | Covered |
| I-03 (Category B → HOLD) | test_sanctions.py | Covered |
| I-04 (£10k thresholds) | test_tx_monitor.py | Covered |
| I-05 (Threshold immutability) | test_aml_orchestrator.py | Covered |
| I-06 (Hard override → REJECT) | test_sanctions.py | Covered |
| I-07 (Watchman minMatch=0.80) | test_sanctions.py | Covered |
| I-08 (ClickHouse TTL 5Y) | test_audit_trail.py | Covered |
| I-09 (Auto-verify mandatory) | test_auto_verify.py | Covered |
| I-15 (Jube internal only) | semgrep BANXE-005 | Covered |
| I-21 (No auto-SOUL patch) | semgrep BANXE-008 | Covered |
| I-22 (Agent no policy write) | test_bounded_contexts.py | Covered |
| I-23 (Emergency stop first) | test_emergency_stop.py T-01..T-14 | Covered |
| I-24 (Append-only audit) | test_emergency_stop.py T-15..T-17, BANXE-001 | Covered |
| I-25 (ExplanationBundle ≥ £10k) | test_phase15.py T-31..T-39 | Partial (G-02) |
| I-27 (No autonomous self-improvement) | adversarial-sim.sh | Covered |

---

## 7. Related Documents

- `vibe-coding/src/compliance/COMPLIANCE_ARCH.md` — compliance architecture
- `banxe-architecture/INVARIANTS.md` — 27 invariants being tested
- `governance/trust-zones.yaml` — zone-based test scope
- `docs/ROADMAP-MATRIX.md` — Sprint delivery context
- `vibe-coding/GAP-REGISTER.md` — G-01/G-02/G-03 test gaps
