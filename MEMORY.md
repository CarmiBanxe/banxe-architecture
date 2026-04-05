# banxe-architecture — Sprint Memory

> Auto-maintained by Claude Code sessions. Append-only: add new entries at the bottom.
> Last updated: 2026-04-05

---

## Sprint 4 — Trust Zone Governance + Zero Standing Privileges

### G-11 — Trust Zone Governance (DONE 2026-04-05)

**Deliverables:**
- `banxe-architecture/CONTRIBUTING.md` — full governance guide, 3-zone table, approval rules, branch protection
- `banxe-architecture/governance/trust-zones.yaml` — machine-readable zone spec (RED/AMBER/GREEN), path patterns, shared rules SR-01..SR-04, escalation rules
- `src/compliance/validators/validate_trust_zones.py` — CLI validator: `--file`, `--zone`, `--validate`, `--check-drift`
- `src/compliance/test_trust_zones.py` — 28 tests covering zone assignment, AI policy, approval requirements, CONTRIBUTING content

**Key design decisions:**
- `trust-zones.yaml` is itself in Zone RED (self-protecting, CLASS_B)
- `validate_trust_zones.py` is also RED — once deployed, requires `GOVERNANCE_BYPASS=1` to modify
- Zone matching uses `fnmatch` glob patterns, first-match wins
- Zone RED: AI-FORBIDDEN, requires MLRO/CEO/CTIO approval, signed commits
- Zone AMBER: CLAUDE_CODE_ONLY, architect review required, hooks: invariant_check.py + bounded_context_check.py
- Zone GREEN: PERMITTED (free vibe-coding), CI must pass

**Test result:** 28/28 passed

---

### G-10 — Zero Standing Privileges / JIT Credentials (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/security/jit_credentials.py` — full JIT in-memory implementation
- `src/compliance/security/__init__.py` — package exports
- `src/compliance/test_jit_credentials.py` — 31 tests T-01..T-28

**Key design decisions:**
- `CredentialScope` enum: READ_POLICY, EMIT_DECISION, APPEND_AUDIT, CHECK_EMERGENCY, ORCHESTRATE
  — `POLICY_WRITE` intentionally absent (invariant I-22 / trust boundary B-06)
- `TemporaryCredential` is a frozen dataclass (immutable after issuance)
- `InMemoryCredentialStore` uses `threading.Lock()` for thread-safety
- ZSP-01: Level-3 agents cannot hold EMIT_DECISION, APPEND_AUDIT, CHECK_EMERGENCY, ORCHESTRATE
- ZSP-01: Level-2 agents cannot hold ORCHESTRATE (Level-1 orchestrators only)
- ZSP-02: credentials expire after TTL (default 300s = 5 minutes)
- ZSP-03: all issuances/revocations logged via StructuredLogger (event payload pattern)
- Sprint 5 migration path: replace `InMemoryCredentialStore` with `VaultCredentialStore` (same interface, injected via constructor)
- `get_credential_manager()` — thread-safe singleton (double-checked locking)

**Bugs fixed during implementation:**
- `StructuredLogger.log()` does not exist → fixed to use `.event(event_type=..., payload=...)`
- `pyproject.toml` missing `pythonpath = ["src"]` → added so `compliance.*` imports resolve in pytest

**Test result:** 31/31 passed

---

## Full Test Suite Status (2026-04-05)

| Scope | Tests | Status |
|-------|-------|--------|
| `src/compliance/` (excl. integration + test_suite) | 579 | ✅ ALL PASSED |
| G-10 test_jit_credentials.py | 31 | ✅ |
| G-11 test_trust_zones.py | 28 | ✅ |

---

## GAP Status Summary (Sprint 4 complete)

All 22 gaps from GAP-REGISTER have been addressed. User updating GAP-REGISTER.md directly via GitHub.

Key completed gaps (Sprint 4):
- G-11 Trust Zone Governance — DONE
- G-10 Zero Standing Privileges — DONE
- G-18 DDD Bounded Contexts — DONE
- G-01 Decision Event Log (PostgreSQL) — DONE
- G-12 Agent Passports — DONE
- G-20 Release Pipeline — DONE

---

## Sprint 5 — P3 Maturity (Compliance Snapshot + OPA Sidecar + Review Agent)

### G-13 — Compliance Snapshot Bundle (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/utils/compliance_snapshot.py` — collector + ZIP exporter
- `src/compliance/test_compliance_snapshot.py` — 28 tests T-01..T-28

**Key design decisions:**
- `ComplianceSnapshot` dataclass: timestamp, version, git_sha, policy_checksums (SHA-256 for 5 files), invariants_count, test_results, agent_passports_count, rego_rules_count, gap_register_summary, thresholds, errors
- `collect_snapshot(run_tests=True)` — live snapshot; `run_tests=False` for fast collection
- `export_snapshot_zip(path)` — ZIP with snapshot.json + snapshot.md + 5 artefact files: compliance_config.yaml, INVARIANTS.md, GAP-REGISTER.md, change-classes.yaml, trust-zones.yaml
- `to_markdown()` — human-readable report for MLRO
- Missing files reported as non-fatal errors (never raises)
- CLI: `python -m compliance.utils.compliance_snapshot --output /tmp/audit-YYYY-MM-DD.zip`

**Test result:** 28/28 passed

---

### G-14 — OPA Sidecar Pilot (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/security/opa_sidecar.py` — runtime pre-decision enforcement layer
- `src/compliance/test_opa_sidecar.py` — 28 tests T-01..T-28

**Key design decisions:**
- `OPASidecar` wraps `rego_evaluator.evaluate()` as runtime enforcement before agent decisions
- `PolicyDecision` frozen dataclass: allowed, outcome (ALLOW/DENY/ESCALATE), rule_id, reason, escalation_target, violations
- 3 critical rules enforced:
  - RULE-01 (I-22): Level-2/3 agents cannot write to policy layer → DENY
  - RULE-02 (I-23): Emergency stop must be checked before any decision → DENY
  - RULE-03 (I-25): ExplanationBundle required for decisions > £10K → ESCALATE(MLRO)
- Fail-closed: any internal exception → DENY with rule_id=SIDECAR_ERROR (never silent allow)
- All evaluations logged via StructuredLogger.event() for I-24 audit trail
- `get_sidecar()` module-level singleton
- Integration: call `sidecar.evaluate_pre_decision(agent_id, action, context)` before `_layer2_assess()`

**Test result:** 28/28 passed

---

### G-15 — Multi-Agent Review Pattern (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/review/review_agent.py` — independent rule-based reviewer
- `src/compliance/review/__init__.py` — package exports
- `src/compliance/test_review_agent.py` — 28 tests T-01..T-28

**Key design decisions:**
- `ReviewAgent` is independent of the builder — never generated the proposed change
- `ReviewRequest`: proposed_change (diff), change_class (auto-detected if None), author_agent_id, target_file, rationale, author_level, context
- `ReviewResult`: approved, reviewer_agent_id, concerns, risk_score (0-100), recommendation, resolved_class
- Class-based hard gates: CLASS_B→REJECT(100), CLASS_C→ESCALATE_TO_HUMAN(75), CLASS_D→REJECT(100)
- CLASS_A rule-based scoring: I-21(+90), I-22(+85), trust-zone RED(+70), BC-boundary(+20/+25), no-rationale(+10)
- Threshold: risk>80→REJECT, risk>50→ESCALATE_TO_HUMAN, else→APPROVE
- Auto-detects change class from target_file (SOUL.md/AGENTS.md→B, *.rego/compliance_config.yaml→C, ADR-→D)
- All review decisions logged via StructuredLogger.event() (I-24 append-only)
- Integration: `feedback_loop.py` calls `ReviewAgent.review(request)` before applying a patch

**Test result:** 28/28 passed

---

## Full Test Suite Status (2026-04-05, Sprint 5 complete)

| Scope | Tests | Status |
|-------|-------|--------|
| `src/compliance/` (excl. integration + test_suite) | 663 | ✅ ALL PASSED |
| G-13 test_compliance_snapshot.py | 28 | ✅ |
| G-14 test_opa_sidecar.py | 28 | ✅ |
| G-15 test_review_agent.py | 28 | ✅ |
