# Condition C — Evaluation Protocol (Draft)

Document ID: COND-C-DRAFT-2026-05-12
Status: DRAFT — reviewer not yet named
Scope: Condition C draft per Sprint 4 audit (PR #219)
Track: Innovation Sandbox / Conditions A–D batch (Clause 16)
Date: 2026-05-12

---

## 1. Scope

Condition C requires four artifacts:
1. Offline evaluation procedure
2. Baseline model designation
3. Comparison metrics list
4. Named reviewer for result acceptance

This document drafts artifacts 1–3. Artifact 4 (reviewer naming) is an
operator/CTIO decision that Sub-A cannot make.

---

## 2. Offline Evaluation Procedure

### 2.1 Validation set

- Source: held-out split from the training dataset (Condition A)
- Split: 10% of total labeled samples designated as validation set
- Stratification: equal representation across all 4 classes
- Minimum size: 1000 samples per class (4000 total in validation set)

### 2.2 Classes

| Class | Description |
|---|---|
| `fraud_signal` | Prompt suggests transaction with fraud indicators |
| `compliance_query` | Prompt asks about FCA, AML, KYC, safeguarding, regulatory interpretation |
| `reasoning_task` | Multi-step reasoning, typically non-regulated |
| `developer_task` | Coding or DevOps request from internal user |

### 2.3 Evaluation steps

1. Load validation set (labeled, held-out, never seen during training)
2. For each sample, run classifier (Qwen2.5-0.5B) inference
3. Record: sample_id, true_label, predicted_label, confidence_score,
   inference_latency_ms
4. Compute metrics (see §4)
5. Generate confusion matrix
6. Flag any sample where classifier would route a regulated-class
   prompt to a non-HITL path
7. Compile report (see §7)

### 2.4 Environment

- Hardware: evo2 (128 GB RAM, Vulkan GPU stack)
- Serving: ollama or llama-server (whichever is used during pilot)
- No external API calls during evaluation
- All evaluation runs on-prem within Banxe perimeter

---

## 3. Baseline Model Designation

**Baseline: current rule-based router (no classifier)**

The current LiteLLM router uses static routing rules without any
ML classifier. This is the baseline against which the classifier
candidate is compared.

Baseline behavior:
- All requests routed by model alias in LiteLLM config
- No per-request classification
- Guardrail keywords checked via custom_code (PR #200)
- L3 decisions escalated per HITL policy (PR #207)

The baseline routing accuracy on the labeled validation set is
measured by mapping each sample's true label to the route that
the current static config would assign. This establishes the
"no-classifier" accuracy floor.

---

## 4. Comparison Metrics

| Metric | Definition | How measured |
|---|---|---|
| Routing accuracy (overall) | % of samples where predicted_label == true_label | Correct / total |
| Routing accuracy (per-class) | Same, computed per class | Correct per class / total per class |
| F1 score (per-class) | Harmonic mean of precision and recall per class | Standard F1 formula |
| F1 score (macro average) | Unweighted mean of per-class F1 | Mean of 4 per-class F1 scores |
| p99 classification latency | 99th percentile inference time | From validation run timing data |
| False-block rate | % of non-regulated samples incorrectly classified as fraud_signal or compliance_query | False positives in regulated classes / total non-regulated samples |
| Confusion matrix | 4x4 matrix of true vs predicted | Standard confusion matrix |

---

## 5. Acceptance Thresholds (Proposed)

These thresholds are proposals for the reviewer to approve or adjust.
They are not binding until the reviewer signs off.

| Metric | Threshold | Rationale |
|---|---|---|
| Routing accuracy (overall) | >= 85% | Minimum viable accuracy for shadow-mode evaluation |
| F1 per class | >= 0.80 | No single class should be systematically misclassified |
| p99 classification latency | < 100 ms on evo2 (Vulkan) | Must not add perceptible delay even if wired in future |
| False-block rate | 0% | Classifier must never cause a false block on guardrail keywords |

### Critical safety threshold

If the classifier would route ANY `compliance_query` or `fraud_signal`
sample to a non-HITL path, this is an automatic FAIL regardless of
other metrics. Regulated classes must always reach HITL review.

---

## 6. Reviewer Naming

**Reviewer: ________ (CTIO or MLRO)**

The reviewer must be named by the operator or CTIO before the pilot
begins. The reviewer's responsibilities:

1. Approve or adjust acceptance thresholds (S5) before pilot start
2. Review daily pilot metrics (Day 1-7)
3. Review final evaluation report (Day 7)
4. Issue binding go/no-go decision (Day 8)
5. Sign off on any threshold adjustments during the pilot

Sub-A cannot name the reviewer. This is an operator action.

---

## 7. Reporting Format

### Evaluation report

- Format: Markdown document at `docs/audit/pilot-results-<date>.md`
- Sections:
  1. Evaluation parameters (model, hardware, dataset version)
  2. Overall metrics table
  3. Per-class metrics table
  4. Confusion matrix (rendered as Markdown table)
  5. Latency distribution (p50, p90, p95, p99)
  6. Safety check results (regulated-class routing correctness)
  7. Comparison with baseline
  8. Reviewer sign-off block

### Raw data export

- ClickHouse export of all prediction records from the pilot period
- Format: CSV or Parquet, stored on-prem
- Retention: same as audit sink (7 years)

---

## 8. Operator Actions Required

- [ ] Name a reviewer (CTIO or MLRO)
- [ ] Reviewer approves or adjusts acceptance thresholds
- [ ] Approve evaluation hardware (evo2) for dedicated eval runs
- [ ] Approve raw data retention policy

---

## 9. Decision

Condition C draft: COMPLETE.
Execution: NOT STARTED — requires reviewer naming by operator/CTIO.

---

## 10. References

- PR #219 — Sprint 4 readiness audit
- PR #223 — Sprint 5 pilot plan
- `docs/audit/condition-a-training-dataset-2026-05-12.md` (dataset dependency)
- `docs/audit/condition-d-hitl-audit-sink-2026-05-12.md` (audit sink dependency)
