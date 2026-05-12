# Sprint 4 — ML Track Opening Criteria Readiness Check

Document ID: SPRINT4-READINESS-2026-05-12
Status: REVIEW PASS
Scope: Sprint 4 review pass per Clause 14.5 (SESSION-CANON 2026-05-11)
Track: Innovation Sandbox
Date: 2026-05-12

---

## 1. Scope

This document audits the readiness of each of the four mandatory
prerequisites (Conditions A–D) defined in
`docs/audit/ml-track-opening-criteria-2026-05-11.md` for opening the
ML track. The ML track cannot begin until ALL four conditions are met.

This is a documentation-only review pass. No infrastructure mutations,
no external repo writes, no model downloads were performed.

---

## 2. Reference

- ML track opening criteria: `docs/audit/ml-track-opening-criteria-2026-05-11.md` (PR #215)
- Innovation sandbox roadmap: `docs/audit/innovation-sandbox-roadmap-2026-05-11.md` (PR #215)
- Sprint 3 candidate matrix review: `docs/audit/sprint3-candidate-matrix-review-2026-05-12.md` (PR #217)
- HITL L3 policy: `docs/policies/hitl-l3-agent-gate-2026-05-11.md` (PR #207)
- HITL decision recording runbook: `docs/runbooks/hitl-decision-recording.md` (PR #207)
- SESSION-CANON 2026-05-11, Clauses 1–14, VI.b, VI.c

---

## 3. Per-Prerequisite Readiness

### Condition A — Training Dataset

**Status: NOT-STARTED**

**Owner needed:** Data team + operator

**Required artifacts (per ml-track-opening-criteria §3 Condition A):**

| Artifact | Status | Notes |
|---|---|---|
| Data source identification document | MISSING | No data source has been named or discussed |
| Schema definition | MISSING | No schema exists |
| Label / target class definition | MISSING | Route classes proposed in roadmap §4 (fraud_signal, compliance_query, reasoning_task, developer_task) but not validated against real data |
| Storage location approval | MISSING | No storage path designated |
| Data handling path review | MISSING | No review initiated |

**What Sub-A can do without operator:** Nothing. Sub-A has no authority
over dataset sourcing, storage approval, or data handling policy. These
require operator + data team decisions.

**What unblocks this condition:** Operator names a dataset source (e.g.,
historical request logs from LiteLLM proxy, compliance-api audit logs,
or synthetic generation plan) and grants approval for a data handling path.

---

### Condition B — Integration Point in banxe-compliance-api

**Status: NOT-STARTED**

**Owner needed:** banxe-emi-stack team + operator

**Required artifacts (per ml-track-opening-criteria §3 Condition B):**

| Artifact | Status | Notes |
|---|---|---|
| Exact call site in banxe-compliance-api | MISSING | No call site identified |
| Request/response contract | MISSING | No contract drafted |
| Failure behavior specification | MISSING | No failure mode documented |
| Rollback behavior specification | MISSING | No rollback path documented |

**What Sub-A can do:** Draft a sample request/response contract proposal
for operator review. This would be a non-binding template showing what a
classifier integration call might look like (input: request text, output:
route class + confidence score). Sub-A cannot open PRs against
banxe-compliance-api or banxe-emi-stack without operator authorization
(SESSION-CANON Clause VI.c).

**What unblocks this condition:** Operator authorizes Sub-A to open a
draft PR against banxe-emi-stack with the contract proposal, OR assigns
the integration task directly to the banxe-emi-stack team.

---

### Condition C — Evaluation Protocol

**Status: NOT-STARTED**

**Owner needed:** Operator + CTIO (for reviewer naming)

**Required artifacts (per ml-track-opening-criteria §3 Condition C):**

| Artifact | Status | Notes |
|---|---|---|
| Offline evaluation procedure | MISSING | No eval procedure written |
| Baseline model designation | MISSING | No baseline defined (candidates exist per Sprint 3 matrix but no baseline selected) |
| Comparison metrics list | MISSING | No metrics defined |
| Named reviewer for acceptance | MISSING | No reviewer assigned |

**What Sub-A can do:** Draft a template evaluation protocol covering:
offline accuracy measurement against labeled data, latency benchmarks
on target hardware, comparison between classifier candidates
(Qwen2.5-0.5B vs alternatives), and a pass/fail decision framework.
This would be a non-binding template for operator review.

**What unblocks this condition:** Operator names a reviewer who will
accept or reject evaluation results, and approves the metric set
(e.g., accuracy threshold, latency ceiling, false-positive tolerance
for regulated route classes).

---

### Condition D — HITL + Audit Path

**Status: PARTIAL**

**Owner needed:** Operator + CTIO

**Existing foundation (DONE):**

| Artifact | Status | Location |
|---|---|---|
| HITL L3 agent gate policy | DONE | `docs/policies/hitl-l3-agent-gate-2026-05-11.md` (PR #207) |
| HITL decision recording runbook | DONE | `docs/runbooks/hitl-decision-recording.md` (PR #207) |
| custom_code guardrail with 8 regulated keywords | DONE | Active in LiteLLM config (PR #200) |

These three artifacts establish that:
- a human escalation policy exists for agent-gated decisions
- a recording procedure exists for HITL decisions
- a keyword-based guardrail actively blocks regulated terms at the proxy level

**Concrete missing artifacts:**

| Artifact | Status | Notes |
|---|---|---|
| Escalation rule wiring into compliance-api decision path | MISSING | The HITL L3 policy exists as a standalone document but is not wired into the compliance-api flow |
| Audit event sink contract (ClickHouse table + schema) | MISSING | The recording runbook describes the procedure but does not specify the concrete sink (table name, schema, retention policy) |
| "No silent bypass" enforcement contract | MISSING | The intent is documented but no machine-enforceable contract ensures that regulated decisions cannot bypass review |

**What Sub-A can do:** Draft an escalation rule specification and a
ClickHouse audit table schema proposal for operator review. These
would be non-binding design documents.

**What unblocks this condition:** Operator approves the ClickHouse
schema (table name, column definitions, retention policy) and assigns
the wiring task to connect the escalation rule to the compliance-api
decision path.

---

## 4. Summary Table

| Condition | Description | Status | Sub-A Action Available | Operator Action Required |
|---|---|---|---|---|
| A | Training dataset | NOT-STARTED | None (out of authority) | YES — name dataset source, approve handling path |
| B | banxe-compliance-api integration | NOT-STARTED | Draft contract template | YES — authorize cross-repo PR or assign to team |
| C | Evaluation protocol | NOT-STARTED | Draft eval template | YES — name reviewer, approve metric set |
| D | HITL + audit path | PARTIAL | Draft escalation rule + audit schema | YES — approve ClickHouse schema, assign wiring |

**Overall ML track status: BLOCKED**

---

## 5. Recommendation

Sprint 5 (Pilot plan) remains **BLOCKED** until at minimum Conditions A
and D are fully met. Conditions B and C can be progressed in parallel
with A/D but are also required before pilot execution.

**Immediate productive actions (operator authorization required):**

1. Sub-A can draft a sample integration contract for Condition B — a
   non-binding template showing classifier call shape, input/output
   format, failure modes. This requires only operator saying "go ahead
   and draft it."

2. Sub-A can draft a template evaluation protocol for Condition C —
   covering offline accuracy, latency benchmarks, candidate comparison
   framework. This requires only operator saying "go ahead and draft it."

3. Sub-A can draft a ClickHouse audit schema and escalation rule
   specification for Condition D — building on the existing HITL L3
   policy foundation. This requires only operator approval.

**Actions that require operator + team coordination (Sub-A cannot initiate):**

1. Condition A — dataset source identification. This requires the data
   team to name what data exists, whether it can be used, and how it
   should be handled.

2. Condition B — actual PR against banxe-emi-stack. Sub-A is prohibited
   from mutating that repo (SESSION-CANON Clause VI.c).

3. Condition C — reviewer naming. Only the operator or CTIO can assign
   a human reviewer for evaluation results.

4. Condition D — ClickHouse schema approval and wiring implementation.
   This is an infrastructure decision that crosses repo boundaries.

---

## 6. Decision

**Sprint 4 review pass: CLOSED-WITH-NOTES**

The review pass is complete. All four conditions have been audited against
their defined requirements. The current state is:

- 0 of 4 conditions fully met
- 1 of 4 conditions partially met (D — HITL foundation exists)
- 3 of 4 conditions not started

Sub-A has identified concrete draft artifacts it can produce for
Conditions B, C, and D if operator authorizes. No autonomous start is
permitted under SESSION-CANON Clause VI.c.

**Next:** Sprint 5 (Pilot plan) — BLOCKED on operator action for
Conditions A/B/C/D as documented in this audit. Sub-A returns to
STANDBY per §IX.

---

## 7. References

- ADR-035 (closed)
- ADR-036 (closed)
- SESSION-CANON 2026-05-11, Clauses 1–14
- PR #207 — HITL L3 agent gate policy
- PR #200 — custom_code guardrail
- PR #215 — Innovation sandbox roadmap + ML track opening criteria
- PR #217 — Sprint 3 candidate matrix review
