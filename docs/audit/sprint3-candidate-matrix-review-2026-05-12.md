# Sprint 3 — Candidate Matrix Review

Document ID: SPRINT3-REVIEW-2026-05-12
Status: REVIEW PASS
Scope: Sprint 3 review pass per Clause 14.5 (SESSION-CANON 2026-05-11)
Track: Innovation Sandbox
Date: 2026-05-12

---

## 1. Scope

This document records the Sprint 3 review pass for the Innovation Sandbox
track defined in PR #215. The goal is to compare the declared model candidate
matrix (from `docs/audit/innovation-sandbox-roadmap-2026-05-11.md` §6) against
the physical state of models on evo1, evo2, and Legion as of 2026-05-12.

No models were pulled, removed, or modified during this review.

---

## 2. Declared Matrix (verbatim from PR #215 §6)

| Candidate     | Declared Role            |
|---------------|--------------------------|
| Qwen2.5-0.5B  | Classifier               |
| ZAYA1-8B      | Fast reasoning           |
| qwen3-banxe   | Domain-specific reasoning|
| GLM-4.5-Air   | Deep reasoning           |
| qwen3:235b    | Maximum reasoning        |

---

## 3. Actual State (as of 2026-05-12)

### 3.1 Data Sources

- `ssh evo1 'ollama list'` — executed 2026-05-12
- `ssh evo2 'ollama list'` — executed 2026-05-12
- `ssh evo2 'ps -ef | grep llama-server'` — executed 2026-05-12
- `systemctl --user status litellm` — active (running), PID 2313804

### 3.2 Per-Candidate Status

#### Qwen2.5-0.5B — Classifier candidate

- **evo1:** ABSENT (not in ollama list)
- **evo2:** ABSENT (not in ollama list)
- **llama-server:** NOT RUNNING
- **Status: ABSENT**
- Note: No 0.5B-class model is present on any node. This is expected —
  classifier work is gated by Sprint 4 ML track prerequisites.

#### ZAYA1-8B — Fast reasoning candidate

- **evo1:** ABSENT (not in ollama list)
- **evo2:** ABSENT (not in ollama list)
- **llama-server:** NOT RUNNING
- **Status: ABSENT**
- Note: No ZAYA model variant found on any node. This model may require
  external sourcing and operator authorization before download.

#### qwen3-banxe — Domain-specific reasoning candidate

- **evo1:** ABSENT
- **evo2:** PRESENT as `qwen3:235b-a22b-banxe` (142 GB, modified 8 days ago)
- **llama-server:** NOT RUNNING (served via ollama)
- **Status: PRESENT (evo2 only)**
- Note: The `-banxe` tag variant exists on evo2 alongside the base
  `qwen3:235b-a22b`. This is the domain-adapted variant referenced in the
  candidate matrix. The model is a 235B-class model, not a lightweight
  domain-specific model — role alignment should be reviewed in Sprint 4.

#### GLM-4.5-Air — Deep reasoning candidate

- **evo1:** ABSENT (closest match: `huihui_ai/glm-4.7-flash-abliterated` — different model family and variant)
- **evo2:** ABSENT (same abliterated variant present, not GLM-4.5-Air)
- **llama-server:** NOT RUNNING
- **Status: ABSENT**
- Note: The `glm-4.7-flash-abliterated` model present on both nodes is NOT
  the declared GLM-4.5-Air candidate. These are different model versions with
  different capabilities. The abliterated variant was not declared in the
  candidate matrix and should not be treated as a substitute without evaluation.

#### qwen3:235b — Maximum reasoning candidate

- **evo1:** ABSENT
- **evo2:** PRESENT as `qwen3:235b-a22b` (142 GB, modified 8 days ago, via ollama)
- **evo2:** PRESENT-VIA-LLAMA-SERVER as Q3_K_S quantization on port 8082
  (40-layer GPU offload, ctx 8192, 16 threads, running since 2026-05-09)
- **Status: PRESENT (evo2, dual path)**
- Note: This model is physically available through two serving paths on evo2.
  The ollama instance serves the standard quantization; the llama-server
  instance serves the Q3_K_S quantization with partial GPU offload. Both
  are operational.

---

## 4. Drift Summary

| Candidate     | Declared Role            | Status                          |
|---------------|--------------------------|----------------------------------|
| Qwen2.5-0.5B  | Classifier               | ABSENT                          |
| ZAYA1-8B      | Fast reasoning           | ABSENT                          |
| qwen3-banxe   | Domain reasoning         | PRESENT (evo2)                  |
| GLM-4.5-Air   | Deep reasoning           | ABSENT                          |
| qwen3:235b    | Maximum reasoning        | PRESENT (evo2, dual path)       |

**PRESENT:** 2 of 5 candidates
**ABSENT:** 3 of 5 candidates

Drift vs Sprint 2 review: unchanged. No new models added or removed since
Sprint 2 review pass.

---

## 5. Additional Models Observed (not in candidate matrix)

These models are present on the infrastructure but were NOT declared in the
candidate matrix. Recorded for completeness:

### evo1
- qwen2.5-coder:7b-instruct-q4_K_M (4.7 GB)
- llama3.3:70b (42 GB)
- qwen3.5:35b (23 GB)
- qwen3:4b (2.5 GB)
- qwen3:30b-a3b (18 GB)
- qwen3.5:latest (6.6 GB)
- qwen3-coder-next:q4_K_M (51 GB)
- gurubot/gpt-oss-derestricted:20b (15 GB)
- huihui_ai/glm-4.7-flash-abliterated (18 GB)

### evo2
- llama3.3:70b (42 GB)
- qwen3.5:35b (23 GB)
- qwen3:4b (2.5 GB)
- qwen3:30b-a3b (18 GB)
- qwen3.5:latest (6.6 GB)
- qwen3-coder-next:q4_K_M (51 GB)
- gurubot/gpt-oss-derestricted:20b (15 GB)
- huihui_ai/glm-4.7-flash-abliterated (18 GB)

### Services
- LiteLLM proxy: active (running), PID 2313804, since 2026-05-11 14:09:54

---

## 6. Recommendations

### 6.1 Absent candidates eligible for download (HITL-gated)

- **Qwen2.5-0.5B** — small model (~0.5 GB expected). Download is technically
  trivial but MUST NOT proceed until Sprint 4 ML track prerequisites are met
  (training dataset, evaluation protocol, compliance-api integration point).
  Requires operator authorization.

### 6.2 Absent candidates requiring operator authorization

- **ZAYA1-8B** — external model, sourcing path unclear. Requires operator
  decision on model origin, licensing review, and download authorization.
  Not eligible for autonomous download under any circumstance.

- **GLM-4.5-Air** — specific version not available. The present
  `glm-4.7-flash-abliterated` is a different model and cannot substitute.
  Operator must decide whether GLM-4.5-Air is still the target or if the
  candidate should be revised. Note: GLM models originate from Zhipu AI
  (China) — no sanctioned-jurisdiction concern, but operator should confirm
  licensing and compliance posture.

### 6.3 Present candidates already serving their declared role

- **qwen3-banxe** — present on evo2 as domain-adapted variant. However, this
  is a 235B-class model, which may be oversized for the "domain-specific
  reasoning" tier if the intent was a lightweight specialist. Role alignment
  should be discussed in Sprint 4.

- **qwen3:235b** — present on evo2 via both ollama and llama-server. Already
  serving the maximum reasoning role. Operational and stable (running since
  2026-05-09).

---

## 7. Decision

**Sprint 3: CLOSED (review pass complete)**

The candidate matrix review is complete. Drift is consistent with Sprint 2
findings — no regression, no surprise changes. The 3 absent candidates remain
absent by design (gated by Sprint 4 prerequisites and operator decisions).

No updates to `innovation-sandbox-roadmap-2026-05-11.md` are required — the
declared matrix remains the target state, and the drift is expected and
documented in this review artifact.

**Next: Sprint 4 review pass** — ML track opening criteria readiness check.
Sprint 4 is gated on Conditions A–D from
`docs/audit/ml-track-opening-criteria-2026-05-11.md`.
