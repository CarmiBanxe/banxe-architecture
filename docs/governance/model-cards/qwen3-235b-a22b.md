# Model Card — qwen3:235b-a22b  (DRAFT — pending operator/CRO approval)

> **DRAFT — pending operator/CRO approval.** Verifiable fields from the live ssh/ollama audit + `docs/canon/HW-MODEL-UPGRADE-matrix.md` + `docs/runbooks/factory-routing-map.md` + `MODEL-RISK-MANAGEMENT.md` §3. Operator/CRO fields left **AWAITS OPERATOR** — no model id, quant, threshold, classification, or backend invented. Per `docs/governance/model-cards/TEMPLATE.md`; validated by `make mrm`.


---


## 1. Identity
- **Model / alias:** `qwen3:235b-a22b`
- **Role in canon:** reasoning master — backing model for the `reasoning`/`project-reason` aliases.
- **MRM tier (inferred):** **T2 — Reasoning / advisory (long-form planning / ADR / dense reasoning; human-reviewed, NOT auto-executing)** (MRM §3; inferred from role).
- **Binding regulatory classification:** **AWAITS OPERATOR** (operator/CRO; the inferred tier is not a binding FCA/EBA classification — MRM §3).

## 2. Provenance
- **Source / weights:** `ollama` model `qwen3:235b-a22b` (verified present via `ollama list`).
- **Size:** 142 GB (HW-MODEL-UPGRADE-matrix.md).
- **Quantization:** **Q3_K_S** (asserted, HW-matrix).
- **Host / route:** **evo2 ONLY** (canonical max, IL-CANON-OPERATOR-2026-05 #3) (HW-matrix / factory-routing-map).
- **Backend routing divergence:** N/A unless reconciled by operator (see MRM §3 ai-heavy note for the one known divergence).

## 3. Intended use & boundaries
- **Intended use:** dense compliance/architecture reasoning, MLRO-escalation explanation, cross-repo planning — human-reviewed, not auto-executing.
- **Out of scope / non-goals:** advisory only — MUST NOT auto-execute a regulated decision; output is human-reviewed (not auto-merging).
- **Human-in-the-loop:** operator review for any compliance-adjacent use; no autonomous regulated action.

## 4. Evaluation & limitations
- **Validation mechanism (existing):** Guardian (deterministic rules) + Canon Judge (ADR-025, **audit-only** today) — MRM §4/§5.
- **Eval results:** placeholder — AWAITS OPERATOR (no model-level benchmark asserted).
- **Known limitations:** *placeholder — AWAITS OPERATOR* (drift/calibration not measured in repo).
- **Independent validation (SR 11-7):** **AWAITS OPERATOR** (MRM §5) — applies primarily to T1; recorded for completeness.

## 5. Lifecycle controls (existing mechanisms — MRM §4)
- **Deployment gate:** Operator gate (MEDIUM) for reasoning/advisory work — P4 Audit Pack + P5 Evidence Pack where applicable.
- **Monitoring:** LiteLLM request logging + immutable audit logs (INV-07: 5-year TTL, ClickHouse).
- **Monitoring thresholds (drift / hallucination / accuracy-decay / calibration):** **AWAITS OPERATOR** (MRM §6).
- **Decommission:** `ollama rm` = destructive op → **per-model operator confirmation** (G-CLUSTER-03; HW-matrix §3.2).

## 6. Provenance of this card
- **Author / date:** Factory (S-MRM T2/T3 cards) / 2026-06-26 — **DRAFT**. · **Review cycle:** annually *(proposed)*. · **Owner:** **CRO — AWAITS OPERATOR**.
- **Refs:** `docs/governance/MODEL-RISK-MANAGEMENT.md` (§3-§6); `docs/canon/HW-MODEL-UPGRADE-matrix.md` (size/placement/quant); `docs/runbooks/factory-routing-map.md` (alias→model); `scripts/mrm-validate.sh`.
