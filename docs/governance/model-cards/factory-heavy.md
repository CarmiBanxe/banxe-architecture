# Model Card — factory-heavy (alias)  (DRAFT — pending operator/CRO approval)

> **DRAFT — pending operator/CRO approval.** Verifiable fields from the live ssh/ollama audit + `docs/canon/HW-MODEL-UPGRADE-matrix.md` + `docs/runbooks/factory-routing-map.md` + `MODEL-RISK-MANAGEMENT.md` §3. Operator/CRO fields left **AWAITS OPERATOR** — no model id, quant, threshold, classification, or backend invented. Per `docs/governance/model-cards/TEMPLATE.md`; validated by `make mrm`.


---


## 1. Identity
- **Model / alias:** `factory-heavy (alias)`
- **Role in canon:** LiteLLM alias — heavy-reasoning factory route.
- **MRM tier (inferred):** **T2 — Reasoning / advisory (long-form planning / ADR / dense reasoning; human-reviewed, NOT auto-executing)** (MRM §3; inferred from role).
- **Binding regulatory classification:** **AWAITS OPERATOR** (operator/CRO; the inferred tier is not a binding FCA/EBA classification — MRM §3).

## 2. Provenance
- **Alias resolution:** **alias → `llama3.3:70b`** — factory-heavy → llama3.3:70b, evo1+evo2 :11434 LB (factory-routing-map). The backing model also holds a T1 card (`llama3.3-70b.md`) for its Project-Guardian role; the factory-heavy alias is the T2 reasoning route to the same weights..
- **Source / weights:** the backing ollama model `llama3.3:70b` (verified present via `ollama list`). Callers use the alias only — no direct model IDs in caller config.
- **Size:** 42 GB (backing) (HW-MODEL-UPGRADE-matrix.md).
- **Quantization:** not asserted in repo (HW-matrix size-only for llama3.3:70b).
- **Host / route:** evo1+evo2 :11434 LB (HW-matrix / factory-routing-map).
- **Backend routing divergence:** N/A unless reconciled by operator (see MRM §3 ai-heavy note for the one known divergence).

## 3. Intended use & boundaries
- **Intended use:** heavy reasoning / architecture-level factory work — advisory, human-reviewed.
- **Out of scope / non-goals:** advisory only — MUST NOT auto-execute a regulated decision; output is human-reviewed (not auto-merging).
- **Human-in-the-loop:** operator review for any compliance-adjacent use; no autonomous regulated action.

## 4. Evaluation & limitations
- **Validation mechanism (existing):** Guardian (deterministic rules) + Canon Judge (ADR-025, **audit-only** today) — MRM §4/§5.
- **Eval results:** see `llama3.3-70b.md`.
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
