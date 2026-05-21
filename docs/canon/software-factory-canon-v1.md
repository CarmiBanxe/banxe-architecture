# Software Factory Canon v1.0

**Status:** RATIFIED (2026-05-14, Sub-A Clause 17)
**Date:** 2026-05-14
**Owner:** Operator (Moriel Carmi)
**Scope:** CarmiBanxe organisation — all repos under banxe-emi-stack and MetaClaw
**Binding ADRs:** ADR-019 (Guardian two-family), ADR-020 (memory governance), ADR-025 (agent interaction canon), ADR-031 (deny-paths)

---

## 1. Purpose

This canon defines the operating model for a role-based software factory where:

- **Claude Code** acts as planner, reviewer, and orchestrator.
- **Aider** (via MCP/Qoder) acts as the sole code executor.
- **LiteLLM** serves as the gateway-only routing layer to local Ollama endpoints.
- **Guardian** enforces factory and project invariants deterministically.
- **Canon Judge** evaluates agent output against ADR-025 via LLM (audit mode).

No cloud LLM calls are permitted (ADR-031). All inference runs on the local cluster (evo1, evo2).

---

## 2. Scope

### In scope

- All code generation, refactoring, bug fixing, and test writing across banxe repos.
- Compliance-sensitive workflows (AML/KYC, CASS 15, payment routing).
- Agent memory persistence and skill evolution (MetaClaw core).
- Cluster operations (model deployment, hardware changes).

### Out of scope

- Manual developer work outside the factory loop (permitted but unaudited).
- Third-party SaaS integrations not routed through LiteLLM.

---

## 3. Invariants

These invariants are non-negotiable. Violation triggers an immediate BLOCK verdict.

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| INV-01 | Aider is the PREFERRED code executor via LiteLLM; Claude Code MAY write code directly under --dangerously-skip-permissions for speed; documentation by any role | COLLAB.md, MCP config, S7+S8 retrospective, Sprint 0 amendment 2026-05-21 |
| INV-02 | LiteLLM is gateway-only (no direct Ollama calls from agents) | LiteLLM config, network policy |
| INV-03 | No cloud LLM calls | ADR-031, deny-paths in project_rules.py |
| INV-04 | No float for money — Decimal only | project_rules.py, ruff rules |
| INV-05 | No secrets in commits | .gitignore, Guardian F7/project deny patterns |
| INV-06 | No tech from sanctioned jurisdictions | Global CLAUDE.md |
| INV-07 | Audit logs immutable, 5-year TTL | ClickHouse schema, Guardian auditor |
| INV-08 | One terminal = one project = one repo | COLLAB.md hard invariant |
| INV-09 | Factory baseline (.claude/settings.json) locked | Factory rule F7 |
| INV-10 | Roadmap is append-only | Factory rule F3 |

---

## 4. Factory Professions and Role Matrix

### 4.1 Agent roles

| Role | Actor | Responsibility | Tools |
|------|-------|----------------|-------|
| **Planner** | Claude Code | Decomposes tasks, creates plans, assigns sprints | Plan mode, TaskCreate |
| **Executor** | Aider (via MCP/Qoder) | Writes code, runs commands, applies patches | File edit, shell exec |
| **Reviewer** | Claude Code | Reviews diffs, checks invariants, approves/defers | Git diff, Read, Grep |
| **Factory Guardian** | Guardian (qwen3.5:35b) | Enforces 8 factory rules (F1-F8) deterministically | factory_rules.py |
| **Project Guardian** | Guardian (llama3.3:70b) | Enforces 8 project rules (P1-P8) deterministically | project_rules.py |
| **Canon Judge** | Canon Judge MCP (qwen3.5:35b) | LLM-evaluates output against ADR-025 (audit mode) | canon_judge/mcp/server.py |

### 4.2 Human gate roles

| Role | Person | Gate authority |
|------|--------|---------------|
| **Operator** | Moriel Carmi | Final approval on all promotions, UNSAFE command execution, P0 deprioritisation override |
| **MLRO** | Moriel Carmi (interim until dedicated MLRO designated) | Compliance sign-off on AML/KYC changes, CASS 15 reconciliation, payment routing |
| **CTIO** | Moriel Carmi (interim until dedicated CTIO designated) | Architecture sign-off on ADR amendments, model changes, cluster topology |

### 4.3 HITL risk matrix

| Risk level | Confidence threshold | Approval required |
|------------|---------------------|-------------------|
| LOW | >90% auto-approve | None (auto) |
| MEDIUM | 50-90% | Human (Operator) |
| HIGH | <50% or compliance-sensitive | Human + Compliance officer (MLRO) |

---

## 5. Canonical Route Binding

All agent requests are routed through LiteLLM. Direct Ollama calls are prohibited.

| Alias | Model | Use case | Endpoint |
|-------|-------|----------|----------|
| `banxe-general` / `qwen3-banxe` | qwen3:30b-a3b | Default generation | evo1/evo2 (11434) |
| `fast` | glm-4.7-flash-abliterated | Low-latency tasks | evo1/evo2 (11434) |
| `coding` | qwen3-coder-next:q4_K_M | Code generation | evo1/evo2 (11434) |
| `ai` | qwen3.5:35b | Factory Guardian backbone | evo1/evo2 (11434) |
| `ai-heavy` | llama3.3:70b | Project Guardian backbone | evo1/evo2 (11434) |
| `large` / `glm-air` | GLM-4.5-Air | Heavy reasoning | Legion RPC (8081) |

Route binding is defined in `litellm/litellm-config.v2.yaml` and is the single source of truth.

---

## 6. Five Mandatory Packs

Every factory work unit must produce or reference exactly five packs:

| Pack | Contents | Owner |
|------|----------|-------|
| **P1: Instruction Pack** | Task decomposition, sprint scope, acceptance criteria | Planner (Claude Code) |
| **P2: Execution Pack** | Code diffs, commits, branch references | Executor (Aider) |
| **P3: Evaluation Pack** | Test results (pytest), lint results (ruff), type check (mypy) | Reviewer (Claude Code) |
| **P4: Audit Pack** | Guardian verdicts (F1-F8, P1-P8), Canon Judge evaluation, ClickHouse log entries | Guardian + Canon Judge |
| **P5: Evidence Pack** | PR link, operator sign-off record, MLRO sign-off (if compliance), rollback plan | Operator / MLRO |

---

## 7. Operating Loop

```
plan -> route -> execute -> evaluate -> review -> promote/defer
  ^                                                    |
  +----------------------------------------------------+
                    (defer cycles back)
```

### 7.1 Plan

- Claude Code decomposes the task into atomic work items.
- Each work item gets a sprint assignment and instruction ID (INS-YYYY-MM-DD-NNN).
- Factory rule F4 enforces: no work without an instruction ID.

### 7.2 Route

- Claude Code selects the appropriate LiteLLM alias for the task.
- Request is routed through LiteLLM gateway to the target Ollama endpoint.
- Route selection is logged in the Instruction Pack (P1).

### 7.3 Execute

- Aider receives the task via MCP (Qoder stdio transport).
- Aider writes code, runs tests, commits to the feature branch.
- Factory rule F8 enforces branch prefix conventions.
- All file edits and shell commands are captured in the Execution Pack (P2).

### 7.4 Evaluate

- **Automated:** pytest, ruff check, mypy against the diff.
- **Guardian:** 16 deterministic rules evaluated (8 factory + 8 project).
- **Canon Judge:** LLM evaluation against ADR-025 (audit mode — log only, no block).
- Results populate the Evaluation Pack (P3) and Audit Pack (P4).

### 7.5 Review

- Claude Code reviews the diff, test results, and Guardian verdicts.
- If all verdicts are PASS: proceed to promote.
- If any verdict is WARN: reviewer may proceed with documented justification.
- If any verdict is BLOCK: defer immediately.

### 7.6 Promote / Defer

- **Promote:** PR is created, operator sign-off requested, merged to target branch.
- **Defer:** Work item returns to Plan phase with diagnostic notes. Defer reason is appended to the roadmap (append-only per F3).

---

## 8. Approval Model

### 8.1 Automated approvals (LOW risk)

- All Guardian rules PASS.
- All tests PASS.
- No compliance-sensitive files touched.
- Canon Judge verdict is PASS or WARN.

### 8.2 Operator gate (MEDIUM risk)

Required when:
- Any Guardian rule returns WARN.
- Destructive operations are requested (Stop-Barrier list in CLAUDE_CODE_CANON.md).
- P0 priority deprioritisation (requires explicit `operator-override` in prompt/diff).
- ADR amendments.

### 8.3 MLRO gate (HIGH risk)

Required when:
- Changes touch compliance paths: `compliance/cases/`, `kyc/raw/`, payment routing.
- AML/KYC validation logic is modified.
- CASS 15 reconciliation logic is modified.

### 8.4 CTIO gate

Required when:
- New model added to LiteLLM config.
- Cluster topology changed (new node, GPU rebalance).
- ADR created or amended.

### 8.5 Ruflo checkpoint

[UNKNOWN: Ruflo integration is referenced as a mandatory regulated checkpoint but no concrete implementation exists in the repo. This section will be populated when the Ruflo tool or process is defined. Current assumption: Ruflo is an external regulated-industry quality gate that wraps the operator/MLRO approval into a single auditable checkpoint.]

---

## 9. Mandatory Artefact Set

Every completed work unit must produce:

| Artefact | Format | Location | Retention |
|----------|--------|----------|-----------|
| Instruction record | Markdown | docs/audit/ or sprint doc | Permanent (git) |
| Git commit(s) | Git | Feature branch | Permanent (git) |
| Test results | pytest output | CI / local log | Per sprint |
| Guardian audit log | JSON | ClickHouse `guardian_audit_factory` + `guardian_audit_project` | 5 years (TTL) |
| Canon Judge evaluation | JSON | ClickHouse or local log | 5 years (TTL) |
| PR with sign-off | GitHub PR | GitHub | Permanent |
| Rollback plan | Markdown | PR body or docs/runbooks/ | Permanent (git) |

---

## 10. Promotion / Defer Rules

### 10.1 Promotion criteria (ALL must be true)

1. All 16 Guardian rules return PASS (no BLOCK, no unresolved WARN).
2. pytest passes with zero failures.
3. ruff check passes with zero errors.
4. Canon Judge verdict is PASS (WARN acceptable with documented justification).
5. Operator sign-off recorded (for MEDIUM+ risk).
6. MLRO sign-off recorded (for HIGH risk / compliance).
7. PR approved by at least one human reviewer.

### 10.2 Defer criteria (ANY triggers defer)

1. Any Guardian rule returns BLOCK.
2. pytest failures.
3. Compliance-sensitive change without MLRO sign-off.
4. Operator explicitly rejects.
5. Rollback plan missing for infrastructure changes.

### 10.3 Defer handling

- Deferred items return to Plan phase.
- Defer reason is appended to the roadmap (append-only, per factory rule F3).
- Deferred items are re-prioritised in next sprint planning.
- Maximum 2 consecutive deferrals before escalation to CTIO.

---

## 11. Canon Amendment Rules

### 11.1 Amendment process

1. Proposed amendment is drafted as a PR against this document.
2. Factory rule F5 enforces: ADR amendment must be paired with implementation.
3. Canon Judge evaluates the amendment against ADR-025.
4. Operator approval required for all amendments.
5. CTIO approval required for structural changes (new roles, new packs, new invariants).

### 11.2 Amendment constraints

- Invariants (Section 3) can only be amended with CTIO + Operator dual sign-off.
- Role matrix (Section 4) amendments require CTIO approval.
- Route binding (Section 5) amendments require CTIO approval.
- Operating loop (Section 7) amendments require Operator approval.
- All amendments are versioned: v1.1, v1.2, etc. Major structural changes increment major version.

### 11.3 Emergency amendments

- In case of security incident or regulatory deadline, Operator may apply a temporary amendment with a 72-hour expiry.
- Temporary amendments must be ratified or reverted within the expiry window.
- All temporary amendments are logged in ClickHouse with `amendment_type=EMERGENCY`.

---

## Appendix A: Evidenced Capabilities

This canon is grounded in the following repo artefacts:

| Capability | Evidence |
|------------|----------|
| Guardian two-family architecture | `guardian/README.md`, `guardian/src/rules/` |
| 16 deterministic rules (F1-F8, P1-P8) | `factory_rules.py`, `project_rules.py` |
| Canon Judge MCP server | `guardian/src/canon_judge/mcp/server.py` |
| Aider as sole executor | `.aider.conf.yml`, `COLLAB.md`, `docs/COLLAB.md` |
| LiteLLM gateway | `litellm/litellm-config.v2.yaml` |
| ClickHouse audit persistence | `guardian/src/storage/clickhouse.py` |
| HITL risk matrix | `guardian/src/memory_loader.py` (HITL-MATRIX.yaml) |
| Canon enforcement (Safe/Stop/Default) | `tools/patch_canon_safe_barrier.py` |
| Operator override pattern | `project_rules.py` (P1 rule) |
| Roadmap append-only | Factory rule F3 |
| Branch prefix enforcement | Factory rule F8 |
| Instruction ID tracking | Factory rule F4 |
| ADR amendment pairing | Factory rule F5 |

### Unevidenced / Unknown

| Item | Status |
|------|--------|
| Ruflo checkpoint integration | Referenced but not implemented — placeholder in Section 8.5 |
| promptfoo adversarial evaluation | Not found in repo — Sprint 4 deliverable |
| MLRO designation | Role defined, person not designated |
| CTIO designation | Role defined, person not designated |
| Automated PR creation in factory loop | Pattern exists but not wired end-to-end |

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| **Canon** | The binding set of rules governing factory operation |
| **Guardian** | Deterministic rule engine (two families: Factory + Project) |
| **Canon Judge** | LLM-based evaluator checking output against ADR-025 |
| **Pack** | A mandatory artefact bundle produced by each work unit |
| **HITL** | Human In The Loop — decision matrix for approval routing |
| **Ruflo** | [UNKNOWN] Regulated-industry quality checkpoint |
| **Operator** | Human with final approval authority |
| **MLRO** | Money Laundering Reporting Officer — compliance gate |
| **CTIO** | Chief Technology/Innovation Officer — architecture gate |
| **Defer** | Return a work item to Plan phase with diagnostic notes |
| **Promote** | Merge a completed work item to target branch |
