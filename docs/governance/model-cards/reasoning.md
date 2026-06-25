# Model Card — reasoning (alias)  (DRAFT — pending operator/CRO approval)

> **DRAFT — pending operator/CRO approval.** Verifiable fields from the live ssh/ollama audit + `docs/canon/HW-MODEL-UPGRADE-matrix.md` + `docs/runbooks/factory-routing-map.md` + `MODEL-RISK-MANAGEMENT.md` §3. Operator/CRO fields left **AWAITS OPERATOR** — no model id, quant, threshold, classification, or backend invented. Per `docs/governance/model-cards/TEMPLATE.md`; validated by `make mrm`.


---


## 1. Identity
- **Model / alias:** `reasoning (alias)`
- **Role in canon:** LiteLLM alias — legacy alias for `project-reason`.
- **MRM tier (inferred):** **T2 — Reasoning / advisory (long-form planning / ADR / dense reasoning; human-reviewed, NOT auto-executing)** (MRM §3; inferred from role).
- **Binding regulatory classification:** **AWAITS OPERATOR** (operator/CRO; the inferred tier is not a binding FCA/EBA classification — MRM §3).

## 2. Provenance
- **Alias resolution:** **alias → `qwen3:235b-a22b (Q3_K_S)`** — reasoning / reasoning-235b → qwen3-235b-Q3_K_S, evo2 :8082 (factory-routing-map).
- **Source / weights:** the backing ollama model `qwen3:235b-a22b (Q3_K_S)` (verified present via `ollama list`). Callers use the alias only — no direct model IDs in caller config.
- **Size:** inherit backing (HW-MODEL-UPGRADE-matrix.md).
- **Quantization:** inherit backing.
- **Host / route:** evo2 :8082 (HW-matrix / factory-routing-map).
- **Backend routing divergence:** N/A unless reconciled by operator (see MRM §3 ai-heavy note for the one known divergence).

## 3. Intended use & boundaries
- **Intended use:** reasoning route (legacy alias); resolves to the 235b reasoning master.
- **Out of scope / non-goals:** advisory only — MUST NOT auto-execute a regulated decision; output is human-reviewed (not auto-merging).
- **Human-in-the-loop:** operator review for any compliance-adjacent use; no autonomous regulated action.

## 4. Evaluation & limitations
- **Validation mechanism (existing):** Guardian (deterministic rules) + Canon Judge (ADR-025, **audit-only** today) — MRM §4/§5.
- **Eval results:** see `qwen3-235b-a22b.md`.
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
