# Innovation Sandbox Roadmap
Document ID: SANDBOX-ROADMAP-2026-05-11
Status: ACTIVE PLANNING
Repo: banxe-architecture
Branch Role: Part 8 innovation sandbox + deferred documentation
Terminal Role: sanctioned proving ground for new model, routing, and agent ideas

## 1. Purpose
This branch serves two goals:
1. Close ADR-035 Part 8 as merge-ready deferred documentation.
2. Preserve and structure future innovation work without claiming production rollout.

This terminal is the sandbox for evaluating new ideas before they become production tracks.

## 2. What this branch already closes
This branch closes the documentation layer:
- deferred impact assessment for evo2 Q8_0 rollout
- final summary for ADR-035 Part 8
- HITL decision recording
- maintenance window planning and rollback expectations

In plain language:
- the branch explains what should happen later
- the branch does not claim the rollout already happened
- the branch keeps the decision trail clean and reviewable

## 3. What remains from the earlier smart orchestration goal
The earlier target was a smart orchestration system using existing Banxe AI components.

That larger goal is NOT closed by this branch yet.

Still open:
- request classifier before routing
- unified cache-first routing policy
- fast reasoning tier and deep reasoning tier split
- explicit HITL escalation thresholds
- model evaluation for new candidates
- integration into banxe-compliance-api
- training dataset for ML classifier work

In plain language:
- the architecture idea exists
- the production ML path does not yet exist
- this branch keeps the plan ready so execution can start later without losing context

## 4. Candidate target architecture
Proposed sandbox orchestration:

1. Classifier
   - purpose: detect request class before expensive routing
   - candidate: Qwen2.5-0.5B
   - output classes: fraud_signal, compliance_query, reasoning_task, developer_task

2. Cache
   - purpose: answer repeated requests before model execution
   - backend candidate: Redis / LiteLLM cache

3. Fast reasoning tier
   - purpose: low-cost first-pass reasoning
   - candidates: qwen3-banxe, ZAYA1-8B

4. Deep reasoning tier
   - purpose: expensive high-quality reasoning
   - candidates: GLM-4.5-Air, qwen3:235b

5. HITL gate
   - purpose: route low-confidence or regulated decisions to human review
   - audit sink: ClickHouse / audit log path

## 5. Sprint plan

### Sprint 1 — Deferred package closure
Goal:
- complete all Part 8 deferred documentation
Outputs:
- impact assessment
- final summary
- HITL record
- maintenance window runbook
Exit:
- branch is reviewable as documentation

### Sprint 2 — Routing sandbox definition
Goal:
- define the target orchestration flow without implementing production routing
Outputs:
- classifier -> cache -> fast -> deep -> HITL flow
- routing boundaries
- compliance path restrictions
Exit:
- sandbox architecture is documented and understandable

### Sprint 3 — Model candidate matrix
Goal:
- define candidate models and their intended role
Outputs:
- Qwen2.5-0.5B as classifier candidate
- ZAYA1-8B as fast reasoning candidate
- qwen3-banxe as domain compliance reasoning candidate
- GLM-4.5-Air and qwen3:235b as deep reasoning candidates
Exit:
- model selection logic is recorded with constraints

### Sprint 4 — ML track opening criteria
Goal:
- define what must exist before classifier or ML fine-tuning starts
Outputs:
- training dataset prerequisite
- evaluation protocol
- compliance-api integration prerequisite
- HITL and audit requirements
Exit:
- future ML track can be opened cleanly

### Sprint 5 — Pilot plan
Goal:
- define safe first pilot after prerequisites exist
Outputs:
- shadow-mode design
- rollback path
- success metrics
- fail-stop rules
Exit:
- pilot can be approved or rejected based on explicit criteria

## 6. Model candidate notes
### Qwen2.5-0.5B
Role:
- classifier candidate
Reason:
- small always-on routing model candidate

### ZAYA1-8B
Role:
- fast reasoning candidate
Reason:
- possible replacement for a heavier mid-tier reasoning slot
Constraint:
- must not be treated as production-ready in this branch without integration proof

### qwen3-banxe
Role:
- domain-specific reasoning candidate
Reason:
- domain continuity and Banxe-specific behavior

### GLM-4.5-Air
Role:
- deep reasoning candidate
Reason:
- strong higher-quality tier candidate

### qwen3:235b
Role:
- maximum reasoning tier
Reason:
- deep high-cost reasoning path

## 7. Non-goals
This branch does NOT:
- deploy new models into production
- train a classifier
- modify banxe-compliance-api
- claim benchmarking results not proven in-session
- claim shadow-mode is already active

## 8. Decision
Decision:
- continue this terminal as the innovation sandbox
- keep the branch as a documentation-first proving ground
- open execution tracks only after explicit prerequisites are met
