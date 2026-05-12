# Sprint 5 — Pilot Plan (Draft)

Document ID: SPRINT5-PILOT-PLAN-2026-05-12
Status: DRAFT — pilot is NOT scheduled
Scope: Sprint 5 of innovation-sandbox-roadmap-2026-05-11 (PR #215)
Author: Sub-terminal A under Clause 14.3 (SESSION-CANON 2026-05-11)
Track: Innovation Sandbox
Date: 2026-05-12

---

## 1. Scope

This document defines what the first innovation sandbox pilot would
look like, its go/no-go criteria, fail-stop rules, and rollback path.

**This is a planning document only.** Pilot activation requires all
four prerequisites from the Sprint 4 audit (PR #219) to be marked DONE.
As of 2026-05-12, none are fully met (D is PARTIAL, A/B/C are
NOT-STARTED). Sub-A cannot initiate the pilot under any circumstance
without operator delivery of A/B/C/D completion evidence (SESSION-CANON
Clause VI.c).

---

## 2. Pilot Subject

**Target:** Classifier-tier evaluation using candidate Qwen2.5-0.5B.

**Goal:** Validate whether a 0.5B always-on classifier can route
incoming compliance/KYC/AML/reasoning/developer requests correctly
enough to justify a production rollout decision.

**Out of scope:**
- Deep-tier replacement (qwen3:235b remains unchanged)
- Production routing changes (LiteLLM router unchanged)
- banxe-compliance-api code path mutation
- Any model download or removal without operator approval

---

## 3. Shadow-Mode Design

The pilot operates in shadow-mode only. No customer-facing behavior
changes.

```
                    ┌──────────────────────┐
  Request ──────────►  LiteLLM Router      ├──────► Response (unchanged)
                    │  (current config)    │
                    └─────────┬────────────┘
                              │ async tap (post-response)
                              ▼
                    ┌──────────────────────┐
                    │  Classifier          │
                    │  (Qwen2.5-0.5B,      │
                    │   evo2, shadow only) │
                    └─────────┬────────────┘
                              │ record only
                              ▼
                    ┌──────────────────────┐
                    │  ClickHouse audit     │
                    │  sink (per Cond D)   │
                    └──────────────────────┘
```

**Design principles:**

1. All real production requests continue to be served by the current
   LiteLLM router unchanged.
2. A parallel async tap forwards request prompts (sanitized,
   guardrail-passed) to the classifier endpoint on evo2.
3. Classifier output is recorded in the ClickHouse audit sink. It is
   NOT used to alter routing decisions.
4. No customer-facing latency increase: the classifier runs after the
   response is returned to the caller.
5. The guardrail keyword deny-list (8 regulated keywords, PR #200)
   fires BEFORE the classifier sees the text — the classifier never
   processes raw regulated content.

---

## 4. Pre-Launch Gates

All four conditions from `docs/audit/ml-track-opening-criteria-2026-05-11.md`
must be satisfied and marked DONE in
`docs/audit/sprint4-ml-track-readiness-2026-05-12.md` BEFORE activation.

| Gate | Condition | Required status |
|---|---|---|
| A | Training dataset | DONE — source identified, schema defined, labels defined, storage approved, handling path reviewed |
| B | banxe-compliance-api integration point | DONE — call site identified, contract documented, failure and rollback behavior documented |
| C | Evaluation protocol + named reviewer | DONE — offline eval procedure written, baseline model defined, metrics defined, reviewer named |
| D | HITL + audit path | DONE — escalation rule wired, audit sink schema approved, no-silent-bypass enforcement contract in place |

**Current status (as of 2026-05-12):** A NOT-STARTED, B NOT-STARTED,
C NOT-STARTED, D PARTIAL. **Pilot launch: BLOCKED.**

---

## 5. Success Metrics (Proposed)

These metrics are subject to approval by the reviewer named under
Condition C. They are proposed starting points, not binding thresholds.

| Metric | Target | Measurement method |
|---|---|---|
| Routing accuracy | ≥ 85% on labeled validation set | Compare classifier output vs ground-truth labels |
| p99 classification latency | < 100 ms on evo2 (Vulkan) | Measure from prompt receipt to class output |
| False blocks on guardrail keywords | Zero | Classifier must not interfere with guardrail pipeline |
| Customer-facing impact | Zero | Proven by shadow-mode dual logs (production log vs classifier log, no divergence in served responses) |

---

## 6. Fail-Stop Rules

Any of the following triggers an immediate halt of the pilot:

| Trigger | Action |
|---|---|
| Classifier output would route a regulated-keyword prompt to anything other than HITL | Immediate halt + ASK to operator |
| p99 latency > 500 ms sustained over a 10-minute window | Automatic classifier-off (LiteLLM tap disabled) |
| Any divergence between shadow-mode decisions and production routing that the reviewer flags as risk | Pilot paused, investigation per Condition C reviewer |
| Any audit sink write failure (ClickHouse unavailable) | Classifier tap disabled until sink restored |
| Operator or CTIO requests halt for any reason | Immediate halt, no questions asked |

---

## 7. Rollback Path

Rollback is a single-step operation:

1. **Disable classifier tap** in LiteLLM config (one-line change:
   remove or comment the async tap block).
2. **Keep classifier model on evo2** — no model removal. The model
   remains available for future evaluation without re-download.
3. **Restore previous LiteLLM config** from the timestamped `.bak`
   file created at pilot start.
4. **Record post-mortem** in `docs/audit/hitl-decisions-*.md` per
   runbook RB-HITL-001, including: reason for rollback, data collected
   during pilot, and recommendation for next steps.

**Rollback time estimate:** Under 2 minutes (config revert + LiteLLM
restart). No data loss — all shadow-mode records remain in ClickHouse.

---

## 8. Pilot Lifecycle

| Day | Activity | Gate |
|---|---|---|
| Day 0 | Prerequisites A/B/C/D verified as DONE. Operator approves ASK. Classifier model downloaded to evo2 under operator approval (Clause VI.c). | Operator sign-off required |
| Day 1 | Shadow-mode tap enabled on Legion LiteLLM. Classifier begins receiving sanitized prompts. | Fail-stop rules active |
| Day 1–7 | Collect labeled samples + classifier predictions. Monitor latency, accuracy on known labels, audit sink integrity. | Daily check by reviewer (Condition C) |
| Day 7 | Evaluation report produced per Condition C protocol. Accuracy, latency, false-block rate, and divergence analysis compiled. | Report delivered to reviewer |
| Day 8 | Reviewer issues go/no-go decision. | Binding decision |
| If GO | Phase 2 plan drafted (still no production routing changes until separate ASK approved by operator). | New ASK required |
| If NO-GO | Pilot wound down. Classifier tap disabled. Lessons captured in post-mortem. Candidate replaced or matrix updated in sandbox roadmap. | Post-mortem recorded per RB-HITL-001 |

---

## 9. Explicit Non-Goals

This pilot does NOT:

- Replace any existing production routing path.
- Modify any banxe-compliance-api endpoint or code path.
- Make autonomous decisions — the classifier is advisory only during
  shadow-mode and its output is never used for real routing.
- Serve as a benchmark of model quality alone — it is a validation of
  operational fit (latency, integration stability, audit compliance).
- Establish precedent for skipping prerequisites in future pilots.
- Authorize Sub-A to independently proceed to Phase 2 — a separate
  operator ASK is required even after a GO decision.

---

## 10. Decision

**Sprint 5 plan: DONE (as draft).**

This document completes the innovation sandbox roadmap at the
documentation layer. All 5 sprints are now closed:

| Sprint | Title | Status |
|---|---|---|
| 1 | Deferred package closure | CLOSED (PR #210, #215) |
| 2 | Routing sandbox definition | CLOSED (PR #215) |
| 3 | Model candidate matrix review | CLOSED (PR #217) |
| 4 | ML track readiness audit | CLOSED (PR #219) |
| 5 | Pilot plan draft | CLOSED (this document) |

**Pilot launch remains BLOCKED** until operator delivers A/B/C/D
completion evidence in dedicated PRs. Sub-A cannot initiate pilot
execution, model downloads, compliance-api mutations, or production
routing changes (SESSION-CANON Clause VI.c).

---

## 11. References

- ADR-035 (closed)
- ADR-036 (closed)
- SESSION-CANON 2026-05-11, Clauses 1–14
- PR #200 — custom_code guardrail (8 regulated keywords)
- PR #207 — HITL L3 agent gate policy + decision recording runbook
- PR #215 — Innovation sandbox roadmap + ML track opening criteria
- PR #217 — Sprint 3 candidate matrix review
- PR #219 — Sprint 4 ML track readiness audit
