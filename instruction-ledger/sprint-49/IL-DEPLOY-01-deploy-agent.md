# IL-DEPLOY-01: CTO DeployAgent + DeployPort (PROPOSED → IMPLEMENTED)

- Sprint: 49
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack (branch feat/sprint-49-cto-deploy)
- Root ledger anchor: IL-177
- ADR: ADR-081 (CTO DeployPort — prepare-vs-execute, prod requires CTO approval)
- Created: 2026-06-11

## Context
ORG-STRUCTURE §2.7.2 (CTO / AI Platform, SMF26 — Infrastructure / DevOps) defines `DeployAgent`:
**Staging — L2 Review, gate CTO**; **Production — L3, gate CTO must approve**. This is the first
mask whose action has a **state-changing side effect** (a deployment), not a read — the most
safety-critical agent so far. The ADR-049 §D2 mask needs an injectable port that makes execution
**structurally impossible without an explicit human-approval token** — ADR-081 adds one port-first.

Only DeployAgent is built this sprint. `MonitoringAgent` (§2.7.2, L1) and `MLPipelineAgent`
(§2.7.1, L3/I-27) are deferred.

## Delivered
### ADR-081 port (`services/deploy/deploy_port.py`)
`DeployPort` — abc.ABC + `InMemoryDeployPort` + `DeployPortError`. `DeployEnv(StrEnum)` = STAGING /
PRODUCTION; frozen DTOs `DeploymentPlan` / `ApprovalRequest` / `DeployResult`.
- `prepare_deployment(target_env)` — read/validate/propose, no side effect.
- `request_approval(plan)` — raise the action to the human (CTO) gate.
- `execute_deployment(plan, approval_token)` — the only state-changing method; **raises
  `DeployPortError` when the token is absent or invalid** (prod mandatory; staging requires a CTO
  review token too). There is no parameterless / autonomous execute path. No real CI/CD integration
  (I-10) — InMemory test impl only.

### Agent (`services/agents/deploy_agent.py`, ORG §2.7.2)
Full ADR-049 §D2 gate-chain where the **step-up position is the CTO approval token** (the analogue
of ADR-078's £100k→CFO step-up). prepare = read (AUTO). deploy_staging = L2: `force_review=True`,
token carried as `human_reviewed_by`; no token → HOLD_FOR_REVIEW (proceed=False, `execute_deployment`
not called, escalate→CTO); with token → execute. deploy_production = L3: `force_review=True` always
(`requires_step_up=True`); no/empty token → HALT (port.execute never called, escalate→CTO); with a
token → execute (port re-validates, raises on invalid → recorded then re-raised). One ADR-046
`AgentDecisionRecord` per action; port + recorder injected.

### Safety invariant + R-SEC (enforced in code + test)
**The agent NEVER autonomously executes a production deployment.** `test_production_no_token_halt_at_
confidence_100` proves prod at confidence=1.0 with no token still HALTs and a call-spy confirms
`port.execute_deployment` is never invoked. No scope op bypasses approval (`DeployPort.autonomous_
execute` is not on the allow-list). **R-SEC:** the approval token is credential-like and appears in
NO `AgentDecisionRecord` field (six explicit assertions); lineage carries only opaque handles
(plan_id, target_env).

## Verification
- 54 tests; 100% coverage on both new modules (`deploy_port.py` 54 stmts, `deploy_agent.py` 157
  stmts). ruff check + `ruff format --check` clean; semgrep (banxe-rules) clean; full suite 10668
  passed / 0 failed.
- Branches covered: prepare AUTO; staging no-token → HOLD, with-token → execute; prod no-token →
  HALT (execute never called) even at confidence=1.0, valid-token → execute, invalid-token →
  DeployPortError emit+reraise; HALT_UNRESOLVED_PROCESS; REJECT_OUT_OF_SCOPE (autonomous-execute
  refused); BLOCK_LOW_CONFIDENCE; HALT_COST_CAP_BREACH (per-request + per-window);
  HALT_COMPLIANCE_BLOCK (escalate→CTO); ValueError on out-of-range confidence; band boundaries;
  R-SEC token-not-in-lineage; one record per action; the no-autonomous-prod-deploy invariant.

## Doc-sync (this PR, banxe-architecture)
- `docs/adr/ADR-081-cto-deploy-port.md` (new).
- `docs/ORG-STRUCTURE.md` §2.7.2 — `(PROPOSED)` removed on both DeployAgent rows (staging + prod);
  MonitoringAgent + MLPipelineAgent untouched.
- `INSTRUCTION-LEDGER.md` — root block `### IL-177` (append-only; IL-175 = PR #404, IL-176 = the
  ORG↔code reconciliation audit PR #405, so DeployAgent lands as IL-177).
- `MEMORY.md` — sprint-49 block.
