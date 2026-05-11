# ML Track Opening Criteria
Document ID: ML-TRACK-OPEN-2026-05-11
Status: PLANNED / NOT STARTED
Repo: banxe-architecture
Parent Context: Part 8 innovation sandbox

## 1. Intent
This document defines when the next ML track may start.

That next track is not an infra track.
It is an ML track and must begin only when both of the following exist:
1. training dataset
2. integration point in banxe-compliance-api

## 2. Why the ML track is not open yet
The branch currently contains planning and deferred documentation.
It does not yet contain the minimum execution prerequisites for ML work.

Missing prerequisites:
- labeled or otherwise defined training dataset
- integration contract with banxe-compliance-api
- evaluation protocol
- acceptance thresholds
- audit path for model-assisted decisions

## 3. Mandatory opening conditions
The ML track may open only when all conditions below are satisfied.

### Condition A — Training dataset exists
Minimum expectation:
- data source identified
- schema defined
- labels or target classes defined
- storage location approved
- data handling path reviewed

### Condition B — Integration point exists
Minimum expectation:
- exact call site in banxe-compliance-api identified
- expected request and response contract documented
- failure behavior documented
- rollback behavior documented

### Condition C — Evaluation protocol exists
Minimum expectation:
- offline evaluation procedure written
- baseline model defined
- comparison metrics defined
- reviewer named for result acceptance

### Condition D — HITL and audit path exist
Minimum expectation:
- human escalation rule written
- audit event sink identified
- regulated decisions never bypass review silently

## 4. Proposed first ML track
Suggested title:
ML follow-up: classifier and orchestration candidate evaluation

Suggested scope:
- evaluate small classifier candidate
- define route classes
- compare fast-tier candidates
- produce recommendation, not production cutover

Suggested first candidates:
- classifier: Qwen2.5-0.5B
- fast reasoning: ZAYA1-8B
- domain reasoning: qwen3-banxe

## 5. Explicit non-goals for the first ML track
The first ML track should NOT:
- replace the full deep reasoning tier
- force production routing changes
- bypass HITL
- claim production quality from synthetic-only testing
- merge infra and ML changes into one uncontrolled step

## 6. Exit criteria for the first ML track
The first ML track is complete only if it produces:
- dataset note
- integration note
- evaluation report
- recommendation on classifier viability
- recommendation on fast-tier viability
- explicit go / no-go decision

## 7. Decision memory
Decision:
- this terminal remains the sandbox for innovation planning
- ML execution is blocked until dataset and integration point exist
- when those conditions are met, ML work may continue in this same terminal under the sandbox canon
